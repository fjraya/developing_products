#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(leaflet)
library(plotly)



# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Covid: vaccination status in Spain"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            selectInput(inputId = "date", label = "Select Date", choices = NULL),
            selectInput(inputId = "ccaa", label = "Select CCAA", choices = NULL)
        ),
        # Show a plot of the generated distribution
        mainPanel(
            valueBoxOutput("total"),
            valueBoxOutput("one_dose"),
            valueBoxOutput("two_dose"),
            br(),
            h2("Distribution of vaccines"),
            leafletOutput("mymap"),
            h2("Historic distribution of vaccines"),
            plotlyOutput("plot1")
        )
    )
))
