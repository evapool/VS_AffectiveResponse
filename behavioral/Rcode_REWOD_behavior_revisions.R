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
# modified by E.R.P on JANUARY 2021                                                                #
# modified by D.M.T. on October 2021                                                               #



#--------------------------------------  PRELIMINARY STUFF ----------------------------------------
#load libraries
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}

pacman::p_load(apaTables, MBESS, afex, car, ggplot2, dplyr, plyr, tidyr, 
               reshape, Hmisc, Rmisc,  ggpubr, ez, gridExtra, plotrix, 
               lsmeans, BayesFactor, effectsize, devtools,misty)

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
home_path       <- dirname(rstudioapi::getActiveDocumentContext()$path)
pos             <- regexpr("VS_AffectiveResponse", home_path) # we want the path to the root folder
home_path       <- substr(home_path, 1, pos+19)

# Set working directory
analysis_path <- file.path(home_path, 'behavioral')
figures_path <- file.path(analysis_path, 'figures')
setwd(analysis_path)

# open datasets
PAV  <- read.delim(file.path(analysis_path, 'databases/REWOD_PAVCOND_ses_first.txt'), header = T, sep ='') # read in dataset
INST <- read.delim(file.path(analysis_path, 'databases/REWOD_INSTRU_ses_first.txt'), header = T, sep ='') # read in dataset
PIT  <- read.delim(file.path(analysis_path, 'databases/REWOD_PIT_ses_second.txt'), header = T, sep ='') # read in dataset
HED  <- read.delim(file.path(analysis_path, 'databases/REWOD_HEDONIC_ses_second.txt'), header = T, sep ='') # read in dataset

# themes for plots

averaged_theme <- theme_bw(base_size = 32, base_family = "Helvetica")+
  theme(strip.text.x = element_text(size = 32, face = "bold"),
        strip.background = element_rect(color="white", fill="white", linetype="solid"),
        legend.position="none",
        legend.text  = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.title.x = element_text(size = 32),
        axis.title.y = element_text(size =  32),
        axis.line = element_line(size = 0.5),
        panel.border = element_blank())



