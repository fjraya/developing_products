#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)

cleanNumericData <- function(source) {
    source <- as.numeric(gsub("\\.", "", source))
    source[is.na(source)] <- 0
    return (source)
}

ccaa <- read.csv("./ccaa.csv")
data <- read.csv("./ccaa_vacunas.csv", na.strings = c("NA", ""))
data$Personas_completa <- cleanNumericData(data$Personas_completa)
data$Dosis_administradas <- cleanNumericData(data$Dosis_administradas)
data$Entregadas_Pfizer <- cleanNumericData(data$Entregadas_Pfizer)
data$Entregadas_Moderna <- cleanNumericData(data$Entregadas_Moderna)
data$Entregadas_AstraZeneca <- cleanNumericData(data$Entregadas_AstraZeneca)

data <- merge(data, ccaa, by=c("CCAA"))
# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    observe({
        updateSelectInput(inputId = "date", choices = sort(unique(data$Fecha)), selected = max(data$Fecha))
    })
    observe({
        updateSelectInput(inputId = "ccaa", choices = sort(unique(data$CCAA)), selected="España")
    })
    
    
    getDataFiltered <- reactive({
        data[data$Fecha == input$date & data$CCAA == input$ccaa, ]
    })
    
    getCCAAFiltered <- reactive({
        data[data$CCAA == input$ccaa, ]
    })
    
    output$total <- renderValueBox({
        valueBox(
            sum(getDataFiltered()$Dosis_administradas) + sum(getDataFiltered()$Personas_completa),
            "Total", 
            color = "green"
        )
    })
    
    output$one_dose <- renderValueBox({
        valueBox(
            sum(getDataFiltered()$Dosis_administradas) - sum(getDataFiltered()$Personas_completa),
            "One dose", 
            color = "green"
        )
    })

    output$two_dose <- renderValueBox({
        valueBox(
            sum(getDataFiltered()$Personas_completa),
            "Two dose", 
            color = "green"
        )
    })
    
    output$mymap <- renderLeaflet({
        getDataFiltered() %>% leaflet() %>%
            addTiles(options = providerTileOptions(minZoom = 0, maxZoom = 10)) %>% addMarkers(popup=paste
                                      ("<br>CCAA: ", 
                                          getDataFiltered()$CCAA, 
                                          "<br>Pfizer: ", 
                                          getDataFiltered()$Entregadas_Pfizer, 
                                          "<br>Moderna: ", 
                                          getDataFiltered()$Entregadas_Moderna,
                                          "<br>Astrazeneca: ",
                                          getDataFiltered()$Entregadas_AstraZeneca
                                      ) 
            )
    })
    
    
    output$plot1 <- renderPlotly(
        plot1 <- plot_ly(
            x = getCCAAFiltered()$Fecha,
            y = getCCAAFiltered()$Entregadas_Pfizer + getCCAAFiltered()$Entregadas_Moderna + getCCAAFiltered()$Entregadas_AstraZeneca 
            )
    )


})
