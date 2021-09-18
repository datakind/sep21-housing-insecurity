#Maps of ACS variables Miami-Dade

#libraries
library(dplyr)
library(sf)
library(sp)
library(readr)
library(leaflet)

#setwd('/DataDive_Housing')

#load data---------------------------------------------------------------------
ACS <- readr::read_csv(
  file = 'data/miami_dade_fl_processed_2017_to_2019_20210916.csv')
geos <- sf::st_read('data/miami_dade_fl_2010_tracts_formatted.geojson')
geos_ACS <- merge(geos,ACS)


#clean data--------------------------------------------------------------------
geos_ACS = geos_ACS[geos_ACS$`total-households` > 0,]

#pct below poverty line is blank so remove
geos_ACS = geos_ACS[, !(names(geos_ACS) %in% c("pct-below-poverty-level"))]

demog_total <- geos_ACS$`pct-white`+geos_ACS$`pct-af-am`+geos_ACS$`pct-hispanic`+
  geos_ACS$`pct-am-indian`+geos_ACS$`pct-asian`+geos_ACS$`pct-nh-pi`+
  geos_ACS$`pct-multiple`+geos_ACS$`pct-other`

geos_ACS$`pct-white` <- (geos_ACS$`pct-white`/demog_total)*100
geos_ACS$`pct-af-am` <- (geos_ACS$`pct-af-am`/demog_total)*100
geos_ACS$`pct-hispanic` <- (geos_ACS$`pct-hispanic`/demog_total)*100
geos_ACS$`pct-am-indian` <- (geos_ACS$`pct-am-indian`/demog_total)*100
geos_ACS$`pct-asian` <- (geos_ACS$`pct-asian`/demog_total)*100
geos_ACS$`pct-nh-pi` <- (geos_ACS$`pct-nh-pi`/demog_total)*100
geos_ACS$`pct-multiple` <- (geos_ACS$`pct-multiple`/demog_total)*100
geos_ACS$`pct-other` <- (geos_ACS$`pct-other`/demog_total)*100

#make a layer for each column--------------------------------------------------
colNames <- colnames(geos_ACS)

colNames <- colNames[26:69]

map <- geos_ACS$geometry%>% leaflet()%>%
addProviderTiles("CartoDB.Positron")  # Base groups

for (currName in colNames){
  #section
  b <- geos_ACS[c("census_tract_GEOID", "total-households",currName)]
  colnames(b) <- c("census_tract_GEOID", "total-households","curr", "geometry")
  
  b = b[b$curr >= 0,]
  b = na.omit(b)
  
  #make color scale (example- median gross rent)
  qpal <- leaflet::colorBin( #can try with colorQuantile
    palette = "YlGn",
    domain = b$curr, n=7)
  
  #make labels
  labels <- sprintf(
    "<strong>Geo ID: %s</strong>
    <br/>%g total households
    <br/>%g %s",
    b$census_tract_GEOID, b$`total-households`,
    b$curr, currName
  ) %>% lapply(htmltools::HTML)
  
  map <- map %>%
    # Overlay groups
    addPolygons(color = qpal(b$curr) ,
                weight=1,
                smoothFactor=0.5,
                opacity=1.0,
                fillOpacity=0.5,
                group = currName,
                label = labels
    )#%>% #try without legend
    #addLegend("bottomleft", pal = qpal, 
    #          values = b$curr,
    #          title = currName,
    #          opacity = 1,
    #          group = currName
    #)
  
}


map <- map %>%
  addLayersControl(
    baseGroups = colNames, #try with baseGroups
    options = layersControlOptions(collapsed = FALSE)
  )


htmlwidgets::saveWidget(map, file = 'MiamiDade_baseGroups_nolegend_bins.html', selfcontained=TRUE)
