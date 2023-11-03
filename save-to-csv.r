library(rvest)
library(dplyr)
library(purrr)
library(httr)

html_dir <- "./data"

# List all HTML files in the directory
html_files <- list.files(html_dir, pattern = "\\.html$", full.names = TRUE)

length(html_files)
extract_table <- function(file_path) {
  page <- read_html(file_path)
  table <- html_table(page)
  if (length(table) > 0) {
    return(table[[1]])
  } else {
    return(NULL)
  }
}

tables <- map(html_files, extract_table) %>%
  bind_rows()

data <- subset(tables, select = 1)
print(data)

# Output data to a CSV file
write.csv(data, file = "output.csv", row.names = FALSE)
