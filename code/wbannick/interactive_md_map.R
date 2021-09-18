# Interactive Maps - Task 2
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
    `census_tract_GEOID` = as.character(`census_tract_GEOID`), # for join
  ) %>%
  # a quick rename to shift perspectives :)
  rename("pct-poc" = "pct-non-white")

# -----------------------------------------------
# IV. Appending Summary Statistics to Map
# -----------------------------------------------
# This excerpt has two purposes: 
## A) Sepcifying which data we want to actually showcase in the map
## B) Renaming variables to readable labels to be displayed in the map
#### these new names will be ugly for programmers but prettier for visualizations


# Per the task description we want to highlight:
## evictions/foreclosures/overall housing loss
md_mapping_sums <- md_sums %>%
  transmute(
    `census_tract_GEOID`, # for the join
    # I think this makes things slightly more readable in the map
    `Census Tract` = paste0("Census Tract ", `census_tract_GEOID`),
    #always good to keep in case we combine with other counties
    state, county, county_GEOID,
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
    # rounding and adding percent sign so is consistent with other race data 
    # which is formatted in next section
    `Percent People of Color` = round(`pct-poc`) %>% paste0("%"),
    # Income/Rent
    # as char because weird tmap tendency to display as 0 mln
    # probably should add commas for viewers
    `Median Household Income` = `median-household-income` %>% as.character(),
    `Median Gross Rent` = `median-gross-rent`
  ) %>%
  mutate(
    across(is.numeric, round, 2)
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
# V. Appending Racial Breakdowns of Tracts
# -----------------------------------------------
# for better label display, I am grabbing the percentages of two highest racial groups
race_by_tract <- select(md_sums, all_of(
  #only want race columns for this
  c("census_tract_GEOID","pct-white", "pct-af-am", "pct-hispanic", "pct-am-indian",
    "pct-asian", "pct-nh-pi", "pct-multiple", "pct-other"))) %>%
  # pivot to long df so we can group by tract and find largest racial groups more easily
  pivot_longer(cols = -`census_tract_GEOID`, names_to = "race", values_to = "pct") %>%
  # dropping zeros (no need to display)
  filter(pct != 0) %>%
  # grabbing top 2 by each tract
  arrange(census_tract_GEOID, desc(pct)) %>%
  group_by(census_tract_GEOID) %>%
  # for ties, this will grab 3
  top_n(2) %>%
  mutate(
    rank = row_number(),
    # more readable labels
    race = recode(race,
      "pct-af-am" = "Black",
      "pct-am-indian" = "Native American",
      "pct-hispanic" = "Hispanic",
      "pct-multiple" = "Multiple",
      "pct-white" = "White"
    ),
    # too many decimal places would make pop up crowded imo
    pct = round(pct)
  ) %>%
  # back to wide so we can join 1 to 1
  pivot_wider(
    id_cols = "census_tract_GEOID",
    names_from = "rank",
    values_from = c("race", "pct")) %>%
  mutate(
    # this creates a label that will look good in the pop up (I hope)
    `Largest Racial Groups` = ifelse(is.na(race_3),
      paste0(race_1, " (", pct_1, "%), ", race_2, " (", pct_2, "%)"),
      # one has a tie and so a thrid race to display
      paste0(race_1, " (", pct_1, "%), ", race_2, " (", pct_2, "%)", race_3,
             " (", pct_3, "%)")
    )
  )
# joining on race comp
md_sf <- left_join(
  md_sf,
  select(race_by_tract, `census_tract_GEOID`, `Largest Racial Groups`)
  )

# -----------------------------------------------
# VI. Producing the Interactive Map
# -----------------------------------------------
# just to look for breaks...
hist(md_sf$`Housing Loss Index`)
hist(md_sf$`Housing Loss Index`, breaks = c(0, 0.5, 1, 1.5, 2, 4))

# creating the tmap object (will be outputed as interactive html Leaflet)
house_loss_map <- 
  tmap::tm_shape(md_sf, name = "Housing Loss Miami-Dade County (2017-2019)") + 
  tm_polygons(
    "Housing Loss Index",
    id = "Census Tract",
    palette = "-magma",
    popup.vars = 
      # not 100% sure on best order haha
      c(
        "Number of Households",
        "Housing Loss Index",
        "Evictions Per Year",
        # maybe remove these two so a little cleaner
        "Mortgage Foreclosures Per Year",
        "Tax Lien Foreclosures Per Year",
        "Median Household Income",
        # Crucial for helping to determine if people are being targeted/
        # disproportianetly affected
        "Percent People of Color",
        "Largest Racial Groups"
      ),
    # based both on hist and understanding of the var
    breaks = c(0, 0.5, 1, 1.5, 2, 4),
    # so we can see streets/neighborhood identifiers. 
    # (census tracts aren't easily recongnized by most) 
    alpha = 0.67,
  ) +
  # zooms that make sense in this context
  tm_view(
    set.zoom.limits = c(9,15),
    # I actually think 9.5 is a perfect starting zoom but could get it start there
    # It would start at 10 then you'd have to zoom out one. Probs could be fixed.
    #set.zoom.limits = c(9,15)
    #set.view = 9.5
    ) +
  # first with streets, but also one thats just a canvas
  tmap_options(basemaps = c("OpenStreetMap", "Esri.WorldGrayCanvas")) 

tmap_save(house_loss_map, filename = "outputs/wbannick/miami-dade_housing_loss_map.html")

# TODOS: 
## 1) Exeperiment with adding a layer for total evictions. Better coverage. 
# Does it change the picture?
## 2) I think it would be interesting to see what adding a layer with colors for
# what the plurality racial group is for tracts could be illuminating in
# determining if certain groups are being discriminated against. Could also
# categorize tracts as something like Majority Black, Majority Hisp, Majority White,
# Mixed (if no majority or perhaps no 2/3 majority).
## 3) Experiment with adding a layer for income brackets

