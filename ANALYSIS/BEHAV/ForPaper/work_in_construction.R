                                                                                                 #
#                                                                                                  #                                                 #                                                                                                  #
#     Differential contributions of ventral striatum subregions in the motivational                #
#           and hedonic components of the affective response to reward                             #
#                                                                                                  #
#                                                                                                  #
#                   Eva R Pool                                                                     #
#                   David Munoz Tord                                                               #
#                   Sylvain Delplanque                                                             #
#                   Yoann Stussi                                                                   #
#                   Patrik Vuilleumier                                                             #
#                   David Sander                                                                   #
#                                                                                                  #
# Created by D.M.T. on NOVEMBER 2018                                                               #
# modified by E.R.P on  JANUARY  2021 (short version) (February 2021 D.M.T.)                                             #


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

# get tool
devtools::source_gist("2a1bb0133ff568cbe28d", 
                      filename = "geom_flat_violin.R")

devtools::source_gist("383aa93ffa161665c0dca1103ef73d9d", 
                      filename = "effect_CI.R")


#SETUP

# Set path
#home_path       <- '/Users/evapool/mountpoint/REWOD'
home_path       <- '~/REWOD'

# Set working directory
analysis_path <- file.path(home_path, 'CODE/ANALYSIS/BEHAV/ForPaper')
covariatePIT_path <- file.path(home_path, '/DERIVATIVES/GLM/ForPaper/PIT/GLM-between/group_covariates')
covariateHED_path <- file.path(home_path, '/DERIVATIVES/GLM/ForPaper/hedonic/GLM-between/group_covariates')
figures_path <- file.path(analysis_path, 'figures')
setwd(analysis_path)


#datasets directory
data_path <- file.path(home_path,'DERIVATIVES/BEHAV') 


PIT  <- read.delim(file.path(data_path,'PIT/REWOD_PIT_ses_second.txt'), header = T, sep ='') # read in dataset


HED.TASK     <- read.csv(file.path(analysis_path, 'databases/Betas_TASK_HED.csv')) 


PIT.TASK   <- read.csv(file.path(analysis_path, 'databases/Betas_TASK_PIT.csv'),) 



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






#-------------------------------------  PREPROC   -----------------------------------------------------

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




# ------------------------------------- PIT during PIT -----------------------------------------

# Compile database
PIT.ROI <- merge(PIT.index, PIT.TASK, by = 'ID')

#rank or not rank ?
cor.test(PIT.ROI$deltaCS, PIT.ROI$core, method = 'pearson')
cor.test(PIT.ROI$deltaCS_R, PIT.ROI$core, method = 'pearson')

# long format for left and right
#PIT.ROI.TASK.PIT.long <- gather(PIT.ROI.TASK.PIT, ROI , beta, core_L:core_R, factor_key=TRUE)

#PIT.ROI.TASK.PIT.long$ROI_type = 'Pav_ROI'

# -------------------------------- STAT
# core
core_eff.stat     <- aov_car(core ~ deltaCS_R + Error (ID), data = PIT.ROI,
                              observed = c("deltaCS_R"), factorize = F, anova_table = list(es = "none"))

pes_ci(core ~ deltaCS_R  + Error (ID), data = PIT.ROI,
                              observed = c("deltaCS_R"), factorize = F)


BF <- lmBF(core ~ deltaCS_R + ID, data = PIT.ROI, 
                     whichRandom = "ID", iterations = 50000) ; BF


#emmeans(VS_CA_eff.stat,  ~ ROI:deltaCS_R)

# -------------------------------- PLOT
#PIT.ROI.TASK.PIT.means <- aggregate(PIT.ROI.TASK.PIT.long$beta, by = list(PIT.ROI.TASK.PIT.long$ID, PIT.ROI.TASK.PIT.long$deltaCS_R), FUN='mean') # extract means
#colnames(PIT.ROI.TASK.PIT.means) <- c('ID','beta', 'effort')

