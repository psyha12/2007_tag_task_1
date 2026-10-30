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

# 1. Load Data ------------------------------------------------------------

source("R/global/data/data_prep.R")
source("R/global/data/load_activity_data.R")
source("R/global/data/load_sleep_data.R")

source("R/global/data/load_weight_data.R")

# Sleep data

sleep_data <- load_sleep_data()


sleep_day <- sleep_data$daily_sleep
minute_sleep <- sleep_data$minute_sleep
minute_mets <- sleep_data$minute_mets

# Weight data

weight_data <- load_weight_data()

# 2. Load Functions -------------------------------------------------------

source("R/global/functions/kpi_boxes.R")
source("R/global/functions/leaderboard_function.R")
source("R/global/functions/utils.R")