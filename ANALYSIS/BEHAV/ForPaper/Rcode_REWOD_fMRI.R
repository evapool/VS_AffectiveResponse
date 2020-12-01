####################################################################################################
#                                                                                                  #
#                                                                                                  #                                                 #                                                                                                  #
#                                    TITLE OF THE PAPER                                            #
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
# modified by E.R.P on  NOVEMBER  2020                                                             #
####################################################################################################


#--------------------------------------  PRELIMINARY STUFF ----------------------------------------
#load libraries
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}

pacman::p_load(apaTables, MBESS, afex, car, ggplot2, dplyr, plyr, tidyr, 
               reshape, Hmisc, Rmisc,  ggpubr, ez, gridExtra, plotrix, 
               lsmeans, BayesFactor, effectsize, devtools,misty,questionr,ggplot, ggExtra)

ﬁif(!require(devtools)) {
  install.packages("devtools")
  library(devtools)
}

# get tool
devtools::source_gist("2a1bb0133ff568cbe28d", 
                      filename = "geom_flat_violin.R")



#SETUP

# Set path
home_path       <- '/Users/evapool/mountpoint2'
#home_path       <- '~/REWOD'

# Set working directory
analysis_path <- file.path(home_path, 'CODE/ANALYSIS/BEHAV/ForPaper')
figures_path <- file.path(analysis_path, 'figures')
setwd(analysis_path)

#datasets dictory
data_path <- file.path(home_path,'DERIVATIVES/BEHAV') 

# open datasets
PAV  <- read.delim(file.path(data_path,'PAV/REWOD_PAVCOND_ses_first.txt'), header = T, sep ='') # read in dataset
INST <- read.delim(file.path(data_path,'INSTRU/REWOD_INSTRU_ses_first.txt'), header = T, sep ='') # read in dataset
PIT  <- read.delim(file.path(data_path,'PIT/REWOD_PIT_ses_second.txt'), header = T, sep ='') # read in dataset
HED  <- read.delim(file.path(data_path,'HED/REWOD_HEDONIC_ses_second.txt'), header = T, sep ='') # read in dataset


ROI_HED.lik     <- read.delim(file.path(analysis_path, 'databases/Betas_ROI_Hed_TASK_Hed.txt'), header = T, sep ='') 

ROI_HED.CSpCSm  <- read.delim(file.path(analysis_path, 'databases/Betas_ROI_Hed_task_PIT.txt'), header = T, sep ='') 
ROI_PIT.lik     <- read.delim(file.path(analysis_path, 'databases/Betas_ROI_PIT_TASK_hedonic.txt'), header = T, sep ='') 
ROI_PIT.CSpCSm  <- read.delim(file.path(analysis_path, 'databases/Betas_ROI_PIT_TASK_PIT.txt'), header = T, sep ='') 


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





# -------------------------------------------------------------------------------------------------
#                                              PIT 
# -------------------------------------------------------------------------------------------------

# ------------------------------------- PIT ROI during PIT -----------------------------------------

# Compile database
PIT.ROI.TASK.PIT <- merge(PIT.index, ROI_PIT.CSpCSm, by = 'ID')
# rename variables for this database
PIT.ROI.TASK.PIT <- rename.variable(PIT.ROI.TASK.PIT, 'PIT_EFF_VSCA_right_betas', 'NAc_CA_right')
PIT.ROI.TASK.PIT <- rename.variable(PIT.ROI.TASK.PIT, 'PIT_Eff_VSCA_left_betas', 'NAc_CA_left')

# remove ROI from CS+ vs CS- independent from effort
PIT.ROI.TASK.PIT %>% select(-one_of('PIT_CS_NACschell_right_betas','PIT_CS_NACshell_left_betas'))

# long format for left and right
PIT.ROI.TASK.PIT.long <- gather(PIT.ROI.TASK.PIT, ROI , beta, NAc_CA_right:NAc_CA_left, factor_key=TRUE)


