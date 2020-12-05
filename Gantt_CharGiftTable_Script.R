# Import libraries
#install.packages("tidyverse")
library(tidyverse)

# Import data from CSV
charGifts <- read.csv("./Gantt_CharGift_Char_Data.csv")
head(charGifts)

stdGifts <- read.csv("./Gantt_CharGift_Std_Data.csv")
head(stdGifts)

# Change column names
cols <- c("Character", "Best Gifts", "Image")
colnames(charGifts) <- cols
head(charGifts)

cols <- c("Character", "Best Gifts", "Image")
colnames(stdGifts) <- cols
head(stdGifts)

# Save as RDS for use in Shiny
saveRDS(charGifts, file = "Folder where app.r is stored/charDetails.rds")   ## UPDATE THIS
saveRDS(stdGifts, file = "Folder where app.r is stored/charDetailsStd.rds") ## UPDATE THIS
