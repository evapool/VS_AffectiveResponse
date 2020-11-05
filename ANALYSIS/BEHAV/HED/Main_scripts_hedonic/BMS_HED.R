## R code for FOR HED MODEL SELECTION
## following Barr et al. (2013) 
## last modified on April 2020 by David MUNOZ TORD

invisible(lapply(paste0('package:', names(sessionInfo()$otherPkgs)), detach, character.only=TRUE, unload=TRUE))

# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(lme4, lmerTest, optimx, car, visreg, ggplot2, ggpubr, sjPlot, influence.ME, bayestestR)

# SETUP ------------------------------------------------------------------

task = 'HED'

# Set working directory
analysis_path <- file.path('~/REWOD/DERIVATIVES/BEHAV', task) 
figures_path  <- file.path('~/REWOD/DERIVATIVES/FIGURES/BEHAV') 
setwd(analysis_path)


## LOADING AND INSPECTING THE DATA
load('HED.RData')

#View(HED)
dim(HED)
#str(HED)

#set "better" optimizer
control = lmerControl(optimizer ='optimx', optCtrl=list(method='nlminb'))

## BASIC RANDOM INTERCEPT MODEL

mod0 <- lmer(likC ~ condition * intC + (1|id) , data = HED, control = control) 
summary(mod0)


## COMPARING RANDOM EFFECTS MODELS
mod1 <- lmer(likC ~ condition * intC + (1|id) + (1|trialxcondition) , 
             data = HED, control = control) 
mod2 <- lmer(likC ~ condition * intC + (condition|id) , 
             data = HED, control = control) 
mod3 <- lmer(likC ~ condition * intC + (condition|id) + (1|trialxcondition) , 
             data = HED, control = control) 
mod4 <- lmer(likC ~ condition * intC + (condition|id) + (condition|trialxcondition) , 
             data = HED, control = control) 
mod5 <- lmer(likC ~ condition * intC + (condition + intC|id) + (condition|trialxcondition) , 
             data = HED, control = control) 
mod6 <- lmer(likC ~ condition * intC + (condition * intC|id) + (condition |trialxcondition) , 
             data = HED, control = control) 
mod7 <- lmer(likC ~ condition * intC + (condition|id) + (condition + intC|trialxcondition) , 
             data = HED, control = control) 
mod8 <- lmer(likC ~ condition * intC + (condition|id) + (condition * intC|trialxcondition) , 
             data = HED, control = control) 


# comparing BIC measures, allowing a Bayesian comparison of non-nested frequentist models (Wagenmakers, 2007)
bayesfactor_models(mod0, mod1, mod2, mod3, mod4, mod5, mod6,mod7,mod8, denominator = mod0) #mod6 #best random structure


## BEST RANDOM SLOPE MODEL
rslope <- mod6
summary(rslope)
ranova(rslope) #there is statistically "significant" variation in slopes between individuals and trials


# create data frames containing residuals and fitted
# values for each model we ran above
a <-  data_frame(
  model = "random.slope",
  fitted = predict(rslope),
  residual = residuals(rslope))

b <- data_frame(
  model = "random.intercept",
  fitted = predict(rint),
  residual = residuals(rint))

# join the two data frames together
residual.fitted.data <- bind_rows(a,b)

# plots residuals against fitted values for each model
residual.fitted.data %>%
  ggplot(aes(fitted, residual)) +
  geom_point() +
  geom_smooth(se=F) +
  facet_wrap(~model)
#We can see that the residuals from the random slope model XX problem here ##
#the range of fitted values, which suggests that the assumption of 
#homogeneity of variance is met in the random slope model

mod <- mod6
summary(mod)
moddummy <- lm(likC ~ condition*intC, data = HED)

## PLOTTING
visreg(mod,points.par=list(col="darkgoldenrod3"),line.par=list(col="royalblue4",lwd=4))

#for to continuous predictor by group
#visreg(mod1,xvar="group",by="condition",gg=TRUE,type="contrast",ylab="Liking (z)",breaks=c(-2,0,2),xlab="Intervention")


# MODEL ASSUMPTION CHECKS :  -----------------------------------

#explicitly check correlation (between individuals’ intercept and slope residuals)
VarCorr(mod) #The correlation between the random intercept and slopes is pretty high, so we keep them

#1) Multicollinearity / VIF larger than 10 is considered problematic. 
vif(mod) #well good nothing above 10 so no problem keeping everything

#2)Linearity #3)Homoscedasticity AND #4)Normality of residuals
plot_model(mod, type = "diag") #super cool sjPlots for checking assumptions -> not bad except residuals I guess but seen worst

#5) Absence of influential data points
boxplot(scale(ranef(mod)$id), las=2) #simple univariate boxplots 

set.seed(101) #disgnostic plots -> Cook's distance ->  20 & 16
alt.est <- influence(mod,maxfun=100,  group="id")   #set to 100 to really have a good estimate BUT #takes forever
cookD = cooks.distance(alt.est)
df <- data.frame(id = row.names(cookD), cookD) 
df <- arrange(df, cookD)
df$id <- factor(df$id, levels = df$id)
n_tot = length(df$id)
cutoff = 4/(n_tot-length(moddummy$coefficients)-1) #rule of thumb cutoff not to take to seriously


#little function to plot the outlier because the car ones doesnt work anymore on merMod
ggdotchart(df, x = "id", y = "cookD", sorting = "ascending",add = "segments") +
  geom_hline(yintercept=cutoff, linetype="dashed", color = "red") +
  geom_text(aes(label = id, hjust = -0.5), size = 3) +
  scale_y_continuous(limits = c(0, cutoff+0.2)) +
  scale_x_discrete(expand=c(0,2)) +
  coord_flip() + 
  theme(legend.position = 'none', axis.ticks.y = element_blank(),  axis.text.y = element_blank())


# The rest on REWOD_HED - Special thanks to Ben Meuleman, Eva R. Pool and Yoann Stussi -----------------------------------------------------------------
