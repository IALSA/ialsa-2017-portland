# The purpose of this script is to print forest plots and save data for their production

# run the line below to stitch a basic html output. For elaborated report, run the corresponding .Rmd file
# knitr::stitch_rmd(script="./manipulation/0-ellis-island.R", output="./manipulation/stitched-output/0-ellis-island.md")
#These first few lines run only when the file is run in RStudio, !!NOT when an Rmd/Rnw file calls it!!
rm(list=ls(all=TRUE))  #Clear the variables from previous runs.
cat("\f") # clear console

# ---- load-sources ------------------------------------------------------------
# Call `base::source()` on any repo file that defines functions needed below.  Ideally, no real operations are performed.
source("./scripts/mplus/group-variables.R")
source("./scripts/mplus/model-components.R")
source("./reports/physical-physical/forest/support-functions.R")

# ---- load-packages -----------------------------------------------------------
# Attach these packages so their functions don't need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
library(magrittr) #Pipes
library(ggplot2)
library(forestplot)
# Verify these packages are available on the machine, but their functions need to be qualified: http://r-pkgs.had.co.nz/namespace.html#search-path
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

# catalog containing model results
path_catalog_wide <- "./model-output/physical-physical/2-catalog-wide.csv"
path_catalog_long <- "./model-output/physical-physical/3-catalog-long.csv"

# ---- load-data ---------------------------------------------------------------
catalog_wide <- readr::read_csv(path_catalog_wide,col_names = TRUE)
catalog_long <- readr::read_csv(path_catalog_long,col_names = TRUE)

# ---- inspect-data ---------------------------
catalog_wide %>% dplyr::glimpse()

# ---- tweak-data --------------------
# perform custom touch-up, local to physical-physical track

# define possible pairs: models with pairs in these sets will be selected
pulmonary_gait_pairs <- c("fev", "fev100","pef","gait","tug")
pulmonary_grip_pairs <- c("fev", "fev100","pef","grip")
gait_grip_pairs      <- c("gait","tug"   ,"grip")

catalog_wide <- catalog_wide %>% 
  dplyr::mutate(
    pair = ifelse(
      process_a %in% pulmonary_gait_pairs & process_b %in% pulmonary_gait_pairs,"pulmonary-gait",ifelse(
        process_a %in% pulmonary_grip_pairs & process_b %in% pulmonary_grip_pairs,"pulmonary-grip",ifelse(
          process_a %in% gait_grip_pairs & process_b %in% gait_grip_pairs, "gait-grip",NA
        )
      ))
  ) %>%
  dplyr::arrange(desc(pair), study_name, process_a, process_b) %>%
  dplyr::mutate(domain = pair)
  # dplyr::select(-pair) 

catalog_wide %>% glimpse()
# ---- dummy -------------------
# library(dplyr)
# catalog_wide %>%
#   filter(model_number=="b1") %>%
#   filter(model_type %in% c("aehplus")) %>%
#   group_by(process_a,process_b, study_name) %>%
#   summarize(n_b1_aesplus_models=n()) %>%
#   # filter(process_a %in% c("gait","tug")) %>%
#   # filter(process_a %in% c("grip")) %>%
#   # filter(process_a %in% c("fev","pef")) %>%
#   print(n=nrow(.))
#
#
# catalog_wide %>%
#   filter(model_number=="b1",model_type =="aehplus") %>%
#     group_by(process_a, process_b, study_name) %>%
#   summarize(n_models=n()) %>%
#   filter(process_a %in% c("fev","pef")) %>%
#   print(n=nrow(.))


# colnames(catalog_wide)
# catalog_wide %>%
#   dplyr::filter(model_number=="b1") %>%
#   dplyr::group_by(process_b_domain) %>%
#   # dplyr::filter(is.na(domain)) %>%
#   dplyr::summarize(count=n()) %>%
#   dplyr::arrange(count)

catalog_wide %>% 
  dplyr::distinct(process_a, process_b)

