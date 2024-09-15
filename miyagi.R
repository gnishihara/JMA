library(tidyverse)
library(polite) # HTMLの読み込みに必要
library(rvest) # HTMLの読み込みに必要
library(lubridate)

source("prec_and_block.R")
source("scrape_jma_table.R")

prec_no = read_csv("list_of_prec_no.csv")
block_no = scrape_block_no(prec_no = 34)

# Shiogama, Miyagi Prefecutre
# arikawa = block_no %>% filter(str_detect(block, "有川")) %>% slice(2)

# No mpa data in shiogama
basetibble = tibble(prec_no = 34, block_no = 1030, kubun = "a")
fnames = dir("~/Lab_Data/weather/", pattern = "Shiogama*.*rds", full = TRUE)
fnames = tibble(fnames) |>
  mutate(ff = map(fnames, file.info)) |>
  unnest(ff) |>
  filter(near(mtime, max(mtime))) |> pull(fnames)
d1 = read_rds(fnames)

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

  oname = str_glue("{folder}{sdate}_{edate}_Shiogama_JMA_Data.rds")
  all |> write_rds(oname)

  oname = oname |> str_replace("rds", "csv")
  all |> write_csv(oname)

}



# Also download ishimaki for hpa data.
basetibble = tibble(prec_no = 34, block_no = 47592, kubun = "s")
fnames = dir("~/Lab_Data/weather/", pattern = "Ishimaki*.*rds", full = TRUE)
fnames = tibble(fnames) |>
  mutate(ff = map(fnames, file.info)) |>
  unnest(ff) |>
  filter(near(mtime, max(mtime))) |> pull(fnames)
d1 = read_rds(fnames)
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

  oname = str_glue("{folder}{sdate}_{edate}_Ishimaki_JMA_Data.rds")
  all |> write_rds(oname)

  oname = oname |> str_replace("rds", "csv")
  all |> write_csv(oname)

}
