library(shiny)
library(shinydashboard)
library(plotly)
library(dplyr)
library(shinyWidgets)
library(shinyBS)

# Load everything
source("R/functions/fct_calculate_pct_change.R")
source("R/functions/kpi_boxes.R")

source("R/pages/mod_activity.R")
source("R/pages/mod_calories.R")
source("R/pages/mod_heartrate.R")
source("R/pages/mod_weight.R")
source("R/pages/mod_sleep.R")

# ----- Fitbit Dashboard User-Interface -----
ui <- dashboardPage(
  
  dashboardHeader(
    title = "FitBit Activity Dashboard"
  ),
  
  dashboardSidebar(
    
    sidebarMenu(
      id = "tabs",
      
      menuItem("Activity",
               tabName = "activity",
               icon = icon("person-walking")),
      menuItem("Calories",
               tabName = "calories",
               icon = icon("fire")),
      menuItem("Heart Rate",
               tabName = "heartrate",
               icon = icon("heart")),
      menuItem("Weight", 
               tabName = "weight",
               icon = icon("weight-scale")),
      menuItem("Sleep",
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
  
  mod_heartrate_server(input, output, session)
}

shinyApp(ui, server)