  #load libraries
  if(!require(pacman)) {
    install.packages("pacman")
    library(pacman)
  }
  
  pacman::p_load(RNOmni, tidyverse, dplyr, plyr, tidyr)
  
  home_path   <- '~/REWOD'
  #home_path       <- '/Users/evapool/mountpoint2'
  
  analysis_path <-file.path(home_path,'DERIVATIVES/GLM/PIT/GLM-04/group_covariates/')
  setwd(analysis_path)
  
  data_path <- file.path(home_path,'DERIVATIVES/BEHAV') 
  
  
  PIT  <- read.delim(file.path(data_path,'PIT/REWOD_PIT_ses_second.txt'), header = T, sep ='') # read in dataset
  
  
  ## remove sub 8 (we dont have scans)
  PIT <- subset (PIT,!id == '8') 
  
  # define factors
  fac <- c("id", "session", "condition",  "trialxcondition")
  PIT[fac] <- lapply(PIT[fac], factor)
  
  #subset 
  PIT <- subset (PIT,task == 'PIT') 
  PIT.s <- subset (PIT, condition != 'Baseline')

  #create contrast
  CSp = subset(PIT.s, condition == 'CSplus')
  CSm = subset(PIT.s, condition == 'CSminus'); diff = CSp;
  diff$n_grips = CSp$n_grips - CSm$n_grips; 
  
  #agregate
  PIT.means <- aggregate( diff$n_grips, by = list(diff$id), FUN='mean') # extract means
  colnames(PIT.means) <- c('id','n_grips')
  

  PIT.means$id= as.numeric(as.character(PIT.means$id))
  
  # COVARIATE RANKNORM ------------------------------------------------------
  #centered
  PIT.means$n_gripsC = scale(PIT.means$n_grips, scale = F)
  plot(density(PIT.means$n_gripsC)) #skewed
  diffC = select(PIT.means, c(id, n_gripsC))
  
  #z-scored
  PIT.means$n_gripsZ = scale(PIT.means$n_grips)
  plot(density(PIT.means$n_gripsZ)) #skewed
  diffZ = select(PIT.means, c(id, n_gripsZ))
  
  # Ranked
  PIT.means$n_gripsR = rank(PIT.means$n_gripsZ)
  plot(density(PIT.means$n_gripsR))
  diffR = select(PIT.means, c(id, n_gripsR))
  
  # RankNorm (Draw from chi-1 distribution)
  PIT.means$n_gripsT = RankNorm(PIT.means$n_gripsZ[,])
  plot(density(PIT.means$n_gripsT))
  diffT = select(PIT.means, c(id, n_gripsT))
  
  write.table(diffC, (file.path(analysis_path, "CSp-CSm_eff_c.txt")), row.names = F, sep="\t") 
  write.table(diffZ, (file.path(analysis_path, "CSp-CSm_eff_z.txt")), row.names = F, sep="\t")
  write.table(diffR, (file.path(analysis_path, "CSp-CSm_eff_rank.txt")), row.names = F, sep="\t")
  write.table(diffT, (file.path(analysis_path, "CSp-CSm_eff_ranknorm.txt")), row.names = F, sep="\t")