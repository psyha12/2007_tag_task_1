# Filters
observeEvent(TRUE, {
  
  updateDateRangeInput(
    session,
    "activity_dates",
    start = min(daily_activity$ActivityDate, na.rm = TRUE),
    end = max(daily_activity$ActivityDate, na.rm = TRUE),
    min = min(daily_activity$ActivityDate, na.rm = TRUE),
    max = max(daily_activity$ActivityDate, na.rm = TRUE)
  )
  
}, once = TRUE)


# Filtered Daily Activity

activity_data <- reactive({
  
  req(input$selected_id, input$activity_dates)
  req(length(input$selected_id) > 0)
  
  daily_activity %>%
    filter(
      Id %in% input$selected_id,
      ActivityDate >= input$activity_dates[1],
      ActivityDate <= input$activity_dates[2]
    )
  
})


# All Participants for KPI Comparisons 

overall_activity <- reactive({
  
  req(input$activity_dates)
  
  daily_activity %>%
    filter(
      ActivityDate >= input$activity_dates[1],
      ActivityDate <= input$activity_dates[2]
    )
  
})


# Hourly Steps (Using filtered data)

hourly_activity_data <- reactive({
  
  req(input$selected_id, input$activity_dates)
  req(length(input$selected_id) > 0)
  
  hourly_steps %>%
    filter(
      Id %in% input$selected_id,
      as.Date(ActivityHour) >= input$activity_dates[1],
      as.Date(ActivityHour) <= input$activity_dates[2]
    )
  
})


# Filtered Daily Intensities

intensity_data <- reactive({
  
  req(input$selected_id, input$activity_dates)
  req(length(input$selected_id) > 0)
  
  daily_intensities %>%
    filter(
      Id %in% input$selected_id,
      ActivityDay >= input$activity_dates[1],
      ActivityDay <= input$activity_dates[2]
    )
  
})


# Leaderboard

leaderboard <- reactive({
  
  req(nrow(activity_data()) > 0)
  
  create_leaderboard(
    data = activity_data(),
    person_col = "Id",
    metric_col = "TotalSteps",
    date_col = "ActivityDate",
    start_date = input$activity_dates[1],
    end_date = input$activity_dates[2],
    rank_fun = sum
  )
  
})


output$activity_leaderboard <- renderDT({
  
  display_data <- leaderboard() %>%
    mutate(
      Medal = case_when(
        rank == 1 ~ "\U0001F947",
        rank == 2 ~ "\U0001F948",
        rank == 3 ~ "\U0001F949",
        TRUE ~ as.character(rank)
      ),
      Id = as.character(Id)
    ) %>%
    select(
      Rank = Medal,
      User = Id,
      Steps = value
    )
  
  DT::datatable(
    display_data,
    rownames = FALSE,
    options = list(
      pageLength = 10,
      dom = "tp"
    )
  ) %>%
    DT::formatRound(
      columns = "Steps",
      digits = 0,
      mark = ","
    )
  
})


# Average Daily Steps KPI

output$avg_steps <- renderValueBox({
  
  req(nrow(activity_data()) > 0)
  
  selected_avg <- activity_data() %>%
    summarise(
      value = mean(TotalSteps, na.rm = TRUE)
    ) %>%
    pull(value)
  
  overall_avg <- overall_activity() %>%
    summarise(
      value = mean(TotalSteps, na.rm = TRUE)
    ) %>%
    pull(value)
  
  pct_change <- if (
    is.finite(overall_avg) && overall_avg != 0
  ) {
    ((selected_avg - overall_avg) / overall_avg) * 100
  } else {
    NA_real_
  }
  
  create_kpi_box(
    title = "Average Daily Steps",
    value = round(selected_avg),
    direction = "higher_better",
    pct_change = pct_change,
    icon_name = "person-walking"
  )
  
})


# Average Daily Active Minutes KPI 

