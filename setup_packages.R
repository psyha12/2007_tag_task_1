project_packages <- c(
  "shiny",
  "shinydashboard",
  "plotly",
  "dplyr",
  "odbc",
  "tidyr",
  "DBI",
  "stringr",
  "scales",
  "reshape2",
  "janitor",
  "DT",
  "gt",
  "openxlsx",
  "tidyverse",
  "skimr",
  "GGally",
  "corrplot",
  "ggplot2",
  "lubridate"
)

missing_packages <- setdiff(
  project_packages,
  rownames(installed.packages())
)

if (length(missing_packages) > 0) {
  install.packages(missing_packages)
}