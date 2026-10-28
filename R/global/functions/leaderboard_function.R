# This script creates the leaderboard fucntion
# It can filter by dates, and you can search by id

create_leaderboard <- function(
    data,
    person_col,
    metric_col,
    user_id = NULL,
    date_col = NULL,
    start_date = NULL,
    end_date = NULL,
    rank_fun = sum
) {
  
  
  
  if (!is.null(date_col)) {
    
    # Takes min and max if no date in-putted
    if (is.null(start_date)) {
      start_date <- min(data[[date_col]], na.rm = TRUE)
    }
    if (is.null(end_date)) {
      end_date <- max(data[[date_col]], na.rm = TRUE)
    }
    
    
    data <- data %>%
      filter(
        .data[[date_col]] >= start_date,
        .data[[date_col]] <= end_date
      )
    
  }
  
  leaderboard <- data %>%
    group_by(.data[[person_col]]) %>%
    summarise(
      value = rank_fun(.data[[metric_col]], na.rm = TRUE),
      .groups = "drop"
    ) %>%
    arrange(desc(value)) %>%
    mutate(rank = row_number())
  
  if (!is.null(user_id)) {
    
    leaderboard <- leaderboard %>%
      mutate(
        selected_user =
          .data[[person_col]] == user_id
      )
    
  }
  
  leaderboard
  
}