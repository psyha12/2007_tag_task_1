# Loads the data for the heart rate tab
# Returns a single table (about 2.5M rows). Needs data_prep.R sourced first.

load_heartrate_data <- function() {
    read_fitbit_csv("heartrate_seconds", "Time")
}
