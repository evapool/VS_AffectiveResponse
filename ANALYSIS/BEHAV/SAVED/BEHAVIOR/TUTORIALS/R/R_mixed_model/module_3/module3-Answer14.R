#Question 14
library(languageR) # load in languageR library
data(lexdec) # load in lexdec data set
lexdec.lmer = lmer(RT~NativeLanguage*Frequency+(1+Frequency|Subject),data=lexdec, REML = F)
# build a linear mixed effects model on RTs, using main effects of native language, frequency, and an interaction; include random intercept for subjects and a random slope of frequency by subject
# Note use of REML=F argument. This is needed in order to properly perform the likelihood ratio test (given below)
lexdecSimp.lmer = lmer(RT~NativeLanguage*Frequency+(1|Subject),data=lexdec, REML = F)
# build a linear mixed effects model on RTs, using main effects of native language, frequency, and an interaction; include random intercept for subjects
anova(lexdecSimp.lmer,lexdec.lmer)
# perform a likelihood ratio test [see later in slides] comparing the two models

#Yes; there is a significant improvement in fit when including random slopes for the frequency effect by subjects, correlated with the subject intercepts (χ(2)= 9.0, p < .05)