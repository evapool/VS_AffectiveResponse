#                                                                                                  #
#                                                                                                  #          
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
# modified by E.R.P on  JANUARY  2021                                                              #
# modified by D.M.T. on October  2021                                                              #
# modified by E.R.P  on NOVEMBER  2021                                                             # 

#--------------------------------------  PRELIMINARY STUFF ----------------------------------------
#load libraries
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}

pacman::p_load(apaTables, MBESS, afex, car, ggplot2, dplyr, plyr, tidyr, 
               reshape, Hmisc, Rmisc,  ggpubr, ez, gridExtra, plotrix, 
               lsmeans, BayesFactor, effectsize, devtools,misty,questionr,ggplot, ggExtra, doBy,BayesFactor, BayesianFirstAid)

if(!require(devtools)) {
  install.packages("devtools")
  library(devtools)
}


# get tool
devtools::source_gist("2a1bb0133ff568cbe28d", 
                      filename = "geom_flat_violin.R")

devtools::source_gist("383aa93ffa161665c0dca1103ef73d9d", 
                      filename = "effect_CI.R")


# SETUP -------------------------------------------------------------------


# Set path
home_path       <-    dirname(dirname(rstudioapi::getActiveDocumentContext()$path))


# Set working directory
analysis_path <- file.path(home_path, 'behavioral')
covariatePIT_path <- file.path(home_path, 'univariate/PIT/group_covariates')
covariateHED_path <- file.path(home_path, 'univariate/HED/group_covariates')
figures_path <- file.path(analysis_path, 'figures')

if (analysis_path != getwd()) # important for when we source 
  setwd(analysis_path)


# open datasets
PAV  <- read.delim(file.path(analysis_path, 'databases/REWOD_PAVCOND_ses_first.txt'), header = T, sep ='') # read in dataset
INST <- read.delim(file.path(analysis_path, 'databases/REWOD_INSTRU_ses_first.txt'), header = T, sep ='') # read in dataset
PIT  <- read.delim(file.path(analysis_path, 'databases/REWOD_PIT_ses_second.txt'), header = T, sep ='') # read in dataset
HED  <- read.delim(file.path(analysis_path, 'databases/REWOD_HEDONIC_ses_second.txt'), header = T, sep ='') # read in dataset


ROI_HED.lik     <- read.delim(file.path(analysis_path, 'databases/Betas_ROI_Hed_TASK_Hed.txt'), header = T, sep ='') 
ROI_HED.CSpCSm  <- read.delim(file.path(analysis_path, 'databases/Betas_ROI_Hed_task_PIT.txt'), header = T, sep ='') 
ROI_PIT.lik     <- read.delim(file.path(analysis_path, 'databases/Betas_ROI_PIT_TASK_hedonic.txt'), header = T, sep ='') 
ROI_PIT.CSpCSm  <- read.delim(file.path(analysis_path, 'databases/Betas_ROI_PIT_TASK_PIT.txt'), header = T, sep ='') 

# remove variable we do not use
ROI_PIT.CSpCSm = ROI_PIT.CSpCSm%>% select(-one_of('PIT_CS_VS_right_betas','PIT_CS_VS_left_betas')) # remove ROI defined based on the CS+ vs CS- constrast without considering effort
ROI_PIT.lik = ROI_PIT.lik%>% select(-one_of('PIT_CS_VS_right_betas','PIT_CS_VS_left_betas')) # remove ROI defined based on the CS+ vs CS- constrast without considering effort

ROI_HED.lik    =  ROI_HED.lik%>% select(-one_of('HED_VS_small_betas')) # remove ROI that did not survive correction
ROI_HED.CSpCSm =  ROI_HED.CSpCSm%>% select(-one_of('HED_VS_small_betas')) # remove ROI that did not survive correction

