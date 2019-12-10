#Question 15

# Assumes code chunk 28 has been executed

frequencyMain.lmer = lmer(RT~Frequency*NativeLanguageContrast -Frequency+ (1+Frequency|Subject)+(1+NativeLanguageContrast|Word),data=lexdec, REML=F)

anova (full.lmer, frequencyMain.lmer)
#  β= -0.044, SE β= 0.007,χ2(1) = 31.24, p < .05


nativeLanguageMain.lmer = lmer(RT~Frequency*NativeLanguageContrast -NativeLanguageContrast+ (1+Frequency|Subject)+(1+NativeLanguageContrast|Word),data=lexdec, REML=F)

anova (full.lmer, nativeLanguageMain.lmer)
#  β= 0.286, SE β= 0.09,χ2(1) = 8.54, p < .05
