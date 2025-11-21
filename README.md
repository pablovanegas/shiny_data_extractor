# Shiny Data Extractor

Shiny Data Extractor is a **production-grade**, interactive R Shiny application designed to extract emails, phone numbers, and URLs from various data formats. This application features a modern Bootstrap 5 interface (bslib), modular architecture, manual extraction triggers, asynchronous processing, and comprehensive error handling.

## 🚀 Key Features

### Core Functionality
- **Multi-format Support**: Upload and process CSV, Excel (XLSX), and text files
- **Pattern Extraction**: Extract emails, phone numbers, and URLs using advanced regex patterns  
- **Column Selection**: Choose specific columns to process for optimized performance (CSV/Excel files)
- **Manual Trigger**: Explicit "Start Extraction" button prevents unnecessary processing
- **Data Export**: Download results in Excel (.xlsx) or text (.txt) format

### Advanced Capabilities
- **Modular Architecture**: Built with reusable Shiny modules following best practices
- **Lazy Loading**: Extraction only executes on user action, allowing column optimization
- **Asynchronous Processing**: Handle large files without UI freezing using `promises` and `future`
- **Real-time Feedback**: Enhanced notifications with detailed extraction statistics
- **Robust Data Handling**: Prevents dimension reduction bugs with `drop = FALSE` and `intersect()`
- **Enhanced Error Handling**: Comprehensive validation with user-friendly, actionable error messages
- **Dark Mode Toggle**: Switch between light and dark themes instantly
- **4-Card Dashboard**: Visual statistics for Total, Emails, Phone Numbers, and URLs

### Performance & Scalability
- **Chunked Processing**: Handle large datasets (GB+) efficiently with memory-optimized streaming
- **Worker Isolation**: Extraction functions in `global.R` accessible to async workers
- **Multiple Encodings**: Automatic detection and support for UTF-8 and Latin-1 character sets
- **File Validation**: Comprehensive checks for file format, content, and column existence
- **URL Truncation**: Smart table display with tooltips for long URLs

## 📁 Project Structure

```
shiny_data_extractor/
├── app.R                    # Application launcher
├── global.R                 # Global functions and configurations
├── ui.R                     # User interface definition
├── server.R                 # Server logic (modular)
├── modules/                 # Shiny modules directory
│   ├── file_input_module.R      # File upload and configuration
│   ├── data_display_module.R    # Data table and results display
│   ├── download_module.R        # Export functionality
│   └── data_extraction_module.R # Core extraction logic
├── www/                     # Static web assets
│   └── styles.css               # Custom CSS styles
├── README.md               # This file
├── REQUIREMENTS.md         # Package dependencies
└── data_extractor.Rproj   # RStudio project file
```

## 🛠️ Installation & Setup

### Quick Start
1. **Clone or download** this repository
2. **Open R/RStudio** and set working directory to the project folder
3. **Run the application**:
   ```r
   source("app.R")
   ```
   This will automatically install missing packages and launch the app.

### Manual Package Installation
```r
# Required packages
install.packages(c(
  "shiny", "DT", "shinythemes", "shinyWidgets", 
  "readxl", "openxlsx", "stringr"
))

# Optional (for enhanced performance)
install.packages(c("promises", "future"))
```

See [REQUIREMENTS.md](REQUIREMENTS.md) for detailed installation instructions.

## 📖 User Guide

### Step-by-Step Usage

1. **Select Extraction Types**: Choose what to extract (Emails, Phone Numbers, URLs) from the multi-select dropdown
2. **Choose File Format**: Select CSV, XLSX, or TXT based on your file type
3. **Upload File**: Browse and select your data file (drag-and-drop supported)
4. **Configure Settings**:
   - **CSV**: Select appropriate delimiter (comma, semicolon, tab, pipe, etc.)
   - **Excel**: Specify sheet number to process (default: 1)
   - **Text**: Encoding auto-detected (UTF-8/Latin-1)
5. **Select Columns**: Choose specific columns to process (optimizes performance by reducing data scope)
6. **Click "Start Extraction"**: Manual trigger ensures you can optimize before processing
7. **View Results**: Extracted data displays in an interactive table with 4 summary cards
8. **Download**: Export results as Excel (.xlsx) or text (.txt) with original filename preserved

### Supported File Types

| Format | Extensions | Features |
|--------|------------|----------|
| **CSV** | `.csv` | Custom delimiters, encoding detection |
| **Excel** | `.xlsx` | Multi-sheet support, sheet selection |
| **Text** | `.txt` | Plain text processing, encoding detection |

### Extraction Patterns

- **Emails**: Advanced regex pattern with false-positive filtering
- **Phone Numbers**: International and US/Canada formats supported
- **URLs**: HTTP/HTTPS, FTP, and www domains

## 🏗️ Architecture & Technical Details

### Modular Design (v2.1 Architecture)
The application is built using **Shiny Modules** following separation of concerns:

- **File Input Module** (`file_input_module.R`): Handles upload, validation, delimiter/sheet configuration, and column selection
- **Data Extraction Module** (`data_extraction_module.R`): **Manual trigger architecture** with lazy loading - extraction only fires on button click
- **Data Display Module** (`data_display_module.R`): Interactive DT table with URL truncation, tooltips, and filtering options
- **Download Module** (`download_module.R`): Export functionality with format selection and error handling

