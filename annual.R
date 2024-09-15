library(tidyverse)
library(rvest)
library(lubridate)

URL = "https://www.data.jma.go.jp/obd/stats/etrn/view/annually_s.php?prec_no=84&block_no=47843&year=&month=&day=&view=p1"
URL = "https://www.data.jma.go.jp/obd/stats/etrn/view/annually_s.php?prec_no=84&block_no=47817&year=&month=&day=&view=p1"
check_bad_data = function(x) {
  chk = function(x, pattern) {str_detect(x, pattern) %>% sum()}
  badvals = c("]", "×", "///")
  y = sapply(x, chk, pattern = badvals)
  x[y>0] = NA
  x
}


out = read_html(URL)
out = out %>% html_nodes(xpath = '//*[@id="tablefix1"]')
df = out %>% html_table(fill = TRUE) %>% magrittr::extract2(1)

windn = names(df[-2, ]) %>% str_detect("風向・風速") %>% which()
hpan  = names(df[-2, ]) %>% str_detect("気圧") %>% which()

weather = df[-3, ] %>% as_tibble(.name_repair="universal") %>%
  select(1,4,5,6,
         8,11,12, 13,
         15,16,18,20) %>%
  rename_all(~c("year", "total_rain", "max_daily_rain", "max_hourly_rain",
                "temperature", "high_temperature", "low_temperature", "humidity",
                "wind", "max_wind", "gust", "insol")) %>%
  slice(-c(1,2)) %>%
  mutate_all(~check_bad_data(.)) %>%
    mutate_all(as.numeric)
library(mice)
weather2 = mice(weather, m = 50)
mice::complete(weather2) %>% as_tibble() %>% print(n = 20)

complete(weather2) %>% as_tibble() %>%
ggplot(aes(x = year, y = insol)) +
  geom_point(aes(color = "impute")) +
  geom_point(aes(color = "original"), data = weather) +
  geom_smooth(method = "gam",
              formula = y~s(x, bs = "gp", k = 7),
              method.args = list(family = gaussian()))

