library(shiny)
library(shinydashboard)
library(plotly)
library(dplyr)

# ----- Fitbit Dashboard User-Interface -----
ui <- dashboardPage(
  
  dashboardHeader(title = "FitBit Activity Dashboard"),
  
  dashboardSidebar(
    
    sidebarMenu(
      id = "tabs",
      
      # ----- Activity Tab -----
      menuItem(
        "Activity",
        tabName = "activity",
        icon = icon("person-walking")
      ),
      
      # ----- Calorie Tab -----
      menuItem(
        "Calories",
        tabName = "calories",
        icon = icon("fire")
      ),
      
      # ----- Heart-rate Tab -----
      menuItem(
        "Heart Rate",
        tabName = "heartrate",
        icon = icon("heart")
      ),
      
      # ----- Weight Tab -----
      menuItem(
        "Weight",
        tabName = "weight",
        icon = icon("weight-scale")
      ),
      
      # ----- Sleep Tab -----
      menuItem(
        "Sleep",
        tabName = "sleep",
        icon = icon("bed")
      )
    )
  ),
  
  dashboardBody(
    
    tabItems(
      # ----- UIs for each page -----
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
  
}

shinyApp(ui, server)