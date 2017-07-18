rm(list=ls(all=TRUE))
########## Production of reports from .Rmd files ###

path_eas   <- base::file.path("./reports/physical-physical/tabulations/eas.Rmd")
path_elsa  <- base::file.path("./reports/physical-physical/tabulations/elsa.Rmd")
path_hrs   <- base::file.path("./reports/physical-physical/tabulations/hrs.Rmd")
path_ilse  <- base::file.path("./reports/physical-physical/tabulations/ilse.Rmd")
path_lasa  <- base::file.path("./reports/physical-physical/tabulations/lasa.Rmd")
path_map   <- base::file.path("./reports/physical-physical/tabulations/map.Rmd")
path_nuage <- base::file.path("./reports/physical-physical/tabulations/nuage.Rmd")
path_octo  <- base::file.path("./reports/physical-physical/tabulations/octo.Rmd")
path_satsa <- base::file.path("./reports/physical-physical/tabulations/satsa.Rmd")

# Has no gait: map, nuage, satsa

#  Define groups of reports
allReports<- c(
   path_eas
  ,path_elsa
  ,path_hrs
  ,path_ilse
  ,path_lasa
  ,path_map
  ,path_nuage
  ,path_octo
  ,path_satsa
)
# Place report paths HERE ###########
pathFilesToBuild <- c(allReports) ##########


testit::assert("The knitr Rmd files should exist.", base::file.exists(pathFilesToBuild))
# Build the reports
for( pathFile in pathFilesToBuild ) {
  #   pathMd <- base::gsub(pattern=".Rmd$", replacement=".md", x=pathRmd)
  rmarkdown::render(input = pathFile,
                    output_format=c(
                      # "html_document" # set print_format <- "html" in seed-study.R
                      #, "pdf_document"
                      # ,"md_document"
                      "word_document" # set print_format <- "pandoc" in seed-study.R
                    ),
                    clean=TRUE)
}
