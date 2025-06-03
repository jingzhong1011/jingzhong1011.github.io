###########
## Setup ##
###########
pkgs <- c("data.table", "dplyr", "geojsonsf", "ggplot2", "ggpubr",
          "highcharter", "htmltools", "knitr", "reshape2", "sf",
          "shiny", "shinydashboard", "showtext", "spdep", "stringr",
          "tidyr", "tmap", "TWmap", "zoo")
invisible(lapply(pkgs, library, character.only = TRUE))

fntltp <- JS("function(){
  return this.series.yAxis.categories[this.point.y] + ' (Age ' +  this.series.xAxis.categories[this.point.x] + '): ' +
  Highcharts.numberFormat(this.point.value, 2);
}")


##########
## Data ##
##########

MOI <- fread("MOIMOH_ZH.csv") %>% unique()


LEsmoothed <- fread("LEsmoothed_mean.csv")


age_colors <-   c("#E83929", "#D7003A", "#C72C48", 
                  "#F17C67", "#FB9966", "#E28D35",
                  "#FFB11B", "#F9BF45", "#FBE251", 
                  "#90B44B", "#1B813E", "#00896C",
                  "#80ABA9", "#00A7B5", "#507EA4", 
                  "#4D5A99", "#8B81C3", "#5A3F7D", 
                  "#A2A2A2")


geoData <- st_read("bord_town.shp") %>% 
  subset(substr(town, 1, 1) != 0) %>% 
  rename("MOI" = "town")


########
## UI ##
########
ui <- navbarPage(title = "Life Expectancy Estimation", id = "navBar",
                 position = "static-top",
                 theme = "black",
                 inverse = T,
                 collapsible = T,
                 fluid = T, 
                 windowTitle = "LE Visualization",
                 selected = "LEsmoothed",
                 tabPanel("LE by Township", value = "LEsmoothed", 
                          fluidRow(
                            column(width = 12, h4("Smoothed Life Expectancy by Year and Sex", align = "center")),
                            column(width = 12, sliderInput("LEsmoothed_year",
                                                          label = h6("Year"),
                                                          min = 2000, max = 2021, value = 2000,
                                                          animate = animationOptions(
                                                            interval = 1000,
                                                            loop = FALSE,
                                                            playButton = actionButton("play", "Play", icon = icon("play"), width = "75px", style = "margin-top: 5px; color: #fff; background-color: #337ab7; border-color: #2e6da4"),
                                                            pauseButton = actionButton("pause", "Pause", icon = icon("pause"), width = "75px", style = "margin-top: 5px; color: #fff; background-color: #337ab7; border-color: #2e6da4")
                                                          )
                            ), align = "center"),
                            column(width = 6, h5("Male", align = "center"), highchartOutput("LEmeanMap_male", height = "1080px")),
                            column(width = 6, h5("Female", align = "center"), highchartOutput("LEmeanMap_female", height = "1080px")),
                            column(width = 6, h5("Male", align = "center"), highchartOutput("LEsdMap_male", height = "1080px")),
                            column(width = 6, h5("Female", align = "center"), highchartOutput("LEsdMap_female", height = "1080px")),
                            column(width = 3, h5("LE Top 10 (Male)", align = "center"), highchartOutput("LEtop10_male")),
                            column(width = 3, h5("LE Bottom 10 (Male)", align = "center"), highchartOutput("LEbottom10_male")),
                            column(width = 3, h5("LE Top 10 (Female)", align = "center"), highchartOutput("LEtop10_female")),
                            column(width = 3, h5("LE Bottom 10 (Female)", align = "center"), highchartOutput("LEbottom10_female"))
                          )
                 )
)


