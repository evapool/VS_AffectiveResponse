## R code for FOR PIT PLOT
## last modified on April 2020 by David MUNOZ TORD

# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, dplyr, plyr, lme4, car, afex, r2glmm, optimx, sjPlot, emmeans, visreg, RNOmni, jtools, interactions, sjstats, Rmisc)

# SETUP ------------------------------------------------------------------

task = 'PIT'

# Set working directory
analysis_path <- file.path('~/REWOD/DERIVATIVES/BEHAV', task) 
figures_path  <- file.path('~/REWOD/DERIVATIVES/FIGURES/BEHAV') 
setwd(analysis_path)

## LOADING AND INSPECTING THE DATA
load('PIT.RData')

#set "better" lmer optimizer #nolimit # yoloptimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

mod = lmer(n_grips ~ condition + (condition |id), data = PIT, control = control, REML = FALSE)



# PLOT --------------------------------------------------------------------
source('~/REWOD/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R')

#increase repetitions limit
emm_options(pbkrtest.limit = 5000)
emm_options(lmerTest.limit = 5000)

#get contrasts and means for MAIN PLOT
CI_pit = confint(emmeans(mod, pairwise~ condition, adjust = "tukey"),level = 0.95,method = c("boot"),nsim = 5000)

df.predicted = data.frame(CI_pit$emmeans)

#get predicted by ind
rand = ranef(mod)
ran = data.frame(rand$id)
fix = t(data.frame(fixef(mod)))
df = ran + fix[col(ran)]
df$CSp = df$X.Intercept.
df$base = df$CSp + df$condition0
df$CSm = df$CSp + df$condition.1
df = select(df, c(CSp,base, CSm))
df$id = as.factor(c(1:length(df$CSm)))
df.observed <- gather(df, condition, emmean, CSp:CSm, factor_key=TRUE)
#df.observed = ddply(PIT, .(id, trial, condition), summarise, emmean = mean(perceived_liking, na.rm = TRUE)) 

df.observed$condition = as.factor(revalue(df.observed$condition, c(CSm="-1", base="0",CSp="1")))
df.observed$condition = factor(df.observed$condition,levels(df.observed$condition)[c(1,3,2)])

df.observed.jit <- df.observed %>% mutate(condjit = jitter(as.numeric(condition), 0.9),
                                          grouping = interaction(id, condition))

df.predicted.jit <- df.predicted %>% mutate(condjit = jitter(as.numeric(condition), 0.9),
                                            grouping = interaction(1, condition))

#ind
plt0 = ggplot(df.observed.jit, aes(x=condition,  y=emmean)) + 
  geom_blank() +
  geom_flat_violin(aes( fill = condition), alpha = .4, position = position_nudge(x = .3, y = 0), adjust = 1.5, trim = F, color = 'white') + 
  geom_line(aes(condjit, group = id), alpha = 0.1) +
  geom_point(aes(condjit), size=1, alpha=0.5)
#group
plt = plt0  +
  geom_bar(data = df.predicted.jit,aes( fill = condition), stat = "identity", position=position_dodge2(width=0.9), alpha = 0.4, width = 0.5) +
  geom_errorbar(data = df.predicted.jit, aes(group = condition, ymin=emmean - SE, ymax=emmean + SE), size=0.5, width=0.1,  color = "black", position=position_dodge(width = 0.5)) +
  geom_point(data = df.predicted.jit, size = 2,  shape = 23, color= "black", fill = 'grey40',  position=position_dodge2(width = 0.5))


plot = plt +   theme_bw() +
  scale_color_manual(values = c("1"="blue", "0"="", "-1"="red"), guide=FALSE) +
  scale_fill_manual(values = c("1"="blue", "0"="black", "-1"="red"), guide=FALSE) +
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,30, by = 5)), limits = c(0,30)) +
  scale_x_discrete(labels=c("CS+", "CS-", "Baseline")) + 
  theme_bw() +
  theme(aspect.ratio = 1.7/1,
        plot.margin = unit(c(1, 1, 1.2, 1), units = "cm"),
        plot.title = element_text(hjust = 0.5),
        plot.caption = element_text(hjust = 0.5),
        panel.grid.major.x = element_blank(), #element_line(size=.2, color="lightgrey") ,
        panel.grid.major.y = element_line(size=.2, color="lightgrey") ,
        axis.text.x =  element_text(size=12,  colour = "black"), #element_blank(), #element_text(size=10,  colour = "black", vjust = 0.5),
        axis.text.y = element_text(size=10,  colour = "black"),
        axis.title.x =  element_text(size=16), 
        axis.title.y = element_text(size=16),  
        axis.line.x = element_blank(),
        legend.title=element_blank(),
        strip.background = element_rect(fill="white"))+ 
  labs(x = "Pavlovian Stimulus", y =  "Number of Grips", title = "",
       caption = "Error bar represent \u00B1 SE for the model estimated means\n") #Solution