# rename variable for clarity
ROI_PIT.CSpCSm  <- rename.variable(ROI_PIT.CSpCSm, 'PIT_EFF_VSDL_right_betas', 'VS_DL_right') # now that we only have ROI based on the same constrast we do no need to specify the constrast name in the name variable
ROI_PIT.CSpCSm <- rename.variable(ROI_PIT.CSpCSm, 'PIT_Eff_VSDL_left_betas', 'VS_DL_left')

ROI_PIT.lik  <- rename.variable(ROI_PIT.lik, 'PIT_EFF_VSDL_right_betas', 'VS_DL_right') # now that we only have ROI based on the same constrast we do no need to specify the constrast name in the name variable
ROI_PIT.lik <- rename.variable(ROI_PIT.lik, 'PIT_Eff_VSDL_left_betas', 'VS_DL_left')

# rename for clarity
ROI_HED.lik  <- rename.variable(ROI_HED.lik, 'HED_VS_VM_betas', 'VS_VM') # simply remove betas form the name
ROI_HED.lik  <- rename.variable(ROI_HED.lik, 'HED_mOFC_betas', 'mOFC') # simply remove betas form the name
ROI_HED.CSpCSm  <- rename.variable(ROI_HED.CSpCSm, 'HED_mOFC_betas', 'mOFC') # simply remove betas form the name
ROI_HED.CSpCSm  <- rename.variable(ROI_HED.CSpCSm, 'HED_VS_VM_betas', 'VS_VM') # simply remove betas form the name

# get betas from ROI defined by Cartmell et al., 2019
HED.TASK     <- read.csv(file.path(analysis_path, 'databases/Betas_TASK_HED.csv')) 
PIT.TASK   <- read.csv(file.path(analysis_path, 'databases/Betas_TASK_PIT.csv')) 


# themes for plots

averaged_theme_regression <- theme_bw(base_size = 28, base_family = "Helvetica")+
  theme(strip.text.x = element_text(size = 28, face = "bold"),
        strip.background = element_rect(color="white", fill="white", linetype="solid"),
        legend.position="none",
        legend.text  = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.title.x = element_text(size = 28),
        axis.title.y = element_text(size =  28),
        axis.line = element_line(size = 0.5),
        panel.border = element_blank())

averaged_theme_ttest <- theme_bw(base_size = 28, base_family = "Helvetica")+
  theme(strip.text.x = element_text(size = 28, face = "bold"),
        strip.background = element_rect(color="white", fill="white", linetype="solid"),
        legend.position="none",
        legend.text  = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.title.y = element_text(size =  28),
        axis.line = element_line(size = 0.5),
        panel.border = element_blank())


pal = viridis::inferno(n=5)


########################################### PREPROCESSING ################################################

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

# write group covariate for SPM analysis
diffR = select(PIT.index, c(ID, deltaCS_R))
diffR$ID <- as.numeric(as.character(diffR$ID))
write.table(diffR, (file.path(covariatePIT_path, "CSp-CSm_eff_rank.txt")), row.names = F, sep="\t")


#-------------------------------------- PAV  -----------------------------------------------------
fac <- c("id", "session", "condition",  "trial")
PAV[fac] <- lapply(PAV[fac], factor)
PAV$RT               <- PAV$RT * 1000# get times in milliseconds 
#Preprocessing RT
PAV.clean <- filter(PAV, rounds == 1)##only first round
PAV.clean$condition <- droplevels(PAV.clean$condition, exclude = "Baseline")
##shorter than 100ms and longer than 3sd+mean
PAV.clean <- filter(PAV.clean, RT >= 100) # min RT is 106ms
PAV.clean <- ddply(PAV.clean, .(id), transform, RTm = mean(RT))
PAV.clean <- ddply(PAV.clean, .(id), transform, RTsd = sd(RT))
PAV.clean <- filter(PAV.clean, RT <= RTm+3*RTsd) 

