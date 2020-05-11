## R code for FOR OBIWAN_PIT
# last modified on February by Eva

# -----------------------  PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(Rmisc, car, lme4, lmerTest, pbkrtest, ggplot2, dplyr, plyr, tidyr, multcomp, mvoutlier, HH, doBy, psych, pastecs, reshape, reshape2, 
               jtools, effects, compute.es, DescTools, MBESS, afex, ez, metafor, influence.ME)

#nfluence.ME,lmerTest, lme4, MBESS, afex, car, ggplot2, dplyr, plyr, tidyr, reshape, Hmisc, Rmisc,  ggpubr, gridExtra, plotrix, lsmeans, BayesFactor)

#SETUP
task = 'HED'

# Set working directory
analysis_path <- file.path('~/OBIWAN/DERIVATIVES/BEHAV') 
setwd(analysis_path)

figures_path  <- file.path('~/OBIWAN/DERIVATIVES/FIGURES/BEHAV') 


# open dataset
OBIWAN_HED <- read.delim(file.path(analysis_path,'OBIWAN_HEDONIC.txt'), header = T, sep ='') # read in dataset


# define factors
OBIWAN_HED$id      <- factor(OBIWAN_HED$id)
OBIWAN_HED$trial    <- factor(OBIWAN_HED$trial)
OBIWAN_HED$group    <- factor(OBIWAN_HED$group)

OBIWAN_HED$Condition[OBIWAN_HED$condition== 'MilkShake']     <- 'Reward'
OBIWAN_HED$Condition[OBIWAN_HED$condition== 'Empty']     <- 'Control'

OBIWAN_HED$Condition <- factor(OBIWAN_HED$Condition)
OBIWAN_HED$trialxcondition <- factor(OBIWAN_HED$trialxcondition)


OBIWAN_HED  <- subset(OBIWAN_HED, group != 'obese')

# get means by condition 
bt = ddply(OBIWAN_HED, .(trialxcondition), summarise,  perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE)) 
# get means by condition and trialxcondition
btc = ddply(OBIWAN_HED, .(Condition, trialxcondition), summarise,  perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE)) #, EMG = mean(EMG, na.rm = TRUE)) 

# get means by participant 
bsT = ddply(OBIWAN_HED, .(id, trialxcondition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE)) #, EMG = mean(EMG, na.rm = TRUE)) 
bsC= ddply(OBIWAN_HED, .(id, Condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE))
bsTC = ddply(OBIWAN_HED, .(id, trialxcondition, Condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE), perceived_intensity = mean(perceived_intensity, na.rm = TRUE))


# ------------------------------------------ Pleasure  ----------------------------------------------------------


#ratings

dfLIK <- summarySEwithin(bsC,
                          measurevar = "perceived_liking",
                          withinvars = c("Condition"), 
                          idvar = "id")

#bsLIK$Condition <- as.factor(bsLIK$Condition)

dfLIK$Condition = factor(dfLIK$Condition)
#bsLIK$Condition = factor(bsLIK$Condition,levels(bsLIK$Condition)[c(3,2,1)]) 


#rainplot Liking
bsC$Condition <- as.factor(bsC$Condition)
source('~/OBIWAN/CODE/ANALYSIS/BEHAV/R_functions/rainclouds.R')

