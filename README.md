# Forest_Fire_Risk_Modeling

# Project Overview 
This repository contains R scripts and related materials for the research project on forest fire risk mapping in Rasuwa District, Nepal using Random Forest (RF).

## Authors
SJK designed the study, conducted the investigation, curated and analyzed the data, prepared the original draft of the manuscript, and developed the visualizations. 
MD contributed to methodology development, software implementation, and project administration, and was responsible for rewriting, editing, and preparing the final version of the manuscript. 
AP supervised the research work, validated the findings, and contributed to reviewing and editing the manuscript.


## ⚙️ Setup & Installation  
### Prerequisites  
- R Version: `>= 4.4.1
You'll need the following software installed: 
R statistical programming language:
[Download R](https://cran.r-project.org/) 
[Download RStudio](https://posit.co/download/rstudio-desktop/)
- Key R Packages:  
packages <- c("rasterVis", "sf", "usdm", "sdm", "ggplot2", "dplyr", "dismo", "rgee", 
              "terra", "mapview", "shiny", "leaflet", "reticulate", "raster", 
              "rJava", "ggspatial", "randomForest", "caret", "pROC", "geosphere")

install.packages(packages)





## Repository Structure
•	Data preprocessing: This script has used for cleaning, transforming, and preparing external datasets before modeling
•	Model training: Contains scripts for training the machine learning models (like Random Forest or BRT) used in forest fire risk mapping.
•	Model validation: Includes scripts and results related to testing the model performance (AUC, and confusion matrix).
•	Visualization: Holds scripts and outputs for making maps, graphs, and other visual results of the model.
•	fire incidents analysis: This script has data and analysis related to forest fire incidents recorded over the past 13 years in the study area.




## Acknowledgment
Dhakal Milan developed this code as part of a research project on forest fire risk mapping in Rasuwa District, Nepal, which was conducted in collaboration with Kunwar. j Sudeep and Parajuli Ashok. For the complete study and results, refer to the published research paper.


forest fire risk mapping in rasuwa district of Nepal using earh observation and machine learning.
