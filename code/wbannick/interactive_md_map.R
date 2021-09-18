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
# III. Fixing Summary Stats
# -----------------------------------------------


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
    # let's round all percents to be more readable. I think 2 decimals should be good,
    # BUT this can be altered
    across(matches("pct-"), round, 2),
    # decided to this for avg too
    across(matches("avg-"), round, 2),
  ) %>%
  # a quick rename to shift perspectives :)
  rename("pct-poc" = "pct-non-white")

# -----------------------------------------------
# IV. Appending Summary Statistics to Map
# -----------------------------------------------
# This excerpt has two purposes: 
## A) Sepcifying which data we want to actually showcase in the map
## B) Renaming variables to readable labels to be displayed in the map
#### these new names will be ugly for programmers but pretty for visualizations

# Per the task description we want to highlight:
## evictions/foreclosures/overall housing loss
md_mapping_sums <- md_sums %>%
  transmute(
    `Census Tract` = as.character(`census_tract_GEOID`), # for join
    state, county, county_GEOID, # always good to keep in case w bind rows
    `Number of Households` = `total-households`,
    # think this will be the first layer at least
    `Housing Loss Index` = `housing-loss-index`,
    # '' per year (2017-2019)
    `Evictions Per Year` = `avg-evictions`,
    `Mortgage Foreclosures Per Year` = `avg-foreclosure-sales`,
    `Tax Lien Foreclosures Per Year` = `avg-lien-foreclosures`,
    # rates
    `Eviction Rate` = `avg-eviction-rate`,
    `Mortgage Foreclosure Rate` = `avg-foreclosure-rate`,
    `Tax Lien Foreclosure Rate` = `avg-lien-foreclosure-rate`,
    # race
  )

# the actual join
md_sf <- left_join(md_sf, md_mapping_sums) %>%
  # dropping those with zero households
  filter(`Number of Households` != 0)

# let's make sure we're good..
table(is.na(md_sf$`Number of Households`))
table(is.na(md_sf$`Housing Loss Index`))
table(is.na(md_mapping_sums$`Housing Loss Index`))

# -----------------------------------------------
# V. Producing the Actual Map
# -----------------------------------------------


house_loss_map <- 
  tmap::tm_shape(md_sf, name = "Housing Loss Miami-Dade County (2017-2019)") + 
  tm_polygons(
    "Housing Loss Index",
    id = "Census Tract",
    palette = "-magma",
    popup.vars = 
      c(
        "Housing Loss Index",
        "Number of Households",
        "Evictions Per Year",
        "Mortgage Foreclosure Rate",
        "Tax Lien Foreclosure Rate"
      ),
    #breaks = c()
  )

tmap_save(house_loss_map, filename = "outputs/wbannick/miami-dade_housing_loss_map.html")
