# Import libraries
#install.packages("vistime")
#install.packages("tidyverse")
#install.packages("lubridate")
library(vistime)
library(tidyverse)
library(lubridate)

# Import data from CSV
myData <- read.csv("./Gantt_Data.csv")
head(myData)

# Format dates correctly for plotting
myData$Start <- mdy_hm(myData$Start)
myData$Start <- format(as.POSIXct(myData$Start), "%Y-%m-%d %H:%M")

myData$End <- mdy_hm(myData$End)
myData$End <- format(as.POSIXct(myData$End), "%Y-%m-%d %H:%M")

head(myData)

# Change 0:00 to 24:00
myData[myData == "2000-01-02 00:00"] <- "2000-01-01 24:00"
myData[myData == "2000-01-01 00:00"] <- "2000-01-01 24:00"
tail(myData)

# Add Color column
myData$Color <- "pink"
head(myData)

# Apply Color Scheme
myData <- within(myData, Color[Location == "Beach"] <- "#F4E57E")
myData <- within(myData, Color[Location == "Cindersap Forest"] <- "#C5E3C0")
myData <- within(myData, Color[Location == "General Store"] <- "#EA96C0")
myData <- within(myData, Color[Location == "Home"] <- "#51ACB8")
myData <- within(myData, Color[Location == "Pelican Town"] <- "#91D6E3")
myData <- within(myData, Color[Location == "Saloon"] <- "#F58469")

head(myData)

# Add empty tooltip column - must be lowercase for vistime to recognize it
myData$tooltip <- ""
head(myData)

# Save data as RDS for Shiny
saveRDS(myData, file = "Folder where app.r is stored/schedules.rds") ## UPDATE THIS

# Create Chart
vistime(data = myData, col.event = "Location", col.start = "Start", col.end = "End", 
        col.group = "Day", col.color = "Color", optimize_y = TRUE, linewidth = 25, 
        title = "Character Schedule")
