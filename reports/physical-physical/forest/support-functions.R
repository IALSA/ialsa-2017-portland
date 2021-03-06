# ---- formatting-functions ---------------------------------------
compute_significance <- function(
  est,
  se,
  pval
){
  signif <- ifelse(
    pval > .1, " ", ifelse(
      (pval <=.1 & pval >.05),".",ifelse(
        (pval<=.05 & pval>.01),"*",ifelse(
          (pval<=.01 & pval>.001),"**",ifelse(
            pval<=.001,"***",NA)
        )
      )
    )
  )
  return(signif)
}

numformat <- function(val) { sub("^(-?)0.", "\\1.", sprintf("%.2f", val)) }

dense_v1 <- function(
  est,
  se,
  pval,
  star=FALSE
){
  signif <- ifelse(
    pval > .1, " ", ifelse(
      (pval <=.1 & pval >.05),".",ifelse(
        (pval<=.05 & pval>.01),"*",ifelse(
          (pval<=.01 & pval>.001),"**",ifelse(
            pval<=.001,"***"," ")
        )
      )
    )
  )

  # est_pretty  <- sprintf("%0.2f", est)
  # se_pretty   <- sprintf("%0.2f", se)
  # pval_pretty <- sprintf("%0.2f",pval)
  est_pretty  <- numformat( est)
  se_pretty   <- numformat( se)
  pval_pretty <- numformat(pval)
  pval_pretty <- ifelse(pval>.99, ".99", sub("^0(.\\d+)$", "\\1", pval_pretty)) #Cap p-value at .99
  # pval_pretty <- sprintf("%.2f", pval) #Remove leading zero from p-value.
  # pval_pretty <- numformat( pval) #Remove leading zero from p-value.
  pval_pretty <- sprintf("$p$=%s", pval_pretty)
  pval_pretty <- ifelse(pval_pretty=="$p$=.00", "$p$<.01", pval_pretty)       #Cap p-value at .01
  pval_pretty <- ifelse(pval_pretty=="$p$=NA" , "$p$= NA", pval_pretty)       #Pad NA with space
  dense       <- sprintf("%4s(%4s), %7s", est_pretty, se_pretty, pval_pretty)
  if(star=="TRUE"){
    dense <- sprintf("%4s(%4s), %7s %s",est_pretty, se_pretty, pval_pretty, signif )
  }
  dense       <- ifelse((is.nan(est)|is.na(est)|is.infinite(est)), "---", dense)
  return(dense)

}

dense_v2 <- function(
  est,
  lo,
  hi
){
  est_pretty <- numformat(est)
  lo_pretty  <- numformat(lo)
  hi_pretty  <- numformat(hi)


  # if(star){
  #   dense <- sprintf("%4s(%4s,%4s)%s", est_pretty, lo_pretty, hi_pretty, signif)
  # }else{
  dense <- sprintf("%4s(%4s,%4s)", est_pretty, lo_pretty, hi_pretty)
  # }
  dense <- ifelse((is.nan(est)|is.na(est)|is.infinite(est)), "---", dense)
  return(dense)
}

dense_v3 <- function(
  est,
  lo,
  hi,
  star=F,
  signif
){
  est_pretty <- numformat(est)
  lo_pretty  <- numformat(lo)
  hi_pretty  <- numformat(hi)

  if(star){
    dense <- sprintf("%4s(%4s,%4s)%s", est_pretty, lo_pretty, hi_pretty, signif)
  }else{
    dense <- sprintf("%4s(%4s,%4s)", est_pretty, lo_pretty, hi_pretty)
  }
  dense <- ifelse((is.nan(est)|is.na(est)|is.infinite(est)), "---", dense)
  return(dense)
}