#compute mean and index
PAV.means <- aggregate(PAV.clean$RT, by = list(PAV.clean$id, PAV.clean$condition, PAV.clean$liking_ratings), FUN='mean') # extract means
colnames(PAV.means) <- c('id','condition','liking','RT')
#index RT
PAV.means <- ddply(PAV.means, .(id), transform, deltaCS_RT = RT[condition=="CSplus"] - RT[condition=="CSminus"])
#index CSliking
PAV.means <- ddply(PAV.means, .(id), transform, deltaCS_lik = liking[condition=="CSplus"] - liking[condition=="CSminus"])

PAV.means <- rename.variable(PAV.means, 'id', 'ID')
PAV.index <- subset(PAV.means, condition == 'CSplus')



#-------------------------------------- HED -----------------------------------------------------------
fac <- c("id", "condition",  "trialxcondition")
HED[fac] <- lapply(HED[fac], factor)

HED.s <- subset (HED, condition == 'neutral'| condition == 'chocolate')

# mean and index
HED.means <- aggregate(HED.s$perceived_liking, by = list(HED.s$id, HED.s$condition), FUN='mean') # extract means

colnames(HED.means) <- c('id','condition','perceived_liking')
#index US liking
HED.means <- ddply(HED.means, .(id), transform, deltaUS_lik = perceived_liking[condition=="chocolate"] - perceived_liking[condition=="neutral"])

#index US liking
HED.means <- ddply(HED.means, .(id), transform, US_lik = mean(perceived_liking[condition=="chocolate"]))
HED.index <- subset(HED.means, condition == 'chocolate')

HED.index <- rename.variable(HED.index, 'id', 'ID')

#index odor intensity
HED.int.means <- aggregate(HED$perceived_intensity, by = list(HED$id, HED$condition), FUN='mean') # extract means
colnames(HED.int.means) <- c('id','condition','perceived_intensity')
HED.int.means <- ddply(HED.int.means, .(id), transform, 
                       delta_int = mean(perceived_intensity[condition=="chocolate" | condition =="neutral"] - mean(perceived_intensity[condition == "empty"])))
HED.int.index <- subset(HED.int.means, condition == 'chocolate')

HED.int.index <- rename.variable(HED.int.index, 'id', 'ID')


# write group covariate for SPM analysis
diffL = select(HED.index, c(ID, deltaUS_lik))
diffL$ID <- as.numeric(as.character(diffL$ID))
write.table(diffL, (file.path(covariateHED_path, "Pleasant_Neutral.txt")), row.names = F, sep="\t")



########################################### PIT ################################################

# ------------------------------------- PIT ROI during PIT -----------------------------------------

# Compile database
PIT.ROI.TASK.PIT <- merge(PIT.index, ROI_PIT.CSpCSm, by = 'ID')

# long format for left and right
PIT.ROI.TASK.PIT.long <- gather(PIT.ROI.TASK.PIT, ROI , beta, VS_DL_right:VS_DL_left, factor_key=TRUE)

PIT.ROI.TASK.PIT.long$ROI_type = 'PIT_ROI'

# -------------------------------- STAT (to check if there is an interaction with ROI )
VS_DL_eff.stat     <- aov_car(beta ~ deltaCS_R + ROI + Error (ID/ROI), data = PIT.ROI.TASK.PIT.long,
                              observed = c("deltaCS_R"), factorize = F, anova_table = list(es = "pes"))
F_to_eta2(f = c(41.89), df = c(1), df_error = c(22)) # effect sizes (90%CI)

emmeans(VS_DL_eff.stat,  ~ ROI:deltaCS_R)




# -------------------------------- PLOT
PIT.ROI.TASK.PIT.means <- aggregate(PIT.ROI.TASK.PIT.long$beta, by = list(PIT.ROI.TASK.PIT.long$ID, PIT.ROI.TASK.PIT.long$deltaCS_R), FUN='mean') # extract means
colnames(PIT.ROI.TASK.PIT.means) <- c('ID','beta', 'effort')

