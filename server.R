library(shiny)
library(readxl)
library(stringr)
library(openxlsx)  
library(shinythemes)
server <- function(input, output, session) {
  
  # Dark mode function
  output$bodyClasses <- renderUI({
    if (input$dark) {
      tags$script("document.body.classList.add('dark-mode');")
    } else {
      tags$script("document.body.classList.remove('dark-mode');")
    }
  })
  #----------------------------------------------------------------------#
  
  # Funciones 
  
  extraer_correos <- function(data, email_pattern) {
    correos <- c()
    for (entry in data) {
      correos_found <- str_extract_all(entry, email_pattern)[[1]]
      correos <- unique(c(correos, correos_found))
    }
    return(correos)
  }
  
  extraer_numeros <- function(data, phone_pattern) {
    numeros <- c()
    for (entry in data) {
      numeros_found <- str_extract_all(entry, phone_pattern)[[1]]
      numeros <- unique(c(numeros, numeros_found))
    }
    return(numeros)
  }
  
  extraer_urls <- function(data, url_pattern) {
    urls <- c()
    for (entry in data) {
      urls_found <- str_extract_all(entry, url_pattern)[[1]]
      urls <- unique(c(urls, urls_found))
    }
    return(urls)
  }
  
  #---------------------------------------------------------------------#
  
  # Reactivos
  
  # Store the original file content
  originalFileContent <- reactiveVal(NULL)
  
  # Reactive values to store custom patterns
  custom_patterns <- reactiveValues(
    email = list(),
    phone = list(),
    url = list()
  )
  
  #---------------------------------------------------------------------#
  
  
  # Function to read file based on type
  read_file <- function(file, file_type) {
    tryCatch({
      switch(file_type,
             "CSV" = {
               sep <- if (input$csv_sep != "Other") input$csv_sep else input$csv_other
               read.csv(file$datapath, sep = sep)
             },
             "XLSX" = {
               read_xlsx(file$datapath, sheet = input$excel_sheet)
             },
             "TXT" = {
               readLines(file$datapath)
             }
      )
    },
    error = function(e) {
      showModal(modalDialog(
        title = "Error",
        "The file could not be read. Please verify that the file is valid and the selected file type is correct.",
        easyClose = TRUE
      ))
      return(NULL)
    })
  }
  
  # Function to extract data based on multiple patterns
  extract_data <- function(data, patterns) {
    extracted <- list()
    
    for (pattern in patterns) {
      matches <- stringr::str_extract_all(data, pattern, vectorize = TRUE)
      extracted[[pattern]] <- unlist(matches)
    }
    
    extracted
  }

  
  # Default patterns
  email_pattern <- "\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}\\b"
  phone_pattern <- "\\b\\d{3}[-.]?\\d{3}[-.]?\\d{4}\\b"
  url_pattern <- "https?://(?:www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b(?:[-a-zA-Z0-9()@:%_\\+.~#?&//=]*)"
  

  # Function to validate URLs
  validate_url <- function(url) {
    grepl("^(http|https)://[a-z0-9]+([-.]{1}[a-z0-9]+)*\\.[a-z]{2,5}(:[0-9]{1,5})?(/.*)?$", url)
  }
  
  # Function to format phone numbers
  format_phone <- function(phone, format) {
    digits <- gsub("\\D", "", phone)
    switch(format,
           "Keep Original" = phone,
           "XXX-XXX-XXXX" = paste0(substr(digits, 1, 3), "-", substr(digits, 4, 6), "-", substr(digits, 7, 10)),
           "(XXX) XXX-XXXX" = paste0("(", substr(digits, 1, 3), ") ", substr(digits, 4, 6), "-", substr(digits, 7, 10))
    )
  }
  
  # Observers for adding custom patterns
  observeEvent(input$add_email_pattern, {
    if (input$email_pattern != "") {
      custom_patterns$email <- c(custom_patterns$email, input$email_pattern)
    }
  })
  
  observeEvent(input$add_phone_pattern, {
    if (input$phone_pattern != "") {
      custom_patterns$phone <- c(custom_patterns$phone, input$phone_pattern)
    }
  })
  
  observeEvent(input$add_url_pattern, {
    if (input$url_pattern != "") {
      custom_patterns$url <- c(custom_patterns$url, input$url_pattern)
    }
  })
  
  # File upload and processing
  observeEvent(input$file, {
    req(input$file)
    
    file_type <- switch(input$file_type,
                        "CSV" = "csv",
                        "XLSX" = "xlsx",
                        "TXT" = 'txt')
    
    data_sheet <- tryCatch(
      switch(file_type,
             "csv" = {
               sep <- if (input$csv_sep!= "Other") input$csv_sep else input$csv_other
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
    
    if (tolower(file_ext)!= tolower(input$file_type)) {
      showModal(modalDialog(
        title = "Error",
        "The file extension does not match the selected file type. Please select the correct file type or upload a file with the correct extension.",
        easyClose = TRUE
      ))
      return()
    }
    
    email_pattern <- "([_a-z0-9-]+(?:\\.[_a-z0-9-]+)*@[a-z0-9-]+(?:\\.[a-z0-9-]+)*(?:\\.[a-z]{2,63}))"
    phone_pattern <- "\\d{3}[-.]?\\d{3}[-.]?\\d{4}"
    url_pattern <- "https?://(?:www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b(?:[-a-zA-Z0-9()@:%_\\+.~#?&//=]*)"
    
    correos <- extraer_correos(data_sheet, email_pattern)
    numeros <- extraer_numeros(data_sheet, phone_pattern)
    urls <- extraer_urls(data_sheet, url_pattern)
    
    originalFileContent(correos)
    originalFileContent(numeros)
    originalFileContent(urls)
    
    output$contents <- renderTable({
      data.frame(Content = originalFileContent())
    })
  })
  
  # Download handlers
  output$Download <- downloadHandler(
    filename = function() {
      paste0(tools::file_path_sans_ext(input$file$name), "_extracted_data.xlsx")
    },
    content = function(file) {
      write.xlsx(originalFileContent(), file)
    }
  )
  
  output$Download2 <- downloadHandler(
    filename = function() {
      paste0(tools::file_path_sans_ext(input$file$name), "_extracted_data.txt")
    },
    content = function(file) {
      writeLines(unlist(lapply(names(originalFileContent()), function(name) {
        c(paste0(name, ":"), originalFileContent()[[name]], "")
      })), file)
    }
  )
  
  
  # shinyjs to show/hide custom patterns
  observeEvent(input$use_custom_email_pattern, {
    if (input$use_custom_email_pattern) {
      shinyjs::show("email_pattern")
      shinyjs::show("add_email_pattern")
    } else {
      shinyjs::hide("email_pattern")
      shinyjs::hide("add_email_pattern")
    }
  })
  
  
}