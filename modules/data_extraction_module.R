# ==============================================================================
# Data Extraction Module - REFACTORED FOR MANUAL TRIGGER
# Lazy loading architecture: extraction only on explicit user action
# Enhanced UI/UX Feedback
# ==============================================================================

data_extraction_ui <- function(id) {
  ns <- NS(id)
  tagList(
    # Manual extraction trigger button with enhanced feedback
    div(
      class = "extraction-control-panel",
      actionButton(
        ns("start_extraction"),
        label = tagList(
          tags$i(class = "fas fa-play-circle", style = "margin-right: 0.5rem;"),
          "Start Extraction"
        ),
        class = "btn btn-primary btn-lg btn-extraction",
        width = "100%",
        style = "margin-bottom: 1rem;"
      ),
      # Enhanced status output with more prominent styling
      div(
        class = "extraction-status-container",
        uiOutput(ns("extraction_status"))
      )
    )
  )
}

data_extraction_server <- function(id, file_inputs) {
  moduleServer(id, function(input, output, session) {
    # Reactive values for extracted data
    extractedData <- reactiveVal(list(emails = character(0), phones = character(0), urls = character(0)))
    extractionInProgress <- reactiveVal(FALSE)

    # ===========================================================================
    # MANUAL TRIGGER: Extraction only fires when user clicks button
    # This implements true lazy loading and allows column optimization
    # ===========================================================================
    observeEvent(input$start_extraction,
      {
        req(file_inputs$file())
        req(file_inputs$extract_types())

        # Skip if file status indicates an error
        if (!is.null(file_inputs$file_status()) && file_inputs$file_status()$type == "error") {
          return()
        }

        extractionInProgress(TRUE)

        # ENHANCED: Show prominent non-blocking notification with icon
        notification_id <- showNotification(
          tagList(
            tags$div(
              style = "display: flex; align-items: center; gap: 0.75rem;",
              tags$i(class = "fas fa-cog fa-spin", style = "font-size: 1.5rem; color: #3b82f6;"),
              tags$div(
                tags$strong("Processing your data..."),
                tags$br(),
                tags$small("This may take a moment for large files. Feel free to continue working.")
              )
            )
          ),
          duration = NULL,
          closeButton = FALSE,
          type = "message",
          id = "extraction_notification"
        )

        # ===========================================================================
        # ROBUST DATA PREPARATION: Prevent dimension reduction bugs
        # Uses drop=FALSE and intersect() for 100% structural safety
        # ===========================================================================
        data <- file_inputs$loaded_data()
        extract_types <- file_inputs$extract_types()

        # Validate extract types
        if (is.null(extract_types) || length(extract_types) == 0) {
          showNotification(
            tagList(
              tags$i(class = "fas fa-exclamation-triangle", style = "margin-right: 0.5rem;"),
              "Please select at least one data type to extract"
            ),
            type = "warning",
            duration = 5
          )
          extractionInProgress(FALSE)
          return()
        }

        # Prepare text data based on file type and selected columns
        if (is.data.frame(data)) {
          selected <- file_inputs$selected_columns()

          # Validate column selection
          if (is.null(selected) || length(selected) == 0) {
            showNotification(
              tagList(
                tags$i(class = "fas fa-exclamation-triangle", style = "margin-right: 0.5rem;"),
                "Please select at least one column to process"
              ),
              type = "warning",
              duration = 5
            )
            extractionInProgress(FALSE)
            removeNotification(notification_id)
            return()
          }

          # CRITICAL: Use intersect to ensure selected columns actually exist
          valid_columns <- intersect(selected, names(data))

          if (length(valid_columns) == 0) {
            showNotification(
              tagList(
                tags$i(class = "fas fa-times-circle", style = "margin-right: 0.5rem;"),
                "Selected columns do not exist in the data"
              ),
              type = "error",
              duration = 5
            )
            extractionInProgress(FALSE)
            removeNotification(notification_id)
            return()
          }

          # CRITICAL: Use drop=FALSE to preserve data frame structure
          subset_data <- data[, valid_columns, drop = FALSE]

          # Convert to character vector for extraction
          text_data <- unlist(lapply(subset_data, as.character), use.names = FALSE)
        } else {
          text_data <- as.character(data)
        }

        # Execute extraction asynchronously using future_promise
        future_promise({
          # This code runs in a separate R process
          extract_data_chunked(text_data, extract_types)
        }) %...>% (function(extracted) {
          # This code runs back in the main Shiny session after promise resolves

          # Normalize lengths for display
          max_length <- max(length(extracted$emails), length(extracted$phones), length(extracted$urls))
          if (max_length == 0) max_length <- 1

          extracted$emails <- c(extracted$emails, rep("", max_length - length(extracted$emails)))
          extracted$phones <- c(extracted$phones, rep("", max_length - length(extracted$phones)))
          extracted$urls <- c(extracted$urls, rep("", max_length - length(extracted$urls)))

          # Update reactive values
          extractedData(extracted)
          extractionInProgress(FALSE)

          # Remove processing notification
          removeNotification(notification_id)

          # ENHANCED: Show detailed success notification with better styling
          total_items <- sum(nzchar(extracted$emails)) + sum(nzchar(extracted$phones)) + sum(nzchar(extracted$urls))
          showNotification(
            tagList(
              tags$div(
                style = "display: flex; align-items: flex-start; gap: 0.75rem;",
                tags$i(class = "fas fa-check-circle", style = "font-size: 1.5rem; color: #10b981;"),
                tags$div(
                  tags$strong(style = "font-size: 1.1rem;", "Extraction Complete!"),
                  tags$br(),
                  tags$div(
                    style = "margin-top: 0.5rem; padding: 0.5rem; background: rgba(16, 185, 129, 0.1); border-radius: 0.375rem;",
                    tags$div(style = "font-weight: 600; color: #059669;", paste(total_items, "total items found:")),
                    tags$ul(
                      style = "margin: 0.5rem 0 0 0; padding-left: 1.5rem; list-style: none;",
                      tags$li(
                        tags$i(class = "fas fa-envelope", style = "margin-right: 0.5rem; color: #06b6d4;"),
                        sum(nzchar(extracted$emails)), "emails"
                      ),
                      tags$li(
                        tags$i(class = "fas fa-phone", style = "margin-right: 0.5rem; color: #10b981;"),
                        sum(nzchar(extracted$phones)), "phone numbers"
                      ),
                      tags$li(
                        tags$i(class = "fas fa-link", style = "margin-right: 0.5rem; color: #f59e0b;"),
                        sum(nzchar(extracted$urls)), "URLs"
                      )
                    )
                  )
                )
              )
            ),
            type = "message",
            duration = 10
          )
        }) %...!% (function(error) {
          # Error handling - runs in main session if promise fails
          extractionInProgress(FALSE)
          removeNotification(notification_id)

          # ENHANCED: More informative error notification
          showNotification(
            tagList(
              tags$div(
                style = "display: flex; align-items: flex-start; gap: 0.75rem;",
                tags$i(class = "fas fa-exclamation-circle", style = "font-size: 1.5rem; color: #ef4444;"),
                tags$div(
                  tags$strong("Extraction Failed"),
                  tags$br(),
                  tags$small(paste("Error:", error$message)),
                  tags$br(),
                  tags$small("Please check your file format and try again.")
                )
              )
            ),
            type = "error",
            duration = 10
          )

          extractedData(list(emails = character(0), phones = character(0), urls = character(0)))
        })
      },
      ignoreNULL = TRUE,
      ignoreInit = TRUE
    )

    # ENHANCED: Render extraction status with better visual design
    output$extraction_status <- renderUI({
      if (extractionInProgress()) {
        div(
          class = "alert alert-info extraction-in-progress",
          style = "border-left: 4px solid #3b82f6; animation: pulse 2s ease-in-out infinite;",
          tags$div(
            style = "display: flex; align-items: center; gap: 0.75rem;",
            tags$i(class = "fa fa-spinner fa-spin", style = "font-size: 1.25rem;"),
            tags$div(
              tags$strong("Extraction in Progress"),
              tags$br(),
              tags$small("Processing your data asynchronously. You can continue using the interface.")
            )
          )
        )
      } else {
        # Show configuration summary when ready
        data <- file_inputs$loaded_data()
        selected <- file_inputs$selected_columns()
        types <- file_inputs$extract_types()

        if (!is.null(data) && !is.null(types) && length(types) > 0) {
          div(
            class = "alert alert-light extraction-ready",
            style = "border-left: 4px solid #10b981;",
            tags$div(
              style = "display: flex; align-items: flex-start; gap: 0.75rem;",
              tags$i(class = "fas fa-info-circle", style = "font-size: 1.25rem; color: #3b82f6;"),
              tags$div(
                tags$strong("Ready to Extract"),
                tags$ul(
                  style = "margin-bottom: 0; margin-top: 0.5rem; padding-left: 1.25rem;",
                  tags$li(
                    tags$strong(length(types)), " data type(s): ",
                    tags$span(style = "color: #6366f1;", paste(types, collapse = ", "))
                  ),
                  if (is.data.frame(data)) {
                    tags$li(
                      tags$strong(length(selected)), " column(s) ",
                      tags$span(style = "color: #64748b;", paste0("of ", ncol(data), " total"))
                    )
                  }
                )
              )
            )
          )
        } else {
          NULL
        }
      }
    })

    # Return the extracted data
    return(list(
      extracted_data = extractedData,
      extraction_in_progress = extractionInProgress
    ))
  })
}