pp <- ggplot(PIT.ROI.TASK.PIT.means, aes(y = effort, x = beta)) +
  geom_point(color = pal[2]) +
  geom_smooth(method='lm', color = pal[2], fill = pal[2], alpha = 0.2,fullrange=TRUE) +
  labs(y = 'Beta estimates (a.u)', x ='Cue-triggered effort (rank)') +
  scale_fill_manual(values=pal[2], guide = 'none') +
  theme_bw()

ppp <- pp + averaged_theme_regression

pppp <- ggMarginal(ppp + theme(legend.position = c(1, 1), legend.justification = c(1, 1),
                               legend.background = element_rect(color = "white")), 
                   type = "density", alpha = .1, color = NA, fill = pal[2], margin = 'y') 

pdf(file.path(figures_path,'Figure_VS_DorsoLateral_PIT.pdf'))
print(pppp)
dev.off()




# ------------------------------------- HED ROI during PIT -----------------------------------------
HED.ROI.TASK.PIT <- merge(PIT.index, ROI_HED.CSpCSm, by = 'ID')
HED.ROI.TASK.PIT$ROI_type = 'hed_ROI'


#mOFC
mOFC_eff.stat             <- aov_car(mOFC ~ deltaCS_R + Error (ID), data = HED.ROI.TASK.PIT,
                                     observed = c("deltaCS_R"), factorize = F, anova_table = list(es = "pes")) # no
F_to_eta2(f = c(0.06), df = c(1), df_error = c(22)) # effect sizes (90%CI)
intROIPIT.BF <- lmBF(mOFC ~ deltaCS_R + ID, data = HED.ROI.TASK.PIT, 
                                        whichRandom = "ID", iterations = 50000)

#VS VENTRO MEDIAL
VS_VM_eff.stat     <- aov_car(VS_VM ~ deltaCS_R + Error (ID), data = HED.ROI.TASK.PIT,
                                     observed = c("deltaCS_R"), factorize = F, anova_table = list(es = "pes")) # no
F_to_eta2(f = c(0.69), df = c(1), df_error = c(22)) # effect sizes (90%CI)
intROIPIT.BF <- lmBF(VS_VM ~ deltaCS_R + ID, data = HED.ROI.TASK.PIT, 
                     whichRandom = "ID", iterations = 50000)


# -------------------------------- PLOT

# pannel 1
pp <- ggplot(HED.ROI.TASK.PIT, aes(y = mOFC, x = deltaCS_R)) +
  geom_point(color = pal[2]) +
  geom_smooth(method='lm', color = pal[2], fill = pal[2], alpha = 0.2,fullrange=TRUE) +
  labs(y = 'Beta estimates (a.u)', x ='Cue-triggered effort (rank)') +
  scale_fill_manual(values=pal[2], guide = 'none') +
  theme_bw()

ppp <- pp + averaged_theme_regression 

pppp <- ggMarginal(ppp + theme(legend.position = c(1, 1), legend.justification = c(1, 1),
                               legend.background = element_rect(color = "white")), 
                   type = "density", alpha = .1, color = NA, fill = pal[2], margin = 'y') 

pdf(file.path(figures_path,'Figure_mOFC_PIT.pdf'))
print(pppp)
dev.off()

# pannel 2
pp <- ggplot(HED.ROI.TASK.PIT, aes(y = VS_VM, x = deltaCS_R)) +
  geom_point(color = pal[2]) +
  geom_smooth(method='lm', color = pal[2], fill = pal[2], alpha = 0.2,fullrange=TRUE) +
  labs(y = 'Beta estimates (a.u)', x ='Cue-triggered effort (rank)') +
  scale_fill_manual(values=pal[2], guide = 'none') +
  theme_bw()

ppp <- pp + averaged_theme_regression 

pppp <- ggMarginal(ppp + theme(legend.position = c(1, 1), legend.justification = c(1, 1),
                               legend.background = element_rect(color = "white")), 
                   type = "density", alpha = .1, color = NA, fill = pal[2], margin = 'y') 

