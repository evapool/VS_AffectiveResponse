# Problem 2
lengthFrequencyModel = lm(RT~Length+Frequency,data=lexdec) # build a linear model
summary(lengthFrequencyModel)  # print out the summary. 

# You'll notice that both of the slopes (for frequency and length) are smaller than in the simpler models. There's a bigger reduction for length than frequency.
# Why? First notice that frequency and length are correlated (long words tend to be lower in frequency)
cor(lexdec$Length,lexdec$Frequency)

# As shown in the Johnson excerpt, the correlation coefficients are estimated by subtracting a fraction intercorrelations between variables. 
# The amount you subtract depends on the relative size of the correlation between the other predictor variable and the dependent measure. Here, since length has a weaker correlation with RT than frequency, this means that you subtract relatively less from the frequency predictor relative to the length predictor.


# prediction for length 5, frequency 4.5
lengthFrequencyModel$coefficients[1]+lengthFrequencyModel$coefficients[2]*5.0+lengthFrequencyModel$coefficients[3]*4.5