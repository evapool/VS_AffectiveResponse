####################################################################################################
#                                                                                                  #
#                                                                                                  #                                                 #                                                                                                  #
#     Differential contributions of ventral striatum subregions in the motivational                #
#           and hedonic components of the affective processing of the reward                       #
#                                                                                                  #
#                                                                                                  #
#                   Eva R Pool                                                                     #
#                   David Munoz Tord                                                               #
#                   Sylvain Delplanque                                                             #
#                   Yoann Stussi  
#                   Donato Cereghetti
#                   Patrik Vuilleumier                                                             #
#                   David Sander                                                                   #
#                                                                                                  #
# Created by D.M.T. on NOVEMBER 2018                                                               #
# modified by E.R.P on  NOVEMBER 2021 
#
# TO ADRESS CONCERN: TRY TO REMOVE LEFT VS DL TO TEST FOR POTENTIAL MOVEMENT CONFUNDS
####################################################################################################



#--------------------------------------  PRELIMINARY STUFF ----------------------------------------
#load libraries
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}

pacman::p_load(apaTables, MBESS, afex, car, ggplot2, dplyr, plyr, tidyr, 
               reshape, Hmisc, Rmisc,  ggpubr, ez, gridExtra, plotrix, 
               lsmeans, BayesFactor, effectsize, devtools,misty,questionr,ggplot, ggExtra,
               doBy,BayesFactor,BayesianFirstAid)

if(!require(devtools)) {
  install.packages("devtools")
  library(devtools)
}

se <- function (x,na.rm=TRUE) {
  if (!is.vector(x)) STOP("'x' must be a vector.")
  if (!is.numeric(x)) STOP("'x' must be numeric.")
  if (na.rm) x <- x[stats::complete.cases(x)]
  sqrt(stats::var(x)/length(x))
}


#SETUP
# Set path
home_path       <- dirname(rstudioapi::getActiveDocumentContext()$path)
pos             <- regexpr("VS_AffectiveResponse", home_path) # we want the path to the root folder
home_path       <- substr(home_path, 1, pos+19)


# Set working directory
analysis_path <- file.path(home_path, 'behavioral')
setwd(analysis_path)


# open datasets
PIT  <- read.delim(file.path(analysis_path, 'databases/REWOD_PIT_ses_second.txt'), header = T, sep ='') # read in dataset
HED  <- read.delim(file.path(analysis_path, 'databases/REWOD_HEDONIC_ses_second.txt'), header = T, sep ='') # read in dataset


ROI_HED.lik     <- read.delim(file.path(analysis_path, 'databases/Betas_ROI_Hed_TASK_Hed.txt'), header = T, sep ='') 
ROI_HED.CSpCSm  <- read.delim(file.path(analysis_path, 'databases/Betas_ROI_Hed_task_PIT.txt'), header = T, sep ='') 
ROI_PIT.lik     <- read.delim(file.path(analysis_path, 'databases/Betas_ROI_PIT_TASK_hedonic.txt'), header = T, sep ='') 
ROI_PIT.CSpCSm  <- read.delim(file.path(analysis_path, 'databases/Betas_ROI_PIT_TASK_PIT.txt'), header = T, sep ='') 






# -------------------------------------------------------------------------------------------------
#                                             PREPROC
# -------------------------------------------------------------------------------------------------

#-------------------------------------  PIT   -----------------------------------------------------

# PIT
PIT.all <- PIT
fac <- c("id", "session", "condition",  "trialxcondition")
PIT.all[fac] <- lapply(PIT.all[fac], factor)
PIT <- subset (PIT.all,task == 'PIT') 
PIT <- subset (PIT, condition == 'CSplus'| condition == 'CSminus')
PIT.means <- aggregate(PIT$n_grips, by = list(PIT$id, PIT$condition), FUN='mean') # extract means
colnames(PIT.means) <- c('id','condition','n_grips')

