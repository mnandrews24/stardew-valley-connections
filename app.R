# Import libraries
#install.packages("shiny")
#install.packages("shinyWidgets")
#install.packages("tidyverse")
#install.packages("collapsibleTree")
#install.packages("vistime")
#install.packages("plotly")
#install.packages("DT")

library(shiny)
library(shinyWidgets)
library(tidyverse)
library(collapsibleTree)
library(vistime)
library(plotly)
library(DT)

# Link to Sankey data sources - saved in same folder as app.r
sankey <- readRDS("sankey.rds")

# Link to Dendrogram data sources - saved in same folder as app.r
bundles <- readRDS("bundles.rds")

# Link to Gantt data sources - saved in same folder as app.r
schedules <- readRDS("schedules.rds")
charDetails <- readRDS("charDetails.rds")
charDetails2 <- readRDS("charDetailsStd.rds")
charPic <- readRDS("charPic.rds")
charInfo <- readRDS("charInfo.rds")

### Data for Sankey Filters 
myData <- sankey
# Build links data frame
linksNetwork <- data.frame(source = myData$source, 
                           target = myData$target, 
                           value = myData$value, 
                           category = myData$category,
                           color = myData$color, 
                           season = myData$season, 
                           bin = myData$bin)

# Build nodes data frame
nodesNetwork <- data.frame(name = c(as.character(linksNetwork$source), as.character(linksNetwork$target)), 
                           category = as.character(linksNetwork$category), 
                           color = as.character(linksNetwork$color), 
                           season = as.character(linksNetwork$season), 
                           bin = as.character(linksNetwork$bin))
nodesNetwork <- unique(nodesNetwork)

# Get Use colors to all be the same
uses <- nodesNetwork[nodesNetwork$name %in% linksNetwork$target,]
uses$color <- "#737373"
index <- match(linksNetwork$target, nodesNetwork$name)
nodesNetwork$color[index] <- uses$color

# Get ID values for source and target fields - zero indexed
linksNetwork$IDsource <- match(linksNetwork$source, nodesNetwork$name) - 1
linksNetwork$IDtarget <- match(linksNetwork$target, nodesNetwork$name) - 1

### Define UI for application
ui <- fluidPage(
    titlePanel("Stardew Valley: Missed Connections"),
    tabsetPanel(
        tabPanel("Item Connections",fluid = TRUE, 
                 sidebarLayout(
                     sidebarPanel(
                         h3("Search"),
                         # Search for Items
                         selectizeInput(inputId = "search2",
                                        label = "Search for Items",
                                        choices = c("Select an Item" = "", unique(sankey$source)),
                                        selected = "Pumpkin",
                                        multiple = FALSE,
                                        options = list(placeholder = "Item")
                         ),
                         
                         h6("Search must be cleared for filters to work"),
                         actionButton(inputId = "clearSearch",
                                      label = "Clear Search"),
                         
                         h3("Filter"),
                         h6("All filters must have a value for chart to render"),
                         # Filter by Category
                         selectizeInput(inputId = "filterCat",
                                        label = "Select a Category",
                                        choices = NULL,
                                        multiple = FALSE,
                                        options = list(placeholder = 'Select Category')
                         ),
                         
                         # Filter by Season
                         selectizeInput(inputId = "filterSeas",
                                        label = "Select a Season",
                                        choices = NULL,
                                        multiple = FALSE,
                                        options = list(
                                            placeholder = 'Select Season',
                                            onInitialize = I('function() { this.setValue(""); }')
                                        )),
                         
                         # Filter by Bin
                         selectizeInput(inputId = "filterBin",
                                        label = "Select a Sale Value",
                                        choices = NULL,
                                        multiple = FALSE,
                                        options = list(
                                            placeholder = 'Select Bin',
                                            onInitialize = I('function() { this.setValue(""); }')
                                        ))
                         ),
                     mainPanel(fluidRow(
                         plotlyOutput("sankey", height = 800)
                         )))),
                
        tabPanel("Community Center Bundles", 
                 fluidRow(
                     column(width = 3, 
                            wellPanel(align = "center",
                                      h3("Explore the Community Center Bundles!"),
                                      img(src = "CC_Complete.png", height = "50%", width = "50%"),
                                      h5("Click Circles to Expand the Hierarchy"))),
                     column(width = 9,
                            collapsibleTreeOutput("dendro", height = "800px")
                 ))),

        tabPanel("Character Schedules", fluid = TRUE, 
                 fluidRow(
                     column(4,
                            wellPanel(
                                h3("Filters"),
                                h6("All filters must have a value for chart to render"),
                                # Drop down filter for Character
                                selectInput("filterChar", "Select a Character", choices = unique(schedules$Character), 
                                            selected = "Elliott", multiple = FALSE),
                                # Drop down filter for Season
                                selectInput("filterSeason", "Select a Season", choices = unique(schedules$Season), 
                                            selected = "Spring", multiple = FALSE),
                                # Drop down filter for Weather
                                selectInput("filterWeather", "Select the Weather", choices = unique(schedules$Weather), 
                                            selected = "Nice", multiple = FALSE), 
                                # Drop down filter for Community Center Completion
                                selectInput("filterCC", "Community Center Complete?", choices = unique(schedules$CC_Completed),
                                            selected = "No", multiple = FALSE),
                                # Drop down filter for BFF 6+ Hearts
                                selectInput("filterBFF", "6+ Hearts with BFF?", choices = unique(schedules$BFF_6PlusHearts),
                                            selected = "No", multiple = FALSE), 
                                # Drop down filter for Spouse
                                selectInput("filterSpouse", "Are you their spouse?", choices = unique(schedules$Spouse), 
                                            selected = "No", multiple = FALSE),
                                DT::dataTableOutput('picture'),
                                DT::dataTableOutput('info'),
                            )),
                     column(8,
                            plotlyOutput("gantt"),
                            fluidRow(
                                column(4,DT::dataTableOutput('charGifts')),
                                column(4,DT::dataTableOutput('charGiftsStd')),
                                column(4,h5(strong("Legend")),img(src = "GanttLegend.png"))
                                       
                            ))
                    ))
                 
                ))

