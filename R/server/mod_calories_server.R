# Calories Tab Server Logic
# Sourced with local = TRUE inside server(), so input/output/session are in scope

# Initialize dropdowns and date ranges
observe({
  
  updateSelectInput(
    session,
    "calories_athlete_id",
    choices = sort(unique(daily_calories$Id))
  )
  
  updateDateRangeInput(
    session,
    "calories_dates",
    start = min(daily_calories$ActivityDay, na.rm = TRUE),
    end = max(daily_calories$ActivityDay, na.rm = TRUE),
    min = min(daily_calories$ActivityDay, na.rm = TRUE),
    max = max(daily_calories$ActivityDay, na.rm = TRUE)
  )
  
  updateDateInput(
    session,
    "calories_comparison_date",
    value = min(as.Date(hourly_calories$ActivityHour), na.rm = TRUE)
  )
  
})

# Reactive: Leaderboard data
calories_leaderboard <- reactive({
  
  req(input$calories_dates)
  
  create_leaderboard(
    data = daily_calories,
    person_col = "Id",
    metric_col = "Calories",
    date_col = "ActivityDay",
    start_date = input$calories_dates[1],
    end_date = input$calories_dates[2],
    rank_fun = sum
  )
  
})

# KPI Box: Average Daily Calories (for selected participant vs group)
output$calories_total <- renderValueBox({
  
  req(input$calories_athlete_id)
  
  athlete_id <- as.character(input$calories_athlete_id)
  
  # Athlete's average
  user_avg <- daily_calories %>%
    filter(Id == athlete_id) %>%
    summarise(value = mean(Calories, na.rm = TRUE)) %>%
    pull(value)
  
  # Group average
  overall_avg <- daily_calories %>%
    summarise(value = mean(Calories, na.rm = TRUE)) %>%
    pull(value)
  
  change <- ((user_avg - overall_avg) / overall_avg) * 100
  
  create_kpi_box(
    title = "Average Daily Calories",
    value = round(user_avg),
    change = change
  )
  
})

# KPI Box: Max Day Calories (for selected participant)
output$calories_avg_daily <- renderValueBox({
  
  req(input$calories_athlete_id)
  
  athlete_id <- as.character(input$calories_athlete_id)
  
  # Athlete's max day
  user_max <- daily_calories %>%
    filter(Id == athlete_id) %>%
    summarise(value = max(Calories, na.rm = TRUE)) %>%
    pull(value)
  
  # Group max day
  overall_max <- daily_calories %>%
    summarise(value = max(Calories, na.rm = TRUE)) %>%
    pull(value)
  
  change <- ((user_max - overall_max) / overall_max) * 100
  
  create_kpi_box(
    title = "Max Day Calories",
    value = round(user_max),
    change = change
  )
  
})

# KPI Box: Total Calories (for selected participant)
output$calories_max_day <- renderValueBox({
  
  req(input$calories_athlete_id)
  
  athlete_id <- as.character(input$calories_athlete_id)
  
  # Athlete's total
  user_total <- daily_calories %>%
    filter(Id == athlete_id) %>%
    summarise(value = sum(Calories, na.rm = TRUE)) %>%
    pull(value)
  
  # Group total average per person
  overall_total <- daily_calories %>%
    group_by(Id) %>%
    summarise(total = sum(Calories, na.rm = TRUE), .groups = "drop") %>%
    summarise(value = mean(total, na.rm = TRUE)) %>%
    pull(value)
  
  change <- ((user_total - overall_total) / overall_total) * 100
  
  create_kpi_box(
    title = "Total Calories",
    value = format(round(user_total), big.mark = ","),
    change = change
  )
  
})

# Leaderboard Table
output$calories_leaderboard <- renderDT({
  
  display_data <- calories_leaderboard() %>%
    mutate(
      Medal = case_when(
        rank == 1 ~ "🥇",
        rank == 2 ~ "🥈",
        rank == 3 ~ "🥉",
        TRUE ~ as.character(rank)
      ),
      Id = as.character(Id)
    ) %>%
    select(
      Rank = Medal,
      User = Id,
      Calories = value
    ) %>%
    mutate(Calories = format(Calories, big.mark = ","))
  
  datatable(
    display_data,
    rownames = FALSE,
    options = list(
      pageLength = 5,
      dom = "tp"
    )
  )
  
})

# Hourly Calories Comparison Plot (YOU vs GROUP AVERAGE)
output$calories_hourly_plot <- renderPlotly({
  
  req(input$calories_athlete_id, input$calories_comparison_date)
  
  tryCatch({
    
    athlete_id <- as.character(input$calories_athlete_id)
    selected_date <- as.Date(input$calories_comparison_date)
    
    # Prepare hourly data
    hourly_data <- hourly_calories %>%
      mutate(
        date = as.Date(ActivityHour, tz = "UTC"),
        hour = lubridate::hour(ActivityHour)
      )
    
    # Get selected athlete's hourly data
    athlete_data <- hourly_data %>%
      filter(Id == athlete_id, date == selected_date) %>%
      select(hour, athlete_calories = Calories)
    
    # Get peer average (excluding selected athlete)
    peer_data <- hourly_data %>%
      filter(Id != athlete_id, date == selected_date) %>%
      group_by(hour) %>%
      summarise(peer_mean = mean(Calories, na.rm = TRUE), .groups = "drop")
    
    # Combine data
    plot_data <- tibble(hour = 0:23) %>%
      left_join(athlete_data, by = "hour") %>%
      left_join(peer_data, by = "hour") %>%
      pivot_longer(
        c(athlete_calories, peer_mean),
        names_to = "series",
        values_to = "calories"
      ) %>%
      mutate(
        series = case_when(
          series == "athlete_calories" ~ "You",
          series == "peer_mean" ~ "Group Average"
        )
      )
    
    # Create plot
    p <- ggplot(
      plot_data,
      aes(x = hour, y = calories, colour = series, group = series)
    ) +
      geom_line(linewidth = 1.2) +
      geom_point(size = 2.5) +
      scale_colour_manual(
        values = c(
          "You" = "#0072B2",
          "Group Average" = "#E69F00"
        )
      ) +
      scale_x_continuous(
        breaks = seq(0, 23, by = 2),
        labels = paste0(seq(0, 23, by = 2), ":00")
      ) +
      labs(
        title = paste("Hourly Calories on", selected_date),
        x = "Time of Day",
        y = "Calories Burned",
        colour = ""
      ) +
      theme_minimal() +
      theme(
        legend.position = "top",
        plot.title = element_text(face = "bold")
      )
    
    ggplotly(p, tooltip = c("x", "y", "colour"))
    
  }, error = function(e) {
    plotly_empty() %>%
      layout(title = paste("Error:", e$message))
  })
  
})
