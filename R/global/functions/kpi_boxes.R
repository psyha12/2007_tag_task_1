#' Create KPI box function that can be used across the dashboard 
#' 
#' @param title - Title of the box 
#' @param value - The metric to show in the box - E.g. Number of Steps 
#' @param change - The change in the metric - E.g. The percentage change in number of steps 

create_kpi_box <- function(title, value, change) {
  
  colour <- if (change > 0) { "green" } # E.g. If Steps have increased - show green
  else if (change < 0) { "red" }        # E.g. If steps have decreased - show red 
  else { "blue" }                       # E.g. If steps haven't changed - show blue 
  
  arrow <- if (change > 0) { icon("caret-up") }   # E.g. If Steps have increased - show arrow upwards
  else if (change < 0) { icon("caret-down") }     # E.g. If Steps have increased - show arrow downwards
  else { icon("minus") }                          # E.g. If Steps have increased - show no arrow 
  
  valueBox(value = value,
           subtitle = tagList(title,                         # Title of the box 
                              br(),                          # Line space 
                              arrow,                         # Arrow 
                              paste(round(change, 1), "%")), # Percentage Change 
           color = colour)                # Colour of the box 
}