mod_heartrate_ui <- function() {
  
  # ----- Tab Name -----
  shinydashboard::tabItem(
    tabName = "heartrate",
    
    shiny::fluidRow(
      # ----- User defined Filtering -----
      shinydashboard::box(
        width = 12,
        title = "Filters",
        status = "primary",
        solidHeader = TRUE,
        
        # Date Range to Look at 
        column(
          6,
          # last 7 days 
          shiny::actionButton("hr_last_7", "Last 7 Days"),
          # Last month
          shiny::actionButton("hr_last_month", "Last Month"),
          # Last 3 months 
          shiny::actionButton("hr_last_3_months", "Last 3 Months"),
          # All time 
          shiny::actionButton("hr_all_time", "All Time"),
          br(),
          # Print out the Date Range it is covering
          tags$b("Date Range"),
          textOutput("hr_current_range")
          ),
    
        # Specific Participant to view
        column(
          4,
          shinyWidgets::pickerInput(
            "hr_user",
            "Select ID(s)",
            choices = NULL,
            selected = NULL,
            multiple = TRUE,
            options = pickerOptions(
              actionsBox = TRUE,
              selectedTextFormat = "count > 2",
              countSelectedText = "{0} id(s) selected")
            )
          )
      )
    ),
    
    # KPI widgets 
    fluidRow(
      valueBoxOutput("hr_avg", width = 3),
      valueBoxOutput("hr_peak", width = 3),
      valueBoxOutput("hr_resting", width = 3),
      valueBoxOutput("hr_active", width = 3)
    ),
    
    # Main Chart - Heart Rate Trend over Time 
    fluidRow(
      shinydashboard::box(
        width = 10,
        title = "Hourly Heart Rate Over Time",
        status = "primary",
        solidHeader = TRUE,
        
        plotly::plotlyOutput("hr_trend_plot")
      ),
      
      shinydashboard::box(
        width = 2,
        title = "Heart Rate Zones",
        status = "primary",
        solidHeader = TRUE,
        
        tags$small(
          tags$b("Resting:"), " <60 | ",
          tags$b("Normal:"), " 60-100 | ",
          tags$b("Active:"), " 100-140 | ",
          tags$b("Vigorous:"), " >140"
        ),
        
        br(), br(),
        
        uiOutput("hr_zones")
      )
    ),
    # Analysis Charts
    fluidRow(
      
      shinydashboard::box(
        width = 6,
        title = "Heart Rate by Weekday",
        status = "primary",
        solidHeader = TRUE,
        
        plotlyOutput("hr_weekday")
      ),
      
      shinydashboard::box(
        width = 6,
        title = "Heart Rate by Time of Day",
        status = "primary",
        solidHeader = TRUE,
        
        plotlyOutput("hr_timeofday")
      )
    )
    
  )
  
}

