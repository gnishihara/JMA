# Reading meteorological data from the kishocho site.
# Greg Nishihara
# 2019 Oct 30
# 参考URL:
# https://www.r-bloggers.com/using-rvest-to-scrape-an-html-table/
# https://codeday.me/jp/qa/20190408/516767.html

# Packages and sourced files -----------------------------------------
library(tidyverse)
library(rvest)
library(lubridate)
source("prec_and_block.R")
source("scrape_jma_table.R")


prec_no = read_csv("list_of_prec_no.csv")
block_no = scrape_block_no()
block_no %>% print(n = Inf)

fukue20190820 = block_no %>%
  filter(str_detect(block, "福江")) %>%
  mutate(year = 2019, month = 8, day = 20) %>%
  mutate(data = pmap(list(year, month, day, prec_no, block_no, kubun), get_hpa)) %>%
  select(block, data)

fukue20190820 %>% unnest(data)