# -------------------------------- STAT
VS_CA_eff.stat     <- aov_car(beta ~ deltaCS_R + ROI + Error (ID/ROI), data = PIT.ROI.TASK.PIT.long,
                              observed = c("deltaCS_R"), factorize = F, anova_table = list(es = "pes"))
F_to_eta2(f = c(41.89), df = c(1), df_error = c(22)) # effect sizes (90%CI)



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
                   type = "density", alpha = .1, color = NA, fill = pal[2]) 

pdf(file.path(figures_path,'Figure_NAc_CA_PIT.pdf'))
print(ppp)
dev.off()

# ------------------------------------- CS+/CS- ROI during PIT  (SUPPLEMENTARY)  ---------------------------
# Compile database
CS.ROI.TASK.PIT <- merge(PIT.index, ROI_PIT.CSpCSm, by = 'ID')
CS.ROI.TASK.PIT <- merge(PAV.index, CS.ROI.TASK.PIT, by = 'ID')
CS.ROI.TASK.PIT <- merge(HED.index, CS.ROI.TASK.PIT, by = 'ID')
# rename variables for this database
CS.ROI.TASK.PIT <- rename.variable(CS.ROI.TASK.PIT, 'PIT_CS_NACschell_right_betas', 'NAcShell_right')
CS.ROI.TASK.PIT <- rename.variable(CS.ROI.TASK.PIT, 'PIT_CS_NACshell_left_betas', 'NAcShell_left')

# remove ROI related to effort
CS.ROI.TASK.PIT %>% select(-one_of('PIT_EFF_VSCA_right_betas','PIT_Eff_VSCA_left_betas'))

# long format for left and right
CS.ROI.TASK.PIT.long <- gather(CS.ROI.TASK.PIT, ROI, beta, NAcShell_right:NAcShell_left, factor_key=TRUE)


# -------------------------------- STAT
# EFF (is the CS activation stronger when more effort is mobilized)
NAcShell_eff.stat     <- aov_car(beta ~ deltaCS_R + ROI + Error (ID/ROI), data = CS.ROI.TASK.PIT.long,
                                 observed = c("deltaCS_R"), factorize = F, anova_table = list(es = "pes"))
F_to_eta2(f = c(6.97), df = c(1), df_error = c(22)) # effect sizes (90%CI)

#US liking (is the CS activation stronger when the us is more liked)
NAcShell_USlik.stat     <- aov_car(beta ~ US_lik + ROI + Error (ID/ROI), data = CS.ROI.TASK.PIT.long,
                                   observed = c("US_lik"), factorize = F, anova_table = list(es = "pes")) # nop

# ------------------------------- EXTRA STAT TO REMOVE (THIS WILL JUST OPEN MORE QUESTIONS AND TESTS THAN IT CAN ANSWER)
#RT pavlovian day 1 (to remove)
NAcShell_rt.stat     <- aov_car(beta ~ deltaCS_RT + ROI + Error (ID/ROI), data = CS.ROI.TASK.PIT.long,
                                observed = c("deltaCS_RT"), factorize = F, anova_table = list(es = "pes")) # not convicing
#RT pavlovian day 1(to remove)
NAcShell_lik.stat     <- aov_car(beta ~ deltaCS_lik + ROI + Error (ID/ROI), data = CS.ROI.TASK.PIT.long,
                                 observed = c("deltaCS_lik"), factorize = F, anova_table = list(es = "pes")) # nop

# -------------------------------- PLOT
CS.ROI.TASK.PIT.means <- aggregate(CS.ROI.TASK.PIT.long$beta, by = list(CS.ROI.TASK.PIT.long$ID, CS.ROI.TASK.PIT.long$deltaCS_R), FUN='mean') # extract means
colnames(CS.ROI.TASK.PIT.means) <- c('ID','beta', 'effort')

pp <- ggplot(CS.ROI.TASK.PIT.means, aes(y = effort, x = beta)) +
  geom_point(color = pal[2]) +
  geom_smooth(method='lm', color = pal[2], fill = pal[2], alpha = 0.2,fullrange=TRUE) +
  labs(y = 'Beta estimates (a.u)', x ='Cue-triggered effort (rank)') +
  scale_fill_manual(values=pal[2], guide = 'none') +
  theme_bw()

