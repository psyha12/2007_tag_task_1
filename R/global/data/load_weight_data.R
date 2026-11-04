# Loads the data for the weight tab
# Returns a single table. Needs data_prep.R sourced first.

load_weight_data <- function() {
    read_fitbit_csv("weightLogInfo", "Date")
}
