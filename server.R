server <- function(input, output, session) {
  # Dark mode function
  output$bodyClasses <- renderUI({
    if (input$dark) {
      tags$script("document.body.classList.add('dark-mode');")
    } else {
      tags$script("document.body.classList.remove('dark-mode');")
    }
  })
  
  # Initialize modules
  file_inputs <- file_input_server("file_input")
  extraction_results <- data_extraction_server("extraction", file_inputs)
  data_display_server("display", extraction_results$extracted_data)
  download_server("download", extraction_results$extracted_data, reactive({
    if (!is.null(file_inputs$file())) file_inputs$file()$name else NULL
  }))
}
