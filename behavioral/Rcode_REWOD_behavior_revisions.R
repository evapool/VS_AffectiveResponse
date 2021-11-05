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


if(!require(ddpcr)) {
  install.packages("ddpcr")
  library(ddpcr)
}  # to do quiet source


# Set path
analysis_path <- dirname(rstudioapi::getActiveDocumentContext()$path)

# Set working directory
if (analysis_path != getwd()) # important for when we source 
  setwd(analysis_path)

quiet(source(file.path(analysis_path, "Rcode_REWOD_behavior.R")), all=T) # run script quietly


# -------------------------------------- EXTINCTION CONCERN ---------------------------------------

# ----------------- Analysis suggested by reviewer
PIT.s$half= ifelse(as.numeric(PIT.s$trialxcondition)==8, NA, as.numeric(PIT.s$trialxcondition))
PIT.s$half = factor(ifelse(PIT.s$half >= 9, "second", "first"))
PIT.s = PIT.s[!is.na(PIT.s$half),]

PIT.half.aov <- aov_car(n_grips ~ condition*half + Error (id/condition*half), data = PIT.s, anova_table = list(correction = "GG", es = "pes")); PIT.half.aov
F_to_eta2(f = c(7.43), df = c(1), df_error = c(23))

# Bayes factors trial effect
PIT.half <- aggregate(PIT.s$n_grips, by = list(PIT.s$id, PIT.s$half,PIT.s$condition), FUN='mean') # extract means
colnames(PIT.half ) <- c('id','half','condition','n_grips')

PIT.BF.int <- anovaBF(n_grips ~ condition*half + id, data = PIT.half, 
                      whichRandom = "id", iterations = 50000); PIT.BF.int
PIT.BF.int[4]/ PIT.BF.int[3]


# post hoc contrasts
emms = emmeans(PIT.half.aov, ~ condition*half)

custom <- list("CS- early>late" = c(1,0,-1,0), "CS+ early>late" = c(0,1,0,-1)) 

contrast(emms, custom)

# plot
plt = ggplot(as_tibble(emms), aes(half, emmean, color = condition, fill = condition)) +
               geom_point() +
               geom_line(aes(group = condition), alpha = .5) +
               geom_crossbar(aes(ymin=emmean-SE, ymax=emmean+SE), width = 0.2 , alpha = 0.1)+
               ylab('Number of Grips')+
               xlab('Extinction Phase')+
               scale_color_manual(labels = c("CS+", "CS-"), values=c("CSplus" = pal[2],"CSminus"=pal[1]), name="Conditioned \n Stimulus")  +
               scale_fill_manual(labels = c("CS+", "CS-"), values=c("CSplus" = pal[2],"CSminus"=pal[1]), name="Conditioned \n Stimulus")  +
                scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,15, by = 5)), limits = c(0,16.5)) +
  scale_x_discrete(labels=c("Early", "Late")) +
               theme_bw() + averaged_theme + theme(panel.grid.major.y = element_line(size=.2, color="lightgrey"))

plt

pdf(file.path(figures_path,'Figure_PIT_phase_extinction.pdf'))
print(plt)
dev.off()

# follow up CS plus
PIT.aov.CSplus <- aov_car(n_grips ~ half + Error (id/half), data = subset(PIT.s, condition == 'CSplus'), anova_table = list(correction = "GG", es = "pes")); PIT.aov.CSplus
F_to_eta2(f = c(5.80), df = c(1), df_error = c(23))

PIT.BF.CSplus <- anovaBF(n_grips ~ half + id, subset(PIT.half, condition == "CSplus"), 
                      whichRandom = "id", iterations = 50000); PIT.BF.CSplus

# follow up CS minus
PIT.aov.CSminus <- aov_car(n_grips ~ half + Error (id/half), data = subset(PIT.s, condition == 'CSminus')); PIT.aov.CSminus 
F_to_eta2(f = c(0.26), df = c(1), df_error = c(23))

