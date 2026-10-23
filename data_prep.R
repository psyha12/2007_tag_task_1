# Data preparation for the Fitbit dashboard

# Parses Fitbit timestamps into POSIXct
# Handles both "4/12/2016" and "4/12/2016 12:03:00 AM" (month/day/year).
# Anything that can't be parsed becomes NA
parse_fitbit_datetime <- function(x) {
    lubridate::parse_date_time(x, orders = c("mdY IMS p", "mdY"), tz = "UTC")
}
