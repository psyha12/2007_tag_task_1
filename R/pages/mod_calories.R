mod_calories_ui <- function() {
  
  tabItem(
    
    tabName = "calories",
    
    fluidRow(
      
      box(
        width = 12,
        h2("Calories")
      )
      
    ),
    
    fluidRow(
      
      column(
        width = 9,
        
        selectInput(
          "calories_athlete_id",
          "Select Participant",
          choices = NULL
        )
        
      )
      
    ),
    
    fluidRow(
      
      column(
        width = 9,
        
        fluidRow(
          
          valueBoxOutput(
            "calories_total",
            width = 4
          ),
          
          valueBoxOutput(
            "calories_avg_daily",
            width = 4
          ),
          
          valueBoxOutput(
            "calories_max_day",
            width = 4
          )
          
        ),
        
        br(),
        
        fluidRow(
          
          column(
            width = 5,
            
            box(
              width = 12,
              title = "Select a Day",
              
              dateInput(
                "calories_selected_day",
                "Pick a date:",
                value = NULL
              ),
              
              verbatimTextOutput(
                "calories_day_total"
              )
              
            )
            
          ),
          
          column(
            width = 7,
            
            box(
              width = 12,
              title = "Hourly Breakdown",
              
              plotlyOutput(
                "calories_hourly_breakdown",
                height = "250px"
              )
              
            )
            
          )
          
        )
        
      ),
      
      column(
        width = 3,
        
        box(
          width = 12,
          title = "Leaderboard",
          
          dateRangeInput(
            "calories_dates",
            "Rank users between:"
          ),
          
          DTOutput(
            "calories_leaderboard"
          )
          
        )
        
      )
      
    ),
    
    fluidRow(
      
      box(
        
        width = 12,
        title = "Your Calories vs Group Average",
        
        plotlyOutput(
          "calories_hourly_plot",
          height = "400px"
        )
        
      )
      
    )
    
  )
  
}