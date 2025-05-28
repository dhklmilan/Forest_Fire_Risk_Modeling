# This script is licensed under the MIT License.
# Copyright © 2024 (Dhakal, Milan)

# Set the working directory
setwd("D:/Rasuwa_Ensemble\\results_hyperpara")

# necessary layers of the study
slope <- raster::raster("D:\\Rasuwa_Ensemble\\layers\\Slope_DEM.tif")
# Convert RasterLayer to SpatRaster
slope_spat <- terra::rast(slope)


aspect <- raster::raster("D:\\Rasuwa_Ensemble\\layers\\Rasuwa_Aspect.tif")
# Convert RasterLayer to SpatRaster
aspect_spat <- terra::rast(aspect)


elevation <- raster::raster("D:\\Rasuwa_Ensemble\\layers\\Rasuwa_elevation_old.tif")
# Convert RasterLayer to SpatRaster
elevation_spat <- terra::rast(elevation)


twi <- raster::raster("D:\\Rasuwa_Ensemble\\layers\\Rasuwa_TWI.tif")
# Convert RasterLayer to SpatRaster
twi_spat <- terra::rast(twi)

set <- raster::raster("D:\\Rasuwa_Ensemble\\layers\\Rasuwa_SET.tif")
# Convert RasterLayer to SpatRaster
set_spat <- terra::rast(set)

road <- raster::raster("D:\\Rasuwa_Ensemble\\layers\\Rasuwa_ROAD.tif")
# Convert RasterLayer to SpatRaster
road_spat <- terra::rast(road)

wind <- raster::raster("D:\\Rasuwa_Ensemble\\layers\\Rasuwa_WIND.tif")
# Convert RasterLayer to SpatRaster
wind_spat <- terra::rast(wind)

ndvi <- raster::raster("D:\\Rasuwa_Ensemble\\layers\\Rasuwa_NDVI.tif")
# Convert RasterLayer to SpatRaster
ndvi_spat <- terra::rast(ndvi)


pre <- raster::raster("D:\\Rasuwa_Ensemble\\layers\\Rasuwa_PRE.tif")
# Convert RasterLayer to SpatRaster
pre_spat <- terra::rast(pre)

lulc <- raster::raster("D:\\Rasuwa_Ensemble\\layers\\Rasuwa_LULC.tif")
# Convert RasterLayer to SpatRaster
lulc_spat <- terra::rast(lulc)
# View categories
cats(lulc_spat)

lst <- raster::raster("D:\\Rasuwa_Ensemble\\layers\\Day_Temperature2.tif")
#Convert RasterLayer to SpatRaster (Day_Temperature2 is 24 years datasets)
lst_spat <- terra::rast(lst)

# List of raster variables
raster_list <- list(ndvi_spat, wind_spat, twi_spat, elevation_spat, aspect_spat, set_spat,
                    road_spat, pre_spat, lst_spat, lulc_spat)

# Apply project, resample, and crop to each raster
raster_list <- lapply(raster_list, function(r) crop(resample(project(r, crs(slope_spat)), slope_spat), slope_spat))



# list of raster
raster_list <- list(ndvi_spat, wind_spat, twi_spat, elevation_spat, aspect_spat, set_spat,
                    road_spat, pre_spat, lst_spat, lulc_spat, slope_spat)

# Use the first raster(slope), only for reference
ref_raster <- slope_spat

#  projection, resample and extent matching using single function in single code
raster_list <- lapply(raster_list, function(r) crop(resample(project(r, crs(ref_raster)), ref_raster), ref_raster))

# Assign names back
names(raster_list) <- c("ndvi_spat", "wind_spat", "twi_spat", "elevation_spat", "aspect_spat", 
                        "set_spat", "road_spat", "pre_spat", "lst_spat", "lulc_spat", "slope_spat")

list2env(raster_list, envir = .GlobalEnv)


#========================makinf predictors containner and change into raster==========================
# stack all the independent variables and names as predictors
predictors <- c(
  ndvi_spat,
  wind_spat,
  twi_spat,
  elevation_spat,
  slope_spat,     
  aspect_spat,   
  set_spat,
  road_spat,
  pre_spat,
  lst_spat,
  lulc_spat
)



# try this once to extract values and make dataframe,fire_values <- values(predict, na.rm = TRUE)

# change it to raster stack
predict_rast <- raster::stack(predictors)
res(predictors)
summary(predictors)

#====================================load shape file and fire incidents ==============================
# study area
aoi <- ("D:\\Rasuwa_Ensemble\\aoi\\rasuwa.shp")
rasuwa <- st_read(aoi)
rasuwashp <- st_transform(rasuwa, crs = 4326)


# Load the fire Shapefile
shapefile_path <- "D:\\Rasuwa_Ensemble\\Rasuwa fire points\\h_and_l_clip_to_4_10_11.shp"
firetrain <- st_read(shapefile_path)
firetrain <- st_transform(firetrain, crs = 4326)

# Display the first few rows to confirm it loaded correctly
head(firetrain)
summary(firetrain)
print(nrow(firetrain)) 


#========================= this method for spatial thining of fire occurances point==============================
#  Extract coordinates
fire_df <- data.frame(
  LONGITUDE = st_coordinates(firetrain)[, 1],
  LATITUDE = st_coordinates(firetrain)[, 2]
)

