sleep_day <- read_fitbit_csv(
  "sleepDay",
  "SleepDay"
) %>%
  distinct() %>%
  mutate(
    SleepEfficiency =
      (TotalMinutesAsleep / TotalTimeInBed) * 100
  )

# Minute-by-minute sleep data

minute_sleep <- read_fitbit_csv(
  "minuteSleep",
  "date"
) %>%
  distinct()

# Minute METs data

minute_mets <- read_fitbit_csv(
  "minuteMETsNarrow",
  "ActivityMinute"
) %>%
  distinct()