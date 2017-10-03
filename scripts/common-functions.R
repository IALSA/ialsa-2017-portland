# print names and associated lables of variables (if attr(.,"label)) is present
names_labels <- function(ds){
  dd <- as.data.frame(ds)
  
  nl <- data.frame(matrix(NA, nrow=ncol(dd), ncol=2))
  names(nl) <- c("name","label")
  for (i in seq_along(names(dd))){
    # i = 2
    nl[i,"name"] <- attr(dd[i], "names")
    if(is.null(attr(dd[[i]], "label")) ){
      nl[i,"label"] <- NA}else{
        nl[i,"label"] <- attr(dd[,i], "label")
      }
  }
  return(nl)
}
# names_labels(ds=oneFile)

# adds neat styling to your knitr table
neat <- function(x, html = T , ...){
  # browser()
  # knitr.table.format = output_format
  if(!html){
    x_t <- knitr::kable(x, format = "pandoc", row.names = F,...)
  }else{
    x_t <- x %>%
      # x %>%
      # knitr::kable() %>%
      knitr::kable(format="html",row.names = F, ...) %>%
      kableExtra::kable_styling(
        bootstrap_options = c("striped", "hover", "condensed","responsive"),
        # bootstrap_options = c( "condensed"),
        full_width = F,
        position = "left"
      )
  }
  return(x_t)
}# usage:
# nt <- t %>% neat()

# adds a formated datatable
neat_DT <- function(x, filter_="top"){
  
  xt <- x %>%
    as.data.frame() %>% 
    DT::datatable(
      class   = 'cell-border stripe'
      ,filter  = filter_
      ,options = list(
        pageLength = 6,
        autoWidth  = FALSE
      )
    )
  return(xt)
}#usage:
# dt <- t %>% neat_DT()


# ----- basic-line-graph ------------------------------------------------
basic_line <- function(
  d_observed,
  variable_name,
  time_metric,
  color_name="black",
  line_alpha=1,
  line_size =.5,
  smoothed = FALSE,
  main_title     = variable_name,
  x_title        = paste0("Time metric: ", time_metric),
  y_title        = variable_name,
  rounded_digits = 0L
) {
  
  d_observed <- as.data.frame(d_observed) #Hack so dplyr datasets don't mess up things
  d_observed <- d_observed[!base::is.na(d_observed[, variable_name]), ]
  
  g <- ggplot(d_observed, aes_string(x=time_metric, y = variable_name))
  if(!smoothed){
    g <- g + geom_line(aes_string(group="id"), size=line_size, color=scales::alpha(color_name,line_alpha), na.rm=T)
  } else{
    g <- g + geom_smooth(aes_string(group="id"),size=line_size,  method="lm",color=scales::alpha(color_name,line_alpha), na.rm=T, se=F )
    g <- g + geom_smooth(method="loess", color="blue", size=1, fill="gray80", alpha=.3, na.rm=T)
    
  }
  
  g <- g + scale_x_continuous(labels=scales::comma_format()) +
    scale_y_continuous(labels=scales::comma_format()) +
    # labs(title=main_title, x=x_title, y=y_title) +
    theme_light() +
    theme(axis.ticks.length = grid::unit(0, "cm"))
  return( g )
}

# g <- basic_line(d, "cogn_global", "fu_year", "salmon", .9, .1, T)
# g
