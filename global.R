library(shiny)
library(readxl)
library(stringr)
library(openxlsx)

# Función para extraer correos electrónicos
extract_emails <- function(text) {
  email_pattern <- "([_a-z0-9-]+(?:\\.[_a-z0-9-]+)*@[a-z0-9-]+(?:\\.[a-z0-9-]+)*(?:\\.[a-z]{2,63}))"
  emails <- unlist(str_extract_all(text, email_pattern))
  return(unique(emails))
}

# Función para extraer números de teléfono
extract_phone_numbers <- function(text) {
  phone_pattern <- "\\+?[0-9]{1,3}[-.\\s]?\\(?[0-9]{1,4}\\)?[-.\\s]?[0-9]{1,4}[-.\\s]?[0-9]{1,4}[-.\\s]?[0-9]{1,4}"
  phone_numbers <- unlist(str_extract_all(text, phone_pattern))
  return(unique(phone_numbers))
}

# Función para leer el archivo y extraer datos
process_file <- function(file_path, file_type, sep = ",", sheet = 1) {
  if (file_type == "csv") {
    data <- read.csv(file_path, sep = sep, encoding = "UTF-8")
  } else if (file_type == "xlsx") {
    data <- read_xlsx(file_path, sheet = sheet)
  } else if (file_type == "txt") {
    data <- readLines(file_path, encoding = "UTF-8")
  }
  return(data)
}