ggplot(bsC, aes(x = Condition, y = perceived_liking, fill = Condition)) +
  geom_jitter(width = 0.02, color="black",alpha=0.5, size = 0.5) +
  geom_bar(data=dfLIK, stat="identity", alpha=0.6, width=0.35, position = position_dodge(width = 0.01)) +
  geom_flat_violin(alpha = .5, position = position_nudge(x = .25, y = 0), adjust = 1.5, trim = F, color = NA) + 
  scale_fill_manual("legend", values = c("Reward"="blue", "Control"="black")) +
  geom_line(aes(x=Condition, y=perceived_liking, group=id), col="grey", alpha=0.4) +
  geom_errorbar(data=dfLIK, aes(x = Condition, ymax = perceived_liking + se, ymin = perceived_liking - se), width=0.1, colour="black", alpha=1, size=0.4)+
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,100, by = 20)), limits = c(0,100)) +
  theme_classic() +
  theme(plot.margin = unit(c(1, 1, 1, 1), units = "cm"),  axis.title.x = element_text(size=16), axis.text.x = element_text(size=12),
        axis.title.y = element_text(size=16), legend.position = "none", axis.ticks.x = element_blank(), axis.line.x = element_line(color = "white")) +
  labs(
    x = "Taste Stimulus",
    y = "Plesantness Ratings"
  )

#********************************** PLOT 1 main effect by subject
OBIWAN_HED.bs = ddply(OBIWAN_HED, .(id, condition), summarise, perceived_liking = mean(perceived_liking, na.rm = TRUE)) 
bg = ddply(OBIWAN_HED.bs,.(condition),summarise, perceived_liking=mean(perceived_liking))
er   <- ddply(OBIWAN_HED.bs, .(condition), summarise, perceived_liking = sd(perceived_liking)/sqrt(length(perceived_liking)))

ggplot(OBIWAN_HED.bs, aes(x = condition, y = perceived_liking, fill = condition, color = condition)) +
  geom_point(alpha = .5)  +
  geom_bar(data =bg, stat = "identity", width=.9, position = "dodge", alpha = .5, color = NA) +
  geom_errorbar(data = bg, aes(ymin = perceived_liking - er$perceived_liking, ymax = perceived_liking + er$perceived_liking), width = .1) +
  geom_line(aes(group = id), alpha = .2, size = 0.5, color = "gray") +
  theme_bw() +
  labs(
    title = "Hedonicity",
    x = "Trial",
    y = "Liking"
  )

#***************************************** PLOT 2 main effect by trial
OBIWAN_HED.bt   = ddply(OBIWAN_HED, .(trialxcondition, condition), summarise,  perceived_liking = mean(perceived_liking, na.rm = TRUE)) 
er   <- ddply(OBIWAN_HED, .(trialxcondition,condition), summarise, perceived_liking = sd(perceived_liking)/sqrt(length(perceived_liking)))

OBIWAN_HED.bt$trialxcondition <- as.numeric(OBIWAN_HED.bt$trialxcondition)

OBIWAN_HED.bt$min = OBIWAN_HED.bt$perceived_liking - er$perceived_liking
OBIWAN_HED.bt$max  = OBIWAN_HED.bt$perceived_liking + er$perceived_liking

pp <- ggplot(OBIWAN_HED.bt, aes(x = trialxcondition, y = perceived_liking, fill = condition, color = condition)) +
  geom_point()  +
  geom_abline(slope= 0, intercept=50, linetype = "dashed", color = "black") +
  geom_line(aes(group = condition), alpha = 0.9, size = 1) +
  geom_ribbon(aes(ymin=OBIWAN_HED.bt$min, ymax=OBIWAN_HED.bt$max), alpha=0.2, linetype = 0 ) +
  theme_bw() +
  labs(
    title = "Perceived Pleasure",
    x = "Trial",
    y = "Ratings"
  )

ppp <- pp + theme_linedraw(base_size = 12, base_family = "Helvetica")+
  theme(strip.text.x = element_text(size = 12, face = "bold"),
        plot.title = element_text(size = 12, face = "bold", hjust = 0.5),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        axis.line.y = element_line(size = 0.5, linetype = "solid", colour = "#999999"),
        axis.line.x = element_line(size = 0.5, linetype = "solid", colour = "#999999"),
        #legend.position="none",
        legend.text  = element_text(size = 12),
        #axis.ticks.x = element_blank(),
        axis.text.x  = element_text(size = 12),
        axis.title.x = element_text(size = 12, face = "bold", hjust = 0.5),
        axis.title.y = element_text(size = 12, face = "bold", hjust = 0.5))

