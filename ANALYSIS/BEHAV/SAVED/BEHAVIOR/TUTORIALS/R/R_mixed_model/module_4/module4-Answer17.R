# Question 17

# Background main effect
dataNoCorrelationOnlyMainB.lmer =lmer (Correct~BackgroundContrast*ProbabilityContrast*StyleContrast-BackgroundContrast+(1|Subject)+(0+BackgroundContrast|Subject)+(0+ProbabilityContrast|Subject)+(0+StyleContrast|Subject),data=data,family="binomial",REML=F)
anova(dataNoCorrelationOnlyMain.lmer,dataNoCorrelationOnlyMainB.lmer)

# Style main effect
dataNoCorrelationOnlyMainS.lmer =lmer (Correct~BackgroundContrast*ProbabilityContrast*StyleContrast-StyleContrast+(1|Subject)+(0+BackgroundContrast|Subject)+(0+ProbabilityContrast|Subject)+(0+StyleContrast|Subject),data=data,family="binomial",REML=F)
anova(dataNoCorrelationOnlyMain.lmer,dataNoCorrelationOnlyMainS.lmer)

# Probability main effect
dataNoCorrelationOnlyMainP.lmer =lmer (Correct~BackgroundContrast*ProbabilityContrast*StyleContrast-ProbabilityContrast+(1|Subject)+(0+BackgroundContrast|Subject)+(0+ProbabilityContrast|Subject)+(0+StyleContrast|Subject),data=data,family="binomial",REML=F)
anova(dataNoCorrelationOnlyMain.lmer,dataNoCorrelationOnlyMainP.lmer)

# Background * Style interaction
dataNoCorrelationOnlyMainBS.lmer =lmer (Correct~BackgroundContrast*ProbabilityContrast*StyleContrast-BackgroundContrast:StyleContrast+(1|Subject)+(0+BackgroundContrast|Subject)+(0+ProbabilityContrast|Subject)+(0+StyleContrast|Subject),data=data,family="binomial",REML=F)
anova(dataNoCorrelationOnlyMain.lmer,dataNoCorrelationOnlyMainBS.lmer)

# Background* Probability interaction
dataNoCorrelationOnlyMainBP.lmer =lmer (Correct~BackgroundContrast*ProbabilityContrast*StyleContrast-BackgroundContrast:ProbabilityContrast+(1|Subject)+(0+BackgroundContrast|Subject)+(0+ProbabilityContrast|Subject)+(0+StyleContrast|Subject),data=data,family="binomial",REML=F)
anova(dataNoCorrelationOnlyMain.lmer,dataNoCorrelationOnlyMainBP.lmer)

# Probability * Style interaction
dataNoCorrelationOnlyMainPS.lmer =lmer (Correct~BackgroundContrast*ProbabilityContrast*StyleContrast-ProbabilityContrast:StyleContrast+(1|Subject)+(0+BackgroundContrast|Subject)+(0+ProbabilityContrast|Subject)+(0+StyleContrast|Subject),data=data,family="binomial",REML=F)
anova(dataNoCorrelationOnlyMain.lmer,dataNoCorrelationOnlyMainPS.lmer)

# 3-way Background, probability, style interaction
dataNoCorrelationOnlyMainBPS.lmer =lmer (Correct~BackgroundContrast*ProbabilityContrast*StyleContrast-BackgroundContrast:ProbabilityContrast:StyleContrast+(1|Subject)+(0+BackgroundContrast|Subject)+(0+ProbabilityContrast|Subject)+(0+StyleContrast|Subject),data=data,family="binomial",REML=F)
anova(dataNoCorrelationOnlyMain.lmer,dataNoCorrelationOnlyMainBPS.lmer)