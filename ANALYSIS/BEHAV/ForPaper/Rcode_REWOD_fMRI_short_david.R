#                                                                                                  #
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
# modified by E.R.P on  JANUARY  2021 (short version) (April 2021 D.M.T.)                                             #



#--------------------------------------  PRELIMINARY STUFF ----------------------------------------
#load libraries
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}

pacman::p_load(apaTables, MBESS, afex, car, ggplot2, dplyr, plyr, tidyr, 
               reshape, Hmisc, Rmisc,  ggpubr, ez, gridExtra, plotrix, 
               lsmeans, BayesFactor, effectsize, devtools,misty,questionr,ggplot, ggExtra,
               doBy,BayesFactor,BayesianFirstAid, boot, lmPerm)

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

# add function directory
source(paste(analysis_path, "/functions/cohen_d_ci.R", sep = ""))

#datasets directory
data_path <- file.path(home_path,'DERIVATIVES/BEHAV') 

# open datasets
PAV  <- read.delim(file.path(data_path,'PAV/REWOD_PAVCOND_ses_first.txt'), header = T, sep ='') # read in dataset
INST <- read.delim(file.path(data_path,'INSTRU/REWOD_INSTRU_ses_first.txt'), header = T, sep ='') # read in dataset
PIT  <- read.delim(file.path(data_path,'PIT/REWOD_PIT_ses_second.txt'), header = T, sep ='') # read in dataset
HED  <- read.delim(file.path(data_path,'HED/REWOD_HEDONIC_ses_second.txt'), header = T, sep ='') # read in dataset



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





# ----------------------------------------    PREPROC ---------------------------------------

# -------------------------------------  PIT   ----------------------------------------------

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



#-------------------------------------- HED -------------------------------------------------------
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





# ------------------------------------- CORE during PIT -----------------------------------------

# Compile database
PIT.ROI <- merge(PIT.index, PIT.TASK, by = 'ID')

# -------------------------------- STAT

# permut
mod = lmp(core ~ deltaCS_R, PIT.ROI) 
summary(mod)
#cor.test(PIT.ROI$deltaCS, PIT.ROI$core, method = 'kendall') # rank

#eff size CI bootstrap
CI_R <- boot(PIT.ROI,function(data,indices) 
              summary(lmp(core~deltaCS,data[indices,]))$r.squared,R=10000)
quantile(CI_R$t,c(0.025,0.975))



aov_car(core ~ deltaCS_R  + Error (ID ), data = PIT.ROI, observed = c("deltaCS_R"), factorize = F, anova_table = list(es = "none"))
pes_ci(core ~ deltaCS_R  + Error (ID ), data = PIT.ROI, observed = c("deltaCS_R"), factorize = F)

BF <- lmBF(core ~ deltaCS_R + ID, data = PIT.ROI, 
           whichRandom = "ID", iterations = 50000) ; BF


# PLOT PIT CORE -----------------------------------------------------------


pp <- ggplot(PIT.ROI, aes(y = core, x = deltaCS)) +
  geom_point(color = pal[2]) +
  geom_smooth(method='lm', color = pal[2], fill = pal[2], alpha = 0.2,fullrange=TRUE) +
  labs(y = 'CS+ > CS- (a.u.)', x ='PIT index') + #Beta estimates (a.u) # Cue-triggered effort
  scale_fill_manual(values=pal[2], guide = 'none') +
  theme_bw()

ppp <- pp + averaged_theme_regression

ppp



pp <- ggplot(PIT.ROI, aes(y = core, x = deltaCS_R)) +
  geom_point(color = pal[2]) +
  geom_smooth(method='lm', color = pal[2], fill = pal[2], alpha = 0.2,fullrange=TRUE) +
  labs(y = 'Beta estimates (a.u)', x =' Cue-triggered effort') + # #
  scale_fill_manual(values=pal[2], guide = 'none') +
  theme_bw()

ppp <- pp + averaged_theme_regression

ppp

