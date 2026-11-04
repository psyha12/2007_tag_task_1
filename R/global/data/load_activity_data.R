# Loads the data for the activity tab
# Returns a named list of tables. Needs data_prep.R sourced first.

load_activity_data <- function() {
    list(
        daily_activity     = read_fitbit_csv("dailyActivity",            "ActivityDate"),
        daily_steps        = read_fitbit_csv("dailySteps",               "ActivityDay"),
        daily_intensities  = read_fitbit_csv("dailyIntensities",         "ActivityDay"),
        hourly_steps       = read_fitbit_csv("hourlySteps",              "ActivityHour"),
        hourly_intensities = read_fitbit_csv("hourlyIntensities",        "ActivityHour"),
        minute_steps = merge_narrow_wide(
            "minuteStepsNarrow", "ActivityMinute",
            "minuteStepsWide",   "ActivityHour", "Steps"
            ),
        minute_intensities = merge_narrow_wide(
            "minuteIntensitiesNarrow", "ActivityMinute",
            "minuteIntensitiesWide",   "ActivityHour", "Intensity"
            ),
        minute_mets        = read_fitbit_csv("minuteMETsNarrow",         "ActivityMinute")
    )
}

