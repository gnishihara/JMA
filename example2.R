library(tidyverse)
library(rvest) # HTMLの読み込みに必要
library(lubridate)

source("prec_and_block.R")
source("scrape_jma_table.R")

prec_no = read_csv("list_of_prec_no.csv")
block_no = scrape_block_no(prec_no = 84)

# arikawa = block_no %>% filter(str_detect(block, "有川")) %>% slice(2)

arikawa = block_no %>% filter(str_detect(block, "有川")) %>% slice(2) %>%
  mutate(year = list(2017:2020)) %>%
  unnest(year) %>%
  mutate(month = list(1:12)) %>%
  unnest(month) %>%
  mutate(day = map(month, function(x) {
    1:days_in_month(x)
  })) %>% unnest(day) %>%
  mutate(data = pmap(list(year, month, day, prec_no, block_no, kubun), get_hpa)) %>%
  select(block, data) %>%
  unnest(data) %>%
  mutate(H = hour(datetime) + minute(datetime)/60)

arikawa %>% write_csv("~/Lab_Data/weather/201701_202012_Arikawa_JMA_Data.csv")

arikawa2021 = block_no %>% filter(str_detect(block, "有川")) %>% slice(2) %>%
  mutate(year = 2021) %>%
  unnest(year) %>%
  mutate(month = list(1:5)) %>%
  unnest(month) %>%
  mutate(day = map(month, function(x) {
    1:days_in_month(x)
  })) %>% unnest(day) %>%
  mutate(data = pmap(list(year, month, day, prec_no, block_no, kubun), get_hpa)) %>%
  select(block, data)%>%
  unnest(data) %>%
  mutate(H = hour(datetime) + minute(datetime)/60)

arikawa2021 %>% write_csv(file = "~/Lab_Data/weather/202101_202105_Arikawa_JMA_Data.csv")


################################################################################
arikawa202009 = block_no %>% filter(str_detect(block, "有川")) %>% slice(2) %>%
  mutate(year = 2020) %>%
  unnest(year) %>%
  mutate(month = list(9)) %>%
  unnest(month) %>%
  mutate(day = map(month, function(x) {
    1:14
  })) %>% unnest(day) %>%
  mutate(data = pmap(list(year, month, day, prec_no, block_no, kubun), get_hpa)) %>%
  select(block, data)%>%
  unnest(data) %>%
  mutate(H = hour(datetime) + minute(datetime)/60)
arikawa202009 %>%  write_csv(path = "~/Lab_Data/weather/20209_01-14_Arikawa_JMA_Data.csv")

################################################################################


fukue = block_no %>% filter(str_detect(block, "福江"))

fukue = fukue %>%
  mutate(year = list(2017:2020)) %>%
  unnest(year) %>%
  mutate(month = list(1:12)) %>%
  unnest(month) %>%
  mutate(day = map(month, function(x) {
    1:days_in_month(x)
  })) %>% unnest(day) %>%
  mutate(data = pmap(list(year, month, day, prec_no, block_no, kubun), get_hpa)) %>%
  select(block, data)%>%
  unnest(data) %>%
  mutate(H = hour(datetime) + minute(datetime)/60)

fukueB = block_no %>% filter(str_detect(block, "福江")) %>%
  mutate(year = 2021) %>%
  unnest(year) %>%
  mutate(month = list(1:2)) %>%
  unnest(month) %>%
  mutate(day = map(month, function(x) {
    1:days_in_month(x)
  })) %>% unnest(day) %>%
  mutate(data = pmap(list(year, month, day, prec_no, block_no, kubun), get_hpa)) %>%
  select(block, data)%>%
  unnest(data) %>%
  mutate(H = hour(datetime) + minute(datetime)/60)

fukue %>% write_csv(file = "~/Lab_Data/weather/201701_202012_Fukue_JMA_Data.csv")
fukueB %>% write_csv(file = "~/Lab_Data/weather/202101_202102_Fukue_JMA_Data.csv")









