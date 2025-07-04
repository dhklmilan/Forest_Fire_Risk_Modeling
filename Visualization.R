# This script is licensed under the MIT License.
# Copyright © 2024 (Dhakal, Milan)

#===========================ROC PLOT=====================================================================================

# Step 1: Predict probabilities
pred_prob <- predict(final_rf_model, test_data, type = "prob")[, "1"]    # confusion on rf_model and final_rf_model to put here

# Step 2: Generate ROC curve object
roc_curve <- roc(test_data$fire, pred_prob, levels = c(0, 1), direction = "<")

# Step 3: Prepare data frame for plotting
roc_data <- data.frame(
  fpr = rev(1 - roc_curve$specificities),  # False Positive Rate
  tpr = rev(roc_curve$sensitivities)       # True Positive Rate
)

# Step 4: Extract AUC value
auc_value <- auc(roc_curve)
auc_value

# Step 5: Plot ROC Curve in your preferred format
roc_plot <- ggplot(roc_data, aes(x = fpr, y = tpr)) +
  geom_line(color = "blue", size = 1) +  # ROC curve line
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", color = "red") +  # Reference line
  labs(title = "", x = "False Positive Rate (FPR)", y = "True Positive Rate (TPR)") +
  theme_minimal(base_size = 14) +
  theme(panel.border = element_rect(color = "black", fill = NA, size = 1),
        axis.line = element_line(color = "black"),
        axis.text = element_text(color = "black"),
        axis.title = element_text(color = "black", size = 12, face = "bold")) +
  scale_x_continuous(expand = c(0, 0), limits = c(0, 1)) +
  scale_y_continuous(expand = c(0, 0), limits = c(0, 1.05)) +
  geom_label(aes(x = 0.85, y = 0.1, label = paste("AUC =", round(auc_value, 2))), 
             fill = "white", color = "black", label.size = 0.5, size = 5)

print(roc_plot)

#ggsave("ROC_Curve.jpg", plot = roc_plot, width = 8, height = 6, dpi = 500, units = "in")
#============================================VARIABLE IMPORTANCE==========================================================

# Explore variable importancey
imp <- varImp(final_rf_model)


# Convert to data frame and normalize to 100
imp_df <- data.frame(Variable = rownames(imp),
                     Importance = imp[, 1])
imp_df$Normalized <- (imp_df$Importance / sum(imp_df$Importance)) * 100

# Sort by importance
imp_df <- imp_df[order(imp_df$Normalized, decreasing = TRUE), ]
imp_df
var_labels <- c(
  "aspect" = "Aspect",
  "Red" = "Land Use / Land Cover",
  "clipmap" = "Distance to Road",
  "clipst" = "Proximity to Settlement",
  "LST_Day_1km" = "Temperature",
  "Rasuwa_elevation_old" = "Elevation",
  "Rasuwa_TWI" = "TWI (Topographic Wetness Index)",
  "slope" = "Slope",
  "NDVI" = "NDVI",
  "Wind.Speed" = "Wind Speed"
)
# Replace variable names using the mapping
imp_df$Label <- var_labels[imp_df$Variable]


vimp <- ggplot(imp_df, aes(x = reorder(Label, Normalized), y = Normalized)) +
  geom_bar(stat = "identity", fill = "steelblue", color = "black", size = 0.5) +  # Black border around bars
  coord_flip() +  # Horizontal bars
  theme_minimal(base_size = 14) +  # Minimal theme
  labs(x = "Predictor", y = "Importance (%)") +  # Naming the x and y axes
  theme(
    axis.title = element_text(face = "bold", size = 14),  # Make axis titles bold
    axis.text = element_text(color = "black", size = 12),  # Axis text styling
    panel.border = element_rect(color = "black", fill = NA, size = 1),  # Box around plot area
    panel.grid = element_blank(),  # Remove all grid lines
    plot.margin = unit(c(0, 0, 0, 0), "cm")  # Correct margin usage with unit()
  )

vimp
#ggsave("Variable_importance_hyper.jpg", plot = vimp, width = 12 , height = 6, dpi = 500, units = "in")


#==============================partial dependency curve=================================================================
library(pdp)
library(ggplot2)
library(dplyr)

# Select predictor variable names (excluding "Red" - Land Cover)
predictor_vars <- setdiff(colnames(train_data), c("fire", "Red"))

# Create a list to store partial dependence results
pd_list <- list()

# Loop through each predictor and calculate partial dependence
for (var in predictor_vars) {
  pd <- partial(final_rf_model, 
                pred.var = var, 
                train = train_data, 
                type = "classification",
                which.class = "1",  # Focus on fire probability
                prob = TRUE,
                grid.resolution = 50)
  
  # Convert to dataframe and add variable name
  pd_df <- as.data.frame(pd)
  colnames(pd_df) <- c("Variable_Value", "Predicted_Probability")
  pd_df$Variable <- var_labels[var]  # Apply renaming
  
  # Store in list
  pd_list[[var]] <- pd_df
}

