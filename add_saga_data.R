# Saga, Saga Data
library(tidyverse)
library(rvest) # HTMLの読み込みに必要
library(lubridate)
source("prec_and_block.R")
source("scrape_jma_table.R")

prec_no = read_csv("list_of_prec_no.csv")
block_no = scrape_block_no(prec_no = 85)
bn =　
  block_no |>
  filter(str_detect(block, "佐賀"))
############################################################
basetibble = tibble(
  prec_no = bn$prec_no,
  block_no = bn$block_no,
  kubun = bn$kubun
)

fname = "saga_jma_dataset"
oname = str_replace(fname, "dataset", "dataset_until_")
fname = str_c(fname, ".rds")
file.exists(fname)
if (file.exists(fname)) {
  dout0 = read_rds(fname)
  dout0 = dout0 |> drop_na(datetime)
  start_date = dout0 |> last() |> pull(datetime) |> floor_date("months")
  outname = str_c(oname, start_date, ".rds")
  file.copy(fname, outname)
} else {
  start_date = ymd("2021-01-01")
}

end_date = today() - days(1)
end_date = start_date + years(2)

datetime_sequence = seq(start_date, end_date, by = "days")

dout = tibble(
  prec_no = bn$prec_no,
  block_no = bn$block_no,
  kubun = bn$kubun,
  datetime = datetime_sequence
)

dout = dout |>
  mutate(data = pmap(list(
    year(datetime),
    month(datetime),
    day(datetime),
    prec_no,
    block_no,
    kubun
  ), get_hpa))

if (any(grepl("^dout0$", ls()))) {
  dout0 |>
    filter(datetime < start_date) |>
    bind_rows(dout) |>
    distinct() |>
    write_rds(fname)
} else {
  dout |>
    distinct() |>
    write_rds(fname)
}

outfile = str_c("~/Lab_Data/weather/", fname)
file.copy(fname, outfile, overwrite = TRUE)
sprintf("Added data from %s to %s to %s",
        start_date, end_date, fname)
