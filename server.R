# ==============================================================================
# Server Logic - Shiny Data Extractor
# Adapted for Bootstrap 5 with bslib >= 0.6.0
# ==============================================================================

server <- function(input, output, session) {
  # Initialize modules
  file_inputs <- file_input_server("file_input")
  extraction_results <- data_extraction_server("extraction", file_inputs)
  data_display_server("display", extraction_results$extracted_data)
  download_server("download", extraction_results$extracted_data, reactive({
    if (!is.null(file_inputs$file())) file_inputs$file()$name else NULL
  }))

  # Value box outputs for statistics - CORRECTED to work with list structure
  output$total_count <- renderText({
    data <- extraction_results$extracted_data()

    # Validate that data exists and is a list
    if (is.null(data) || !is.list(data)) {
      return("0")
    }

    # Count non-empty items from each list
    email_count <- sum(nzchar(data$emails), na.rm = TRUE)
    phone_count <- sum(nzchar(data$phones), na.rm = TRUE)
    url_count <- sum(nzchar(data$urls), na.rm = TRUE)

    total <- email_count + phone_count + url_count
    format(total, big.mark = ",")
  })

  output$email_count <- renderText({
    data <- extraction_results$extracted_data()

    if (is.null(data) || !is.list(data) || is.null(data$emails)) {
      return("0")
    }

    # Count non-empty email strings
    email_count <- sum(nzchar(data$emails), na.rm = TRUE)
    format(email_count, big.mark = ",")
  })

  output$phone_count <- renderText({
    data <- extraction_results$extracted_data()

    if (is.null(data) || !is.list(data) || is.null(data$phones)) {
      return("0")
    }

    # Count non-empty phone strings
    phone_count <- sum(nzchar(data$phones), na.rm = TRUE)
    format(phone_count, big.mark = ",")
  })

  # NEW: URL count output (Previously Missing)
  output$url_count <- renderText({
    data <- extraction_results$extracted_data()

    if (is.null(data) || !is.list(data) || is.null(data$urls)) {
      return("0")
    }

    # Count non-empty URL strings
    url_count <- sum(nzchar(data$urls), na.rm = TRUE)
    format(url_count, big.mark = ",")
  })

  # Results summary text
  output$results_summary <- renderText({
    data <- extraction_results$extracted_data()

    if (is.null(data) || !is.list(data)) {
      return("No data extracted yet")
    }

    # Count non-empty items
    email_count <- sum(nzchar(data$emails), na.rm = TRUE)
    phone_count <- sum(nzchar(data$phones), na.rm = TRUE)
    url_count <- sum(nzchar(data$urls), na.rm = TRUE)
    total <- email_count + phone_count + url_count

    if (total == 0) {
      return("No data extracted yet")
    }

    paste0(
      total, " total items | ", email_count, " emails | ",
      phone_count, " phones | ", url_count, " URLs"
    )
  })
}
