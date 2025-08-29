# Data Extraction Module
# Handles the core data extraction logic with async processing and progress indication

data_extraction_ui <- function(id) {
  ns <- NS(id)
  # This module is primarily server-side, but we can add progress indicators here if needed
  uiOutput(ns("extraction_status"))
}

data_extraction_server <- function(id, file_inputs) {
  moduleServer(id, function(input, output, session) {
    
    # Reactive values for extracted data
    extractedData <- reactiveVal(list(emails = character(0), phones = character(0), urls = character(0)))
    extractionInProgress <- reactiveVal(FALSE)
    
    # Enhanced extraction functions with chunked processing for large files
    extract_data_chunked <- function(text_data, extract_types, chunk_size = 10000) {
      emails <- character(0)
      phones <- character(0)
      urls <- character(0)
      
      # Process in chunks for large datasets
      if (length(text_data) > chunk_size) {
        total_chunks <- ceiling(length(text_data) / chunk_size)
        
        for (i in seq(1, length(text_data), by = chunk_size)) {
          end_idx <- min(i + chunk_size - 1, length(text_data))
          chunk <- text_data[i:end_idx]
          
          # Update progress
          progress_val <- i / length(text_data)
          
          if ("Emails" %in% extract_types) {
            chunk_emails <- extract_emails(chunk)
            emails <- c(emails, chunk_emails)
          }
          if ("Phone Numbers" %in% extract_types) {
            chunk_phones <- extract_phone_numbers(chunk)
            phones <- c(phones, chunk_phones)
          }
          if ("URLs" %in% extract_types) {
            chunk_urls <- extract_urls(chunk)
            urls <- c(urls, chunk_urls)
          }
        }
      } else {
        # Process normally for smaller datasets
        if ("Emails" %in% extract_types) emails <- extract_emails(text_data)
        if ("Phone Numbers" %in% extract_types) phones <- extract_phone_numbers(text_data)
        if ("URLs" %in% extract_types) urls <- extract_urls(text_data)
      }
      
      # Remove duplicates and empty values
      emails <- unique(emails[emails != ""])
      phones <- unique(phones[phones != ""])
      urls <- unique(urls[urls != ""])
      
      return(list(emails = emails, phones = phones, urls = urls))
    }
    
    # Main extraction logic with progress indication
    observeEvent({
      file_inputs$file()
      file_inputs$selected_columns()
      file_inputs$extract_types()
    }, {
      req(file_inputs$file())
      req(file_inputs$extract_types())
      
      # Skip if file status indicates an error
      if (!is.null(file_inputs$file_status()) && file_inputs$file_status()$type == "error") {
        return()
      }
      
      extractionInProgress(TRUE)
      
      # Use withProgress for user feedback
      withProgress(message = 'Extracting data...', value = 0, {
        
        tryCatch({
          data <- file_inputs$loaded_data()
          
          # Prepare text data based on file type and selected columns
          if (is.data.frame(data)) {
            selected <- file_inputs$selected_columns()
            if (is.null(selected) || length(selected) == 0) {
              text_data <- character(0)
            } else {
              incProgress(0.2, detail = "Processing selected columns...")
              text_data <- unlist(data[selected], use.names = FALSE)
            }
          } else {
            incProgress(0.2, detail = "Processing text data...")
            text_data <- as.character(data)
          }
          
          incProgress(0.3, detail = "Extracting patterns...")
          
          # Extract data with chunked processing
          extracted <- extract_data_chunked(text_data, file_inputs$extract_types())
          
          incProgress(0.8, detail = "Finalizing results...")
          
          # Normalize lengths for display
          max_length <- max(length(extracted$emails), length(extracted$phones), length(extracted$urls))
          if (max_length == 0) max_length <- 1
          
          extracted$emails <- c(extracted$emails, rep("", max_length - length(extracted$emails)))
          extracted$phones <- c(extracted$phones, rep("", max_length - length(extracted$phones)))
          extracted$urls <- c(extracted$urls, rep("", max_length - length(extracted$urls)))
          
          extractedData(extracted)
          
          incProgress(1, detail = "Complete!")
          
        }, error = function(e) {
          showNotification(paste("Error during extraction:", e$message), type = "error", duration = 10)
          extractedData(list(emails = character(0), phones = character(0), urls = character(0)))
        })
        
        extractionInProgress(FALSE)
      })
      
    }, ignoreInit = TRUE)
    
    # Render extraction status
    output$extraction_status <- renderUI({
      if (extractionInProgress()) {
        div(class = "alert alert-info", 
            tags$i(class = "fa fa-spinner fa-spin"), 
            "Extracting data...")
      } else {
        NULL
      }
    })
    
    # Return the extracted data
    return(list(
      extracted_data = extractedData,
      extraction_in_progress = extractionInProgress
    ))
  })
}
