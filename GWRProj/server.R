#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
pacman::p_load(sf, tidyverse, tmap, onemapsgapi, httr, jsonlite, olsrr, GWmodel, dotenv, matrixStats, spdep, SpatialML, Metrics, ggpubr)


## we will load the model here
coordinates_table <- read_rds("data/rds/rs_coords_full.rds")

#making the table



# Define server logic required to draw a histogram
function(input, output, session) {
  
    output$hdb_table <- renderDataTable(
      {
        if(is.null(input$file1)){
          filtered_data_table <- coordinates_table %>%
                                  filter()
          
          
          
          
          
          
          
          
          
          
          
          return(coordinates_table)
          
          
          
          
          
          
          
          
          
          
          
          
        } else {
          req(input$file1)
          df <- read_rds(input$file1$datapath)
          return(df)
        }
      }
      
      

    )

    output$upload_table <- renderDataTable({
      
      # input$file1 will be NULL initially. After the user selects
      # and uploads a file, head of that data file by default,
      # or all rows if selected, will be shown.
      
      req(input$file1)
      
      df <- read_rds(input$file1$datapath)
      return(df)
      
      
    })

}
