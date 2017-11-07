#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.

library(shiny)
library(stringr)
library(tidytext)
library(tidyverse)


# increase the default file inut size to 50 MB
options(shiny.maxRequestSize = 50*1024^2)

# Define server logic required 
shinyServer(function(input, output) {
   
  # take the inputs from UI (fileInput - "text_file") and 
  # read them into a reactive dataframe
  text_data <- reactive({
        
      file_with_text <- input$text_file
      
      if(is.null(file_with_text)){return()} 
      read_delim(file = file_with_text$datapath, delim = input$sep, col_names = FALSE,
                 locale = locale(encoding = "WINDOWS-1252")) 
    
  })# end reactive
  
  
  # build regex pattern lexicons for each type of personal information
  pan_no <- "[[A-Z]]{5}[[:digit:]]{4}[[A-Z]]{1}|PAN[[:space:]][[A-Z]]{5}[[:digit:]]{4}[[A-Z]]{1}|PAN[[:space:]][A-z]{1,}[[:space:]][A-Z]{5}[[:digit:]]{4}[A-Z]{1}"
  email_address <- ".{1,}@.{1,}.{1}[A-z]{3,}"
  folio_no <- "Folio.{1,}[0-9]{10}|folio.{1,}[0-9]{10}"
  
  df <- reactive({
    ln <- length(text_data()$X1)
    
    text_data()$X1 %>%
      map(str_detect ,pattern = c(pan_no,email_address,folio_no)) %>% 
      set_names(1:ln) %>% as_data_frame()  %>% 
      gather(line_number, string_presence , 1:ln  ) %>%
      bind_cols(data_frame(information_type = rep_len(c("pan_no","email_address",
                                            "folio_no"), ln*3)))
  })# end reactive
  
  
  # exclusion of false positives
  df <- reactive({
    ln <- length(text_data()$X1)
      
    # pan number - exclusion of false positives
    text_data()$X1 %>% str_replace_all("(?<=For example).{1,}[[A-Z]]{5}[[:digit:]]{4}[[A-Z]]{1}", "") %>%
      map(str_detect ,pattern = c(pan_no,email_address,folio_no)) %>% 
      set_names(1:ln) %>% as_data_frame()  %>% 
      gather(line_number, string_presence , 1:ln  ) %>%
      bind_cols(data_frame(information_type = rep_len(c("pan_no","email_address",
                                                  "folio_no"), ln*3)))
  })
  
  
 
  # the outputs, table showing the data etc.
  output$textData <- renderTable({
    if(is.null(text_data())){return ()}
    text_data()
  })
  
  
  # output 2, the plot with the string detection results
  output$ggplot <- renderPlot({
    (
      df() %>% filter(string_presence == TRUE) %>%
        ggplot(., aes(information_type)) +
        geom_bar(aes(fill = line_number))
    
      )# end ggplot
    
  })# end renderPlot
  
  # the dynamic UI
  output$tb <- renderUI({
    
    # check if the file has been uploaded, if not display the image, 
    # otherwise display the data
    if(is.null(text_data())){
      h5("Powered by", tags$img(src='rstudio-stringr.png', heigth=600, width=600))
      }else{
      tabsetPanel(tabPanel("Data", tableOutput("textData")),
                  tabPanel("Plot", plotOutput("ggplot")))}
    
  })
  
  
})