# compute index of interest
PIT.means <- ddply(PIT.means, .(id), transform, deltaCS = n_grips[condition=="CSplus"] - n_grips[condition=="CSminus"])
PIT.means <- subset(PIT.means, condition == 'CSplus')
PIT.means$deltaCS_Z  = scale(PIT.means$deltaCS, scale = F)
PIT.means$deltaCS_R = rank(PIT.means$deltaCS_Z)
PIT.index <- rename.variable(PIT.means, 'id', 'ID')

#-------------------------------------- HED -----------------------------------------------------------
fac <- c("id", "condition",  "trialxcondition")
HED[fac] <- lapply(HED[fac], factor)
HED.s <- subset (HED, condition == 'neutral'| condition == 'chocolate')



# -------------------------------------------------------------------------------------------------
#                                      BUILD PIT BETA DATABASE
# -------------------------------------------------------------------------------------------------

# ------------------------------------- PIT ROI during PIT -----------------------------------------

# Compile database
PIT.ROI.TASK.PIT <- merge(PIT.index, ROI_PIT.CSpCSm, by = 'ID')
# rename variables for this database
PIT.ROI.TASK.PIT <- rename.variable(PIT.ROI.TASK.PIT, 'PIT_EFF_VSDL_right_betas', 'VS_DL_right')
PIT.ROI.TASK.PIT <- rename.variable(PIT.ROI.TASK.PIT, 'PIT_Eff_VSDL_left_betas', 'VS_DL_left')

# remove ROI from CS+ vs CS- independent from effort AND VS DL left to adress possible residual motor confunds
PIT.ROI.TASK.PIT = PIT.ROI.TASK.PIT %>% select(-one_of('PIT_CS_VS_right_betas','PIT_CS_VS_left_betas','VS_DL_left'))
PIT.ROI.TASK.PIT$ROI_type = 'Pav_ROI'

# long format for comparison later
PIT.ROI.TASK.PIT.long <- gather(PIT.ROI.TASK.PIT, ROI , beta, VS_DL_right, factor_key=TRUE)
PIT.ROI.TASK.PIT.long$ROI_type = 'Pav_ROI'



# ------------------------------------- HED ROI during PIT -----------------------------------------
HED.ROI.TASK.PIT <- merge(PIT.index, ROI_HED.CSpCSm, by = 'ID')

# rename variables for this database
HED.ROI.TASK.PIT <- rename.variable(HED.ROI.TASK.PIT, 'HED_VS_VM_betas', 'VS_VM')
HED.ROI.TASK.PIT <- rename.variable(HED.ROI.TASK.PIT, 'HED_mOFC_betas', 'mOFC')
HED.ROI.TASK.PIT$ROI_type = 'hed_ROI'



# -------------------------------------------------------------------------------------------------
#                                     BUILD HED BETA DATABASE
# -------------------------------------------------------------------------------------------------

# ------------------------------------- HED ROI during HED -----------------------------------------

HED.ROI.HED.TASK <- ROI_HED.lik

# rename variables for this database
HED.ROI.HED.TASK <- rename.variable(HED.ROI.HED.TASK, 'HED_VS_VM_betas', 'VS_VM')
HED.ROI.HED.TASK <- rename.variable(HED.ROI.HED.TASK, 'HED_mOFC_betas', 'mOFC')



# ------------------------------------- PIT ROI during HED -----------------------------------------

PIT.ROI.HED.TASK <- merge(PIT.index, ROI_PIT.lik, by = 'ID')

# rename variables for this database
PIT.ROI.HED.TASK <- rename.variable(PIT.ROI.HED.TASK, 'PIT_EFF_VSDL_right_betas', 'VS_DL_right')
PIT.ROI.HED.TASK <- rename.variable(PIT.ROI.HED.TASK, 'PIT_Eff_VSDL_left_betas', 'VS_DL_left')

# remove ROI from CS+ vs CS- independent from effort AND VS DL left to adress possible residual motor confunds
PIT.ROI.HED.TASK %>% select(-one_of('PIT_CS_VS_right_betas','PIT_CS_VS_left_betas','VS_DL_left'))

# long format for comparing later
PIT.ROI.HED.TASK.long <- gather(PIT.ROI.HED.TASK, ROI , beta, VS_DL_right, factor_key=TRUE)



