server <- function(input, output, session) {
  # Dark mode function
  output$bodyClasses <- renderUI({
    if (input$dark) {
      tags$script("document.body.classList.add('dark-mode');")
    } else {
      tags$script("document.body.classList.remove('dark-mode');")
    }
  })

  # Store the extracted content
  extractedEmails <- reactiveVal(NULL)
  extractedPhones <- reactiveVal(NULL)
  extractedUrls <- reactiveVal(NULL)
  loadedData <- reactiveVal(NULL)

  # Dynamically generate column checkboxes after file upload (for CSV/XLSX)
  observeEvent(input$file, {
    req(input$file)
    file_type <- switch(input$file_type,
                        "CSV" = "csv",
                        "XLSX" = "xlsx",
                        "TXT" = 'txt')
    # Try reading file, catch errors
    data <- tryCatch({
      process_file(input$file$datapath, file_type, sep = if (input$csv_sep != "Other") input$csv_sep else input$csv_other, sheet = input$excel_sheet)
    }, error = function(e) NULL)
    loadedData(data)
    # Only show checkboxes for data.frames (CSV/XLSX)
    if (is.data.frame(data)) {
      updateCheckboxGroupInput(session, "selected_columns", choices = names(data), selected = names(data))
    }
  })

  # Render UI for column selection (checkboxes)
  output$checkbox_group <- renderUI({
    data <- loadedData()
    if (is.data.frame(data)) {
      checkboxGroupInput("selected_columns", "Select columns to process:",
                         choices = names(data),
                         selected = names(data))
    } else {
      NULL
    }
  })

  # Main extraction logic
  observeEvent({input$file; input$selected_columns}, {
    req(input$file)
    file_type <- switch(input$file_type,
                        "CSV" = "csv",
                        "XLSX" = "xlsx",
                        "TXT" = 'txt')
    data <- loadedData()
    # If data is data.frame, subset to selected columns
    if (is.data.frame(data)) {
      selected <- input$selected_columns
      if (is.null(selected) || length(selected) == 0) {
        text_data <- character(0)
      } else {
        text_data <- unlist(data[selected], use.names = FALSE)
      }
    } else {
      text_data <- unlist(data)
    }

    emails <- if("Emails" %in% input$extract_types) extract_emails(text_data) else character(0)
    phones <- if("Phone Numbers" %in% input$extract_types) extract_phone_numbers(text_data) else character(0)
    urls <- if("URLs" %in% input$extract_types) extract_urls(text_data) else character(0)

    max_length <- max(length(emails), length(phones), length(urls))
    emails <- c(emails, rep("", max_length - length(emails)))
    phones <- c(phones, rep("", max_length - length(phones)))
    urls <- c(urls, rep("", max_length - length(urls)))

    extractedEmails(emails)
    extractedPhones(phones)
    extractedUrls(urls)

    output$contents <- renderDataTable({
      data.frame(Emails = extractedEmails(), Phones = extractedPhones(), URLs = extractedUrls(), stringsAsFactors = FALSE)
    })
  }, ignoreInit = TRUE)

  output$Download <- downloadHandler(
    filename = function() {
      paste(tools::file_path_sans_ext(input$file$name), "_datos", ".xlsx", sep = "")
    },
    content = function(file) {
      datos_df <- data.frame(
        Emails = as.character(extractedEmails()),
        Phones = as.character(extractedPhones()),
        URLs = as.character(extractedUrls())
      )
      write.xlsx(datos_df, file)
    }
  )

  output$Download2 <- downloadHandler(
    filename = function() {
      paste(tools::file_path_sans_ext(input$file$name), "_datos", ".txt", sep = "")
    },
    content = function(file) {
      datos <- c(extractedEmails(), extractedPhones(), extractedUrls())
      write.table(datos, file)
    }
  )
}