# Combine all partial dependence results
pd_combined <- bind_rows(pd_list)
pd_combined

# Create faceted plot with outer box and centered plots
ggplot(pd_combined, aes(x = Variable_Value, y = Predicted_Probability)) +
  geom_line(size = 1, color = "purple") +
  geom_smooth(method = "loess", linetype = "dashed", color = "black", se = FALSE) +  # Optional smoothing
  facet_wrap(~ Variable, scales = "free_x") +
  labs(x = "Variable Values", y = "Probability") + #title = "Partial Dependence Plots") +
  theme_minimal() +
  theme(
    legend.position = "none",  # Remove legend
    panel.border = element_rect(color = "black", fill = NA, size = 1.2),  # Add outer box
    axis.title.x = element_text(size = 14, face = "bold"),
    axis.title.y = element_text(size = 14, face = "bold"),
    strip.text = element_text(size = 12, face = "bold"),  # Improve facet labels
    plot.margin = unit(c(10, 10, 10, 10), "pt"),  # Corrected margin format
    panel.spacing = unit(1, "lines")  # Add spacing between facets for centering effect
  )

#ggsave("Partial_Dependence_Plots.jpg", width = 12, height = 10, dpi = 500, units = "in")



#======================================== FINAL RISK MAP WITHLAYOUT =======================================================
#========================================                           ======================================================

# Predict Fire Risk Across the Study Area
fire_risk_map <- terra::predict(predict, final_rf_model, type = "prob", index = 2)

plot(fire_risk_map)

forest <- ("D:\\Rasuwa_Ensemble\\shape\\4_10_11.shp")
rforest <- st_read(forest)
# Convert sf to SpatVector
forest_vec <- terra::vect(forest)
# Convert RasterLayer to SpatRaster
fire_risk_spat <- rast(fire_risk_map)
fire_risk_clipped <- terra::mask(fire_risk_spat, forest_vec)

plot(fire_risk_clipped)



# Save the raster as a GeoTIFF file
terra::writeRaster(fire_risk_clipped, filename = "risk_map_rf.tif", overwrite = TRUE)


# Define breakpoints manually
breaks <- c(0, 0.243137, 0.396078, 0.556863, 0.741176, 1)

# Create a reclassification matrix
reclass_matrix <- cbind(breaks[-length(breaks)], breaks[-1], 1:5)

# Perform raster reclassification
fire_risk_classified <- classify(fire_risk_clipped, reclass_matrix)

# Convert raster to data frame for plotting
fire_risk_df <- as.data.frame(fire_risk_classified, xy = TRUE)
colnames(fire_risk_df) <- c("x", "y", "risk_class")

# Convert risk_class to a factor
fire_risk_df$risk_class <- factor(fire_risk_df$risk_class, 
                                  levels = 5:1, 
                                  labels = c("Very High", "High", "Moderate", "Low", "Very Low"))


# Remove NA values
fire_risk_df <- fire_risk_df[!is.na(fire_risk_df$risk_class), ]

# Define colors
risk_colors <- c("red", "orange", "yellow", "lightgreen", "darkgreen")
map_plot <- ggplot() +
  geom_sf(data = rasuwashp, fill = "white", color = "black") +  # District boundary
  geom_raster(data = fire_risk_df, aes(x = x, y = y, fill = risk_class)) +
  
  scale_fill_manual(values = risk_colors, name = "Fire Risk Level", na.value = "transparent") +
  
  # Add title with white background
  geom_label(aes(x = mean(range(fire_risk_df$x)), 
                 y = max(fire_risk_df$y) + 0.09,  
                 label = "Forest Fire Risk Map of Rasuwa District"), 
             size = 7, fontface = "bold", fill = "white", label.size = NA) +
  
  theme_minimal() +
  theme(
    panel.grid.major = element_line(color = scales::alpha("lightgray", 0.3)),
    panel.background = element_rect(fill = "white"),
    legend.position = c(0.88, 0.15),  # Legend inside the map
    legend.title = element_text(face = "bold", size = 14),
    legend.text = element_text(size = 12),
    legend.background = element_rect(fill = "white", color = NA),  # White background, NO border
    axis.title = element_blank()
  ) +  
  
  # Add scale bar and north arrow
  annotation_scale(location = "bl", width_hint = 0.2) +
  annotation_north_arrow(location = "tr", which_north = "true",
                         pad_x = unit(0.2, "in"), pad_y = unit(0.2, "in"),
                         style = north_arrow_fancy_orienteering)

# Print the map only once
print(map_plot)

# Save the plot
#ggsave("rasuwa_fire_risk_map2.jpg", plot = map_plot, width = 10, height = 8, units = "in", dpi = 1000)

