server <- function(input, output, session) {
  
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
  
  # Reactive values to store custom patterns
  custom_patterns <- reactiveValues(
    email = list(),
    phone = list(),
    url = list()
  )
  
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
  extract_data <- function(data, patterns, columns = NULL) {
    extracted <- c()
    
    for (pattern in patterns) {
      if (is.data.frame(data) && !is.null(columns)) {
        for (col_name in columns) {
          column_data <- na.omit(as.character(data[[col_name]]))
          for (entry in column_data) {
            extracted <- c(extracted, str_extract_all(entry, pattern)[[1]])
          }
        }
      } else if (is.character(data)) {
        extracted <- c(extracted, unlist(regmatches(data, gregexpr(pattern, data))))
      }
    }
    
    unique(extracted)
  }
  
  # Default patterns
  email_pattern <- "\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}\\b"
  phone_pattern <- "\\b\\d{3}[-.]?\\d{3}[-.]?\\d{4}\\b"
  url_pattern <- "https?://(?:www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b(?:[-a-zA-Z0-9()@:%_\\+.~#?&//=]*)"
  
  # Function to validate emails
  validate_email <- function(email) {
    grepl("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", email)
  }
  
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
    
    file_type <- input$file_type
    file_ext <- tolower(tools::file_ext(input$file$name))
    
    expected_ext <- switch(file_type,
                           "CSV" = "csv",
                           "XLSX" = "xlsx",
                           "TXT" = "txt")
    
    if (file_ext != expected_ext) {
      showModal(modalDialog(
        title = "Error",
        "The file extension does not match the selected file type. Please select the correct file type or upload a file with the correct extension.",
        easyClose = TRUE
      ))
      return()
    }
    
    data <- read_file(input$file, file_type)
    
    if (is.null(data)) return()
    
    if (file_type %in% c("CSV", "XLSX")) {
      output$checkbox_group <- renderUI({
        checkboxGroupInput("columns", "Select columns:", choices = names(data))
      })
    }
    
    observe({
      req(input$extract_types)
      extracted_data <- list()
      
      if ("Emails" %in% input$extract_types) {
        email_patterns <- if (input$use_custom_email_pattern) 
          c(custom_patterns$email, input$email_pattern) 
        else 
          email_pattern
        emails <- extract_data(data, email_patterns, if (file_type %in% c("CSV", "XLSX")) input$columns else NULL)
        if (input$validate_email) {
          emails <- emails[sapply(emails, validate_email)]
        }
        extracted_data$Emails <- emails
      }
      
      if ("Phone Numbers" %in% input$extract_types) {
        phone_patterns <- if (input$use_custom_phone_pattern) 
          c(custom_patterns$phone, input$phone_pattern) 
        else 
          phone_pattern
        phones <- extract_data(data, phone_patterns, if (file_type %in% c("CSV", "XLSX")) input$columns else NULL)
        phones <- sapply(phones, format_phone, format = input$phone_format)
        extracted_data$`Phone Numbers` <- phones
      }
      
      if ("URLs" %in% input$extract_types) {
        url_patterns <- if (input$use_custom_url_pattern) 
          c(custom_patterns$url, input$url_pattern) 
        else 
          url_pattern
        urls <- extract_data(data, url_patterns, if (file_type %in% c("CSV", "XLSX")) input$columns else NULL)
        if (input$validate_url) {
          urls <- urls[sapply(urls, validate_url)]
        }
        extracted_data$URLs <- urls
      }
      
      originalFileContent(extracted_data)
      
      output$contents <- renderDT({
        datatable(do.call(rbind, lapply(names(extracted_data), function(name) {
          data.frame(Type = name, Content = extracted_data[[name]])
        })))
      })
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