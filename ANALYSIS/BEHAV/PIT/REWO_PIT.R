## R code for FOR PIT
# last modified on august 2020 by David

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
task = 'PIT'

# Set working directory
analysis_path <- file.path('~/REWOD/DERIVATIVES/BEHAV', task) 
setwd(analysis_path)

# open dataset
PIT <- read.delim(file.path(analysis_path,'REWOD_PIT_ses_second.txt'), header = T, sep ='') # read in dataset

## subsetting into 3 differents tasks
PIT.all <- PIT
# define factors
fac <- c("id", "session", "condition",  "trialxcondition")
PIT.all[fac] <- lapply(PIT.all[fac], factor)

#subset phases
RIM <- subset (PIT.all,task == 'Reminder') 
PE <- subset (PIT.all,task == 'Partial_Extinction') 
PIT <- subset (PIT.all,task == 'PIT') 

# Center level-1 predictor within cluster (CWC)
PIT$gripC = center(PIT$n_grips, type = "CWC", group = PIT$id)
densityPlot(PIT$gripC) #not bad but not good

#change value of condition
PIT$condition = as.factor(revalue(PIT$condition, c(CSminus="-1", Baseline="0", CSplus="1")))
PIT$condition = factor(PIT$condition,levels(PIT$condition)[c(3,2,1)])

#save RData for cluster computing
# save.image(file = "PIT.RData", version = NULL, ascii = FALSE,
#            compress = FALSE, safe = TRUE)


### ANALYSIS ------------------------

#FOR MODEL SELECTION we followed Barr et al. (2013) approach SEE --> CODE/ANALYSIS/BEHAV/MODEL_SELECTION/BMS_PIT.R

#set "better" lmer optimizer #nolimit # yoloptimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

#set to method LRT 
model = mixed(gripC ~ condition + (condition |id),
              data = PIT, method = "LRT", control = control, REML = FALSE)
model

# Mixed Model Anova Table (Type 3 tests, LRT-method)
# 
# Model: n_grips ~ condition + (condition | id)
# Data: PIT
# Df full model: 10
# Effect df    Chisq p.value
# 1 condition  2 11.10 **    .004

#manually
main = lmer(n_grips ~ condition + (condition |id) , data = PIT, control = control, REML = FALSE)
null = update(main, . ~ . - condition)

#manual test to double check and to get delta AIC
test = anova(main, null, test = 'Chisq')
test

#Δ AIC = 7.097514 
delta_AIC = test$AIC[1] -test$AIC[2] 
delta_AIC

#get BF fro mixed see Wagenmakers, 2007
exp((test[1,2] - test[2,2])/2) #



# Computing CIs and Post-Hoc contrasts ------------------------------------
mod = lmer(n_grips ~ condition + (condition |id), data = PIT, control = control)
#get estimated means a contrasts
CI_cond =confint(emmeans(mod, list(pairwise ~ condition)), level = .95, type = "response", adjust = "tukey")
CI_cond

p_cont =emmeans(mod, list(pairwise ~ condition), level = .95, type = "response", adjust = "tukey")
p_cont

# $`emmeans of condition`
# condition emmean   SE df lower.CL upper.CL
# 1          12.06 1.21 23     8.95     15.2
# -1          7.54 1.29 23     4.22     10.9
# 0           7.60 1.25 23     4.38     10.8
# 
# Degrees-of-freedom method: kenward-roger 
# Confidence level used: 0.95 
# Conf-level adjustment: sidak method for 3 estimates 
# 
# $`pairwise differences of condition`
# contrast estimate    SE df lower.CL upper.CL t.ratio p.value
# 1 - (-1)   4.5250 1.233 23    1.437    7.613 3.670  0.0035 
# 1 - 0      4.4639 1.238 23    1.364    7.564  3.606  0.0041 
# (-1) - 0  -0.0611 0.319 23   -0.861    0.738 -0.191  0.9800 

#sentence => main is 'signifincatly' better than the null model wihtout condition a fixe effect
# condition affected handgrip presses (χ2 (2)= 11.10, p=.004), in average having 4.5250 ± 1.23 (SE) more squeezes compared to CS- condition and,
# 4.4639 ± 1.238 (SE) compared to the baseline.

