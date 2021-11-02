library(tidyverse)
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

shiogama19 =
  basetibble |>
  mutate(year = list(2019)) %>%
  unnest(year) %>%
  mutate(month = list(1:12)) %>%
  unnest(month) %>%
  mutate(day = map(month, function(x) {
    1:days_in_month(x)
  })) %>% unnest(day) %>%
  mutate(data = pmap(list(year, month, day, prec_no, block_no, kubun), get_hpa))

shiogama20 =
  basetibble |>
  mutate(year = list(2020)) %>%
  unnest(year) %>%
  mutate(month = list(1:12)) %>%
  unnest(month) %>%
  mutate(day = map(month, function(x) {
    1:days_in_month(x)
  })) %>% unnest(day) %>%
  mutate(data = pmap(list(year, month, day, prec_no, block_no, kubun), get_hpa))

shiogama21 =
  basetibble |>
  mutate(year = list(2021)) %>%
  unnest(year) %>%
  mutate(month = list(1:10)) %>%
  unnest(month) %>%
  mutate(day = map(month, function(x) {
    1:days_in_month(x)
  })) %>% unnest(day) %>%
  mutate(data = pmap(list(year, month, day, prec_no, block_no, kubun), get_hpa))

shiogama = bind_rows(shiogama19, shiogama20) %>% bind_rows(shiogama21)

shiogama =shiogama %>%
  select(block_no, data) %>%
  unnest(data) %>%
  mutate(H = hour(datetime) + minute(datetime)/60)

shiogama %>%
  write_csv("~/Lab_Data/weather/201901_202110_Shiogama_JMA_Data.csv")


# Also download ishimaki for hpa data.
basetibble = tibble(prec_no = 34, block_no = 47592, kubun = "s")

ishimaki19 =
  basetibble |>
  mutate(year = list(2019)) %>%
  unnest(year) %>%
  mutate(month = list(1:12)) %>%
  unnest(month) %>%
  mutate(day = map(month, function(x) {
    1:days_in_month(x)
  })) %>% unnest(day) %>%
  mutate(data = pmap(list(year, month, day, prec_no, block_no, kubun), get_hpa))

ishimaki20 =
  basetibble |>
  mutate(year = list(2020)) %>%
  unnest(year) %>%
  mutate(month = list(1:12)) %>%
  unnest(month) %>%
  mutate(day = map(month, function(x) {
    1:days_in_month(x)
  })) %>% unnest(day) %>%
  mutate(data = pmap(list(year, month, day, prec_no, block_no, kubun), get_hpa))

ishimaki21 =
  basetibble |>
  mutate(year = list(2021)) %>%
  unnest(year) %>%
  mutate(month = list(1:10)) %>%
  unnest(month) %>%
  mutate(day = map(month, function(x) {
    1:days_in_month(x)
  })) %>% unnest(day) %>%
  mutate(data = pmap(list(year, month, day, prec_no, block_no, kubun), get_hpa))

ishimaki = bind_rows(ishimaki19, ishimaki20) %>% bind_rows(ishimaki21)

ishimaki =ishimaki %>%
  select(block_no, data) %>%
  unnest(data) %>%
  mutate(H = hour(datetime) + minute(datetime)/60)

ishimaki %>%
  write_csv("~/Lab_Data/weather/201901_202110_Ishimaki_JMA_Data.csv")

