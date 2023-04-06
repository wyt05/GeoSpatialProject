#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
pacman::p_load(sf, tidyverse, tmap, onemapsgapi, httr, jsonlite, olsrr, corrplot ,GWmodel, dotenv, matrixStats, spdep, SpatialML, Metrics, ggpubr)


## we will load the model here
coordinates_table <- read_rds("data/rds/rs_coords_full.rds")





#making the table



# Define server logic required to draw a histogram
function(input, output, session) {
  
    ## This check which file we should use
  
    resale_data <- reactive({
      
      start_date <- base::paste(input$filter_start_year, input$filter_start_month, sep="-")
      
      end_date <- base::paste(input$filter_end_year, input$filter_end_month, sep="-")
      
      if(is.null(input$file1)){
        
        resale_flat_full <-  filter(coordinates_table, flat_type == input$filter_flat_type) %>% 
          filter(month >= start_date & month <= end_date) %>%
          select(2, 7, 11, 15:17, 19:38) %>%
          rename("AREA_SQM" = "floor_area_sqm", 
                 "LEASE_YRS" = "remaining_lease_mths", 
                 "PRICE"= "resale_price",
                 "AGE"= "age",
                 "STOREY_ORDER" = "storey_order") %>%
          relocate("PRICE") %>%
          relocate(geometry, .after = last_col())
        
        return(resale_flat_full)
      }
      else {
        req(input$file1)
        df <- read_rds(input$file1$datapath)
        
        resale_flat_full <- filter(df,flat_type == input$filter_flat_type) %>% 
          filter(month >= start_date & month <= end_date) %>%
          select(2, 7, 11, 15:17, 19:38) %>%
          rename("AREA_SQM" = "floor_area_sqm", 
                 "LEASE_YRS" = "remaining_lease_mths", 
                 "PRICE"= "resale_price",
                 "AGE"= "age",
                 "STOREY_ORDER" = "storey_order") %>%
          relocate("PRICE") %>%
          relocate(geometry, .after = last_col())
        
        return(resale_flat_full)
      }
    })
  

    resale_data_cleaned <- reactive({
      
      start_date <- base::paste(input$filter_start_year, input$filter_start_month, sep="-")
      
      end_date <- base::paste(input$filter_end_year, input$filter_end_month, sep="-")
      
      if(is.null(input$file1)){
        
        resale_flat_full <-  filter(coordinates_table, flat_type == input$filter_flat_type) %>% 
          filter(month >= start_date & month <= end_date) %>%
          select(7, 11, 15:17, 19:38) %>%
          rename("AREA_SQM" = "floor_area_sqm", 
                 "LEASE_YRS" = "remaining_lease_mths", 
                 "PRICE"= "resale_price",
                 "AGE"= "age",
                 "STOREY_ORDER" = "storey_order") %>%
          relocate("PRICE") %>%
          relocate(geometry, .after = last_col())
        
        return(resale_flat_full)
      }
      else {
        req(input$file1)
        df <- read_rds(input$file1$datapath)
        
        resale_flat_full <- filter(df,flat_type == input$filter_flat_type) %>% 
          filter(month >= start_date & month <= end_date) %>%
          select(7, 11, 15:17, 19:38) %>%
          rename("AREA_SQM" = "floor_area_sqm", 
                 "LEASE_YRS" = "remaining_lease_mths", 
                 "PRICE"= "resale_price",
                 "AGE"= "age",
                 "STOREY_ORDER" = "storey_order") %>%
          relocate("PRICE") %>%
          relocate(geometry, .after = last_col())
        
        return(resale_flat_full)
      }
    })
    
    resale_data_nogeo <- reactive({
      
      new_df <- resale_data_cleaned() %>%
        st_drop_geometry() 
      
      return(new_df)
    })
    
    
    
    nogeo_lm <- reactive({
      
      var_formulat <- as.formula(paste("PRICE"," ~ ",paste(input$dependent_variable,collapse="+")))
      
      resale_mlr1 <- lm(var_formulat, resale_data_nogeo())
      
      return(resale_mlr1)
      
      
    })
      
    ### This is to render the HDB Data Table
    output$hdb_table <- renderDataTable(
      {
        print(resale_data())
      }
    )
    
    
    
    
    
    
    ### This is to render the histrogram Plot
    
    output$histogram_plots <- renderPlot({
      
          ggplot(data=resale_data(), aes_string(x= input$hist_variable)) +
            geom_histogram(bins=input$num_bins, color="black", fill=input$fill_color) +
            labs(title = "Distribution",
                 x = input$hist_variable,
                 y = 'Frequency')
          
    })
    
    ### This is the explaination for text

    output$key_summaries <- renderDataTable(
      {
          return(summary(st_drop_geometry(resale_data() %>% select(input$hist_variable))))
      }
    )

    

        

    output$top_towns <- renderDataTable(
      {
          var_mean <- aggregate(resale_data()[,input$hist_variable], list(resale_data()$town), mean)
          top10 = top_n(var_mean, 10, input$hist_variable) %>%
            arrange(desc(input$hist_variable))
          
          
          top10 <- st_drop_geometry(top10)      
          
          return(top10)
        
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
    
    ### This is to render the Correlation Plot
    
    output$corrPlot <- renderPlot({
      corrplot(cor(resale_data_nogeo()[, 2:23]), 
               diag = FALSE, 
               order = "AOE",
               tl.pos = "td",
               tl.cex = 0.5,
               method = "number", 
               type = "upper")
    })
    
    output$linear_regress <- renderPrint({
      summary(nogeo_lm())
    })
    
    output$linear_regress_1 <- renderPrint({
      ols_vif_tol(nogeo_lm())
    })    
    
    output$linear_regress_2 <- renderPlot({
      ols_plot_resid_fit(nogeo_lm())
    })
    
    output$linear_regress_3 <- renderPlot({
      ols_plot_resid_hist(nogeo_lm())
    })
    
}
