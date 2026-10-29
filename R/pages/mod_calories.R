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
        
        box(
          
          width = 12,
          title = "Calories Burned",
          
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
        
        fluidRow(
          
          column(
            width = 6,
            selectInput(
              "calories_athlete_id",
              "Select Participant",
              choices = NULL
            )
          ),
          
          column(
            width = 6,
            dateInput(
              "calories_comparison_date",
              "Select Date",
              value = NULL
            )
          )
          
        ),
        
        plotlyOutput(
          "calories_hourly_plot",
          height = "350px"
        )
        
      )
      
    )
    
  )
  
}