pp <- ggplot(PIT.ROI, aes(y = core, x = deltaCS_R)) +
  geom_point(color = pal[2]) +
  geom_smooth(method='lm', color = pal[2], fill = pal[2], alpha = 0.2,fullrange=TRUE) +
  labs(y = 'Beta estimates (a.u)', x ='Cue-triggered effort (rank)') +
  scale_fill_manual(values=pal[2], guide = 'none') +
  theme_bw()

ppp <- pp + averaged_theme_regression

# pdf(file.path(figures_path,'Figure_CORE_PIT_nomarg.pdf'))
# print(ppp)
# dev.off()

figure1 <- ggMarginal(ppp + theme(legend.position = c(1, 1), legend.justification = c(1, 1),
                               legend.background = element_rect(color = "white")), 
                   type = "density", alpha = .1, color = NA, fill = pal[2]) 
figure1
# pdf(file.path(figures_path,'Figure_CORE_PIT.pdf'))
# print(pppp)
# dev.off()




# ------------------------------------- HED during PIT -----------------------------------------
#HED.ROI <- merge(PIT.index, ROI_HED.CSpCSm, by = 'ID')

# rename variables for this database
#HED.ROI.TASK.PIT <- rename.variable(HED.ROI.TASK.PIT, 'HED_NACcoreshell_betas', 'NAc_shell_core')
#HED.ROI.TASK.PIT <- rename.variable(HED.ROI.TASK.PIT, 'HED_mOFC_betas', 'mOFC')
#HED.ROI.TASK.PIT$ROI_type = 'hed_ROI'


#mOFC
mOFC_eff.stat             <- aov_car(mOFC ~ deltaCS_R + Error (ID), data = PIT.ROI,
                                     observed = c("deltaCS_R"), factorize = F, anova_table = list(es = "pes")) # no

pes_ci(core ~ deltaCS_R  + Error (ID), data = PIT.ROI,
       observed = c("deltaCS_R"), factorize = F)

BF <- lmBF(mOFC ~ deltaCS_R + ID, data = PIT.ROI, 
                     whichRandom = "ID", iterations = 50000); BF


#shell
shell_eff.stat     <- aov_car(shell ~ deltaCS_R + Error (ID), data = PIT.ROI,
                                     observed = c("deltaCS_R"), factorize = F, anova_table = list(es = "pes")) # no

pes_ci(shell ~ deltaCS_R  + Error (ID), data = PIT.ROI,
       observed = c("deltaCS_R"), factorize = F)

BF <- lmBF(shell ~ deltaCS_R + ID, data = PIT.ROI, 
                     whichRandom = "ID", iterations = 50000); BF


# -------------------------------- PLOT

# pannel 1
pp <- ggplot(PIT.ROI, aes(y = mOFC, x = deltaCS_R)) +
  geom_point(color = pal[2]) +
  geom_smooth(method='lm', color = pal[2], fill = pal[2], alpha = 0.2,fullrange=TRUE) +
  labs(y = 'Beta estimates (a.u)', x ='Cue-triggered effort (rank)') +
  scale_fill_manual(values=pal[2], guide = 'none') +
  theme_bw()

ppp <- pp + averaged_theme_regression 

figure2 <- ggMarginal(ppp + theme(legend.position = c(1, 1), legend.justification = c(1, 1),
                               legend.background = element_rect(color = "white")), 
                   type = "density", alpha = .1, color = NA, fill = pal[2]) 
figure2
# pdf(file.path(figures_path,'Figure_mOFC_PIT.pdf'))
# print(pppp)
# dev.off()

# pannel 2
pp <- ggplot(PIT.ROI, aes(y = shell, x = deltaCS_R)) +
  geom_point(color = pal[2]) +
  geom_smooth(method='lm', color = pal[2], fill = pal[2], alpha = 0.2,fullrange=TRUE) +
  labs(y = 'Beta estimates (a.u)', x ='Cue-triggered effort (rank)') +
  scale_fill_manual(values=pal[2], guide = 'none') +
  theme_bw()

ppp <- pp + averaged_theme_regression 

