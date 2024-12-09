# Reading the Iwate-Navi website
# Greg Nishihara
# 2024 Sep 28
# 参考URL:
# https://www.r-bloggers.com/using-rvest-to-scrape-an-html-table/
# https://codeday.me/jp/qa/20190408/516767.html

# Packages and sourced files -----------------------------------------
library(tidyverse)
library(polite)
library(rvest)
library(lubridate)

# Functions ----------------------------------------------------------
year = 2024
month = 9
day = 1



get_iwate = function(year, month, day) {
  URL = str_c("https://www.suigi.pref.iwate.jp/teichi/daily/report/",
        "/", year, "/", month, "/", day)
  session = bow(URL, force = TRUE)
  out = scrape(session)

  out = out |> html_nodes(xpath = '//*[@id="contents"]/table[1]') |>
    html_table(fill = TRUE) |>
    magrittr::extract2(1)

  location = out |> slice(2) |> gather(value = "location") # Location
  period = out |> slice(3) |> gather(value = "period") # Period
  df1 = full_join(location, period)

  df2 = out |>
    slice(-c(1:3)) |>
    filter(str_detect(X1, "時")) |>
    pivot_longer(-X1, names_to = "key")

  df0 = full_join(df1, df2) |>
    mutate(value = as.double(value))
  data_date = df0 |> filter(str_detect(location, "\\d{4}年")) |> pull(location)
  df0 = df0 |> filter(!str_detect(location, "\\d{4}年")) |>
    filter(str_detect(period, "当年"))

  df0 |>
    mutate(date = ymd(data_date), .before = "location") |>
    mutate(depth = str_extract(location, "\\d+"), .before = "location") |>
    mutate(site = str_extract(location, regex("^[一-龥々*]+")), .before = "location") |>
    mutate(hour = str_extract(X1, "\\d+")) |>
    mutate(depth = as.double(depth),
           hour = as.double(hour),
           datetime = (sprintf("%s %.2d", date , hour))) |>
    mutate(datetime = ymd_h(datetime)) |>
    select(site,depth, datetime, site, temperature = value)
}

year = 1994:2023
a1 = as_date("2017-01-01")
a2 = today()

dset = tibble(date = seq(a1,a2, by = "day")) |>
  mutate(year = year(date), month = month(date), day = day(date))
dset |> tail()

df1 = get_iwate(2024, 9, 24)

dset = dset |>
  mutate(data = pmap(list(year, month, day),
                     \(x, y, z) {
                       get_iwate(x, y, z)
                     }))

rdsname = str_c("iwate_navi_dataset_20170101-", str_remove_all(a2, "-"), ".csv")
dset |> unnest(data) |> write_csv(rdsname)

