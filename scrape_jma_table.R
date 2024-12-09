# Reading meteorological data from the kishocho site.
# Greg Nishihara
# 2019 Oct 30
# updated 2022 Feb 2 to include the polite package.
# 参考URL:
# https://www.r-bloggers.com/using-rvest-to-scrape-an-html-table/
# https://codeday.me/jp/qa/20190408/516767.html

# Packages and sourced files -----------------------------------------
library(tidyverse)
library(polite)
library(rvest)
library(lubridate)
source("prec_and_block.R")

# Functions ----------------------------------------------------------

check_bad_data = function(x) {
  chk = function(x, pattern) {str_detect(x, pattern) %>% sum()}
  badvals = c("]", "×", "///")
  y = sapply(x, chk, pattern = badvals)
  x[y>0] = NA
  x
}
year = 2023
month = 7
day = 19
prefecture = 84
site = 47843
kubun = "s"

get_hpa = function(year, month, day, prefecture = 84, site = 47843, kubun = "s") {
  wind_pattern = c("北"="N", "南" = "S", "東" = "E", "西" = "W")
  URL = paste("http://www.data.jma.go.jp/obd/stats/etrn/view/10min_",
              kubun,
              "1.php?",
              "prec_no=", prefecture,
              "&block_no=", site,
              "&year=", year,
              "&month=", month,
              "&day=", day,
              "&view=",sep="")
  session = bow(URL, force = TRUE)
  out = scrape(session)
  out = out %>% html_nodes(xpath = '//*[@id="tablefix1"]')
  check_validity = out %>% html_name() %>% length()
  if(check_validity == 0) stop("Site and prefecture does not match.")

  df = out %>% html_nodes(xpath = '//*[@id="tablefix1"]') %>%
    html_table(fill = TRUE) %>% magrittr::extract2(1)

  windn = names(df[-1, ]) %>% str_detect("風向・風速") %>% which()
  hpan  = names(df[-1, ]) %>% str_detect("気圧") %>% which()

  df[-1, ] %>%
    as_tibble(.name_repair="unique_quiet") %>%
    select(datetime = contains("時分"),
           hpa = matches(paste0("^気.*", hpan[2])),
           rain = contains("降水量"),
           temperature_air = contains("気温"),
           wind = matches(paste0("^風.*",windn[1])),
           gust = matches(paste0("^風.*",windn[3])),
           wind_direction = matches(paste0("^風.*",windn[2])),
           gust_direction = matches(paste0("^風.*",windn[4]))
           ) %>%
    mutate_all(~check_bad_data(.)) %>%
    mutate_at(vars(-contains("direction"), -datetime),
              ~str_extract(., "[0-9]+\\.[0-9]+")) %>%
    mutate_at(vars(-contains("direction"), -datetime), as.numeric) %>%
    mutate_at(vars(contains("direction")),
              ~str_replace_all(., wind_pattern)) %>%
    mutate(datetime = ymd_hm(str_glue("{year}-{month}-{day} {datetime}"))) |>
    drop_na(datetime)
}


build_month = function(df, test = NULL) {
  y = df$year
  m = df$month
  thismonth = today() |> month()
  thisyear = today() |> year()
  if(near(thisyear, y) & near(thismonth, m)) {stop("Data was downloaded.")}
  if(!is.null(test)) {thismonth = test}
  y = y:thisyear
  N = length(y)
  if(N > 2) {
    middlevalues = replicate(N - 2, 1:12, simplify = FALSE)
    z = c(list(m:12), middlevalues, list(1:(thismonth-1)))
  }  else if(N <= 2 & N > 1) {
    z = list(m:12, 1:(thismonth-1))
  } else if(near(N, 1)) {
    if(m < thismonth) {
      z = list(m:(thismonth-1))
    } else {
      z = list(1:(thismonth-1))
    }
  }
  bind_cols(df |> select(-year, -month), tibble(year = y, month = z)) |> unnest(month)
}
bm = possibly(build_month, otherwise = NULL, quiet = FALSE)
