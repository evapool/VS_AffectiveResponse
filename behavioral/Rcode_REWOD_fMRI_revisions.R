#                                                                                                  #
#                                                                                                  #          #                                                                                                  #
#                                                                                                  #
#     Differential contributions of ventral striatum subregions in the motivational                #
#           and hedonic components of the affective processing of the reward                       #
#                                                                                                  #
#                                                                                                  #
#                   Eva R Pool                                                                     #
#                   David Munoz Tord                                                               #
#                   Sylvain Delplanque                                                             #
#                   Yoann Stussi                                                                   #
#                   Donato Cereghetti                                                              #
#                   Patrik Vuilleumier                                                             #
#                   David Sander                                                                   #
#                                                                                                  #
# Created by D.M.T. on NOVEMBER 2018                                                               #
# modified by E.R.P on  NOVEMBER 2021                                                              #
# modified by D.M.T. on October 2021                                                               #
# TO ADRESS CONCERN: TRY TO REMOVE LEFT VS DL TO TEST FOR POTENTIAL MOVEMENT CONFUNDS              #


if(!require(ddpcr)) {
  install.packages("ddpcr")
  library(ddpcr)
}  # to do quiet source

#SETUP
# Set path
home_path       <- dirname(dirname(rstudioapi::documentPath()))

# Set working directory
analysis_path <- file.path(home_path, 'behavioral')

if (analysis_path != getwd()) #important for when we source !!
  setwd(analysis_path)


quiet(source(file.path(analysis_path, "Rcode_REWOD_fMRI.R")), all=T) # run script quietly



# ------------------------------------- HED ROI during PIT -----------------------------------------
HED.ROI.TASK.PIT <- merge(PIT.index, ROI_HED.CSpCSm, by = 'ID')

# rename variables for this database
HED.ROI.TASK.PIT <- rename.variable(HED.ROI.TASK.PIT, 'HED_VS_VM_betas', 'VS_VM')
HED.ROI.TASK.PIT <- rename.variable(HED.ROI.TASK.PIT, 'HED_mOFC_betas', 'mOFC')
HED.ROI.TASK.PIT$ROI_type = 'hed_ROI'



########################################### BUILD HED BETA DATABASE ################################################

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



########################################### DIRECT COMPARAISON DURING PIT IN VS ################################################


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
intROIHED.BF





