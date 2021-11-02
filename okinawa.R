library(tidyverse)
library(rvest) # HTMLの読み込みに必要
library(lubridate)

source("prec_and_block.R")
source("scrape_jma_table.R")

prec_no = read_csv("list_of_prec_no.csv")
block_no = scrape_block_no(prec_no = 84)

# arikawa = block_no %>% filter(str_detect(block, "有川")) %>% slice(2)

nago19 =
  tibble(prec_no = 91, block_no = 47940, kubun = "s") %>%
  mutate(year = list(2019)) %>%
  unnest(year) %>%
  mutate(month = list(1:12)) %>%
  unnest(month) %>%
  mutate(day = map(month, function(x) {
    1:days_in_month(x)
  })) %>% unnest(day) %>%
  mutate(data = pmap(list(year, month, day, prec_no, block_no, kubun), get_hpa))

nago20 =
  tibble(prec_no = 91, block_no = 47940, kubun = "s") %>%
  mutate(year = list(2020)) %>%
  unnest(year) %>%
  mutate(month = list(1:12)) %>%
  unnest(month) %>%
  mutate(day = map(month, function(x) {
    1:days_in_month(x)
  })) %>% unnest(day) %>%
  mutate(data = pmap(list(year, month, day, prec_no, block_no, kubun), get_hpa))

nago21 =
  tibble(prec_no = 91, block_no = 47940, kubun = "s") %>%
  mutate(year = list(2021)) %>%
  unnest(year) %>%
  mutate(month = list(1:10)) %>%
  unnest(month) %>%
  mutate(day = map(month, function(x) {
    1:days_in_month(x)
  })) %>% unnest(day) %>%
  mutate(data = pmap(list(year, month, day, prec_no, block_no, kubun), get_hpa))

nago = bind_rows(nago19, nago20) %>% bind_rows(nago21)

nago = nago %>%
  select(block_no, data) %>%
  unnest(data) %>%
  mutate(H = hour(datetime) + minute(datetime)/60)

nago %>%
  write_csv("~/Lab_Data/weather/201901_202110_Nago_JMA_Data.csv")

