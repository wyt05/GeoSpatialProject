#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinycssloaders)

options(spinner.color="#0275D8", spinner.color.background="#ffffff", spinner.size=2)

pacman::p_load("shinythemes")
pacman::p_load(sf, tidyverse, tmap, onemapsgapi, httr, jsonlite, olsrr, corrplot ,GWmodel, dotenv, matrixStats, spdep, SpatialML, Metrics, ggpubr)

coordinates_table <- read_rds("data/rds/rs_coords_full.rds")

resale_flat_full <- coordinates_table %>%
  select(7, 11, 15:17, 19:38) %>%
  rename("AREA_SQM" = "floor_area_sqm", 
         "LEASE_YRS" = "remaining_lease_mths", 
         "PRICE"= "resale_price",
         "AGE"= "age",
         "STOREY_ORDER" = "storey_order") %>%
  relocate("PRICE") %>%
  relocate(geometry, .after = last_col()) %>%
  st_drop_geometry() 


resale_flat_full_nogeo <- coordinates_table %>%
  select(7, 15:17, 19:38) %>%
  rename("AREA_SQM" = "floor_area_sqm", 
         "LEASE_YRS" = "remaining_lease_mths",
         "AGE"= "age",
         "STOREY_ORDER" = "storey_order") %>%
  relocate(geometry, .after = last_col())%>%
  st_drop_geometry() 


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
                      
                      tabPanel("CorrPlot",
                               fluidPage(
                                 width = "100%",
                                 h3("CTEST FOR NORMALITY ASSUMPTION"),
                                 plotOutput("corrPlot")
                                 
                               )
                               
                      ),
                      
                      tabPanel("EDA",
                               h3("Exploratory Data Analysis"),
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
                                     inputId = "hist_variable",
                                     label = "Histogram Variabe",
                                     choices = colnames(resale_flat_full),
                                     selected = "resale_price"),
                                   
                                   sliderInput(
                                     inputId = "num_bins",
                                     label = "Number of Bins",
                                     min = 5,
                                     max = 20,
                                     value = c(5)),
                                   
                                   selectInput(
                                     inputId = "fill_color",
                                     label = "Fill color",
                                     choices = c(
                                       "blue" = "blue",
                                              "red" = "red",
                                              "green" = "green",
                                              "yellow" = "yellow",
                                              "orange" = "orange"
                                     ),
                                     selected = "red"
                                   )
                                   
                                 ),
                                 
                                 mainPanel(
                                   h3("Histogram Plots"),
                                   
                                   withSpinner(plotOutput('histogram_plots'), type = 2),
                                   
                                   h6("The Histogram will tell you whether the data is skewed or not. Most are skewed, but they resemble a normal distribution enough most of the time."),
                                   "",
                                   h3("Key Summaries"),
                                   h6("This segment basically tell you what the Key Summaries of the selected variables are for which town"),
                                   "",
                                   withSpinner(dataTableOutput('key_summaries'), type = 2),
                                   
                                   h6("You can find find the Top 10 towns of the indicated variable here."),
                                   withSpinner(dataTableOutput('top_towns'), type = 2),
                                   
                                   h3("Data Frame"),
                                   
                                   dataTableOutput('hdb_table')
                                   
                                 )
                               ),                      
                               
                      ),
                      
                      
                      tabPanel("Multiple Linear Regression",
                               titlePanel("Multiple Linear Regression"),
                               
                               sidebarLayout(
                                 sidebarPanel(
                                   
                                   h4("Dependent Variables"),
                                   h6("Please Reference the CorrPlot to select the correct variable. The Correlation Plot is currently static to give you an over view"),
                                   "",
                                   "",
                                   selectInput(
                                     inputId = "dependent_variable",
                                     label = "Y-Axis",
                                     choices = colnames(resale_flat_full_nogeo) ,
                                     selected = colnames(resale_flat_full_nogeo),
                                     multiple = TRUE),
                                   
                                   h4("Weight Matrix"),
                                   h6("Please ensuret that the Lower Bound is greater than the Upper Bound. Please note that the computation will take a long time."),
                                   
                                   numericInput(
                                     inputId = "lowerBound",
                                     label = "Weight Matrix Lower Bound (km)",
                                     value = 0,
                                     min = 0,
                                     max = NA),
                                   
                                   numericInput(
                                     inputId = "upperBound",
                                     label = "Weight Matrix Upper Bound (km)",
                                     value = 2500,
                                     min = 1,
                                     max = NA),
                                   
                                   selectInput(
                                     inputId = "matrixStyles",
                                     label = "Matrix Style",
                                     choices = list("Basic Binary" = "B",
                                                    "Row Standardised" = "W",
                                                    "Global Standardised" = "C",
                                                    "Sum over all links to Unity" = "U",
                                                    "Variance Stabalized" = "S",
                                                    "Minimum Maximum" = "minmax"
                                     ),
                                     selected = "W"),
                                   
                                   selectInput(
                                     inputId = "zeroPolicy",
                                     label = "Set Zero Policy",
                                     choices = list("TRUE" = TRUE,
                                                    "FALSE" = FALSE
                                     ),
                                     selected = TRUE),
                                   
                                   h6("Pressing the Button will result in a Long Loading Time, please refrain from pressing it unless you wish to compute the value in real time."),
                                   
                                   actionButton(
                                     inputId = "computeMoran", 
                                     label = "Compute Moran")
                                   
                                 ),
                                 
                                 
                                 
                                 mainPanel(
                                   h3("Multiple Linear Regression"),
                                   
                                   
                                   withSpinner(verbatimTextOutput("linear_regress"), type = 2),
                                   
                                   
                                   h6("Please remove all the models that are considered not significant based on your estimated probability."),
                                   h6(""),
                                   
                                   h3("Testing for Linearity"),
                                   h4("Checking for Multi-Colinearlity"),
                                   withSpinner(verbatimTextOutput("linear_regress_1"), type = 2),
                                   
                                   h6("Remove All Variables with VIF more than 10 as they are signs of collinearity"),
                                   h6(),
                                   h4("Testing for Non Linearlity"),
                                   withSpinner(plotOutput("linear_regress_2"), type = 2),
                                           
                                   h6("Try to keep all the points close to the line"),
                                   h6(" "),
                                   
                                   h4("Test for Normality Assumption"),
                                   withSpinner(plotOutput("linear_regress_3"), type = 2),
                                   
                                   h6("Try to keep all the residues resemble a Normal Distribution"),
                                   
                                   h3("Testing for Auto Spatial Correlation"),
                                   h6("Since we are planning to build a Geographically Weighted Linear Regression Model, we would need to perform a Test of Spatial Auto Correlation"),
                                   
                                   withSpinner(verbatimTextOutput("moran_test"), type = 2),
                                   
                                   h6(" What we are looking for is the p-value for the Moran Test. If the p-value is less than the alpha value of 0.05, we will reject the null hypothesis that the residuals are randomly distributed."),
                                   
                                   h6("This value loaded is calculated with the default value, press the 'Compute Moran' Button to render a real time value but it will take a long time to load. The value above will be updated"),
                                   
                                   
                                 )
                                 
                               )

                      ),

                      tabPanel("Geographically Weighted Regression",
                               titlePanel("Generating Geographically Weighted regression model"),
                               
                               sidebarLayout(
                                 sidebarPanel(
                                   numericInput(
                                     inputId = "bandwidth",
                                     label = "Bandwidth of the Model",
                                     value = 9121,
                                     min = 0,
                                     max = NA),
                                   
                                   selectInput(
                                     inputId = "kernelValues",
                                     label = "Kernal Style",
                                     choices = list("Gaussian" = "gaussian",
                                                    "Exponential" = "exponential",
                                                    "Bi Square" = "bisquare",
                                                    "Tri Cube" = "tricube",
                                                    "Box Car" = "boxcar"
                                     ),
                                     selected = "gaussian"),
                                   
                                   selectInput(
                                     inputId = "adaptive",
                                     label = "Adaptive?",
                                     choices = list("TRUE" = "TRUE",
                                                    "FALSE" = "FALSE"
                                     ),
                                     selected = "TRUE"),
                                   
                                   numericInput(
                                     inputId = "power",
                                     label = "Power of Minkowski Distance",
                                     value = 2,
                                     min = 0,
                                     max = NA),
                                   
                                   numericInput(
                                     inputId = "theta",
                                     label = "Angle in Radians",
                                     value = 0,
                                     min = 0,
                                     max = 6.283),
                                   
                                   selectInput(
                                     inputId = "longlat",
                                     label = "Great Circle Distance?",
                                     choices = list("TRUE" = "TRUE",
                                                    "FALSE" = "FALSE"
                                     ),
                                     selected = FALSE),
                                   
                                   h6("Generating the GWR will result in a Long Loading Time, please refrain from pressing it unless you wish to compute the value in real time."),
                                   
                                   actionButton(
                                     inputId = "generate_gwr", 
                                     label = "Generate GWR"),
                                   
                                   h6("Generating the Bandwidth and GWR will result in a Long Loading Time, please refrain from pressing it unless you wish to compute the value in real time."),
                                   
                                   selectInput(
                                     inputId = "approach",
                                     label = "Great Circle Distance?",
                                     choices = list("CV" = "CV",
                                                    "AIC" = "AIC"
                                     ),
                                     selected = "CV"),
                                   
                                   actionButton(
                                     inputId = "compute_bandwidth", 
                                     label = "Use Computed BandWidth"),
                                   
                                 ),
                                 
                                 
                                 
                                 mainPanel(
                                   h3("Testing for Auto Spatial Correlation"),
                                   h6("We will be generating the GW_Adaptive Method"),
                                   
                                   withSpinner(verbatimTextOutput("gw_adaptive"), type = 2),
                                   
                                   h6("This value loaded is calculated with the default value, press the 'Generate GWR' or 'Use Computed BandWidth' Button to render a real time value but it will take a long time to load. The value above will be updated"),
                                   
                                 )
                                 
                               )
                               
                      ),                      
                      
                      tabPanel("Predicting",
                               titlePanel("Predicting the Values"),
                               
                               sidebarLayout(
                                 sidebarPanel(
                                   
                                   selectInput(
                                     inputId = "selectedModel",
                                     label = "Select Regression Model to Use",
                                     choices = list("GeoGraphically Weighted Regression" = "GWR",
                                                    "Multiple Linear Regression" = "MLR"
                                     ),
                                     selected = "MLR"),
                                   
                                   h6("For GWR Please upload a RDS File to use. It must be a Spatial Dataframe with all the values"),
                                   fileInput("file2", "Choose RDS File",
                                             multiple = TRUE,
                                             accept = c(".rds")),
                                   
                                   h6("Please follow the order as stated when entering the values"),
                                   
                                   withSpinner(verbatimTextOutput("insert_values"), type = 2),
                                   
                                   textAreaInput("values", "Please Input the Values seperated by Commas", rows = 3, value = "120000,20,30,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12")
                                   
                                 ),
                                 
                                 
                                 mainPanel(
                                   h3("Predicted Value"),
                                   h6("Generating the Prediction for GWR and Bandwidth will result in a Long Loading Time, please refrain from pressing it unless you wish to compute the value in real time."),

                                   withSpinner(verbatimTextOutput("predictions"), type = 2),
                                   
                                 )
                                 
                               )
                               
                      ),                            
 
                      tabPanel("Interactive Map",
                               titlePanel("Interactive Map"),
                               sidebarLayout(
                                 sidebarPanel(titlePanel("Disclaimer"),
                                              selectInput(
                                                inputId = "filter_start_year_map",
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
                                                inputId = "filter_end_year_map",
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
                                                inputId = "filter_start_month_map",
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
                                                inputId = "filter_end_month_map",
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
                                                inputId = "filter_flat_type_map",
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
                                                inputId = "view_variable_map",
                                                label = "map_variable",
                                                choices = colnames(resale_flat_full),
                                                selected = "resale_price"),
                                              
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
                                   h3("Interactive TMap"),
                                   withSpinner(tmapOutput("mapPlot", width = "100%", height = 400), type = 2)
                                   
                                 ),
                                 
                               )
                      ),
                                           
                      
                      tabPanel("Upload File",
                               titlePanel("Upload the RDS"),
                               sidebarLayout(
                                 
                                 sidebarPanel(titlePanel("Disclaimer"),
                                              h6("You will also need to make sure that all the information has been computed already, otherwise it will not work, please follow the naming scheme as seen in the EDA Tab"),
                                              h6("You will need to ensure that the RDS is below 5MB, otherwise it will crash"),
                                              titlePanel("Upload File"),
                                              fileInput("file1", "Choose RDS File",
                                                        multiple = TRUE,
                                                        accept = c(".rds")),
                                 ),
                                 
                                 
                                 mainPanel(
                                   h3("Uploaded Table"),
                                   withSpinner(dataTableOutput('upload_table'), type = 2)
                                   
                                 ),

                               )
                      ),
                      
                      
                      
                      
           )
           
)
