# ==============================================================================
# Instalación y Actualización de Dependencias
# Shiny Data Extractor - Bootstrap 5
# ==============================================================================

cat("Verificando e instalando dependencias...\n\n")

# Función para instalar/actualizar paquetes
install_or_update <- function(package, min_version = NULL) {
  if (!requireNamespace(package, quietly = TRUE)) {
    cat(paste0("Instalando ", package, "...\n"))
    install.packages(package, repos = "https://cran.rstudio.com/")
  } else {
    current_version <- packageVersion(package)
    cat(paste0(package, " (version ", current_version, ") ya instalado\n"))
    
    # Si se especifica versión mínima, verificar
    if (!is.null(min_version)) {
      if (current_version < min_version) {
        cat(paste0("Actualizando ", package, " a version >= ", min_version, "...\n"))
        install.packages(package, repos = "https://cran.rstudio.com/")
      }
    }
  }
}

# Instalar/actualizar paquetes requeridos
cat("=== PAQUETES CORE ===\n")
install_or_update("shiny", "1.7.0")
install_or_update("bslib", "0.6.0")  # CRÍTICO: necesita >= 0.6.0 para page_navbar()
install_or_update("DT", "0.18")
install_or_update("readxl", "1.4.0")
install_or_update("openxlsx", "4.2.0")
install_or_update("stringr", "1.4.0")

cat("\n=== PAQUETES OPCIONALES (Performance) ===\n")
install_or_update("promises", "1.2.0")
install_or_update("future", "1.25.0")

cat("\n=== VERIFICACIÓN FINAL ===\n")
cat("Cargando librerías...\n")

library(shiny)
library(bslib)
library(DT)
library(readxl)
library(openxlsx)
library(stringr)
library(promises)
library(future)
library(shinyWidgets)
cat("\n✓ Todas las dependencias instaladas correctamente!\n")
cat("\nVersiones instaladas:\n")
cat(paste0("  - shiny: ", packageVersion("shiny"), "\n"))
cat(paste0("  - bslib: ", packageVersion("bslib"), "\n"))
cat(paste0("  - DT: ", packageVersion("DT"), "\n"))
cat(paste0("  - readxl: ", packageVersion("readxl"), "\n"))
cat(paste0("  - openxlsx: ", packageVersion("openxlsx"), "\n"))
cat(paste0("  - stringr: ", packageVersion("stringr"), "\n"))
cat(paste0("  - promises: ", packageVersion("promises"), "\n"))
cat(paste0("  - future: ", packageVersion("future"), "\n"))

# Verificar que page_navbar esté disponible
if (exists("page_navbar", where = "package:bslib", mode = "function")) {
  cat("\n✓ page_navbar() está disponible en bslib!\n")
} else {
  cat("\n✗ WARNING: page_navbar() NO encontrado. Instale bslib >= 0.6.0\n")
  cat("  Ejecute: install.packages('bslib', repos='https://cran.rstudio.com/')\n")
}

cat("\n=== INSTALACIÓN COMPLETADA ===\n")
cat("Ahora puede ejecutar la aplicación con: source('app.R')\n")
