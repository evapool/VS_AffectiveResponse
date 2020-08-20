## R code for FOR HED
# last modified on August 2020 by David

invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))
# -----------------------  PRELIMINARY STUFF ----------------------------------------
# load libraries
#pacman::p_load(mosaic, influence.ME,lmerTest, lme4, MBESS, afex, car, ggplot2, dplyr, sm, plyr, tidyr, reshape, Hmisc, Rmisc,  ggpubr, gridExtra, plotrix, lsmeans, BayesFactor, )
pacman::p_load(tidyverse, dplyr, plyr, lme4, car, afex, r2glmm, optimx, emmeans,misty, bayestestR)

if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}


#SETUP
task = 'HED'

# Set working directory
analysis_path <- file.path('~/REWOD/DERIVATIVES/BEHAV', task) 
figures_path  <- file.path('~/REWOD/DERIVATIVES/FIGURES/BEHAV') 
setwd(analysis_path)

# open dataset (session two only)
HED <- read.delim(file.path(analysis_path,'REWOD_HEDONIC_ses_second.txt'), header = T, sep ='') # read in dataset


# define as.factors
fac <- c("id", "session", "condition", "trialxcondition")
HED[fac] <- lapply(HED[fac], factor)

#removing empty condition
HED.woemp <- filter(HED, condition != "empty")

## remove sub 8 
HED <- filter(HED,  id != "8")

# get means by condition 
bt = ddply(HED, .(trialxcondition), summarise,  perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE)) 
# get means by condition and trialxcondition
bct = ddply(HED, .(condition, trialxcondition), summarise,  perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), EMG = mean(EMG, na.rm = TRUE)) 

# get means by participant 
bs = ddply(HED, .(id, trialxcondition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE), EMG = mean(EMG, na.rm = TRUE)) 
bsLIK = ddply(HED, .(id, Condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE))
bsEMG = ddply(HED, .(id, Condition), summarise, EMG = mean(EMG, na.rm = TRUE), EMG = mean(EMG, na.rm = TRUE))

# Center level-1 predictor within cluster (CWC)
HED$likC = center(HED$perceived_liking, type = "CWC", group = HED$id)
HED$intC = center(HED$perceived_intensity, type = "CWC", group = HED$id)
densityPlot(HED$likC)

#change value of condition
HED$condition = as.factor(revalue(HED$condition, c(empty="-1", neutral="0", chocolate="1")))


#save RData for cluster computing
# save.image(file = "HED.RData", version = NULL, ascii = FALSE,
#            compress = FALSE, safe = TRUE)

### ANALYSIS ------------------------

#FOR MODEL SELECTION we followed Barr et al. (2013) approach SEE --> CODE/ANALYSIS/BEHAV/MODEL_SELECTION/BMS_HED.R

#set "better" lmer optimizer #nolimit # yoloptimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

#set to method LRT 
model = mixed(likC ~ condition * intC + (condition * intC|id) + (condition |trialxcondition),
              data = HED, method = "LRT", control = control, REML = FALSE)
model

# Mixed Model Anova Table (Type 3 tests, LRT-method)
# 
# Model: likC ~ condition * intC + (condition * intC | id) + (condition | 
#                                                               Model:     trialxcondition)
# Data: HED
# Df full model: 34
# Effect df      Chisq p.value
# 1      condition  2  39.13 ***   <.001
# 2           intC  1 161.29 ***   <.001
# 3 condition:intC  2 162.00 ***   <.001

#manually
main = lmer(perceived_liking ~ condition * intC + (condition * intC|id) + (condition |trialxcondition), data = HED, control = control, REML = FALSE)
null = update(main, . ~ . - condition)

#manual test to double check and to get delta AIC
test = anova(main, null, test = 'Chisq')
test

#Δ AIC = 74.08242 #!! changed here to AIC 
delta_AIC = test$AIC[1] -test$AIC[2] 
delta_AIC

