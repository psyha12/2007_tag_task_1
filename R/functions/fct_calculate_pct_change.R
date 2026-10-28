calculate_pct_change <- function(current, previous) {
  
  if (is.na(current) ||
      is.na(previous) ||
      is.nan(current) ||
      is.nan(previous) ||
      previous == 0) {
    
    return(NA_real_)
  }
  
  ((current - previous) / previous) * 100
  
}