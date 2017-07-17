# the purpose of this script is to create a data transfer object (dto), which will hold all data and metadata from each candidate study of the exercise

# run the line below to stitch a basic html output. For elaborated report, run the corresponding .Rmd file
# knitr::stitch_rmd(script="./manipulation/0-ellis-island.R", output="./manipulation/stitched-output/0-ellis-island.md")
#These first few lines run only when the file is run in RStudio, !!NOT when an Rmd/Rnw file calls it!!
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.
cat("\f") # clear console

# ---- load-sources ------------------------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.  Ideally, no real operations are performed.
source("./scripts/mplus/group-variables.R")
source("./scripts/mplus/extraction-functions-auto.R")
# source("./scripts/common-functions.R")

# ---- load-packages -----------------------------------------------------------
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(magrittr) #Pipes
library(MplusAutomation)
library(IalsaSynthesis)

# ---- declare-globals ---------------------------------------------------
path_folder <- "./model-output/physical-physical/studies/"
path_save <- "./model-output/physical-physical/0-catalog-raw"

# Verify these packages are available on the machine, but their functions need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
requireNamespace("ggplot2")
requireNamespace("tidyr")
requireNamespace("dplyr") #Avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
requireNamespace("testit") #For asserting conditions meet expected patterns.

# ---- utility-functions -------------------------------------------------
# functions local to this script are stored in this chunk
# takes in a vector of paths and collects model results from the .out file

collect_one_study <- function(
   lst          # list object (brocken by studies) with paths to model outputs
  ,study        # name of the study to be passed for extraction
  ,column_names # character vector with names of items to be extracted from the output
  ,save_folder  # folder where the extracted results shall be placed
){
  ## Values for testing and development
  # paths_out    <- list_path_out[["eas"]]
  # lst          <- list_path_out
  # study        <- "elsa"
  # column_names <- selected_results
  # save_folder  <- path_folder
  
  # create a file to be populated, this helps organize model output
  results <- data.frame(matrix(NA, ncol = length(column_names) ))
  names(results) <- column_names
  #  populate the `results` mold for all models of a given study
  for(i in seq_along(lst[[study]]) ){
    # for(i in 50:50){
    # i <- 3; study = "elsa"
    (collected <- collect_result(path = lst[[study]][i] ) )
    (collected_names <- names(collected))
    results[i, collected_names] <- collected
  }
  # save the parsed results near the raw outputs
  write.csv(results,  paste0(save_folder,"/0-parsed-results-",study,".csv"), row.names=F)
  return(results)
}
# Demonstrate usage:
# collect_one_study(
#    lst          = list_path_out                          
#   ,study        = "eas"                     
#   ,column_names = selected_results                       
#   ,save_folder  = path_folder                     
# )

# ---- load-data ---------------------------------------------------------------
# create a list object broken by study, containing paths to model outputs
list_path_out <-list(
   "eas"   = list.files(file.path(path_folder,"eas"),full.names=T, recursive=T, pattern="out$")
  ,"elsa"  = list.files(file.path(path_folder,"elsa"),full.names=T, recursive=T, pattern="out$")
  ,"hrs"   = list.files(file.path(path_folder,"hrs"),full.names=T, recursive=T, pattern="out$")
  ,"ilse"  = list.files(file.path(path_folder,"ilse"),full.names=T, recursive=T, pattern="out$")
  ,"lasa"  = list.files(file.path(path_folder,"lasa"),full.names=T, recursive=T, pattern="out$")
  ,"map"   = list.files(file.path(path_folder,"map"),full.names=T, recursive=T, pattern="out$")
  ,"nuage" = list.files(file.path(path_folder,"nuage"),full.names=T, recursive=T, pattern="out$")
  ,"octo"  = list.files(file.path(path_folder,"octo"),full.names=T, recursive=T, pattern="out$")
  ,"satsa" = list.files(file.path(path_folder,"satsa"),full.names=T, recursive=T, pattern="out$")
)

# ---- inspect-data ------------------------------------------------
list_path_out[["elsa"]]
path <- list_path_out[["elsa"]][1]
path <- list_path_out[["nuage"]][1]

# ---- tweak-data --------------------------------------------------
# remove models that did not terminate normaly
# at this point, detection is manual
a <- list_path_out[["elsa"]]
b <- a[grepl("b1_female_aehplus_grip_gait.out$", a)]
list_path_out[["elsa"]] <- setdiff(list_path_out[["elsa"]], b)

# ---- parse-model-outputs --------------------------------------------
collect_one_study(list_path_out,"eas",   selected_results, path_folder)
collect_one_study(list_path_out,"elsa",  selected_results, path_folder)
collect_one_study(list_path_out,"hrs",   selected_results, path_folder)
collect_one_study(list_path_out,"ilse",  selected_results, path_folder)
collect_one_study(list_path_out,"lasa",  selected_results, path_folder)
collect_one_study(list_path_out,"map",   selected_results, path_folder)
collect_one_study(list_path_out,"nuage", selected_results, path_folder)
collect_one_study(list_path_out,"octo",  selected_results, path_folder)
collect_one_study(list_path_out,"satsa", selected_results, path_folder)

# ---- assemble-catalog ---------------------------------------------------------
# create a path to the folder one step above from the study specific within project
a <- strsplit(path_folder,"/")[[1]]
b <- a[1:(length(a)-1)]
path_one_up <- paste0(paste(b,collapse="/"),"/")
# list the files that conform to a certain structure
(combine_studies <- list.files(path_folder, pattern = "^0-parsed-results-\\w+\\.csv$", full.names =T) )
# create a 
dtos <- list()
for(i in seq_along(combine_studies)){
  dtos[[i]] <- read.csv(combine_studies[i], header=T, stringsAsFactors = F)
}
# combine results files from each study
catalog <- dplyr::bind_rows(dtos)

# ---- save-to-disk ------------------------------------------------------------
write.csv(catalog,  paste0(path_save,".csv"), row.names=F)