figure3 <- ggMarginal(ppp + theme(legend.position = c(1, 1), legend.justification = c(1, 1),
                               legend.background = element_rect(color = "white")), 
                   type = "density", alpha = .1, color = NA, fill = pal[2]) 
figure3
# pdf(file.path(figures_path,'Figure_SHELL_PIT.pdf'))
# print(pppp)
# dev.off()









# ------------------------------------- HED during HED -----------------------------------------


#NEED TO CHANGE OFC!!

# Compile database
#HED.ROI.HED.TASK <- HED.TASK

# long format for left and right
#HED.ROI.HED.TASK.long <- gather(HED.ROI.HED.TASK, ROI , beta, shell_L:shell_R, factor_key=TRUE)

#HED.ROI.HED.TASK.long$ROI_type = 'HED_ROI'

# -------------------------------- STAT
#HED.stat     <- aov_car(beta ~  ROI + Error (ID/ROI), data = HED.ROI.HED.TASK.long, anova_table = list(es = "none"))

#pes_ci(beta ~ deltaCS_R + ROI + Error (ID/ROI), data = PIT.ROI.TASK.PIT.long,
       #observed = c("deltaCS_R"), factorize = F)

# rename variables for this database
#HED.ROI.HED.TASK <- rename.variable(HED.ROI.HED.TASK, 'HED_NACcoreshell_betas', 'NAc_shell_core')
#HED.ROI.HED.TASK <- rename.variable(HED.ROI.HED.TASK, 'HED_mOFC_betas', 'mOFC')

#------------------------------- STAT
t.test(HED.TASK$shell); #se(HED.TASK$shell)
# BF
ttestBF(HED.TASK$shell)
# effect size
cohen_d_ci(HED.TASK$shell, conf.level = .95)

t.test(HED.TASK$mOFC); #se(HED.TASK$mOFC)
# BF
ttestBF(HED.TASK$mOFC)
# effect size
cohen_d_ci(HED.TASK$mOFC, conf.level = .95)

# -------------------------------- PLOT

# SET SAME Y scale

# pannel 1
dfG = summarySE(data = HED.TASK, measurevar = "mOFC")

pp <- ggplot(HED.TASK, aes(x = 0.5, y = mOFC)) +
  geom_abline(slope=0, intercept=0, linetype = "dashed", color = "gray") +
  geom_flat_violin(scale = "count", trim = FALSE, alpha = .2, color = NA, fill = pal[3], width = 0.5) +
  geom_jitter(alpha = .6, color = pal[3], width = 0.02) +
  geom_crossbar(data = dfG, aes(ymin= mOFC-se, ymax= mOFC+se), 
                width = 0.2 , alpha = 0.1, color = pal[3])+
  ylab('Beta estimates (a.u.)') +
  xlab('') + 
  scale_y_continuous(expand = c(-0, 0), breaks = c(seq.int(-0.035,0.06, by = 0.015)), limits = c(-0.035,0.06))  +
  scale_x_continuous(expand = c(0, 0), breaks = c(seq.int(0.2,0.8, by = 0.25)), limits = c(0.2,0.8))  +
  theme_bw()

ppp <- pp + averaged_theme_ttest 

ppp
# pdf(file.path(figures_path,'Figure_mOFC_HED.pdf'))
# print(ppp)
# dev.off()


# pannel 2
dfG = summarySE(data = HED.TASK, measurevar = "shell")


pp <- ggplot(HED.TASK, aes(x = 0.5, y = shell)) +
  geom_abline(slope=0, intercept=0, linetype = "dashed", color = "gray") +
  geom_flat_violin(scale = "count", trim = FALSE, alpha = .2, color = NA, fill = pal[3], width = 0.5) +
  geom_jitter(alpha = .6, color = pal[3], width = 0.02) +
  geom_crossbar(data = dfG, aes(y =  shell, ymin= shell-se, ymax= shell+se), 
                width = 0.2 , alpha = 0.1, color = pal[3])+
  ylab('Beta estimates (a.u.)') +
  xlab('') +
  scale_y_continuous(expand = c(-0, 0), breaks = c(seq.int(-0.035,0.06, by = 0.015)), limits = c(-0.035,0.06))  +
  scale_x_continuous(expand = c(0, 0), breaks = c(seq.int(0.2,0.8, by = 0.25)), limits = c(0.2,0.8))  +
  theme_bw()