figure1 <- ggMarginal(ppp + theme(legend.position = c(1, 1), legend.justification = c(1, 1),
                                  legend.background = element_rect(color = "white")), 
                      type = "density", alpha = .1, color = NA, fill = pal[2]) 
figure1
pdf(file.path(figures_path,'Figure_CORE_PIT.pdf'))
print(figure1)
dev.off()



# compile

PIT.long <- gather(PIT.ROI, ROI , beta, shell:core, factor_key=TRUE)
PIT.long$ROI <- relevel(PIT.long$ROI, "core") # Make core first

core_eff.stat     <- aov_car(beta ~ deltaCS_Z + ROI + Error (ID/ROI), data = PIT.long ,
                             observed = c("deltaCS_Z"), factorize = F, anova_table = list(es = "none"))


pes_ci(beta ~ deltaCS_Z  + ROI + Error (ID/ROI), data = PIT.long,
       observed = c("deltaCS_Z"), factorize = F)

emtrends(core_eff.stat, pairwise ~ ROI, var = "deltaCS_Z") #shel trends within 0 whereas core not

#emmip(core_eff.stat, ROI ~ deltaCS_Z, cov.reduce = range) # vizualize

test = extractBF(generalTestBF(beta ~ deltaCS_Z*ROI + ID, data= PIT.long, whichRandom = 'ID', neverExclude =  'ID', whichModels ="top")); BF = 1/test[1] #switch to BF10




# ------------------------------------- SHELL during HED -----------------------------------------

#permut
set.seed(123); DAAG::onet.permutation(HED.TASK$shell, nsim = 10000, plotit = F)
dfG = summarySE(data = HED.TASK, measurevar = "shell"); dfG


#ttest
t.test(HED.TASK$shell)

# BF
ttestBF(HED.TASK$shell)

# effect size
cohen_d_ci(HED.TASK$shell, conf.level = .95)



# -------------------------------- PLOT HED SHELL-----------------


# pannel 1


pp <- ggplot(HED.TASK, aes(x = 0.5, y = shell)) +
  geom_abline(slope=0, intercept=0, linetype = "dashed", color = "gray") +
  geom_flat_violin(scale = "count", trim = FALSE, alpha = .2, color = NA, fill = pal[3], width = 0.5) +
  geom_jitter(alpha = .6, color = pal[3], width = 0.02) +
  geom_crossbar(data = dfG, aes(ymin= shell-se, ymax= shell+se), 
                width = 0.2 , alpha = 0.1, color = pal[3])+
  ylab('Liking Modulation (a.u.)') + #Beta estimates (a.u.)
  xlab('') + 
  #scale_y_continuous(expand = c(-0, 0), breaks = c(seq.int(-0.03,0.05, by = 0.02)), limits = c(-0.031,0.051))  +
  scale_x_continuous(expand = c(0, 0), breaks = c(seq.int(0.1,0.8, by = 0.25)), limits = c(0.2,0.8))  +
  theme_bw()

ppp <- pp + averaged_theme_ttest 

ppp



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



# OTHER STUFF -------------------------------------------------------------------


pp <- ggplot(PIT.ROI, aes(y = shell, x = deltaCS_R)) +
  geom_point(color = pal[2]) +
  geom_smooth(method='lm', color = pal[2], fill = pal[2], alpha = 0.2,fullrange=TRUE) +
  labs(y = 'CS+ > CS- (a.u.)', x ='PIT index') + #Beta estimates (a.u) # Cue-triggered effort
  scale_fill_manual(values=pal[2], guide = 'none') +
  theme_bw()

pp + averaged_theme_regression

#plot inter 
  
pp <- ggplot(PIT.long, aes(y = beta, x = deltaCS, color = ROI, fill = ROI)) +
  geom_point() +
  geom_smooth(method='lm', alpha = 0.2, fullrange=TRUE) +
  labs(y = 'CS+ > CS- (a.u.)', x ='PIT index') + #Beta estimates (a.u) # Cue-triggered effort
  scale_fill_manual(values=c("core"="royalblue", "shell"=pal[3]), guide = 'none') +
  scale_color_manual(values=c("core"="royalblue", "shell"=pal[3]), guide = 'none') +
  theme_bw()

