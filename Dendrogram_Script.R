# Install libraries
#install.packages("collapsibleTree")
library(collapsibleTree) 

# Import data from CSV
bundles <- read.csv("./Dendrogram_Data.csv")
head(bundles)

# Save as RDS for R Shiny
saveRDS(bundles, file = "Folder where app.r is stored/bundles.rds") ## UPDATE THIS

# Create Chart
collapsibleTree(bundles, c("Level2", "Level3", "Level4"), collapsed = TRUE,
                zoomable = FALSE, root = "Community Center", fill = "#51ACB7", tooltip = FALSE)