mod = lmer(perceived_liking ~ condition * intC + (condition * intC|id) + (condition |trialxcondition), data = HED, control = control)
#get estimated means a contrasts
CI_cond =confint(emmeans(mod, list(pairwise ~ condition)), level = .95, type = "response", adjust = "tukey")
CI_cond

p_cont =emmeans(mod, list(pairwise ~ condition), level = .95, type = "response", adjust = "tukey")
p_cont

# $`emmeans of condition`
# condition emmean   SE   df lower.CL upper.CL
# 1           63.2 1.21 23.9     60.0     66.3
# -1          54.4 1.39 22.4     50.8     58.0
# 0           50.5 1.52 24.0     46.6     54.4
# 
# Degrees-of-freedom method: kenward-roger 
# Confidence level used: 0.95 
# Conf-level adjustment: sidak method for 3 estimates 
# 
# $`pairwise differences of condition`
# contrast estimate   SE   df lower.CL upper.CL t.ratio p.value
# 1 - -1       8.75 1.26 22.0   5.5827     11.9 6.880   <.0001 
# 1 - 0       12.66 1.30 25.5   9.4117     15.9 9.618   <.0001
# -1 - 0       3.91 1.60 23.6  -0.0788      7.9 2.408   0.0604 


#sentence => main is 'significantly' better than the null model without condition as a fixed effect
# condition affected liking rating (χ2 (2)= 39.13, p<0.001), rising reward ratings by 12.66 points ± 1.30 SE
#compared to neutral condition and, 8.75 ± 1.26 (SE) compared to the control condition.


#custom contrast
con <- list(c1 = c(1, -0.5, -0.5))
cont = confint(emmeans(mod, ~ condition, contr = con, adjust = "none")) # Reward vs All
cont

contp = emmeans(mod, ~ condition, contr = con, adjust = "none") # Reward vs All
contp

# $contrasts
# contrast estimate   SE   df  lower.CL upper.CL t.ratio p.value
# c1           10.7 1.01   24   18.62     12.8    10.605  <.0001 


#looking at coeficients # takes a while
coef.out <- function(merMod) { coef(merMod)$id[,3] } #column 3 is coeficient for diff of neutral from reward
set.seed(123)
system.time(boot.out <- bootMer(mod,FUN=coef.out,nsim=1000,use.u=TRUE))
coef.conf = confint(boot.out,method="boot",boot.type="perc",level=0.95)
coef.conf
#This paints a slightly more interesting picture. We have one person 
#with no significant decreases in liking for the neutral stimulus,
#In other words, the proportion of people preferring the reward stim from the neutral stim is 
#estimated to be 96% (23/24)!.

# > coef.conf
# 2.5 %      97.5 %
#   [1,] -22.097854 -15.3981256
# [2,] -23.849763 -16.3243634
# [3,] -11.926957  -0.8848230
# [4,] -19.099847 -12.9719988
# [5,] -23.602331 -16.5157630
# [6,] -23.012752 -15.6108323
# [7,]  -7.918265   0.2604946
# [8,] -15.066342  -7.5394401
# [9,] -19.000003 -12.5361719
# [10,]  -9.917984  -2.1133027
# [11,] -23.727080 -15.6164994
# [12,] -14.969074  -4.3188563
# [13,] -11.563129  -3.6353199
# [14,] -11.180472  -4.7447221
# [15,] -12.272361  -6.5216738
# [16,] -12.812225  -4.1851672
# [17,] -13.633907  -5.1727962
# [18,] -16.397199  -9.1308239
# [19,] -17.508154  -9.6845467
# [20,] -15.994223  -7.8881373
# [21,] -17.667754  -7.4282208
# [22,] -14.194433  -5.6137141
# [23,] -12.128672  -4.8118686
# [24,] -26.458025 -17.8183389



# The END - Special thanks to Ben Meuleman, Eva R. Pool and Yoann Stussi -----------------------------------------------------------------



