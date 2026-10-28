# Sourced with local = TRUE inside server(), so input/output/session are in scope

observe({
  
  updateDateRangeInput(
    session,
    "activity_dates",
    start = min(daily_activity$date, na.rm = TRUE),
    end   = max(daily_activity$date, na.rm = TRUE)
  )
  
})

activity_data <- reactive({
  
  req(input$selected_id)
  
  daily_activity %>%
    filter(id %in% input$selected_id)
  
})

leaderboard <- reactive({
  
  req(input$activity_dates)
  
  create_leaderboard(
    data = activity_data(),
    person_col = "id",
    metric_col = "total_steps",
    date_col = "date",
    start_date = input$activity_dates[1],
    end_date = input$activity_dates[2]
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
      id = as.character(id)
    ) %>%
    select(
      Rank = Medal,
      User = id,
      Steps = value
    )
  
  datatable(
    display_data,
    rownames = FALSE,
    options = list(
      pageLength = 10,
      dom = "tp"
    )
  )
  
})
