server <- function(input, output) {
  # Dark mode function
  output$bodyClasses <- renderUI({
    if (input$dark) {
      tags$script("document.body.classList.add('dark-mode');")
    } else {
      tags$script("document.body.classList.remove('dark-mode');")
    }
  })
  
  # Store the original file content
  originalFileContent <- reactiveVal(NULL)
  phoneNumbers <- reactiveVal(NULL)
  
  observeEvent(input$file, {
    req(input$file) # Read the file content
    
    file_type <- switch(input$file_type,
                        "CSV" = "csv",
                        "XLSX" = "xlsx",
                        "TXT" = 'txt')
    
    data <- process_file(input$file$datapath, file_type, sep = if (input$csv_sep != "Other") input$csv_sep else input$csv_other, sheet = input$excel_sheet)
    
    if (file_type == "txt") {
      text_data <- data
    } else {
      text_data <- unlist(data)
    }
    
    emails <- extract_emails(text_data)
    phones <- extract_phone_numbers(text_data)
    
    originalFileContent(emails)
    phoneNumbers(phones)
    
    output$contents <- renderTable({
      data.frame(Emails = originalFileContent(), Phones = phoneNumbers())
    })
  })
  
  output$Download <- downloadHandler(
    filename = function() {
      paste(tools::file_path_sans_ext(input$file$name), "_datos", ".xlsx", sep = "")
    },
    content = function(file) {
      datos_df <- data.frame(
        Emails = as.character(originalFileContent()),
        Phones = as.character(phoneNumbers())
      )
      write.xlsx(datos_df, file)
    }
  )
  
  output$Download2 <- downloadHandler(
    filename = function() {
      paste(tools::file_path_sans_ext(input$file$name), "_datos", ".txt", sep = "")
    },
    content = function(file) {
      datos <- c(originalFileContent(), phoneNumbers())
      write.table(datos, file)
    }
  )
}
