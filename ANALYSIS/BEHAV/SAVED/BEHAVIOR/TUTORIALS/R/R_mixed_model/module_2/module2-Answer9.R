# Question 9

library(languageR)
data(lexdec)

# Question 9a
summary (lm(RT~Frequency,data=lexdec[lexdec$NativeLanguage=="English",]))
summary (lm(RT~Frequency,data=lexdec[lexdec$NativeLanguage=="Other",]))
# Non-native speakers show a stronger effect of frequency (greater decrease in reaction times for high frequency words)

# Question 9b
int.lm = lm(RT~Frequency*NativeLanguage,data=lexdec)
summary(int.lm)

# Question 9c
int.lm$coefficients[2] # Predicted effect for natives
int.lm$coefficients[2] +int.lm$coefficients[4] # Predicted effect for non-natives
# Same effects as in the simple linear regressions