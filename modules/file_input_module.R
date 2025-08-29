# File Input Module
# Handles file upload and configuration (type, separator, sheet selection)

file_input_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    # Enhanced extraction type selection
    div(class = "form-group",
      tags$label(
        tags$i(class = "fas fa-list-check", style = "margin-right: 0.5rem;"),
        "Data Types to Extract:",
        `for` = ns("extract_types")
      ),
      pickerInput(
        inputId = ns("extract_types"),
        label = NULL,
        choices = list(
          "Contact Information" = list(
            "Emails" = "Emails",
            "Phone Numbers" = "Phone Numbers"
          ),
          "Web Resources" = list(
            "URLs" = "URLs"
          )
        ),
        multiple = TRUE,
        selected = c("Emails", "Phone Numbers", "URLs"),
        options = list(
          'actions-box' = TRUE,
          'live-search' = TRUE,
          'selected-text-format' = "count > 2",
          'count-selected-text' = "{0} data types selected"
        )
      ),
      div(class = "help-block",
        tags$i(class = "fas fa-info-circle", style = "margin-right: 0.25rem;"),
        "Select one or more data types to extract from your file"
      )
    ),
    
    # Enhanced file type selection
    div(class = "form-group",
      tags$label(
        tags$i(class = "fas fa-file", style = "margin-right: 0.5rem;"),
        "File Format:",
        `for` = ns("file_type")
      ),
      pickerInput(
        inputId = ns("file_type"),
        label = NULL,
        choices = list(
          "Structured Data" = list(
            "CSV" = "CSV",
            "Excel (XLSX)" = "XLSX"
          ),
          "Plain Text" = list(
            "Text (TXT)" = "TXT"
          )
        ),
        selected = "CSV",
        options = list(
          style = "btn-outline-primary",
          'live-search' = FALSE
        )
      ),
      div(class = "help-block",
        tags$i(class = "fas fa-info-circle", style = "margin-right: 0.25rem;"),
        "Choose the format that matches your file type"
      )
    ),
    
    # Enhanced file input with drag-and-drop styling
    div(class = "form-group file-upload-container",
      tags$label(
        tags$i(class = "fas fa-cloud-upload-alt", style = "margin-right: 0.5rem;"),
        "Upload Your File:",
        `for` = ns("file")
      ),
      div(class = "file-input-wrapper",
        fileInput(
          ns("file"), 
          label = NULL,
          accept = c("text/csv", "text/xlsx", 'text/txt', ".csv", ".xlsx", ".txt"),
          buttonLabel = tagList(
            tags$i(class = "fas fa-folder-open", style = "margin-right: 0.5rem;"),
            "Browse Files"
          ),
          placeholder = "No file selected"
        )
      )
    ),
    
    # CSV-specific options with enhanced styling
    conditionalPanel(
      condition = paste0("input['", ns("file_type"), "'] == 'CSV'"),
      div(class = "csv-options-panel",
        div(class = "form-group",
          tags$label(
            tags$i(class = "fas fa-columns", style = "margin-right: 0.5rem;"),
            "CSV Delimiter:",
            `for` = ns("csv_sep")
          ),
          pickerInput(
            inputId = ns("csv_sep"),
            label = NULL,
            choices = list(
              "Common Delimiters" = list(
                "Comma (,)" = ",",
                "Semicolon (;)" = ";"
              ),
              "Other Delimiters" = list(
                "Tab" = "\t",
                "Space" = " ",
                "Custom" = "Other"
              )
            ),
            selected = ",",
            options = list(style = "btn-outline-info")
          ),
          conditionalPanel(
            condition = paste0("input['", ns("csv_sep"), "'] == 'Other'"),
            div(class = "custom-separator",
              textInput(
                ns('csv_other'), 
                label = tags$span(
                  tags$i(class = "fas fa-edit", style = "margin-right: 0.5rem;"),
                  "Custom Delimiter:"
                ),
                value = ',',
                placeholder = "Enter delimiter character"
              )
            )
          ),
          div(class = "help-block",
            tags$i(class = "fas fa-info-circle", style = "margin-right: 0.25rem;"),
            "Select the character that separates columns in your CSV file"
          )
        )
      )
    ),
    
    # Excel-specific options with enhanced styling
    conditionalPanel(
      condition = paste0("input['", ns("file_type"), "'] == 'XLSX'"),
      div(class = "excel-options-panel",
        div(class = "form-group",
          tags$label(
            tags$i(class = "fas fa-table", style = "margin-right: 0.5rem;"),
            "Excel Sheet Number:",
            `for` = ns("excel_sheet")
          ),
          numericInput(
            ns("excel_sheet"), 
            label = NULL,
            value = 1, 
            min = 1, 
            max = 100,
            step = 1
          ),
          div(class = "help-block",
            tags$i(class = "fas fa-info-circle", style = "margin-right: 0.25rem;"),
            "Specify which sheet to process (1 = first sheet)"
          )
        )
      )
    ),
    
    # Column selection with enhanced UI
    div(class = "column-selection-container",
      uiOutput(ns("checkbox_group"))
    ),
    
    # File status with enhanced visual feedback
    div(class = "file-status-container",
      uiOutput(ns("file_status"))
    )
  )
}

