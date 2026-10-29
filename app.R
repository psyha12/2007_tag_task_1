library(shiny)
library(shinydashboard)
library(plotly)
library(dplyr)


# GLOBAL
# Loads all source libraries / data / environmental variables / functions
source("R/global/global.R")

# ui tabs 
source("R/pages/mod_activity.R")
source("R/pages/mod_calories.R")
source("R/pages/mod_heartrate.R")
source("R/pages/mod_weight.R")
source("R/pages/mod_sleep.R")
source("R/global/global.R")
source("R/server/mod_sleep_server.R")

# ----- Fitbit Dashboard User-Interface -----
ui <- dashboardPage(
  
  dashboardHeader(
    title = "FitBit Activity Dashboard"
  ),
  
  dashboardSidebar(
    
    sidebarMenu(
      id = "tabs",
      
      menuItem(
        "Activity",
        tabName = "activity",
        icon = icon("person-walking")
      ),
      
      menuItem(
        "Calories",
        tabName = "calories",
        icon = icon("fire")
      ),
      
      menuItem(
        "Heart Rate",
        tabName = "heartrate",
        icon = icon("heart")
      ),
      
      menuItem(
        "Weight",
        tabName = "weight",
        icon = icon("weight-scale")
      ),
      
      menuItem(
        "Sleep",
        tabName = "sleep",
        icon = icon("bed")
      )
    )
  ),
  
  dashboardBody(
    
    tabItems(
      
      mod_activity_ui(),
      mod_calories_ui(),
      mod_heartrate_ui(),
      mod_weight_ui(),
      mod_sleep_ui()
      
    )
    
  )
)

# ----- Server -----
server <- function(input, output, session){
  
  # Activity
  source("R/server/server_activty.R", local = TRUE)
  
  # Calories
  source("R/server/mod_calories_server.R", local = TRUE)
  
  # Sleep
  mod_sleep_server(
    input,
    output,
    session
  )
  
}

shinyApp(ui, server)