pdf(file.path(figures_path,'Figure_VS_VentroMedial_PIT.pdf'))
print(pppp)
dev.off()




########################################### HEDONIC ################################################

# ------------------------------------- HED ROI during HED -----------------------------------------

HED.ROI.HED.TASK <- ROI_HED.lik


#------------------------------- STAT
# BF
ttestBF(HED.ROI.HED.TASK$VS_VM)
# effect size
cohen_d_ci(HED.ROI.HED.TASK$VS_VM, conf.level = .95)

# BF
ttestBF(HED.ROI.HED.TASK$mOFC)

# effect size
cohen_d_ci(HED.ROI.HED.TASK$mOFC, conf.level = .95)

# -------------------------------- PLOT

# SET SAME Y scale

# pannel 1
dfG = summaryBy(mOFC ~ 1, data = HED.ROI.HED.TASK,
                FUN = function(x) { c(m = mean(x, na.rm = T),
                                      s = se(x, na.rm = T)) } )

pp <- ggplot(HED.ROI.HED.TASK, aes(x = 0.5, y = mOFC)) +
  geom_abline(slope=0, intercept=0, linetype = "dashed", color = "gray") +
  geom_flat_violin(scale = "count", trim = FALSE, alpha = .2, color = NA, fill = pal[3], width = 0.5) +
  geom_jitter(alpha = .6, color = pal[3], width = 0.02) +
  geom_crossbar(data = dfG, aes(y =  mOFC.m, ymin= mOFC.m-mOFC.s, ymax= mOFC.m+mOFC.s), 
                width = 0.2 , alpha = 0.1, color = pal[3])+
  ylab('Beta estimates (a.u.)') +
  xlab('') + 
  scale_y_continuous(expand = c(-0, 0), breaks = c(seq.int(-0.035,0.06, by = 0.015)), limits = c(-0.035,0.06))  +
  scale_x_continuous(expand = c(0, 0), breaks = c(seq.int(0.2,0.8, by = 0.25)), limits = c(0.2,0.8))  +
  theme_bw()

ppp <- pp + averaged_theme_ttest 

pdf(file.path(figures_path,'Figure_mOFC_HED.pdf'))
print(ppp)
dev.off()


# pannel 2
dfG = summaryBy(VS_VM ~ 1, data = HED.ROI.HED.TASK,
                FUN = function(x) { c(m = mean(x, na.rm = T),
                                      s = se(x, na.rm = T)) } )

pp <- ggplot(HED.ROI.HED.TASK, aes(x = 0.5, y = VS_VM)) +
  geom_abline(slope=0, intercept=0, linetype = "dashed", color = "gray") +
  geom_flat_violin(scale = "count", trim = FALSE, alpha = .2, color = NA, fill = pal[3], width = 0.5) +
  geom_jitter(alpha = .6, color = pal[3], width = 0.02) +
  geom_crossbar(data = dfG, aes(y =  VS_VM.m, ymin= VS_VM.m-VS_VM.s, ymax= VS_VM.m+VS_VM.s), 
                width = 0.2 , alpha = 0.1, color = pal[3])+
  ylab('Beta estimates (a.u.)') +
  xlab('') +
  scale_y_continuous(expand = c(-0, 0), breaks = c(seq.int(-0.035,0.06, by = 0.015)), limits = c(-0.035,0.06))  +
  scale_x_continuous(expand = c(0, 0), breaks = c(seq.int(0.2,0.8, by = 0.25)), limits = c(0.2,0.8))  +
  theme_bw()

ppp <- pp + averaged_theme_ttest 

pdf(file.path(figures_path,'Figure_VS_VentroMedial_HED.pdf'))
print(ppp)
dev.off()


# ------------------------------------- PIT ROI during HED -----------------------------------------

PIT.ROI.HED.TASK <- merge(PIT.index, ROI_PIT.lik, by = 'ID')

# long format for left and right
PIT.ROI.HED.TASK.long <- gather(PIT.ROI.HED.TASK, ROI , beta, VS_DL_right:VS_DL_left, factor_key=TRUE)


