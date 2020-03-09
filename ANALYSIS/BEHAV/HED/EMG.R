## R code for FOR REWOD GENERAL
# last modified on August 2019 by David


# -----------------------  PRELIMINARY STUFF ----------------------------------------
# load libraries
pacman::p_load(ggplot2, dplyr, plyr, tidyr, reshape, reshape2, Hmisc, corrplot, ggpubr, gridExtra, mosaic, car, purrr)

if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}




#SETUP
task = 'hedonic'
con_name2 = 'Reward-Neutral'
con2 = 'reward-neutral'

mod2 = 'EMG'




## R code for FOR REWOD_HED
# Set working directory -------------------------------------------------


analysis_path <- file.path('~/REWOD/DERIVATIVES/ANALYSIS', task) 
setwd(analysis_path)

# open dataset 18 !
BETAS_R_N <- read.delim(file.path(analysis_path, 'ROI', paste('extracted_betas_',con_name2,'.txt',sep="")), header = T, sep ='\t') # read in dataset


EMG_R_N <- read.delim(file.path(analysis_path, 'GLM-18', 'group_covariates', paste('REV_', con2,'_', mod2, '_zscore.txt',sep="")), header = T, sep ='\t') # read in dataset

# merge
R_N_EMG = merge(BETAS_R_N, EMG_R_N, by.x = "ID", by.y = "subj", all.x = TRUE)


# define factors
R_N_EMG$ID <- factor(R_N_EMG$ID)



# PLOT FUNCTIONS --------------------------------------------------------------------


R_N_EMG %>%
  keep(is.numeric) %>% 
  gather() %>% 
  ggplot(aes(value)) +
  facet_wrap(~ key, scales = "free") +
  geom_density() 

Boxplot(~vmPFC_betas, data= R_N_EMG, id=TRUE) # identify all outliers
Boxplot(~subgen_betas, data= R_N_EMG, id=TRUE) 



# open dataset 16 !
R_N_EMG16 <- read.delim(file.path(analysis_path, 'ROI', paste('extracted_betas_GLM_16.txt',sep="")), header = T, sep ='\t') # read in dataset


# PLOT FUNCTIONS --------------------------------------------------------------------

R_N_EMG16 %>%
  keep(is.numeric) %>% 
  gather() %>% 
  ggplot(aes(value)) +
  facet_wrap(~ key, scales = "free") +
  geom_density() 

Boxplot(~OFC_betas, data= R_N_EMG16, id=TRUE) # identify all outliers
Boxplot(~shell_R_betas, data= R_N_EMG16, id=TRUE) 


# open dataset 15 !
R_N_EMG15 <- read.delim(file.path(analysis_path, 'ROI', paste('extracted_betas_GLM_15.txt',sep="")), header = T, sep ='\t') # read in dataset


# PLOT FUNCTIONS --------------------------------------------------------------------

R_N_EMG15 %>%
  keep(is.numeric) %>% 
  gather() %>% 
  ggplot(aes(value)) +
  facet_wrap(~ key, scales = "free") +
  geom_density() 


Boxplot(~OFC_betas, data= R_N_EMG15, id=TRUE) # identify all outliers
Boxplot(~shell_R_betas, data= R_N_EMG15, id=TRUE) 


