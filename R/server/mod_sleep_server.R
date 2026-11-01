mod_sleep_server <- function(input, output, session) {
  
  observe({
    
    updateSelectInput(
      session,
      "sleep_user",
      choices = sort(unique(sleep_day$Id))
    )
    
    updateDateRangeInput(
      session,
      "sleep_dates",
      start = min(sleep_day$SleepDay, na.rm = TRUE),
      end = max(sleep_day$SleepDay, na.rm = TRUE),
      min = min(sleep_day$SleepDay, na.rm = TRUE),
      max = max(sleep_day$SleepDay, na.rm = TRUE)
    )
    
  })
  
  sleep_data <- reactive({
    
    req(input$sleep_user)
    
    sleep_day %>%
      filter(Id == input$sleep_user)
    
  })
  
  output$sleep_leaderboard <- renderDT({
    
    display_data <- create_leaderboard(
      
      data = sleep_day,
      
      person_col = "Id",
      
      metric_col = "SleepEfficiency",
      
      user_id = input$sleep_user,
      
      date_col = "SleepDay",
      
      start_date = input$sleep_dates[1],
      
      end_date = input$sleep_dates[2],
      
      rank_fun = mean
      
    ) %>%
      select(
        User = Id,
        Efficiency = value,
        Rank = rank
      )
    
    datatable(
      
      display_data,
      
      rownames = FALSE,
      
      options = list(
        pageLength = 3,
        dom = "tp"
      )
      
    )
    
  })
  
  output$avg_efficiency <- renderValueBox({
    
    req(input$sleep_user)
    
    user_avg <- sleep_day %>%
      filter(Id == input$sleep_user) %>%
      summarise(
        value = mean(SleepEfficiency, na.rm = TRUE)
      ) %>%
      pull(value)
    
    overall_avg <- sleep_day %>%
      summarise(
        value = mean(SleepEfficiency, na.rm = TRUE)
      ) %>%
      pull(value)
    
    pct_change <- ((user_avg - overall_avg) / overall_avg) * 100
    
    create_sleep_kpi_box(
      title = "Sleep Efficiency",
      value = paste0(round(user_avg, 1), "%"),
      direction = "higher_better",
      pct_change = pct_change
    )
    
  })
  
  output$avg_sleep <- renderValueBox({
    
    req(input$sleep_user)
    
    user_avg <- sleep_day %>%
      filter(Id == input$sleep_user) %>%
      summarise(
        value = mean(TotalMinutesAsleep, na.rm = TRUE)
      ) %>%
      pull(value)
    
    overall_avg <- sleep_day %>%
      summarise(
        value = mean(TotalMinutesAsleep, na.rm = TRUE)
      ) %>%
      pull(value)
    
    pct_change <- ((user_avg - overall_avg) / overall_avg) * 100
    
    create_sleep_kpi_box(
      title = "Minutes Asleep",
      value = round(user_avg),
      direction = "higher_better",
      pct_change = pct_change
    )
    
  })
  
  output$sleep_distribution <- renderPlotly({
    
    req(input$sleep_user)
    
    avg_sleep <- sleep_day %>%
      group_by(Id) %>%
      summarise(
        AvgSleep = mean(
          TotalMinutesAsleep,
          na.rm = TRUE
        ),
        .groups = "drop"
      )
    
    selected_sleep <- avg_sleep %>%
      filter(Id == input$sleep_user) %>%
      pull(AvgSleep)
    
    p <- ggplot(
      avg_sleep,
      aes(x = AvgSleep)
    ) +
      
      geom_histogram(
        bins = 10,
        fill = "#4F81BD",
        colour = "white"
      ) +
      
      geom_vline(
        xintercept = selected_sleep,
        colour = "red",
        linewidth = 1.5
      ) +
      
      labs(
        title = "Sleep Compared to Other Users",
        x = "Average Minutes Asleep",
        y = "Number of Users"
      ) +
      
      theme_minimal()
    
    ggplotly(p)
    
  })
  
  output$sleep_activity <- renderPlotly({
    
    req(input$sleep_user)
    
    avg_sleep <- sleep_day %>%
      group_by(Id) %>%
      summarise(
        AvgSleep = mean(
          TotalMinutesAsleep,
          na.rm = TRUE
        ),
        .groups = "drop"
      )
    
    avg_mets <- minute_mets %>%
      group_by(Id) %>%
      summarise(
        AvgMETs = mean(
          METs,
          na.rm = TRUE
        ),
        .groups = "drop"
      )
    
    comparison <- left_join(
      avg_sleep,
      avg_mets,
      by = "Id"
    )
    
    comparison$Selected <- ifelse(
      comparison$Id == input$sleep_user,
      "You",
      "Other Users"
    )
    
    p <- ggplot(
      comparison,
      aes(
        x = AvgSleep,
        y = AvgMETs,
        colour = Selected
      )
    ) +
      
      geom_point(size = 4) +
      
      scale_colour_manual(
        values = c(
          "Other Users" = "grey70",
          "You" = "dodgerblue"
        )
      ) +
      
      labs(
        title = "Sleep vs Physical Activity",
        x = "Average Minutes Asleep",
        y = "Average METs"
      ) +
      
      theme_minimal()
    
    ggplotly(p)
    
  })
  
  output$sleep_state_breakdown <- renderPlotly({
    
    req(input$sleep_user)
    
    sleep_states <- minute_sleep %>%
      filter(
        as.character(Id) == as.character(input$sleep_user)
      ) %>%
      mutate(
        State = case_when(
          value == 1 ~ "Asleep",
          value == 2 ~ "Restless",
          value == 3 ~ "Awake"
        )
      ) %>%
      count(State)
    
    req(nrow(sleep_states) > 0)
    
    plot_ly(
      sleep_states,
      labels = ~State,
      values = ~n,
      type = "pie",
      hole = 0.5
    ) %>%
      layout(
        title = "Sleep State Breakdown"
      )
    
  })
  
}