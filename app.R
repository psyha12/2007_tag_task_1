# Fitbit Dashboard
# Run with: shiny::runApp()  (or click "Run App" in RStudio)

library(shiny)
library(shinydashboard) 
library(dplyr)
library(ggplot2)
library(lubridate)

# ----- Fitbit Dshboard User-Interface -----
ui <- dashboardPage(
  # Add header 
  dashboardHeader(title = "Fitbit Dashboard"),
  # Add sidebar for different tabs - this may change? 
  dashboardSidebar(
    sidebarMenu(
      id = "tabs",
      menuItem("Overview",     tabName = "overview",  icon = icon("home")),
      menuItem("Steps",        tabName = "steps",     icon = icon("shoe-prints")),
      menuItem("Heart Rate",   tabName = "heartrate", icon = icon("heart")),
      menuItem("Weight",       tabName = "weight",    icon = icon("weight-scale"))
    )
  ),
  
  dashboardBody(
    tabItems(
      
      # ---- Overview ----
      tabItem(tabName = "overview",
              h2("Overview")
      ),
      
      # ---- Steps ----
      tabItem(tabName = "steps",
              h2("Steps")
      ),
      
      # ---- Heart Rate ----
      tabItem(tabName = "heartrate",
              h2("Heart Rate")
      ),
      
      # ---- Weight ----
      tabItem(tabName = "weight",
              h2("Weight")
      ),
      
      # ---- Data Quality ----
      tabItem(tabName = "quality",
              h2("Data Quality")
      ),
      
      # ---- About ----
      tabItem(tabName = "about",
              h2("About")
      )
    )
  )
)

# ----- Server -----
server <- function(input, output, session) {
  
}

# Run the app
shinyApp(ui, server)