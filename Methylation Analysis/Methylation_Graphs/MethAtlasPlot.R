################################
# LOAD LIBRARIES #
################################

#For data manipulation
library(dplyr) #v1.1.3

#Plots graph
library(ggplot2) #v4.0.3

#Turns y-axis into % scale
library(scales) #v1.4.0

#Reshaping data
library(tidyr) #v1.3.0

#Adds patterns to plots
library(ggpattern) #v1.3.1

#Provides colourblind friendly palette
library(viridis) #v0.6.5

################################
# DATA PREP #
################################

#Reading in all .csvs into data frames
B78_24 <- read.csv("B78_24_build_deconv_output.csv")
B70_24 <- read.csv("B70_24_build_deconv_output.csv")
B123_25_ATHENA <- read.csv("B123_25_ATHENA_build_deconv_output.csv")
B168_24 <- read.csv("B168_24_build_deconv_output.csv")
B358_24 <- read.csv("B358_24_build_deconv_output.csv")
HC_78 <- read.csv("HC_78_build_deconv_output.csv")

#Putting all data frames into a list
df_list <- list(B78_24, B70_24, B123_25_ATHENA, B168_24, B358_24, HC_78)

#Combine all data frames into one data frame based on the shared value of column X
plot_data <- Reduce(function(x, y) left_join(x, y, by = "X"), df_list ) |>
  #Reshape data from wide to long format
  pivot_longer(cols = -X, names_to = "Patient", values_to = "Value") |> 
  #Change column x to more appropriate name
  rename(Tissue = X)

#Ordering tissues by total size and removing any tissues with a total value of 0.00
plot_data <- plot_data |> group_by(Tissue) |>
  #Create new column equal to the total value of each tissue shared by all patients
  mutate(total_val = sum(Value, na.rm = TRUE)) |>
  #Stop grouping tissues
  ungroup() |> 
  #Remove any tissues where their total value is 0
  filter(total_val > 0) |> 
  #Sort tissues by their total value to make graph easier to read
  arrange(desc(total_val)) |>
  #Use this arrangement to create a factor to tell ggplot correct ordering
  mutate(Tissue = factor(Tissue, levels = unique(Tissue)))

#Finding the total number of unique tissues (ignoring tissues with a value of 0)
num_tissues <- length(unique(plot_data$Tissue))

################################
# GRAPH PREP #
################################

#Creating a gradient of colours for the number of available tissues (using colourblind friendly pallette)
assigned_colors <- viridis(num_tissues)

#Loop through ordered tissues and assigning patterns to make the graph easier to read
assigned_patterns <- rep(c("none", "stripe", "stripe", "crosshatch"), length.out = num_tissues)

#Looping through ordered tissues and assigning angles to make the graph easier to read
assigned_angles <- rep(c(0, 45, 135, 45), length.out = num_tissues)

################################
# PLOT GRAPH #
################################

#Plot graph with assigned patterns and angles of patterns
gg_plot <- ggplot(plot_data, aes(x = Patient, y = Value, fill = Tissue, pattern = Tissue, pattern_angle = Tissue)) + 
  geom_bar_pattern(
    position = "fill", stat = "identity", width = 0.65, color = "#ffffff", linewidth = 0.15, 
    pattern_color = "#ffffffaa", pattern_fill = "#ffffffaa", pattern_density = 0.08, pattern_spacing = 0.025
  ) +
  
  #Assigning chosen colours, angles and patterns
  scale_fill_manual(values = assigned_colors) +
  scale_pattern_manual(values = assigned_patterns) +
  scale_pattern_angle_manual(values = assigned_angles) +
  
  #Scale y axis by %
  scale_y_continuous(labels = percent_format()) +
  #Label x and y axis and legend
  labs(x = "Patient", y = "Percentage Composition", fill = "Tissue", pattern = "Tissue", pattern_angle = "Tissue") +
  theme_minimal() +
  theme(
    #Clean up the look of the x-axis labels
    axis.text.x = element_text(angle = 45, hjust = 1, face = "bold"),
    #Remove vertical grid lines
    panel.grid.major.x = element_blank()
  )

################################
# SAVE GRAPH #
################################

#Height, width, and dpi chosen through trial and error
ggsave("MethAtlas_Plot.png", plot = gg_plot, width = 20, height = 14, units = "cm", dpi = 900)
