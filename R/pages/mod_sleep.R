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
      
      box(
        
        width = 9,
        title = "Sleep Efficiency",
        
        withMathJax(),
        
        div(
          style = "text-align:center; padding:20px; font-size:24px;",
          
          "$$
          Sleep\\ Efficiency=
          \\frac{Total\\ Minutes\\ Asleep}
          {Total\\ Time\\ In\\ Bed}
          \\times100
          $$
          "
          
        )
        
      ),
      
      box(
        
        width = 3,
        title = "Leaderboard",
        
        dateRangeInput(
          "sleep_dates",
          "Select date range:"
        ),
        
        DTOutput(
          "sleep_leaderboard"
        )
        
      )
      
    ),
    
    fluidRow(
      
      valueBoxOutput(
        "avg_efficiency"
      ),
      
      valueBoxOutput(
        "avg_sleep"
      )
      
    ),
    
    fluidRow(
      
      box(
        
        width = 12,
        title = "Sleep Distribution",
        
        selectInput(
          "sleep_user",
          "Select an ID to View",
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
        title = "Sleep Efficiency Ranking",
        
        plotlyOutput(
          "sleep_efficiency_rank",
          height = "350px"
        )
        
      )
      
    )
    
  )
  
}