pdf(file.path(figures_path,'Liking_ratings_control.pdf'))
print(ppp)
dev.off()

#************************************************** test
mdl.liking = lmer(perceived_liking ~ condition*trialxcondition+(condition|id)+ (condition|trialxcondition), data = OBIWAN_HED, REML=FALSE)
anova(mdl.liking)


# ------------------------------------------ Intensity ----------------------------------------------------------


#********************************* PLOT 1 main effect by subject
OBIWAN_HED.bs = ddply(OBIWAN_HED, .(id, condition), summarise, perceived_intensity = mean(perceived_intensity, na.rm = TRUE)) 
bg = ddply(OBIWAN_HED.bs,.(condition),summarise, perceived_intensity=mean(perceived_intensity))
er   <- ddply(OBIWAN_HED.bs, .(condition), summarise, perceived_intensity = sd(perceived_intensity)/sqrt(length(perceived_intensity)))

ggplot(OBIWAN_HED.bs, aes(x = condition, y = perceived_intensity, fill = condition, color = condition)) +
  geom_point(alpha = .5)  +
  geom_bar(data =bg, stat = "identity", width=.9, position = "dodge", alpha = .5, color = NA) +
  geom_errorbar(data = bg, aes(ymin = perceived_intensity - er$perceived_intensity, ymax = perceived_intensity + er$perceived_intensity), width = .1) +
  geom_line(aes(group = id), alpha = .2, size = 0.5, color = "gray") +
  theme_bw() +
  labs(
    title = "Intensity",
    x = "Trial",
    y = "Intensity"
  )

#*********************************  PLOT2 main effect by trial
OBIWAN_HED.bt   = ddply(OBIWAN_HED, .(trialxcondition, condition), summarise,  perceived_intensity = mean(perceived_intensity, na.rm = TRUE)) 
er   <- ddply(OBIWAN_HED, .(trialxcondition,condition), summarise, perceived_intensity = sd(perceived_intensity)/sqrt(length(perceived_intensity)))

OBIWAN_HED.bt$trialxcondition <- as.numeric(OBIWAN_HED.bt$trialxcondition)

OBIWAN_HED.bt$min = OBIWAN_HED.bt$perceived_intensity - er$perceived_intensity
OBIWAN_HED.bt$max  = OBIWAN_HED.bt$perceived_intensity + er$perceived_intensity

pp <- ggplot(OBIWAN_HED.bt, aes(x = trialxcondition, y = perceived_intensity, fill = condition, color = condition)) +
  geom_point()  +
  geom_abline(slope= 0, intercept=50, linetype = "dashed", color = "black") +
  geom_line(aes(group = condition), alpha = 0.9, size = 1) +
  geom_ribbon(aes(ymin=OBIWAN_HED.bt$min, ymax=OBIWAN_HED.bt$max), alpha=0.2, linetype = 0 ) +
  theme_bw() +
  labs(
    title = "Perceived Intensity",
    x = "Trial",
    y = "Ratings"
  )

ppp <- pp + theme_linedraw(base_size = 12, base_family = "Helvetica")+
  theme(strip.text.x = element_text(size = 12, face = "bold"),
        plot.title = element_text(size = 12, face = "bold", hjust = 0.5),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        axis.line.y = element_line(size = 0.5, linetype = "solid", colour = "#999999"),
        axis.line.x = element_line(size = 0.5, linetype = "solid", colour = "#999999"),
        #legend.position="none",
        legend.text  = element_text(size = 12),
        #axis.ticks.x = element_blank(),
        axis.text.x  = element_text(size = 12),
        axis.title.x = element_text(size = 12, face = "bold", hjust = 0.5),
        axis.title.y = element_text(size = 12, face = "bold", hjust = 0.5))

pdf(file.path(figures_path,'Intensity_ratings_control.pdf'))
print(ppp)
dev.off()

