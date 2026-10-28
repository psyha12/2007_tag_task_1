# Loads the data for the calories tab
# Returns a named list of tables. Needs data_prep.R sourced first.

load_calorie_data <- function() {
    list(
        daily_calories  = read_fitbit_csv("dailyCalories",         "ActivityDay"),
        hourly_calories = read_fitbit_csv("hourlyCalories",        "ActivityHour"),
        minute_calories = merge_narrow_wide(
            "minuteCaloriesNarrow", "ActivityMinute",
            "minuteCaloriesWide",   "ActivityHour", "Calories"
            )
    )
}