dense_v4 <- function(
  lo,
  hi,
  star=F,
  signif
){
  lo_pretty  <- numformat(lo)
  hi_pretty  <- numformat(hi)

  if(star){
    dense <- sprintf("(%4s,%4s)%s", lo_pretty, hi_pretty, signif)
  }else{
    dense <- sprintf("(%4s,%4s)", lo_pretty, hi_pretty)
  }
  dense <- ifelse((is.nan(lo)|is.na(lo)|is.infinite(lo)), "---", dense)
  return(dense)
}

# ---- utility-functions ------------------------
prettify_catalog <- function(
  catalog#,
  # model_type_   = "aehplus",
  # model_number_ = "b1"
){
  catalog_pretty <- catalog %>%
    # dplyr::filter(process_a %in% c("fev","fev100", "pef", "pek")) %>%
    # dplyr::filter(model_type %in% model_type_) %>%
    # dplyr::filter(model_number %in% model_number_) %>%
    dplyr::mutate(
      # compute CI of the estimated correlations
      er_tau_00_ci95lo    = er_tau_00_est -  er_tau_00_se*1.96,
      er_tau_00_ci95hi    = er_tau_00_est +  er_tau_00_se*1.96,
      er_tau_11_ci95lo    = er_tau_11_est -  er_tau_11_se*1.96,
      er_tau_11_ci95hi    = er_tau_11_est +  er_tau_11_se*1.96,
      er_sigma_00_ci95lo  = er_sigma_00_est -  er_sigma_00_se*1.96,
      er_sigma_00_ci95hi  = er_sigma_00_est +  er_sigma_00_se*1.96,
      # simplify significance of raw covariances
      signif_levels = compute_significance(ab_tau_00_est,  ab_tau_00_se,   ab_tau_00_pval),
      singif_slopes = compute_significance(ab_tau_11_est,  ab_tau_11_se,   ab_tau_11_pval),
      signif_resid  = compute_significance(ab_sigma_00_est,ab_sigma_00_se, ab_sigma_00_pval),

      # assemble the desnse of raw covariances
      tau_levels = dense_v1(ab_tau_00_est,  ab_tau_00_se,     ab_tau_00_pval,   star = T),
      tau_slopes = dense_v1(ab_tau_11_est,  ab_tau_11_se,     ab_tau_11_pval,   star = T),
      tau_resid  = dense_v1(ab_sigma_00_est,ab_sigma_00_se,   ab_sigma_00_pval, star = T),
      # assemble the dense of estimated correlations
      er_levels  = dense_v1(er_tau_00_est,  er_tau_00_se,     er_tau_00_pval,   star = T),
      er_slopes  = dense_v1(er_tau_11_est,  er_tau_11_se,     er_tau_11_pval,   star = T),
      er_resid   = dense_v1(er_sigma_00_est,er_sigma_00_se,   er_sigma_00_pval, star = T),
      # assemble the dens of CI for estimated correlations
      # er_levels_ci      = sprintf("(%.2f,%.2f)",er_tau_00_ci95lo,er_tau_00_ci95hi ),
      # er_slopes_ci     = sprintf("(%.2f,%.2f)",er_tau_11_ci95lo,er_tau_11_ci95hi ),
      # er_resid_ci      = sprintf("(%.2f,%.2f)",er_sigma_00_ci95lo,er_sigma_00_ci95hi ),
      # er_levels_ci   = dense_v3(er_tau_00_est, er_tau_00_ci95lo, er_tau_00_ci95hi, star=F),
      # er_slopes_ci   = dense_v3(er_tau_11_est, er_tau_11_ci95lo, er_tau_11_ci95hi, star=F),
      # er_resid_ci    = dense_v3(er_sigma_00_est, er_sigma_00_ci95lo, er_sigma_00_ci95hi, star=F ),
      er_levels_ci   = dense_v4(er_tau_00_ci95lo, er_tau_00_ci95hi, star=F),
      er_slopes_ci   = dense_v4(er_tau_11_ci95lo, er_tau_11_ci95hi, star=F),
      er_resid_ci    = dense_v4(er_sigma_00_ci95lo, er_sigma_00_ci95hi, star=F ),
      # assemble the dense of computed correlations
      cr_levels  = dense_v3(cr_levels_est, cr_levels_ci95_lo, cr_levels_ci95_hi,star = F, signif_levels),
      cr_slopes  = dense_v3(cr_slopes_est, cr_slopes_ci95_lo, cr_slopes_ci95_hi,star = F, singif_slopes),
      cr_resid   = dense_v3(cr_resid_est,  cr_resid_ci95_lo,  cr_resid_ci95_hi, star = F, signif_resid)
      # )
    ) %>%
    dplyr::select(
      domain, study_name,
      model_number, subgroup, model_type, process_a, process_b, subject_count,
      # dense       point estimate   st.error/lower ci   p-value/upper ci
      tau_levels,   ab_tau_00_est,   ab_tau_00_se,       ab_tau_00_pval,
      er_levels,    er_tau_00_est,   er_tau_00_se,       er_tau_00_pval,
      er_levels_ci,                  er_tau_00_ci95lo,   er_tau_00_ci95hi,
      cr_levels,    cr_levels_est,   cr_levels_ci95_lo,  cr_levels_ci95_hi,
      # dense       point estimate   st.error/lower ci   p-value/upper ci
      tau_slopes,   ab_tau_11_est,   ab_tau_11_se,       ab_tau_11_pval,
      er_slopes,    er_tau_11_est,   er_tau_11_se,       er_tau_11_pval,
      er_slopes_ci,                  er_tau_11_ci95lo,   er_tau_11_ci95hi,
      cr_slopes,    cr_slopes_est,   cr_slopes_ci95_lo,  cr_slopes_ci95_hi,
      # dense       point estimate   st.error/lower ci   p-value/upper ci
      tau_resid,    ab_sigma_00_est, ab_sigma_00_se,     ab_sigma_00_pval,
      er_resid,     er_sigma_00_est, er_sigma_00_se,     er_sigma_00_pval,
      er_resid_ci,                   er_sigma_00_ci95lo, er_sigma_00_ci95hi,
      cr_resid,     cr_resid_est,    cr_resid_ci95_lo,   cr_resid_ci95_hi
    ) %>%
    dplyr::arrange(domain,process_b)
  return(catalog_pretty)
}

