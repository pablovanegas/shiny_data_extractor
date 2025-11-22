# ==============================================================================
# Data Display Module
# Manages the display of extracted data table and results summary
# Enhanced with URL truncation and tooltips
# ==============================================================================

data_display_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    # Enhanced results summary with statistics cards
    div(class = "results-summary-section",
      uiOutput(ns("results_summary")),
      uiOutput(ns("statistics_cards"))
    ),
    
    # Enhanced data table with improved styling
    div(class = "data-table-section",
      div(class = "table-header",
        h3(
          tags$i(class = "fas fa-table", style = "margin-right: 0.5rem;"),
          "Extracted Data",
          style = "color: var(--primary-color); margin-bottom: 1rem;"
        ),
        div(class = "table-controls",
          uiOutput(ns("table_controls"))
        )
      ),
      DTOutput(ns("contents"))
    )
  )
}

data_display_server <- function(id, extracted_data) {
  moduleServer(id, function(input, output, session) {
    
    # Enhanced results summary with better styling
    output$results_summary <- renderUI({
      data <- extracted_data()
      
      # Check if data is null or empty list
      if (is.null(data) || !is.list(data)) {
        return(div(class = "alert alert-info",
          tags$i(class = "fas fa-info-circle"),
          "No data extracted yet. Please upload a file and select extraction types to begin."
        ))
      }
      
      # Count non-empty items
      email_count <- sum(nzchar(data$emails), na.rm = TRUE)
      phone_count <- sum(nzchar(data$phones), na.rm = TRUE)
      url_count <- sum(nzchar(data$urls), na.rm = TRUE)
      total_count <- email_count + phone_count + url_count
      
      if (total_count == 0) {
        return(div(class = "alert alert-warning",
          tags$i(class = "fas fa-exclamation-triangle"),
          "No emails, phone numbers, or URLs found in the selected data. Try adjusting your file selection or extraction types."
        ))
      }
      
      # Build results message
      results_parts <- c()
      if (email_count > 0) results_parts <- c(results_parts, paste(email_count, "emails"))
      if (phone_count > 0) results_parts <- c(results_parts, paste(phone_count, "phone numbers"))
      if (url_count > 0) results_parts <- c(results_parts, paste(url_count, "URLs"))
      
      div(class = "alert alert-success",
        tags$i(class = "fas fa-check-circle"),
        strong("Extraction Complete! "),
        sprintf("Found %d total items: %s", total_count, paste(results_parts, collapse = ", "))
      )
    })
    
    # Statistics cards for visual representation
    output$statistics_cards <- renderUI({
      data <- extracted_data()
      
      if (is.null(data) || !is.list(data)) return(NULL)
      
      email_count <- sum(nzchar(data$emails), na.rm = TRUE)
      phone_count <- sum(nzchar(data$phones), na.rm = TRUE)
      url_count <- sum(nzchar(data$urls), na.rm = TRUE)
      
      if (email_count + phone_count + url_count == 0) return(NULL)
      
      div(class = "statistics-cards",
        div(class = "row",
          div(class = "col-md-4",
            div(class = "stat-card",
              tags$i(class = "fas fa-envelope fa-2x", style = "color: var(--primary-color); margin-bottom: 0.5rem;"),
              div(class = "stat-number", email_count),
              div(class = "stat-label", "Emails Found")
            )
          ),
          div(class = "col-md-4",
            div(class = "stat-card",
              tags$i(class = "fas fa-phone fa-2x", style = "color: var(--secondary-color); margin-bottom: 0.5rem;"),
              div(class = "stat-number", phone_count),
              div(class = "stat-label", "Phone Numbers")
            )
          ),
          div(class = "col-md-4",
            div(class = "stat-card",
              tags$i(class = "fas fa-link fa-2x", style = "color: var(--success-color); margin-bottom: 0.5rem;"),
              div(class = "stat-number", url_count),
              div(class = "stat-label", "URLs Found")
            )
          )
        )
      )
    })
    
    # Table controls for filtering and export options
    output$table_controls <- renderUI({
      data <- extracted_data()
      
      if (is.null(data) || !is.list(data)) return(NULL)
      
      total <- sum(nzchar(data$emails), na.rm = TRUE) + 
               sum(nzchar(data$phones), na.rm = TRUE) + 
               sum(nzchar(data$urls), na.rm = TRUE)
      
      if (total == 0) return(NULL)
      
      div(class = "table-controls-container",
        div(class = "btn-group", role = "group",
          actionButton(
            session$ns("show_all"), 
            "Show All",
            class = "btn btn-outline-primary btn-sm",
            icon = icon("eye")
          ),
          actionButton(
            session$ns("show_emails_only"), 
            "Emails Only",
            class = "btn btn-outline-primary btn-sm", 
            icon = icon("envelope")
          ),
          actionButton(
            session$ns("show_phones_only"), 
            "Phones Only",
            class = "btn btn-outline-primary btn-sm",
            icon = icon("phone")
          ),
          actionButton(
            session$ns("show_urls_only"), 
            "URLs Only",
            class = "btn btn-outline-primary btn-sm",
            icon = icon("link")
          )
        )
      )
    })
    
    # Reactive value for table filtering
    table_filter <- reactiveVal("all")
    
    # Filter button observers
    observeEvent(input$show_all, { 
      table_filter("all")
    })
    observeEvent(input$show_emails_only, { 
      table_filter("emails")
    })
    observeEvent(input$show_phones_only, { 
      table_filter("phones")
    })
    observeEvent(input$show_urls_only, { 
      table_filter("urls")
    })
    
    # ENHANCED: Data table with URL truncation and better UX
    output$contents <- renderDataTable({
      data <- extracted_data()
      filter_type <- table_filter()
      
      # Validate data exists and is a list
      validate(
        need(!is.null(data) && is.list(data), "No data to display")
      )
      
      # Create display dataframe from list structure
      df <- data.frame(
        Emails = data$emails,
        `Phone Numbers` = data$phones,
        URLs = data$urls,
        stringsAsFactors = FALSE,
        check.names = FALSE
      )
      
      # Remove completely empty rows
      df <- df[rowSums(df != "", na.rm = TRUE) > 0, , drop = FALSE]
      
      # Validate we have data to show
      validate(
        need(nrow(df) > 0, "No extracted data available")
      )
      
      # Apply filtering based on selection
      if (filter_type == "emails") {
        df <- df[df$Emails != "", , drop = FALSE]
        if (nrow(df) > 0) {
          df <- df[, "Emails", drop = FALSE]
        }
      } else if (filter_type == "phones") {
        df <- df[df$`Phone Numbers` != "", , drop = FALSE]
        if (nrow(df) > 0) {
          df <- df[, "Phone Numbers", drop = FALSE]
        }
      } else if (filter_type == "urls") {
        df <- df[df$URLs != "", , drop = FALSE]
        if (nrow(df) > 0) {
          df <- df[, "URLs", drop = FALSE]
        }
      }
      
      # Return filtered dataframe
      df
      
    }, options = list(
      pageLength = 25,
      lengthMenu = c(10, 25, 50, 100),
      scrollX = TRUE,
      searching = TRUE,
      ordering = TRUE,
      info = TRUE,
      autoWidth = FALSE,
      # ENHANCED: Column definitions with URL truncation
      columnDefs = list(
        list(className = "dt-center", targets = "_all"),
        # Truncate URLs column (assumed to be column 2, 0-indexed)
        list(
          targets = 2,  # URLs column (0-indexed: Emails=0, Phone Numbers=1, URLs=2)
          render = JS(
            "function(data, type, row, meta) {",
            "  if (type === 'display' && data.length > 50) {",
            "    return '<span title=\"' + data + '\">' + data.substr(0, 50) + '...</span>';",
            "  }",
            "  return data;",
            "}"
          )
        )
      ),
      language = list(
        search = "Search extracted data:",
        lengthMenu = "Show _MENU_ entries per page",
        info = "Showing _START_ to _END_ of _TOTAL_ entries",
        infoEmpty = "No entries available",
        infoFiltered = "(filtered from _MAX_ total entries)",
        paginate = list(
          first = "First",
          last = "Last",
          `next` = "Next",
          previous = "Previous"
        )
      ),
      dom = '<"top"<"left"l><"right"f>>rt<"bottom"<"left"i><"right"p>>',
      initComplete = JS(
        "function(settings, json) {",
        "$(this.api().table().header()).css({'background-color': 'var(--bg-tertiary)', 'color': 'var(--text-primary)'});",
        "}"
      )
    ), class = "display nowrap cell-border hover")
    
    # Return the data table output for potential external use
    return(reactive(output$contents))
  })
}