ppp <- pp + averaged_theme_ttest 

ppp
# pdf(file.path(figures_path,'Figure_shell_HED.pdf'))
# print(ppp)
# dev.off()


# ------------------------------------- PIT during HED -----------------------------------------

# PIT.ROI.HED.TASK <- merge(PIT.index, ROI_PIT.lik, by = 'ID')
# 
# # rename variables for this database
# PIT.ROI.HED.TASK <- rename.variable(PIT.ROI.HED.TASK, 'PIT_EFF_VSCA_right_betas', 'NAc_CA_right')
# PIT.ROI.HED.TASK <- rename.variable(PIT.ROI.HED.TASK, 'PIT_Eff_VSCA_left_betas', 'NAc_CA_left')
# 
# # remove ROI from CS+ vs CS- independent from effort
# PIT.ROI.HED.TASK %>% select(-one_of('PIT_CS_NACschell_right_betas','PIT_CS_NACshell_left_betas'))
# 
# 
# # long format for left and right
# PIT.ROI.HED.TASK.long <- gather(PIT.ROI.HED.TASK, ROI , beta, NAc_CA_right:NAc_CA_left, factor_key=TRUE)


# -------------------------------- STAT
# VS_CA_lik.stat     <- aov_car(shell ~ ROI + Error (ID/ROI), data = PIT.ROI.HED.TASK.long, factorize = F, anova_table = list(es = "pes")) 
# 
# # since there is no ROI effect let's compute the main effect on the average
# PIT.ROI.HED.TASK.means <- aggregate(PIT.ROI.HED.TASK.long$beta, by = list(PIT.ROI.HED.TASK.long$ID), FUN='mean') # extract means
# colnames(PIT.ROI.HED.TASK.means) <- c('ID','betas')
t.test(HED.TASK$core)
# BF
ttestBF(HED.TASK$core)
# effect size
cohen_d_ci(HED.TASK$core, conf.level = .95)

# ----------------------------- PLOT
dfG = summarySE(data = HED.TASK, measurevar = "core")


pp <- ggplot(HED.TASK, aes(x = 0.5, y = core)) +
  geom_abline(slope=0, intercept=0, linetype = "dashed", color = "gray") +
  geom_flat_violin(scale = "count", trim = FALSE, alpha = .2, color = NA, fill = pal[3], width = 0.5) +
  geom_jitter(alpha = .6, color = pal[3], width = 0.02) +
  geom_crossbar(data = dfG, aes(ymin= core-sd, ymax= core+sd), 
                width = 0.2 , alpha = 0.1, color = pal[3])+
  ylab('Beta estimates (a.u.)') +
  xlab('') + 
  #scale_y_continuous(expand = c(-0, 0), breaks = c(seq.int(-0.035,0.06, by = 0.015)), limits = c(-0.035,0.06))  +
  scale_x_continuous(expand = c(0, 0), breaks = c(seq.int(0.2,0.8, by = 0.25)), limits = c(0.2,0.8))  +
  theme_bw()

ppp <- pp + averaged_theme_ttest 

ppp
# pdf(file.path(figures_path,'Figure_core_HED.pdf'))
# print(ppp)
# dev.off()












# -----------------------------------   DIRECT COMPARAISON DURING PIT IN VS 
# ----------------------------------------------PIT TASK -----------------------------------------------


HED.TASK$task = "HED"; PIT.ROI$task = "PIT"

COMPARE <- join (HED.TASK, PIT.ROI, type = 'full')


#CM.HED.ROI.PIT = HED.TASK
#CM.HED.ROI.PIT = CM.HED.ROI.PIT %>% select(-one_of('mOFC','HED_NACshell_betas'))
#CM.HED.ROI.PIT <- rename.variable(CM.HED.ROI.PIT, 'NAc_shell_core', 'beta')

