# Purpose of this script is to explore dailyActivity_merged, dailyCalories_merged, dailyIntensities_merged







# # 0. Set up ---------------------------------------------------------------
library(odbc) 
library(dplyr) 
library(tidyr) 
library(DBI)
library(stringr)
library(scales)
library(reshape2)
library(janitor)
library(DT)
library(gt)
library(openxlsx)
library(tidyverse)
library(skimr)
library(janitor) 
library(GGally)
library(tidyverse)
library(plotly)
library(skimr)
library(corrplot)






# Import data 
dailyActivity <- read_csv("Data/dailyActivity_merged.csv") %>% 
  clean_names()

dailyCalories <- read_csv("Data/dailyCalories_merged.csv") %>% 
  clean_names()


dailyIntensities <- read_csv("Data/dailyIntensities_merged.csv") %>% 
  clean_names()



# 1. Check data ------------------------------------------------------------
# what
names(dailyActivity)
# daily steps, distance, sedentry - active minutes, daily calories
names(dailyCalories)
# just daily calories
names(dailyIntensities)
# sedentry - active minutes

# check if data is the same- if so daily activity is the only dataset needed as duplicated in calories and intensities 



# check NA's
colSums(is.na(dailyActivity))
colSums(is.na(dailyCalories))
colSums(is.na(dailyIntensities))
# no NA's

# check duplicates
sum(duplicated(dailyActivity))
sum(duplicated(dailyCalories))
sum(duplicated(dailyIntensities))
# no dulicates

# check users
n_distinct(dailyActivity$id)
n_distinct(dailyCalories$id)
n_distinct(dailyIntensities$id)
setequal(dailyActivity$id, dailyCalories$id)
setequal(dailyActivity$id, dailyIntensities$id)

# consistent date format needed
dailyActivity$date <- as.Date(dailyActivity$activity_date,
                              format = "%m/%d/%Y")

dailyCalories$date <- as.Date(dailyCalories$activity_day,
                              format = "%m/%d/%Y")

dailyIntensities$date <- as.Date(dailyIntensities$activity_day,
                                 format = "%m/%d/%Y")

range.Date(dailyActivity$date)
range.Date(dailyCalories$date)
range.Date(dailyIntensities$date)
# all datasets have the same range "2016-04-12" "2016-05-12"






# 2. Summary Stats --------------------------------------------------------

summary(dailyActivity)
summary(dailyCalories)
summary(dailyIntensities)

skim(dailyActivity)
skim(dailyCalories)
skim(dailyIntensities)




# 3. Visuals --------------------------------------------------------------


dailyActivity %>%
  ggplot(aes(total_steps)) +
  geom_histogram(bins = 30, fill = "steelblue") +
  labs(title = "Distribution of Daily Steps")

dailyActivity %>%
  ggplot(aes(calories)) +
  geom_histogram(bins = 30, fill = "darkgreen") +
  labs(title = "Distribution of Daily Calories")

dailyIntensities %>%
  ggplot(aes(sedentary_minutes)) +
  geom_histogram(bins = 30, fill = "darkred") +
  labs(title = "Distribution of Sedentary Minutes")


dailyActivity %>%
  ggplot(aes(y = total_steps)) +
  geom_boxplot(fill = "lightblue") +
  labs(title = "Daily Steps")

dailyActivity %>%
  ggplot(aes(y = calories)) +
  geom_boxplot(fill = "lightgreen") +
  labs(title = "Daily Calories")

# compare calories to steps
dailyActivity %>%
  ggplot(aes(total_steps, calories)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", colour = "red") +
  labs(
    title = "Steps vs Calories Burned",
    x = "Total Steps",
    y = "Calories"
  )



# 4. Join -----------------------------------------------------------------



# Rename everything except join fields as have the same name
dailyActivity_renamed <- dailyActivity %>%
  rename_with(~paste0("activity_", .x), -c(id, date))

dailyCalories_renamed <- dailyCalories %>%
  rename_with(~paste0("calories_", .x), -c(id, date))

dailyIntensities_renamed <- dailyIntensities %>%
  rename_with(~paste0("intensity_", .x),-c(id, date))

# Join
merged_data <- dailyActivity_renamed %>%
  left_join(dailyCalories_renamed, by = c("id", "date")) %>%
  left_join(dailyIntensities_renamed, by = c("id", "date"))

names(merged_data)

remove_duplicate_columns <- function(df) {
  
  dup_cols <- sapply(seq_along(df), function(i) {
    any(sapply(seq_len(i - 1), function(j) {
      identical(df[[i]], df[[j]])
    }))
  })
  
  df[, !dup_cols]
}
names(cleaned_merged_data)

cleaned_merged_data <- remove_duplicate_columns(merged_data)

summary <- cleaned_merged_data %>%
  group_by(id) %>%
  summarise(
    avg_steps = mean(activity_total_steps, na.rm = TRUE),
    max_steps = max(activity_total_steps, na.rm = TRUE),
    avg_calories = mean(activity_calories, na.rm = TRUE),
    avg_sedentary = mean(activity_sedentary_minutes, na.rm = TRUE),
    avg_active = mean(activity_very_active_minutes, na.rm = TRUE),
    days_recorded = n()
  )



# 5. Visuals --------------------------------------------------------------

# steps vs calories
p <- ggplot(
  cleaned_merged_data,
  aes(
    x = activity_total_steps,
    y = activity_calories
  )
) +
  geom_point(alpha = .6) +
  geom_smooth(
    method = "lm",
    colour = "red"
  ) +
  labs(
    title = "Steps vs Calories Burned"
  )

ggplotly(p)


# sedentry time vs calories
p <- ggplot(
  cleaned_merged_data,
  aes(very_active_minutes,
      calories)) +
  geom_point(alpha = .6) +
  geom_smooth(
    method = "lm",
    colour = "red"
  ) +
  labs(
    title = "Very Active Minutes vs Calories"
  )

ggplotly(p)


# leaderboard
top10 <- summary %>%
  arrange(desc(avg_steps)) %>%
  head(10)

plot_ly(
  top10,
  x = ~reorder(as.factor(id), avg_steps),
  y = ~avg_steps,
  type = "bar"
) %>%
  layout(
    title = "Top 10 Users by Average Daily Steps",
    xaxis = list(title = "User"),
    yaxis = list(title = "Average Steps")
  )

# bottomboard
bottom10 <- summary %>%
  arrange(avg_steps) %>%
  head(10)

plot_ly(
  bottom10,
  x = ~reorder(as.factor(id), avg_steps),
  y = ~avg_steps,
  type = "bar"
) %>%
  layout(
    title = "Least Active Users",
    xaxis = list(title = "User"),
    yaxis = list(title = "Average Steps")
  )


plot_ly(
  summary,
  x = ~avg_active,
  y = ~avg_sedentary,
  type = "scatter",
  mode = "markers",
  text = ~id
) %>%
  layout(
    title = "Active vs Sedentary Behaviour",
    xaxis = list(title = "Average Active Minutes"),
    yaxis = list(title = "Average Sedentary Minutes")
  )


activity_summary <- cleaned_merged_data %>%
  count(activity_band)

plot_ly(
  activity_summary,
  labels = ~activity_band,
  values = ~n,
  type = "pie"
) %>%
  layout(
    title = "Activity Category Distribution"
  )


summary %>%
  summarise(
    average_steps = mean(avg_steps),
    average_calories = mean(avg_calories),
    average_active_minutes = mean(avg_active),
    average_sedentary_minutes = mean(avg_sedentary)
  )
