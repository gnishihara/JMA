library(tidyverse)
library(rvest) # HTMLの読み込みに必要
library(lubridate)

source("prec_and_block.R")
source("scrape_jma_table.R")

prec_no = read_csv("list_of_prec_no.csv")
block_no = scrape_block_no(prec_no = 84)
#
# arikawa = block_no %>% filter(str_detect(block, "有川")) %>% slice(2)
#
# arikawa2017 =
#   arikawa %>%
#   mutate(year = 2017) %>%
#   unnest(year) %>%
#   mutate(month = list(1:12)) %>%
#   unnest(month) %>%
#   mutate(day = map(month, function(x) {
#     1:days_in_month(x)
#   })) %>% unnest(day) %>%
#   mutate(data = pmap(list(year, month, day, prec_no, block_no, kubun), get_hpa)) %>%
#   select(block, data)
#
# arikawa2018 = arikawa %>%
#   mutate(year = 2018) %>%
#   unnest(year) %>%
#   mutate(month = list(1:12)) %>%
#   unnest(month) %>%
#   mutate(day = map(month, function(x) {
#     1:days_in_month(x)
#   })) %>% unnest(day) %>%
#   mutate(data = pmap(list(year, month, day, prec_no, block_no, kubun), get_hpa)) %>%
#   select(block, data)
#
# arikawa2019 = arikawa %>%
#   mutate(year = 2019) %>%
#   unnest(year) %>%
#   mutate(month = list(1:10)) %>%
#   unnest(month) %>%
#   mutate(day = map(month, function(x) {
#     1:days_in_month(x)
#   })) %>% unnest(day) %>%
#   mutate(data = pmap(list(year, month, day, prec_no, block_no, kubun), get_hpa)) %>%
#   select(block, data)


fukue = block_no %>% filter(str_detect(block, "福江"))

fukue2017 = fukue %>%
  mutate(year = 2017) %>%
  unnest(year) %>%
  mutate(month = list(1:12)) %>%
  unnest(month) %>%
  mutate(day = map(month, function(x) {
    1:days_in_month(x)
  })) %>% unnest(day) %>%
  mutate(data = pmap(list(year, month, day, prec_no, block_no, kubun), get_hpa)) %>%
  select(block, data)

fukue2018 = fukue %>%
  mutate(year = 2018) %>%
  unnest(year) %>%
  mutate(month = list(1:12)) %>%
  unnest(month) %>%
  mutate(day = map(month, function(x) {
    1:days_in_month(x)
  })) %>% unnest(day) %>%
  mutate(data = pmap(list(year, month, day, prec_no, block_no, kubun), get_hpa)) %>%
  select(block, data)

fukue2019 = fukue %>%
  mutate(year = 2019) %>%
  unnest(year) %>%
  mutate(month = list(1:10)) %>%
  unnest(month) %>%
  mutate(day = map(month, function(x) {
    1:days_in_month(x)
  })) %>% unnest(day) %>%
  mutate(data = pmap(list(year, month, day, prec_no, block_no, kubun), get_hpa)) %>%
  select(block, data)



# arikawa = arikawa2017 %>% bind_rows(arikawa2018) %>% bind_rows(arikawa2019)
fukue = fukue2017 %>% bind_rows(fukue2018) %>% bind_rows(fukue2019)

# arikawa = arikawa %>% unnest(data) %>% mutate(H = hour(datetime) + minute(datetime)/60)
fukue = fukue %>% unnest(data) %>% mutate(H = hour(datetime) + minute(datetime)/60)

# write.csv(arikawa, file = "arikawa_2017to2019_10.csv")
write.csv(fukue, file = "fukue_2017to2019_10.csv")
