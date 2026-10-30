mod_weight_ui <- function() {
  
  tabItem(
    tabName = "weight",
    
    fluidRow(
      
      box(width = 12,

        h2("Weight")
      
      )
      
    ),

    fluidRow(

      column(width = 8,

        fluidRow(

          box(width = 8,

            selectInput(
              "weight_select_user",
              "Select user",
              choices = NULL
            )

          ),

          box(width = 4,

            dateRangeInput(
              "weight_select_dates",
              "Select date range"
            )

          )

        ),

        fluidRow(

          valueBoxOutput("weight_kpi_weight", width = 4),

          valueBoxOutput("weight_kpi_bmi", width = 4),
          
          box(width = 4,
            
            title = "KPI info",
            
            "Weight and BMI show the latest reading and the % change since the first reading in the selected timeframe."
          
          )

        ),

        fluidRow(

          box(width = 12,

            title = "BMI chart",
            plotlyOutput("weight_bmi_graph"),
            footer = "Displays the most recent BMI reading in the timerange"

          )

        )

      ),

      column(width = 4,

        box(width = 12,

          DTOutput("weight_leaderboard")
        
        )

      )

    )

  )
  
}