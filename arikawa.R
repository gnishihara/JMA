# Fukue weather data (there is no data for Arikawa)
# 2021 Nov 02
# Greg Nishihara
#
library(tidyverse)
library(rvest) # HTMLの読み込みに必要
library(lubridate)
source("prec_and_block.R")
source("scrape_jma_table.R")

prec_no = read_csv("list_of_prec_no.csv")
block_no = scrape_block_no(prec_no = 84)
bn = block_no %>% filter(str_detect(block, "福江"))

################################################################################
fnames = dir("~/Lab_Data/weather/", pattern = "Fukue*.*rds", full = TRUE)

fnames = tibble(fnames) |>
  mutate(ff = map(fnames, file.info)) |>
  unnest(ff) |>
  filter(near(mtime, max(mtime))) |> pull(fnames)

d1 = read_rds(fnames)

d1 |> filter(as_date(datetime) == "2023-07-19")

basetibble = tibble(prec_no = bn$prec_no, block_no = bn$block_no, kubun = bn$kubun)
d1last = d1 |> slice_tail(n = 1) |>
  transmute(year = year(datetime), month = month(datetime))
d2 = bind_cols(basetibble, d1last) |> bm()


if(!is.null(d2)) {
  d2 = d2 |>
    mutate(day = map(month, function(x) {
      1:days_in_month(x)
    })) %>% unnest(day) %>%
    mutate(data = pmap(list(year, month, day, prec_no, block_no, kubun), get_hpa))

  d2 = d2 |> select(block_no, data) %>% unnest(data)
  d2 |> tail()

  all = bind_rows(d1, d2)
  all = all |> mutate(H = hour(datetime) + minute(datetime)/60)

  sdate = all |> slice_head() |> mutate(date = as_date(datetime)) |> pull(date) |> str_remove_all("-")
  edate = all |> slice_tail(n = 1) |> mutate(date = as_date(datetime)) |> pull(date) |> str_remove_all("-")
  folder = "~/Lab_Data/weather/"

  oname = str_glue("{folder}{sdate}_{edate}_Fukue_JMA_Data.rds")
  all |> write_rds(oname)

  oname = oname |> str_replace("rds", "csv")
  all |> write_csv(oname)

}

# The RDS files were wrong.
# Temporary fix 2022 Aug 23
wind_pattern = c("北"="N", "南" = "S", "東" = "E", "西" = "W")

rds = str_subset(fnames, "202208") |> read_rds()
oname = str_subset(fnames, "202208")

rds |> mutate(hpa = ifelse(is.na(hpa), kpa * 10, hpa)) |>
  mutate(wind_direction = ifelse(is.na(wind_direction), str_replace_all(wind_dir, wind_pattern), wind_direction)) |>
  mutate(rain = ifelse(is.na(rain), rainfall, rain), wind = ifelse(is.na(wind), wind_speed, wind)) |>
  select(block, datetime, hpa, rain, temperature_air, wind, gust, wind_direction, gust_direction, H) |>
  write_rds(oname)









