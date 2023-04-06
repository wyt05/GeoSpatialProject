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
                          
                          plotOutput('histogram_plots'),
                          h6("The Histogram will tell you whether the data is skewed or not. Most are skewed, but they resemble a normal distribution enough most of the time."),
                          "",
                          h3("Key Summaries"),
                          h6("This segment basically tell you what the Key Summaries of the selected variables are for which town"),
                          "",
                          dataTableOutput('key_summaries'),
                          h6("You can find find the Top 10 towns of the indicated variable here."),
                          dataTableOutput('top_towns'),

                          
                          h3("Data Frame"),
                          
                          dataTableOutput('hdb_table')
                          
                        )
                      ),                      
                      
             ),
             
             
             tabPanel("Multiple Linear Regression",
                      titlePanel("Multiple Linear Regression"),

                      sidebarLayout(
                        sidebarPanel(
                          h6("Please Reference the CorrPlot to select the correct variable. The Correlation Plot is currently static to give you an over view"),
                          "",
                          selectInput(
                            inputId = "dependent_variable",
                            label = "Y-Axis",
                            choices = colnames(resale_flat_full_nogeo) ,
                            selected = colnames(resale_flat_full_nogeo),
                            multiple = TRUE)
                        ),
                        
                        
                        
                        mainPanel(
                          h3("Multiple Linear Regression"),
                          verbatimTextOutput("linear_regress"),
                          
                          h6("Please remove all the models that are considered not significant based on your estimated probability."),
  
                          h3("Testing for Linearity"),
                          h5("CHECKING FOR MULTICOLLINEARITY"),
                          verbatimTextOutput("linear_regress_1"),
                          h6("Remove All Variables with VIF more than 10 as they are signs of collinearity"),
                          
                          h5("TEST FOR NON-LINEARITY"),
                          plotOutput("linear_regress_2"),          
                          h6("Try to keep all the points close to the line"),

                          h5("TEST FOR NORMALITY ASSUMPTION"),
                          plotOutput("linear_regress_3"),   
                          h6("Try to keep all the residues resemble a Normal Distribution")
  
                        )
                        
                      )
                      
               
               
               
             ),
             
             
             tabPanel("Upload File",
                      titlePanel("Upload the RDS"),
                      sidebarLayout(
                        
                        sidebarPanel(titlePanel("Disclaimer"),
                          "You will also need to make sure that all the information has been computed already, otherwise it will not work, please follow the naming scheme as seen in the EDA Tab",
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