file_input_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # Reactive values
    loadedData <- reactiveVal(NULL)
    fileStatus <- reactiveVal(NULL)
    
    # File processing with enhanced validation and error handling
    observeEvent(input$file, {
      req(input$file)
      
      # Show processing status immediately
      fileStatus(list(
        type = "processing",
        message = "Processing file..."
      ))
      
      # Validate file type matches selection
      file_ext <- tools::file_ext(input$file$name)
      expected_ext <- switch(input$file_type,
                           "CSV" = "csv",
                           "XLSX" = "xlsx", 
                           "TXT" = "txt")
      
      if (tolower(file_ext) != expected_ext) {
        fileStatus(list(
          type = "error",
          message = paste("File extension", file_ext, "does not match selected type", input$file_type, 
                         ". Please select the correct file type or upload a different file.")
        ))
        loadedData(NULL)
        return()
      }
      
      # Get file size for user feedback
      file_size <- file.info(input$file$datapath)$size
      file_size_mb <- round(file_size / (1024^2), 2)
      
      # Try reading file with comprehensive error handling
      data <- tryCatch({
        result <- process_file(
          input$file$datapath, 
          expected_ext, 
          sep = if (input$csv_sep != "Other") input$csv_sep else input$csv_other, 
          sheet = input$excel_sheet
        )
        
        # Validate data is not empty
        if (is.null(result) || (is.data.frame(result) && nrow(result) == 0) || 
            (is.character(result) && length(result) == 0)) {
          stop("File appears to be empty or contains no readable data")
        }
        
        # Create success message with file details
        success_msg <- if (is.data.frame(result)) {
          paste("File loaded successfully:",
                nrow(result), "rows,", 
                ncol(result), "columns",
                if (file_size_mb > 0.1) paste("(", file_size_mb, "MB)") else "")
        } else {
          paste("File loaded successfully:",
                length(result), "lines",
                if (file_size_mb > 0.1) paste("(", file_size_mb, "MB)") else "")
        }
        
        fileStatus(list(
          type = "success",
          message = success_msg
        ))
        
        result
      }, error = function(e) {
        fileStatus(list(
          type = "error",
          message = paste("Error reading file:", e$message)
        ))
        NULL
      })
      
      loadedData(data)
    })
    
    # Enhanced column selection checkboxes
    output$checkbox_group <- renderUI({
      data <- loadedData()
      if (is.data.frame(data) && ncol(data) > 0) {
        div(class = "column-selection-panel",
          tags$label(
            tags$i(class = "fas fa-columns", style = "margin-right: 0.5rem;"),
            "Select Columns to Process:",
            style = "font-weight: 600; color: var(--primary-color);"
          ),
          div(class = "checkbox-grid",
            checkboxGroupInput(
              session$ns("selected_columns"), 
              label = NULL,
              choices = setNames(names(data), paste0(names(data), " (", sapply(data, class), ")")),
              selected = names(data),
              inline = FALSE
            )
          ),
          div(class = "column-actions",
            actionButton(
              session$ns("select_all_cols"), 
              "Select All",
              class = "btn btn-outline-primary btn-sm",
              icon = icon("check-square")
            ),
            actionButton(
              session$ns("deselect_all_cols"), 
              "Deselect All",
              class = "btn btn-outline-secondary btn-sm",
              icon = icon("square")
            )
          ),
          div(class = "help-block",
            tags$i(class = "fas fa-info-circle", style = "margin-right: 0.25rem;"),
            "Choose specific columns to search for data patterns"
          )
        )
      } else {
        NULL
      }
    })
    
    # Column selection button handlers
    observeEvent(input$select_all_cols, {
      data <- loadedData()
      if (is.data.frame(data)) {
        updateCheckboxGroupInput(session, "selected_columns", selected = names(data))
      }
    })
    
    observeEvent(input$deselect_all_cols, {
      updateCheckboxGroupInput(session, "selected_columns", selected = character(0))
    })
    
    # Enhanced file status messages with better visual design
    output$file_status <- renderUI({
      status <- fileStatus()
      if (!is.null(status)) {
        if (status$type == "error") {
          div(class = "alert alert-danger",
            tags$i(class = "fas fa-exclamation-triangle"),
            strong("Error: "), status$message
          )
        } else if (status$type == "success") {
          div(class = "alert alert-success",
            tags$i(class = "fas fa-check-circle"),
            strong("Success: "), status$message
          )
        } else if (status$type == "processing") {
          div(class = "alert alert-info",
            tags$i(class = "fas fa-spinner fa-spin"),
            status$message
          )
        }
      }
    })
    
    # Return reactive values for parent server
    return(list(
      file = reactive(input$file),
      file_type = reactive(input$file_type),
      extract_types = reactive(input$extract_types),
      csv_sep = reactive(input$csv_sep),
      csv_other = reactive(input$csv_other),
      excel_sheet = reactive(input$excel_sheet),
      selected_columns = reactive(input$selected_columns),
      loaded_data = loadedData,
      file_status = fileStatus
    ))
  })
}
