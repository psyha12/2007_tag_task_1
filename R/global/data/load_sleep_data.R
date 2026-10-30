# Loads the data for the sleep tab
# Returns a named list of tables. Needs data_prep.R sourced first.

load_sleep_data <- function() {
    list(
        daily_sleep  = read_fitbit_csv("sleepDay", "SleepDay"),

        # Value: 1 = asleep, 2 = restless, 3 = awake
        # the raw file has some exact duplicate rows, which are dropped
        minute_sleep = dplyr::distinct(read_fitbit_csv("minuteSleep", "date"))
    )
}
