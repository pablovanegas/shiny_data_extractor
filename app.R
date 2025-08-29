# Data Extractor App Launcher
# This script launches the Shiny Data Extractor application
# 
# Usage: 
#   - Open R/RStudio
#   - Set working directory to this folder
#   - Run: source("app.R")
#   - Or simply: shiny::runApp()

# Load required libraries
if (!require("shiny")) {
  install.packages("shiny")
  library(shiny)
}

if (!require("DT")) {
  install.packages("DT")
  library(DT)
}

if (!require("shinythemes")) {
  install.packages("shinythemes")
  library(shinythemes)
}

if (!require("shinyWidgets")) {
  install.packages("shinyWidgets")
  library(shinyWidgets)
}

if (!require("readxl")) {
  install.packages("readxl")
  library(readxl)
}

if (!require("openxlsx")) {
  install.packages("openxlsx")
  library(openxlsx)
}

if (!require("stringr")) {
  install.packages("stringr")
  library(stringr)
}

# Optional packages for async processing (install if needed for large files)
if (!require("promises")) {
  message("Installing 'promises' package for async processing...")
  install.packages("promises")
}

if (!require("future")) {
  message("Installing 'future' package for async processing...")
  install.packages("future")
}

# Source the application files
source("global.R")
source("ui.R")
source("server.R")

# Launch the application
cat("Launching Shiny Data Extractor...\n")
cat("The app will open in your default web browser.\n")
cat("To stop the app, press Ctrl+C or Esc in the R console.\n\n")

shinyApp(ui = ui, server = server)
