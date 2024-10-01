library(shiny)
library(shinythemes)
library(shinyWidgets)
library(DT)
ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  
  titlePanel("Data Extractor"),
  uiOutput("bodyClasses"),
  sidebarLayout(
    sidebarPanel(
      materialSwitch("dark", "Dark Mode", status = "primary"),
      
      pickerInput(
        inputId = "file_type",
        label = "Choose File Type:",
        choices = c("CSV", "XLSX", "TXT"),
        options = list(`style` = "btn-primary")
      ),
      
      fileInput("file", "Choose a File", accept = c("text/csv", "text/xlsx", 'text/txt', ".csv", ".xlsx", ".txt")),
      
      conditionalPanel(
        condition = "input.file_type == 'CSV'",
        pickerInput(
          inputId = "csv_sep",
          label = "CSV Separator:",
          choices = c("Comma" = ",", "Semicolon" = ";", "Tab" = "\t", "Space" = " ", "Other" = "Other"),
          options = list(`style` = "btn-info")
        ),
        conditionalPanel(
          condition = "input.csv_sep == 'Other'",
          textInput('csv_other', 'Other Separator:', ',')
        )
      ),
      
      conditionalPanel(
        condition = "input.file_type == 'XLSX'",
        numericInput("excel_sheet", "Excel Sheet Number:", 1)
      ),
      
      helpText("Please select the file type first, then upload your file."),
      
      pickerInput(
        inputId = "extract_types",
        label = "Choose Extract Types:",
        choices = c("Emails", "Phone Numbers", "URLs"),
        multiple = TRUE,
        options = list(`actions-box` = TRUE)
      ),
      
      conditionalPanel(
        condition = "input.extract_types.includes('Emails')",
        prettyCheckbox(
          inputId = "use_custom_email_pattern",
          label = "Use custom email pattern?",
          value = FALSE,
          status = "primary",
          animation = "smooth"
        ),
        conditionalPanel(
          condition = "input.use_custom_email_pattern",
          textInput("email_pattern", "Email Pattern:", 
                    value = "\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}\\b"),
          actionButton("add_email_pattern", "Add Another Pattern", icon = icon("plus"))
        ),
        prettyCheckbox(
          inputId = "validate_email",
          label = "Validate Emails",
          value = TRUE,
          status = "info",
          animation = "smooth"
        )
      ),
      
      conditionalPanel(
        condition = "input.extract_types.includes('Phone Numbers')",
        prettyCheckbox(
          inputId = "use_custom_phone_pattern",
          label = "Use custom phone pattern?",
          value = FALSE,
          status = "primary",
          animation = "smooth"
        ),
        conditionalPanel(
          condition = "input.use_custom_phone_pattern",
          textInput("phone_pattern", "Phone Pattern:", 
                    value = "\\b\\d{3}[-.]?\\d{3}[-.]?\\d{4}\\b"),
          actionButton("add_phone_pattern", "Add Another Pattern", icon = icon("plus"))
        ),
        pickerInput(
          inputId = "phone_format",
          label = "Phone Format:",
          choices = c("Keep Original", "XXX-XXX-XXXX", "(XXX) XXX-XXXX"),
          options = list(`style` = "btn-primary")
        )
      ),
      
      conditionalPanel(
        condition = "input.extract_types.includes('URLs')",
        prettyCheckbox(
          inputId = "use_custom_url_pattern",
          label = "Use custom URL pattern?",
          value = FALSE,
          status = "primary",
          animation = "smooth"
        ),
        conditionalPanel(
          condition = "input.use_custom_url_pattern",
          textInput("url_pattern", "URL Pattern:", 
                    value = "https?://(?:www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b(?:[-a-zA-Z0-9()@:%_\\+.~#?&//=]*)"),
          actionButton("add_url_pattern", "Add Another Pattern", icon = icon("plus"))
        ),
        prettyCheckbox(
          inputId = "validate_url",
          label = "Validate URLs",
          value = TRUE,
          status = "info",
          animation = "smooth"
        )
      ),
      

      
      uiOutput("checkbox_group"), 
      downloadButton("Download", "Download xlsx", icon = icon("file-excel"), class = 'btn-success'),
      downloadButton("Download2", "Download txt", icon = icon("file-alt"), class = 'btn-info')
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Extracted Data", DTOutput("contents")),
        tabPanel("Tutorial", 
                 h2("Tutorial:"),
                 p("This app is designed to extract emails, phone numbers, and/or URLs from different file types."),
                 p("1. Select one or more extraction types (Emails, Phone Numbers, URLs)."),
                 p("2. For each selected type, choose whether to use a custom pattern or the default one."),
                 p("3. If using a custom pattern, enter it in the text box. You can add multiple patterns if needed."),
                 p("4. Choose the file type (CSV, XLSX, or TXT)."),
                 p("5. Upload your file."),
                 p("6. If you chose CSV, select the appropriate separator."),
                 p("7. If you chose XLSX, input the correct sheet number."),
                 p("8. Use the checkboxes to select which columns to process (if applicable)."),
                 p("9. The extracted data will be displayed in the 'Extracted Data' tab."),
                 p("10. Download the extracted data in xlsx or txt format using the download buttons.")
        )
      )
    )
  )
)