# ---- save-data-for-tables --------------------------
# prepare data for saving
# d_catalog <- catalog_wide %>%
#   dplyr::mutate(
#     process_b        = process_b_label,       # replace NAMES of measures and domains
#     process_b_domain = process_b_domain_label # with  LABELS of measure and domains
#   ) %>%
#   dplyr::select(-process_b_label, -process_b_domain_label)
d_catalog <- catalog_wide
# for(track in c("pulmonary")){
# for(track in c("gait","grip","pulmonary")){
  for(gender in c("andro")){
    # for(gender in c("male","female","andro")){
    # for(format in c("meta"))
    for(format in c("full","brief","meta"))
      d_catalog %>%
      dplyr::filter(model_type == "aehplus",model_number=="b1") %>%
      prettify_catalog() %>%
      save_corr_table(
        track="all",
        gender,
        format,
        "./reports/physical-physical/forest/table-data/")
  }
# }


# ---- dummy -------------
# track values is defined in Rmd
# track = "pulmonary"
# gender = "male"
get_freq <- function(d, varname){
  # d <- data_forest
  varname <- c("domain","subgroup")
  d %>%
    dplyr::group_by_(.dots=varname) %>%
    dplyr::summarize(n=n()) %>%
    dplyr::arrange(n)
}

# ---- table-dynamic -----------------------------------------------------------
# track = "gait"
# track = "grip"
# track = "pulmonary"
track = "all"

d <- catalog_wide %>%
  dplyr::filter(
    model_type  %in%  c("a","ae","aeh","aehplus","full"),
    model_number %in% c("b1")
  ) %>%
  prettify_catalog() %>%
  select_for_table(track = track, gender = "andro",format = "full", pretty_name=F)

selected_columns <- colnames(d)
replace_italics <- function(x,  pattern="p"){
  xx <- sub( paste0("\\$",pattern,"\\$"), pattern, x)
  return(xx)
}
d[,selected_columns] <- lapply(d[,selected_columns], replace_italics, pattern="p")

static_variables <- c(
  # "process_b_domain", "study_name",       "model_number",     "subgroup",
  "domain",             "study_name",       "model_number",     "subgroup",
  "model_type",       "process_a",        "process_b",        "subject_count"
)
dynamic_variables <- setdiff(colnames(d), static_variables)
d <- d %>%
  tidyr::gather_("index","dense",dynamic_variables) %>%
  dplyr::mutate(
    covariance = ifelse(grepl("_ci$",index),"Correlation CI",
                        ifelse(grepl("^tau_",index),"Covariance",
                               ifelse(grepl("^er_",index),"Correlation",
                                      ifelse(grepl("^cr_",index),"Fisher's R",NA)))),
    parameter = ifelse( grepl("levels",index),"Levels",
                        ifelse(grepl("slopes",index),"Slopes",
                               ifelse(grepl("resid", index),"Residuals",NA))),
    value = dense
  ) %>%
  dplyr::select(-index,-dense, -model_number) %>%
  tidyr::spread(parameter,value) %>%
  dplyr::mutate(
    subject_count = as.numeric(subject_count),
    study_name = toupper(study_name)
    # ,process_a = toupper(process_a)
  ) %>%
  dplyr::rename(
    N         = subject_count
    ,study     = study_name
    ,domain    = domain
    # ,physical  = process_a
    # ,cognitive = process_b
  ) %>%
  dplyr::select(
    domain, study, subgroup, model_type, process_a, process_b, N, covariance, Levels, Slopes, Residuals
    # domain, study, subgroup, model_type, physical, cognitive, N, covariance, Levels, Slopes, Residuals
    # subgroup, model_type, domain, study, physical, cognitive, N, covariance, Levels, Slopes, Residuals
  )

change_to_factors <- setdiff(colnames(d),"N" )
d[,change_to_factors] <- lapply(d[,change_to_factors], factor)

# d %>%
#   DT::datatable(
#     class     = 'cell-border stripe',
#     # caption   = "Table of Correlations",
#     filter    = "top",
#     options   = list(pageLength = 6, autoWidth = TRUE)
#   )


catalog_wide %>% glimpse()


