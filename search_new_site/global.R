library(shiny)
library(RColorBrewer)
library(shinyWidgets)
library(leaflet)
library(tidyverse)
library(httr)
library(rjson)
library(jsonlite)
library(sp)




sw_station <- readRDS("data/sw_clustr_result.rds")
sw_station_nm <- sw_station$name %>% unique() %>% sort()

pal <- colorFactor(palette = c("red", "darkgreen", "navy", "orange", "purple", "skyblue"), domain =  as.factor(sw_station$cluster))
