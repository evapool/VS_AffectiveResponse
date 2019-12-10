# Code chunk 1
library(languageR)  #load in languageR library
data (lexdec) # load in lexical decision data set

####################################
# Code chunk 2
frequencyModel = lm(RT~Frequency,data=lexdec) # build a linear model
summary(frequencyModel)  # print out the summary. Note the intercept and slope of the line
plot(RT~Frequency,data=lexdec)  # plot the data 
abline(frequencyModel, lty="dashed", col="red") # add a (dashed) regression line to the figure

####################################
# Code chunk 3 
# Simulate reaction time data
rt <- c() # vector to store RTs
frequency <- c() # vector to store frequencies
for (frequencyValue in seq(1.7,7.7,by=.01)){
		frequency <- append(frequency,frequencyValue)
		rt <- append(rt,6.6-0.04*frequencyValue+rnorm(1, 0,sd = 0.2)) # select a random number where mean of normal distribution is a function of intercept, frequency, with a constant standard deviation
	}

data <- data.frame(cbind(rt,frequency)) #build a dataframe of the 2 vectors
# Build a linear model; does it recover the coefficients from the function that generated the observations?
model <- lm(rt~frequency,data) # build linear model of RTs
summary(model)
plot(rt~frequency,data=data) # plot simulated data
abline(model,lty="dashed",col="red") # add a regression line to figure

####################################
# Code chunk 4
# Simulate reaction time data
rt <- c() # vector to store RTs
frequency <- c() # vector to store frequencies
length <- c() # vector to store lengths
for (frequencyValue in seq(1.7,7.7,by=.01)){
	for (lengthValue in 1:10){
		frequency <- append(frequency,frequencyValue)
		length <- append(length,lengthValue)
		rt <- append(rt,6.6-0.04*frequencyValue+0.02*lengthValue+rnorm(1, 0,sd = 0.2)) # select a random number where mean of normal distribution is a function of frequency AND length, with a constant standard deviation
	}
}
lengthFrequencyData <- data.frame(cbind(rt,length,frequency)) #build a dataframe of the 3 vectors
lengthFrequencyModel <- lm(rt~length+frequency,lengthFrequencyData) # build linear model of RTs
summary(lengthFrequencyModel) # summary of model

####################################
# Code chunk 5
hist(lengthFrequencyModel$residuals) # distribution of residuals for model


####################################
# Code chunk 6

qqnorm(lengthFrequencyModel$residuals) #normal quantile-quantile plot of the model's residuals
qqline(lengthFrequencyModel$residuals) #draw a line through first and third quantiles


####################################
# Code chunk 7
rt <- c() # vector to store RTs
frequency <- c() # vector to store frequencies
length <- c() # vector to store lengths
noiseSD <- 0 #standard deviation of random noise in selection of frequencies correlated with length

for (lengthValue in 1:10){
	for (k in 1:10) {  # generate 10 observations at each length
		frequencyValue = rnorm(1, (1/lengthValue)*7,sd=noiseSD)  # generate a random frequency, drawing from a normal distribution with a mean equal to 1 / length of the current item [times 7, to yield values comparable to previous simulations]. This makes sure freqeuncy is highly correlated to length; all short words have high frequencies, long words have low frequencies.
		frequency <- append(frequency,frequencyValue)
		length <- append(length,lengthValue)
		rt <- append(rt,6.6-0.04*frequencyValue+0.02*lengthValue+rnorm(1, 0,sd = 0.2)) # select a random number where mean of normal distribution is a function of frequency AND length, with a constant standard deviation
	}
}
data.correlated <- data.frame(cbind(rt,length,frequency)) #build a dataframe of the 3 vectors

####################################
# Code chunk 8

cor(data.correlated) # correlation table. Note high correlation of factors

####################################
# Code chunk 9
model.correlated <- lm(rt~length+frequency,data.correlated) # build linear model of RTs
summary(model.correlated) # summary of model

####################################
# Code chunk 10

rt <- c() # vector to store RTs
frequency <- c() # vector to store frequencies
length <- c() # vector to store lengths
outlierProb <- 0.10
for (frequencyValue in seq(1.7,7.7,by=.1)){
	for (lengthValue in 1:10){
		frequency <- append(frequency,frequencyValue)
		length <- append(length,lengthValue)
		if(runif(1,0,1) < 1-outlierProb) # draw a random sample from a uniform distribution betwen (0,1)
			# with pr(1-outlierProb), generate rts as before
			rt <- append(rt,6.6-0.04*frequencyValue+0.02*lengthValue+rnorm(1, 0,sd = 0.2)) # select a random number where mean of normal distribution is a function of frequency AND length, with a constant standard deviation
		else
			# with pr(outlierProb), generate an outlier with an RT between 7.75 and 9 
			rt <- append(rt,runif(1,min=7.75,max=9)) # outlier
	}
}
outlierData <- data.frame(cbind(rt,length,frequency)) #build a dataframe of the 3 vectors


####################################
# Code chunk 11
#

# hist(outlierData$rt)  # histogram of RTs; note fat right tail

####################################
# Code chunk 12
#

outlierModel <- lm(rt~length+frequency,outlierData) # build linear model of RTs
summary(outlierModel) # summary of model
qqnorm(outlierModel$residuals) #normal quantile-quantile plot of the model's residuals
qqline(outlierModel$residuals) #draw a line through first and third quantiles

####################################
# Code chunk 13
#

outlierTrimModel <- lm(rt~length+frequency,outlierData,subset=rt<7.5) # build linear model of RTs # build linear model of RTs
summary(outlierTrimModel) # summary of model
qqnorm(outlierTrimModel$residuals) #normal quantile-quantile plot of the model's residuals
qqline(outlierTrimModel$residuals) #draw a line through first and third quantiles

####################################
# Code chunk 14
#

curve(dgamma(x,shape=2, rate = 2),from = 0, to = 4) # example of a gamma distribution. Note that this is "naturally" skewed--these are not outliers, it's simply a different distribution




