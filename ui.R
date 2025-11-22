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
      # Statistics value boxes
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
                tags$p("Choose specific columns to process for structured data (CSV/Excel files). This optimizes performance.")
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
      
      # Supported Formats & Capabilities (Simplified for better UX)
      layout_columns(
        col_widths = c(6, 6),
        card(
          card_header(tags$h5(tags$i(class = "fas fa-file", style="margin-right:0.5rem;"), "Supported Formats")),
          card_body(
            tags$ul(
              tags$li(tags$strong("CSV:"), " Auto-detection of delimiters, UTF-8 support."),
              tags$li(tags$strong("Excel (XLSX):"), " Multi-sheet support with schema validation."),
              tags$li(tags$strong("Text (TXT):"), " Unstructured text processing.")
            )
          )
        ),
        card(
          card_header(tags$h5(tags$i(class = "fas fa-magic", style="margin-right:0.5rem;"), "Extraction Engine")),
          card_body(
            tags$ul(
              tags$li(tags$strong("Smart Regex:"), " Filters out image files (e.g., user.png@domain) and invalid phones."),
              tags$li(tags$strong("Async Core:"), " Processes gigabyte-sized files in background without freezing the UI.")
            )
          )
        )
      )
    )
  ),
  
  # ============================================================================
  # About Tab (PROFESSIONAL PORTFOLIO VERSION)
  # ============================================================================
  nav_panel(
    title = "About",
    icon = icon("info-circle"),
    layout_columns(
      col_widths = 12,
      
      # Hero Section & GitHub CTA
      card(
        class = "border-0 shadow-sm",
        card_body(
          div(
            class = "text-center p-4",
            tags$h2("Shiny Data Extractor", class = "display-5 fw-bold text-primary mb-3"),
            tags$p(class = "lead text-muted mb-4", 
                   "A production-grade, open-source tool designed to streamline data scraping and cleaning workflows for Data Scientists."),
            
            # GitHub Button
            div(
              class = "text-center",
              style = "margin: 2rem 0;",
              tags$a(
                href = "https://github.com/pablovanegas/shiny_data_extractor", # PLACEHOLDER: REEMPLAZAR
                target = "_blank",
                class = "btn btn-primary btn-lg",
                style = "padding: 0.75rem 2rem; font-size: 1.1rem; box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);",
                tags$i(class = "fab fa-github", style = "margin-right: 0.75rem; font-size: 1.3rem;"),
                "View Source Code on GitHub",
                tags$i(class = "fas fa-external-link-alt", style = "margin-left: 0.5rem; font-size: 0.9rem;")
              )
            )
          )
        )
      ),
      
      # Value Proposition Section (Adapted from Agent suggestion)
      card(
        card_header(
          tags$h4(
            tags$i(class = "fas fa-lightbulb", style = "margin-right: 0.5rem; color: var(--bs-warning);"),
            "Why This Tool Matters",
            style = "margin: 0;"
          )
        ),
        card_body(
          layout_columns(
            col_widths = c(6, 6),
            
            # Use Cases
            div(
              tags$h5(
                tags$i(class = "fas fa-chart-line", style = "margin-right: 0.5rem; color: var(--bs-primary);"),
                "Real-World Applications"
              ),
              tags$ul(
                class = "list-unstyled",
                style = "line-height: 1.8;",
                tags$li(tags$i(class = "fas fa-check-circle text-success me-2"), tags$strong("Lead Generation:"), " Extract contacts from business directories."),
                tags$li(tags$i(class = "fas fa-check-circle text-success me-2"), tags$strong("Data Cleaning:"), " Normalize messy datasets before analysis."),
                tags$li(tags$i(class = "fas fa-check-circle text-success me-2"), tags$strong("Research Automation:"), " Accelerate data prep for NLP projects.")
              )
            ),
            
            # Architecture Highlights (For Tech Recruiters)
            div(
              tags$h5(
                tags$i(class = "fas fa-code-branch", style = "margin-right: 0.5rem; color: var(--bs-info);"),
                "Scalable Architecture"
              ),
              tags$ul(
                class = "list-unstyled",
                style = "line-height: 1.8;",
                tags$li(tags$i(class = "fas fa-layer-group text-secondary me-2"), tags$strong("Modular:"), " Decoupled UI/Logic for easy maintenance."),
                tags$li(tags$i(class = "fas fa-bolt text-secondary me-2"), tags$strong("Async Pipeline:"), " Non-blocking processes for heavy workloads."),
                tags$li(tags$i(class = "fas fa-robot text-secondary me-2"), tags$strong("Extensible:"), " Ready for NLP model integration.")
              )
            )
          )
        )
      ),
      
      # Technical Limitations (Honesty Section)
      card(
        class = "bg-light border-start border-warning border-4",
        card_body(
          tags$h5(tags$i(class = "fas fa-exclamation-triangle text-warning me-2"), "Big Data Constraints & Roadmap"),
          tags$p(class = "small text-muted mb-0", 
                 "Current architecture relies on in-memory processing (R base). For enterprise-scale datasets (>5GB), future versions will integrate SQL backends or out-of-core libraries like `arrow` or `polars` to bypass RAM limitations.")
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
      "© 2025 Data Extractor"
    )
  )
)