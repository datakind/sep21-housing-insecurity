library(httr)
library(jsonlite)
library(dplyr)
library(readr)

years <- c("2014", "2019")
data_profiles <- c("DP02", "DP03", "DP04", "DP05")

master_df <- data.frame()
for(i in seq_along(years)){
  for(j in seq_along(data_profiles)){
    url <- paste0("https://api.census.gov/data/", years[i], "/acs/acs5/profile/groups/", data_profiles[j], ".json")
    print(url)
    
    temp <- httr::content(httr::GET(url = url))
    temp <- do.call(rbind.data.frame, temp$variables)
    temp <- tibble::rownames_to_column(temp, "variable_code")
    temp$acs_year <- years[i]
    
    master_df <- rbind(master_df, temp)
  }
}

readr::write_csv(master_df, "acs5_variable_dict_2014_2019.csv", na = "")
