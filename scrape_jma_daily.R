library(tidyverse)
library(polite)
library(rvest)
library(lubridate)
library(purrr)

check_bad_data = function(x) {
  chk = function(x, pattern) {str_detect(x, pattern) %>% sum()}
  badvals = c("]", "×", "///", "\\)", "--")
  y = sapply(x, chk, pattern = badvals)
  x[y>0] = NA
  x
}

convert_tab = function(df) {
  windn = names(df[-c(1:3), ]) |> str_detect("風向・風速") |> which()
  hpan  = names(df[-c(1:3), ]) |> str_detect("気圧") |> which()
  rainn  = names(df[-c(1:3), ]) |> str_detect("降水量") |> which()
  tempn  = names(df[-c(1:3), ]) |> str_detect("気温") |> which()
  wind_pattern = c("北"="N", "南" = "S", "東" = "E", "西" = "W")

  df[-c(1:3), ] |>
    # as_tibble(.name_repair="universal") |>
    as_tibble(.name_repair = ~ vctrs::vec_as_names(., repair = "universal", quiet = TRUE)) |>
    select(day = matches("^日$"),
           hpa = matches(paste0("^気.*", hpan[2])),
           rain = matches(paste0("^降水量.*", rainn[1])),
           temperature_air = matches(paste0("^気温.*", tempn[1])),
           wind = matches(paste0("^風.*",windn[1])),
           wind_max = matches(paste0("^風.*",windn[2])),
           gust = matches(paste0("^風.*",windn[4])),
           wind_direction = matches(paste0("^風.*",windn[3])),
           gust_direction = matches(paste0("^風.*",windn[5])),
           daylight = matches("日照時間")) |>
    mutate(across(!matches("(direction)"), check_bad_data))　|>
    mutate(across(-contains("direction"), as.numeric)) |>
    mutate(across(contains("direction"), ~str_replace_all(., wind_pattern)))
}

convert_table = possibly(convert_tab, otherwise = NA)

get_jma_table = function(kubun, prec_no, block_no, year, month) {
  baseurl = "https://www.data.jma.go.jp/obd/stats/etrn/view/"
  jmaurl = str_glue("{baseurl}daily_{kubun}.php?prec_no={prec_no}&block_no={block_no}&year={year}&month={month}&day=&view=")
  session = bow(jmaurl, force = TRUE)
  out = scrape(session, content = "text/html; charset=UTF-8")
  xpath = "/html/body/div[2]/div/div[2]/table"
  out = out |> html_nodes(xpath = xpath)
  check_validity = out |> html_name() |> length()
  if(check_validity == 0) stop("Site and prefecture does not match.")
  df = out |> html_nodes(xpath = xpath) |> html_table(fill = TRUE) |> magrittr::extract2(1)

  convert_table(df)

}


block_no = list("Fukue" = "47843", "Nagasaki" = "47817", "Sasebo" = "47812", "Hirado" = "47805")
kubun    = list("Fukue" = "s1", "Nagasaki" = "s1", "Sasebo" = "s1", "Hirado" = "s1")
dset = full_join(as_tibble(kubun) |> pivot_longer(cols = everything()),
                 as_tibble(block_no) |> pivot_longer(cols = everything()), by = "name") |>
  rename(kubun = value.x, block_no = value.y) |>
  mutate(prec_no = rep("84", 4))

syear = 2016
eyear = 2023

tmp = expand_grid(year = syear:eyear, month = 1:12) |>
  mutate(month = sprintf("%02d", month),
         year = as.character(year),
         ymd = ymd(str_glue("{year}-{month}-01"))) |>
  filter(ymd < floor_date(today(), "month"))

dset = dset |>mutate(tmp = list(tmp)) |> unnest(tmp)

dsetout = dset |> mutate(data = pmap(list(kubun, prec_no, block_no, year, month), get_jma_table, .progress = T))

dsetout2 = dsetout |> select(name, year, month, data) |>
  unnest(data) |>
  mutate(ymd = ymd(str_c(year, month, day)), .before = hpa) |>
  select(-c(year, month, day))


oname = str_glue("~/Lab_Data/weather/{syear}_{eyear}_Nagasaki_daily_s1.rds")
dsetout2 |> write_rds(file = oname)
dsetout2 |> write_excel_csv(str_replace(oname, "rds", "csv"))