# -------------------------------- STAT 
VS_DL_lik.stat     <- aov_car(beta ~ ROI + Error (ID/ROI), data = PIT.ROI.HED.TASK.long, factorize = F, anova_table = list(es = "pes")) 

# since there is no ROI effect let's compute the main effect on the average
PIT.ROI.HED.TASK.means <- aggregate(PIT.ROI.HED.TASK.long$beta, by = list(PIT.ROI.HED.TASK.long$ID), FUN='mean') # extract means
colnames(PIT.ROI.HED.TASK.means) <- c('ID','betas')
t.test(PIT.ROI.HED.TASK.means$betas)
# BF
ttestBF(PIT.ROI.HED.TASK.means$betas)
# effect size
cohen_d_ci(PIT.ROI.HED.TASK.means$betas, conf.level = .95)

# ----------------------------- PLOT
dfG = summaryBy(betas ~ 1, data = PIT.ROI.HED.TASK.means,
                FUN = function(x) { c(m = mean(x, na.rm = T),
                                      s = se(x, na.rm = T)) } )

pp <- ggplot(PIT.ROI.HED.TASK.means, aes(x = 0.5, y = betas)) +
  geom_abline(slope=0, intercept=0, linetype = "dashed", color = "gray") +
  geom_flat_violin(scale = "count", trim = FALSE, alpha = .2, color = NA, fill = pal[3], width = 0.5) +
  geom_jitter(alpha = .6, color = pal[3], width = 0.02) +
  geom_crossbar(data = dfG, aes(y =  betas.m, ymin= betas.m-betas.s, ymax= betas.m+betas.s), 
                width = 0.2 , alpha = 0.1, color = pal[3])+
  ylab('Beta estimates (a.u.)') +
  xlab('') + 
  #scale_y_continuous(expand = c(-0, 0), breaks = c(seq.int(-0.035,0.06, by = 0.015)), limits = c(-0.035,0.06))  +
  scale_x_continuous(expand = c(0, 0), breaks = c(seq.int(0.2,0.8, by = 0.25)), limits = c(0.2,0.8))  +
  theme_bw()

ppp <- pp + averaged_theme_ttest 

pdf(file.path(figures_path,'Figure_VS_DorsoLateral_HED.pdf'))
print(ppp)
dev.off()


########################################### DIRECT COMPARAISON DURING PIT IN VS ################################################


# ----------------------------------------------PIT TASK -----------------------------------------------

CM.HED.ROI.PIT = HED.ROI.TASK.PIT
CM.HED.ROI.PIT = CM.HED.ROI.PIT %>% select(-one_of('mOFC'))
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
F_to_eta2(f = c(6.58), df = c(1), df_error = c(22)) # effect sizes (90%CI)


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
CM.PIT.ROI.PIT$ROI_type = 'PIT_ROI'

HED.ROI.COMPARE <- join (CM.HED.ROI.PIT, CM.PIT.ROI.PIT, type = 'full')

HED.ROI.COMPARE.means <- aggregate(HED.ROI.COMPARE$beta, 
                                   by = list(HED.ROI.COMPARE$ID,HED.ROI.COMPARE$ROI_type), FUN='mean') # extract means
colnames(HED.ROI.COMPARE.means) <- c('ID','ROI_type','beta')

HED.ROI.COMPARE.means$ROI_type = factor(HED.ROI.COMPARE.means$ROI_type)

# test
directHEDroi.stat     <- aov_car(beta ~ ROI_type  + Error (ID/ROI_type), data = HED.ROI.COMPARE, 
                                 factorize = F, anova_table = list(es = "pes"))
F_to_eta2(f = c(4.79), df = c(1), df_error = c(23)) # effect sizes (90%CI)


intROIHED.BF <- anovaBF(beta ~ ROI_type + ID, data = HED.ROI.COMPARE.means, 
                              whichRandom = "ID", iterations = 50000)