plot(plot)

cairo_pdf(file.path(figures_path,paste(task, 'cond&grips.pdf',  sep = "_")),
          width     = 5.5,
          height    = 6)

plot(plot)
dev.off()


### PLOT  Trial by trial -----------

df <- summarySE(RIM, measurevar="n_grips", groupvars=c("id", "trial"))
dfRIM <- summarySEwithin(df,measurevar = "n_grips",withinvars = c("trial"), idvar = "id")
dfRIM$Task_Name <- paste0("Reminder")
dfRIM$condition <- paste0("-2")

df <- summarySE(PE, measurevar="n_grips", groupvars=c("id", "trial"))
dfPE <- summarySEwithin(df, measurevar = "n_grips", withinvars = c("trial"),idvar = "id")
dfPE$Task_Name <- paste0("Partial Extinction")
dfPE$condition <- paste0("-3")

newdf <- rbind(dfRIM, dfPE)
newdf$trial = as.numeric(newdf$trial)
df <- summarySE(PIT, measurevar="n_grips", groupvars=c("id", "trialxcondition", "condition"))
dfPIT <- summarySEwithin(df,measurevar = "n_grips",withinvars = c("condition", "trialxcondition"),  idvar = "id")
dfPIT$trial =as.numeric(dfPIT$trialxcondition) +9
#dodge only for CS- and Baseline
for (i in  1:length(dfPIT$trial)) {
  if(dfPIT$condition[i] == -1) {
    dfPIT$trial[i] = dfPIT$trial[i] + 0.15
  }
  else if(dfPIT$condition[i] == 0) {
    dfPIT$trial[i] = dfPIT$trial[i] - 0.15
  }
}
dfPIT$Task_Name <- paste0("PIT")
dfPIT = select(dfPIT, c( 'trial', 'N' , 'n_grips', 'sd', 'se', 'ci', 'Task_Name', 'condition'))

df <- rbind(newdf, dfPIT)
df$condition = as.factor(df$condition)

df$condition = factor(df$condition,levels(df$condition)[c(2,3,5,1,4)])

plotTRIAL = ggplot(df, aes(x = trial, y = n_grips, linetype=Task_Name, color = condition)) +
  geom_line(alpha = .7, size = 1, show.legend = F) +
  geom_errorbar(aes(ymax = n_grips + se, ymin = n_grips - se), width=0.7, alpha=0.7, size=0.4, linetype='dashed')+ 
  geom_point(color = 'grey40') +
  scale_color_manual(labels = c('Reminder', 'Partial Extinction', 'CS+', 'CS-', 'Baseline'), values = c("-2"="grey40", "-3"="grey20", "-1" ="red", "0"='black', '1'="blue")) +
  scale_y_continuous(expand = c(0, 0),  limits = c(4,16), breaks = c(seq.int(4,16, by = 2))) + 
  scale_x_continuous(expand = c(0, 0), limits = c(0 ,24.5), breaks=c(seq.int(1,24, by = 1)))+ 
  scale_linetype_manual(values = c("Reminder"="dashed", "Partial Extinction"="dotdash", "PIT" ="solid"))+
  guides(color = guide_legend(override.aes = list(linetype = c(2, 4, 1, 1, 1) ) ) ) +
  theme_bw() +
  theme(aspect.ratio = 1/1.7,
      plot.margin = unit(c(1, 1, 1.2, 1), units = "cm"),
      plot.title = element_text(hjust = 0.5),
      plot.caption = element_text(hjust = 0.5),
      panel.grid.major.x = element_blank(), #element_line(size=.2, color="lightgrey") ,
      panel.grid.major.y = element_line(size=.2, color="lightgrey") ,
      axis.text.x =  element_text(size=8,  colour = "black"), #element_blank(), #element_text(size=10,  colour = "black", vjust = 0.5),
      axis.text.y = element_text(size=10,  colour = "black"),
      axis.title.x =  element_text(size=16), 
      axis.title.y = element_text(size=16),  
      axis.line.x = element_blank(),
      legend.position = c(0.9, 0.87), 
      legend.text=element_text(size=5),  
      legend.key.size = unit(0.005, "cm"),
      legend.key.width = unit(1, "line"),
      legend.title=element_blank(),
      strip.background = element_rect(fill="white"))+ 
  labs(x = "Trial", y =  "Number of Grips", title = "") #Solution