ppp <- pp + averaged_theme_regression

ppp

# Compile database
HED.ROI <- merge(HED.index, HED.TASK, by = 'ID')


HED.long <- gather(HED.ROI, ROI , beta, shell:core, factor_key=TRUE)

shell.stat     <- aov_car(beta ~  ROI + Error (ID/ROI), data = HED.long, factorize = F, anova_table = list(es = "none"))



# ------------------------------------- SHELL during PIT -----------------------------------------


#shell
shell_eff.stat     <- aov_car(shell ~ deltaCS_R + Error (ID), data = PIT.ROI,
                              observed = c("deltaCS_R"), factorize = F, anova_table = list(es = "none")) # no

pes_ci(shell ~ deltaCS_R  + Error (ID), data = PIT.ROI,
       observed = c("deltaCS_R"), factorize = F)

BF <- lmBF(shell ~ deltaCS_R + ID, data = PIT.ROI, 
           whichRandom = "ID", iterations = 50000); BF


# -------------------------------- PLOT



# pannel 2
pp <- ggplot(PIT.ROI, aes(y = shell, x = deltaCS)) +
  geom_point(color = pal[2]) +
  geom_smooth(method='lm', color = pal[2], fill = pal[2], alpha = 0.2,fullrange=TRUE) +
  labs(y = 'Beta estimates (a.u)', x ='PIT index ') +
  scale_fill_manual(values=pal[2], guide = 'none') +
  theme_bw()

ppp <- pp + averaged_theme_regression 

figure3 <- ggMarginal(ppp + theme(legend.position = c(1, 1), legend.justification = c(1, 1),
                                  legend.background = element_rect(color = "white")), 
                      type = "density", alpha = .1, color = NA, fill = pal[2]) 
figure3
pdf(file.path(figures_path,'Figure_SHELL_PIT.pdf'))
print(pppp)
dev.off()



# ------------------------------------- CORE during HED -----------------------------------------


# -------------------------------- STAT
set.seed(123); DAAG::onet.permutation(HED.TASK$core, nsim = 10000, plotit = F)
dfG = summarySE(data = HED.TASK, measurevar = "core"); dfG

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





# -------------------------------      DIRECT COMPARAISON DURING PIT IN VS----------------------------------------------------------------------------------

# ----------------------------------------------PIT TASK -----------------------------------------------

CM.HED.ROI.PIT = HED.ROI.TASK.PIT
CM.HED.ROI.PIT = CM.HED.ROI.PIT %>% select(-one_of('mOFC','HED_NACshell_betas'))
CM.HED.ROI.PIT <- rename.variable(CM.HED.ROI.PIT, 'NAc_shell_core', 'beta')

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
intROIPIT.BF <- recompute(intROIPIT.BF , iterations = 50000)
intROIPIT.BF[9]/intROIPIT.BF[8] 






# ----------------------------------------------HED TASK -----------------------------------------------

CM.HED.ROI.HED = HED.ROI.HED.TASK
CM.HED.ROI.HED = CM.HED.ROI.HED %>% select(-one_of('mOFC','HED_NACshell_betas'))
CM.HED.ROI.HED <- rename.variable(CM.HED.ROI.HED, 'NAc_shell_core', 'beta')
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
F_to_eta2(f = c(4.79), df = c(1), df_error = c(23)) # effect sizes (90%CI)


intROIHED.BF <- anovaBF(beta ~ ROI_type + ID, data = HED.ROI.COMPARE.means, 
                        whichRandom = "ID", iterations = 50000)
intROIHED.BF <- recompute(intROIHED.BF, iterations = 50000)
intROIHED.BF




# ----------------------------      HED - PIT behavioral LINK ----------------------

# Behavioral correlation cue triggered effort and Us liking
scatterplot(PIT.index$deltaCS_R, HED.index$US_lik)
cor.test(PIT.index$deltaCS, HED.index$US_lik, method = 'kendall')
cor.test(PIT.index$deltaCS_R, HED.index$US_lik, method = 'pearson')