intROIHED.BF


########################################### Pavlovian-triggered motivation and sensory pleasure within the core-like and shell-like divisions ################################################


# ------------------------------------- CORE during PIT -----------------------------------------

# Compile database
PIT.ROI <- merge(PIT.index, PIT.TASK, by = 'ID')


# -------------------------------- STAT
aov_car(core ~ deltaCS_R  + Error (ID ), data = PIT.ROI,
        observed = c("deltaCS_R"), factorize = F, anova_table = list(es = "none"))

F_to_eta2(f = c(10.63), df = c(1), df_error = c(22)) # effect sizes (90%CI)

BF <- lmBF(core ~ deltaCS_R + ID, data = PIT.ROI, 
           whichRandom = "ID", iterations = 50000) ; BF

# -------------------------------- PLOT
pp <- ggplot(PIT.ROI, aes(y = core, x = deltaCS_R)) +
  geom_point(color = pal[2]) +
  geom_smooth(method='lm', color = pal[2], fill = pal[2], alpha = 0.2,fullrange=TRUE) +
  labs(y = 'Core Beta estimate (a.u.)', x ='Cue-triggered effort (rank)') + #Beta estimates (a.u) # Cue-triggered effort
  scale_fill_manual(values=pal[2], guide = 'none') +
  theme_bw()

ppp <- pp + averaged_theme_regression

pppp  <- ggMarginal(ppp + theme(legend.position = c(1, 1), legend.justification = c(1, 1),
                                  legend.background = element_rect(color = "white")), 
                      type = "density", alpha = .1, color = NA, fill = pal[2], margin = 'y') 
pdf(file.path(figures_path,'Figure_CORE_PIT.pdf'))
print(pppp)
dev.off()

# ------------------------------------- CORE during HED -----------------------------------------

# -------------------------------- STAT
t.test(HED.TASK$core)
# BF
ttestBF(HED.TASK$core)
# effect size
cohen_d_ci(HED.TASK$core, conf.level = .95)


# ------------------------------------- SHELL during HED -----------------------------------------

# -------------------------------- STAT
#ttest
t.test(HED.TASK$shell)
# BF
ttestBF(HED.TASK$shell)
# effect size
cohen_d_ci(HED.TASK$shell, conf.level = .95)

# -------------------------------- PLOT
dfG = summarySE(data = HED.TASK, measurevar = "shell"); dfG
pp <- ggplot(HED.TASK, aes(x = 0.5, y = shell)) +
  geom_abline(slope=0, intercept=0, linetype = "dashed", color = "gray") +
  geom_flat_violin(scale = "count", trim = FALSE, alpha = .2, color = NA, fill = pal[3], width = 0.5) +
  geom_jitter(alpha = .6, color = pal[3], width = 0.02) +
  geom_crossbar(data = dfG, aes(ymin= shell-se, ymax= shell+se), 
                width = 0.2 , alpha = 0.1, color = pal[3])+
  ylab('Beta estimates (a.u.)') + #
  xlab('') + 
  scale_y_continuous(expand = c(-0, 0), breaks = c(seq.int(-0.04,0.04, by = 0.02)), limits = c(-0.045,0.045))  +
  scale_x_continuous(expand = c(0, 0), breaks = c(seq.int(0.1,0.8, by = 0.25)), limits = c(0.2,0.8))  +
  theme_bw()

ppp <- pp + averaged_theme_ttest 

ppp
pdf(file.path(figures_path,'Figure_shell_HED.pdf'))
print(ppp)
dev.off()


# ------------------------------------- SHELL during PIT -----------------------------------------

# -------------------------------- STAT
shell_eff.stat     <- aov_car(shell ~ deltaCS_R + Error (ID), data = PIT.ROI,
                              observed = c("deltaCS_R"), factorize = F, anova_table = list(es = "none")) # no

F_to_eta2(f = c(2.04), df = c(1), df_error = c(22)) # effect sizes (90%CI)