### Key Architectural Improvements (v2.1)
- ✅ **Lazy Loading Pattern**: Extraction waits for explicit user action (eliminates eager loading bug)
- ✅ **Worker-Safe Functions**: All extraction functions moved to `global.R` for async worker access
- ✅ **Dimension Safety**: Uses `drop = FALSE` and `intersect()` to prevent single-column collapse bugs
- ✅ **Enhanced Notifications**: HTML-structured feedback with icons, progress, and detailed results
- ✅ **Modern UI (Bootstrap 5)**: Built with `bslib >= 0.6.0` using `page_navbar`, `layout_sidebar`, and `value_box`

### Performance Optimizations
- **Asynchronous Processing**: Non-blocking extraction using `promises` and `future` with `multisession` plan
- **Chunked Processing**: `extract_data_chunked()` handles large files in memory-efficient batches
- **Smart Column Filtering**: Only processes user-selected columns (true optimization)
- **Reactive Invalidation Control**: Manual trigger prevents cascade re-execution

### Enhanced Error Handling & Validation
- File format validation with MIME type checking
- Encoding detection with automatic fallback (UTF-8 → Latin-1)
- Column existence validation with `intersect()`
- Empty data detection with user-friendly messages
- Processing status tracking with visual indicators
- Detailed error notifications with actionable suggestions

## 🔧 Development & Customization

### Adding New Extraction Patterns
1. **Add extraction function to `global.R`** (ensures async worker access):
   ```r
   extract_custom_pattern <- function(text) {
     # Your regex logic here
     pattern <- "your_regex_pattern"
     matches <- unlist(str_extract_all(text, pattern))
     return(unique(matches[!is.na(matches)]))
   }
   ```
2. **Update extraction types** in `file_input_module.R` (UI pickerInput)
3. **Modify extraction logic** in `extract_data_chunked()` function (`global.R`)
4. **Add value box** in `ui.R` and corresponding `renderText()` in `server.R`

### Customizing UI Themes
- **Modify Bootstrap 5 theme** in `ui.R` (`bs_theme()` configuration)
- **Custom CSS** in `www/styles.css` for component-specific styling
- **Dark mode** toggle already implemented via `input_dark_mode()`
- **Color schemes**: Update semantic colors in `bs_theme()` (primary, success, warning, etc.)

### Performance Tuning
- **Adjust chunk size** in `extract_data_chunked()` (default: 10,000 items per batch)
- **Configure `future` plan** in `global.R` (options: `sequential`, `multisession`, `multicore`)
- **Optimize regex patterns** for specific use cases to reduce false positives
- **Column pre-filtering**: Encourage users to select fewer columns for faster processing

## 🐛 Troubleshooting

### Common Issues

**App won't start**
- Check R version (>= 4.0.0 required)
- Install missing packages via `app.R`

**Large file processing is slow**
- Increase available memory
- Install `promises` and `future` packages
- Consider file preprocessing

**Extraction results are incomplete**
- Verify file encoding (try different character sets)
- Check column selection for structured data
- Review extraction pattern requirements

**Download fails**
- Ensure write permissions in download directory
- Check available disk space
- Verify extracted data is not empty

## 📊 Performance Benchmarks

| File Size | Records | Processing Time* | Memory Usage* |
|-----------|---------|------------------|---------------|
| 1 MB | ~10K | 2-5 seconds | ~50 MB |
| 10 MB | ~100K | 10-30 seconds | ~200 MB |
| 100 MB | ~1M | 1-3 minutes | ~500 MB |
| 1 GB | ~10M | 5-15 minutes | ~2 GB |

*Approximate values, depends on system specifications and data complexity

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes following the modular architecture
4. Test thoroughly with various file types and sizes
5. Submit a pull request with detailed description

## 📄 License

This project is open source. Feel free to use, modify, and distribute according to your needs.

## 🆕 Version History

### v2.1.0 (Current - November 2025)
**"Manual Trigger & UI/UX Enhancement Release"**
- 🎯 **Manual Extraction Trigger**: Lazy loading architecture - extraction only on explicit button click
- 🐛 **Bug Fixes**: Eliminated eager loading bug and dimension reduction issues
- 🎨 **4-Card Dashboard**: Added missing "URLs Found" value box for complete statistics
- 💬 **Enhanced Notifications**: Rich HTML feedback with detailed extraction results breakdown
- 📊 **URL Truncation**: Smart table display with tooltips for long URLs (50-char limit)
- 🔒 **Robust Column Handling**: `drop = FALSE` and `intersect()` prevent structural bugs
- ⚡ **Worker-Safe Architecture**: Extraction functions in `global.R` for async access
- 🎨 **Bootstrap 5 UI**: Modern `bslib` implementation with responsive design

### v2.0.0 (Previous)
- ✅ Complete modular refactor using Shiny modules
- ✅ Enhanced error handling and validation  
- ✅ Asynchronous processing support
- ✅ Column selection for structured data
- ✅ Improved extraction patterns
- ✅ Results summary and statistics
- ✅ Memory-efficient chunked processing

### v1.0.0 (Initial Release)
- Basic file upload and processing
- Simple extraction patterns
- Basic download functionality

