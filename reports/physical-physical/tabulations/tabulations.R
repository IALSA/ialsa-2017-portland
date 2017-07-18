# The purpose of this script is to print various tabulations of model results

# run the line below to stitch a basic html output. For elaborated report, run the corresponding .Rmd file
# knitr::stitch_rmd(script="./manipulation/0-ellis-island.R", output="./manipulation/stitched-output/0-ellis-island.md")
#These first few lines run only when the file is run in RStudio, !!NOT when an Rmd/Rnw file calls it!!
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.
cat("\f") # clear console

# ---- load-sources ------------------------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.  Ideally, no real operations are performed.
source("./scripts/mplus/group-variables.R")
source("./scripts/mplus/model-components.R")
source("./scripts/table-assembly-functions.R")

# ---- load-packages -----------------------------------------------------------
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(magrittr) #Pipes
# Verify these packages are available on the machine, but their functions need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
requireNamespace("ggplot2") # graphing
requireNamespace("tidyr")   # data wrangling
requireNamespace("dplyr")   # avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
requireNamespace("testit")  # asserting conditions meet expected patterns.
requireNamespace("readr")   # input and output of data
requireNamespace("scales")
requireNamespace("knitr")
requireNamespace("DT")

# ---- declare-globals ---------------------------------------------------------
options(show.signif.stars=F) #Turn off the annotations on p-values
print_format <- "pandoc"
# print_format <- "html"
model_type_standard <- "aehplus" # spread at outcome pair level
# model_type_set <- c("a", "ae", "aeh", "aehplus", "full") # spread at model type level
model_type_set <- c("a", "ae", "aeh", "aehplus","full") # spread at model type level
# model_type_set <- c("aehplus") # spread at model type level

# catalog containing model results
path_catalog_wide <- "./model-output/physical-physical/2-catalog-wide.csv"
path_catalog_long <- "./model-output/physical-physical/3-catalog-long.csv"
# template for structuring tables for reporting individual models
path_stencil <- "./data/public/raw/stencils/study-specific-stencil-v10.csv"

# ---- load-data ---------------------------------------------------------------
catalog_wide <- readr::read_csv(path_catalog_wide,col_names = TRUE)
catalog_long <- readr::read_csv(path_catalog_long,col_names = TRUE)
stencil <- readr::read_csv(path_stencil,col_names = TRUE)

# ---- tweak-data ---------------------------------------------

# ---- explorations -------------------------------------------
catalog_long %>% view_options(
  study_name_ ="elsa"
  ,full_id     = T
  # ,subgroups   = c("female")
  # ,model_types = c("aehplus")
  # ,processes_a = c("grip")
  # ,processes_b = "symbol"
)
# Has no grip:
# eas, elsa, hrs, ilse, lasa, map, nuage, octo, satsa
# ---- print-functions -----------------

print_header <- function(
  catalog_long
){
  cat("\n#",outcome,": Available models \n")
  print(cat("\n",paste0("Study **",toupper(study),"** have contributed the following outcome pairs to the IASLA-2015-Portland model pool:"),"\n"))
  cat("\n")
  print(
    knitr::kable(
      view_options(catalog_long
                   ,study_name_ = study#"eas"
                   ,full_id     = F
                   ,subgroups   = c("female","male")
                   ,processes_a = outcome#"pef"
      )
      # ,format = "html"
      ,format = print_format
    )
  )
  cat("\n")
  for(gender in c("female","male")){
    cat("\n")
    print(
      knitr::kable(
        view_options(catalog_long
                     ,study_name_ = study#"eas"
                     ,full_id     = T
                     ,subgroups   = gender
                     ,processes_a = outcome#"pef"
        )
        # ,format = "html"
        ,format = print_format
      )
    )
    cat("\n")
  }
}

