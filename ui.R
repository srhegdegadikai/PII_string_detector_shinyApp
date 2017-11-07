#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("String detector"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      
      # file input to take in the text file
      fileInput("text_file","Upload the text"),
      helpText("Default max. file size is 50MB"),
      tags$hr(),
      h5(helpText("Select the read_delim parameters below")),
      br(),
      radioButtons(
        inputId = 'sep', label = "Seperator", 
        choices = c("Comma(,)" =',' ,"Semicolon(;)"=';' ,"Tab(\\t)"='\t', 
                      "Space"='', "NewLine(\\n)" = "\n"), 
        selected = '\n'
      )# end radioButtons
      
    ),# end sidebarPanel
    
    mainPanel(
      uiOutput("tb")
    )
    
    
    
  )# end sidebarLayout
))
