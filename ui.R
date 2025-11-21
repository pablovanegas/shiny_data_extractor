# ==============================================================================
# UI Definition - Shiny Data Extractor
# Modern Bootstrap 5 implementation using bslib >= 0.6.0
# ==============================================================================

ui <- page_navbar(
  title = div(
    tags$i(class = "fas fa-search", style = "margin-right: 0.5rem;"),
    "Data Extractor"
  ),

  # Modern Bootstrap 5 theme with bslib
  theme = bs_theme(
    version = 5,
    preset = "cosmo",
    primary = "#3b82f6",
    secondary = "#6366f1",
    success = "#10b981",
    info = "#06b6d4",
    warning = "#f59e0b",
    danger = "#ef4444",
    base_font = font_google("Inter"),
    heading_font = font_google("Yusei Magic"),
    font_scale = 0.95,
    spacer = "1rem"
  ),

  # Custom CSS and Font Awesome
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css"),
    tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"),
    tags$link(
      rel = "stylesheet",
      href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"
    )
  ),

  # ============================================================================
  # Main Tab: Extracted Data
  # ============================================================================
  nav_panel(
    title = "Extracted Data",
    icon = icon("table"),
    layout_sidebar(
      # Sidebar with configuration
      sidebar = sidebar(
        title = div(
          tags$i(class = "fas fa-cog", style = "margin-right: 0.5rem;"),
          "Configuration"
        ),
        width = 400,

        # File input module
        card(
          card_header(
            tags$i(class = "fas fa-file-upload", style = "margin-right: 0.5rem;"),
            "File Upload"
          ),
          card_body(
            file_input_ui("file_input")
          )
        ),

        # Download section
        card(
          card_header(
            tags$i(class = "fas fa-download", style = "margin-right: 0.5rem;"),
            "Export Data"
          ),
          card_body(
            download_ui("download")
          )
        )
      ),

      # Main content area
      # CORRECTED: Statistics value boxes - NOW WITH 4 CARDS (ADDED URLs)
      layout_columns(
        col_widths = c(3, 3, 3, 3), # 4 equal columns for symmetry
        value_box(
          title = "Total Extracted",
          value = textOutput("total_count"),
          showcase = icon("database"),
          theme = "primary",
          showcase_layout = "left center"
        ),
        value_box(
          title = "Emails Found",
          value = textOutput("email_count"),
          showcase = icon("envelope"),
          theme = "info",
          showcase_layout = "left center"
        ),
        value_box(
          title = "Phone Numbers",
          value = textOutput("phone_count"),
          showcase = icon("phone"),
          theme = "success",
          showcase_layout = "left center"
        ),
        # NEW: URLs Value Box (Previously Missing)
        value_box(
          title = "URLs Found",
          value = textOutput("url_count"),
          showcase = icon("link"),
          theme = "warning",
          showcase_layout = "left center"
        )
      ),


      # Extraction control panel (Manual Trigger)
      card(
        card_header(
          tags$i(class = "fas fa-rocket", style = "margin-right: 0.5rem;"),
          "Extraction Control"
        ),
        card_body(
          data_extraction_ui("extraction")
        )
      ),

      # Results table
      card(
        full_screen = TRUE,
        card_header(
          class = "d-flex justify-content-between align-items-center",
          div(
            tags$i(class = "fas fa-table", style = "margin-right: 0.5rem;"),
            "Extracted Data"
          ),
          div(
            class = "text-muted small",
            textOutput("results_summary", inline = TRUE)
          )
        ),
        card_body(
          data_display_ui("display")
        )
      )
    )
  ),

  # ============================================================================
  # Tutorial Tab
  # ============================================================================
  nav_panel(
    title = "Tutorial",
    icon = icon("graduation-cap"),
    layout_columns(
      col_widths = 12,
      card(
        card_header(
          tags$h3(
            tags$i(class = "fas fa-graduation-cap", style = "margin-right: 0.5rem;"),
            "How to Use Data Extractor",
            style = "margin: 0;"
          )
        ),
        card_body(
          layout_columns(
            col_widths = c(6, 6),

            # Left column - Steps 1-4
            div(
              div(
                class = "tutorial-step",
                tags$h4(
                  tags$span(class = "step-number", "1"),
                  "Select Extraction Types"
                ),
                tags$p("Choose what data to extract: emails, phone numbers, and/or URLs from the dropdown menu.")
              ),
              div(
                class = "tutorial-step",
                tags$h4(
                  tags$span(class = "step-number", "2"),
                  "Choose File Format"
                ),
                tags$p("Select your file type: CSV, Excel (XLSX), or plain text (TXT).")
              ),
              div(
                class = "tutorial-step",
                tags$h4(
                  tags$span(class = "step-number", "3"),
                  "Upload Your File"
                ),
                tags$p("Browse and select your data file using the file upload button.")
              ),
              div(
                class = "tutorial-step",
                tags$h4(
                  tags$span(class = "step-number", "4"),
                  "Configure Settings"
                ),
                tags$p("For CSV files, select the appropriate delimiter. For Excel files, specify the sheet number.")
              )
            ),

            # Right column - Steps 5-7
            div(
              div(
                class = "tutorial-step",
                tags$h4(
                  tags$span(class = "step-number", "5"),
                  "Select Columns"
                ),
                tags$p("Choose specific columns to process for structured data (CSV/Excel files).")
              ),
              div(
                class = "tutorial-step",
                tags$h4(
                  tags$span(class = "step-number", "6"),
                  "View Results"
                ),
                tags$p("Extracted data appears in the main panel with summary statistics and counts.")
              ),
              div(
                class = "tutorial-step",
                tags$h4(
                  tags$span(class = "step-number", "7"),
                  "Download Results"
                ),
                tags$p("Export your extracted data in Excel (.xlsx) or text (.txt) format.")
              )
            )
          )
        )
      ),

      # Supported Formats
      card(
        card_header(
          tags$h3(
            tags$i(class = "fas fa-file", style = "margin-right: 0.5rem;"),
            "Supported File Formats",
            style = "margin: 0;"
          )
        ),
        card_body(
          layout_columns(
            col_widths = c(4, 4, 4),
            div(
              class = "format-card text-center",
              tags$i(class = "fas fa-file-csv fa-3x text-success mb-3"),
              tags$h5("CSV Files"),
              tags$p("Comma-separated values with customizable delimiters")
            ),
            div(
              class = "format-card text-center",
              tags$i(class = "fas fa-file-excel fa-3x text-success mb-3"),
              tags$h5("Excel Files"),
              tags$p("Microsoft Excel files with multi-sheet support")
            ),
            div(
              class = "format-card text-center",
              tags$i(class = "fas fa-file-alt fa-3x text-success mb-3"),
              tags$h5("Text Files"),
              tags$p("Plain text files with UTF-8 and Latin-1 encoding")
            )
          )
        )
      ),

      # Extraction Patterns
      card(
        card_header(
          tags$h3(
            tags$i(class = "fas fa-magic", style = "margin-right: 0.5rem;"),
            "Extraction Capabilities",
            style = "margin: 0;"
          )
        ),
        card_body(
          layout_columns(
            col_widths = c(4, 4, 4),
            div(
              class = "pattern-card text-center",
              tags$i(class = "fas fa-envelope fa-3x text-primary mb-3"),
              tags$h5("Email Addresses"),
              tags$p("Advanced regex patterns with false-positive filtering")
            ),
            div(
              class = "pattern-card text-center",
              tags$i(class = "fas fa-phone fa-3x text-primary mb-3"),
              tags$h5("Phone Numbers"),
              tags$p("International and US/Canada formats supported")
            ),
            div(
              class = "pattern-card text-center",
              tags$i(class = "fas fa-link fa-3x text-primary mb-3"),
              tags$h5("URLs"),
              tags$p("HTTP/HTTPS, FTP, and www domain detection")
            )
          )
        )
      )
    )
  ),

  # ============================================================================
  # About Tab
  # ============================================================================
  nav_panel(
    title = "About",
    icon = icon("info-circle"),
    layout_columns(
      col_widths = 12,
      card(
        card_header(
          tags$h3(
            tags$i(class = "fas fa-info-circle", style = "margin-right: 0.5rem;"),
            "About Data Extractor",
            style = "margin: 0;"
          )
        ),
        card_body(
          tags$p(
            class = "lead",
            "Shiny Data Extractor is a production-grade, interactive R Shiny application designed to extract emails, phone numbers, and URLs from various data formats."
          ),
          tags$hr(),
          layout_columns(
            col_widths = c(6, 6),
            div(
              tags$h4(
                tags$i(class = "fas fa-star", style = "margin-right: 0.5rem;"),
                "Key Features"
              ),
              tags$ul(
                tags$li("Multi-format file support (CSV, Excel, Text)"),
                tags$li("Advanced pattern recognition"),
                tags$li("Column-specific processing"),
                tags$li("Real-time progress indication"),
                tags$li("Comprehensive error handling"),
                tags$li("Export in multiple formats"),
                tags$li("Dark/Light theme support"),
                tags$li("Responsive mobile design")
              )
            ),
            div(
              tags$h4(
                tags$i(class = "fas fa-rocket", style = "margin-right: 0.5rem;"),
                "Performance"
              ),
              tags$ul(
                tags$li("Handles large files (GB+)"),
                tags$li("Asynchronous processing"),
                tags$li("Memory-efficient chunked reading"),
                tags$li("Progress tracking"),
                tags$li("Responsive user interface"),
                tags$li("Optimized for speed"),
                tags$li("UTF-8 and Latin-1 encoding support"),
                tags$li("Sheet selection for Excel files")
              )
            )
          ),
          tags$hr(),
          card(
            class = "bg-light",
            card_body(
              tags$h4(
                tags$i(class = "fas fa-code", style = "margin-right: 0.5rem;"),
                "Technical Details"
              ),
              tags$p(
                "Built with R Shiny using a modular architecture for maintainability and scalability. Utilizes advanced regex patterns for accurate data extraction and includes comprehensive validation and error handling."
              ),
              tags$p(
                tags$strong("Technology Stack:"),
                " R, Shiny, bslib (Bootstrap 5), DT, readxl, openxlsx, stringr, promises, future"
              ),
              tags$p(
                tags$strong("Version:"),
                " 2.1.0 (UI/UX Enhanced)",
                tags$br(),
                tags$strong("Last Updated:"),
                " November 2025"
              )
            )
          )
        )
      )
    )
  ),

  # ============================================================================
  # Navbar Items (Dark Mode Toggle)
  # ============================================================================
  nav_spacer(),
  nav_item(
    tags$div(
      class = "nav-link",
      style = "cursor: pointer; padding: 0.5rem 1rem;",
      input_dark_mode(
        id = "dark_mode",
        mode = "light",
        style = "display: inline-flex; align-items: center; gap: 0.5rem;"
      ),
      tags$span(
        style = "margin-left: 0.5rem; font-size: 0.9rem;",
        "Theme"
      )
    )
  ),
  nav_item(
    tags$div(
      class = "text-muted small",
      style = "padding: 0.5rem 1rem; display: flex; align-items: center;",
      "© 2025 Data Extractor | Built with ",
      tags$i(class = "fas fa-heart text-danger", style = "margin: 0 0.25rem;"),
      " using R Shiny & bslib"
    )
  )
)
