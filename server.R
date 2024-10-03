library(shiny)
library(readxl)
library(stringr)
library(openxlsx)  
library(shinythemes)


extract_phone_numbers <- function(file, pattern) {
  # Read the file into a character vector
  text <- readLines(file, encoding = "UTF-8")
  
  # Use regular expressions to extract phone numbers
  phone_numbers <- str_extract_all(text, pattern)
  
  # Return the extracted phone numbers as a character vector
  unlist(phone_numbers)
}

format_phone_numbers <- function(phone_numbers, format) {
  if (format == "XXX-XXX-XXXX") {
    phone_numbers <- gsub("\\b(\\d{3})(\\d{3})(\\d{4})\\b", "\\1-\\2-\\3", phone_numbers)
  } else if (format == "(XXX) XXX-XXXX") {
    phone_numbers <- gsub("\\b(\\d{3})(\\d{3})(\\d{4})\\b", "(\\1) \\2-\\3", phone_numbers)
  }
  phone_numbers
}



server <- function(input, output) {
  
  
  # Dark mode function
  output$bodyClasses <- renderUI({
    if (input$dark) {
      tags$script("document.body.classList.add('dark-mode');")
    } else {
      tags$script("document.body.classList.remove('dark-mode');")
    }
  })
  
  #----------------------------------------------------------------------
  
  # FUNCIONES DE LECTURA 
  
  
  #Store the original file content
  originalFileContent <- reactiveVal(NULL)
  
  observeEvent(input$file, {
    req(input$file) # Read the file content
    
    file_type <- switch(input$file_type,
                        "CSV" = "csv",
                        "XLSX" = "xlsx",
                        "TXT" = 'txt')
    
    data_sheet <- tryCatch(
      switch(file_type,
             "csv" = {
               sep <- if (input$csv_sep != "Other") input$csv_sep else input$csv_other
               read.csv(input$file$datapath, sep = sep)
             },
             "xlsx" = {
               tryCatch(
                 read_xlsx(input$file$datapath, sheet = input$excel_sheet),
                 error = function(e) {
                   showModal(modalDialog(
                     title = "Error",
                     "La hoja de Excel especificada no existe en el archivo subido. Por favor, selecciona una hoja válida.",
                     easyClose = TRUE
                   ))
                   return(NULL)
                 }
               )
             },
             "txt" = {
               readLines(input$file$datapath)
             }
      ),
      error = function(e) {
        showModal(modalDialog(
          title = "Error",
          "El archivo no se pudo leer. Por favor, verifica que el archivo sea válido y que el tipo de archivo seleccionado sea correcto.",
          easyClose = TRUE
        ))
        return(NULL)
      }
    )
    
    file_ext <- tools::file_ext(input$file$name)
    
    if (tolower(file_ext) != tolower(input$file_type)) {
      showModal(modalDialog(
        title = "Error",
        "The file extension does not match the selected file type. Please select the correct file type or upload a file with the correct extension.",
        easyClose = TRUE
      ))
      return()
    }
    
    # Fin de la funciones de lectura
    #------------------------------------------------
    
    
    email_pattern <- "([_a-z0-9-]+(?:\\.[_a-z0-9-]+)*@[a-z0-9-]+(?:\\.[a-z0-9-]+)*(?:\\.[a-z]{2,63}))"
    phone_pattern <- "\\+?[0-9]{1,3}[-.\\s]?\\(?[0-9]{1,3}\\)?[-.\\s]?[0-9]{1,3}[-.\\s]?[0-9]{1,3}[-.\\s]?[0-9]{1,3}[-.\\s]?[0-9]{1,3}"
    ulr_pattern <- "https?://(?:[-\\w.]|(?:%[a-fA-F0-9]{2}))+"
    correos <- c()
    phones <- c()
    urls <- c()
    
    switch(file_type,
           "csv" = {
             data_sheet <- read.csv(input$file$datapath, sep = sep)
             
             #crete checkbox group
             output$checkbox_group <- renderUI({
               checkboxGroupInput("columns", "Select columns:", choices = names(data_sheet))
             })
             
             observeEvent(input$columns, {
               req(input$columns)
               correos <- c()
               phones <- c()
               for (col_name in input$columns) {
                 correos_raw <- na.omit(as.character(data_sheet[[col_name]]))
                 phones_raw <- na.omit(as.character(data_sheet[[col_name]]))
                 
                 for (entry in correos_raw) {
                   correos_found <- str_extract_all(entry, email_pattern)[[1]]
                   correos <- unique(c(correos, correos_found))
                 }
                 
                 for (entry in phones_raw) {
                   phones_found <- str_extract_all(entry, phone_pattern)[[1]]
                   phones <- unique(c(phones, phones_found))
                 }
               }
               originalFileContent(correos)
               output$contents <- renderTable({
                 data.frame(Content = originalFileContent())
               })
               if (length(phones) > 0) {
                 output$phone_contents <- renderTable({
                   data.frame(Content = phones)
                 })
               }
             })
           },
           "xlsx" = {
             data_sheet <- read_xlsx(input$file$datapath, sheet = input$excel_sheet)
             
             #crete checkbox group
             output$checkbox_group <- renderUI({
               checkboxGroupInput("columns", "Select columns:", choices = names(data_sheet))
             })
             
             observeEvent(input$columns, {
               req(input$columns)
               correos <- c()
               phones <- c()
               for (col_name in input$columns) {
                 correos_raw <- na.omit(as.character(data_sheet[[col_name]]))
                 phones_raw <- na.omit(as.character(data_sheet[[col_name]]))
                 
                 for (entry in correos_raw) {
                   correos_found <- str_extract_all(entry, email_pattern)[[1]]
                   correos <- unique(c(correos, correos_found))
                 }
                 
                 for (entry in phones_raw) {
                   phones_found <- str_extract_all(entry, phone_pattern)[[1]]
                   phones <- unique(c(phones, phones_found))
                 }
               }
               originalFileContent(correos)
               output$contents <- renderTable({
                 data.frame(Content = originalFileContent())
               })
               if (length(phones) > 0) {
                 output$phone_contents <- renderTable({
                   data.frame(Content = phones)
                 })
               }
             })
           },
           "txt" = {
             data_sheet <- readLines(input$file$datapath)
             emails <- unlist(regmatches(data_sheet, gregexpr(email_pattern, data_sheet)))
             phones <- unlist(regmatches(data_sheet, gregexpr(phone_pattern, data_sheet)))
             originalFileContent(unique(emails))
             output$contents <- renderTable({
               data.frame(Content = originalFileContent())
             })
             if (length(phones) > 0) {
               output$phone_contents <- renderTable({
                 data.frame(Content = phones)
               })
             }
           }
    )
    save_file <- function() {
      file.copy(input$file$datapath, "/home/juan/Desktop/shiny_email")
    }
    
    output$Download <- downloadHandler(
      filename = function() {
        paste(tools::file_path_sans_ext(input$file$name), "_datos", ".xlsx", sep = "")
      },
      content = function(file) {
        datos_df <- data.frame(
          Emails = as.character(originalFileContent()),
          Phones = as.character(phones)
        )
        write.xlsx(datos_df, file)
      }
    )
    
    output$Download2 <- downloadHandler(
      filename = function() {
        paste(tools::file_path_sans_ext(input$file$name), "_datos", ".txt", sep = "")
      },
      content = function(file) {
        datos <- c(originalFileContent(), phones)
        write.table(datos, file)
      }
    )
    
  }) # End of observeEvent of file upload
} # End of server function