## Server code for Grid-Driven Vehicle Emissions Shiny project
#Loading required R packages
library(dplyr)
library("readxl")
library(factoextra)
library(shiny)
library(shinydashboard)

## COEFFICENT LOOKUP ###################################################
# bring in the reference file of electric grid CO2 coefficients vs. ZIP codes
zipcoeff = read.csv(file="zip_coefficients.csv")

# create a lookup function to reference the coefficient file
# input zip code, get back a coefficient in mt CO2 / MWh
coefflookup <- function(zipcode) {
  
  ziprow <- zipcoeff %>%
    filter(zip == zipcode)
  
  cf = ziprow$Coefficient
  
  return(cf)
}

# load the file containing zip codes, electricity and gas prices
power_gas_prices = read.csv(file="zip_code_gas_electricity.csv")

# function that can be called from UI at runtime
powerpricelookup <- function(zipcode, type = "MPG") {
  
  # some code to look at the table above
  #   and return electric cost $/kWh OR gas cost $/gal
  #   depending on vehicle type and ZIP code
  #   -- see section 8.5 above for an example
  #   type will be either "MPG" or "MPKWh"
  
  if (type == "MPG") {
    return(power_gas_prices[power_gas_prices$zip == zipcode,"Gas_cost"])
  }
  else {
    return(power_gas_prices[power_gas_prices$zip == zipcode,"Elect_cost"])
  }
}

# bring in the vehicle data
vehicles <- read_excel("Vehicles_data.xlsx", sheet = "Data_converted")
vehicles$List_Price = round(vehicles$List_Price,0)

# select desired columns
veh_disp <- vehicles %>%
  select(VehicleType,Make,Model,Powertrain,List_Price,FE_City,FE_Highway,FE_Unit)

# store gasoline-to-CO2 coefficient for reference (constant)
gasoline_coeff = 0.008887  # 8.887 kg CO2/gallon, converted to metric tons

## RSHINY SERVER CODE ###############################################
# Define server logic to summarize and view selected dataset ----
vehicle_finder_server <- function(input, output) {
  
  # Build the dataset for EV vehicles based on inputs
  datasetEV <- reactive({
    req(input$vehType)
    req((input$chargerAccess == "Yes" | input$weeklyMiles < 300) & input$freqRoadTrips=="Rarely")
    req(input$zipCode %in% zipcoeff$zip)
    req(input$hwyMiles)
    filter(veh_disp, VehicleType %in% input$vehType) %>%
      filter(FE_Unit == "MPKWh") %>%
      #filter(List_Price <= input$maxPrice) %>%
      mutate(WeeklyCost = input$weeklyMiles / (FE_City * (1- input$hwyMiles/100) + FE_Highway * input$hwyMiles/100)
             * powerpricelookup(as.numeric(input$zipCode),"MPKWh")) %>%
      mutate(WeeklyCO2_kg =  input$weeklyMiles / (FE_City * (1- input$hwyMiles/100) + FE_Highway * input$hwyMiles/100)
             * coefflookup(as.numeric(input$zipCode))) %>%
      arrange(WeeklyCO2_kg)
  })
  
  # Build the dataset for ICE vehicles based on inputs
  datasetICE <- reactive({
    req(input$vehType)
    req(input$chargerAccess)
    req(input$zipCode %in% zipcoeff$zip)
    req(input$hwyMiles)    
    filter(veh_disp, VehicleType %in% input$vehType) %>%
      filter(FE_Unit == "MPG") %>%
      #filter(List_Price <= input$maxPrice) %>%      
      mutate(WeeklyCost = input$weeklyMiles / (FE_City * (1- input$hwyMiles/100) + FE_Highway * input$hwyMiles/100)
             * powerpricelookup(as.numeric(input$zipCode),"MPG")) %>%
      mutate(WeeklyCO2_kg =  input$weeklyMiles / (FE_City * (1- input$hwyMiles/100) + FE_Highway * input$hwyMiles/100)
             * gasoline_coeff * 1000) %>%
      arrange(WeeklyCO2_kg)
  })
  
  # Extract min/max price data from the input selections
  maxprice <- reactive({
    req(input$priceRange)
    as.numeric(input$priceRange[2]*1000)
  })
  minprice <- reactive({
    req(input$priceRange)
    as.numeric(input$priceRange[1]*1000)
  })
  
  # Build output table the first "n" EV vehicles within the price range
  #   using the reactive dataset from above -- 
  #   note that the calling format is tablename()$fieldname for reactive tables, parens are important
  output$EVlist <- renderTable({
    head(datasetEV()[datasetEV()$List_Price<=maxprice() & datasetEV()$List_Price>=minprice(),],n=input$nCars)
  })
  
  # Show the first "n" ICE vehicles within the price range
  output$ICElist <- renderTable({
    head(datasetICE()[datasetICE()$List_Price<=maxprice() & datasetICE()$List_Price>=minprice(),],n=input$nCars)
  })
  
  # lookup local prices and coefficient based on input zip code
  # - electricity price
  powerprice <- reactive({
    req(input$zipCode)
    powerpricelookup(as.numeric(input$zipCode),"MPKWh")
  })
  
  # - gasoline price
  fuelprice <- reactive({
    req(input$zipCode)
    powerpricelookup(as.numeric(input$zipCode),"MPG")
  })
  
  # - electric grid CO2 coefficient  
  powercoeff <- reactive({
    req(input$zipCode)
    coefflookup(as.numeric(input$zipCode))
  })
  
  # define output boxes for local prices and coefficient
  output$fuelbox <- renderValueBox({
    valueBox(paste("$",fuelprice(),"/gal"),"Fuel Cost", color = "yellow")
  })
  output$powerbox <- renderValueBox({
    valueBox(paste("$",powerprice(),"/kWh"),"Power Cost", color = "green")
  })
  output$coeffbox <- renderValueBox({
    valueBox(paste(powercoeff(),"kg CO2/kWh"),"Local Grid Emissions", color = "black")
  })
  
  
  # build out a file of power mix by ZIP code, then we can display that too
  #  output$powermix <- renderTable({
  #    get_my_power_mix something something need to create the export file first
  #  })
  
}