select_for_table <- function(
  ds_cat,
  track,          # gait, grip, pulmonary : selects process a / PHYSICAL MEASURE
  gender = "andro", # andro, male, female : selects subgroup
  format = "full",   # full, focus, brief : selects columns to display
  pretty_name = TRUE # columns names are pretty, ready for table
){
  # browser()
  d1 <- ds_cat
  # select relevant PROCESS A / PHYSICAL MEASURE
  if(!track=="all"){
    if(track=="gait"){
      d2 <- d1 %>% dplyr::filter(process_a %in% c("gait","tug"))
    }
    if(track=="grip"){
      d2 <- d1 %>% dplyr::filter(process_a %in% c("grip"))
    }
    if(track=="pulmonary"){
      d2 <- d1 %>% dplyr::filter(process_a %in% c("fev","pef", "pek"))
    }
  }else{
    d2 <- d1
  }

  # select relevant SUBGROUP
  if(!gender=="andro"){
    d3 <- d2 %>% dplyr::filter(subgroup == gender )
  }else{
    d3 <- d2
  }

  if(format=="full"){
    d4 <- d3 %>%
      dplyr::select(
        domain, study_name,
        model_number, subgroup, model_type, process_a, process_b, subject_count,
        tau_levels, er_levels, er_levels_ci, cr_levels,
        tau_slopes, er_slopes, er_slopes_ci, cr_slopes,
        tau_resid,  er_resid, er_resid_ci, cr_resid
      ) 
    
     if(pretty_name){
      d4 <- d4 %>%
        dplyr::rename_(
          "study"               = "study_name",
          "$n$"                 = "subject_count",
          # "Process A"           = "process_a",
          # "Process B"           = "process_b",
          "Cov(Levels)"         = "tau_levels",       # Covariance             est(se)pval
          "Cov(Slopes)"         = "tau_slopes",
          "Cov(Residuals)"      = "tau_resid",
          "Corr(Levels)Est"     = "er_levels",        # Correlation Estimated  est(se)pval
          "Corr(Slopes)Est"     = "er_slopes",
          "Corr(Residuals)Est"  = "er_resid",
          "CI(Levels)Est"       = "er_levels_ci",     # Correlation Estimated  (lo,hi)
          "CI(Slopes)Est"       = "er_slopes_ci",
          "CI(Residuals)Est"    = "er_resid_ci",
          "Corr(Levels)Comp"    = "cr_levels",        # Correlation Computed   est(lo,hi)
          "Corr(Slopes)Comp"    = "cr_slopes",
          "Corr(Residuals)Comp" = "cr_resid"
        )
    }
  }
  if(format=="focus"){
    d4 <- d3 %>%
      dplyr::select(
        domain, study_name,
        model_number, subgroup, model_type, process_a, process_b, subject_count,
        er_levels, er_slopes, er_resid
      ) %>%
      dplyr::rename_(
        "study"               = "study_name",
        "$n$"                 = "subject_count",
        "Corr(Levels)Est"     = "er_levels",        # Correlation Estimated  est(se)pval
        "Corr(Slopes)Est"     = "er_slopes",
        "Corr(Residuals)Est"  = "er_resid"
      )
  }
  if(format=="brief"){
    d4 <- d3 %>%
      dplyr::select(
        domain, study_name,
        model_number, subgroup, model_type, process_a, process_b, subject_count,
        er_tau_00_est,   er_tau_00_se,   er_tau_00_pval,   er_tau_00_ci95lo,   er_tau_00_ci95hi,
        er_tau_11_est,   er_tau_11_se,   er_tau_11_pval,   er_tau_11_ci95lo,   er_tau_11_ci95hi,
        er_sigma_00_est, er_sigma_00_se, er_sigma_00_pval, er_sigma_00_ci95lo, er_sigma_00_ci95hi
      )
  }

  if(format=="meta"){
    d4 <- d3 %>%
      dplyr::mutate(
        subgroup = factor(subgroup, levels = c("female","male"), labels = c("Women","Men")),
        subgroup = as.character(subgroup)
      ) %>%
      dplyr::select(
        domain, study_name, process_a, process_b, subgroup, subject_count,
        # dense       point estimate   st.error/lower ci   p-value/upper ci
        tau_levels,   ab_tau_00_est,   ab_tau_00_se,       ab_tau_00_pval,
        tau_slopes,   ab_tau_11_est,   ab_tau_11_se,       ab_tau_11_pval,
        tau_resid,    ab_sigma_00_est, ab_sigma_00_se,     ab_sigma_00_pval
      ) %>%
      dplyr::rename_(
        "study" = "study_name",
        "sex"   = "subgroup",
        "$n$"   = "subject_count"
      )

  }
  # d4 <- d4 %>%
  #   dplyr::mutate(
  #     subject_count = scales::comma(subject_count)
  #   )
  return(d4)

}
# Usage:
# output_table <- prettify_catalog(catalog) %>%
#   select_for_table("gait","male","full")
#

