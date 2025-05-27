# Forest Fire Risk Assessment using Machine Learning and Earth Observation Technique in Himalayan Regions: Insights from Rasuwa District, Nepal

## Study Overview 
This repository contains R scripts and related materials for the research on forest fire risk mapping in Rasuwa District, Nepal, using Random Forest (RF).

## Setup & Installation  
### Prerequisites  
- R Version: `>= 4.4.1
You'll need the following software installed: 
R statistical programming language:
[Download R](https://cran.r-project.org/) 
[Download RStudio](https://posit.co/download/rstudio-desktop/)
- Key R Packages:  
packages <- c("rasterVis", "sf", "usdm", "ggplot2", "dplyr", "terra", "mapview", "raster", "randomForest", "pROC",)

install.packages(packages)

## Repository Structure
- Data preprocessing: This script has used for cleaning, transforming, and preparing external datasets before modeling
- Model training: Contains scripts for training the random forest model with different hyperparameters used in forest fire risk mapping.
- Model validation: Includes scripts and results related to testing the model performance (AUC, and confusion matrix).
- Visualization: Holds scripts and outputs for making maps, graphs, and other visual results of the model.
- fire incidents analysis: This script has data and analysis related to forest fire incidents recorded over the past 13 years in the study area.


## Data Requirements
This research utilizes a combination of topographic, climatic, anthropogenic, and biophysical factors to model forest fire risk in the Rasuwa District, Nepal. After acquiring the raw datasets, data preprocessing steps such as buffering, clipping, and masking were applied using GEE and ArcGIS. These steps are explained in detail in the Methodology section of the research paper.

### **Forest Fire Incidents**

This research used forest fire incident data from the NASA VIIRS (Visible Infrared Imaging Radiometer Suite) active fire product at ~375m spatial resolution. The dataset covers a 13-year period from 2012 to 2024, eliminating low confidence incidents.

> NASA FIRMS (Fire Information for Resource Management System)

Resolution: ~375 meters

Sensor: VIIRS (Suomi NPP / NOAA-20)

Time Period: 2012–2024

Use: Used to analyze the spatial and temporal distribution of fire incidents and to train and test the model.

### **Topographic Datasets**

•	Elevation- SRTM DEM

•	Slope- SRTM DEM

•	Aspect- SRTM DEM

•	Topographic Wetness Index (TWI)- SRTM DEM

### **Climatic Datasets**
•	Temperature [MOD11C3 V6.1](https://lpdaac.usgs.gov/products/mod11c3v061/)

•	Precipitation [(Hijmans et al., 2005)](https://www.worldclim.org/)

  > Hijmans, R. J., Cameron, S. E., Parra, J. L., Jones, P. G., & Jarvis, A. (2005). Very high resolution interpolated climate surfaces for global land areas. International 
  Journal of Climatology, 25(15), 1965–1978. https://doi.org/10.1002/JOC.1276

Wind Speed [Global Wind Atlas](https://globalwindatlas.info/en/)

### **Anthropogenic Datasets**
•	Distance to Roads (OpenStreetMap, 2023)

 > OpenStreetMap, H. (2023). Nepal Roads (OpenStreetMap Export) https://data.humdata.org/dataset/hotosm_npl_roads

•	Distance to Settlements- (OCHA, 2015)

  > OCHA. (2015). Settlements in Nepal | Humanitarian Dataset | HDX. https://data.humdata.org/dataset/settlements-in-nepal

### **Biophysical Datasets**
•	Land Use Land Cover (LULC)- [FRTC, 2024](https://frtc.gov.np/downloadfiles/NLCMS_Report-1734713324.pdf)

•	Normalized Difference Vegetation Index (NDVI) 

  Landsat 8


## Acknowledgment
Dhakal Milan developed this code as part of a research project on forest fire risk mapping in Rasuwa District, Nepal, which was conducted in collaboration with Kunwar. j Sudeep and Parajuli Ashok. For the complete study and results, refer to the published research paper.

