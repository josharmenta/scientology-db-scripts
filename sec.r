library(rvest)
library(dplyr)
library(purrr)
library(httr)
library(edgar)

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

data <- subset(tables, select=1)
print(data)


# Create an empty data frame with two columns
split_names_df <- data.frame(column1 = character(0), column2 = character(0))

# Loop through each name in your single-column table
# Loop through each name in your single-column table
for (name in data$Name) {
  words <- unlist(strsplit(name, " "))  # Split the name into words

  if (length(words) == 1) {
    split_names_df <- rbind(split_names_df, data.frame(column1 = words, column2 = ""))
  } else if (length(words) == 2) {
    split_names_df <- rbind(split_names_df, data.frame(column1 = words[1], column2 = words[2]))
  } else {
    split_names_df <- rbind(split_names_df, data.frame(column1 = words[1:2], column2 = paste(words[3:length(words)], collapse = " ")))
  }
}

# Reset row names of the new data frame
rownames(split_names_df) <- NULL

# View the resulting data frame
print(split_names_df)

# Define year constant
# (EDGAR starts at 2023)
years_vector <- seq(1990, 2023)

for (i in 1:nrow(split_names_df)) {
  a <- split_names_df$column1[i]
  b <- split_names_df$column2[i]

# Query parameters
	query_params <- list(forename = a, name = b)

	print(query_params)

# Query EDGAR
  edgar_output <- searchFilings(cik.no = all,
  form.type = all,
  filing.year = years_vector, query_params)
  print(edgar_output)

}