#looking at sum of coeficients
# set.seed(123)
# coef.out2 <- function(merMod) {coef(merMod)$id[,2] + coef(merMod)$id[,3]}
# system.time(boot.out <- bootMer(mod,FUN=coef.out2,nsim=1,use.u=TRUE))
# confint(boot.out,method="boot",boot.type="perc",level=0.95)

# 
# # INTENSITY ---------------------------------------------------------------
# 
# 
# main.model.int = lmer(perceived_intensity ~ condition + trialxcondition + (1+condition|id), data = HED, REML=FALSE)
# summary(main.model.int)
# 
# null.model.int = lmer(perceived_intensity ~ trialxcondition + (1+condition|id), data = HED, REML=FALSE)
# 
# testint = anova(main.model.int, null.model.int, test = 'Chisq')
# testint
# #sentence => main.intensity is 'signifincatly' better than the null model wihtout condition a fixe effect
# # condition affected intensity rating (χ2 (1)= 868.41, p<2.20×10ˆ-16), rising reward ratings by 17.63 points ± 0.57 (SEE) compared to neutral condition and,
# # 17.63 ± 0.56 (SEE) compared to the control condition.
# 
# #Δ BIC = XX
# delta_BIC = testint$BIC[1] -testint$BIC[2] 
# delta_BIC
# 
# ems = emmeans(main.model.int, list(pairwise ~ condition), adjust = "tukey")
# confint(emmeans(main.model.int,list(pairwise ~ condition)), level = .95, type = "response", adjust = "tukey")
# plot(ems)
# ems
# 
# 
# 
# #compute ptukey because ems rounds everything !!
# pR_C = 1 - ptukey(9.657 * sqrt(2), 3, 25.06)
# pR_C 
# 
# # Neutral VS Control (so we do that to be less bias and more conservator)
# # playing against ourselvees
# cont = emmeans(main.model.lik, ~ condition)
# contr_mat <- coef(pairs(cont))[c("c.3")]
# emmeans(main.model.lik, ~ condition, contr = contr_mat, adjust = "none")$contrasts
# 
# 
# # planned contrast
# HED$cvalue[HED$condition== 'chocolate']     <- 2
# HED$cvalue[HED$condition== 'empty']     <- -1
# HED$cvalue[HED$condition== 'neutral']     <- -1
# 
# 
# # planned contrast
# HED$cvalue[HED$condition== 'chocolate']     <- 2
# HED$cvalue[HED$condition== 'empty']     <- -1
# HED$cvalue[HED$condition== 'neutral']     <- -1
# 
# #
# main.cont.int = lmer(perceived_intensity ~ cvalue + trialxcondition + (1|id), data = HED, REML=FALSE)
# summary(main.cont.int)
# 
# null.cont.int = lmer(perceived_intensity ~ trialxcondition + (1|id), data = HED, REML=FALSE)
# 
# testint2 = anova(main.cont.int, null.cont.int, test = 'Chisq')
# testint2
# #sentence => main.intensity is 'signifincatly' better than the null model without condition as fixed effect
# # condition affected intensity rating (χ2 (1)= XX p<2.20×10ˆ-16), rising reward intensity ratings by XX points ± X.X (SEE) compared to the other two conditions
# #Δ BIC = XX
# delta_BIC = test2$BIC[1] -test2$BIC[2] 
# delta_BIC
# 
# 
# # 
# # #  contrast NEUTRAL - EMPTY "we play against ourselves by oding this contrast and being conservator"
# # HED$cvalue1[HED$condition== 'chocolate']     <- 0
# # HED$cvalue1[HED$condition== 'empty']     <- 1
# # HED$cvalue1[HED$condition== 'neutral']     <- -1
# # HED$cvalue1       <- factor(HED$cvalue1)
# # 
# # #
# # main.cont1 = lmer(perceived_intensity ~ cvalue1 + trialxcondition + (1|id), data = HED, REML=FALSE)
# # summary(main.cont1)

