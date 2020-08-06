## R code for FOR HED PLOT
## last modified on April 2020 by David MUNOZ TORD

# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, dplyr, plyr, lme4, car, afex, r2glmm, optimx, sjPlot, emmeans, visreg, RNOmni, jtools, interactions, sjstats, Rmisc)

# SETUP ------------------------------------------------------------------

task = 'HED'

# Set working directory
analysis_path <- file.path('~/REWOD/DERIVATIVES/BEHAV', task) 
figures_path  <- file.path('~/REWOD/DERIVATIVES/FIGURES/BEHAV') 
setwd(analysis_path)


## LOADING AND INSPECTING THE DATA
load('HED.RData')

#set "better" lmer optimizer #nolimit # yoloptimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

mod = lmer(perceived_liking ~ condition * intC + (condition * intC|id) + (condition |trialxcondition), data = HED, control = control, REML = FALSE)


# PLOT --------------------------------------------------------------------
source('~/REWOD/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R')

#increase repetitions limit
emm_options(pbkrtest.limit = 5000)
emm_options(lmerTest.limit = 5000)

#get contrasts and means for MAIN PLOT
CI_lik = confint(emmeans(mod, pairwise~ condition, adjust = "tukey"),level = 0.95,method = c("boot"),nsim = 5000)

df.predicted = data.frame(CI_lik$emmeans)

#get predicted by ind
rand = ranef(mod)
ran = data.frame(rand$id)
fix = t(data.frame(fixef(mod)))
df = ran + fix[col(ran)]
df$reward = df$X.Intercept.
df$neutral = df$reward + df$condition0
df$empty = df$reward + df$condition.1
df = select(df, c(reward,empty, neutral))
df$id = as.factor(c(1:length(df$neutral)))
df.observed <- gather(df, condition, emmean, reward:neutral, factor_key=TRUE)
#df.observed = ddply(HED, .(id, trial, condition), summarise, emmean = mean(perceived_liking, na.rm = TRUE)) 

df.observed$condition = as.factor(revalue(df.observed$condition, c(empty="-1", neutral="0",reward="1")))
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
  scale_color_manual(values = c("1"="blue", "0"="red", "-1"="black"), guide=FALSE) +
  scale_fill_manual(values = c("1"="blue", "0"="red", "-1"="black"), guide=FALSE) +
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 20)), limits = c(0,100)) +
  scale_x_discrete(labels=c("Reward", "Neutral", "Control")) + 
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
  labs(x = "Odor Stimulus", y =  "Pleasantness Ratings", title = "",
       caption = "Error bar represent \u00B1 SE for the model estimated means\n") #Solution

plot(plot)

cairo_pdf(file.path(figures_path,paste(task, 'cond&pleas.pdf',  sep = "_")),
          width     = 5.5,
          height    = 6)

plot(plot)
dev.off()


### PLOT  Trial by trial -----------
df <- summarySE(HED, measurevar="perceived_liking", groupvars=c("id", "trialxcondition", "condition"))

dfLIK <- summarySEwithin(df,
                         measurevar = "perceived_liking",
                         withinvars = c("condition", "trialxcondition"), 
                         idvar = "id")

dfLIK$condition = factor(dfLIK$condition,levels(dfLIK$condition)[c(1,3,2)])
dfLIK$trialxcondition =as.numeric(dfLIK$trialxcondition)


ggplot(dfLIK, aes(x = trialxcondition, y = perceived_liking, color=condition)) +
  geom_line(alpha = .7, size = 1, position =position_dodge(width = 0.5)) +
  geom_point(position =position_dodge(width = 0.5)) +
  geom_errorbar(aes(ymax = perceived_liking +se, ymin = perceived_liking -se), width=0.5, alpha=0.7, size=0.4, position = position_dodge(width = 0.5))+
  scale_colour_manual(values = c("1"="blue", "0"="red", "-1"="black"),labels=c("Reward", "Neutral", "Control")) +
  scale_y_continuous(expand = c(0, 0),  limits = c(40,80),  breaks=c(seq.int(40,80, by = 5))) +  #breaks = c(4.0, seq.int(5,16, by = 2.5)),
  scale_x_continuous(expand = c(0, 0), limits = c(0,18.5), breaks=c(seq.int(1,18, by = 1)))+ 
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"), axis.title.x = element_text(size=16),
        axis.title.y = element_text(size=16), legend.position = c(0.9, 0.9), legend.title=element_blank()) +
  labs(x = "Trials",y = "Pleasantness Ratings")

