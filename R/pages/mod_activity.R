
mod_activity_ui <- function() {
  
  tabItem(
    
    tabName = "activity",
    
    # Page title
    
    fluidRow(
      box(
        width = 12,
        h2("Activity")
      )
    ),
    
    # Filters
    
    fluidRow(
      box(
        width = 12,
        title = "Filters",
        
        fluidRow(
          column(
            width = 8,
            dateRangeInput(
              "activity_dates",
              "Date Range",
              start = NULL,
              end = NULL
            )
          ),
          
          column(
            width = 4,
            pickerInput(
              "selected_id",
              "Select ID",
              choices = sort(unique(daily_activity$Id)),
              selected = sort(unique(daily_activity$Id)),
              multiple = TRUE,
              options = pickerOptions(
                actionsBox = TRUE,
                selectedTextFormat = "count > 2",
                countSelectedText = "{0} IDs selected"
              )
            )
          )
        )
      )
    ),
    
  #kpi boxes
    
    fluidRow(
      valueBoxOutput(
        "avg_steps",
        width = 6
      ),
      
      valueBoxOutput(
        "avg_active_minutes",
        width = 6
      )
    ),
    
  # Steps Trend & Leaderboard
    
    fluidRow(
      box(
        width = 8,
        title = "Daily Steps Trend",
        
        selectInput(
          inputId = "compare_id",
          label = "Compare Participant",
          choices = sort(unique(daily_activity$Id)),
          selected = sort(unique(daily_activity$Id))[1]
        ),
        
        plotlyOutput(
          "steps_trend",
          height = "350px"
        )
      ),
      
      box(
        width = 4,
        title = "Steps Leaderboard",
        DT::DTOutput("activity_leaderboard")
      )
    ),
    
#Hourly Steps & Intensity
    
    fluidRow(
      box(
        width = 6,
        title = "Hourly Steps Pattern",
        plotlyOutput(
          "hourly_steps_plot",
          height = "350px"
        )
      ),
      
      box(
        width = 6,
        title = "Activity Intensity",
        plotlyOutput(
          "activity_intensity",
          height = "350px"
        )
      )
    )
    
  )
  
}
