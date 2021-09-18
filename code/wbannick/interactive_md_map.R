# TASK 1.2
# Task 2: Using the programming language, library, or software of your choice,
# create interactive maps of housing loss for the census tracts of Miami-Dade County,
# FL. Can you display evictions/foreclosures/overall housing loss aside other
# variables, either directly on the maps or using tooltips or similar functionality?

# -----------------------------------------------
# I. Setup/Functions
# -----------------------------------------------

library(tidyverse) # for general data cleaning/simplified style
library(sf) # for spatial data transformation
library(tmap) # great for interactive maps!

# quick helper fxn for fixing the raw number issue (SEE III.)
calculate_pct <- function(num, denom){
  pct <- (num/denom) * 100
}

# -----------------------------------------------
# II. Loading in the Data
# -----------------------------------------------

# since these are not on git made a path variable
# if you are trying to run this with a different file system,
# you SHOULD only need to adjust this line :)
data_dir_path <- "~/Documents/DataKind/DataDiveSept2021/Data/"

# the spatial data for Miami Dade
md_sf <- sf::read_sf(
  paste0(data_dir_path, "miami_dade_fl_2010_tracts_formatted.geojson"))
# summary stats for the county
md_sums <- read_csv(
  paste0(data_dir_path, "miami_dade_fl_processed_2017_to_2019_20210916.csv"))

# -----------------------------------------------
# III. Appending Summary Statistics to Map
# -----------------------------------------------
# So we want: evictions/foreclosures/overall housing loss

md_sums <- md_sums %>%
  mutate(
    # First, it seems the pct race variables are raw numbers not percentages
    # So let's reformat...
    # so we have the denominator
    n_residents = `pct-white` + `pct-af-am` + `pct-hispanic` + `pct-am-indian` + 
      `pct-asian` + `pct-nh-pi` + `pct-multiple` + `pct-other`,
    # fixing the pcts for race
    across(
      all_of(
        c("pct-white", "pct-af-am", "pct-hispanic", "pct-am-indian",
          "pct-asian", "pct-nh-pi", "pct-multiple", "pct-other")), 
      # using helper function from setup
      calculate_pct, n_residents
      ),
    # this was also wrong but in a different way
    `pct-non-white` = (100 - `pct-white`),
    `pct-renters` = calculate_pct(`total-renter-occupied-households`, `total-households`),
    # let's round all percents to be more readable. I think 2 decimals should be good,
    # BUT this can be altered
    across(matches("pct-"), round, 2),
    
  ) %>%
  # a quick rename to shift perspectives :)
  rename("pct-poc" = "pct-non-white")



