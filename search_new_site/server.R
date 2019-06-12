



getAddressInfo <- function(address){
    res <- GET(url = url_addr,
               add_headers(Authorization= paste0("KakaoAK ",api_key), 
                           Host = "dapi.kakao.com"), 
               query = list("query" = address)
    )
    temp_df <- res %>% content(as = 'text') %>% fromJSON()
    temp_df <- temp_df$documents
    temp_df$address
}


getSwstaionInfo <- function(ctgr_cd = "SW8", lon, lat, radius){
    
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




function(input, output, session){
    
    filteredData <- reactive({
        if(is.null(input$lines) == 0 & is.null(input$clust) == 0){
        sw_station2 <- sw_station %>% filter(name %in% input$lines & cluster %in% input$clust)
        sw_points <- data.frame(lon = as.numeric(sw_station2$lon),
                                lat = as.numeric(sw_station2$lat))
        sp <- SpatialPoints(sw_points)
        sw_station_location <- SpatialPointsDataFrame(sp,sw_station2)
        sw_station_location
            
        } else if(is.null(input$lines) == 1 & is.null(input$clust) == 0){
            sw_station2 <- sw_station %>% filter(cluster %in% input$clust)
            sw_points <- data.frame(lon = as.numeric(sw_station2$lon),
                                    lat = as.numeric(sw_station2$lat))
            sp <- SpatialPoints(sw_points)
            sw_station_location <- SpatialPointsDataFrame(sp,sw_station2)
            sw_station_location
            
        } else if(is.null(input$lines) == 0 & is.null(input$clust) == 1){
            sw_station2 <- sw_station %>% filter(name %in% input$lines)
            sw_points <- data.frame(lon = as.numeric(sw_station2$lon),
                                    lat = as.numeric(sw_station2$lat))
            sp <- SpatialPoints(sw_points)
            sw_station_location <- SpatialPointsDataFrame(sp,sw_station2)
            sw_station_location
            
        } else{
            sw_station2 <- sw_station
            sw_points <- data.frame(lon = as.numeric(sw_station2$lon),
                                    lat = as.numeric(sw_station2$lat))
            sp <- SpatialPoints(sw_points)
            sw_station_location <- SpatialPointsDataFrame(sp,sw_station2)
            sw_station_location
            
        }
        
    })

    output$map <- renderLeaflet({
        # Use leaflet() here, and only include aspects of the map that
        # won't need to change dynamically (at least, not unless the
        # entire map is being torn down and recreated).
        leaflet() %>% 
            setView(lng = 126.96474263398179, lat = 37.52977360379245, zoom = 12) %>% 
            addProviderTiles(provider = providers$CartoDB)
    })
    
    
    
    observe({
        
        
        leafletProxy("map", data = filteredData()) %>%
            clearMarkers() %>% 
            addCircleMarkers(
                             lng = filteredData()@coords[,1], 
                             lat = filteredData()@coords[,2], 
                             color = ~pal(as.factor(filteredData()@data$cluster)),
                             radius = 30 * (filteredData()@data$std_FD6_count + filteredData()@data$std_CE7_count) + 5,
                             stroke = F,
                             fillOpacity = 0.4)
        
    })
    
    searchaddr <- eventReactive(input$addr_search,{
        address <- getAddressInfo(address = input$addr)
        address <- address %>% mutate(lon = as.numeric(x), lat = as.numeric(y))
        
        closeto <- getSwstaionInfo(ctgr_cd = "SW8", lon = address$lon, lat = address$lat, radius = 2000)
        if(nrow(closeto) > 0){
        closeto_sw_points <- data.frame(lon = as.numeric(closeto$x),
                                lat = as.numeric(closeto$y))
        closeto_sp <- SpatialPoints(closeto_sw_points)
        closeto_sw_station_location <- SpatialPointsDataFrame(closeto_sp,closeto)
        
        ls <- list("location" = address, "close_sw" = closeto_sw_station_location)
        
        ls
        } else {
            closeto <- getSwstaionInfo(ctgr_cd = "SW8", lon = address$lon, lat = address$lat, radius = 5000)
            
            closeto_sw_points <- data.frame(lon = as.numeric(closeto$x),
                                            lat = as.numeric(closeto$y))
            closeto_sp <- SpatialPoints(closeto_sw_points)
            closeto_sw_station_location <- SpatialPointsDataFrame(closeto_sp,closeto)
            
            ls <- list("location" = address, "close_sw" = closeto_sw_station_location)
            
            ls
        }
    
    }, ignoreNULL = T)
    
    observe({
        leafletProxy("map", data = searchaddr()$location) %>% 
            addMarkers(lng = ~lon, lat = ~lat) %>%
            #addMarkers(data = searchaddr()$close_sw, lng = searchaddr()$close_sw@coords[,1], lat = searchaddr()$close_sw@coords[,2], icon = icon("fas fa-subway", lib = "font-awesome")) %>%
            addPopups(data = searchaddr()$close_sw, 
                      lng = searchaddr()$close_sw@coords[,1], 
                      lat = searchaddr()$close_sw@coords[,2], 
                      popup = paste0(searchaddr()$close_sw@data$place_name, "<br/>",searchaddr()$close_sw@data$distance, "m"), 
                      options = popupOptions(closeButton = FALSE))
    })
    
    

    
    resetaddr <- eventReactive(input$addr_reset,{
        if(is.null(input$lines) == 0 & is.null(input$clust) == 0){
            sw_station2 <- sw_station %>% filter(name %in% input$lines & cluster %in% input$clust)
            sw_points <- data.frame(lon = as.numeric(sw_station2$lon),
                                    lat = as.numeric(sw_station2$lat))
            sp <- SpatialPoints(sw_points)
            sw_station_location <- SpatialPointsDataFrame(sp,sw_station2)
            sw_station_location
            
        } else if(is.null(input$lines) == 1 & is.null(input$clust) == 0){
            sw_station2 <- sw_station %>% filter(cluster %in% input$clust)
            sw_points <- data.frame(lon = as.numeric(sw_station2$lon),
                                    lat = as.numeric(sw_station2$lat))
            sp <- SpatialPoints(sw_points)
            sw_station_location <- SpatialPointsDataFrame(sp,sw_station2)
            sw_station_location
            
        } else if(is.null(input$lines) == 0 & is.null(input$clust) == 1){
            sw_station2 <- sw_station %>% filter(name %in% input$lines)
            sw_points <- data.frame(lon = as.numeric(sw_station2$lon),
                                    lat = as.numeric(sw_station2$lat))
            sp <- SpatialPoints(sw_points)
            sw_station_location <- SpatialPointsDataFrame(sp,sw_station2)
            sw_station_location
            
        } else{
            sw_station2 <- sw_station
            sw_points <- data.frame(lon = as.numeric(sw_station2$lon),
                                    lat = as.numeric(sw_station2$lat))
            sp <- SpatialPoints(sw_points)
            sw_station_location <- SpatialPointsDataFrame(sp,sw_station2)
            sw_station_location
            
        }
        }, ignoreNULL = T)
    
    observe({
        leafletProxy("map", data = resetaddr()) %>%
            clearMarkers() %>% 
            addCircleMarkers(
                lng = resetaddr()@coords[,1], 
                lat = resetaddr()@coords[,2], 
                color = ~pal(as.factor(resetaddr()@data$cluster)),
                radius = 25 * (resetaddr()@data$std_FD6_count + resetaddr()@data$std_CE7_count) + 5,
                stroke = F,
                fillOpacity = 0.4)
    })
    
}




