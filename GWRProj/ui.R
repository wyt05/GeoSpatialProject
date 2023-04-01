#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
fluidPage(

  navbarPage("GWR",
             tabPanel("About Us",
                      titlePanel("GWR"),
                      sidebarLayout(
                        sidebarPanel(titlePanel("A look into the Hedonic Pricing Models of HDB Flats"),
                                     "A look into the Hedonic Pricing Models of HDB Flats",
                                     tags$ul(
                                       tags$li('Chen Hao Xian'),
                                       tags$li('Pierre Jean Michel Haas'),
                                       tags$li('Tan Wen Yang'),
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
                      ),
                    )
                   ),
                      
             tabPanel("EDA"),
             tabPanel("GWR")
  )
  
)