BF <- lmBF(shell ~ deltaCS_R + ID, data = PIT.ROI, 
           whichRandom = "ID", iterations = 50000); BF




########################################### HED - PIT behavioral LINK  ################################################


# Behavioral correlation cue triggered effort and Us liking
scatterplot(PIT.index$deltaCS_R, HED.index$US_lik)
cor.test(PIT.index$deltaCS, HED.index$US_lik, method = 'kendall')
cor.test(PIT.index$deltaCS_R, HED.index$US_lik, method = 'pearson')

########################################### TASK VALIDATION MODELS ################################################



ROI.val     <- read.delim(file.path(analysis_path, 'databases/Betas_ROI_VALIDATION.txt'), header = T, sep =',')

# ------------------------------------- HED ---------------------------------------------------------

t.test(ROI.val$HED_piriform_right); se(ROI.val$HED_piriform_right)
# BF
ttestBF(ROI.val$HED_piriform_right)
# effect size
cohen_d_ci(ROI.val$HED_piriform_right, conf.level = .95)

t.test(ROI.val$HED_piriform_left); se(ROI.val$HED_piriform_left)
# BF
ttestBF(ROI.val$HED_piriform_left)
# effect size
cohen_d_ci(ROI.val$HED_piriform_left, conf.level = .95)


# ------------------------------------- PIT --------------------------------------------------------
t.test(ROI.val$PIT_thalamus); se(ROI.val$PIT_thalamus)
# BF
ttestBF(ROI.val$PIT_thalamus)
# effect size
cohen_d_ci(ROI.val$PIT_thalamus, conf.level = .95)

t.test(ROI.val$PIT_cerebellum); se(ROI.val$PIT_cerebellum)
# BF
ttestBF(ROI.val$PIT_cerebellum)
# effect size
cohen_d_ci(ROI.val$HED_piriform_left, conf.level = .95)




########################################### PIT PLOT BMS ################################################


PIT_BMS <- read.csv(file.path(analysis_path, 'databases/PIT_BMS.csv'))
PIT_BMS$GLM = as.factor(PIT_BMS$GLM) 

pp = ggplot(PIT_BMS, aes(x = GLM, y = mean, fill = I(pal[2]), color = I(pal[2]))) +
  geom_bar( stat = "identity", alpha = .3, width=0.5) +
  geom_errorbar(aes(ymax = mean + sd, ymin = mean - sd), width=0.05,  alpha=1) +
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,1, by = 0.2)), limits = c(0,1)) +
  scale_x_discrete(labels=c("Between", "Between +\n Control", "Within", "Within +\n Control")) +
  labs(y =  "Exceedance Probability", x = "PIT Model")   +
  theme_bw()
ppp <- pp + averaged_theme_regression +     theme(axis.text.x = element_text(size = 18))
ppp

pdf(file.path(figures_path,'Figure_BMS_PIT.pdf'))
print(ppp)
dev.off()


########################################### HED PLOT BMS ################################################



HED_BMS <- read.csv(file.path(analysis_path, 'databases/hedonic_BMS.csv'))
HED_BMS$GLM = as.factor(HED_BMS$GLM) 

pp = ggplot(HED_BMS, aes(x = GLM, y = mean, fill = I(pal[3]), color = I(pal[3]))) +
  geom_bar( stat = "identity", alpha = .3, width=0.5) +
  geom_errorbar(aes(ymax = mean + sd, ymin = mean - sd), width=0.05,  alpha=1) +
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,1, by = 0.2)), limits = c(0,1)) +
  scale_x_discrete(labels=c("Between", "Between +\n Control", "Within", "Within +\n Control")) +
  labs(y =  "Exceedance Probability", x = "Hedonic Model")   +
  theme_bw()
ppp <- pp + averaged_theme_regression +     theme(axis.text.x = element_text(size = 18))
ppp

pdf(file.path(figures_path,'Figure_BMS_HED.pdf'))
print(ppp)
dev.off()