# ----- print-forest  --------------------------------
# i <- "intercept"
# i <- "slope"
# i <- "residual"
# for(track in c("gait","grip","pulmonary")){
  # track = "gait"
  # track = "grip"
  # track = "pulmonary"
  track = "all"
  # path_graph_jpeg = paste0("./reports/correlation-3/forest-plot-",track,"/")
  path_graph_jpeg = paste0("./reports/physical-physical/forest/forest-plot/")
  # path_graph_jpeg = paste0("./reports/correlation-3/test/")
  for(i in c("intercept","slope","residual")){
    # i = "intercept"
    data_forest <- catalog_wide %>%
      prettify_catalog() %>%
      # dplyr::filter(
      #   model_number == "b1"
      #   ,  model_type   == "aehplus"
      #   ,! process_b    == "trailsb"
      # ) %>%
      get_forest_data(track = track,index = i) %>%
      tidyr::drop_na(mean)
    colnames(data_forest)
    # data_forest %>% get_freq()
    (domain_cycle <- setdiff(unique(data_forest$domain),NA))
    (subgroup_cycle <- unique(data_forest$subgroup))
    for(dom in domain_cycle){
      # cat("\n##",dom,"\n")
      for(gender in subgroup_cycle){
        # (dom = "immediate and recognition memory")
        # (dom = "gait-grip")
        # (gender = "female")
        # n_lines = 13
        (n_lines <- data_forest %>%
           dplyr::filter(domain==dom,subgroup==gender) %>%
           nrow())
        # save graphic
        # make sure it conforms to `track-domain-gender-index` formula
        path_save = paste0(path_graph_jpeg,dom,"-",gender,"-",i,".jpg")
        print(path_save)
        jpeg(
          filename  =  path_save,
          width     = 900,
          height    = 140 + 20*n_lines,
          units     = "px",
          pointsize = 12,
          quality   = 100
        )
        data_forest %>% print_forest_plot(dom,gender,i)
        dev.off()
      }
    }
  }
# }


# ---- place-forest --------------------------------------
# places previously printed plot onto a single canvas
# track = "gait"
# track = "grip"
# track = "pulmonary"
path_folder <- paste0("./reports/physical-physical/forest/forest-plot")
jpegs <- list.files(path_folder, full.names = T)
lst <- list()
regex_pattern <- "(\\w+)-(.+)-(\\w+)-(\\w+).jpg$"
for(i in seq_along(jpegs)){
  (lst[["track"]][i]    = sub(regex_pattern,"\\1", basename(jpegs[i]) ) )
  (lst[["domain"]][i]   = sub(regex_pattern,"\\2", basename(jpegs[i]) ) )
  (lst[["subgroup"]][i] = sub(regex_pattern,"\\3", basename(jpegs[i]) ) )
  (lst[["index"]][i]    = sub(regex_pattern,"\\4", basename(jpegs[i]) ) )
  (lst[["path"]][i]     = sub("[./]","../../..",jpegs[i]))
}
ds_jpegs <- dplyr::bind_rows(lst)

index_cycle    <- ds_jpegs$index %>% unique() %>% sort(decreasing = T)
domain_cycle   <- ds_jpegs$domain %>% unique()
subgroup_cycle <- ds_jpegs$subgroup %>% unique()
for(ind in index_cycle){
  cat("\n# Forest: ", ind,"\n")
  for(dom in domain_cycle){
    cat("\n## ",dom,"\n")
    for(gender in subgroup_cycle){
      #Don't specify width.  This maintains the aspect ratio.
      path <- ds_jpegs %>%
        dplyr::filter(
          index    == ind,
          domain   == dom,
          subgroup == gender
        ) %>%
        dplyr::select(path) %>%
        as.character()
      # print(path)
      # testit::assert("File does not exist",file.exists(path))
      if(file.exists( sub("../../../","./",path) ) ){
        cat('<img src="', path, '" alt="', basename(path),'">\n', sep="")
      }
      # cat("\n")
    }
  }
}



