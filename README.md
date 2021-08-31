# Introduction
Housing insecurity is a looming crisis in the U.S. Nearly 5 million Americans lose their homes through eviction and foreclosure. Volunteers will derive insights, create visualizations, and recommend action for Florida counties.

Please read the full [project brief](https://docs.google.com/document/d/1ovSvMK39wO6NXqCrH0chQL7aRHR6Lr0vQIzXhmUEBFk/edit#) for more information.

# Key Questions for the DataDive Event
1. What is... 

# Datasets with Suggested Uses
This section gives a very brief overview of the files in the [data](https://drive.google.com/drive/u/1/folders/19B0xzeRyozYJDxwXKlGIPFe3Qnc3nfux) folder on Google Drive.

### data_dictionary.csv
Use this file to find 'human-readable' names for the ACS variables in the Hillsborough County and NYC files below. There are over 1,000 variables in the American Community Survey datasets, but half correspond to count estimates (these end in just 'E', e.g., `DP02_002E`) and half correspond to percentage estimates (these end in 'PE', e.g., `DP02_002PE`). In other words, `DP02_002E` and `DP02_002PE` represent the same information, only in different formats. Hence, depending on whether or not you choose to work with counts or rates in your analysis, it may only be necessary to work with half of these variables.

For more precise definitions of the concepts described in the data dictionary, please see this very thorough documentation provided by the Census Bureau: https://www2.census.gov/programs-surveys/acs/tech_docs/subject_definitions/2019_ACSSubjectDefinitions.pdf

### TEMP_acs.csv
Use this file to generate tract-level summaries of demographic and socioeconomic variables for Florida.
