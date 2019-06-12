


shinyUI(bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(top = 10, left = 50, 
                pickerInput(inputId = "lines", label = "호선:",  
                            choices = sw_station_nm,
                            selected = sw_station_nm[17],
                            multiple = T
                            ),
                pickerInput(inputId = "clust", label = "Cluster:",  
                            choices = sw_station$cluster %>% unique() %>% sort(),
                            selected = "1",
                            multiple = T
                )
  ),
  absolutePanel(top = 10, right = 50,
                searchInput(
                  inputId = "addr",
                  label = "Click search icon", 
                  placeholder = "주소를 입력하세요.",
                  btnSearch = icon("search"), 
                  btnReset = icon("remove"),
                  width = 300
                ))
)

)
  