save_corr_table <- function(
  catalog_pretty,
  track,
  gender,
  format,
  folder
){
  d <- catalog_pretty %>%
    select_for_table(track=track, gender=gender, format=format)
  # folder <- "./reports/correlation-3/summary-data/"
  # path <- paste0(folder,track,"-",gender,"-",format,".csv")
  path <- paste0(folder,format,".csv")
  readr::write_csv(d,path)
}

# --- get-forest-data -----------------

get_forest_data <- function(
  catalog_pretty,
  track,
  index
){
  # track = "pulmonary"
  # index = "residual"
  # select relevant PROCESS A / PHYSICAL MEASURE
  if(track=="all"){
    d1 <- catalog_pretty
  }else{
    if(track=="gait"){
      d1 <- catalog_pretty %>% dplyr::filter(process_a %in% c("gait","tug"))
    }
    if(track=="grip"){
      d1 <- catalog_pretty %>% dplyr::filter(process_a %in% c("grip"))
    }
    if(track=="pulmonary"){
      d1 <- catalog_pretty %>% dplyr::filter(process_a %in% c("fev","pef", "pek"))
    }
  }

  d2 <- d1 %>%

    dplyr::select(
      domain, study_name,
      model_number, subgroup, model_type, process_a, process_b, subject_count,
      er_tau_00_est,   er_tau_00_ci95lo,   er_tau_00_ci95hi,   er_levels,
      er_tau_11_est,   er_tau_11_ci95lo,   er_tau_11_ci95hi,   er_slopes,
      er_sigma_00_est, er_sigma_00_ci95lo, er_sigma_00_ci95hi, er_resid

    ) %>%
    plyr::rename( c(
      # "process_b_domain" ="domain",
      "study_name"       ="study",
      # "process_a"        ="physical",
      # "process_b"        ="cognitive",
      "subject_count"    ="n"
    ))
  if(index == "intercept"){
    d2 <- d2 %>%
      plyr::rename( c(
        "er_tau_00_est"    ="mean",
        "er_tau_00_ci95lo" ="lower",
        "er_tau_00_ci95hi" ="upper",
        "er_levels"        ="dense"
      ))
  }
  if(index == "slope"){
    d2 <- d2 %>%
      plyr::rename( c(
        "er_tau_11_est"    ="mean",
        "er_tau_11_ci95lo" ="lower",
        "er_tau_11_ci95hi" ="upper",
        "er_slopes"        ="dense"
      ))
  }
  if(index == "residual"){
    d2 <- d2 %>%
      plyr::rename( c(
        "er_sigma_00_est"    ="mean",
        "er_sigma_00_ci95lo" ="lower",
        "er_sigma_00_ci95hi" ="upper",
        "er_resid"           ="dense"
      ))
  }
    d2 <- d2 %>%
      dplyr::mutate(
        dense = gsub("[$]p[$]","p",dense)
      ) %>%
      dplyr::select(
        study,model_number,subgroup,model_type, 
        # physical, cognitive, 
        process_a, process_b, 
        domain,n, mean, lower, upper, dense
      )
  return(d2)
}
# Usage
# data_forest <- get_forest_data(catalog_pretty,"pulmonary","intercept")