### Define server logic
server <- function(input, output, session){
    ##### Sankey Diagram Code
    ### Reactive Data for Filters
    sankeyFilter <- reactive({
        linksNetwork %>%
            filter(category == input$filterCat) %>% 
            filter(season == input$filterSeas) %>% 
            filter(bin == input$filterBin)
    })
    
    updateSelectizeInput(
        session = session,
        inputId = "filterCat",
        choices = sort(unique(as.character(linksNetwork$category))),
        selected = "",
        options = list(placeholder = 'Select Category'),
        server = TRUE
    )
    
    observeEvent(input$filterCat,{
        choice_filterSeas <- sort(unique(as.character(linksNetwork$season[which(linksNetwork$category==input$filterCat)])))
        
        updateSelectizeInput(
            session = session,
            inputId = "filterSeas",
            choices = choice_filterSeas
        )
    })
    
    observeEvent(input$filterSeas,{
        choice_filterBin <- sort(unique(as.character(linksNetwork$bin[which(linksNetwork$category==input$filterCat &
                                                                                linksNetwork$season==input$filterSeas)])))
        
        updateSelectizeInput(
            session = session,
            inputId = "filterBin",
            choices = choice_filterBin
        )
    })
    
    ## Reactive Search Data
    observeEvent(input$clearSearch, {
        updateSelectizeInput(session, "search2", selected = "") 
    })  
    
    searchFilter <- reactive({
        linksNetwork %>% filter(source == input$search2)
    })

    # Plot Sankey Diagram
    output$sankey <- renderPlotly({
        if (input$search2 != "") { # if search input is not empty, update filters and plot using search data
            updateSelectizeInput(session, "filterSeas", selected = "")
            updateSelectizeInput(session, "filterBin", selected = "")
            updateSelectizeInput(session, "filterCat", selected = "")
            
            plot_ly(
                type = "sankey", 
                orientation = "h", 
                
                node = list(
                    label = nodesNetwork$name,
                    color = nodesNetwork$color,
                    pad = 15, 
                    thickness = 20, 
                    line = list(
                        color = "black", 
                        width = 0.5
                    )
                ),
                
                link = list(
                    source = searchFilter()$IDsource, 
                    target = searchFilter()$IDtarget, 
                    value = searchFilter()$value
                ),
                
                hoverinfo = "none"
                
            ) %>% config(displaylogo = FALSE, modeBarButtons = list(list("resetViewSankey")))
        } else { # plot using filter data if search input is empty
            plot_ly(
                type = "sankey", 
                orientation = "h", 
                
                node = list(
                    label = nodesNetwork$name,
                    color = nodesNetwork$color,
                    pad = 15, 
                    thickness = 20, 
                    line = list(
                        color = "black", 
                        width = 0.5
                    )
                ),
                
                link = list(
                    source = sankeyFilter()$IDsource, 
                    target = sankeyFilter()$IDtarget, 
                    value = sankeyFilter()$value
                ),
                
                hoverinfo = "none"
                
            ) %>% config(displaylogo = FALSE, modeBarButtons = list(list("resetViewSankey")))
        }
        
    })

    ##### Dendrogram Diagram Code
    # Plot Dendrogram
    output$dendro <- renderCollapsibleTree({
        collapsibleTree(bundles, c("Level2", "Level3", "Level4"), collapsed = TRUE,
                        zoomable = FALSE, root = "Community Center", fill = "#79C47C", tooltip = FALSE)
    })
    
    ##### Gantt Chart Code
    ### Character Loved Gifts Table
    # Reactive data connecting character selection to Character Gifts Table
    charFilterGifts <- reactive({
        charDetails %>% filter(Character == input$filterChar)
    })
    
    # Generate table with gifts and images
    output$charGifts <- DT::renderDataTable({
        DT::datatable(charFilterGifts(), escape = FALSE, rownames = FALSE, 
                      options = list(dom = 't', bSort = FALSE, 
                                     columnDefs = list(list(visible = FALSE, targets = 0))))
    })
    
    ### Standard Loved Gifts Table
    # Reactive data connecting character selection to Standard Gifts Table
    charFilterStd <- reactive({
        charDetails2 %>% filter(Character == input$filterChar)
    })
    
    # Generate 2nd table with gifts and images
    output$charGiftsStd <- DT::renderDataTable({
        DT::datatable(charFilterStd(), escape = FALSE, rownames = FALSE, 
                      options = list(dom = 't', bSort = FALSE, 
                                     columnDefs = list(list(visible = FALSE, targets = 0))))
    })
    
    ### Character Profile Section
    # Reactive data connecting Gantt character selection to Picture
    charFilterPic <- reactive({
        charPic %>% filter(Character == input$filterChar)
    })    
    
    # Generate table with Picture
    output$picture <- DT::renderDataTable({
        DT::datatable(charFilterPic(), escape = FALSE, rownames = FALSE, colnames = '',
                      options = list(dom = 't', bSort = FALSE, columnDefs = list(list(visible = FALSE, targets = 0),
                                                                                 list(className = 'dt-center', targets = "_all"))))
    })
    
    # Reactive data connecting Gantt chart character selection to Profile Info
    charFilterInfo <- reactive({
        charInfo %>% filter(Character == input$filterChar)
    })    
    
    # Generate chart with Profile Info
    output$info <- DT::renderDataTable({
        DT::datatable(charFilterInfo(), escape = FALSE, rownames = FALSE, 
                      options = list(dom = 't', bSort = FALSE, columnDefs = list(list(visible = FALSE, targets = 0),
                                                                                 list(className = 'dt-center', targets = "_all"))))
    })
    ### Gantt Chart
    # Reactive data for Gantt Chart
    schedulesFilter <- reactive({
        filtered <- schedules %>% filter(Character == input$filterChar, Season == input$filterSeason, 
                                         Weather == input$filterWeather, CC_Completed == input$filterCC, 
                                         BFF_6PlusHearts == input$filterBFF, Spouse == input$filterSpouse)
    })
    
    # Plot Gantt chart
    output$gantt <- renderPlotly({
        vistime(data = schedulesFilter(), col.event = "Location", col.start = "Start", col.end = "End", 
                col.group = "Day", col.color = "Color", optimize_y = TRUE, linewidth = 25, 
                title = "Character Schedule") %>% config(displayModeBar = FALSE) %>% layout(xaxis = list(fixedrange = TRUE)) %>% layout(yaxis = list(fixedrange = TRUE))
    })
}
# Run the application 
shinyApp(ui = ui, server = server)

# Publish to shinyapps.io
library(rsconnect)
rsconnect::deployApp('C:/Users/Mnandrews24/Documents/MICA/Thesis/R/ShinyApp/StardewValley')

