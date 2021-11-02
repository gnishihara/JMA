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

fnames = dir("~/Lab_Data/weather/", pattern = "Fukue*.*rds", full = TRUE)
d1 = read_rds(fnames)

basetibble = tibble(prec_no = bn$prec_no, block_no = bn$block_no, kubun = bn$kubun)

d1last = d1 |> slice_tail(n = 1) |>
  transmute(year = year(datetime), month = month(datetime))

d2 = bind_cols(basetibble, d1last) |>
  mutate(month = map(month, function(x) {
    thismonth = today() |> month()
    x:(thismonth - 1)
  })) |>
  unnest(month) |>
  mutate(day = map(month, function(x) {
    1:days_in_month(x)
  })) %>% unnest(day) %>%
  mutate(data = pmap(list(year, month, day, prec_no, block_no, kubun), get_hpa))

d2 = d2 |> select(block_no, data) %>% unnest(data)

all = bind_rows(d1, d2)
all = all |> mutate(H = hour(datetime) + minute(datetime)/60)

sdate = all |> slice_head() |> mutate(date = as_date(datetime)) |> pull(date) |> str_remove_all("-")
edate = all |> slice_tail(n = 1) |> mutate(date = as_date(datetime)) |> pull(date) |> str_remove_all("-")
folder = "~/Lab_Data/weather/"

oname = str_glue("{folder}{sdate}_{edate}_Fukue_JMA_Data.rds")
all |> write_rds(oname)

oname = oname |> str_replace("rds", "csv")
all |> write_csv(oname)


