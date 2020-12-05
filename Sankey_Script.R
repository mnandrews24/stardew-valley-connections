# Import libraries
#install.packages("tidyverse")
#install.packages("plotly")
library(tidyverse)
library(plotly)

# Import data from CSV - will split nodes and links out in the app
myData <- read.csv("./Sankey_Data.csv")
head(myData)

# Add value column - for plotting
myData$value <- 1
head(myData)

# Add Color column
myData$color <- "pink"
head(myData)

# Define color scheme
myData <- within(myData, color[category == "Animal Product"] <- "#91D6E3")
myData <- within(myData, color[category == "Artifact"] <- "#F58469")
myData <- within(myData, color[category == "Artisan Good"] <- "#A94564")
myData <- within(myData, color[category == "Crop"] <- "#79C47C")
myData <- within(myData, color[category == "Dish"] <- "#F4E57E")
myData <- within(myData, color[category == "Fish"] <- "#51ACB7")
myData <- within(myData, color[category == "Foraged"] <- "#9982BC")
myData <- within(myData, color[category == "Mineral"] <- "#EA96C0")
myData <- within(myData, color[category == "Refined Good"] <- "#C9AC9D")
myData <- within(myData, color[category == "Resource"] <- "#C5E3C0")

head(myData)

# Export to RDS file for use in R Shiny
saveRDS(myData, file = "Folder where app.r is stored/sankey.rds") ## UPDATE THIS
