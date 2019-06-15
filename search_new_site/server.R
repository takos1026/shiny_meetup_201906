


getAddressInfo <- function(address){
    api_key <- "65c3453db582c1a3e7c1465d1b6910a2"
    url_addr <- "https://dapi.kakao.com/v2/local/search/address.json"
    
    res <- GET(url = url_addr,
               add_headers(Authorization= paste0("KakaoAK ",api_key), 
                           Host = "dapi.kakao.com"), 
               query = list("query" = address)
    )
    temp_df <- res %>% content(as = 'text') %>% fromJSON()
    temp_df <- temp_df$documents
    temp_df$address[1,]
}


getSwstaionInfo <- function(ctgr_cd = "SW8", lon, lat, radius){
    api_key <- "65c3453db582c1a3e7c1465d1b6910a2"
    url_ctgr <- "https://dapi.kakao.com/v2/local/search/category.json"
    
    res <- GET(url = url_ctgr,
               add_headers(Authorization= paste0("KakaoAK ",api_key), 
                           Host = "dapi.kakao.com"), 
               query = list("category_group_code" = ctgr_cd,
                            "x" = lon,
                            "y" = lat,
                            "page" = 1,
                            "sort" = "distance",
                            "radius" = radius
               )
    )
    temp_df <- res %>% content(as = 'text') %>% fromJSON()
    temp_df <- temp_df$documents
    temp_df
}


getAroundInfo <- function(lon, lat, radius = 1000){
    
    df <- tibble()
    base_url <- "http://apis.data.go.kr/B553077/api/open/sdsc"
    sub_url <- "/storeListInRadius?" #반경내 업소조회
    key <- "eOPD27BF3hmd94YM9S4wmWZJlUJBInBKcNnpO33mFarHPLNpbV5FjX5JZLoyExtD7ajVIGkKeKCmnHLRjRgvHA%3D%3D"
    
    url <- paste0(base_url,
                  sub_url,
                  "radius=", radius,
                  "&cx=", lon,
                  "&cy=", lat,
                  "&ServiceKey=", key,
                  "&numOfRows=", "1000",
                  "&pageNo=", "1",
                  "&type=", "json")
    
    res <- GET(url = url)
    res <- res %>% content(as = 'text') %>% fromJSON()
    temp_df <- res$body$items
    df <- df %>% bind_rows(temp_df)
    
    if(res$body$totalCount > 1000) {
        available <- ceiling(res$body$totalCount/1000) - 1
        page_limit <- 1 + available
        for(i in 2:page_limit){
            url <- paste0(base_url,
                          sub_url,
                          "radius=", radius,
                          "&cx=", lon,
                          "&cy=", lat,
                          "&ServiceKey=", key,
                          "&numOfRows=", "1000",
                          "&pageNo=", i,
                          "&type=", "json")
            res <- GET(url = url)
            res <- res %>% content(as = 'text') %>% fromJSON()
            temp_df <- res$body$items
            df <- df %>% bind_rows(temp_df)

        }
    }
    
    
    df <- df %>% na.omit() %>% filter(indsLclsCd %in% c("Q", "S", "F", "R", "D")) %>% mutate(lon = as.numeric(lon), lat = as.numeric(lat))
    df
}


