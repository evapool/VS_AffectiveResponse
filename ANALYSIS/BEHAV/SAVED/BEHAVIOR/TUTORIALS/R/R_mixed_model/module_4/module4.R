####################################
# Code chunk 28
#
library(languageR)
data(lexdec)

contrasts(lexdec$NativeLanguage)=c(-.5,.5) # re-define as contrast-coded rather than treatment coded

lexdec$NativeLanguageContrast <- contrasts(lexdec$NativeLanguage)[,1][as.numeric(lexdec$NativeLanguage)]


####################################
# Code chunk 29
#

# model predict RT using main effects of frequency, native language, as well as their interaction. Includes random intercepts for subjects and words, along with correlated random slopes for frequency by subject and native language by word. This is the maximal random effects structure.
full.lmer = lmer(RT~Frequency*NativeLanguageContrast + (1+Frequency|Subject)+(1+NativeLanguageContrast|Word),data=lexdec, REML=F)

summary(full.lmer) #print summary of model

####################################
# Code chunk 29
#

# Build a model that does include the interaction of frequency and native language, holding everything else constant.
interaction.lmer  = lmer(RT~Frequency*NativeLanguageContrast - 	Frequency:NativeLanguageContrast + (1+Frequency|Subject)	+(1+NativeLanguageContrast|Word),data=lexdec, REML=F)
# Compare the likelihood of this model to the full model using the likelihood ratio test
anova (full.lmer, interaction.lmer)
#  β= -0.027, SE β= 0.01,χ2(1) = 6.94, p < .05

####################################
# Code chunk 30
#
data = read.delim("scnn.txt") # read in data

# contrast code all predictors
 contrasts(data$Background)=c(-.5,.5)
 contrasts(data$Probability)=c(-.5,.5)
contrasts(data$Style)=c(-.5,.5)

# translate contrasts into numerical predictors
data$BackgroundContrast <- contrasts(data$Background)[,1][as.numeric(data$Background)]
data$ProbabilityContrast <- contrasts(data$Probability)[,1][as.numeric(data$Probability)]
data$StyleContrast <- contrasts(data$Style)[,1][as.numeric(data$Style)]

library(lme4)

# These are the models that fail to converge
# Maximal model
dataFull.lmer =lmer (Correct~BackgroundContrast*ProbabilityContrast*StyleContrast+(1+BackgroundContrast*ProbabilityContrast*StyleContrast|Subject),data=data,family="binomial",REML=F)

# Model with no correlations between random effects
dataNoCorrelation.lmer =lmer (Correct~BackgroundContrast*ProbabilityContrast*StyleContrast+(1|Subject)+(0+BackgroundContrast|Subject)+(0+ProbabilityContrast|Subject)+(0+StyleContrast|Subject)+(0+BackgroundContrast*ProbabilityContrast|Subject)+(0+BackgroundContrast*StyleContrast|Subject)+(0+ProbabilityContrast*StyleContrast|Subject)+(0+BackgroundContrast*ProbabilityContrast*StyleContrast|Subject),data=data,family="binomial",REML=F)

# Model with no correlations between random effects, eliminating 3 way interaction random slope
dataNoCorrelationNo3Way.lmer =lmer (Correct~BackgroundContrast*ProbabilityContrast*StyleContrast+(1|Subject)+(0+BackgroundContrast|Subject)+(0+ProbabilityContrast|Subject)+(0+StyleContrast|Subject)+(0+BackgroundContrast*ProbabilityContrast|Subject)+(0+BackgroundContrast*StyleContrast|Subject)+(0+ProbabilityContrast*StyleContrast|Subject),data=data,family="binomial",REML=F)

# This model converges
# Model with no correlations between random effects, eliminating 2 and 3 way interaction random slopes
dataNoCorrelationOnlyMain.lmer =lmer (Correct~BackgroundContrast*ProbabilityContrast*StyleContrast+(1|Subject)+(0+BackgroundContrast|Subject)+(0+ProbabilityContrast|Subject)+(0+StyleContrast|Subject),data=data,family="binomial",REML=F)
