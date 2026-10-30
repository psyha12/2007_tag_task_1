# Load everything
# Source all R scripts from the R directory and subfolders
list.files("R",
           pattern = "\\.R$",
           recursive = TRUE,
           full.names = TRUE) |>
  sort() |>
  lapply(source) |>
  invisible()

# ----- Fitbit Dashboard User-Interface -----
ui <- dashboardPage(
  
  dashboardHeader(title = "FitBit Activity Dashboard"),
  
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

  # Weight
  mod_weight_server(
    input,
    output,
    session
  )

  mod_heartrate_server(input, output, session)
}

shinyApp(ui, server)