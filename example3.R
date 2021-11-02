library(tidyverse)
library(rvest) # HTMLの読み込みに必要
library(lubridate)

fukue = read_csv("fukue_2017to2019_10.csv")
arikawa = read_csv("arikawa_2017to2019_10.csv")

# arikawa %>% filter(year(datetime) == 2017) %>% select(-X1) %>% write_csv("Arikawa_2017.csv")


library(sugrrants)

# p1 = fukue %>% mutate(year = year(datetime)) %>%
#   filter(year == 2017) %>%
#   mutate(date = as_date(datetime)) %>%
#   ggplot() +
#   geom_point(aes(x = H, y = hpa)) +
#   facet_calendar(date)
# ggsave(file = "fukue2017.png", p1, width = 841, height = 594, units="mm")
# p2 = fukue %>% mutate(year = year(datetime)) %>%
#   filter(year == 2018) %>%
#   mutate(date = as_date(datetime)) %>%
#   ggplot() +
#   geom_point(aes(x = H, y = hpa)) +
#   facet_calendar(date)
# ggsave(file = "fukue2018.png", p1, width = 841, height = 594, units="mm")
# p3 = fukue %>% mutate(year = year(datetime)) %>%
#   filter(year == 2019) %>%
#   mutate(date = as_date(datetime)) %>%
#   ggplot() +
#   geom_point(aes(x = H, y = hpa)) +
#   facet_calendar(date)
# ggsave(file = "fukue2019.png", p1, width = 841, height = 594, units="mm")



p1 = arikawa %>% mutate(year = year(datetime)) %>%
  filter(year == 2017) %>%
  mutate(date = as_date(datetime)) %>%
  ggplot() +
  geom_point(aes(x = H, y = wind)) +
  facet_calendar(date)
ggsave(file = "arikawa2017.png", p1, width = 841, height = 594, units="mm")
p2 = arikawa %>% mutate(year = year(datetime)) %>%
  filter(year == 2018) %>%
  mutate(date = as_date(datetime)) %>%
  ggplot() +
  geom_point(aes(x = H, y = wind)) +
  facet_calendar(date)
ggsave(file = "arikawa2018.png", p1, width = 841, height = 594, units="mm")
p3 = arikawa %>% mutate(year = year(datetime)) %>%
  filter(year == 2019) %>%
  mutate(date = as_date(datetime)) %>%
  ggplot() +
  geom_point(aes(x = H, y = wind)) +
  facet_calendar(date)
ggsave(file = "arikawa2019.png", p1, width = 841, height = 594, units="mm")



