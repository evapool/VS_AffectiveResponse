# Question 16
vot = read.delim("neighbors.txt")
library(lme4)

# Code consonant contrasts
vot$Consonant.Contrasts <- vot$Consonant
contrasts(vot$Consonant.Contrasts) <- cbind ("lingual vs. bilabial"=c(.25,-.5,.25),"alveolar vs. velar"=c(.5,0,-.5))

# Translate consonant contrasts into numerical predictors
vot$LingualBilabialContrast <- contrasts(vot$Consonant.Contrasts)[,1][as.numeric(vot$Consonant.Contrasts)]

vot$AlveolarVelarContrast <- contrasts(vot$Consonant.Contrasts)[,2][as.numeric(vot$Consonant.Contrasts)]

# Code condition contrasts
vot$Condition.Contrasts <- vot$Condition
contrasts(vot$Condition.Contrasts) <- cbind("competitor vs. no competitor"=c(-.25,-.25,.5),"present vs. absent"=c(.5,-.5,0))

# Translate condition contrasts into numerical predictors
vot$CompNCompContrast <- contrasts(vot$Condition.Contrasts)[,1][as.numeric(vot$Condition.Contrasts)]
vot$PresAbsContrast <- contrasts(vot$Condition.Contrasts)[,2][as.numeric(vot$Condition.Contrasts)]

# LMER predicting VOT 4 contrasts above with Maximal random effects structure. No random slopes for consonaont place of articulation across pairs, as each pair as a unique place of articulation.
vot.lmer = lmer(VOT~LingualBilabialContrast+AlveolarVelarContrast+CompNCompContrast+PresAbsContrast+(1+LingualBilabialContrast+AlveolarVelarContrast+CompNCompContrast+PresAbsContrast|Subject)+(1+CompNCompContrast+PresAbsContrast|Pair),data=vot,REML=F)

# Test for each main effect

#Lingual v bilabial
votLB.lmer = lmer(VOT~LingualBilabialContrast+AlveolarVelarContrast+CompNCompContrast+PresAbsContrast-LingualBilabialContrast+(1+LingualBilabialContrast+AlveolarVelarContrast+CompNCompContrast+PresAbsContrast|Subject)+(1+CompNCompContrast+PresAbsContrast|Pair),data=vot,REML=F)
anova(vot.lmer,votLB.lmer)

#Alveolar v velar
votAV.lmer = lmer(VOT~LingualBilabialContrast+AlveolarVelarContrast+CompNCompContrast+PresAbsContrast-AlveolarVelarContrast+(1+LingualBilabialContrast+AlveolarVelarContrast+CompNCompContrast+PresAbsContrast|Subject)+(1+CompNCompContrast+PresAbsContrast|Pair),data=vot,REML=F)
anova(vot.lmer,votAV.lmer)

#Competitor v no competitor
votCNC.lmer = lmer(VOT~LingualBilabialContrast+AlveolarVelarContrast+CompNCompContrast+PresAbsContrast-CompNCompContrast+(1+LingualBilabialContrast+AlveolarVelarContrast+CompNCompContrast+PresAbsContrast|Subject)+(1+CompNCompContrast+PresAbsContrast|Pair),data=vot,REML=F)
anova(vot.lmer,votCNC.lmer)

# Competitor present v competitor absent
votPA.lmer = lmer(VOT~LingualBilabialContrast+AlveolarVelarContrast+CompNCompContrast+PresAbsContrast-PresAbsContrast+(1+LingualBilabialContrast+AlveolarVelarContrast+CompNCompContrast+PresAbsContrast|Subject)+(1+CompNCompContrast+PresAbsContrast|Pair),data=vot,REML=F)
anova(vot.lmer,votPA.lmer)

# The same issues we discussed with multiple regression more generally apply to mixed models as well. Here you can see that we still have an issue with outliers.
qqnorm(residuals(vot.lmer))
qqline(residuals(vot.lmer))

# Inspection of the vots reveals a few outliers

hist(vot$VOT)

# I then used this outlier trimming method; refitting the model shows a much better residual distribution.
votSubset = vot[vot$VOT<=0.130,]

votSubset.lmer = lmer(VOT~LingualBilabialContrast+AlveolarVelarContrast+CompNCompContrast+PresAbsContrast+(1+LingualBilabialContrast+AlveolarVelarContrast+CompNCompContrast+PresAbsContrast|Subject)+(1+CompNCompContrast+PresAbsContrast|Pair),data=votSubset,REML=F)

qqnorm(residuals(votSubset.lmer))
qqline(residuals(votSubset.lmer))

# I then proceeded with model comparison and ran into a stumbling block.
votSubsetLB.lmer = lmer(VOT~LingualBilabialContrast+AlveolarVelarContrast+CompNCompContrast+PresAbsContrast-LingualBilabialContrast+(1+LingualBilabialContrast+AlveolarVelarContrast+CompNCompContrast+PresAbsContrast|Subject)+(1+CompNCompContrast+PresAbsContrast|Pair),data=votSubset,REML=F)

# This leads to an interesting situation where one of the subset models won't coverge (even though the overall model does). What I typically do here is repeat the model selection process; once it converges, I refit the full model with the reduced random effects structure, and then repeat the model comparison process.
# In this case, I had a theoretical reason to want to focus on the neighborhood effects (I'm actually not interested in the place of articulation effects--the experiment was really about neighborhood effects). So I began with eliminating those random slopes. This converged

votSubsetLB.lmer = lmer(VOT~LingualBilabialContrast+AlveolarVelarContrast+CompNCompContrast+PresAbsContrast-LingualBilabialContrast+(1+CompNCompContrast+PresAbsContrast|Subject)+(1+CompNCompContrast+PresAbsContrast|Pair),data=votSubset,REML=F)

# I then re-fit the main model--double checked the residuals-- and then proceeded with model comparisons.
votSubset.lmer = lmer(VOT~LingualBilabialContrast+AlveolarVelarContrast+CompNCompContrast+PresAbsContrast+(1++CompNCompContrast+PresAbsContrast|Subject)+(1+CompNCompContrast+PresAbsContrast|Pair),data=votSubset,REML=F)

qqnorm(residuals(votSubset.lmer))
qqline(residuals(votSubset.lmer))

anova(votSubset.lmer,votSubsetLB.lmer)

votSubsetAV.lmer = lmer(VOT~LingualBilabialContrast+AlveolarVelarContrast+CompNCompContrast+PresAbsContrast-AlveolarVelarContrast+(1+CompNCompContrast+PresAbsContrast|Subject)+(1+CompNCompContrast+PresAbsContrast|Pair),data=votSubset,REML=F)
anova(votSubset.lmer,votSubsetAV.lmer)
votSubsetCNC.lmer = lmer(VOT~LingualBilabialContrast+AlveolarVelarContrast+CompNCompContrast+PresAbsContrast-CompNCompContrast+(1+CompNCompContrast+PresAbsContrast|Subject)+(1+CompNCompContrast+PresAbsContrast|Pair),data=votSubset,REML=F)
anova(votSubset.lmer,votSubsetCNC.lmer)
votSubsetPA.lmer = lmer(VOT~LingualBilabialContrast+AlveolarVelarContrast+CompNCompContrast+PresAbsContrast-PresAbsContrast+(1+CompNCompContrast+PresAbsContrast|Subject)+(1+CompNCompContrast+PresAbsContrast|Pair),data=votSubset,REML=F)
anova(votSubset.lmer,votSubsetPA.lmer)

# So what should you report here? I would probably report the results of the model fit with the full data set, and then add a footnote saying that similar results are found when outliers are excluded.