#custom contrast
con <- list(c1 = c(1, -0.5, -0.5))
cont = confint(emmeans(mod, ~ condition, contr = con, adjust = "none")) # CS+ vs All
cont

contp = emmeans(mod, ~ condition, contr = con, adjust = "none") # Reward vs All
contp
# $contrasts
# contrast estimate   SE df lower.CL upper.CL t.ratio p.value
# c1           4.49 1.22 23 1.96     7.03      3.669   0.0013 



#looking at coeficients # takes a while
coef.out <- function(merMod) { coef(merMod)$id[,2] } #column 2 is coeficient for diff of CS- from CS+
set.seed(123)
system.time(boot.out <- bootMer(mod,FUN=coef.out,nsim=1000,use.u=TRUE))
coef.conf = confint(boot.out,method="boot",boot.type="perc",level=0.95)
coef.conf

#> coef.conf
# 2.5 %      97.5 %
#   [1,]  -4.058886   1.0713879
# [2,]  -5.657097  -0.8020781
# [3,]  -2.835040   1.9499898
# [4,]  -1.913733   3.7694031
# [5,]  -2.395117   2.5780803
# [6,] -15.632002 -10.2750003
# [7,]  -2.733613   2.2090749
# [8,]  -2.358591   3.0331393
# [9,]  -3.724512   1.3372591
# [10,]  -9.131967  -4.1372079
# [11,] -12.771407  -7.6988326
# [12,]  -9.323349  -4.2921694
# [13,] -19.036580 -13.7673433
# [14,]  -4.735738   0.3260050
# [15,]  -5.010133   0.2421240
# [16,] -10.539334  -5.5553837
# [17,]  -8.487117  -3.3561484
# [18,]  -3.110474   1.8152025
# [19,]  -4.323865   0.5358006
# [20,] -21.991755 -16.6916971
# [21,]  -5.648079  -0.2952588
# [22,]  -3.909614   1.2414764
# [23,]  -3.475462   1.2073542
# [24,]  -6.783787  -1.9115101

#This paints a slightly more interesting picture. We have 11 person 
#with no significant decreases  (95%) in grips for the CS- stimulus,
#In other words, the proportion of people showing a PIT effect is 
#estimated to be 63% (15/24)!. -


