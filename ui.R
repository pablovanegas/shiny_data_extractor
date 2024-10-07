library(shiny)
library(shinythemes)
library(shinyWidgets)
library(DT)

ui <- fluidPage(
  theme = shinytheme("cosmo"),  # Using the 'cosmo' theme for a modern look
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  
  titlePanel(
    h1("Data Extractor", style = "font-family: 'Yusei Magic', sans-serif; color: #2c3e50;")
  ),
  uiOutput("bodyClasses"),
  
  sidebarLayout(
    sidebarPanel(
      materialSwitch("dark", "Dark Mode", status = "primary"),
      br(),
      
      pickerInput(
        inputId = "extract_types",
        label = "Choose Extract Types:",
        choices = c("Emails", "Phone Numbers", "URLs"),
        multiple = TRUE,
        options = list('actions-box' = TRUE)
      ),
      br(),
      
      pickerInput(
        inputId = "file_type",
        label = "Choose File Type:",
        choices = c("CSV", "XLSX", "TXT"),
        options = list(style = "btn-primary")
      ),
      br(),
      
      fileInput("file", "Choose a File", accept = c("text/csv", "text/xlsx", 'text/txt', ".csv", ".xlsx", ".txt")),
      br(),
      
      conditionalPanel(
        condition = "input.file_type == 'CSV'",
        pickerInput(
          inputId = "csv_sep",
          label = "CSV Separator:",
          choices = c("Comma" = ",", "Semicolon" = ";", "Tab" = "\t", "Space" = " ", "Other" = "Other"),
          options = list(style = "btn-info")
        ),
        conditionalPanel(
          condition = "input.csv_sep == 'Other'",
          textInput('csv_other', 'Other Separator:', ',')
        ),
        br()
      ),
      
      conditionalPanel(
        condition = "input.file_type == 'XLSX'",
        numericInput("excel_sheet", "Excel Sheet Number:", 1),
        br()
      ),
      
      helpText("Please select the file type first, then upload your file."),
      br(),
      

      
      uiOutput("checkbox_group"),
      br(), 
      
      downloadButton("Download", "Download xlsx", icon = icon("file-excel"), class = 'btn-success'),
      br(),
      downloadButton("Download2", "Download txt", icon = icon("file-alt"), class = 'btn-info')
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Extracted Data", DTOutput("contents")),
        tabPanel("Tutorial", 
                 h2("Tutorial:"),
                 p("This app is designed to extract emails, phone numbers, and/or URLs from different file types."),
                 p("1. Select one or more extraction types (Emails, Phone Numbers, URLs)."),
                 p("2. Choose the file type (CSV, XLSX, or TXT)."),
                 p("3. Upload your file."),
                 p("4. If you chose CSV, select the appropriate separator."),
                 p("5. If you chose XLSX, input the correct sheet number."),
                 p("6. Use the checkboxes to select which columns to process (if applicable)."),
                 p("7. The extracted data will be displayed in the 'Extracted Data' tab."),
                 p("8. Download the extracted data in xlsx or txt format using the download buttons.")
        )
      )
    )
  )
)
