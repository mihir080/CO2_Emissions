# This is a script to analyse CO2 Emissions from Food consumption across coutries

# Checking and installing required packages
packages <- c('readr', 'tidyverse', 'ggplot2', 'ggtext', 'tidytext', 'ggthemes', 'broom', 'knitr', 'plotly', 'sf', "rnaturalearthdata", 'rnaturalearth')
#install all packages that are not already installed
install.packages(setdiff(packages, rownames(installed.packages())))

# Loading all packages as required

for (pkg in packages){
  library(pkg, character.only = TRUE)
}

# Setting the working directory and the working space options
setwd("~/Documents/D Drive/Mihir Docs UMD/Python/CO2_Emissions")
options(scipen = 999) # Using non scientific values for numbers

#Loading the dataset - csv file 
foodconsumption <- read_csv("Dataset_Foodconsumption.csv")
head(foodconsumption) # Verifying the read dataset

# Basic and descriptive statistics 
foodconsumption %>%
  summary() # Checking the summary statsitics of the dataset
  dim(foodconsumption) # Checking the dimensions of the dataset

#Visualizing data to compare and to see descriptive stats
#Using boxplots will allows us to compare the impact of consumption and 
#emissions and see proportions
foodconsumption %>% 
  # Changing the dataset to a long format for plotting
  gather(key = "feature", value = "value", -country, -food_category) %>% 
  # Creating box plots
  ggplot(aes(x = "", y = value, color = feature)) +
  geom_boxplot() +
  facet_wrap(~feature, scales = "fixed") +
  scale_y_log10() + #using log for better comparison
  theme(legend.position = "none") +
  labs(x = NULL, # Remove X Axis labels
       y = "Values (Log)",
       title = "Distribution of CO2 and Consumption")

#The box plots are fairly compareable but are not providing the best 
#representation.
#Adding jitter points to see the spread and positoning of data points
foodconsumption %>% 
  # Changing the dataset to a long format for plotting
  gather(key = "feature", value = "value", -country, -food_category) %>% 
  ggplot(aes(x = "", y = value, color = feature)) + 
  geom_boxplot() +
  geom_jitter(alpha = .1) + # Adding
  facet_wrap(~feature, scales = "fixed") + 
  scale_y_log10() +
  theme(legend.position = "none") +
  labs(x = NULL, # Remove X Axis labels
       y = "Values (Log)",
       title = "Distribution of CO2 Emissions and Consumption")

#Comparing the emissions per unit of food consumption

#Consumption = Kg ate by each person
#CO2 Emission = Kg of CO2 produced by each person
#For every Kg of CO2, how many Kg of food was consumed? 

foodconsumption %>% 
  filter(consumption != 0) %>%  # Removing the values where food consumption is 0
  # Creating a new variable for emission per consumption 
  mutate(emissionperfood = co2_emmission/consumption) %>%
  group_by(food_category) %>% 
  # Checking the average emission per kg consumption grouped by food category
  summarise(avg_emission = mean(emissionperfood)) %>% 
  ggplot(aes(x = reorder(food_category, avg_emission), y = avg_emission, fill = food_category)) +
  geom_col() + #Adding bar charts
  coord_flip() +
  theme_hc() +
  theme(legend.position = "none") +
  labs(x = NULL, # Remove X Axis labels
       y = "Emissions / Kg Consumption",
       title = "CO2 Emissions per Kg Consumption By Food Category")

#Based on this graph, Lamb & Goat and Beef should be avoided

#Comparing the emissions on a country level

# Load world map data
world <- ne_countries(scale = "medium", returnclass = "sf")

#Segregating data for country sepcific values
country_wise <- foodconsumption %>% 
  group_by(country) %>%
  summarise(co2_emmission = sum(co2_emmission)) %>% 
  select(country, co2_emmission) 
names(country_wise) <- c("Country", "Emissions") #Changing coloumns names to merge with World

# Merge emissions data with world map data
world <- merge(world, country_wise, by.x = "admin", by.y = "Country", all.x = TRUE)