# The END - Special thanks to Ben Meuleman, Eva R. Pool and Yoann Stussi -----------------------------------------------------------------
# 
# 
# mod2 <- lmer(gripC ~condition + (condition|id) ,     data = PIT, control = control) 
# 
# # Ben saif boundary (singular) fit: see ?isSingular was ok if the variance checks out
# null.model = lmer(n_grips ~  trialxcondition + (1+condition |id), data = PIT, REML = FALSE) 
# 
# test = anova(main.model, null.model, test = 'Chisq')
# test
# 
# 
# 
# 
# 
# #Δ BIC
# delta_BIC = test$BIC[2] - test$BIC[1]
# delta_BIC
# 
# # #difflsmeans
# # pairw = difflsmeans(main.model, test.effs="condition")
# # plot(parw)
# # pairw
# 
# #emmeans
# ems = emmeans(main.model, list(pairwise ~ condition), adjust = "none")
# confint(emmeans(main.model, list(pairwise ~ condition)) level = .95, type = "response", adjust = "tukey")
# plot(ems)
# ems
# 
# 
# 
# # manual planned contrasts
# PIT$cvalue[PIT$condition== 'CSplus']       <- 2
# PIT$cvalue[PIT$condition== 'CSminus']      <- -1
# PIT$cvalue[PIT$condition== 'Baseline']     <- -1
# PIT$cvalue1      <- factor(PIT$cvalue1)
# 
# main.cont = lmer(n_grips ~ cvalue + trialxcondition + (1|id), data = PIT, REML = FALSE) 
# summary(main.cont)
# ems = emmeans(main.cont, list(pairwise ~ cvalue), adjust = "tukey")
# 
# null.cont = lmer(n_grips ~  trialxcondition + (1|id), data = PIT, REML = FALSE) 
# 
# 
# test2 = anova(main.cont, null.cont, test = 'Chisq')
# test2
# 
# #Δ BIC
# delta_BIC = test$BIC[1] -test$BIC[2] 
# delta_BIC
# 
# #OR ALSO planned contrast also in case: CS+ VS CS- and Baseline
# #A = c(2, 0, 0)
# #B = c(0, -1, -1)
# #cont = emmeans(main.model, ~ condition)
# #contrast(cont, method = list(A - B) )
# 
# 
# 
# # CSminus VS Baseline (so we do that to be less bias and more conservator)
# # playing against ourselvees
# cont = emmeans(main.model, ~ condition)
# contr_mat <- coef(pairs(cont))[c("c.3")]
# emmeans(main.model, ~ condition, contr = contr_mat, adjust = "none")$contrasts
# confint(emmeans(main.model, ~ condition, contr = contr_mat, adjust = "none")$contrasts)
# 
# 
# 
# 
# 
# 
# 
# # REMINDER ----------------------------------------------------------------
# 
# 
# # ANOVA trials ------------------------------------------------------------
# 
# ##1. number of grips: are participants gripping more over time?
# RIM$trial            <- factor(RIM$trial)
# 
# 
# anova_model = ezANOVA(data = RIM,
#                       dv = n_grips,
#                       wid = id,
#                       within = trial,
#                       detailed = TRUE,
#                       type = 3)
# 
# #using afex
# rem.aov <- aov_car(n_grips ~ trial + Error(id/trial), data = RIM, anova_table = list(es = "pes"))
# 
# #contrast pairvise corrected to get pvalues
# ems = emmeans(rem.aov, list(pairwise ~ trial), adjust = "tukey")
# ems
# 
# # effect sizes ------------------------------------------------------------
# #source('~/REWOD/CODE/ANALYSIS/BEHAV/my_tools/pes_ci.R')
# 
# 
# #pes_ci <- function(formula, data, conf.level, epsilon, anova.type)
# 
# 
# 
# # Partial extinction ------------------------------------------------------
# 
# # 
# 
# PE$trial            <- factor(PE$trial)
# 
# dfTRIAL <- data_summary(PE, varname="n_grips", groupnames=c("trial"))
# 
# o = length(dfTRIAL$sd)
# for(x in 1:o){
#   dfTRIAL$sem[x] <- dfTRIAL$sd[x]/sqrt(length(dfTRIAL$sd))
# }
# 
# 
# 
# ##plot n_grips to see the trajectory of learning (overall average by trials)
# 
# ggplot(dfTRIAL, aes(x = trial, y = n_grips)) +
#   geom_point() + geom_line(group=1) +
#   geom_errorbar(aes(ymin=n_grips-sem, ymax=n_grips+sem), color='grey', width=.2,
#                 position=position_dodge(0.05), linetype = "dasPIT") +
#   theme_classic() +
#   #scale_y_continuous(expand = c(0, 0), limits = c(10,16)) + #, breaks = c(9.50, seq.int(10,15, by = 1)), ) +
#   #scale_x_continuous(expand = c(0, 0), limits = c(0,25), breaks=c(0, seq.int(1,25, by = 3))) + #,breaks=c(seq.int(1,24, by = 2), 24), limits = c(0,24)) + 
#   labs(x = "Trial
#        ",
#        y = "Number of Squeezes",title= "   
#        ") +
#   theme(text = element_text(size=rel(4)), plot.margin = unit(c(1, 1,0, 1), units = "cm"), axis.title.x = element_text(size=16), axis.title.y = element_text(size=16))
# 
# 
# #ANALYSIS
# 
# # ANOVA trials ------------------------------------------------------------
# 
# ##1. number of grips: are participants gripping more over time?
# PE$trial            <- factor(PE$trial)
# 
# 
# anova_model = ezANOVA(data = PE,
#                       dv = n_grips,
#                       wid = id,
#                       within = trial,
#                       detailed = TRUE,
#                       type = 3)
# 
# #using afex
# pe.aov <- aov_car(n_grips ~ trial + Error(id/trial), data = PE, anova_table = list(es = "pes"))
# 
# #contrast pairvise corrected to get pvalues
# ems = emmeans(pe.aov, list(pairwise ~ trial), adjust = "tukey")
# ems
# 




