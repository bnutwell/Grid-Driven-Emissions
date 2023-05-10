### UI For Grid-Driven Vehicle Emissions analysis tool
#Loading required R packages
library(dplyr)
library(factoextra)
library(shiny)
library(shinydashboard)


# Define UI for dataset viewer app ----
vehicle_finder_ui <- fluidPage(
  
  # App title ----
  titlePanel("My Driving Needs"),
  
  # Sidebar layout with a input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      # Input: Selector for filtering vehicle types ----
      selectInput(inputId = "vehType",
                  label = "I'm looking for a:",
                  choices = c("Sedan", "SUV", "Pickup","Hatchback"),
                  selected = "Sedan"),
      
      # Input: Slider for price range    
      sliderInput("priceRange", 
                  label = "Price Range K$:",
                  min = 20, max = 150, value = c(20,55),
                  step = 5, round = TRUE, pre = "$",
                  animate = FALSE),
      
      # Input: Selector for access to a charger
      selectInput("chargerAccess", 
                  label = "I have access to an EV charger",
                  choices = list("Yes", 
                                 "No"),
                  selected = "Yes"),    
      
      # Input: Selector for frequency of long trips
      selectInput("freqRoadTrips", 
                  label = "Frequency of trips >300 miles",
                  choices = list("Rarely", 
                                 "Monthly",
                                 "Weekly"),
                  selected = "Rarely"),    
      
      # Input: Slider for typical weekly miles driven
      sliderInput("weeklyMiles", 
                  label = "Weekly Miles Driven:",
                  min = 50, max = 950, value = 250,
                  step = 25, round = TRUE,
                  animate = FALSE),
      
      # Input: Slider for % highway mileage
      sliderInput("hwyMiles", 
                  label = "% of miles on Highway:",
                  min = 0, max = 100, value = 50,
                  step = 25, round = TRUE,
                  animate = FALSE),
      
      # Input: Numeric entry for user zip code
      numericInput(inputId = "zipCode",
                   label = "My local ZIP code:",
                   value = 30312),      
      
      # Input: Numeric entry for number of vehicles to show
      numericInput(inputId = "nCars",
                   label = "Number of cars to show:",
                   value = 5),      
      
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # show relevant local values in boxes at top      
      fluidRow(
        valueBoxOutput("fuelbox"),
        valueBoxOutput("powerbox"),
        valueBoxOutput("coeffbox")
      ),
      
      # display an image, not sure why this doesn't work so commenting it out
      #img(src = "Eco_car_image2.png", height = 181, width = 400),
      
      # Output: HTML tables with requested number of observations ----
      tableOutput("EVlist"),
      tableOutput("ICElist")
      
    )
  )
)