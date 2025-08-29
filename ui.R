ui <- fluidPage(
  theme = shinytheme("cosmo"),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
    tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"),
    tags$title("Shiny Data Extractor - Professional Data Extraction Tool")
  ),
  
  # Header Section
  div(class = "header-container",
    div(class = "container-fluid",
      div(class = "row align-items-center",
        div(class = "col-md-8",
          titlePanel(
            div(class = "fade-in",
              h1(
                tags$i(class = "fas fa-search", style = "margin-right: 0.5rem;"),
                "Data Extractor",
                style = "margin-bottom: 0.5rem;"
              ),
              p("Professional data extraction tool for emails, phone numbers, and URLs",
                style = "color: var(--text-secondary); font-size: 1.1rem; margin: 0;")
            )
          )
        ),
        div(class = "col-md-4 text-right",
          div(class = "header-controls",
            materialSwitch("dark", 
                          label = tags$span(
                            tags$i(class = "fas fa-moon", style = "margin-right: 0.5rem;"),
                            "Dark Mode"
                          ), 
                          status = "primary",
                          inline = TRUE)
          )
        )
      )
    )
  ),
  
  uiOutput("bodyClasses"),
  
  div(class = "main-container",
    div(class = "container-fluid",
      div(class = "row",
        # Enhanced Sidebar
        div(class = "col-lg-4 col-md-5",
          div(class = "sidebar-panel slide-in",
            div(class = "panel panel-default",
              div(class = "panel-header",
                h3(
                  tags$i(class = "fas fa-cog", style = "margin-right: 0.5rem;"),
                  "Configuration",
                  style = "margin: 0; color: var(--primary-color);"
                )
              ),
              div(class = "panel-body",
                # File input module UI with enhanced styling
                div(class = "config-section",
                  file_input_ui("file_input")
                ),
                
                hr(style = "margin: 2rem 0; border-color: var(--border-color);"),
                
                # Download section with enhanced styling
                div(class = "download-section",
                  h4(
                    tags$i(class = "fas fa-download", style = "margin-right: 0.5rem;"),
                    "Export Data",
                    style = "color: var(--primary-color); margin-bottom: 1rem;"
                  ),
                  download_ui("download")
                )
              )
            )
          )
        ),
        
        # Enhanced Main Panel
        div(class = "col-lg-8 col-md-7",
          div(class = "main-panel fade-in",
            tabsetPanel(id = "mainTabs",
              # Enhanced Data Tab
              tabPanel("Extracted Data", 
                       value = "data_tab",
                       icon = icon("table"),
                       div(class = "tab-content-wrapper",
                         # Status and extraction indicators
                         div(class = "status-section",
                           data_extraction_ui("extraction")
                         ),
                         
                         # Results summary with enhanced styling
                         div(class = "results-section",
                           data_display_ui("display")
                         )
                       )
              ),
              
              # Enhanced Tutorial Tab
              tabPanel("Tutorial", 
                       value = "tutorial_tab",
                       icon = icon("graduation-cap"),
                       div(class = "tab-content-wrapper",
                         div(class = "info-card",
                           h2(
                             tags$i(class = "fas fa-graduation-cap", style = "margin-right: 0.5rem;"),
                             "How to Use Data Extractor"
                           ),
                           div(class = "tutorial-content",
                             div(class = "row",
                               div(class = "col-md-6",
                                 div(class = "tutorial-step",
                                   h4(
                                     tags$span(class = "step-number", "1"),
                                     "Select Extraction Types"
                                   ),
                                   p("Choose what data to extract: emails, phone numbers, and/or URLs from the dropdown menu.")
                                 ),
                                 div(class = "tutorial-step",
                                   h4(
                                     tags$span(class = "step-number", "2"),
                                     "Choose File Format"
                                   ),
                                   p("Select your file type: CSV, Excel (XLSX), or plain text (TXT).")
                                 ),
                                 div(class = "tutorial-step",
                                   h4(
                                     tags$span(class = "step-number", "3"),
                                     "Upload Your File"
                                   ),
                                   p("Browse and select your data file using the file upload button.")
                                 ),
                                 div(class = "tutorial-step",
                                   h4(
                                     tags$span(class = "step-number", "4"),
                                     "Configure Settings"
                                   ),
                                   p("For CSV files, select the appropriate delimiter. For Excel files, specify the sheet number.")
                                 )
                               ),
                               div(class = "col-md-6",
                                 div(class = "tutorial-step",
                                   h4(
                                     tags$span(class = "step-number", "5"),
                                     "Select Columns"
                                   ),
                                   p("Choose specific columns to process for structured data (CSV/Excel files).")
                                 ),
                                 div(class = "tutorial-step",
                                   h4(
                                     tags$span(class = "step-number", "6"),
                                     "View Results"
                                   ),
                                   p("Extracted data appears in the main panel with summary statistics and counts.")
                                 ),
                                 div(class = "tutorial-step",
                                   h4(
                                     tags$span(class = "step-number", "7"),
                                     "Download Results"
                                   ),
                                   p("Export your extracted data in Excel (.xlsx) or text (.txt) format.")
                                 )
                               )
                             ),
                             
                             div(class = "supported-formats",
                               h3("Supported File Formats"),
                               div(class = "row",
                                 div(class = "col-md-4",
                                   div(class = "format-card",
                                     tags$i(class = "fas fa-file-csv fa-2x", style = "color: var(--success-color);"),
                                     h5("CSV Files"),
                                     p("Comma-separated values with customizable delimiters")
                                   )
                                 ),
                                 div(class = "col-md-4",
                                   div(class = "format-card",
                                     tags$i(class = "fas fa-file-excel fa-2x", style = "color: var(--success-color);"),
                                     h5("Excel Files"),
                                     p("Microsoft Excel files with multi-sheet support")
                                   )
                                 ),
                                 div(class = "col-md-4",
                                   div(class = "format-card",
                                     tags$i(class = "fas fa-file-alt fa-2x", style = "color: var(--success-color);"),
                                     h5("Text Files"),
                                     p("Plain text files with UTF-8 and Latin-1 encoding")
                                   )
                                 )
                               )
                             ),
                             
                             div(class = "extraction-patterns",
                               h3("Extraction Capabilities"),
                               div(class = "row",
                                 div(class = "col-md-4",
                                   div(class = "pattern-card",
                                     tags$i(class = "fas fa-envelope fa-2x", style = "color: var(--primary-color);"),
                                     h5("Email Addresses"),
                                     p("Advanced regex patterns with false-positive filtering")
                                   )
                                 ),
                                 div(class = "col-md-4",
                                   div(class = "pattern-card",
                                     tags$i(class = "fas fa-phone fa-2x", style = "color: var(--primary-color);"),
                                     h5("Phone Numbers"),
                                     p("International and US/Canada formats supported")
                                   )
                                 ),
                                 div(class = "col-md-4",
                                   div(class = "pattern-card",
                                     tags$i(class = "fas fa-link fa-2x", style = "color: var(--primary-color);"),
                                     h5("URLs"),
                                     p("HTTP/HTTPS, FTP, and www domain detection")
                                   )
                                 )
                               )
                             )
                           )
                         )
                       )
              ),
              
              # New About Tab
              tabPanel("About", 
                       value = "about_tab",
                       icon = icon("info-circle"),
                       div(class = "tab-content-wrapper",
                         div(class = "info-card",
                           h2(
                             tags$i(class = "fas fa-info-circle", style = "margin-right: 0.5rem;"),
                             "About Data Extractor"
                           ),
                           div(class = "about-content",
                             p("Shiny Data Extractor is a production-grade, interactive R Shiny application designed to extract emails, phone numbers, and URLs from various data formats."),
                             
                             div(class = "row",
                               div(class = "col-md-6",
                                 h4("Key Features"),
                                 tags$ul(
                                   tags$li("Multi-format file support (CSV, Excel, Text)"),
                                   tags$li("Advanced pattern recognition"),
                                   tags$li("Column-specific processing"),
                                   tags$li("Real-time progress indication"),
                                   tags$li("Comprehensive error handling"),
                                   tags$li("Export in multiple formats")
                                 )
                               ),
                               div(class = "col-md-6",
                                 h4("Performance"),
                                 tags$ul(
                                   tags$li("Handles large files (GB+)"),
                                   tags$li("Asynchronous processing"),
                                   tags$li("Memory-efficient chunked reading"),
                                   tags$li("Progress tracking"),
                                   tags$li("Responsive user interface"),
                                   tags$li("Dark/Light theme support")
                                 )
                               )
                             ),
                             
                             div(class = "tech-info",
                               h4("Technical Details"),
                               p("Built with R Shiny using a modular architecture for maintainability and scalability. Utilizes advanced regex patterns for accurate data extraction and includes comprehensive validation and error handling.")
                             )
                           )
                         )
                       )
              )
            )
          )
        )
      )
    )
  ),
  
  # Add custom CSS for enhanced styling
  tags$style(HTML("
    .header-container {
      background: linear-gradient(135deg, var(--bg-primary), var(--bg-secondary));
      padding: 2rem 0;
      margin-bottom: 2rem;
      border-bottom: 1px solid var(--border-color);
    }
    
    .main-container {
      padding-bottom: 3rem;
    }
    
    .sidebar-panel .panel {
      border: none;
      box-shadow: var(--shadow-lg);
      border-radius: var(--border-radius);
      background: var(--bg-primary);
    }
    
    .panel-header {
      background: linear-gradient(135deg, var(--bg-tertiary), var(--bg-secondary));
      padding: 1.5rem;
      border-radius: var(--border-radius) var(--border-radius) 0 0;
      border-bottom: 1px solid var(--border-color);
    }
    
    .panel-body {
      padding: 2rem;
    }
    
    .config-section, .download-section {
      margin-bottom: 1.5rem;
    }
    
    .tutorial-step {
      margin-bottom: 2rem;
      padding: 1rem;
      border-left: 3px solid var(--primary-color);
      background: var(--bg-secondary);
      border-radius: 0 var(--border-radius-sm) var(--border-radius-sm) 0;
    }
    
    .step-number {
      display: inline-block;
      width: 30px;
      height: 30px;
      background: var(--primary-color);
      color: white;
      border-radius: 50%;
      text-align: center;
      line-height: 30px;
      font-weight: 600;
      margin-right: 0.5rem;
    }
    
    .format-card, .pattern-card {
      text-align: center;
      padding: 1.5rem;
      background: var(--bg-secondary);
      border-radius: var(--border-radius);
      margin-bottom: 1rem;
      transition: var(--transition);
    }
    
    .format-card:hover, .pattern-card:hover {
      transform: translateY(-2px);
      box-shadow: var(--shadow-md);
    }
    
    .supported-formats, .extraction-patterns {
      margin-top: 2rem;
      padding-top: 2rem;
      border-top: 1px solid var(--border-color);
    }
    
    .about-content {
      line-height: 1.7;
    }
    
    .tech-info {
      margin-top: 2rem;
      padding: 1.5rem;
      background: var(--bg-secondary);
      border-radius: var(--border-radius);
    }
    
    .header-controls {
      display: flex;
      align-items: center;
      justify-content: flex-end;
    }
  "))
)
