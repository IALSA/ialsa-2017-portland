# knitr::stitch_rmd(script="./___/___.R", output="./___/___/___.md")
# These first few lines run only when the file is run in RStudio, !!NOT when an Rmd/Rnw file calls it!!
rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.
cat("\f") # clear console 

# This script reads two files: patient event table + location map. 
rm(list=ls(all=TRUE)) #Clear the memory of variables from previous run. This is not called by knitr, because it's above the first chunk.

# ---- load-packages -----------------------------------------------------------
library(ggplot2) #For graphing
library(magrittr) #Pipes
library(dplyr) # for shorter function names. but still prefer dplyr:: stems
library(knitr) # dynamic documents
library(rmarkdown) # dynamic
library(kableExtra) # enhanced tables, see http://haozhu233.github.io/kableExtra/awesome_table_in_html.html
# library(TabularManifest) # exploratory data analysis, see https://github.com/Melinae/TabularManifest
requireNamespace("knitr", quietly=TRUE)
requireNamespace("scales", quietly=TRUE) #For formating values in graphs
requireNamespace("RColorBrewer", quietly=TRUE)
requireNamespace("dplyr", quietly=TRUE)
requireNamespace("DT", quietly=TRUE) # for dynamic tables
# requireNamespace("plyr", quietly=TRUE)
# requireNamespace("reshape2", quietly=TRUE) #For converting wide to long
# requireNamespace("mgcv, quietly=TRUE) #For the Generalized Additive Model that smooths the longitudinal graphs.

# ---- load-sources ------------------------------------------------------------
#Load any source files that contain/define functions, but that don't load any other types of variables
#   into memory.  Avoid side effects and don't pollute the global environment.
source("./manipulation/function-support.R")  # assisting functions for data wrangling and testing
source("./manipulation/object-glossary.R")   # object definitions
source("./scripts/common-functions.R")       # reporting functions and quick views
source("./scripts/graphing/graph-presets.R") # font and color conventions

# ---- declare-globals --------------------------------------------------------
# catalog containing model results
path_catalog_wide <- "./model-output/physical-cognitive/2-catalog-wide.csv"
path_catalog_long <- "./model-output/physical-cognitive/3-catalog-long.csv"

path_forrest_table <- "./reports/physical-cognitive/forest/table-data/pulmonary-meta.csv"

options(show.signif.stars=F) #Turn off the annotations on p-values
print_format <- "pandoc"
# print_format <- "html"

# ---- load-data -------------------------------------------------------------
catalog_wide <- readr::read_csv(path_catalog_wide,col_names = TRUE)
catalog_long <- readr::read_csv(path_catalog_long,col_names = TRUE)
forest_meta  <- readr::read_csv(path_forrest_table,col_names = TRUE)

# ---- inspect-data -------------------------------------------------------------
forest_meta %>% glimpse()

# ---- tweak-data --------------------------------------------------------------
# perform custom touch-up, local to physical-cognitive track
catalog_wide <- catalog_wide %>%
  # dplyr::filter(!process_a == "fev100") %>% # remove temporary items (usually for testing)
  dplyr::filter(model_type == "aehplus",model_number=="b1")  # limit the scope

catalog_long <- catalog_long %>%
  # dplyr::filter(!process_a == "fev100") %>% # remove temporary items (usually for testing)
  dplyr::filter(model_type == "aehplus",model_number=="b1")  # limit the scope



# ---- basic-table --------------------------------------------------------------

# ---- basic-graph --------------------------------------------------------------

# Sonata form report structure
# ---- dev-a-0 ---------------------------------
# ---- dev-a-1 ---------------------------------
# ---- dev-a-2 ---------------------------------
# ---- dev-a-3 ---------------------------------
# ---- dev-a-4 ---------------------------------
# ---- dev-a-5 ---------------------------------

# ---- dev-b-0 ---------------------------------
# ---- dev-b-1 ---------------------------------
# ---- dev-b-2 ---------------------------------
# ---- dev-b-3 ---------------------------------
# ---- dev-b-4 ---------------------------------
# ---- dev-b-5 ---------------------------------

# ---- recap-0 ---------------------------------
# ---- recap-1 ---------------------------------
# ---- recap-2 ---------------------------------
# ---- recap-3 ---------------------------------


# ---- publish ---------------------------------------
path_report_1 <- "./sandbox/criterion-scale-effect/criterion-scale-effect.Rmd"
# path_report_2 <- "./reports/*/report_2.Rmd"
# allReports <- c(path_report_1,path_report_2)
allReports <- c(path_report_1)

pathFilesToBuild <- c(allReports)
testit::assert("The knitr Rmd files should exist.", base::file.exists(pathFilesToBuild))
# Build the reports
for( pathFile in pathFilesToBuild ) {
  
  rmarkdown::render(input = pathFile,
                    output_format=c(
                      "html_document" # set print_format <- "html" in seed-study.R
                      # "pdf_document"
                      # ,"md_document"
                      # "word_document" # set print_format <- "pandoc" in seed-study.R
                    ),
                    clean=TRUE)
}