print_body <- function(
  catalog_long,
  catalog_wide
){
  
  for(gender in c("female","male")){
    # if(gender == "female"){
    #   processes_b <- c("block", "digit_tot","symbol", "trailsb")
    # }else{ # covariate sets may differ by gender, both must have the standard "aehplus"
    #   processes_b <- c("block", "digit_tot","symbol", "trailsb") # fas would break it no standard
    # }
    cat("\n#",gender,"\n")
    print_outcome_pairs(
      d = catalog_long
      ,study = study#'eas'
      ,gender = gender
      ,outcome = outcome#"pef"
      ,model_type_standard = model_type_standard#"aehplus" # spread at outcome pair level
      ,model_type_set = model_type_set#c("a", "ae", "aeh", "aehplus", "full") # spread at model type level
      ,print_format = print_format
    )
    # cat("\n## Summary","\n")
    # cat("\n",paste0("Study = _",toupper(study),"_; Gender = _",gender,"_; Process (a) = _",outcome,"_\n"))
    # cat("\n Computed correlations:\n")
    # print_coefficients(
    #   d = catalog_wide
    #   ,study_name    = study
    #   ,subgroup      = gender
    #   ,pivot         = outcome
    #   ,target_names  = c(
    #     "er_tau_00_est"
    #     ,"er_tau_11_est"
    #     ,"er_sigma_00_se")
    #   ,target_labels = c(
    #     "Correlation of Levels"
    #     ,"Correlation of Slopes"
    #     ,"Correlation of Residuals")
    #   # ,processes_b_  = processes_b
    # )
    # cat("\n")
    # cat("P-values for corresponding covariances: \n")
    # print_coefficients(
    #   d              = catalog_wide         # contains model solutions, row = model
    #   ,study_name    = study           # name of study
    #   ,subgroup      = gender          # gender : male or female
    #   ,pivot         = outcome         # fixed; name of process 1
    #   ,target_names  = c(              # coefficients of interest
    #        "er_tau_00_pval"
    #     ,  "er_tau_11_pval"
    #     ,"er_sigma_00_pval"
    #   )
    #   ,target_labels = c(              # labels for the coefs of interest
    #     "Correlation of Levels"
    #     ,"Correlation of Slopes"
    #     ,"Correlation of  Residuals"
    #   )
    # )
  }
}


# ---- eas ---------------------------------------------------------
study <- 'eas'

outcome <- "grip"
print_header(catalog_long)
print_body(catalog_long, catalog_wide)

outcome <- "pef"
print_header(catalog_long)
print_body(catalog_long, catalog_wide)

# elsa has only "aehplus" form
# ---- elsa ---------------------------------------------------------
study <- 'elsa'

outcome <- "grip"
print_header(catalog_long)
print_body(catalog_long, catalog_wide)

outcome <- "fev100"
print_header(catalog_long)
print_body(catalog_long, catalog_wide)

# ---- hrs ---------------------------------------------------------
study <- 'hrs'

outcome <- "grip"
print_header(catalog_long)
print_body(catalog_long, catalog_wide)

outcome <- "pef"
print_header(catalog_long)
print_body(catalog_long, catalog_wide)

# ---- ilse ---------------------------------------------------------
study <- 'ilse'

outcome <- "grip"
print_header(catalog_long)
print_body(catalog_long, catalog_wide)


# ---- lasa ---------------------------------------------------------
study <- 'lasa'

outcome <- "grip"
print_header(catalog_long)
print_body(catalog_long, catalog_wide)

outcome <- "pef"
print_header(catalog_long)
print_body(catalog_long, catalog_wide)

# ---- map ---------------------------------------------------------
study <- 'map'

outcome <- "fev"
print_header(catalog_long)
print_body(catalog_long, catalog_wide)

outcome <- "gait"
print_header(catalog_long)
print_body(catalog_long, catalog_wide)

# ---- nuage ---------------------------------------------------------
study <- 'nuage'

outcome <- "grip"
print_header(catalog_long)
print_body(catalog_long, catalog_wide)

# ---- octo ---------------------------------------------------------
study <- 'octo'

outcome <- "grip"
print_header(catalog_long)
print_body(catalog_long, catalog_wide)

outcome <- "pef"
print_header(catalog_long)
print_body(catalog_long, catalog_wide)

# ---- satsa ---------------------------------------------------------
study <- 'satsa'

outcome <- "grip"
print_header(catalog_long)
print_body(catalog_long, catalog_wide)

outcome <- "gait"
print_header(catalog_long)
print_body(catalog_long, catalog_wide)




# ---- session-info ---------------------
cat("\n#Session Info")
sessionInfo()