ppp <- pp + averaged_theme_regression

pppp <- ggMarginal(ppp + theme(legend.position = c(1, 1), legend.justification = c(1, 1),
                               legend.background = element_rect(color = "white")), 
                   type = "density", alpha = .1, color = NA, fill = pal[2]) 

pdf(file.path(figures_path,'Figure_NAc_CS_PIT.pdf'))
print(ppp)
dev.off()



# ------------------------------------- HED ROI during PIT -----------------------------------------
HED.ROI.TASK.PIT <- merge(PIT.index, ROI_HED.CSpCSm, by = 'ID')

# rename variables for this database
HED.ROI.TASK.PIT <- rename.variable(HED.ROI.TASK.PIT, 'HED_NACcoreshell_betas', 'NAc_shell_core')
HED.ROI.TASK.PIT <- rename.variable(HED.ROI.TASK.PIT, 'HED_NACshell_betas', 'NAc_shell')
HED.ROI.TASK.PIT <- rename.variable(HED.ROI.TASK.PIT, 'HED_mOFC_betas', 'mOFC')

mOFC_eff.stat             <- aov_car(mOFC ~ deltaCS_R + Error (ID), data = HED.ROI.TASK.PIT,
                                     observed = c("deltaCS_R"), factorize = F, anova_table = list(es = "pes")) # no

NAcShell_eff.stat         <- aov_car(NAc_shell ~ deltaCS_R + Error (ID), data = HED.ROI.TASK.PIT,
                                     observed = c("deltaCS_R"), factorize = F, anova_table = list(es = "pes")) # yes (survive correction for ROI)

NAcShellCore_eff.stat     <- aov_car(NAc_shell_core ~ deltaCS_R + Error (ID), data = HED.ROI.TASK.PIT,
                                     observed = c("deltaCS_R"), factorize = F, anova_table = list(es = "pes")) # no



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
                   type = "density", alpha = .1, color = NA, fill = pal[2]) 

pdf(file.path(figures_path,'Figure_mOFC_PIT.pdf'))
print(ppp)
dev.off()

# pannel 2
pp <- ggplot(HED.ROI.TASK.PIT, aes(y = NAc_shell, x = deltaCS_R)) +
  geom_point(color = pal[2]) +
  geom_smooth(method='lm', color = pal[2], fill = pal[2], alpha = 0.2,fullrange=TRUE) +
  labs(y = 'Beta estimates (a.u)', x ='Cue-triggered effort (rank)') +
  scale_fill_manual(values=pal[2], guide = 'none') +
  theme_bw()

ppp <- pp + averaged_theme_regression 

pppp <- ggMarginal(ppp + theme(legend.position = c(1, 1), legend.justification = c(1, 1),
                               legend.background = element_rect(color = "white")), 
                   type = "density", alpha = .1, color = NA, fill = pal[2]) 

pdf(file.path(figures_path,'Figure_NAc_shell_PIT.pdf'))
print(ppp)
dev.off()

# pannel 3
pp <- ggplot(HED.ROI.TASK.PIT, aes(y = NAc_shell_core, x = deltaCS_R)) +
  geom_point(color = pal[2]) +
  geom_smooth(method='lm', color = pal[2], fill = pal[2], alpha = 0.2,fullrange=TRUE) +
  labs(y = 'Beta estimates (a.u)', x ='Cue-triggered effort (rank)') +
  scale_fill_manual(values=pal[2], guide = 'none') +
  theme_bw()

ppp <- pp + averaged_theme_regression 

pppp <- ggMarginal(ppp + theme(legend.position = c(1, 1), legend.justification = c(1, 1),
                               legend.background = element_rect(color = "white")), 
                   type = "density", alpha = .1, color = NA, fill = pal[2]) 

pdf(file.path(figures_path,'Figure_NAc_shell_core_PIT.pdf'))
print(ppp)
dev.off()







# -------------------------------------------------------------------------------------------------
#                                             HED
# -------------------------------------------------------------------------------------------------