# ---- table-static-full ------------------------------------------------------------
cat("\n# Group by domain\n")
for(gender in c("male","female")){
  # gender = "male"
  cat("\n##",gender)
  # d %>% glimpse()
  d <- catalog_wide %>%
    dplyr::filter(
      model_type == "aehplus",
      model_number == "b1"
    ) %>%
    prettify_catalog() %>%
    select_for_table(track,gender = gender,format = "full")
  # if(track=="pulmonary"){d <- d %>% rename_domains(track)}
  d <- d %>%
    dplyr::filter(subgroup %in% gender) %>%
    dplyr::select(-model_number, -subgroup, -model_type) %>%
    dplyr::mutate() %>%
    # dplyr::arrange(domain,study,cognitive ) %>%
    dplyr::arrange(domain,study,process_b ) %>%
    knitr::kable(
      format     = print_format,
      align      = c("l","l","r","l","c",  "r","l","r","l",  "r","l","r","l",  "r","l","r","l") # cognitive full
      # align      = c(     "l", "r", "l", "c", "r","l","r","l","r","l") # physical
    ) %>%
    print()
}
cat("\n# Grouped by study\n")
for(gender in c("male","female")){
  cat("\n##",gender)
  d <- catalog_wide %>%
    dplyr::filter(
      model_type == "aehplus",
      model_number == "b1"
    ) %>%
    prettify_catalog() %>%
    select_for_table(track,gender = gender,format = "full")
  # if(track=="pulmonary"){d <- d %>% rename_domains(track)}
  d <- d %>%
    dplyr::filter(subgroup %in% gender) %>%
    dplyr::select(-model_number, -subgroup, -model_type) %>%
    # dplyr::arrange(study,domain,cognitive) %>%
    dplyr::arrange(study,domain,process_b) %>%
    knitr::kable(
      format     = print_format,
      align      = c("l","l","r","l","c",  "r","l","r","l",  "r","l","r","l", "r","l","r","l") # cognitive full
      # align      = c(     "l", "r", "l", "c", "r","l","r","l","r","l") # physical
    ) %>%
    print()
}


# ---- table-static-focus ------------------------------------------------------------
cat("\n#Group by domain\n")
for(gender in c("male","female")){
  cat("\n##",gender)
  d <- catalog_wide %>%
    dplyr::filter(
      model_type == "aehplus",
      model_number == "b1"
    ) %>%
    prettify_catalog() %>%
    select_for_table(track,gender = gender,format = "focus")
  # if(track=="pulmonary"){d <- d %>% rename_domains(track)}
  d <- d %>%
    dplyr::filter(subgroup %in% gender) %>%
    dplyr::select(-model_number, -subgroup, -model_type) %>%
    # dplyr::arrange(domain,study,cognitive ) %>%
    dplyr::arrange(domain,study,process_b ) %>%
    knitr::kable(
      format     = print_format,
      align      = c("l","l","r","l","c", "l","l","l") # cognitive
      # align      = c(     "l", "r", "l", "c", "l","l","l") # physical
    ) %>%
    print()
}
cat("\n#Grouped by study\n")
for(gender in c("male","female")){
  cat("\n##",gender)
  d <- catalog_wide %>%
    dplyr::filter(
      model_type == "aehplus",
      model_number == "b1"
    ) %>%
    prettify_catalog() %>%
    select_for_table(track,gender = gender,format = "focus")
  # if(track=="pulmonary"){d <- d %>% rename_domains(track)}
  d <- d %>%
    dplyr::filter(subgroup %in% gender) %>%
    dplyr::select(-model_number, -subgroup, -model_type) %>%
    # dplyr::arrange(study,domain,cognitive) %>%
    dplyr::arrange(domain,study,process_b ) %>%
    knitr::kable(
      format     = print_format,
      align      = c("l","l","r","l","c", "l","l","l") # cognitive
      # align      = c(     "l", "r", "l", "c", "l","l","l") # physical
    ) %>%
    print()
}

# d %>% print_forest_plot("memory")

# ---- publish --------------
# WORD reports
path_full    <- "./reports/physical-physical/forest/forest-full.Rmd"
path_focus   <- "./reports/physical-physical/forest/forest-focus.Rmd"
# Chose production
# allReports <- c(path_full)
# allReports <- c(path_focus)
allReports <- c(path_full,path_focus)

pathFilesToBuild <- c(allReports)
testit::assert("The knitr Rmd files should exist.", base::file.exists(pathFilesToBuild))
# Build the reports
for( pathFile in pathFilesToBuild ) {
  
  rmarkdown::render(input = pathFile,
                    output_format=c(
                      # "html_document" # set print_format <- "html" in seed-study.R
                      # "pdf_document"
                      # ,"md_document"
                      "word_document" # set print_format <- "pandoc" in seed-study.R
                    ),
                    clean=TRUE)
}




# HTML Reports
path_summary <- "./reports/physical-physical/forest/forest-summary.Rmd"
# Chose production
allReports <- c(path_summary)

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



