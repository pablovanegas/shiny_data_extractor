# Shiny Data Extractor - Package Requirements

## Required R Packages

The following R packages are required to run the Shiny Data Extractor application:

### Core Packages (Required)
- `shiny` (>= 1.7.0) - Web application framework
- `DT` (>= 0.18) - Interactive data tables
- `shinythemes` (>= 1.2.0) - Bootstrap themes for Shiny
- `shinyWidgets` (>= 0.7.0) - Enhanced UI widgets
- `readxl` (>= 1.4.0) - Read Excel files
- `openxlsx` (>= 4.2.0) - Write Excel files
- `stringr` (>= 1.4.0) - String manipulation

### Optional Packages (For Enhanced Performance)
- `promises` (>= 1.2.0) - Asynchronous programming
- `future` (>= 1.25.0) - Parallel processing

## Installation Instructions

### Automatic Installation
Run the application using `app.R` - it will automatically install missing packages.

### Manual Installation
```r
# Install required packages
install.packages(c(
  "shiny", "DT", "shinythemes", "shinyWidgets", 
  "readxl", "openxlsx", "stringr"
))

# Install optional packages for better performance
install.packages(c("promises", "future"))
```

### Using renv (Recommended for Development)
```r
# Initialize renv project
renv::init()

# Install packages
renv::install(c(
  "shiny", "DT", "shinythemes", "shinyWidgets", 
  "readxl", "openxlsx", "stringr", "promises", "future"
))

# Create snapshot
renv::snapshot()
```

## System Requirements
- R version >= 4.0.0
- Internet connection (for initial package installation)
- Web browser (Chrome, Firefox, Safari, Edge)

## Memory Requirements
- Minimum: 2GB RAM
- Recommended: 4GB+ RAM for large files (>100MB)
- For files >1GB: 8GB+ RAM recommended

## Supported File Formats
- **CSV**: Comma-separated values with customizable delimiters
- **Excel (XLSX)**: Microsoft Excel files with sheet selection
- **Text (TXT)**: Plain text files with UTF-8 or Latin-1 encoding
