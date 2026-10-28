# utilities to use to reduce code duplication

# Filters data by a shiny::dateRangeInput (inclusive)
# date_col is the table's timestamp column (e.g. "ActivityDate", "Time"), see data_prep.R
filter_by_date <- function(df, date_start, date_end, date_col) {
    if (!(date_col %in% colnames(df))) {
        stop("Column '", date_col, "' not found in data")
    }
    date_start <- lubridate::as_date(date_start)
    date_end <-   lubridate::as_date(date_end)

    df <- df |>
        dplyr::filter(dplyr::between(lubridate::as_date(.data[[date_col]]), date_start, date_end))
    return (df)
}

# Keeps only the selected participants. No selection (NULL or empty) means everyone.
# (the argument is `ids`, not `id`, so it can't be masked by the `id` column)
filter_by_id <- function(df, ids, id_col="Id") {
    if (!(id_col %in% colnames(df))) {
        stop("Column '", id_col, "' not found in data")
    }
    if (length(ids) == 0) {
        return (df)
    }

    df <- df |>
        dplyr::filter(.data[[id_col]] %in% ids)
    return (df)
}
