mod_sleep_ui <- function() {
  
  tabItem(
    
    tabName = "sleep",
    
    fluidRow(
      
      box(
        width = 12,
        h2("Sleep")
      )
      
    ),
    
    fluidRow(
      
      column(
        
        width = 9,
        
        box(
          
          width = 12,
          title = "Sleep Efficiency",
          
          withMathJax(),
          
          div(
            style = "
              text-align:center;
              padding:25px;
              font-size:22px;
            ",
            
            "$$
            Sleep\\ Efficiency =
            \\frac{Total\\ Minutes\\ Asleep}
            {Total\\ Time\\ In\\ Bed}
            \\times 100
            $$
            "
            
          )
          
        ),
        
        fluidRow(
          
          valueBoxOutput(
            "avg_efficiency",
            width = 6
          ),
          
          valueBoxOutput(
            "avg_sleep",
            width = 6
          )
          
        )
        
      ),
      
      column(
        
        width = 3,
        
        box(
          
          width = 12,
          title = "Sleep Efficiency Leaderboard",
          
          dateRangeInput(
            "sleep_dates",
            "Rank users between:"
          ),
          
          DTOutput(
            "sleep_leaderboard"
          )
          
        )
        
      )
      
    ),
    
    fluidRow(
      
      box(
        
        width = 12,
        title = "Sleep Distribution",
        
        selectInput(
          "sleep_user",
          "Select Participant ID",
          choices = NULL
        ),
        
        plotlyOutput(
          "sleep_distribution",
          height = "350px"
        )
        
      )
      
    ),
    
    fluidRow(
      
      box(
        
        width = 6,
        title = "Sleep vs Physical Activity",
        
        plotlyOutput(
          "sleep_activity",
          height = "350px"
        )
        
      ),
      
      box(
        
        width = 6,
        title = "Sleep State Breakdown",
        
        plotlyOutput(
          "sleep_state_breakdown",
          height = "350px"
        )
        
      )
      
    )
    
  )
  
}