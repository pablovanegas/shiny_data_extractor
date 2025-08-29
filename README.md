# Shiny Data Extractor

Shiny Data Extractor is a **production-grade**, interactive R Shiny application designed to extract emails, phone numbers, and URLs from various data formats. This application has been completely refactored with a modular architecture, enhanced error handling, asynchronous processing capabilities, and an intuitive user interface.

## 🚀 Key Features

### Core Functionality
- **Multi-format Support**: Upload and process CSV, Excel (XLSX), and text files
- **Pattern Extraction**: Extract emails, phone numbers, and URLs using advanced regex patterns  
- **Column Selection**: Choose specific columns to process (CSV/Excel files)
- **Data Export**: Download results in Excel or text format

### Advanced Capabilities
- **Modular Architecture**: Built with reusable Shiny modules for maintainability
- **Asynchronous Processing**: Handle large files without UI freezing
- **Progress Indication**: Real-time progress bars during file processing
- **Enhanced Error Handling**: Comprehensive validation and user-friendly error messages
- **Results Summary**: Display extraction statistics and status
- **Dark Mode**: Toggle between light and dark themes

### Performance & Scalability
- **Chunked Processing**: Handle large datasets (GB+) efficiently
- **Memory Optimization**: Streaming approach for reading large files
- **Multiple Encodings**: Support for UTF-8 and Latin-1 character sets
- **File Validation**: Comprehensive checks for file format and content

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

1. **Select Extraction Types**: Choose what to extract (Emails, Phone Numbers, URLs)
2. **Choose File Type**: Select CSV, XLSX, or TXT
3. **Upload File**: Browse and select your data file
4. **Configure Settings**:
   - **CSV**: Select appropriate delimiter (comma, semicolon, tab, etc.)
   - **Excel**: Specify sheet number to process
5. **Select Columns**: Choose which columns to process (for structured data)
6. **View Results**: Extracted data appears in the main panel with summary statistics
7. **Download**: Export results as Excel (.xlsx) or text (.txt) file

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

### Modular Design
The application is built using **Shiny Modules** for better code organization:

- **File Input Module**: Handles upload, validation, and configuration
- **Data Display Module**: Manages results table and summary statistics  
- **Download Module**: Manages export functionality with error handling
- **Data Extraction Module**: Core processing logic with chunked processing

### Performance Optimizations
- **Asynchronous Processing**: Using `promises` and `future` packages
- **Chunked File Reading**: Process large files in memory-efficient chunks
- **Progress Indication**: Real-time feedback during processing
- **Error Recovery**: Comprehensive error handling and validation

### Enhanced Error Handling
- File format validation
- Encoding detection and fallback
- Memory usage warnings
- User-friendly error messages
- Processing status indicators

## 🔧 Development & Customization

### Adding New Extraction Patterns
1. Add extraction function to `global.R`
2. Update extraction types in UI
3. Modify extraction logic in `data_extraction_module.R`

### Customizing UI Themes
- Modify `www/styles.css` for custom styling
- Update theme selection in `ui.R`
- Add new Bootstrap themes via `shinythemes`

### Performance Tuning
- Adjust chunk size in `data_extraction_module.R`
- Configure `future` plan in `global.R`
- Optimize regex patterns for specific use cases

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

### v2.0.0 (Current)
- ✅ Complete modular refactor using Shiny modules
- ✅ Enhanced error handling and validation  
- ✅ Asynchronous processing support
- ✅ Progress indication and status feedback
- ✅ Column selection for structured data
- ✅ Improved extraction patterns
- ✅ Results summary and statistics
- ✅ Memory-efficient chunked processing

### v1.0.0 (Previous)
- Basic file upload and processing
- Simple extraction patterns
- Basic download functionality

