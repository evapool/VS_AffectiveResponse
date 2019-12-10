####################################
# Code chunk 19
#
vot <- read.delim("votPOA.txt") # read in VOT data

# contrast code place of articulation (identical to code chunk 16 from module 2)
vot$POA.Contrasts <- vot$POA
contrasts(vot$POA.Contrasts) <- cbind ("bilabial vs. lingual"=c(.25,-.5,.25),"alveolar vs. velar"=c(-.5,0,.5))


####################################
# Code chunk 20
#
# Make a new column. Each element of the column is drawn from the first column of the contrasts for POA.Contrasts (i.e., .25,-.5,.25). Select an element from this column (= a vector) using [ ]. The number of the element you select is determined by the number of the corresponding level from POA.Contrasts (i.e., 1,2 or 3--given by applying as.numeric to the alphanumeric column VOT$POA.Contrasts)
vot$LingualBilabialContrast <- contrasts(vot$POA.Contrasts)[,1][as.numeric(vot$POA.Contrasts)]

# Make a new column, following same procedure for second column of contrasts from POA.Contrasts
vot$AlveolarVelarContrast <- contrasts(vot$POA.Contrasts)[,2][as.numeric(vot$POA.Contrasts)]


####################################
# Code chunk 21
#

library(lme4)  # load in lme4 library
# build a lmer predicting VOT from the two columns that numerically code the two POA contrasts. Add a random intercept for subjects and words. Add a random slope for both the numerically coded contrasts.
vot.contrast.lmer = lmer (VOT~LingualBilabialContrast+AlveolarVelarContrast+(1+LingualBilabialContrast+AlveolarVelarContrast|Subject)+(1|Word),data=vot, REML=F) 

summary(vot.contrast.lmer) # print out summary  of model

####################################
# Code chunk 22
#
#Compare to one using the contrast-coded vector, not our numerical translation
vot.contrast.oneColumn.lmer = lmer (VOT~POA.Contrasts+(1+POA.Contrasts|Subject)+(1|Word),data=vot,REML=F)

summary(vot.contrast.oneColumn.lmer) # print out summary of model


####################################
# Code chunk 23
#

# test for effect of lingual vs. bilabial
# Build a model that subtracts out the lingual vs. bilabial contrast, holding everything else constant. 
vot.contrast.lingualBilabial.lmer = lmer (VOT~LingualBilabialContrast+AlveolarVelarContrast-LingualBilabialContrast+(1+LingualBilabialContrast+AlveolarVelarContrast|Subject)+(1|Word),data=vot, REML=F)

# Compare the likelihood of this model to the full model using the likelihood ratio test
anova(vot.contrast.lingualBilabial.lmer,vot.contrast.lmer)
# How to report this effect:
# β= 0.0129, SE β= 0.005, χ2(1) = 5.83, p < .05
# Note the coefficient estimate + standard error come from the full model

####################################
# Code chunk 24
#

# test for effect of velar vs. alveolar
# Build a model that subtracts out the velar vs. alveolar contrast, holding everything else constant. 
vot.contrast.AlveolarVelar.lmer = lmer (VOT~LingualBilabialContrast+AlveolarVelarContrast-AlveolarVelarContrast+(1+LingualBilabialContrast+AlveolarVelarContrast|Subject)+(1|Word),data=vot, REML=F)
# Compare the likelihood of this model to the full model using the likelihood ratio test
anova(vot.contrast.AlveolarVelar.lmer,vot.contrast.lmer)
#  β= 0.0128, SE β= 0.005,χ2(1) = 5.74, p < .05


####################################
# Code chunk 25
#

cor(vot$LingualBilabialContrast,vot$AlveolarVelarContrast)

####################################
# Code chunk 26
#
qqnorm(residuals(vot.contrast.lmer))
qqline(residuals(vot.contrast.lmer))

####################################
# Code chunk 27
#
hist(vot$VOT)