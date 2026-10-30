#' Calculate the percentage change 
#' 
#' Calculate the percentage change between two values
#' Returns NA if:
#'   - either value is missing
#'   - either value is not a valid number
#'   - the previous value is zero (avoid division of zero)
#'   
#' @param current Numeric. The current value
#' @param previous Numeric. The previous value used as the baseline
#' 
#' @return A numeric percentage change, or NA_real_ if the calculation cannot be performed safely
#' Positive result = increase 
#' Negative result = decrease 
calculate_pct_change <- function(current, previous) {
  
  if (is.na(current) ||
      is.na(previous) ||
      is.nan(current) ||
      is.nan(previous) ||
      previous == 0) {
    
    return(NA_real_)
  }
  
  # Calculate the percentage change:
  # ((new value - old value) / old value) * 100
  ((current - previous) / previous) * 100
  
}