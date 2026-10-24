# This script loads and prepares the necessary data for the calorie tab


# 0. Import Data ----------------------------------------------------------

daily_calories <- read_csv("R/global/data/raw_data/dailyCalories_merged.csv") %>% 
  clean_names()


hourly_calories <- read_csv("R/global/data/raw_data/hourlyCalories_merged.csv") %>% 
  clean_names()


minute_calories_narrow <- read_csv("R/global/data/raw_data/minuteCaloriesNarrow_merged.csv") %>% 
  clean_names()


minute_calories_wide <- read_csv("R/global/data/raw_data/minuteCaloriesNarrow_merged.csv") %>% 
  clean_names()