function(input, output, session){
    
    output$map <- renderLeaflet({  
        
        leaflet() %>% 
            setView(lng = 126.96474263398179, lat = 37.52977360379245, zoom = 12) %>% 
            addProviderTiles(provider = providers$CartoDB)
    })
    
    
    filteredData <- reactive({
        if(is.null(input$lines) == 0 & is.null(input$clust) == 0){
            sw_station2 <- sw_station %>% filter(name %in% input$lines & cluster %in% input$clust)
            sw_station2
        } else if(is.null(input$lines) == 1 & is.null(input$clust) == 0){
            sw_station2 <- sw_station %>% filter(cluster %in% input$clust)
            sw_station2
        } else if(is.null(input$lines) == 0 & is.null(input$clust) == 1){
            sw_station2 <- sw_station %>% filter(name %in% input$lines)
            sw_station2
            
        } else{
            sw_station2 <- sw_station
            sw_station2
        }
        
    })
  
    observe({
        leafletProxy("map") %>%
            clearMarkers() %>% 
            addCircleMarkers(data = filteredData(),
                             lng = ~as.numeric(lon), 
                             lat = ~as.numeric(lat), 
                             color = ~pal(as.factor(cluster)),
                             radius = 30 * (filteredData()$std_FD6_count + filteredData()$std_CE7_count) + 5,
                             stroke = F,
                             fillOpacity = 0.4, 
                             popup = ~swstation_name)
        
    })
    
    searchaddr <- eventReactive(input$addr_search,{
        
        address <- getAddressInfo(address = input$addr)
        address <- address %>% mutate(lon = as.numeric(x), lat = as.numeric(y))
        
        closeto <- getSwstaionInfo(ctgr_cd = "SW8", lon = address$lon[1], lat = address$lat[1], radius = 2000)
        around <- getAroundInfo(lon = address$lon[1], lat = address$lat[1])
        
        if(nrow(around) > 0 & nrow(closeto) > 0) {
            ls <- list("location" = address, "around" = around, "close_sw" = closeto)
            ls
            
        } else if(nrow(around) > 0 & nrow(closeto) == 0){
            closeto <- getSwstaionInfo(ctgr_cd = "SW8", lon = address$lon[1], lat = address$lat[1], radius = 5000)
            ls <- list("location" = address, "around" = around, "close_sw" = closeto)  
            ls 
            
        } else if(nrow(around) == 0 & nrow(closeto) > 0){
            around <- getAroundInfo(lon = address$lon[1], lat = address$lat[1], radius = 2000)
            ls <- list("location" = address, "around" = around, "close_sw" = closeto)
            ls
        } else {
            around <- getAroundInfo(lon = address$lon[1], lat = address$lat[1], radius = 2000)
            closeto <- getSwstaionInfo(ctgr_cd = "SW8", lon = address$lon[1], lat = address$lat[1], radius = 5000)
            ls <- list("location" = address, "around" = around, "close_sw" = closeto)
            ls
        }
    }, ignoreNULL = T)
    
    observe({
        
        # indsSclsCd / D03A01 : 편의점
        # indsSclsCd / F01A01 : 미용실
        # indsMclsCd / Q12 : 카페
        # indsMclsCd / Q09 : 유흥주점
        # indsSclsCd / R08A02 : 어린이집
        # indsLclsCd / S : 의료
        food <- searchaddr()$around %>% filter(indsLclsCd == "Q"& indsMclsCd != "Q09" & indsMclsCd != "Q12") 
        cafe <- searchaddr()$around %>% filter(indsMclsCd == "Q12") 
        hospital <- searchaddr()$around %>% filter(indsLclsCd == "S"& indsSclsCd != "S04A02") 
        pat <- searchaddr()$around %>% filter(indsSclsCd == "S04A02") 
        kindergarten <- searchaddr()$around %>% filter(indsSclsCd == "R08A02") 
        drink <- searchaddr()$around %>% filter(indsMclsCd == "Q09") 
        hair <- searchaddr()$around %>% filter(indsSclsCd == "F01A01")
        cvs <- searchaddr()$around %>% filter(indsSclsCd == "D03A01")

        leafletProxy("map") %>% 
            #clearMarkers() %>%
            addAwesomeMarkers(data = searchaddr()$location,
                              lng = ~as.numeric(x), 
                              lat = ~as.numeric(y), 
                              icon = awesomeIcons(icon = "home", library = "fa", markerColor = "red"), label = "우리집", group = "POI") %>%
            #addMarkers(data = searchaddr()$close_sw, lng = searchaddr()$close_sw@coords[,1], lat = searchaddr()$close_sw@coords[,2], icon = icon("fas fa-subway", lib = "font-awesome")) %>%
            addAwesomeMarkers(data = searchaddr()$close_sw,
                              lng = ~as.numeric(x), 
                              lat = ~as.numeric(y), 
                              popup = paste0(searchaddr()$close_sw$place_name, "<br/>",searchaddr()$close_sw$distance, "m"),
                              icon = awesomeIcons(icon = "subway", library = "fa", iconColor = "black", markerColor = "lightgray")) %>%
            addAwesomeMarkers(data = food,
                              lng = ~lon,
                              lat = ~lat,
                              icon = awesomeIcons(icon = "glass", library = "fa", iconColor = "black", markerColor = "darkblue"),
                              group = "음식점") %>%
            addAwesomeMarkers(data = cafe,
                              lng = ~lon,
                              lat = ~lat,
                              icon = awesomeIcons(icon = "coffee", library = "fa", iconColor = "black", markerColor = "lightred"),
                              group = "카페") %>%
            addAwesomeMarkers(data = hospital,
                              lng = ~lon,
                              lat = ~lat,
                              icon = awesomeIcons(icon = "medkit", library = "fa", markerColor = "lightblue"),
                              group = "병원") %>%
            addAwesomeMarkers(data = kindergarten,
                              lng = ~lon,
                              lat = ~lat,
                              icon = awesomeIcons(icon = "child", library = "fa", iconColor = "black", markerColor = "lightgreen"),
                              group = "어린이집") %>%
            addAwesomeMarkers(data = pat,
                              lng = ~lon,
                              lat = ~lat,
                              icon = awesomeIcons(icon = "paw", library = "fa", iconColor = "black", markerColor = "lightblue"),
                              group = "동물병원") %>%
            addAwesomeMarkers(data = drink,
                              lng = ~lon,
                              lat = ~lat,
                              icon = awesomeIcons(icon = "beer", library = "fa", iconColor = "black", markerColor = "orange"),
                              group = "유흥주점") %>%
            addAwesomeMarkers(data = hair,
                              lng = ~lon,
                              lat = ~lat,
                              icon = awesomeIcons(icon = "cut", library = "fa", iconColor = "white", markerColor = "purple", iconRotate = 270),
                              group = "미용실") %>%
            addAwesomeMarkers(data = cvs,
                              lng = ~lon,
                              lat = ~lat,
                              icon = awesomeIcons(icon = "archive", library = "fa", iconColor = "white", markerColor = "blue"),
                              group = "편의점") %>%
            
            addLayersControl(baseGroups = c("POI"),
                             overlayGroups = c("병원", "동물병원", "어린이집", "음식점", "카페", "유흥주점", "편의점", "미용실"),
                             position = "bottomright")
        
            
    })
    
    resetaddr <- eventReactive(input$addr_reset,{
        if(is.null(input$lines) == 0 & is.null(input$clust) == 0){
            sw_station2 <- sw_station %>% filter(name %in% input$lines & cluster %in% input$clust)
            sw_station2
        } else if(is.null(input$lines) == 1 & is.null(input$clust) == 0){
            sw_station2 <- sw_station %>% filter(cluster %in% input$clust)
            sw_station2
        } else if(is.null(input$lines) == 0 & is.null(input$clust) == 1){
            sw_station2 <- sw_station %>% filter(name %in% input$lines)
            sw_station2
        } else{
            sw_station2 <- sw_station
            sw_station2
        }
        }, ignoreNULL = T)
    
    observe({
        leafletProxy("map") %>%
            clearMarkers() %>% 
            addCircleMarkers(data = resetaddr(),
                             lng = ~as.numeric(lon),
                             lat = ~as.numeric(lat), 
                            color = ~pal(as.factor(cluster)),
                radius = 25 * (resetaddr()$std_FD6_count + resetaddr()$std_CE7_count) + 5,
                stroke = F,
                fillOpacity = 0.4)
    })
    
}