# Convert to sf object..code is okay this code is useful when points is in xls/csv file
fire_sf <- st_as_sf(fire_df, coords = c("LONGITUDE", "LATITUDE"), crs = 4326)

# Spatial Thinning (Minimum Distance Filtering)
coordinates <- st_coordinates(fire_sf)  # Extract coordinates
dist_matrix <- distm(coordinates, fun = distGeo)  # Compute distance matrix

min_dist <- 100  # Minimum distance in meters
selected_indices <- c()
remaining_indices <- 1:nrow(fire_df)

while (length(remaining_indices) > 0) {
  selected_indices <- c(selected_indices, remaining_indices[1])
  remaining_indices <- remaining_indices[-1]
  
  # Remove points within the minimum distance
  to_remove <- which(dist_matrix[selected_indices[length(selected_indices)], remaining_indices] < min_dist)
  if (length(to_remove) > 0) {
    remaining_indices <- remaining_indices[-to_remove]
  }
}

thinned_fire_sf <- fire_sf[selected_indices, ]

#  Add the 'label' column for training (set to 1)
thinned_fire_sf$label <- 1
print(thinned_fire_sf)

#  Select only required columns: LATITUDE, LONGITUDE, and label
final_fire_df <- data.frame(
  LATITUDE = st_coordinates(thinned_fire_sf)[, 2],
  LONGITUDE = st_coordinates(thinned_fire_sf)[, 1],
  label = thinned_fire_sf$label
)
fire <- final_fire_df[, c("LATITUDE", "LONGITUDE", "label")]

# no need to transform fire in this section, as it's already in the correct CRS.
print(fire)


# Convert 'fire' to an sf object, the fire above  is in dataframe
fire_sf <- st_as_sf(fire, coords = c("LONGITUDE", "LATITUDE"), crs = 4326)

print(fire_sf)

#===================================spatial thining process ends here================================

# ================================== Multicollinearity Assessment ==================================
# perform multicollinearity test, majorly two approach; fist one is by extracting multivalues to point of dependent variables,
# and second one is by stacking independent variables.

# Multicollinearity Assessment
ext <- terra::extract(predictors, firetrain) 
ext <- ext[, -1]  # Remove ID column, there exists

# Check VIF
vif <- vifstep(ext, th = 10)
print(vif)

selected_vars <- vif@results$Variables
print(selected_vars)

#===============================(final predictor) Filter raster stack based on selected variables========
predict <- subset(predictors, selected_vars)
predict <- raster::stack(predict)
predict


# Convert RasterStack (raster package) to SpatRaster (terra package)
predict_terra <- rast(predict)  

# Now extract the values
predictor_values <- terra::extract(predict_terra, vect(combined_points))
res(predict)
summary(predict)

# =========================================================================================================


library(corrplot)
# Compute correlation matrix
cor_matrix <- cor(ext, use = "complete.obs")

# Print correlation matrix
print(cor_matrix)
# Plot correlation matrix
corrplot(cor_matrix, method = "color", type = "upper", tl.cex = 0.8, tl.col = "black")


#=================================process for asigning non fire points===========================
# before processing, confirm if there is fire points having 'fire' column with value 1

# Generate random non-fire points within the study area
set.seed(123)  # For reproducibility
non_fire <- nrow(thinned_fire_sf)  # same number as fire points
non_fire


# Random non-fire incidents points within the study area
random_points <- st_sample(rasuwashp, size = non_fire, type = "random")
#mapview(random_points)

#random_points <- st_sample(rasuwashp, size = 1000, type = "random")


# Convert to sf object and assign non-fire class
non_fire <- st_sf(geometry = random_points, label = 0)


# Ensure non-fire points do not overlap with fire points
non_fire <- non_fire[!st_intersects(non_fire, fire_sf, sparse = FALSE), ]

st_crs(non_fire)
non_fire

# Identify empty geometries
empty_geometries <- st_is_empty(non_fire)

# Filter out the empty geometries
non_fire_filtered <- non_fire[!empty_geometries, ]

# Check the filtered object
print(non_fire_filtered)

# Combine fire and non-fire datasets
combined_points <- bind_rows(fire_sf, non_fire_filtered)
print(combined_points)

# ==============================making datasets ======================================================
# Raster Values extarction at Fire/Non-Fire Points
# extract the values
predictor_values <- terra::extract(predict_terra, vect(combined_points))

# Dataset with Fire Labels (predictor values bhaneko only data nikaleko, dataset bhaneko fire/non fire combined gareko)
dataset <- cbind(data.frame(predictor_values), fire = combined_points$label)
View(dataset)

dataset <- na.omit(dataset)  # Remove NAs
dataset <- dataset[, -1]  # Remove ID column, its going to another level and hamper in modeling


# ==============================Train-Test Split=======================================================
set.seed(123)
train_index <- sample(1:nrow(dataset), size = 0.8 * nrow(dataset))
train_data <- dataset[train_index, ]
test_data  <- dataset[-train_index, ]
print(train_data)
View(train_data)
# Ensure fire column is a factor
train_data$fire <- as.factor(train_data$fire)

test_data$fire <- as.factor(test_data$fire)

#  why fire coumn as a factor? if not:
#  confusionMatrix(predictions, test_data$fire)
#  Error: `data` and `reference` should be factors with the same levels.
