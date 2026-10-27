# Shared helpers for loading the Fitbit data. Nothing is loaded when this file
# is sourced; each tab has its own load_*_data() function (load_*.R in this
# folder) that returns the tables for that tab.
# Source this file before calling any of them.
#
# Column names are kept exactly as they are in the CSVs. In every table:
#   - `Id` is a character
#   - the timestamp column is POSIXct in UTC. Daily data is midnight on that day
#
# Minute data comes in Narrow and Wide files. merge_narrow_wide() melts the
# wide one and outer joins it to the narrow one, so both time windows are kept.

# Folder holding the *_merged.csv files, relative to the app root
fitbit_data_dir <- "data"


# Parses Fitbit timestamps into POSIXct
# Handles both "4/12/2016" and "4/12/2016 12:03:00 AM" (month/day/year).
# Anything that can't be parsed becomes NA
parse_fitbit_datetime <- function(x) {
    lubridate::parse_date_time(x, orders = c("mdY IMS p", "mdY"), tz = "UTC")
}

# reads <name>_merged.csv. time_col is the name of its timestamp column.
read_fitbit_csv <- function(name, time_col) {
    df <- readr::read_csv(file.path(fitbit_data_dir, paste0(name, "_merged.csv")),
                          show_col_types = FALSE)

    df$Id <- as.character(df$Id)
    df[[time_col]] <- parse_fitbit_datetime(df[[time_col]])
    df
}

# merges a narrow and wide file with an outer join.
# value is the measure's name in both files
merge_narrow_wide <- function(narrow, narrow_time_col, wide, wide_time_col, value) {
    narrow <- read_fitbit_csv(narrow, narrow_time_col)

    wide <- read_fitbit_csv(wide, wide_time_col) |>
        tidyr::pivot_longer(dplyr::starts_with(value), names_prefix = value,
                            names_to = "minute", names_transform = as.numeric, values_to = value)

    wide[[narrow_time_col]] <- wide[[wide_time_col]] + 60 * wide$minute
    wide <- wide[c("Id", narrow_time_col, value)]

    dplyr::full_join(narrow, wide, by = c("Id", narrow_time_col, value))
}