#************************************************** test
mdl.intensity = lmer(perceived_intensity ~ condition*trialxcondition+(condition|id)+ (condition|trialxcondition), data = OBIWAN_HED, REML=FALSE)
anova(mdl.intensity)

# ------------------------------------------ Familiarity ----------------------------------------------------------

#********************************* PLOT 1 main effect by subject
OBIWAN_HED.bs = ddply(OBIWAN_HED, .(id, condition), summarise, perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 
bg = ddply(OBIWAN_HED.bs,.(condition),summarise, perceived_familiarity=mean(perceived_familiarity))
er   <- ddply(OBIWAN_HED.bs, .(condition), summarise, perceived_familiarity = sd(perceived_familiarity)/sqrt(length(perceived_familiarity)))


ggplot(OBIWAN_HED.bs, aes(x = condition, y = perceived_familiarity, fill = condition, color = condition)) +
  geom_point(alpha = .5)  +
  geom_bar(data =bg, stat = "identity", width=.9, position = "dodge", alpha = .5, color = NA) +
  geom_errorbar(data = bg, aes(ymin = perceived_familiarity - er$perceived_familiarity, ymax = perceived_familiarity + er$perceived_familiarity), width = .1) +
  geom_line(aes(group = id), alpha = .2, size = 0.5, color = "gray") +
  theme_bw() +
  labs(
    title = "Familiarity",
    x = "Trial",
    y = "Familiarity"
  )

#********************************* PLOT 2 main effect by trial
OBIWAN_HED.bt   = ddply(OBIWAN_HED, .(trialxcondition, condition), summarise,  perceived_familiarity = mean(perceived_familiarity, na.rm = TRUE)) 
er   <- ddply(OBIWAN_HED, .(trialxcondition,condition), summarise, perceived_familiarity = sd(perceived_familiarity)/sqrt(length(perceived_familiarity)))

OBIWAN_HED.bt$trialxcondition <- as.numeric(OBIWAN_HED.bt$trialxcondition)

OBIWAN_HED.bt$min = OBIWAN_HED.bt$perceived_familiarity - er$perceived_familiarity
OBIWAN_HED.bt$max = OBIWAN_HED.bt$perceived_familiarity + er$perceived_familiarity

pp <- ggplot(OBIWAN_HED.bt, aes(x = trialxcondition, y = perceived_familiarity, fill = condition, color = condition)) +
  geom_point()  +
  geom_abline(slope= 0, intercept=50, linetype = "dashed", color = "black") +
  geom_line(aes(group = condition), alpha = 0.9, size = 1) +
  geom_ribbon(aes(ymin=OBIWAN_HED.bt$min, ymax=OBIWAN_HED.bt$max), alpha=0.2, linetype = 0 ) +
  theme_bw() +
  ylim(45, 78)+ 
  labs(
    title = "Perceived familiarity",
    x = "Trial",
    y = "Ratings"
  )

ppp <- pp + theme_linedraw(base_size = 12, base_family = "Helvetica")+
  theme(strip.text.x = element_text(size = 12, face = "bold"),
        plot.title = element_text(size = 12, face = "bold", hjust = 0.5),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        axis.line.y = element_line(size = 0.5, linetype = "solid", colour = "#999999"),
        axis.line.x = element_line(size = 0.5, linetype = "solid", colour = "#999999"),
        #legend.position="none",
        legend.text  = element_text(size = 12),
        #axis.ticks.x = element_blank(),
        axis.text.x  = element_text(size = 12),
        axis.title.x = element_text(size = 12, face = "bold", hjust = 0.5),
        axis.title.y = element_text(size = 12, face = "bold", hjust = 0.5))

pdf(file.path(figures_path,'Familiarity_ratings_control.pdf'))
print(ppp)
dev.off()

#************************************************** test
mdl.familiarity= lmer(perceived_familiarity ~ condition*trialxcondition+(condition|id)+ (condition|trialxcondition), data = OBIWAN_HED, REML=FALSE)
anova(mdl.familiarity)