output$avg_active_minutes <- renderValueBox({
  
  req(nrow(activity_data()) > 0)
  
  selected_avg <- activity_data() %>%
    mutate(
      ActiveMinutes = VeryActiveMinutes +
        FairlyActiveMinutes +
        LightlyActiveMinutes
    ) %>%
    summarise(
      value = mean(ActiveMinutes, na.rm = TRUE)
    ) %>%
    pull(value)
  
  overall_avg <- overall_activity() %>%
    mutate(
      ActiveMinutes = VeryActiveMinutes +
        FairlyActiveMinutes +
        LightlyActiveMinutes
    ) %>%
    summarise(
      value = mean(ActiveMinutes, na.rm = TRUE)
    ) %>%
    pull(value)
  
  pct_change <- if (
    is.finite(overall_avg) && overall_avg != 0
  ) {
    ((selected_avg - overall_avg) / overall_avg) * 100
  } else {
    NA_real_
  }
  
  create_kpi_box(
    title = "Average Daily Active Minutes",
    value = round(selected_avg),
    direction = "higher_better",
    pct_change = pct_change,
    icon_name = "stopwatch"
  )
  
})


# Daily Steps Trend 

output$steps_trend <- renderPlotly({
  
  req(input$compare_id, input$activity_dates)
  
  # Overall Average
  
  overall_steps <- overall_activity() %>%
    group_by(ActivityDate) %>%
    summarise(
      Steps = mean(TotalSteps, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(
      Participant = "Overall Average"
    )
  
  
  # Selected Participant 
  
  selected_steps <- overall_activity() %>%
    filter(
      as.character(Id) == as.character(input$compare_id)
    ) %>%
    group_by(ActivityDate) %>%
    summarise(
      Steps = mean(TotalSteps, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(
      Participant = "Selected Participant"
    )
  
  
  # Combine Both Datasets 
  
  plot_data <- bind_rows(
    overall_steps,
    selected_steps
  )
  
  req(nrow(selected_steps) > 0)
  
  
  # Create Graph
  
  p <- ggplot(
    plot_data,
    aes(
      x = ActivityDate,
      y = Steps,
      colour = Participant,
      group = Participant
    )
  ) +
    geom_line(
      aes(linetype = Participant),
      linewidth = 0.8
    ) +
    geom_point(size = 0.8) +
    scale_linetype_manual(
      values = c(
        "Overall Average" = "dashed",
        "Selected Participant" = "solid"
      )
    ) +
    scale_colour_manual(
      values = c(
        "Overall Average" = "#00A3AD",
        "Selected Participant" = "#F28E2B"
      )
    ) +
    labs(
      x = "Date",
      y = "Daily Steps",
      colour = NULL,
      linetype = NULL
    ) +
    guides(linetype = "none") +
    theme_minimal()
  
  ggplotly(p)
})


# Hourly Steps Pattern

output$hourly_steps_plot <- renderPlotly({
  
  req(nrow(hourly_activity_data()) > 0)
  
  plot_data <- hourly_activity_data() %>%
    mutate(
      Hour = lubridate::hour(ActivityHour)
    ) %>%
    group_by(Hour) %>%
    summarise(
      AvgSteps = mean(StepTotal, na.rm = TRUE),
      .groups = "drop"
    )
  
  p <- ggplot(
    plot_data,
    aes(
      x = Hour,
      y = AvgSteps
    )
  ) +
    geom_col(fill = "#00A3AD") +
    scale_x_continuous(breaks = 0:23) +
    labs(
      title = "Average Steps by Hour",
      x = "Hour of Day",
      y = "Average Hourly Steps"
    ) +
    theme_minimal()
  
  ggplotly(p)
  
})


# Activity Intensity Breakdown

output$activity_intensity <- renderPlotly({
  
  req(nrow(intensity_data()) > 0)
  
  plot_data <- intensity_data() %>%
    summarise(
      VeryActive = mean(VeryActiveMinutes, na.rm = TRUE),
      FairlyActive = mean(FairlyActiveMinutes, na.rm = TRUE),
      LightlyActive = mean(LightlyActiveMinutes, na.rm = TRUE),
      Sedentary = mean(SedentaryMinutes, na.rm = TRUE)
    ) %>%
    tidyr::pivot_longer(
      cols = everything(),
      names_to = "Intensity",
      values_to = "Minutes"
    )
  
  p <- ggplot(
    plot_data,
    aes(
      x = "Selected Participants",
      y = Minutes,
      fill = Intensity
    )
  ) +
    geom_col() +
    labs(
      title = "Average Daily Activity Intensity",
      x = NULL,
      y = "Average Minutes per Day",
      fill = "Intensity"
    ) +
    theme_minimal()
  
  ggplotly(p)
  
})