PIT.BF.CSminus <- anovaBF(n_grips ~ half + id, subset(PIT.half, condition == "CSminus"), 
                         whichRandom = "id", iterations = 50000); PIT.BF.CSminus


# -------------------------------------- REWARD SATURATION CONCERN --------------------------------

# define factors
HED = subset (HED, condition != 'empty')

HED.s <- subset (HED, condition == 'chocolate') # select the reward condition only

# get the right coefficient to code the linear constrast
HED.aov     <- aov_car(perceived_liking ~ trialxcondition + Error (id/trialxcondition), data = HED.s, anova_table = list(correction = "GG", es = "pes"))
HED.emm     <- emmeans(HED.aov, ~ trialxcondition , model = "multivariate")
HED.linear  <- contrast(HED.emm, "poly") # look only at the linear constrast here
coef(HED.linear)


# make linear contrast manually so that can extract BF and effect size
HED.s$saturation = scales::rescale(as.numeric(HED.s$trialxcondition), to = c(-17,17))

# with manual constrast  
summary(aov(perceived_liking ~ saturation + Error (id/saturation), data = HED.s)) # right df

F_to_eta2(f = c(6.256), df = c(1), df_error = c(23)) # effect sizes (90%CI)

# Bayes factors
saturation.BF <- generalTestBF(perceived_liking ~ saturation  + id, data = HED.s, 
                               whichRandom = "id", iterations = 50000); saturation.BF


#----------------- test if the reward was still more pleasant than the neutral odor at the end of experimental session
last.trial = subset(HED, trialxcondition == '18')
last.trial = subset(last.trial,condition != 'empty')
HED.last.trial    <- aov_car(perceived_liking ~ condition + Error (id/condition), data = last.trial, factorize = F); HED.last.trial  # wrong df

F_to_eta2(f = c(43.1), df = c(1), df_error = c(23)) # effect sizes (90%CI)

# Bayes factors
last.trial.BF <- anovaBF(perceived_liking ~ condition   + id, data = last.trial, 
                         whichRandom = "id", iterations = 50000); last.trial.BF



# ----------------------------------- REWARD SATURATION CONCERN INSTRUMENTAL ANALYSIS -----------------------------------

# do a linear constrast only for the answer to reviewers 
INST.aov     <- aov_car(n_grips ~ trial+ Error (id/trial) , data = INST, anova_table = list(correction = "GG", es = "pes")); INST.aov
# effect size
F_to_eta2(f = c(1.702), df = c(1), df_error = c(23)) # effect sizes (90%CI)
# BF
INST.BF <- generalTestBF(n_grips ~ trial + id, data = INST, 
                               whichRandom = "id", iterations = 50000); INST.BF


# does it the behavior linearly decreases over time indexing possible reward saturation effects?
INST.emm     <- emmeans(INST.aov, ~ trial , model = "multivariate")
INST.linear  <- contrast(INST.emm, "poly"); INST.linear # look only at the linear contrast here


# ---------------------- CONCERN: ADD MEAN AND SD TO ANALYSIS SECTION ----------------------------------


estimate.PAV.RT = summaryBy( RT ~ condition, data = PAV.means,
                                   FUN = function(x) { c(m = mean(x), s = sd(x), n = length(x)) } )

estimate.PAV.liking = summaryBy( liking ~ condition, data = PAV.means,
                             FUN = function(x) { c(m = mean(x), s = sd(x), n = length(x)) } )

estimate.INST = summaryBy(n_grips ~ trial, data = INST.T,
                                 FUN = function(x) { c(m = mean(x), s = sd(x), n = length(x)) } )

estimate.PIT = summaryBy(n_grips ~ condition, data = PIT.means,
                          FUN = function(x) { c(m = mean(x), s = sd(x), n = length(x)) } )

estimate.HED = summaryBy(perceived_liking ~ condition, data = HED.means,
                         FUN = function(x) { c(m = mean(x), s = sd(x), n = length(x)) } )

