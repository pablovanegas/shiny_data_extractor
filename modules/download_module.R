# Download Module
# Contains the logic for download buttons and file export

download_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    div(class = "download-options",
      div(class = "download-header",
        p("Export your extracted data in your preferred format:", 
          style = "color: var(--text-secondary); margin-bottom: 1rem;")
      ),
      
      # Excel download with enhanced styling
      div(class = "download-option",
        downloadButton(
          ns("download_xlsx"), 
          label = tagList(
            tags$i(class = "fas fa-file-excel", style = "margin-right: 0.5rem;"),
            "Download Excel File"
          ),
          class = 'btn btn-success btn-lg download-btn',
          style = "width: 100%; margin-bottom: 1rem;"
        ),
        div(class = "download-description",
          tags$small(
            tags$i(class = "fas fa-info-circle", style = "margin-right: 0.25rem;"),
            "Excel format (.xlsx) - Best for data analysis and sharing",
            style = "color: var(--text-muted);"
          )
        )
      ),
      
      # Text download with enhanced styling  
      div(class = "download-option",
        downloadButton(
          ns("download_txt"), 
          label = tagList(
            tags$i(class = "fas fa-file-alt", style = "margin-right: 0.5rem;"),
            "Download Text File"
          ),
          class = 'btn btn-info btn-lg download-btn',
          style = "width: 100%; margin-bottom: 1rem;"
        ),
        div(class = "download-description",
          tags$small(
            tags$i(class = "fas fa-info-circle", style = "margin-right: 0.25rem;"),
            "Plain text format (.txt) - Simple list format",
            style = "color: var(--text-muted);"
          )
        )
      ),
      
      # CSV download option (new)
      div(class = "download-option",
        downloadButton(
          ns("download_csv"), 
          label = tagList(
            tags$i(class = "fas fa-file-csv", style = "margin-right: 0.5rem;"),
            "Download CSV File"
          ),
          class = 'btn btn-warning btn-lg download-btn',
          style = "width: 100%; margin-bottom: 1rem;"
        ),
        div(class = "download-description",
          tags$small(
            tags$i(class = "fas fa-info-circle", style = "margin-right: 0.25rem;"),
            "CSV format (.csv) - Compatible with most data tools",
            style = "color: var(--text-muted);"
          )
        )
      )
    ),
    
    # Download status indicator
    div(class = "download-status",
      uiOutput(ns("download_status"))
    )
  )
}

