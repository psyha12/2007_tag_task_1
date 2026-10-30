mod_activity_ui <- function() {
  
  tabItem(
    
    tabName = "activity",
    
    
    # Filters row
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
              choices = unique(daily_activity$id),
              selected = unique(daily_activity$id),
              multiple = TRUE,
              options = pickerOptions(
                actionsBox = TRUE,
                selectedTextFormat = "count > 2",
                countSelectedText = "{0} id selected")
            ))),
        
        br(),
      
        # Outputs
        # Leader board
        fluidRow(
          column(
            width = 8
            # plots !
            
          ),
          column(
            width = 4,
            DT::DTOutput("activity_leaderboard")
          )))))
}