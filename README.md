# 気象庁の過去のデータ検索サイトからデータ抽出するコード

* `prec_and_block.R` スクリプトには、都道府県のID番号とそれぞれの都道府県に存在する気象台・アメダスなどのステーションIDを抽出するための関数があります。

* `scrape_jma_table.R` スクリプトには、データを抽出するための関数があります。

## 使いかた

いまのところ、１０分間隔のデータを抽出するための関数しか準備していません。
まず、パッケージの読み込みと２つのスクリプトの読み込みをしてください。
では、都道府県のIDが必要です。
ID番号は先にCSVファイル (`list_of_prec_no.csv`) として保存していますので、このファイルを読み込んでください。

サイトのIDが分からない場合、`scrape_block_no()` に `prec_no` を渡しましょう。
長崎県の場合、`prec_no = 84` です。`block_no`に結果を書き込んだので、中身を確認すれば、`block_no` を特定できます。

あとは、年月日の指定です。

## 例
```
library(tidyverse) 
library(rvest) # HTMLの読み込みに必要
library(lubridate)

source("prec_and_block.R")
source("scrape_jma_table.R")

prec_no = read_csv("list_of_prec_no.csv")
block_no = scrape_block_no(prec_no = 84)

fukue20190820 = block_no %>%
  filter(str_detect(block, "福江")) %>%
  mutate(year = 2019, month = 8, day = 20) %>%
  mutate(data = pmap(list(year, month, day, prec_no, block_no, kubun), get_hpa)) %>%
  select(block, data)

fukue20190820 %>% unnest(data)
```

`prec_no = read_csv("list_of_prec_no.csv")`