# select only the variable of interest
#CM.HED.ROI.PIT = select(CM.HED.ROI.PIT, 'ID','deltaCS_R','ROI_type','beta')
#CM.PIT.ROI.PIT = select(PIT.ROI.TASK.PIT.long, 'ID','deltaCS_R','ROI_type','beta')

#PIT.ROI.COMPARE.means <- aggregate(PIT.ROI.COMPARE$beta, 
                                   #by = list(PIT.ROI.COMPARE$ID,PIT.ROI.COMPARE$ROI_type, PIT.ROI#.COMPARE$deltaCS_R), FUN='mean') # extract means
#colnames(PIT.ROI.COMPARE.means) <- c('ID','ROI_type','deltaCS_R','beta')

# PIT.ROI.COMPARE.means$ROI_type = factor(PIT.ROI.COMPARE.means$ROI_type)
# 
# # test
# directPITroi.stat     <- aov_car(beta ~ deltaCS_R*ROI_type  + Error (ID/ROI_type ), data = PIT.ROI.COMPARE,
#                                  observed = c("deltaCS_R"), factorize = F, anova_table = list(es = "pes"))
# F_to_eta2(f = c(6.58), df = c(1), df_error = c(22)) # effect sizes (90%CI)
# 
# 
# intROIPIT.BF <- generalTestBF(beta ~ ROI_type*deltaCS_R + ID, data = PIT.ROI.COMPARE.means, 
#                               whichRandom = "ID", iterations = 50000)
# intROIPIT.BF <- recompute(intROIPIT.BF , iterations = 50000)
# intROIPIT.BF[9]/intROIPIT.BF[8] 






# ----------------------------------------------HED TASK -----------------------------------------------

# CM.HED.ROI.HED = HED.ROI.HED.TASK
# CM.HED.ROI.HED = CM.HED.ROI.HED %>% select(-one_of('mOFC','HED_NACshell_betas'))
# CM.HED.ROI.HED <- rename.variable(CM.HED.ROI.HED, 'NAc_shell_core', 'beta')
# CM.HED.ROI.HED$ROI_type = 'hed_ROI'
# 
# # select only the variable of interest
# CM.PIT.ROI.PIT = select(PIT.ROI.HED.TASK.long, 'ID','deltaCS_R','beta')
# CM.PIT.ROI.PIT$ROI_type = 'pav_ROI'
# 
# HED.ROI.COMPARE <- join (CM.HED.ROI.PIT, CM.PIT.ROI.PIT, type = 'full')
# 
# HED.ROI.COMPARE.means <- aggregate(HED.ROI.COMPARE$beta, 
#                                    by = list(HED.ROI.COMPARE$ID,HED.ROI.COMPARE$ROI_type), FUN='mean') # extract means
# colnames(HED.ROI.COMPARE.means) <- c('ID','ROI_type','beta')
# 
# HED.ROI.COMPARE.means$ROI_type = factor(HED.ROI.COMPARE.means$ROI_type)
# 
# # test
# directHEDroi.stat     <- aov_car(beta ~ ROI_type  + Error (ID/ROI_type), data = HED.ROI.COMPARE, 
#                                  factorize = F, anova_table = list(es = "pes"))
# F_to_eta2(f = c(4.79), df = c(1), df_error = c(23)) # effect sizes (90%CI)
# 
# 
# intROIHED.BF <- anovaBF(beta ~ ROI_type + ID, data = HED.ROI.COMPARE.means, 
#                         whichRandom = "ID", iterations = 50000)
# intROIHED.BF <- recompute(intROIHED.BF, iterations = 50000)
# intROIHED.BF




# -------------------------------------   HED - PIT behavioral LINK --------------------------

# Behavioral correlation cue triggered effort and Us liking
# scatterplot(PIT.index$deltaCS_R, HED.index$US_lik)
# cor.test(PIT.index$deltaCS, HED.index$US_lik, method = 'kendall')
# cor.test(PIT.index$deltaCS_R, HED.index$US_lik, method = 'pearson')