#The End, thanks Yoann


#everything below is not so interesting


# 
# 
# 
# ggplot(df.observed.jit, aes(x = condition, y = emmean, fill = condition)) +
#   geom_jitter(width = 0.02, color="black",alpha=0.5, size = 0.5) +
#   geom_bar(data=df.predicted.jit, stat="identity", alpha=0.6, width=0.35, position = position_dodge(width = 0.01)) +
#   geom_flat_violin(alpha = .5, position = position_nudge(x = .25, y = 0), adjust = 1.5, trim = F, color = NA) + 
#   scale_fill_manual("legend", values = c('1'="blue", '0'="red", '-1'="black")) +
#   geom_line(aes(x=condition, y=emmean, group=id), col="grey", alpha=0.4) +
#   geom_errorbar(data=df.predicted.jit, aes(x = condition, ymax = emmean + se, ymin = emmean - se), width=0.1, colour="black", alpha=1, size=0.4)+
#   scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 20)), limits = c(0,100)) +
#   theme_classic() +
#   theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"),  axis.title.x = element_text(size=16), axis.text.x = element_text(size=12),
#         axis.title.y = element_text(size=16), legend.position = "none", axis.ticks.x = element_blank(), axis.line.x = element_line(color = "white")) +
#   labs(
#     x = "Odor Stimulus",
#     y = "Plesantness Ratings"
#   )
# 
# HED$condition[HED$condition== 'chocolate']     <- 'Reward'
# HED$condition[HED$condition== 'empty']     <- 'Control'
# HED$condition[HED$condition== 'neutral']     <- 'Neutral'
# 
# ggplotRegression <- function (fit) {
#   
#   ggplot(fit$model, aes_string(x = names(fit$model)[2], y = names(fit$model)[1])) + 
#     geom_point() +
#     stat_smooth(method = "lm", col = "red") +
#     labs(title = paste("Rˆ2* = ",signif(summary(fit)$adj.r.squared, 5),
#                        " P =",signif(summary(fit)$coef[2,4], 5)))
# }
# 
# data_summary <- function(data, varname, groupnames){
#   require(plyr)
#   summary_func <- function(x, col){
#     c(mean = mean(x[[col]], na.rm=TRUE),
#       sd = sd(x[[col]], na.rm=TRUE))
#   }
#   data_sum<-ddply(data, groupnames, .fun=summary_func,
#                   varname)
#   data_sum <- rename(data_sum, c("mean" = varname))
#   return(data_sum)
# }
# 
# 
# 
# 
# 
# 
# #### INTENSITY
# df <- summarySE(HED, measurevar="perceived_intensity", groupvars=c("id", "trialxcondition", "condition"))
# 
# dfINT <- summarySEwithin(df,
#                          measurevar = "perceived_intensity",
#                          withinvars = c("condition", "trialxcondition"), 
#                          idvar = "id")
# 
# dfINT$condition = as.factor(dfINT$condition)
# dfINT$condition = factor(dfINT$condition,levels(dfINT$condition)[c(3,2,1)])
# dfINT$trialxcondition =as.numeric(dfINT$trialxcondition)
# 
# 
# ggplot(dfINT, aes(x = trialxcondition, y = perceived_intensity, color=condition)) +
#   geom_line(alpha = .7, size = 1, position =position_dodge(width = 0.5)) +
#   geom_point(position =position_dodge(width = 0.5)) +
#   geom_errorbar(aes(ymax = perceived_intensity +se, ymin = perceived_intensity -se), width=0.5, alpha=0.7, size=0.4, position = position_dodge(width = 0.5))+
#   scale_colour_manual(values = c("Reward"="blue", "Neutral"="red", "Control"="black")) +
#   scale_y_continuous(expand = c(0, 0),  limits = c(10,80),  breaks=c(seq.int(10,80, by = 5))) +  #breaks = c(4.0, seq.int(5,16, by = 2.5)),
#   #scale_x_continuous(expand = c(0, 0), limits = c(0,19), breaks=c(0, seq.int(1,18, by = 2),19))+ 
#   theme_classic() +
#   theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"), axis.title.x = element_text(size=16),
#         axis.title.y = element_text(size=16), legend.position = c(0.9, 0.9), legend.title=element_blank()) +
#   labs(x = "Trials",y = "Intensity Ratings")
# 
# 
# #### EMG
# HED$EMG                        <- zscore(HED$EMG)
# #df <- summarySE(HED, measurevar="EMG", groupvars=c("id", "trialxcondition", "condition"))
# 
# dfEMG <- summarySEwithin(HED,
#                          measurevar = "EMG",
#                          withinvars = c("condition", "trialxcondition"), 
#                          idvar = "id")
# 
# dfEMG$condition = as.factor(dfEMG$condition)
# dfEMG$condition = factor(dfEMG$condition,levels(dfEMG$condition)[c(3,2,1)])
# dfEMG$trialxcondition =as.numeric(dfEMG$trialxcondition)
# 
# 
# ggplot(dfEMG, aes(x = trialxcondition, y = EMG, color=condition)) +
#   geom_line(alpha = .7, size = 1, position =position_dodge(width = 0.5)) +
#   geom_point(position =position_dodge(width = 0.5)) +
#   #geom_ribbon(aes(ymax = EMG +se, ymin = EMG -se), fill = "grey", alpha=0.01, color = 'grey") +
#   geom_errorbar(aes(ymax = EMG +se, ymin = EMG -se), width=0.5, alpha=0.7, size=0.4, position = position_dodge(width = 0.5))+
#   scale_colour_manual(values = c("Reward"="blue", "Neutral"="red", "Control"="black")) +
#   #scale_y_continuous(expand = c(0, 0),  limits = c(10,80),  breaks=c(seq.int(10,80, by = 5))) +  #breaks = c(4.0, seq.int(5,16, by = 2.5)),
#   #scale_x_continuous(expand = c(0, 0), limits = c(0,19), breaks=c(0, seq.int(1,18, by = 2),19))+ 
#   theme_classic() +
#   theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"), axis.title.x = element_text(size=16),
#         axis.title.y = element_text(size=16), legend.position = c(0.9, 0.9), legend.title=element_blank()) +
#   labs(x = "Trials",y = "EMG cor")
# 
# ####Corr COR & LIK
# 
# 
# dfEMG$perceived_liking = dfLIK$perceived_liking
# df = ddply(HED, .(id, condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE),  EMG = mean(EMG, na.rm = TRUE)) 
# # 
# # df = dfEMG
# 
# ggplot(df, aes(x = perceived_liking, y = EMG, color=condition)) +
#   #geom_line(alpha = .7, size = 1, position =position_dodge(width = 0.5)) +
#   geom_point() +
#   theme_classic() +
#   theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"), axis.title.x = element_text(size=16),
#         axis.title.y = element_text(size=16),  legend.title=element_blank())
# 
# dfR <- filter(df,  condition == "Reward")
# dfN <- filter(df,  condition == "Neutral")
# dfC <- filter(df,  condition == "Control")
# 
# 
# cor.test(dfR$EMG,dfR$perceived_liking)  
# cor.test(dfN$EMG,dfN$perceived_liking)  
# cor.test(dfC$EMG,dfC$perceived_liking)  
# 
# bsEMG2 = ddply(HED, .(id), summarise, EMG = mean(EMG, na.rm = TRUE), EMG = mean(EMG, na.rm = TRUE))
# Boxplot(~EMG, data= bsEMG2, id=TRUE) # across conditions
# Boxplot(~EMG, data= dfR, id=TRUE) # for REW
# Boxplot(~EMG, data= dfN, id=TRUE) # for NEU
# Boxplot(~EMG, data= dfC, id=TRUE) # for CON
# 
# 
# 
# # corre <- rmcorr(id, perceived_liking, EMG, HED, CIs = c("analytic",
# #                                                      "bootstrap"), nreps = 100, bstrap.out = F)
# 
# 
# # x = HED$perceived_liking[HED$condition2 == 'Reward']
# # y = HED$perceived_liking[HED$condition2 == 'NoReward']
# # #Compute Leven test for homgeneity of variance
# # leveneTest(HED$perceived_liking ~ HED$condition)
# # 
# # Dummy <- data.frame(numbers = 1:432)
# # Dummy2 <- data.frame(numbers = 1:864)
# # Dummy$'Reward pleasantness ratings' =  x
# # Dummy2$'No Reward pleasantness ratings' =  y
# # 
# # 
# # 
# # 
# # ggplot(Dummy, aes('Reward pleasantness ratings')) +
# # geom_density() + 
# # theme_classic() +
# # theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), legend.position = "none", panel.grid.minor = element_blank(),
# #         panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)
# # 
# # d <- density(Dummy$'Reward pleasantness ratings' ) + theme_classic() +
# #   theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), legend.position = "none", panel.grid.minor = element_blank(),
# #         panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)
# # 
# # plot(d)
# # 
# # 
# # 
# # # plot densities
# # sm.density.compare(HED$perceived_liking, HED$condition,  xlab="Pleasantness ratings")
# # 
# # 
# # # add legend via mouse click
# # colfill<-c(2:(2+length(levels(HED$condition))))
# # legend(locator(1), levels(HED$condition), fill=colfill)
# # 
# # df <- summarySE(HED, measurevar="perceived_liking", groupvars=c("id", "condition"))
# # 
# # # inspecting variance  control ###
# # 
# # REWOD_check<- filter(HED,  id != "3" & id !='4' & id !='13' & id != '20' & id != '23')
# # 
# # 
# # # plot densities
# # sm.density.compare(REWOD_check$perceived_liking, REWOD_check$condition,  xlab="Pleasantness ratings")
# # colfill<-c(2:(2+length(levels(REWOD_check$condition))))
# # legend(locator(1), levels(REWOD_check$condition), fill=colfill)
# # 
# # df2 <- summarySE(REWOD_check, measurevar="perceived_liking", groupvars=c("id", "condition"))
# # 
# # 
# # dfLIK3 <- summarySEwithin(df2,
# #                           measurevar = "perceived_liking",
# #                           withinvars = c("condition"), 
# #                           idvar = "id")
# # 
# # dfLIK3 <- summarySEwithin(df2,
# #                           measurevar = "perceived_liking",
# #                           withinvars = c("condition"), 
# #                           idvar = "id")
# # 
# # # get means by participant 
# # bs2 = ddply(REWOD_check, .(id, trialxcondition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE))
# # bsLIK2 = ddply(REWOD_check, .(id, condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE))
# # 
# # 
# # 
# # dfLIK3$condition <- as.factor(dfLIK3$condition)
# # bsLIK2$condition <- as.factor(bsLIK2$condition)
# # 
# # dfLIK3$condition = factor(dfLIK2$condition,levels(dfLIK3$condition)[c(3,2,1)])
# # bsLIK2$condition = factor(bsLIK$condition,levels(bsLIK2$condition)[c(3,2,1)])  
# # 
# # ggplot(bsLIK2, aes(x = condition, y = perceived_liking, fill = condition)) +
# #   geom_jitter(width = 0.02, color="black",alpha=0.5, size = 0.5) +
# #   geom_bar(data=dfLIK3, stat="identity", alpha=0.6, width=0.35, position = position_dodge(width = 0.01)) +
# #   geom_flat_violin(alpha = .5, position = position_nudge(x = .25, y = 0), adjust = 1.5, trim = F, color = NA) + 
# #   scale_fill_manual("legend", values = c("Reward"="blue", "Neutral"="red", "Control"="black")) +
# #   geom_line(aes(x=condition, y=perceived_liking, group=id), col="grey", alpha=0.4) +
# #   geom_errorbar(data=dfLIK3, aes(x = condition, ymax = perceived_liking + se, ymin = perceived_liking - se), width=0.1, colour="black", alpha=1, size=0.4)+
# #   scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 20)), limits = c(0,100)) +
# #   theme_classic() +
# #   theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"),  axis.title.x = element_text(size=16), axis.text.x = element_text(size=12),
# #         axis.title.y = element_text(size=16), legend.position = "none", axis.ticks.x = element_blank(), axis.line.x = element_line(color = "white")) +
# #   labs(
# #     x = "Odor Stimulus",
# #     y = "Plesantness Ratings"
# #   )
# # 
# # 
# # # inspecting variance NEUTRAL ###
# # 
# # REWOD_check<- filter(HED,  id != "23" )
# # 
# # 
# # # plot densities
# # sm.density.compare(REWOD_check$perceived_liking, REWOD_check$condition,  xlab="Pleasantness ratings")
# # colfill<-c(2:(2+length(levels(REWOD_check$condition))))
# # legend(locator(1), levels(REWOD_check$condition), fill=colfill)
# # 
# # df2 <- summarySE(REWOD_check, measurevar="perceived_liking", groupvars=c("id", "condition"))
# # 
# # 
# # dfLIK3 <- summarySEwithin(df2,
# #                           measurevar = "perceived_liking",
# #                           withinvars = c("condition"), 
# #                           idvar = "id")
# # 
# # dfLIK3 <- summarySEwithin(df2,
# #                           measurevar = "perceived_liking",
# #                           withinvars = c("condition"), 
# #                           idvar = "id")
# # 
# # # get means by participant 
# # bs2 = ddply(REWOD_check, .(id, trialxcondition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE))
# # bsLIK2 = ddply(REWOD_check, .(id, condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE))
# # 
# # 
# # 
# # dfLIK3$condition <- as.factor(dfLIK3$condition)
# # bsLIK2$condition <- as.factor(bsLIK2$condition)
# # 
# # dfLIK3$condition = factor(dfLIK2$condition,levels(dfLIK3$condition)[c(3,2,1)])
# # bsLIK2$condition = factor(bsLIK$condition,levels(bsLIK2$condition)[c(3,2,1)])  
# # 
# # ggplot(bsLIK2, aes(x = condition, y = perceived_liking, fill = condition)) +
# #   geom_jitter(width = 0.02, color="black",alpha=0.5, size = 0.5) +
# #   geom_bar(data=dfLIK3, stat="identity", alpha=0.6, width=0.35, position = position_dodge(width = 0.01)) +
# #   geom_flat_violin(alpha = .5, position = position_nudge(x = .25, y = 0), adjust = 1.5, trim = F, color = NA) + 
# #   scale_fill_manual("legend", values = c("Reward"="blue", "Neutral"="red", "Control"="black")) +
# #   geom_line(aes(x=condition, y=perceived_liking, group=id), col="grey", alpha=0.4) +
# #   geom_errorbar(data=dfLIK3, aes(x = condition, ymax = perceived_liking + se, ymin = perceived_liking - se), width=0.1, colour="black", alpha=1, size=0.4)+
# #   scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 20)), limits = c(0,100)) +
# #   theme_classic() +
# #   theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"),  axis.title.x = element_text(size=16), axis.text.x = element_text(size=12),
# #         axis.title.y = element_text(size=16), legend.position = "none", axis.ticks.x = element_blank(), axis.line.x = element_line(color = "white")) +
# #   labs(
# #     x = "Odor Stimulus",
# #     y = "Plesantness Ratings"
# #   )
# 
# 
# 
# #ratings
# 
# 
# dfLIK2 <- summarySEwithin(df,
#                           measurevar = "perceived_liking",
#                           withinvars = c("condition"), 
#                           idvar = "id")
# 
# dfLIK2 <- summarySEwithin(df,
#                           measurevar = "perceived_liking",
#                           withinvars = c("condition"), 
#                           idvar = "id")
# 
# 
# dfLIK2$condition <- as.factor(dfLIK2$condition)
# bsLIK$condition <- as.factor(bsLIK$condition)
# 
# dfLIK2$condition = factor(dfLIK2$condition,levels(dfLIK2$condition)[c(3,2,1)])
# bsLIK$condition = factor(bsLIK$condition,levels(bsLIK$condition)[c(3,2,1)])  
# 
# # ggplot(bsLIK, aes(x = condition, y = perceived_liking, fill = condition)) +
# #   geom_jitter(width = 0.02, color="black",alpha=0.5, size = 0.5) +
# #   geom_bar(data=dfLIK2, stat="identity", alpha=0.6, width=0.35, position = position_dodge(width = 0.01)) +
# #   scale_fill_manual("legend", values = c("Reward"="blue", "Neutral"="red", "Control"="black")) +
# #   geom_line(aes(x=condition, y=perceived_liking, group=id), col="grey", alpha=0.4) +
# #   geom_errorbar(data=dfLIK2, aes(x = condition, ymax = perceived_liking + se, ymin = perceived_liking - se), width=0.1, colour="black", alpha=1, size=0.4)+
# #   scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 20)), limits = c(0,100)) +
# #   theme_classic() +
# #   theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"),  axis.title.x = element_text(size=16), axis.text.x = element_text(size=12),
# #         axis.title.y = element_text(size=16), legend.position = "none", axis.ticks.x = element_blank(), axis.line.x = element_line(color = "white")) +
# #   labs(
# #     x = "Odor Stimulus",
# #     y = "Plesantness Ratings"
# #   )
# 
# 
# # ggplot(bsLIK, aes(x = condition, y = perceived_liking, fill = condition)) +
# #   geom_jitter(width = 0.02, color="black",alpha=0.5, size = 0.5) +
# #   geom_bar(data=dfLIK2, stat="identity", alpha=0.6, width=0.35, position = position_dodge(width = 0.01)) +
# #   scale_fill_manual("legend", values = c("Reward"="blue", "Neutral"="red", "Control"="black")) +
# #   geom_line(aes(x=condition, y=perceived_liking, group=id), col="grey", alpha=0.4) +
# #   geom_errorbar(data=dfLIK2, aes(x = condition, ymax = perceived_liking + se, ymin = perceived_liking - se), width=0.1, colour="black", alpha=1, size=0.4)+
# #   scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 20)), limits = c(0,100)) +
# #   theme_classic() +
# #   theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"),  axis.title.x = element_text(size=16), axis.text.x = element_text(size=12),
# #         axis.title.y = element_text(size=16), legend.position = "none", axis.ticks.x = element_blank(), axis.line.x = element_line(color = "white")) +
# #   labs(
# #     x = "Odor Stimulus",
# #     y = "Plesantness Ratings"
# #   )
# 
# 
# 
# 
# ggplot(bsLIK, aes(x = condition, y = perceived_liking, fill = condition)) +
#   geom_jitter(width = 0.02, color="black",alpha=0.5, size = 0.5) +
#   geom_bar(data=dfLIK2, stat="identity", alpha=0.6, width=0.35, position = position_dodge(width = 0.01)) +
#   geom_flat_violin(alpha = .5, position = position_nudge(x = .25, y = 0), adjust = 1.5, trim = F, color = NA) + 
#   scale_fill_manual("legend", values = c("Reward"="blue", "Neutral"="red", "Control"="black")) +
#   geom_line(aes(x=condition, y=perceived_liking, group=id), col="grey", alpha=0.4) +
#   geom_errorbar(data=dfLIK2, aes(x = condition, ymax = perceived_liking + se, ymin = perceived_liking - se), width=0.1, colour="black", alpha=1, size=0.4)+
#   scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 20)), limits = c(0,100)) +
#   theme_classic() +
#   theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"),  axis.title.x = element_text(size=16), axis.text.x = element_text(size=12),
#         axis.title.y = element_text(size=16), legend.position = "none", axis.ticks.x = element_blank(), axis.line.x = element_line(color = "white")) +
#   labs(
#     x = "Odor Stimulus",
#     y = "Plesantness Ratings"
#   )
# 
# #EMG - Physio
# 
# dfEMG2 <- summarySEwithin(df,
#                           measurevar = "EMG",
#                           withinvars = c("condition"), 
#                           idvar = "id")
# 
# dfEMG2 <- summarySEwithin(df,
#                           measurevar = "EMG",
#                           withinvars = c("condition"), 
#                           idvar = "id")
# 
# 
# dfEMG2$condition <- as.factor(dfEMG2$condition)
# bsEMG$condition <- as.factor(bsEMG$condition)
# 
# dfEMG2$condition = factor(dfEMG2$condition,levels(dfEMG2$condition)[c(3,2,1)])
# bsEMG$condition = factor(bsEMG$condition,levels(bsEMG$condition)[c(3,2,1)])  
# 
# 
# ggplot(bsEMG, aes(x = condition, y = EMG, fill = condition)) +
#   geom_jitter(width = 0.02, color="black",alpha=0.5, size = 0.5) +
#   geom_bar(data=dfEMG2, stat="identity", alpha=0.6, width=0.35, position = position_dodge(width = 0.01)) +
#   geom_flat_violin(alpha = .5, position = position_nudge(x = .25, y = 0), adjust = 1.5, trim = F, color = NA) + 
#   scale_fill_manual("legend", values = c("Reward"="blue", "Neutral"="red", "Control"="black")) +
#   geom_line(aes(x=condition, y=EMG, group=id), col="grey", alpha=0.4) +
#   geom_errorbar(data=dfEMG2, aes(x = condition, ymax = EMG + se, ymin = EMG - se), width=0.1, colour="black", alpha=1, size=0.4)+
#   #scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 20)), limits = c(0,100)) +
#   theme_classic() +
#   theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"),  axis.title.x = element_text(size=16), axis.text.x = element_text(size=12),
#         axis.title.y = element_text(size=16), legend.position = "none", axis.ticks.x = element_blank(), axis.line.x = element_line(color = "white")) +
#   labs(
#     x = "Odor Stimulus",
#     y = "EMG activity Cor"
#   )
# 
