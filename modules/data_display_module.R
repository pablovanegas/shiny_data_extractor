# Data Display Module
# Manages the display of extracted data table and results summary

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
      
      if (is.null(data) || all(sapply(data, function(x) length(x) == 0 || all(x == "")))) {
        div(class = "alert alert-info",
          tags$i(class = "fas fa-info-circle"),
          "No data extracted yet. Please upload a file and select extraction types to begin."
        )
      } else {
        email_count <- sum(data$emails != "", na.rm = TRUE)
        phone_count <- sum(data$phones != "", na.rm = TRUE)
        url_count <- sum(data$urls != "", na.rm = TRUE)
        total_count <- email_count + phone_count + url_count
        
        if (total_count == 0) {
          div(class = "alert alert-warning",
            tags$i(class = "fas fa-exclamation-triangle"),
            "No emails, phone numbers, or URLs found in the selected data. Try adjusting your file selection or extraction types."
          )
        } else {
          div(class = "alert alert-success",
            tags$i(class = "fas fa-check-circle"),
            strong("Extraction Complete! "),
            sprintf("Found %d total items: %s", 
                   total_count,
                   paste(
                     if (email_count > 0) paste(email_count, "emails") else NULL,
                     if (phone_count > 0) paste(phone_count, "phone numbers") else NULL,
                     if (url_count > 0) paste(url_count, "URLs") else NULL,
                     sep = ", "
                   )
            )
          )
        }
      }
    })
    
    # Statistics cards for visual representation
    output$statistics_cards <- renderUI({
      data <- extracted_data()
      
      if (!is.null(data) && any(sapply(data, function(x) length(x) > 0 && any(x != "")))) {
        email_count <- sum(data$emails != "", na.rm = TRUE)
        phone_count <- sum(data$phones != "", na.rm = TRUE)
        url_count <- sum(data$urls != "", na.rm = TRUE)
        
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
      }
    })
    
    # Table controls for filtering and export options
    output$table_controls <- renderUI({
      data <- extracted_data()
      
      if (!is.null(data) && any(sapply(data, function(x) length(x) > 0 && any(x != "")))) {
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
      }
    })
    
    # Reactive value for table filtering
    table_filter <- reactiveVal("all")
    
    # Filter button observers
    observeEvent(input$show_all, { table_filter("all") })
    observeEvent(input$show_emails_only, { table_filter("emails") })
    observeEvent(input$show_phones_only, { table_filter("phones") })
    observeEvent(input$show_urls_only, { table_filter("urls") })
    
    # Enhanced data table with improved styling and functionality
    output$contents <- renderDataTable({
      data <- extracted_data()
      filter_type <- table_filter()
      
      validate(
        need(!is.null(data), "No data to display"),
        need(any(sapply(data, function(x) length(x) > 0 && any(x != ""))), "No extracted data available")
      )
      
      # Create display dataframe
      df <- data.frame(
        Emails = data$emails,
        "Phone Numbers" = data$phones,
        URLs = data$urls,
        stringsAsFactors = FALSE,
        check.names = FALSE
      )
      
      # Remove completely empty rows
      df <- df[rowSums(df != "", na.rm = TRUE) > 0, ]
      
      # Apply filtering based on selection
      if (filter_type == "emails") {
        df <- df[df$Emails != "", ]
        df <- df[, "Emails", drop = FALSE]
      } else if (filter_type == "phones") {
        df <- df[df$`Phone Numbers` != "", ]
        df <- df[, "Phone Numbers", drop = FALSE]
      } else if (filter_type == "urls") {
        df <- df[df$URLs != "", ]
        df <- df[, "URLs", drop = FALSE]
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
      autoWidth = TRUE,
      columnDefs = list(
        list(className = "dt-center", targets = "_all"),
        list(width = "33%", targets = c(0, 1, 2))
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
    ), class = "display nowrap")
    
    # Return the data table output for potential external use
    return(reactive(output$contents))
  })
}
