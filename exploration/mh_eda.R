library(dplyr)
library(ggplot2)

files <- list.files("data", pattern = "\\.csv$", full.names = TRUE)

hrly_steps <- read.csv("data/hourlySteps_merged.csv") |> 
  mutate(Id = as.character(Id),
         ActivityHour = lubridate::mdy_hms(ActivityHour))

heart_rate_secs <- read.csv("data/heartrate_seconds_merged.csv") |>
  mutate(Id = as.character(Id),
         Time = lubridate::mdy_hms(Time))

weight_log_info<- read.csv("data/weightLogInfo_merged.csv") |> 
  mutate(Id = as.character(Id),
         Date = lubridate::mdy_hms(Date))

summary(hrly_steps)
summary(heart_rate_secs)
summary(weight_log_info)

# Check for missing Values 
colSums(is.na(hrly_steps))
colSums(is.na(heart_rate_secs))
colSums(is.na(weight_log_info))
# None of these datasets have missing values 

# Check for duplicates 
sum(duplicated(hrly_steps))
sum(duplicated(heart_rate_secs))
sum(duplicated(weight_log_info))
# None of these datasets have duplicate records 

# Unique IDs - there should be 30 as stated in the brief? 
dplyr::n_distinct(hrly_steps$Id) # 33 is there actually 33 participants - this needs to be invetsigated 
dplyr::n_distinct(heart_rate_secs$Id)
dplyr::n_distinct(weight_log_info$Id) # only 8 recorded in the weight log info

range(hrly_steps$ActivityHour)
range(heart_rate_secs$Time)
range(weight_log_info$Date)

# Create summary table for my 3 datasets 
data.frame(
  Dataset = c("Hourly Steps", "Heart Rate Seconds", "Weight Log"),
  Rows = c(nrow(hrly_steps),
           nrow(heart_rate_secs),
           nrow(weight_log_info)),
  Columns = c(ncol(hrly_steps),
              ncol(heart_rate_secs),
              ncol(weight_log_info)),
  Unique_Users = c(dplyr::n_distinct(hrly_steps$Id),
                   dplyr::n_distinct(heart_rate_secs$Id),
                   dplyr::n_distinct(weight_log_info$Id))
)

as.numeric(diff(range(hrly_steps$ActivityHour)), units = "days")  # How much data does each participant have?
hrly_steps %>% count(Id, name = "n_hours") %>% arrange(n_hours)
heart_rate_secs %>% count(Id, name = "n_readings") %>% arrange(n_readings)
weight_log_info %>% count(Id, name = "n_weigh_ins") %>% arrange(n_weigh_ins)

# ------ Which IDs appear in more than one dataset?
ids_steps  <- unique(hrly_steps$Id)
ids_hr     <- unique(heart_rate_secs$Id)
ids_weight <- unique(weight_log_info$Id)

length(intersect(ids_steps, ids_hr))
length(intersect(ids_steps, ids_weight))
length(Reduce(intersect, list(ids_steps, ids_hr, ids_weight))) # how many people have all three types of data

hrly_steps %>%
  group_by(Id) %>%
  summarise(first = min(ActivityHour),
            last = max(ActivityHour),
            expected = as.numeric(difftime(last, first, units = "hours")) + 1,
            actual = n(),
            missing = expected - actual) %>%
  arrange(desc(missing))

ggplot(hrly_steps, aes(StepTotal)) + geom_histogram(bins = 50)
ggplot(heart_rate_secs, aes(Value)) + geom_histogram(bins = 50)
ggplot(weight_log_info, aes(WeightKg)) + geom_histogram(bins = 30)
ggplot(weight_log_info, aes(y = WeightKg)) + geom_boxplot()

# ------ Average steps for each hour in the day 
hrly_steps %>%
  mutate(hour = lubridate::hour(ActivityHour)) %>%
  group_by(hour) %>%
  summarise(avg_steps = mean(StepTotal)) %>%
  ggplot(aes(hour, avg_steps)) + geom_col()

# ------ Average Steps based on a week 
hrly_steps %>%
  mutate(day = lubridate::wday(ActivityHour, label = TRUE)) %>%
  group_by(day) %>%
  summarise(avg_steps = mean(StepTotal)) %>%
  ggplot(aes(day, avg_steps)) + geom_col()

# ----- Investigation of heart rate -----
# Hourly mean, min and max 
hr_hourly <- heart_rate_secs %>%
  mutate(ActivityHour = floor_date(Time, "hour")) %>%
  group_by(Id, ActivityHour) %>%
  summarise(avg_hr = mean(Value), min_hr = min(Value), max_hr = max(Value),
            .groups = "drop")

hr_hourly %>%
  filter(Id == first(Id)) %>%     # swap for input$participant in the app
  ggplot(aes(ActivityHour)) +
  geom_ribbon(aes(ymin = min_hr, ymax = max_hr), alpha = 0.2, fill = "#00A3AD") +
  geom_line(aes(y = avg_hr), colour = "#00A3AD") +
  labs(title = "Hourly heart rate", x = "Time", y = "Heart rate (bpm)")

# Average heart rate by hour of day 
hr_hourly %>%
  mutate(hour = hour(ActivityHour)) %>%
  group_by(hour) %>%
  summarise(avg_hr = mean(avg_hr)) %>%
  ggplot(aes(hour, avg_hr)) +
  geom_line(colour = "#00A3AD") + geom_point(colour = "#00A3AD") +
  labs(title = "Average heart rate by hour of day",
       x = "Hour of day", y = "Heart rate (bpm)")