# ---- rename-domains -------------
# rename_domains <- function(
#   catalog_pretty_selected#,
#   # track_name
# ){
#   # browser()
#   # catalog_pretty_selected <- catalog
#   # track_name = "pulmonary"
#   # path_stencil = "./reports/correlation-3/rename-domains-"
#   # path = paste0(path_stencil,track_name,".csv")
#   path = "./reports/correlation-3/domain-grouping.csv"
#
#   d_rules <- readr::read_csv(path)#%>%
#     # dplyr::select(domain, domain_new, study, cognitive)
#
#   # t <- table(d$domain, d$study); t[t==0]<-"."; t
#   # join the model data frame to the conversion data frame.
#   d <- catalog_pretty_selected %>%
#     dplyr::left_join(d_rules )
#   # verify
#   # t <- table(d$domain, d$study);t[t==0]<-".";t
#   # t <- table(d$domain_new, d$study);t[t==0]<-".";t
#   d <- d %>%
#     dplyr::mutate(
#       domain = domain_new
#     ) %>%
#     dplyr::select(-domain_new)
#   return(d)
# }

print_forest_plot <- function(
  data_forest,
  domain_,
  subgroup_,
  index # = "slope"
){
  # domain_="gait"
  # subgroup_ = "male"
  d <- data_forest %>%
    dplyr::filter(
       domain   == domain_
      ,subgroup == subgroup_
    ) %>%
    dplyr::select(domain,study, 
                  process_a, process_b,
                  # physical, cognitive,
                  n,mean,lower, upper,dense )

  compute_average_effect <- function(d){
    (estimate <- d$mean)
    (sample_size <-   d$n)
    # (sd_est  <- sd(estimate,  na.rm =T))
    # (sum_est <- sum(estimate, na.rm =T))

    (mean_effect_est <- crossprod(estimate, sample_size)/sum(sample_size,na.rm=T) %>% as.numeric())
    # (mean_effect_se <- sd_est / sqrt(sum_est))
    (mean_effect_se <- plotrix::std.error(estimate))
    (mean_effect_lower  <- mean_effect_est - (mean_effect_se*1.96))
    (mean_effect_upper <- mean_effect_est + (mean_effect_se*1.96))

    forest_summary <- c(
      "mean" = mean_effect_est,
      "lower" = mean_effect_lower,
      "upper" = mean_effect_upper
    )
    return(forest_summary)
  }
  forest_summary <- d %>% compute_average_effect()


  text_top <- data.frame(
    "study"     =  c(NA,"Study"),
    "process_a"  =  c("Process","A"),
    "process_b"  = c("Process","B"),
    "n"         =  c("Sample","size"),
    "dense"     = as.character(c(NA,NA))
  )
  d_text <- d %>%
    dplyr::mutate(n = scales::comma(n) ) %>%
    dplyr::select(study, process_a, process_b, n, dense) %>%
    as.data.frame()
  d_text <- dplyr::bind_rows(text_top, d_text)
  n_rows <- nrow(d_text)
  d_text[(n_rows+1):(n_rows+2),] <- NA
  # d_text[nrow(d_text),"cognitive"] <- toupper(domain_)
  d_text[nrow(d_text),"process_a"] <- "Summary"
  d_text[nrow(d_text),"dense"] <- sprintf("%s (%s, %s)",
                                          numformat(forest_summary["mean"]),
                                          numformat(forest_summary["lower"]),
                                          numformat(forest_summary["upper"]))
  d_value <- data.frame(
    "mean" = c(NA,NA,d$mean, NA, forest_summary["mean"]),
    "lower"= c(NA,NA,d$lower,NA, forest_summary["lower"]),
    "upper"= c(NA,NA,d$upper,NA, forest_summary["upper"])
  )
  gender_name   <- ifelse(subgroup_=="male","MEN","WOMEN")
  # title_dynamic <- paste0(toupper(index)," correlations in ",toupper(domain_)," domain among ",gender_name,"S")
  title_dynamic <- paste0(toupper(domain_),": correlations between ",toupper(index),"S for ",gender_name)
  g <- forestplot::forestplot(
    d_text,
    d_value,
    # boxsize = .25,
    # mean       = d$mean,
    # lower      = d$lower,
    # upper      = d$upper,
    align      = c("r","r","l","c","c","c"),
    new_page   = TRUE,
    # is.summary = c(FALSE,FALSE,rep(FALSE,n_rows-1),TRUE),
    is.summary = c(TRUE,TRUE,rep(FALSE,n_rows-1),TRUE),
     clip       = c(-1,1),
    # xlog       = TRUE,
    txt_gp = fpTxtGp(label = list(gpar(fontfamily = "",cex=1),
                                  gpar(fontfamily = "",cex=1),
                                  gpar(fontfamily = "",cex=1),
                                  gpar(fontfamily = "",cex=1)
                                  ),
                     ticks = gpar(fontfamily = "", cex=1),
                     xlab  = gpar(fontfamily = "HersheySerif", cex = 1.5)
                     ),
    col        = fpColors(box     = "black",
                          line    = "black",
                          summary = "black"),
    # hrzl_lines = list("3" = gpar(lty=1)),
    hrzl_lines =  gpar(col="#444444"),
    graph.pos  = 5,
    title = title_dynamic
    # title = paste0("Slope correlations among ",toupper(subgroup_),"S")
  )
  return(g)
}
# Usage:
# print_forest_plot(catalog,"pulmonary","memory")


