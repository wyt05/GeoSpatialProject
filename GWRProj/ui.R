#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
pacman::p_load("shinythemes")

# Define UI for application that draws a histogram
fluidPage( theme=shinytheme("cyborg"),

  navbarPage("GWR",
             tabPanel("About Us",
                      titlePanel("A look into the Hedonic Pricing Models of HDB Flats"),
                      sidebarLayout(
                        sidebarPanel(tags$h3("Group Members"),
                                     tags$ul(
                                       tags$li('Chen Hao Xian'),
                                       tags$li('Pierre Jean Michel Haas'),
                                       tags$li('Tan Wen Yang')
                                     )
                        ),
                        mainPanel(
                                  titlePanel("Project Motivation"),
                                  "The price of HDB resale flat has beenon a rise and it has seen 
                                  tremendous growth over the years. However, predicting HDB prices
                                  haven't been easy as most current estimators only look at the
                                  linear relationship between the dependent and independent variables
                                  without factoring spatial heterogeneity. This is because location-specific
                                  variables such as proximity to good schools can have varying effects on housing
                                  prices on different neighbourhoods that cannot be modeled via a linear relationship.",
                                  titlePanel("Objective"),
                                  "Our objective is to make use of Geographically Weighted Regression to create a more
                                  accurate model that properly models the relationship between location-specific variables
                                  with structural variables in order to better gain an accurate insight into the veracity
                                  of which variables contributes the most to the pricing of the HDB flats, and which does not.",
                                  titlePanel("App Functions"),
                                  tags$ol(
                                    tags$li('Exploratory Data Analysis'),
                                    tags$li('GWR'),
                                    tags$li('???')
                                  )
                      ),
                    )
                   ),
                      
             tabPanel("EDA",
                      titlePanel("Exploratory Data Analysis"),
                      sidebarLayout(
                        sidebarPanel(
 
                          selectInput(
                            inputId = "filter_start_year",
                            label = "Start Year",
                            choices = list("2017" = "2017",
                                           "2018" = "2018",
                                           "2019" = "2019",
                                           "2020" = "2020",
                                           "2021" = "2021",
                                           "2022" = "2022",
                                           "2023" = "2023"
                            ),
                            selected = "2021"),
                          

                          selectInput(
                            inputId = "filter_end_year",
                            label = "End Year",
                            choices = list("2017" = "2017",
                                           "2018" = "2018",
                                           "2019" = "2019",
                                           "2020" = "2020",
                                           "2021" = "2021",
                                           "2022" = "2022",
                                           "2023" = "2023"
                            ),
                            selected = "2022"),                          
                                                   
                          selectInput(
                            inputId = "filter_start_month",
                            label = "Start Month",
                            choices = list("January" = "01",
                                           "February" = "02",
                                           "March" = "03",
                                           "April" = "04",
                                           "May" = "05",
                                           "June" = "06",
                                           "July" = "07",
                                           "August" = "08",
                                           "September" = "09",
                                           "Ocotober" = "10",
                                           "November" = "11",
                                           "December" = "12"
                            ),
                            selected = "01"),
                          
                          selectInput(
                            inputId = "filter_end_month",
                            label = "End Month",
                            choices = list("January" = "01",
                                           "February" = "02",
                                           "March" = "03",
                                           "April" = "04",
                                           "May" = "05",
                                           "June" = "06",
                                           "July" = "07",
                                           "August" = "08",
                                           "September" = "09",
                                           "Ocotober" = "10",
                                           "November" = "11",
                                           "December" = "12"
                            ),
                            selected = "12"),
                          
                          selectInput(
                            inputId = "filter_flat_type",
                            label = "Flat Type",
                            choices = list("1 Room" = "1 ROOM",
                                           "2 Room" = "2 ROOM",
                                           "3 Room" = "3 ROOM",
                                           "4 Room" = "4 ROOM",
                                           "5 Room" = "5 ROOM",
                                           "Executive" = "EXECUTIVE"
                            ),
                            selected = "4 ROOM"),
                          
                          
                          selectInput(
                            inputId = "classification",
                            label = "Classification Method",
                            choices = c("pretty" = "pretty",
                                        "quantile" = "quantile",
                                        "sd" = "sd",
                                        "equal" = "equal", 
                                        "kmeans" = "kmeans", 
                                        "hclust" = "hclust", 
                                        "bclust" = "bclust", 
                                        "fisher" = "fisher",
                                        "jenks" = "jenks"
                            ),
                            selected = "pretty"),
                          
                          
                          
                          sliderInput(
                            inputId = "classes",
                            label = "Number of Classes",
                            min = 6,
                            max = 12,
                            value = c(6)),
                          
                          selectInput(
                            inputId = "colour",
                            label = "Colour scheme",
                            choices = c(
                              "blues" = "Blues",
                              "reds" = "Reds",
                              "greens" = "Greens",
                              "Yellow-Orange-Red" = "YlOrRd",
                              "Yellow-Orange-Brown" = "YlOrBr",
                              "Yellow-Green" = "YlGn",
                              "Orange-Red" = "OrRd"
                            ),
                            selected = "YlOrRd"
                          )
                          
                        ),
                        
                        mainPanel(
                          titlePanel("Ducky"),
                          
                          dataTableOutput('hdb_table'),
                          
                          
                          tmapOutput("mapPlot",
                                     width = "100%",
                                     height = 400)
                        )
                      ),                      
                      
             ),
             
             tabPanel("Upload File",
                      titlePanel("Upload the RDS"),
                      sidebarLayout(
                        
                        sidebarPanel(titlePanel("Disclaimer"),
                          "You will also need to make sure that all the information has been computed already, otherwise it will not work.",
                          "You will need to ensure that the RDS is below 5MB, otherwise it will crash",
                          titlePanel("Upload File"),
                          fileInput("file1", "Choose RDS File",
                                    multiple = TRUE,
                                    accept = c(".rds")),
                        ),
                        
                        
                        mainPanel(
                          dataTableOutput('upload_table'),
                        ),
                        
                        
                        
                        
                      )
             ),
             
             


  )
  
)
