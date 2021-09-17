library(dplyr)
library(readr)
library(sf)
library(mapview)

# Tampa example
hillsborough_spdf <- sf::read_sf("~/repos/DataKind/new-america-housing-loss-tool/outputs/hillsborough/mapping_datasets/hillsborough_fl_2010_tracts_formatted.geojson")
hillsborough <- readr::read_csv("~/repos/DataKind/new-america-housing-loss-tool/outputs/hillsborough/mapping_datasets/hillsborough_fl_processed_2017_to_2019_20210916.csv")

hillsborough_merged <- merge(hillsborough_spdf, hillsborough, by = "census_tract_GEOID")
hillsborough_merged %>% 
  dplyr::select(geometry, `housing-loss-index`) %>% 
  mapview::mapview()

# Miami example
miami_dade_spdf <- sf::read_sf("~/repos/DataKind/new-america-housing-loss-tool/outputs/miami_dade/mapping_datasets/miami_dade_fl_2010_tracts_formatted.geojson")
miami_dade <- readr::read_csv("~/repos/DataKind/new-america-housing-loss-tool/outputs/miami_dade/mapping_datasets/miami_dade_fl_processed_2017_to_2019_20210916.csv")

miami_dade_merged <- merge(miami_dade_spdf, miami_dade, by = "census_tract_GEOID")
miami_dade_merged %>% 
  dplyr::select(geometry, `housing-loss-index`) %>% 
  mapview::mapview()

# Orlando example
orange_spdf <- sf::read_sf("~/repos/DataKind/new-america-housing-loss-tool/outputs/orange/mapping_datasets/orange_fl_2010_tracts_formatted.geojson")
orange <- readr::read_csv("~/repos/DataKind/new-america-housing-loss-tool/outputs/orange/mapping_datasets/orange_fl_processed_2017_to_2019_20210916.csv")

orange_merged <- merge(orange_spdf, orange, by = "census_tract_GEOID")
orange_merged %>% 
  dplyr::select(geometry, `housing-loss-index`) %>% 
  mapview::mapview()