############
## Server ##
############
server <- function(input, output){
  
  output$LEmeanMap_male <- renderHighchart({
    highchart(type = "map") %>%
      hc_add_series_map(
        map = geojsonio::geojson_list(geoData),
        df = LEsmoothed %>% filter(YEAR == input$LEsmoothed_year & SEX == 1) %>% mutate(e0_mean = round(e0_mean, 3)),
        value = "e0_mean",
        joinBy = "MOI",
        name = paste("LE at birth", input$LEsmoothed_year, "Male")
      ) %>%
      hc_colorAxis(
        min = 60, max = 90,
        stops = color_stops(10, c("#B50D18", "#D3422F", "#FB9966", "#FFBA84", "#F4E496",
                                  "#E0EAA9", "#B2D494", "#8DC191", "#4D9595", "#26659C"))
      ) %>%
      hc_tooltip(
        pointFormat = '<b>{point.County_Township_ZH}</b><br><b>LE at birth:</b> {point.value:.3f}<br>',
        split = FALSE
      )
  })
  
  output$LEmeanMap_female <- renderHighchart({
    highchart(type = "map") %>%
      hc_add_series_map(
        map = geojsonio::geojson_list(geoData),
        df = LEsmoothed %>% filter(YEAR == input$LEsmoothed_year & SEX == 2) %>% mutate(e0_mean = round(e0_mean, 3)),
        value = "e0_mean",
        joinBy = "MOI",
        name = paste("LE at birth", input$LEsmoothed_year, "Female")
      ) %>% 
      hc_colorAxis(
        min = 60, max = 90,
        naColor = "#808080",
        stops = color_stops(10, c("#B50D18", "#D3422F", "#FB9966", "#FFBA84", "#F4E496", 
                                  "#E0EAA9", "#B2D494", "#8DC191", "#4D9595",  "#26659C"))
      ) %>% 
      hc_tooltip(
        pointFormat = '<b>{point.County_Township_ZH}</b><br><b>LE at birth:</b> {point.value:.3f}<br>',
        split = FALSE
      )
})

  output$LEsdMap_male <- renderHighchart({
    highchart(type = "map") %>%
      hc_add_series_map(
        map = geojsonio::geojson_list(geoData),
        df = LEsmoothed %>% filter(YEAR == input$LEsmoothed_year & SEX == 1),
        value = "e0_sd",
        joinBy = "MOI",
        name = paste("LE at birth", input$LEsmoothed_year, "Male")
      ) %>%
      hc_colorAxis(
        min = 0, max = 7.5
      ) %>%
      hc_tooltip(
        pointFormat = '<b>{point.County_Township_ZH}</b><br><b>Posterior SD of LE:</b> {point.value:.3f}<br>',
        split = FALSE
      )
  })
  
  output$LEsdMap_female <- renderHighchart({
    highchart(type = "map") %>%
      hc_add_series_map(
        map = geojsonio::geojson_list(geoData),
        df = LEsmoothed %>% filter(YEAR == input$LEsmoothed_year & SEX == 2),
        value = "e0_sd",
        joinBy = "MOI",
        name = paste("LE at birth", input$LEsmoothed_year, "Female")
      ) %>%
      hc_colorAxis(
        min = 0, max = 7.5
      ) %>%
      hc_tooltip(
        pointFormat = '<b>{point.County_Township_ZH}</b><br><b>Posterior SD of LE:</b> {point.value:.3f}<br>',
        split = FALSE
      )
  })


  
  
  output$LEtop10_male <- renderHighchart({
    
    dt <- LEsmoothed %>% 
      filter(YEAR == input$LEsmoothed_year & SEX == 1) %>% 
      top_n(10, e0_mean) %>% arrange(desc(e0_mean)) %>% 
      mutate(e0_mean = round(e0_mean, 3))
    highchart() %>% 
      hc_add_series(name = "Top 10 LE", data = dt, dataLabels = list(enabled = TRUE, format = "{point.e0_mean:.3f}"),
                    type = "bar", hcaes(x = as.factor(County_Township_ZH), y = e0_mean), color = "#5bc2e7") %>% 
      hc_xAxis(
        categories = as.factor(dt$County_Township_ZH)
      ) %>% 
      hc_yAxis(max = 95, min = 70)
  })
  output$LEbottom10_male <- renderHighchart({
    
    dt <- LEsmoothed %>% 
      filter(YEAR == input$LEsmoothed_year & SEX == 1) %>% 
      top_n(-10, e0_mean) %>% arrange(e0_mean) %>% 
      mutate(e0_mean = round(e0_mean, 3))
    highchart() %>% 
      hc_add_series(name = "Bottom 10 LE", data = dt, dataLabels = list(enabled = TRUE, format = "{point.e0_mean:.3f}"),
                    type = "bar", hcaes(x = as.factor(County_Township_ZH), y = e0_mean), color = "#ff8da1") %>% 
      hc_xAxis(
        categories = as.factor(dt$County_Township_ZH)
      ) %>% 
      hc_yAxis(max = 80, min = 55)
  })
  
  output$LEtop10_female <- renderHighchart({
    
    dt <- LEsmoothed %>% 
      filter(YEAR == input$LEsmoothed_year & SEX == 2) %>% 
      top_n(10, e0_mean) %>% arrange(desc(e0_mean)) %>% 
      mutate(e0_mean = round(e0_mean, 3))
    highchart() %>% 
      hc_add_series(name = "Top 10 LE", data = dt, dataLabels = list(enabled = TRUE, format = "{point.e0_mean:.3f}"),
                    type = "bar", hcaes(x = as.factor(County_Township_ZH), y = e0_mean), color = "#5bc2e7") %>% 
      hc_xAxis(
        categories = as.factor(dt$County_Township_ZH) 
      ) %>% 
      hc_yAxis(max = 95, min = 70)
  })
  output$LEbottom10_female <- renderHighchart({
    
    dt <- LEsmoothed %>% 
      filter(YEAR == input$LEsmoothed_year & SEX == 2) %>% 
      top_n(-10, e0_mean) %>% arrange(e0_mean) %>% 
      mutate(e0_mean = round(e0_mean, 3))
    highchart() %>% 
      hc_add_series(name = "Bottom 10 LE", data = dt, dataLabels = list(enabled = TRUE, format = "{point.e0_mean:.3f}"),
                    type = "bar", hcaes(x = as.factor(County_Township_ZH), y = e0_mean), color = "#ff8da1") %>% 
      hc_xAxis(
        categories = as.factor(dt$County_Township_ZH)
      ) %>% 
      hc_yAxis(max = 80, min = 55)
  })
  
  
}

# Run the application 
shinyApp(ui = ui, server = server)

