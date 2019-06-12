library(shiny)
library(RColorBrewer)
library(shinyWidgets)
library(leaflet)
library(tidyverse)
library(httr)
library(rjson)
library(jsonlite)
library(sp)


api_key <- "65c3453db582c1a3e7c1465d1b6910a2takos1026"
url_addr <- "https://dapi.kakao.com/v2/local/search/address.json"
url_ctgr <- "https://dapi.kakao.com/v2/local/search/category.json"


sw_station <- readRDS("data/sw_clustr_result.rds")
sw_station_nm <- sw_station$name %>% unique() %>% sort()

pal <- colorFactor(palette = c("red", "darkgreen", "navy", "orange", "purple", "skyblue"), domain =  as.factor(sw_station$cluster))
