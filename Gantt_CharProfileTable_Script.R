# Import libraries
#install.packages("tidyverse")
library(tidyverse)

# Import data from CSV
myData2 <- read.csv("./Gantt_CharProfileTable_Data.csv")
head(myData2)

# Change column names fro whole dataset
cols2 <- c("Character", "Portrait", "Birthday", "BestFriend")
colnames(myData2) <- cols2
head(myData2)

# Separate out the character picture
pic <- subset(myData2, select = c(Character, Portrait))
pic

# Separate out the character info
info <- subset(myData2, select = c(Character, Birthday, BestFriend))
cols <- c("Character", "Birthday", "Best Friend")
colnames(info) <- cols
info

# Save both dataframes as RDS for use in Shiny
saveRDS(pic, file = "Folder where app.r is stored/charPic.rds")   ## UPDATE THIS
saveRDS(info, file = "Folder where app.r is stored/charInfo.rds") ## UPDATE THIS
