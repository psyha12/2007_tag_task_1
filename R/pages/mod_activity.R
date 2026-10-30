# mod_activity_ui <- function() {
#   
#   tabItem(
#     tabName = "activity",
#     
#     fluidRow(
#       
#       box(
#         width = 12,
#         h2("Activity")
#       )
#       
#     )
#     
#   )
#   
# }

mod_activity_ui <- function() {
  
  tabItem(
    
    tabName = "activity",
    
    fluidRow(
      
      box(
        width = 12,
        title = "Activity Leaderboard",
        
        # Filters row
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
        fluidRow(
          column(
            width = 12,
            # leaderboard
            DT::DTOutput("activity_leaderboard")
          )))))
}