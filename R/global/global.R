# Loads all source libraries / data / environmental variables / functions

# 0. Set Up ---------------------------------------------------------------

library(shiny)
library(tidyverse)
library(sf)
library(leaflet)
library(dplyr)
library(shinyWidgets)
library(shinydashboard)
library(plotly)
library(reactable)
library(janitor)
library(DT)
library(lubridate)

# 1. Load Data ------------------------------------------------------------

source("R/global/data/data_prep.R")

source("R/global/data/load_activity_data.R")
source("R/global/data/load_sleep_data.R")
source("R/global/data/load_calorie_data.R")

# Load Sleep Data
source("R/global/data/load_weight_data.R")

# Sleep data

sleep_data <- load_sleep_data()

sleep_day <- sleep_data$daily_sleep
minute_sleep <- sleep_data$minute_sleep
minute_mets <- sleep_data$minute_mets

# Load Activity Data
activity_data <- load_activity_data()

daily_activity <- activity_data$daily_activity

# Load Calorie Data
calorie_data <- load_calorie_data()

daily_calories <- calorie_data$daily_calories
hourly_calories <- calorie_data$hourly_calories
minute_calories <- calorie_data$minute_calories

# Load Daily Intensities for Calories tab
daily_intensities <- read_fitbit_csv("dailyIntensities", "ActivityDay")
# Weight data

weight_data <- load_weight_data()

# 2. Load Functions -------------------------------------------------------

source("R/functions/kpi_boxes.R")
source("R/functions/kpi_boxes_sleep.R")
source("R/functions/leaderboard_function.R")
source("R/functions/utils.R")