plot(plotTRIAL)

cairo_pdf(file.path(figures_path,paste(task, 'trial&grips.pdf',  sep = "_")),
          width     = 6,
          height    = 5.5)

plot(plotTRIAL)
dev.off()
#everything below is not so interesting



# 
# # PLOTS
# PIT$Condition[PIT$condition== 'CSplus']     <- 'CS+'
# PIT$Condition[PIT$condition== 'CSminus']     <- 'CS-'
# PIT$Condition[PIT$condition== 'Baseline']     <- 'Baseline'
# 
# PIT$Condition <- as.factor(PIT$Condition)
# PIT$trialxcondition <- as.factor(PIT$trialxccondition)
# # # FUNCTIONS -------------------------------------------------------------
# 
# 
# ggplotRegression <- function (fit) {
#   
#   ggplot(fit$model, aes_string(x = names(fit$model)[2], y = names(fit$model)[1])) + 
#     geom_point() +
#     stat_smooth(method = "lm", col = "red") +
#     labs(title = paste("Adj R2 = ",signif(summary(fit)$adj.r.squared, 5),
#                        "Intercept =",signif(fit$coef[[1]],5 ),
#                        " Slope =",signif(fit$coef[[2]], 5),
#                        " P =",signif(summary(fit)$coef[2,4], 5)))
# }
# 
# 
# 
# # cleaning ----------------------------------------------------------------
# 
# 
# ## plot overall effect
# # get means by trialxcondition
# RIM.bt = ddply(RIM, .(trial), summarise,  n_grips = mean(n_grips, na.rm = TRUE)) 
# PE.bt = ddply(PE, .(trial), summarise,  n_grips = mean(n_grips, na.rm = TRUE)) 
# PIT.bt = ddply(PIT, .(trialxcondition), summarise,  n_grips = mean(n_grips, na.rm = TRUE)) 
# 
# # get means by condition
# PIT.bc = ddply(PIT, .(condition), summarise,  n_grips = mean(n_grips, na.rm = TRUE)) 
# 
# # get means by trial & condition
# PIT.bct = ddply(PIT, .(trialxcondition, condition), summarise,  n_grips = mean(n_grips, na.rm = TRUE)) 
# 
# # get means by participant 
# RIM.bs = ddply(RIM, .(id, trial), summarise, n_grips = mean(n_grips, na.rm = TRUE)) #not condition
# PE.bs = ddply(PE, .(id, trial), summarise, n_grips = mean(n_grips, na.rm = TRUE)) #not condition
# PIT.bs = ddply(PIT, .(id, Condition), summarise, n_grips = mean(n_grips, na.rm = TRUE)) 
# 
# 
# 
# # PLOTS -------------------------------------------------------------------
# 
# 
# 
# ##plot n_grips to see the trajectory of learning (overall average by trials) by conditions
# 
# df <- summarySE(PIT, measurevar="n_grips", groupvars=c("id", "trialxcondition", "Condition"))
# 
# dfPIT <- summarySEwithin(df,
#                          measurevar = "n_grips",
#                          withinvars = c("Condition", "trialxcondition"), 
#                          idvar = "id")
# 
# 
# dfPIT$Condition = factor(dfPIT$Condition,levels(dfPIT$Condition)[c(3,2,1)])
# dfPIT$trialxcondition =as.numeric(dfPIT$trialxcondition)
# 
# 
# ggplot(dfPIT, aes(x = trialxcondition, y = n_grips, color=Condition)) +
#   geom_point(position = position_dodge(width = 0.5)) +
#   geom_line(alpha = .7, size = 1, position = position_dodge(width = 0.5)) +
#   geom_errorbar(aes(ymax = n_grips + se, ymin = n_grips - se), width=0.5, alpha=0.7, size=0.4,position = position_dodge(width = 0.5))+
#   scale_colour_manual(values = c("CS+"="blue", "CS-"="red", "Baseline"="black")) +
#   scale_y_continuous(expand = c(0, 0),  limits = c(4.0,16)) +  #breaks = c(4.0, seq.int(5,16, by = 2.5)),
#   scale_x_continuous(expand = c(0, 0), limits = c(-10 ,16), breaks=c(-10,seq.int(-9,15, by = 2),16))+ 
#   theme_classic() +
#   theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"), axis.title.x = element_text(size=16), 
#         axis.title.y = element_text(size=16), legend.position = c(0.9, 0.9), legend.title=element_blank()) +
#   labs(x = "Trials",y = "Number of Squeezes")
# 
# 
# 
# # summarySE provides the standard deviation, standard error of the mean, and a (default 95%) confidence interval
# 
# df <- summarySE(PIT, measurevar="n_grips", groupvars=c("id", "Condition"))
# 
# dfPIT2 <- summarySEwithin(df,
#                           measurevar = "n_grips",
#                           withinvars = c("Condition"), 
#                           idvar = "id")
# 
# 
# 
# dfPIT2$Condition = factor(dfPIT2$Condition,levels(dfPIT2$Condition)[c(3,2,1)])
# PIT.bs$Condition = factor(PIT.bs$Condition,levels(PIT.bs$Condition)[c(3,2,1)])  
# 
# # ggplot(PIT.bs, aes(x = Condition, y = n_grips, fill = Condition)) +
# # geom_jitter(width = 0.02, color="black",alpha=0.5, size = 0.5) +
# # geom_bar(data=dfPIT2, stat="identity", alpha=0.6, width=0.35) +
# # scale_fill_manual("legend", values = c("CS+"="blue", "CS-"="red", "Baseline"="black")) +
# # geom_line(aes(x=Condition, y=n_grips, group=id), col="grey", alpha=0.4) +
# # geom_errorbar(data=dfPIT2, aes(x = Condition, ymax = n_grips + se, ymin = n_grips - se), width=0.07, colour="black", alpha=1, size=0.4)+
# # scale_y_continuous(expand = c(0, 0), breaks = c(-1, seq.int(0,30, by = 5)), limits = c(-1,30)) +
# # theme_classic() +
# # theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"),  axis.title.x = element_text(size=16), axis.text.x = element_text(size=12),
# #       axis.title.y = element_text(size=16), legend.position = "none", axis.ticks.x = element_blank(), axis.line.x = element_line(color = "white")) +
# # labs(
# #   x = "Pavlovian Stimulus",
# #   y = "Number of Squeezes"
# # )
# 
# 
# 
# source('~/REWOD/CODE/ANALYSIS/BEHAV/my_tools/rainclouds.R')
# 
# ggplot(PIT.bs, aes(x = Condition, y = n_grips, fill = Condition)) +
#   geom_jitter(width = 0.02, color="black",alpha=0.5, size = 0.5) +
#   geom_flat_violin(alpha = .5, position = position_nudge(x = .25, y = 0), adjust = 1.5, trim = F, color = NA) + 
#   geom_bar(data=dfPIT2, stat="identity", alpha=0.6, width=0.35) +
#   scale_fill_manual("legend", values = c("CS+"="blue", "CS-"="red", "Baseline"="black")) +
#   geom_line(aes(x=Condition, y=n_grips, group=id), col="grey", alpha=0.4) +
#   geom_errorbar(data=dfPIT2, aes(x = Condition, ymax = n_grips + se, ymin = n_grips - se), width=0.07, colour="black", alpha=1, size=0.4)+
#   scale_y_continuous(expand = c(0, 0), breaks = c( seq.int(0,30, by = 5)), limits = c(-0.1,30)) +
#   theme_classic() +
#   theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"),  axis.title.x = element_text(size=16), axis.text.x = element_text(size=12),
#         axis.title.y = element_text(size=16), legend.position = "none", axis.ticks.x = element_blank(), axis.line.x = element_line(color = "white")) +
#   labs(
#     x = "Pavlovian Stimulus",
#     y = "Number of Squeezes"
#   )
# 
# # ANALYSIS
