# This script is licensed under the MIT License.
# Copyright © 2024 (Dhakal, Milan)

# import essesntial libraries
library(patchwork)
library(readxl)
library(ggplot2)
library(dplyr)

# check the list
list.files("D:/Rasuwa_Ensemble/Rasuwa fire points")
data <- read_excel("D:/Rasuwa_Ensemble/Rasuwa fire points/h_and_l_clip_to_4_10_11_835.xls")

str(data)
head(data)
data$ACQ_DATE <- as.Date(data$acq_date, format = "%m/%d/%Y")

#vector (likely representing dates) stored in the acq_date column of the data data frame to a proper Date object.
#as.Date(): This is the function that performs the conversion to the Date class. 

colnames(data)[which(colnames(data) == "10/31/2022")] <- "ACQ_DATE"
data$ACQ_DATE <- as.Date(data$ACQ_DATE, format = "%m/%d/%Y")
summary(data$ACQ_DATE)


# Extract month and year from the Date column
data <- data %>%
  mutate(Month = format(ACQ_DATE, "%B"),  # Extract the full month name
         Year = format(ACQ_DATE, "%Y"))  # Extract the year as a string

# Count fire incidents by month
monthly_data <- data %>%
  group_by(Month) %>%
  summarise(Fire_Count = n()) %>%
  arrange(match(Month, month.name))  # Ensure months are in calendar order

monthly_data 
# Calculate total fire incidents for all months
total_fire_incidents <- sum(monthly_data$Fire_Count)
total_fire_incidents
# Filter data for January to April and calculate their total fire incidents
jan_to_apr_fire_incidents <- monthly_data %>%
  filter(Month %in% month.name[1:5]) %>%
  summarise(Fire_Count = sum(Fire_Count)) %>%
  pull(Fire_Count)

# Calculate the percentage of fire incidents from January to April
percentage_jan_to_apr <- (jan_to_apr_fire_incidents / total_fire_incidents) * 100

# Print the result
print(paste("Percentage of fire incidents from January to April:", round(percentage_jan_to_apr, 2), "%"))


# Count fire incidents by year
yearly_data <- data %>%
  group_by(Year) %>%
  summarise(Fire_Count = n())
yearly_data
summary(yearly_data)
sum(yearly_data$Fire_Count)

# Plot fire incidents by month
ggplot(monthly_data, aes(x = Month, y = Fire_Count, fill = Month)) +
  geom_bar(stat = "identity") +
  labs(title = "Fire Incidents by Month", x = "Month", y = "Number of Fires") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_fill_brewer(palette = "Set3")  # Optional: Add a color palette

# Plot fire incidents by year
ggplot(yearly_data, aes(x = Year, y = Fire_Count, fill = Year)) +
  geom_bar(stat = "identity") +
  labs(title = "Fire Incidents by Year", x = "Year", y = "Number of Fires") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_fill_brewer(palette = "Set3")  # Optional: Add a color palette


ggsave("zfire_incidents_plot6.jpeg", plot = combined_plot, width = 32, height = 14, dpi = 300)