# Plot heatmap on world map
ggplot() +
  geom_sf(data = world, aes(fill = Emissions)) +
  scale_fill_gradient(low = "lightblue", high = "darkred", name = "CO2 Emissions") +
  labs(title = "CO2 Emissions by Country") +
  theme_void()

# Using a globe
world_map <- plot_geo(data = country_wise) %>%
  add_trace(
    type = "choropleth",
    locations = ~Country,
    z = ~Emissions,
    colorscale = "Greens",
    locationmode = "country names"
  )

world_map <- layout(world_map, title = "CO2 Emissions Heatmap by Country", showlegend = FALSE)
# Show the plot
world_map


#Top 5 consuming countries of each food category
foodconsumption %>% 
  group_by(food_category) %>% 
  top_n(consumption, n = 5) %>% 
  arrange(food_category, -consumption) %>% 
  select(-consumption, -co2_emmission)

#The top consuming country for each category
top_consumer <- foodconsumption %>% 
  group_by(food_category) %>% 
  top_n(consumption, n = 1) %>% 
  arrange(food_category, -consumption) %>% 
  select(-consumption, -co2_emmission)
table <- kable(top_consumer, format = "markdown", col.names = c("Country", "Food Category"), caption = "Top Consumer Across Food Categories")
print(table)

#Coutries that appear more than once in the top 5 consumers by food category
top5_multi <- foodconsumption %>% 
  group_by(food_category) %>% 
  top_n(consumption, n = 5) %>% 
  arrange(food_category, -consumption) %>% 
  ungroup() %>% 
  count(country, sort = TRUE) %>% 
  filter(n != 1)
table2 <- kable(top5_multi, format = "markdown", col.names = c("Country", "Number Of Appearances"), caption = "Countries With More Than 1 Appearance In Top 5")
print(table2)

#Comparing the consumption by food type - 2 primary categories (vegan vs non-vegan)
vegan_food <- foodconsumption %>% 
  #Classifying the food categories into vegan and non-vegan
  mutate(vegan = if_else(food_category %in% c("Wheat and Wheat Products", "Rice", "Soybeans", "Nuts inc. Peanut Butter"), "Non-Animal Product", "Animal Product")) %>%
  group_by(country) %>% 
  top_n(consumption, n = 1) %>% 
  group_by(food_category) %>% 
  count(vegan, sort = TRUE) %>% 
  select(-n)
table3 <- kable(vegan_food, format = "markdown", col.names = c("Food Category", "Vegan/Non-Vegan"), caption = "Top Food Categories By Consumption")
print(table3)

#Comparing the emissions by food type - 2 primary categories (vegan vs non-vegan)
vegan_food_em <- foodconsumption %>% 
  #Classifying the food categories into vegan and non-vegan
  mutate(vegan = if_else(food_category %in% c("Wheat and Wheat Products", "Rice", "Soybeans", "Nuts inc. Peanut Butter"), "Non-Animal Product", "Animal Product")) %>%
  group_by(country) %>% 
  top_n(co2_emmission, n = 1) %>% 
  group_by(food_category) %>% 
  count(vegan, sort = TRUE) %>% 
  select(-n)
table4 <- kable(vegan_food_em, format = "markdown", col.names = c("Food Category", "Vegan/Non-Vegan"), caption = "Top Food Categories By Emission")
print(table4)

#Graphically comparing the consumptions and emissions by vegan vs non-vegan
foodconsumption %>% 
  mutate(vegan = if_else(food_category %in% c("Wheat and Wheat Products", "Rice", "Soybeans", "Nuts inc. Peanut Butter"), "Non-Animal Product", "Animal Product")) %>%
  gather(key = "feature", value = "value", -country, -food_category, -vegan) %>% 
  select(-country) %>% 
  ggplot(aes(x = value, fill = vegan)) + 
  geom_density(alpha = .3) + 
  scale_x_log10() + 
  facet_wrap(~feature, scale = "free", nrow = 2) +
  labs(x = NULL, # Remove X Axis labels
       y = NULL,
       title = "Food Consumption and CO2 Emission (Animal and Non-Animal Products)")
