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
# sedentary - active minutes

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



# check datasets are the same
# calories 
setequal(dailyActivity$calories, dailyCalories$calories)
# light_active_distance
setequal(dailyActivity$light_active_distance, dailyIntensities$light_active_distance)
# very_active_minutes
setequal(dailyActivity$very_active_minutes, dailyIntensities$very_active_minutes)
# very_active_distance
setequal(dailyActivity$very_active_distance, dailyIntensities$very_active_distance)
# ok so checking all calories and spot checking 3 intensities columns to activity suggests its the same

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
# Most days are below 15,000

dailyActivity %>%
  ggplot(aes(calories)) +
  geom_histogram(bins = 30, fill = "darkgreen") +
  labs(title = "Distribution of Daily Calories")
# typical calorie burn around 2000 a day
# if a day has 0 calorie burn thats impossible so could discount those rows?

dailyIntensities %>%
  ggplot(aes(sedentary_minutes)) +
  geom_histogram(bins = 30, fill = "darkred") +
  labs(title = "Distribution of Sedentary Minutes")
# multiple peaks - biomodal - distinct clusters of sedentry minutes 


dailyActivity %>%
  ggplot(aes(y = total_steps)) +
  geom_boxplot(fill = "lightblue") +
  labs(title = "Daily Steps")
# outlier of over 20,000 w one 35,000 steps
# median 7406  
# half of all recorded days betweeen 4000 - 10500 steps

dailyActivity %>%
  ggplot(aes(y = calories)) +
  geom_boxplot(fill = "lightgreen") +
  labs(title = "Daily Calories")
# Outlier of over 5000
# half of all recorded days betweeen 1800 - 2800 cals
# several low outliers - again remove from data ? 

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
# as expected moderate - strong positive relationship 
# can see natural differentiation in how different ppl burn different amounts of calories or the same amount of steps - could link to diff intensity?
cor(dailyActivity$total_steps,
    dailyCalories$calories,
    use = "complete.obs")
# 0.5915681 moderate positive relation 



# 4. Summary  -------------------------------------------------------------
# Just do a summary of activity as its 
summmary <- dailyActivity %>% 
  group_by(id) %>%
  summarise(
    avg_steps = mean(total_steps, na.rm = TRUE),
    max_steps = max(total_steps, na.rm = TRUE),
    avg_calories = mean(calories, na.rm = TRUE),
    max_calories = max(calories, na.rm = TRUE),
    avg_sedentary = mean(sedentary_minutes, na.rm = TRUE),
    avg_V_active = mean(very_active_minutes, na.rm = TRUE),
    days_recorded = n()
  )


# remove outliers where:
# would suggest removing rows where steps are 0 but these have avg calories in it - this could be due to a sync issue of just step data or has been generated by fiitbt avg (1440 minutes in a day)

# so do we want to include these?
# I think remove for individual columns? 
## so steps get removed if == 0
## calories remove if < 900 (minimum possible to burn in a day)
## check if distance columns add up, if not remove them
## check if all minutes add up to 1440 - acc impossible due to needing to charge watch 
## whast the difference between tracker, logged and total distance - work out


# CONCLUSION
# The exploratory data analysis found that the Fitbit data is of good quality, containing 940 daily records from 33 participants over a 31-day period with no missing values, duplicates, or inconsistencies between datasets. The analysis showed that participants recorded a median of 7,406 steps and burned a median of 2,134 calories per day, although both measures exhibited some high-value outliers corresponding to particularly active days. Sedentary behaviour was generally high, with a median of 1,058 sedentary minutes per day, and the distribution suggests distinct activity patterns between participants. A moderate positive relationship was identified between step count and calories burned (r = 0.59), indicating that more active individuals tend to burn more calories, although other factors such as activity intensity and individual physiology also play a significant role. Overall, the dataset provides a reliable basis for further analysis and dashboard development, with only a small number of potentially unrealistic records (e.g. zero calories, zero steps, or full-day sedentary readings) requiring investigation or flagging as possible device non-wear days.

