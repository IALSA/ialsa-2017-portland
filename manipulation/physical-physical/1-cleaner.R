# The purpose of this script is to clean the raw catalog

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
# Verify these packages are available on the machine, but their functions need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
requireNamespace("ggplot2") # graphing
requireNamespace("tidyr")   # data wrangling
requireNamespace("dplyr")   # avoid attaching dplyr, b/c its function names conflict with a lot of packages (esp base, stats, and plyr).
requireNamespace("testit")  # asserting conditions meet expected patterns.
requireNamespace("readr")   # input and output of data

# ---- declare_globals ---------------------------------------------------------
path_input   <- "./model-output/physical-physical/0-catalog-raw"
path_save  <- "./model-output/physical-physical/1-catalog-clean"

# ---- load_data ---------------------------------------------------------------
# catalog <- read.csv(paste0(path_input,".csv"), header = T,  stringsAsFactors=FALSE)
catalog <- readr::read_csv(paste0(path_input,".csv"),col_names = TRUE)

# ---- tweak_data --------------------------------------------------------------
colnames(catalog)
ds <- catalog %>% dplyr::arrange_("model_type", "process_a") %>%
  dplyr::select_("study_name", "model_number","subgroup","model_type","process_a", "process_b")

# assing alias
ds <- catalog

# ----- load-rename-classify-mapping -------------------------------------
ds_rules <- read.csv("./data/public/raw/rename-classify-rules.csv", stringsAsFactors = F) %>%
  dplyr::select(-notes,-mplus_name)

# ---- spell-model_number ------------------------------------------------------
t <- table(ds$model_number, ds$study_name);t[t==0]<-".";t

# ---- spell-subgroup ---------------------------------------------------------
t <- table(ds$subgroup, ds$study_name);t[t==0]<-".";t

# ---- spell-model_type -------------------------------------------
t <- table(ds$model_type, ds$study_name);t[t==0]<-".";t


# ---- correct-model_type ------------------------------------------------------
# extract the specific renaming rule
d_rule <- ds_rules %>%
  dplyr::filter(category == "model_type") %>%
  dplyr::select(entry_raw, entry_new)
d_rule
# join the model data frame to the conversion data frame.
ds <- ds %>%
  dplyr::left_join(d_rule, by=c("model_type"="entry_raw"))
# verify
t <- table(ds$entry_new, ds$study_name);t[t==0]<-".";t
t <- table(ds$model_type, ds$entry_new);t[t==0]<-".";t # raw rows, new columns
# head(ds)
# Replace raw entries with new entries
ds <- ds %>%
  dplyr::mutate_("model_type"="entry_new") %>%
  dplyr::select(-entry_new)
t <- table(ds$model_type, ds$study_name); t[t==0]<-"."; t


# ---- spell-process_a -------------------------------------------------
t <- table(ds$process_a, ds$study_name); t[t==0]<-"."; t

# ---- correct-process_a ------------------------------------------------
# extract the specific renaming rule
d_rule <- ds_rules %>%
  dplyr::filter(category == "physical") %>%
  dplyr::select(entry_raw, entry_new)
d_rule
# join the model data frame to the conversion data frame.
ds <- ds %>%
  dplyr::left_join(d_rule, by=c("process_a"="entry_raw"))
# verify
t <- table(ds$entry_new, ds$study_name);t[t==0]<-".";t
head(ds)
t <- table(ds[ ,"entry_new"],  ds[,"study_name"]);t[t==0]<-".";t
# Remove the old variable, and rename the cleaned/condensed variable.
ds <- ds %>%
  dplyr::select(-process_a) %>%
  dplyr::rename_("process_a"="entry_new") # name correction
# verify
t <- table(ds$process_a, ds$study_name); t[t==0]<-"."; t


# ---- spell-process_b -------------------------------------------------
t <- table(ds$process_b, ds$study_name); t[t==0]<-"."; t
d <- ds %>%
  dplyr::group_by_("study_name","process_b") %>%
  dplyr::summarize(count=n()) %>%
  dplyr::ungroup() %>%
  dplyr::arrange_("study_name")
knitr::kable(d)

# ---- correct-process_b ------------------------------------------------
# extract the specific renaming rule
d_rule <- ds_rules %>%
  dplyr::filter(category == "physical") %>%
  dplyr::select(entry_raw,entry_new,label_cell,label_row, domain )
d_rule
# join the model data frame to the conversion data frame.
ds <- ds %>%
  dplyr::left_join(d_rule, by=c("process_b"="entry_raw"))
# verify
t <- table(ds$entry_new, ds$study_name);t[t==0]<-".";t
head(ds)
t <- table(ds[ ,"entry_new"], ds[,"study_name"]);t[t==0]<-".";t
t <- table(ds[ ,"label_cell"],  ds[,"study_name"]);t[t==0]<-".";t
t <- table(ds[ ,"label_row"],  ds[,"study_name"]);t[t==0]<-".";t
t <- table(ds[ ,"domain"],     ds[,"study_name"]);t[t==0]<-".";t
# Remove the old variable, and rename the cleaned/condensed variable.
ds <- ds %>%
  dplyr::select(-process_b) %>%
  dplyr::rename_("process_b"="entry_new") %>% # name correction
  dplyr::rename_("process_b_cell"="label_cell") %>%
  dplyr::rename_("process_b_row"="label_row") %>%
  dplyr::rename_("process_b_domain"="domain")
# verify
t <- table(ds$process_b_row, ds$study_name); t[t==0]<-"."; t

# ---- test_process_b ---------------------------------------
t <- table(ds$process_b, ds$study_name);t[t==0]<-".";t
d <- ds %>% dplyr::group_by_("process_b","study_name") %>% dplyr::summarize(count=n())
d <- d %>% dplyr::ungroup() %>% dplyr::arrange_("study_name")
knitr::kable(d)

# ---- test-process_b_domain -----------------------------------------
t <- table(ds$process_b, ds$process_b_domain);t[t==0]<-".";t

# ---- standardize-names -------------------------
catalog <- rename_columns_in_catalog(ds)

# ---- save-to-disk ------------------------------------------------------------
write.csv(catalog,  paste0(path_save,".csv"), row.names=F)



