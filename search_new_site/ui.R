
shinyUI(
  navbarPage("search_new_site",
             tabPanel(title = "Clustering",
                      div(class = "clust",
                          leafletOutput("clust_map", width = "100%", height = "100%"),
                          absolutePanel(top = 10, left = 50, 
                                        pickerInput(inputId = "lines", label = "호선:",  
                                                    choices = sw_station_nm,
                                                    selected = sw_station_nm[17],
                                                    multiple = T
                                        ),
                                        pickerInput(inputId = "cluster", label = "Cluster:",  
                                                    choices = sw_station$cluster %>% unique() %>% sort(),
                                                    selected = "1",
                                                    multiple = T
                                        )
                          )
                          
                          
                      )
             ),
             tabPanel(title = "Comparison",
                      fluidRow(
                        div(class="outer1",
                            tags$head(includeCSS("style.css")),
                            leafletOutput("map1", width= "100%", height= "100%"),
                            absolutePanel(top = 20, left = 50,
                                          searchInput(
                                            inputId = "addrA",
                                            label = NULL,
                                            value = "용인시 기흥구 사은로126번길 10",
                                            placeholder = "주소를 입력하세요.",
                                            btnSearch = icon("search"), 
                                            btnReset = icon("remove"),
                                            width = 300)
                            )
                        ),
                        
                        div(class="outer2",
                            leafletOutput("map2", width="100%", height= "100%"),
                            absolutePanel(top = 20, left = 50,
                                          searchInput(
                                            inputId = "addrB",
                                            label = NULL,
                                            value = "수원시 영통구 영통동 1052-2",
                                            placeholder = "주소를 입력하세요.",
                                            btnSearch = icon("search"), 
                                            btnReset = icon("remove"),
                                            width = 300)
                            )
                        )
                      )
             )
  )
  
  
)