mod_heartrate_server <- function(input, output, session) {
  # ----- Load the data used in the dashboard ----- 
  heart_rate_data <- load_heartrate_data()
  steps_data <- load_activity_data()
  
  # ----------------------------------------
  # ----- Date filtering functionality -----
  # ----------------------------------------
  # Min date in the Heart Rate data 
  hr_min_date <- min(as.Date(heart_rate_data$Time), na.rm = TRUE)
  # Maximum date in the Heart Rate sata 
  hr_max_date <- max(as.Date(heart_rate_data$Time), na.rm = TRUE)
  
  # Create a reactive date range 
  selected_date_range <- reactiveVal(c(max(hr_max_date - 6, hr_min_date),
                                       hr_max_date))
  
  # ----------------------------------------
  # ----- Button Observers -----
  # ----------------------------------------
  # Last 7 days 
  observeEvent(input$hr_last_7, {
    selected_date_range(c(max(hr_max_date - 6, hr_min_date),
                          hr_max_date))
  })
  # Last month
  observeEvent(input$hr_last_month, {
    selected_date_range(c(max(hr_max_date - 29, hr_min_date),
                          hr_max_date))
  })
  # Last 3 Months 
  observeEvent(input$hr_last_3_months, {
    selected_date_range(c(max(hr_max_date - 89, hr_min_date),
                          hr_max_date))
  })
  # All time 
  observeEvent(input$hr_all_time, {
    selected_date_range(c(hr_min_date, hr_max_date))
  })
  
  # Display the date range selected to the user knows what is selected.
  output$hr_current_range <- renderText({
    paste(
      format(selected_date_range()[1]),
      "to",
      format(selected_date_range()[2])
    )
  })
  
  # ----------------------------------------
  # ----- Create Reactive Filtered Data -----
  # ----------------------------------------
  # ----- HEART RATE DATA -----
  heartrate_filtered <- reactive({
    
    shiny::req(input$hr_user)       # User defined participants 
    
    heart_rate_data |>
      dplyr::filter(
        Id %in% input$hr_user,
        as.Date(Time) >= selected_date_range()[1],
        as.Date(Time) <= selected_date_range()[2]
      )
    
  })
  
  # ----- Create Reactive data for KPI cards -----
  kpi_data <- reactive({
    
    current_data <- heartrate_filtered()
    
    if (nrow(current_data) == 0) {
      
      return(list(
        avg = NA_real_,
        avg_change = NA_real_,
        peak = NA_real_,
        peak_change = NA_real_,
        resting = NA_real_,
        resting_change = NA_real_,
        active = NA_real_,
        active_change = NA_real_
      ))
      
    }
    
    # 1 week previous from the selected date range 
    previous_data <- heart_rate_data |>
      dplyr::filter(
        Id %in% input$hr_user,
        as.Date(Time) >= (selected_date_range()[1] - 7),
        as.Date(Time) < selected_date_range()[2]
      )
    
    # Avg heart rate 
    current_avg <- mean(current_data$Value, na.rm = TRUE)
    previous_avg <- mean(previous_data$Value, na.rm = TRUE)
    
    # Peak heart rate 
    current_peak <- max(current_data$Value, na.rm = TRUE)
    previous_peak <- max(previous_data$Value, na.rm = TRUE)
    
    # Resting heart rate 
    current_resting <- mean(current_data$Value[current_data$Value < 65], na.rm = TRUE)
    previous_resting <- mean(previous_data$Value[previous_data$Value < 65], na.rm = TRUE)
    
    # Active heart rate
    current_active <- mean(current_data$Value > 100) * 100
    previous_active <- mean(previous_data$Value > 100) * 100
    
    list(avg = current_avg,
         avg_change = calculate_pct_change(current_avg, previous_avg),
         
         peak = current_peak,
         peak_change = calculate_pct_change(current_peak, previous_peak),
      
        resting = current_resting,
        resting_change = calculate_pct_change(current_resting, previous_resting),
      
        active = current_active,
        active_change = calculate_pct_change(current_active, previous_active)
        )
  })
  
  observe({
    
    # Get unique iser IDs
    ids <- sort(unique(heart_rate_data$Id))
    
    # Get min and max date for date range picker 
    hr_min_date <- min(as.Date(heart_rate_data$Time), na.rm = TRUE)
    hr_max_date <- max(as.Date(heart_rate_data$Time), na.rm = TRUE)
    
    shinyWidgets::updatePickerInput(
      session,
      "hr_user",
      choices = ids,
      selected = ids
    )
    
  })
  
  # ----------------------------------------
  # ----- Outputs -----
  # ----------------------------------------
  # ----- Avg Heart Rate KPI Widget Output
  output$hr_avg <- renderValueBox({
    
    create_kpi_box(
      title = "Average BPM",
      value = round(kpi_data()$avg, 0),
      pct_change = kpi_data()$avg_change,
      direction = "neutral"
    )
    
  })
  # ----- Peak Heart Rate KPI Widget Output
  output$hr_peak <- renderValueBox({
    
    create_kpi_box(
      title = "Peak BPM",
      value = round(kpi_data()$peak, 0),
      pct_change = kpi_data()$peak_change,
      direction = "neutral"
    )
    
  })
  # ----- Resting Heart Rate KPI Widget Output
  output$hr_resting <- renderValueBox({
    
    value <- kpi_data()$resting
    
    create_kpi_box(
      title = "Resting BPM",
      value = round(kpi_data()$resting, 0),
      pct_change = kpi_data()$resting_change,
      direction = "neutral"
    )
    
  })
  # ----- Active Heart Rate KPI Widget Output
  output$hr_active <- renderValueBox({
    
    create_kpi_box(
      title = "Active BPM %",
      value = paste0(round(kpi_data()$active, 0), "%"),
      pct_change = kpi_data()$active_change,
      direction = "neutral"
    )
    
  })
  # ----- Heart Rate Trend Plot 
  output$hr_trend_plot <- plotly::renderPlotly({
    
    # If the plot cannot render due to insufficient data display a message on the dashboard
    validate(need(nrow(heartrate_filtered()) > 0,
                  "No heart rate data available for the selected participant(s) and date range."))
    
    plot_data <- heartrate_filtered() |>
      dplyr::mutate(hour = lubridate::floor_date(Time, "hour")) |>
      dplyr::group_by(hour) |>
      dplyr::summarise(avg_hr = mean(Value, na.rm = TRUE), .groups = "drop")

    p <- ggplot2::ggplot(plot_data,ggplot2::aes(x = hour, y = avg_hr)) +
      ggplot2::geom_line(colour = "black",linewidth = 0.5) +
      ggplot2::labs(x = NULL,
                    y = "Average BPM") +
      ggplot2::theme_minimal()

    plotly::ggplotly(p)

  })
  # ----- Heart Rate Zones Summary
  output$hr_zones <- renderUI({
    
    zone_data <- heartrate_filtered() |>
      dplyr::mutate(
        Zone = dplyr::case_when(
          Value < 60 ~ "Resting",
          Value < 100 ~ "Normal",
          Value < 140 ~ "Active",
          TRUE ~ "Vigorous"
        )
      ) |>
      dplyr::count(Zone) |>
      dplyr::mutate(pct = round(100 * n / sum(n), 1))
    
    resting_pct <- zone_data$pct[zone_data$Zone == "Resting"]
    normal_pct <- zone_data$pct[zone_data$Zone == "Normal"]
    active_pct <- zone_data$pct[zone_data$Zone == "Active"]
    vigorous_pct <- zone_data$pct[zone_data$Zone == "Vigorous"]
    
    resting_pct <- ifelse(length(resting_pct) == 0, 0, resting_pct)
    normal_pct <- ifelse(length(normal_pct) == 0, 0, normal_pct)
    active_pct <- ifelse(length(active_pct) == 0, 0, active_pct)
    vigorous_pct <- ifelse(length(vigorous_pct) == 0, 0, vigorous_pct)
    
    shiny::tagList(
      
      tags$div(
        style = "font-size:18px; margin-bottom:15px;",
        tags$b("Normal: "),
        paste0(normal_pct, "%")
      ),
      
      tags$div(
        style = "font-size:18px; margin-bottom:15px;",
        tags$b("Resting: "),
        paste0(resting_pct, "%")
      ),
      
      tags$div(
        style = "font-size:18px; margin-bottom:15px;",
        tags$b("Active: "),
        paste0(active_pct, "%")
      ),
      
      tags$div(
        style = "font-size:18px;",
        tags$b("Vigorous: "),
        paste0(vigorous_pct, "%")
      )
      
    )
    
  })
  # ----- Avg Heart Rate at each time of day 
  output$hr_timeofday <- plotly::renderPlotly({
    
    # If the plot cannot render due to insufficient data display a message on the dashboard
    validate(need(nrow(heartrate_filtered()) > 0,
                  "No heart rate data available for the selected participant(s) and date range."))
    
    plot_data <- heartrate_filtered() |>
      dplyr::mutate(period = dplyr::case_when(
        lubridate::hour(Time) < 6 ~ "Night",
        lubridate::hour(Time) < 12 ~ "Morning",
        lubridate::hour(Time) < 18 ~ "Afternoon",
        TRUE ~ "Evening")
        ) |>
      dplyr::group_by(period) |>
      dplyr::summarise(avg_hr = mean(Value, na.rm = TRUE), .groups = "drop")
    
    plot_data$period <- factor(plot_data$period, levels = c("Night",
                                                            "Morning",
                                                            "Afternoon",
                                                            "Evening"
                                                            ))
    p <- ggplot2::ggplot(plot_data, ggplot2::aes(x = reorder(period, avg_hr),
                                                 y = avg_hr)) +
      ggplot2::geom_col(fill = "darkgrey") +
      ggplot2::coord_flip() +
      ggplot2::theme_minimal() +
      ggplot2::labs(x = NULL,
                    y = "Average BPM")
    
    plotly::ggplotly(p)
    
  })
  # ----- Avg Heart Rate each weekday
  output$hr_weekday <- plotly::renderPlotly({
    
    # If the plot cannot render due to insufficient data display a message on the dahsboard
    validate(need(nrow(heartrate_filtered()) > 0,
                  "No heart rate data available for the selected participant(s) and date range."))
    
    plot_data <- heartrate_filtered() |>
      dplyr::mutate(weekday = factor(lubridate::wday(Time, label = TRUE, abbr = TRUE),
                                     levels = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"))) |>
      dplyr::group_by(weekday) |>
      dplyr::summarise(avg_hr = mean(Value, na.rm = TRUE), .groups = "drop")
    
    p <- ggplot2::ggplot(plot_data, ggplot2::aes(x = weekday, y = avg_hr)) +
      ggplot2::geom_col(fill = "darkgrey") +
      ggplot2::theme_minimal() +
      ggplot2::labs(x = NULL, y = "Average BPM") 
    
    plotly::ggplotly(p)
    
  })
  

}