# ------------------------------------- HED ROI during HED -----------------------------------------

HED.ROI.HED.TASK <- merge(PIT.index, ROI_HED.lik, by = 'ID')

# rename variables for this database
HED.ROI.HED.TASK <- rename.variable(HED.ROI.HED.TASK, 'HED_NACcoreshell_betas', 'NAc_shell_core')
HED.ROI.HED.TASK <- rename.variable(HED.ROI.HED.TASK, 'HED_NACshell_betas', 'NAc_shell')
HED.ROI.HED.TASK <- rename.variable(HED.ROI.HED.TASK, 'HED_mOFC_betas', 'mOFC')

#------------------------------- STAT
t.test(HED.ROI.HED.TASK$NAc_shell_core)
t.test(HED.ROI.HED.TASK$NAc_shell)
t.test(HED.ROI.HED.TASK$mOFC)

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
dfG = summaryBy(NAc_shell ~ 1, data = HED.ROI.HED.TASK,
                FUN = function(x) { c(m = mean(x, na.rm = T),
                                      s = se(x, na.rm = T)) } )

pp <- ggplot(HED.ROI.HED.TASK, aes(x = 0.5, y = NAc_shell)) +
  geom_abline(slope=0, intercept=0, linetype = "dashed", color = "gray") +
  geom_flat_violin(scale = "count", trim = FALSE, alpha = .2, color = NA, fill = pal[3], width = 0.5) +
  geom_jitter(alpha = .6, color = pal[3], width = 0.02) +
  geom_crossbar(data = dfG, aes(y =  NAc_shell.m, ymin= NAc_shell.m-NAc_shell.s, ymax= NAc_shell.m+NAc_shell.s), 
                width = 0.2 , alpha = 0.1, color = pal[3])+
  ylab('Beta estimates (a.u.)') +
  xlab('') + 
  scale_y_continuous(expand = c(-0, 0), breaks = c(seq.int(-0.035,0.06, by = 0.015)), limits = c(-0.035,0.06))  +
  scale_x_continuous(expand = c(0, 0), breaks = c(seq.int(0.2,0.8, by = 0.25)), limits = c(0.2,0.8))  +
  theme_bw()

ppp <- pp + averaged_theme_ttest 

pdf(file.path(figures_path,'Figure_NAc_shell_HED.pdf'))
print(ppp)
dev.off()

# pannel 3
dfG = summaryBy(NAc_shell_core ~ 1, data = HED.ROI.HED.TASK,
                FUN = function(x) { c(m = mean(x, na.rm = T),
                                      s = se(x, na.rm = T)) } )

pp <- ggplot(HED.ROI.HED.TASK, aes(x = 0.5, y = NAc_shell_core)) +
  geom_abline(slope=0, intercept=0, linetype = "dashed", color = "gray") +
  geom_flat_violin(scale = "count", trim = FALSE, alpha = .2, color = NA, fill = pal[3], width = 0.5) +
  geom_jitter(alpha = .6, color = pal[3], width = 0.02) +
  geom_crossbar(data = dfG, aes(y =  NAc_shell_core.m, ymin= NAc_shell_core.m-NAc_shell_core.s, ymax= NAc_shell_core.m+NAc_shell_core.s), 
                width = 0.2 , alpha = 0.1, color = pal[3])+
  ylab('Beta estimates (a.u.)') +
  xlab('') +
  scale_y_continuous(expand = c(-0, 0), breaks = c(seq.int(-0.035,0.06, by = 0.015)), limits = c(-0.035,0.06))  +
  scale_x_continuous(expand = c(0, 0), breaks = c(seq.int(0.2,0.8, by = 0.25)), limits = c(0.2,0.8))  +
  theme_bw()

ppp <- pp + averaged_theme_ttest 

pdf(file.path(figures_path,'Figure_NAc_shell_HED.pdf'))
print(ppp)
dev.off()


# ------------------------------------- PIT ROI during HED -----------------------------------------

PIT.ROI.HED.TASK <- merge(PIT.index, ROI_PIT.lik, by = 'ID')