# ------------------------------------------------------------------------------------------------------
#                                       DIRECT COMPARAISON DURING PIT IN VS
# ------------------------------------------------------------------------------------------------------

# ----------------------------------------------PIT TASK -----------------------------------------------

CM.HED.ROI.PIT = HED.ROI.TASK.PIT
CM.HED.ROI.PIT = CM.HED.ROI.PIT %>% select(-one_of('mOFC','HED_VS_small_betas'))
CM.HED.ROI.PIT <- rename.variable(CM.HED.ROI.PIT, 'VS_VM', 'beta')

# select only the variable of interest
CM.HED.ROI.PIT = select(CM.HED.ROI.PIT, 'ID','deltaCS_R','ROI_type','beta')
CM.PIT.ROI.PIT = select(PIT.ROI.TASK.PIT.long, 'ID','deltaCS_R','ROI_type','beta')

PIT.ROI.COMPARE <- join (CM.HED.ROI.PIT, CM.PIT.ROI.PIT, type = 'full')

PIT.ROI.COMPARE.means <- aggregate(PIT.ROI.COMPARE$beta, 
                                   by = list(PIT.ROI.COMPARE$ID,PIT.ROI.COMPARE$ROI_type, PIT.ROI.COMPARE$deltaCS_R), FUN='mean') # extract means
colnames(PIT.ROI.COMPARE.means) <- c('ID','ROI_type','deltaCS_R','beta')

PIT.ROI.COMPARE.means$ROI_type = factor(PIT.ROI.COMPARE.means$ROI_type)

# test
directPITroi.stat     <- aov_car(beta ~ deltaCS_R*ROI_type  + Error (ID/ROI_type ), data = PIT.ROI.COMPARE,
                                 observed = c("deltaCS_R"), factorize = F, anova_table = list(es = "pes"))
F_to_eta2(f = c(6.85), df = c(1), df_error = c(22)) # effect sizes (90%CI)


intROIPIT.BF <- generalTestBF(beta ~ ROI_type*deltaCS_R + ID, data = PIT.ROI.COMPARE.means, 
                              whichRandom = "ID", iterations = 50000)
intROIPIT.BF <- recompute(intROIPIT.BF , iterations = 50000)
intROIPIT.BF[9]/intROIPIT.BF[8] 


# ----------------------------------------------HED TASK -----------------------------------------------

CM.HED.ROI.HED = HED.ROI.HED.TASK
CM.HED.ROI.HED = CM.HED.ROI.HED %>% select(-one_of('mOFC','HED_VS_small_betas'))
CM.HED.ROI.HED <- rename.variable(CM.HED.ROI.HED, 'VS_VM', 'beta')
CM.HED.ROI.HED$ROI_type = 'hed_ROI'

# select only the variable of interest
CM.PIT.ROI.PIT = select(PIT.ROI.HED.TASK.long, 'ID','deltaCS_R','beta')
CM.PIT.ROI.PIT$ROI_type = 'pav_ROI'

HED.ROI.COMPARE <- join (CM.HED.ROI.PIT, CM.PIT.ROI.PIT, type = 'full')

HED.ROI.COMPARE.means <- aggregate(HED.ROI.COMPARE$beta, 
                                   by = list(HED.ROI.COMPARE$ID,HED.ROI.COMPARE$ROI_type), FUN='mean') # extract means
colnames(HED.ROI.COMPARE.means) <- c('ID','ROI_type','beta')

HED.ROI.COMPARE.means$ROI_type = factor(HED.ROI.COMPARE.means$ROI_type)

# test
directHEDroi.stat     <- aov_car(beta ~ ROI_type  + Error (ID/ROI_type), data = HED.ROI.COMPARE, 
                                 factorize = F, anova_table = list(es = "pes"))
F_to_eta2(f = c(4.50), df = c(1), df_error = c(23)) # effect sizes (90%CI)


intROIHED.BF <- anovaBF(beta ~ ROI_type + ID, data = HED.ROI.COMPARE.means, 
                        whichRandom = "ID", iterations = 50000)
intROIHED.BF <- recompute(intROIHED.BF, iterations = 50000)
intROIHED.BF





