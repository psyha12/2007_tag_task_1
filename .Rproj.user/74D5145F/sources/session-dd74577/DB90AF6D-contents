# Fitbit Dashboard
# Run with: shiny::runApp()  (or click "Run App" in RStudio)
# source("data_prep.R")

library(shiny)
library(bslib)     
library(dplyr)
library(ggplot2)
library(lubridate)


# Values used by the filters
all_ids    <- sort(unique(c(hrly_steps$Id, heart_rate_secs$Id, weight_log_info$Id)))
date_start <- as_date(min(hrly_steps$ActivityHour, na.rm = TRUE))
date_end   <- as_date(max(hrly_steps$ActivityHour, na.rm = TRUE))

# ----- Dashboard Design -----
app_colour <- "#00A3AD"

app_theme <- bs_theme(
  version   = 5,
  bootswatch = "flatly",
  primary   = app_colour,
  base_font = font_google("Inter", local = FALSE)
)

theme_set(theme_minimal(base_size = 13))

# ----- Fitbit Dashboard User-Interface -----
ui <- page_navbar(
  title = "Fitbit Activity Dashboard",
  theme = app_theme,
  fillable = FALSE,
  
  # ---- Overview ----
  nav_panel("Overview",
            div(class = "container-fluid",
                layout_columns(
                  col_widths = c(3, 3, 3, 3),
                  value_box("Participants", "-"),            # e.g. valueBox output
                  value_box("Date range", "-"),
                  value_box("In all 3 datasets", "-"),
                  value_box("Total records", "-")
                ),
                layout_columns(
                  col_widths = c(6, 6)
                )
            )
  ),
  
  # ---- Steps ----
  nav_panel("Steps",
            div(layout_columns(
                  col_widths = c(6, 6)
                ),
                layout_columns(
                  col_widths = 12
                )
            )
  ),
  
  # ---- Heart Rate ----
  nav_panel("Heart Rate",
            div(
                layout_columns(
                  col_widths = c(6, 6)
                )
            )
  ),
  
  # ---- Weight ----
  nav_panel("Weight",
            div(
                layout_columns(
                  col_widths = c(8, 4)
                )
            )
  )
)
# ----- Server -----
server <- function(input, output, session) {
  
}

# Run the app
shinyApp(ui, server)