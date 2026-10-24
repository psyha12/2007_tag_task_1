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
# for each tab, write your data prep in a script (saved in the data folder)

source("R/global/data/load_activity_data.R")
#source("R/global/data/load_calorie_data.R")



# 2. Load Functions -------------------------------------------------------

source("R/global/functions/leaderboard_function.R")
