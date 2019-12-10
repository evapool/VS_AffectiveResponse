# Problem 1
lengthModel = lm(RT~Length,data=lexdec) # build a linear model
summary(lengthModel)  # print out the summary. Note the intercept and slope of the line
plot(RT~Length,data=lexdec)  # plot the data 
abline(lengthModel, lty="dashed", col="red") # add a (dashed) regression line to the figure

# Reaction times are slower for longer words.

# prediction for word of length 5 = intercept + coefficient on length * 5
lengthModel$coefficients[1] + lengthModel$coefficients[2] * 5.0