# rename variables for this database
PIT.ROI.HED.TASK <- rename.variable(PIT.ROI.HED.TASK, 'PIT_EFF_VSCA_right_betas', 'NAc_CA_right')
PIT.ROI.HED.TASK <- rename.variable(PIT.ROI.HED.TASK, 'PIT_Eff_VSCA_left_betas', 'NAc_CA_left')

# remove ROI from CS+ vs CS- independent from effort
PIT.ROI.HED.TASK %>% select(-one_of('PIT_CS_NACschell_right_betas','PIT_CS_NACshell_left_betas'))


# long format for left and right
PIT.ROI.HED.TASK.long <- gather(PIT.ROI.HED.TASK, ROI , beta, NAc_CA_right:NAc_CA_left, factor_key=TRUE)


# -------------------------------- STAT
VS_CA_lik.stat     <- aov_car(beta ~ ROI + Error (ID/ROI), data = PIT.ROI.HED.TASK.long, factorize = F, anova_table = list(es = "pes")) 

# since there is no ROI effect let's compute the main effect on the average
PIT.ROI.HED.TASK.means <- aggregate(PIT.ROI.HED.TASK.long$beta, by = list(PIT.ROI.HED.TASK.long$ID), FUN='mean') # extract means
colnames(PIT.ROI.HED.TASK.means) <- c('ID','betas')
t.test(PIT.ROI.HED.TASK.means$beta)

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

pdf(file.path(figures_path,'Figure_NAc_CA_HED.pdf'))
print(ppp)
dev.off()

# ------------------------------------- CS+/CS- ROI during HED (SUPPLEMENTARY) -----------------------------------------

CS.ROI.HED.TASK <- merge(PIT.index, ROI_PIT.lik, by = 'ID')

# rename variables for this database
CS.ROI.HED.TASK <- rename.variable(CS.ROI.HED.TASK, 'PIT_CS_NACschell_right_betas', 'NAcShell_right')
CS.ROI.HED.TASK <- rename.variable(CS.ROI.HED.TASK, 'PIT_CS_NACshell_left_betas', 'NAcShell_left')

# remove ROI related to effort
CS.ROI.HED.TASK %>% select(-one_of('PIT_EFF_VSCA_right_betas','PIT_Eff_VSCA_left_betas'))

# long format for left and right
CS.ROI.HED.TASK.long <- gather(CS.ROI.HED.TASK, ROI , beta, NAcShell_right:NAcShell_left, factor_key=TRUE)


# -------------------------------- STAT
NAcShell_lik.stat     <- aov_car(beta ~ ROI + Error (ID/ROI), data = CS.ROI.HED.TASK.long, factorize = F, anova_table = list(es = "pes")) 

# since there is no ROI effect let's compute the main effect on the average
CS.ROI.HED.TASK.means <- aggregate(CS.ROI.HED.TASK.long$beta, by = list(CS.ROI.HED.TASK.long$ID), FUN='mean') # extract means
colnames(CS.ROI.HED.TASK.means) <- c('ID','betas')
t.test(CS.ROI.HED.TASK.means$betas)


#---------------------------------- PLOT
dfG = summaryBy(betas ~ 1, data = CS.ROI.HED.TASK.means,
                FUN = function(x) { c(m = mean(x, na.rm = T),
                                      s = se(x, na.rm = T)) } )

pp <- ggplot(CS.ROI.HED.TASK.means, aes(x = 0.5, y = betas)) +
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

pdf(file.path(figures_path,'Figure_NAc_CS_HED.pdf'))
print(ppp)
dev.off()








# --------------------------------------------------------------------------------------------------
#                                         HED - PIT behavioral LINK 
# --------------------------------------------------------------------------------------------------

# Behavioral correlation cue triggered effort and Us liking
scatterplot(PIT.index$deltaCS_R, HED.index$US_lik)
cor.test(PIT.index$deltaCS, HED.index$US_lik, method = 'kendall')
cor.test(PIT.index$deltaCS_R, HED.index$US_lik, method = 'pearson')



