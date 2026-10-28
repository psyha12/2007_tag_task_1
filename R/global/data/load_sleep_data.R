load_sleep_data <- function() {
  
  daily_sleep <- read_fitbit_csv(
    "sleepDay",
    "SleepDay"
  ) %>%
    dplyr::distinct() %>%
    dplyr::mutate(
      SleepEfficiency =
        (TotalMinutesAsleep / TotalTimeInBed) * 100
    )
  
  minute_sleep <- read_fitbit_csv(
    "minuteSleep",
    "date"
  ) %>%
    dplyr::distinct()
  
  minute_mets <- read_fitbit_csv(
    "minuteMETsNarrow",
    "ActivityMinute"
  ) %>%
    dplyr::distinct()
  
  list(
    daily_sleep = daily_sleep,
    minute_sleep = minute_sleep,
    minute_mets = minute_mets
  )
  
}