# Question 12

differences <- coef(lmm1)[2] - coef(lm0)[2]  # calculate difference of each slope from the overall slope
t.test (differences) # perform a one sample t-test on these differences
# Result: t(159) = –7.6, p < .05 
# The shows that the "overall" SES effect is not simply an average of all the individual school's SES effect; the simple linear regression's estimate of the effect is biased to reflect the effects of particular schools over others. 

# This is because schools are not evenly represented in the dataset.
tapply(MathAchieve$School,list(MathAchieve$School),length) #calculates number of observations within each school
# These range from 14 to 67
min(tapply(MathAchieve$School,list(MathAchieve$School),length))
max(tapply(MathAchieve$School,list(MathAchieve$School),length))