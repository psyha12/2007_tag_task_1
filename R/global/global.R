

source("R/global/functions/kpi_boxes.R")
source("R/global/functions/leaderboard_function.R")
source("R/global/functions/utils.R")
source("R/global/data/data_prep.R")
source("R/global/data/load_sleep_data.R")

sleep_data <- load_sleep_data()

sleep_day <- sleep_data$daily_sleep
minute_sleep <- sleep_data$minute_sleep
minute_mets <- sleep_data$minute_mets