download_server <- function(id, extracted_data, original_filename) {
  moduleServer(id, function(input, output, session) {
    
    # Reactive value for download status
    download_status <- reactiveVal(NULL)
    
    # Helper function to get base filename
    get_base_filename <- function() {
      if (!is.null(original_filename()) && original_filename() != "") {
        tools::file_path_sans_ext(original_filename())
      } else {
        paste0("extracted_data_", format(Sys.time(), "%Y%m%d_%H%M%S"))
      }
    }
    
    # Enhanced Excel download handler
    output$download_xlsx <- downloadHandler(
      filename = function() {
        paste0(get_base_filename(), "_extracted.xlsx")
      },
      content = function(file) {
        data <- extracted_data()
        
        validate(
          need(!is.null(data), "No data available for download"),
          need(any(sapply(data, function(x) length(x) > 0 && any(x != ""))), "No extracted data to download")
        )
        
        download_status(list(type = "processing", message = "Preparing Excel file..."))
        
        tryCatch({
          # Create enhanced dataframe with metadata
          datos_df <- data.frame(
            `Email Addresses` = as.character(data$emails),
            `Phone Numbers` = as.character(data$phones),
            `URLs` = as.character(data$urls),
            stringsAsFactors = FALSE,
            check.names = FALSE
          )
          
          # Remove completely empty rows for export
          datos_df <- datos_df[rowSums(datos_df != "", na.rm = TRUE) > 0, ]
          
          # Create workbook with formatting
          wb <- createWorkbook()
          addWorksheet(wb, "Extracted Data")
          
          # Add title and metadata
          writeData(wb, 1, "Data Extraction Results", startCol = 1, startRow = 1)
          writeData(wb, 1, paste("Generated on:", Sys.time()), startCol = 1, startRow = 2)
          writeData(wb, 1, paste("Total records:", nrow(datos_df)), startCol = 1, startRow = 3)
          
          # Add data starting from row 5
          writeData(wb, 1, datos_df, startCol = 1, startRow = 5, headerStyle = createStyle(fontColour = "white", fgFill = "#3b82f6", textDecoration = "bold"))
          
          # Apply formatting
          addStyle(wb, 1, createStyle(fontSize = 16, textDecoration = "bold"), rows = 1, cols = 1)
          addStyle(wb, 1, createStyle(fontSize = 12, fontColour = "grey"), rows = 2:3, cols = 1)
          
          saveWorkbook(wb, file, overwrite = TRUE)
          
          download_status(list(type = "success", message = "Excel file downloaded successfully!"))
        }, error = function(e) {
          download_status(list(type = "error", message = paste("Error creating Excel file:", e$message)))
          showNotification(paste("Error creating Excel file:", e$message), type = "error")
        })
      }
    )
    
    # Enhanced CSV download handler
    output$download_csv <- downloadHandler(
      filename = function() {
        paste0(get_base_filename(), "_extracted.csv")
      },
      content = function(file) {
        data <- extracted_data()
        
        validate(
          need(!is.null(data), "No data available for download"),
          need(any(sapply(data, function(x) length(x) > 0 && any(x != ""))), "No extracted data to download")
        )
        
        download_status(list(type = "processing", message = "Preparing CSV file..."))
        
        tryCatch({
          datos_df <- data.frame(
            Email_Addresses = as.character(data$emails),
            Phone_Numbers = as.character(data$phones),
            URLs = as.character(data$urls),
            stringsAsFactors = FALSE
          )
          
          # Remove completely empty rows for export
          datos_df <- datos_df[rowSums(datos_df != "", na.rm = TRUE) > 0, ]
          
          write.csv(datos_df, file, row.names = FALSE, na = "")
          
          download_status(list(type = "success", message = "CSV file downloaded successfully!"))
        }, error = function(e) {
          download_status(list(type = "error", message = paste("Error creating CSV file:", e$message)))
          showNotification(paste("Error creating CSV file:", e$message), type = "error")
        })
      }
    )
    
    # Enhanced text download handler
    output$download_txt <- downloadHandler(
      filename = function() {
        paste0(get_base_filename(), "_extracted.txt")
      },
      content = function(file) {
        data <- extracted_data()
        
        validate(
          need(!is.null(data), "No data available for download"),
          need(any(sapply(data, function(x) length(x) > 0 && any(x != ""))), "No extracted data to download")
        )
        
        download_status(list(type = "processing", message = "Preparing text file..."))
        
        tryCatch({
          # Create structured text output
          output_lines <- c(
            "====================================",
            "     DATA EXTRACTION RESULTS",
            "====================================",
            paste("Generated on:", Sys.time()),
            "",
            "EMAIL ADDRESSES:",
            "----------------"
          )
          
          emails <- data$emails[data$emails != ""]
          if (length(emails) > 0) {
            output_lines <- c(output_lines, emails, "")
          } else {
            output_lines <- c(output_lines, "No email addresses found", "")
          }
          
          output_lines <- c(output_lines,
            "PHONE NUMBERS:",
            "--------------"
          )
          
          phones <- data$phones[data$phones != ""]
          if (length(phones) > 0) {
            output_lines <- c(output_lines, phones, "")
          } else {
            output_lines <- c(output_lines, "No phone numbers found", "")
          }
          
          output_lines <- c(output_lines,
            "URLs:",
            "-----"
          )
          
          urls <- data$urls[data$urls != ""]
          if (length(urls) > 0) {
            output_lines <- c(output_lines, urls, "")
          } else {
            output_lines <- c(output_lines, "No URLs found", "")
          }
          
          output_lines <- c(output_lines,
            "====================================",
            paste("Total items extracted:", length(emails) + length(phones) + length(urls))
          )
          
          writeLines(output_lines, file)
          
          download_status(list(type = "success", message = "Text file downloaded successfully!"))
        }, error = function(e) {
          download_status(list(type = "error", message = paste("Error creating text file:", e$message)))
          showNotification(paste("Error creating text file:", e$message), type = "error")
        })
      }
    )
    
    # Render download status
    output$download_status <- renderUI({
      status <- download_status()
      if (!is.null(status)) {
        if (status$type == "processing") {
          div(class = "alert alert-info",
            tags$i(class = "fas fa-spinner fa-spin"),
            status$message
          )
        } else if (status$type == "success") {
          div(class = "alert alert-success",
            tags$i(class = "fas fa-check-circle"),
            status$message
          )
        } else if (status$type == "error") {
          div(class = "alert alert-danger",
            tags$i(class = "fas fa-exclamation-triangle"),
            status$message
          )
        }
      }
    })
    
    # Clear status after some time
    observe({
      status <- download_status()
      if (!is.null(status) && status$type %in% c("success", "error")) {
        invalidateLater(3000)
        download_status(NULL)
      }
    })
    
    # Return download handlers for potential external use
    return(list(
      xlsx_handler = reactive(output$download_xlsx),
      csv_handler = reactive(output$download_csv),
      txt_handler = reactive(output$download_txt)
    ))
  })
}