timeline_theme <- theme_bw(base_size = 32, base_family = "Helvetica")+
  theme(strip.text.x = element_text(size = 32, face = "bold"),
        strip.background = element_rect(color="white", fill="white", linetype="solid"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        legend.text  = element_text(size =  14),
        legend.title = element_text(size =  14),
        axis.title.x = element_text(size = 32),
        axis.title.y = element_text(size =  32),
        axis.line = element_line(size = 0.5),
        panel.border = element_blank())

pal = viridis::inferno(n=5)


########################################### PIT ################################################
## subsetting into 3 differents tasks
PIT.all <- PIT
# define factors
fac <- c("id", "session", "condition", "trialxcondition")
PIT.all[fac] <- lapply(PIT.all[fac], factor)

#subset phases
RIM <- subset (PIT.all,task == 'Reminder') 
PE <- subset (PIT.all,task == 'Partial_Extinction') 
PIT <- subset (PIT.all,task == 'PIT') 

PIT.s <- subset (PIT, condition == 'CSplus'| condition == 'CSminus')

# -------------------------------------- EXTINCTION CONCERN ---------------------------------------

# ----------------- Analysis suggested by reviewer
PIT.s$half[PIT.s$trialxcondition == '1']   <- "first"
PIT.s$half[PIT.s$trialxcondition == '2']   <- "first"
PIT.s$half[PIT.s$trialxcondition == '3']   <- "first"
PIT.s$half[PIT.s$trialxcondition == '4']   <- "first"
PIT.s$half[PIT.s$trialxcondition == '5']   <- "first"
PIT.s$half[PIT.s$trialxcondition == '6']   <- "first"
PIT.s$half[PIT.s$trialxcondition == '7']   <- "first"
PIT.s$half[PIT.s$trialxcondition == '8']   <- "null"
PIT.s$half[PIT.s$trialxcondition == '9']   <- "second"
PIT.s$half[PIT.s$trialxcondition == '10']   <-"second"
PIT.s$half[PIT.s$trialxcondition == '11']   <-"second"
PIT.s$half[PIT.s$trialxcondition == '12']   <-"second"
PIT.s$half[PIT.s$trialxcondition == '13']   <-"second"
PIT.s$half[PIT.s$trialxcondition == '14']   <-"second"
PIT.s$half[PIT.s$trialxcondition == '15']   <-"second"

PIT.s = subset(PIT.s, half != "null")
PIT.s$half = factor(PIT.s$half)
PIT.half.aov <- aov_car(n_grips ~ condition*half + Error (id/condition*half), data = PIT.s, anova_table = list(correction = "GG", es = "pes"))
F_to_eta2(f = c(7.43), df = c(1), df_error = c(23))

# Bayes factors trial effect
PIT.half <- aggregate(PIT.s$n_grips, by = list(PIT.s$id, PIT.s$half,PIT.s$condition), FUN='mean') # extract means
colnames(PIT.half ) <- c('id','half','condition','n_grips')
PIT.half$half = factor(PIT.half$half)

PIT.BF.int <- anovaBF(n_grips ~ condition*half + id, data = PIT.half, 
                      whichRandom = "id", iterations = 50000)
PIT.BF.int  <- recompute(PIT.BF.int, iterations = 50000)
PIT.BF.int[4]/ PIT.BF.int[3]

# follow up CS plus
PIT.aov.CSplus <- aov_car(n_grips ~ half + Error (id/half), data = subset(PIT.s, condition == 'CSplus'),anova_table = list(correction = "GG", es = "pes"))
F_to_eta2(f = c(5.80), df = c(1), df_error = c(23))

PIT.BF.CSplus <- anovaBF(n_grips ~ half + id, subset(PIT.half, condition == "CSplus"), 
                      whichRandom = "id", iterations = 50000)
PIT.BF.CSplus  <- recompute(PIT.BF.CSplus, iterations = 50000)

# follow up CS minus
PIT.aov.CSminus <- aov_car(n_grips ~ half + Error (id/half), data = subset(PIT.s, condition == 'CSminus'))
F_to_eta2(f = c(0.26), df = c(1), df_error = c(23))

PIT.BF.CSminus <- anovaBF(n_grips ~ half + id, subset(PIT.half, condition == "CSminus"), 
                         whichRandom = "id", iterations = 50000)
PIT.BF.CSminus  <- recompute(PIT.BF.CSminus, iterations = 50000)




########################################### HEDONIC ################################################

# define factors
HED$condition <- factor(HED$condition)
HED$trialxcondition <- factor(HED$trialxcondition) 
HED$id<- factor(HED$id)
HED = subset (HED, condition != 'empty')

# -------------------------------------- REWARD SATURATION CONCERN --------------------------------
HED.s <- subset (HED, condition == 'chocolate') # select the reward condition only

# get the right coefficient to code the linear constrast
HED.aov     <- aov_car(perceived_liking ~ trialxcondition + Error (id/trialxcondition), data = HED.s, anova_table = list(correction = "GG", es = "pes"))
HED.emm     <- emmeans(HED.aov, ~ trialxcondition , model = "multivariate")
HED.linear  <- contrast(HED.emm, "poly") # look only at the linear constrast here
coef(HED.linear)


# make linear contrast manually so that can extract BF and effect size
HED.s$saturation[HED.s$trialxcondition == '1']   <- -17
HED.s$saturation[HED.s$trialxcondition == '2']   <- -15
HED.s$saturation[HED.s$trialxcondition == '3']   <- -13
HED.s$saturation[HED.s$trialxcondition == '4']   <- -11
HED.s$saturation[HED.s$trialxcondition == '5']   <- -9
HED.s$saturation[HED.s$trialxcondition == '6']   <- -7
HED.s$saturation[HED.s$trialxcondition == '7']   <- -5
HED.s$saturation[HED.s$trialxcondition == '8']   <- -3
HED.s$saturation[HED.s$trialxcondition == '9']   <- -1
HED.s$saturation[HED.s$trialxcondition == '10']   <- 1
HED.s$saturation[HED.s$trialxcondition == '11']   <- 3
HED.s$saturation[HED.s$trialxcondition == '12']   <- 5
HED.s$saturation[HED.s$trialxcondition == '13']   <- 7
HED.s$saturation[HED.s$trialxcondition == '14']   <- 9
HED.s$saturation[HED.s$trialxcondition == '15']   <- 11
HED.s$saturation[HED.s$trialxcondition == '16']   <- 13
HED.s$saturation[HED.s$trialxcondition == '17']   <- 15
HED.s$saturation[HED.s$trialxcondition == '18']   <- 17

# with manual constrast  
summary(aov(perceived_liking ~ saturation + Error (id/saturation), data = HED.s)) # right df

F_to_eta2(f = c(6.256), df = c(1), df_error = c(23)) # effect sizes (90%CI)

# Bayes factors
saturation.BF <- generalTestBF(perceived_liking ~ saturation  + id, data = HED.s, 
                               whichRandom = "id", iterations = 50000)
saturation.BF <- recompute(saturation.BF , iterations = 50000)

#----------------- test if the reward was still more pleasant than the neutral odor at the end of experimental session
last.trial = subset(HED, trialxcondition == '18')
last.trial = subset(last.trial,condition != 'empty')
HED.last.trial    <- aov_car(perceived_liking ~ condition + Error (id/condition), data = last.trial, factorize = F) # wrong df

F_to_eta2(f = c(43.1), df = c(1), df_error = c(23)) # effect sizes (90%CI)

# Bayes factors
last.trial.BF <- anovaBF(perceived_liking ~ condition   + id, data = last.trial, 
                         whichRandom = "id", iterations = 50000)
last.trial.BF <- recompute(last.trial.BF, iterations = 50000)



########################################### INSTRUMENTAL ################################################

# define factors
INST$id                       <- factor(INST$id)
INST$session                  <- factor(INST$session)
INST$rewarded_response        <- factor(INST$rewarded_response)

# ----------------------------------- REWARD SATURATION CONCERN -----------------------------------

# do a linear constrast only for the answer to reviewers 
INST.aov     <- aov_car(n_grips ~ trial+ Error (id/trial) , data = INST, anova_table = list(correction = "GG", es = "pes"))
summary(aov(n_grips ~ trial+ Error (id/trial) , data = INST))
# effct size
F_to_eta2(f = c(1.702), df = c(1), df_error = c(23)) # effect sizes (90%CI)
# BF
INST.BF <- generalTestBF(n_grips ~ trial + id, data = INST, 
                               whichRandom = "id", iterations = 50000)
INST.BF <- recompute(INST.BF , iterations = 50000)

# does it the behavior linearly decreases over time indexing possible reward saturation effects?
INST.emm     <- emmeans(INST.aov, ~ trial , model = "multivariate")
INST.linear  <- contrast(INST.emm, "poly") # look only at the linear constrast here








