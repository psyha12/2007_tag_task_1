bmi_chart_background <- function() {
  weight_range_kg <- c(30, 180)
  height_range_m <- c(130:220) / 100
  height_range_m2 <- height_range_m^2

  # BMI of 18.5, 25, 30 define the boundaries of the BMI chart
  trace_underweight <- 18.5*height_range_m2
  trace_healthy     <- 25*height_range_m2
  trace_overweight  <- 30*height_range_m2
  trace_obese       <- weight_range_kg[2]

  traces <- data.frame(height_range_m, trace_underweight, trace_healthy, trace_overweight, trace_obese)

  selected_user_colors <- c("Selected user" = "red", "Other users" = "grey40")

  # Add boundaries to graph
  plot_ly(traces, x = ~height_range_m, colors = selected_user_colors) |>
    add_lines(y = ~trace_underweight, name = "Underweight", fill = "tozeroy", fillcolor = "lightblue",   line = list(width = 0), hoverinfo = "skip") |>
    add_lines(y = ~trace_healthy,     name = "Healthy",     fill = "tonexty", fillcolor = "palegreen",   line = list(width = 0), hoverinfo = "skip") |>
    add_lines(y = ~trace_overweight,  name = "Overweight",  fill = "tonexty", fillcolor = "navajowhite", line = list(width = 0), hoverinfo = "skip") |>
    add_lines(y = ~trace_obese,       name = "Obese",       fill = "tonexty", fillcolor = "mistyrose",   line = list(width = 0), hoverinfo = "skip") |>
    layout(
      xaxis = list(title = "Height (m)"),
      yaxis = list(title = "Weight (kg)", range = weight_range_kg)
    )
}

mod_weight_server <- function(input, output, session) {

  available_users <- sort(unique(weight_data$Id))

  observe({

    updateSelectInput(
        session,
        "weight_select_user",
        choices = available_users
    )

    updateDateRangeInput(
      session,
      "weight_select_dates",
      start = min(weight_data$Date),
      end = max(weight_data$Date),
      min = min(weight_data$Date),
      max = max(weight_data$Date)
    )

  })

  filtered_weight_data <- reactive({

    req(input$weight_select_dates)

    weight_data |>
      filter_by_date(
        date_start = input$weight_select_dates[1],
        date_end = input$weight_select_dates[2],
        date_col = "Date"
      )

  })

  output$weight_kpi_weight <- renderValueBox({

    entries <- filtered_weight_data() |>
      filter_by_id(input$weight_select_user) |>
      arrange(Date)

    validate(need(nrow(entries) > 0, "No entries"))

    first_value <- first(entries[["WeightKg"]])
    last_value <- last(entries[["WeightKg"]])

    create_kpi_box(
      title = "Weight (kg)",
      value = round(last_value, 1),
      change = (last_value - first_value) / first_value * 100
    )

  })

  output$weight_kpi_bmi <- renderValueBox({

    entries <- filtered_weight_data() |>
      filter_by_id(input$weight_select_user) |>
      arrange(Date)

    validate(need(nrow(entries) > 0, "No entries"))

    first_value <- first(entries[["BMI"]])
    last_value <- last(entries[["BMI"]])

    create_kpi_box(
      title = "BMI",
      value = round(last_value, 1),
      change = (last_value - first_value) / first_value * 100
    )

  })

  output$weight_bmi_graph <- renderPlotly({

    validate(need(
      sum(filtered_weight_data()$Id == input$weight_select_user) > 0, 
      "No weight entries for this user in the selected dates."
    ))

    latest_entries <- filtered_weight_data() |>
      group_by(Id) |>
      filter(Date == max(Date)) |>
      ungroup()


    bmi_chart_background() |>
      add_markers(
        data = latest_entries,
        x = ~sqrt(WeightKg / BMI),
        y = ~WeightKg,
        color = ~ifelse(Id == input$weight_select_user, "Selected user", "Other users"),
        customdata = ~BMI,
        marker = list(size = 12, line = list(color = "black", width = 1)),
        hovertemplate = "Weight: %{y:.1f} kg<br>Height: %{x:.2f} m<br>BMI: %{customdata:.1f}<extra></extra>"
      )

  })

  output$weight_leaderboard <- renderDT({

    weight_leaderboard <- create_leaderboard(
      data = filtered_weight_data(),
      person_col = "Id",
      metric_col = "BMI",
      user_id = input$weight_select_user,
      date_col = "Date",
      start_date = input$weight_select_dates[1],
      end_date = input$weight_select_dates[2],
      rank_fun = mean
    ) |>
      arrange(abs(value - 22)) |> # BMI of 22 is the most 'healthy'
      mutate(rank = row_number()) |>
      select(
        Rank = rank,
        UserId = Id,
        BMI = value
      ) |>
      mutate(BMI = round(BMI, 1))
    
    datatable(
      weight_leaderboard,
      rownames = FALSE
    )

  })

}
