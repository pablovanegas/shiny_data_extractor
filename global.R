library(shiny)
library(readxl)
library(stringr)
library(openxlsx)
library(shinythemes)
library(shinyWidgets)
library(DT)
library(promises)
library(future)

# Configure future for async processing
plan(multisession)

# Source all modules
source("modules/file_input_module.R")
source("modules/data_display_module.R")
source("modules/download_module.R")
source("modules/data_extraction_module.R")

# Enhanced function to extract email addresses with validation
extract_emails <- function(text) {
  if (is.null(text) || length(text) == 0) {
    return(character(0))
  }
  
  # Convert to character and handle NAs
  text <- as.character(text)
  text <- text[!is.na(text)]
  
  if (length(text) == 0) {
    return(character(0))
  }
  
  tryCatch({
    # Enhanced email pattern (more comprehensive)
    email_pattern <- "\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}\\b"
    emails <- unlist(str_extract_all(text, email_pattern))
    
    # Filter out obvious false positives
    emails <- emails[!grepl("\\.(jpg|png|gif|pdf|doc|docx)@", emails, ignore.case = TRUE)]
    
    return(unique(emails[!is.na(emails)]))
  }, error = function(e) {
    warning(paste("Error extracting emails:", e$message))
    return(character(0))
  })
}

# Enhanced function to extract phone numbers with validation
extract_phone_numbers <- function(text) {
  if (is.null(text) || length(text) == 0) {
    return(character(0))
  }
  
  # Convert to character and handle NAs
  text <- as.character(text)
  text <- text[!is.na(text)]
  
  if (length(text) == 0) {
    return(character(0))
  }
  
  tryCatch({
    # Enhanced phone pattern (more flexible)
    phone_patterns <- c(
      "\\+?1?[-.\\s]?\\(?[0-9]{3}\\)?[-.\\s]?[0-9]{3}[-.\\s]?[0-9]{4}",  # US/Canada
      "\\+?[0-9]{1,3}[-.\\s]?\\(?[0-9]{1,4}\\)?[-.\\s]?[0-9]{1,4}[-.\\s]?[0-9]{1,4}[-.\\s]?[0-9]{1,4}"  # International
    )
    
    phone_numbers <- character(0)
    for (pattern in phone_patterns) {
      phones <- unlist(str_extract_all(text, pattern))
      phone_numbers <- c(phone_numbers, phones)
    }
    
    # Filter out obvious false positives (like dates, IDs, etc.)
    phone_numbers <- phone_numbers[nchar(gsub("[^0-9]", "", phone_numbers)) >= 7]
    
    return(unique(phone_numbers[!is.na(phone_numbers)]))
  }, error = function(e) {
    warning(paste("Error extracting phone numbers:", e$message))
    return(character(0))
  })
}

# Enhanced function to extract URLs with validation
extract_urls <- function(text) {
  if (is.null(text) || length(text) == 0) {
    return(character(0))
  }
  
  # Convert to character and handle NAs
  text <- as.character(text)
  text <- text[!is.na(text)]
  
  if (length(text) == 0) {
    return(character(0))
  }
  
  tryCatch({
    # Enhanced URL patterns
    url_patterns <- c(
      "https?://(?:[-\\w.]|(?:%[a-fA-F0-9]{2}))+",  # HTTP/HTTPS
      "ftp://(?:[-\\w.]|(?:%[a-fA-F0-9]{2}))+",     # FTP
      "www\\.(?:[-\\w.]|(?:%[a-fA-F0-9]{2}))+"      # www. domains
    )
    
    urls <- character(0)
    for (pattern in url_patterns) {
      extracted <- unlist(str_extract_all(text, pattern))
      urls <- c(urls, extracted)
    }
    
    # Clean up URLs and validate
    urls <- urls[nchar(urls) > 5]  # Minimum reasonable URL length
    urls <- unique(urls[!is.na(urls)])
    
    return(urls)
  }, error = function(e) {
    warning(paste("Error extracting URLs:", e$message))
    return(character(0))
  })
}

# Enhanced function to read files with comprehensive error handling and validation
process_file <- function(file_path, file_type, sep = ",", sheet = 1) {
  # Validate inputs
  if (is.null(file_path) || !file.exists(file_path)) {
    stop("File path does not exist or is invalid")
  }
  
  if (!file_type %in% c("csv", "xlsx", "txt")) {
    stop("Unsupported file type. Must be one of: csv, xlsx, txt")
  }
  
  # Check file size (warn for files > 100MB)
  file_size_mb <- file.info(file_path)$size / (1024^2)
  if (file_size_mb > 100) {
    warning(paste("Large file detected:", round(file_size_mb, 2), "MB. Processing may take some time."))
  }
  
  tryCatch({
    if (file_type == "csv") {
      # Enhanced CSV reading with encoding detection
      data <- tryCatch({
        read.csv(file_path, sep = sep, encoding = "UTF-8", stringsAsFactors = FALSE)
      }, error = function(e) {
        # Try with different encoding if UTF-8 fails
        tryCatch({
          read.csv(file_path, sep = sep, encoding = "latin1", stringsAsFactors = FALSE)
        }, error = function(e2) {
          stop(paste("Failed to read CSV file. Please check the separator and file format.", 
                    "Original error:", e$message))
        })
      })
      
      if (nrow(data) == 0) {
        stop("CSV file appears to be empty")
      }
      
    } else if (file_type == "xlsx") {
      # Enhanced Excel reading with sheet validation
      if (!is.numeric(sheet) || sheet < 1) {
        stop("Sheet number must be a positive integer")
      }
      
      # Check if sheet exists
      tryCatch({
        sheet_names <- readxl::excel_sheets(file_path)
        if (sheet > length(sheet_names)) {
          stop(paste("Sheet", sheet, "does not exist. Available sheets:", 
                    paste(seq_along(sheet_names), collapse = ", ")))
        }
      }, error = function(e) {
        stop(paste("Cannot read Excel file structure:", e$message))
      })
      
      data <- read_xlsx(file_path, sheet = sheet)
      
      if (nrow(data) == 0) {
        stop("Excel sheet appears to be empty")
      }
      
    } else if (file_type == "txt") {
      # Enhanced text file reading
      data <- tryCatch({
        readLines(file_path, encoding = "UTF-8", warn = FALSE)
      }, error = function(e) {
        # Try with different encoding if UTF-8 fails
        tryCatch({
          readLines(file_path, encoding = "latin1", warn = FALSE)
        }, error = function(e2) {
          stop(paste("Failed to read text file:", e$message))
        })
      })
      
      if (length(data) == 0) {
        stop("Text file appears to be empty")
      }
      
      # Remove completely empty lines
      data <- data[nzchar(trimws(data))]
      
      if (length(data) == 0) {
        stop("Text file contains no readable content")
      }
    }
    
    return(data)
    
  }, error = function(e) {
    # Re-throw with more context
    stop(paste("Error processing", toupper(file_type), "file:", e$message))
  })
}
