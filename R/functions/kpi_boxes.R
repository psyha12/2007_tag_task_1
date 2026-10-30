#' Create KPI box function that can be used across the dashboard 
#' 
#' @param title - Title of the box 
#' @param value - The metric to show in the box - E.g. Number of Steps 
#' @param direction - Has the value increased or decreased? 
#' @param pct_change - The change in the metric - E.g. The percentage change in number of steps 
create_kpi_box <- function(title, value, direction, pct_change = NULL) {
  
  # ----- Handle Missing KPI Values -----
  if (is.null(value) ||
      length(value) == 0 ||
      is.na(value) ||
      is.nan(value) ||
      is.infinite(value)) {
    
    return(
      shinydashboard::valueBox(
        value = "N/A",
        subtitle = title,
        icon = shiny::icon("minus"),
        color = "light-blue"
      )
    )
  }
  
  # ----- Handle Missing Percentage Changes -----
  if (is.null(pct_change) ||
      length(pct_change) == 0 ||
      is.na(pct_change) ||
      is.nan(pct_change) ||
      is.infinite(pct_change)) {
    
    pct_change <- 0
  }
  
  # ----- Determine Colour -----
  if (pct_change == 0 || direction == "neutral") {
    colour <- "light-blue"
  } else if (direction == "higher_better") {
    colour <- ifelse(pct_change > 0, "green", "red")
  } else if (direction == "lower_better") {
    colour <- ifelse(pct_change < 0, "green", "red")
  }
  
  # ----- Arrow Text -----
  if (pct_change > 0) {
    icon_text <- paste0("\u25B2 ", round(pct_change, 1), "%")
  } else if (pct_change < 0) {
    icon_text <- paste0("\u25BC ", abs(round(pct_change, 1)), "%")
  } else {
    icon_text <- "0%"
  }
  
  # ----- Create Value Box -----
  shinydashboard::valueBox(
    value = tagList(value,
                    tags$br(),
                    tags$span(icon_text,
                              style = "
                    color:white;
                    font-size:14px;
                    font-weight:bold;
                    ")
    ),
    subtitle = title,
    icon = shiny::icon("heartbeat"),
    color = colour
  )
  
}