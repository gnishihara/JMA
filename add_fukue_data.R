#
library(tidyverse)
library(rvest) # HTMLの読み込みに必要
library(lubridate)
source("prec_and_block.R")
source("scrape_jma_table.R")
library(furrr)
plan(multisession(workers = 7))

prec_no = read_csv("list_of_prec_no.csv")
block_no = scrape_block_no(prec_no = 84)
bn = block_no %>% filter(str_detect(block, "福江"))

################################################################################
basetibble = tibble(prec_no = bn$prec_no, block_no = bn$block_no, kubun = bn$kubun)
dout0 = read_rds("fukue_jma_dataset.rds")
start_date = dout0 |> last() |> pull(datetime) |> floor_date("months")
end_date = today()-days(1)
print(end_date)

dout = tibble(prec_no = bn$prec_no, block_no = bn$block_no, kubun = bn$kubun,
              datetime = seq(start_date, as_datetime(end_date), by = "days")) |>
  mutate(data = future_pmap(list(year(datetime), month(datetime), day(datetime), prec_no, block_no, kubun), get_hpa))

dout |> tail()

file.copy("fukue_jma_dataset.rds", str_c("fukue_jma_dataset_until_", start_date, ".rds"))

dout0 |>
  filter(datetime < start_date) |>
  bind_rows(dout) |>
  write_rds("fukue_jma_dataset.rds")

file.copy("fukue_jma_dataset.rds",
          "~/Lab_Data/weather/fukue_jma_dataset.rds",
          overwrite = TRUE)

