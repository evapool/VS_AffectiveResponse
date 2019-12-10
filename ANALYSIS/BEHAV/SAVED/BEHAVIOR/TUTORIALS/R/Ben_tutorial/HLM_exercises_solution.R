##############################################################
# BEN MEULEMAN
# HLM WORKSHOP
#
# CISA - UNIVERSITY OF GENEVA
# 29.01.2016
##############################################################
# EXERCISES - SOLUTIONS
##############################################################

library(lme4)
library(lmerTest)
library(lattice)
library(car)


##############################################################
## EX1. RESULTS REPLICATION
##############################################################
#
# Try to replicate the analyses conducted during the theory class for the sleep data. 
# Use the scripts HLM_sleep.r and HLM_sleep_plus.r as a basis for this.
#
##############################################################

# See reference scripts for the solution!



##############################################################
## EX2. SLEEP PLUS DATA
##############################################################
#
# For the extended sleep deprivation study, researchers hypothesized that there would
# be an interaction between age and hours of sleep deprivation, such that for older
# people attention would decline faster for increasing deprivation. How can you test this
# hypothesis?
#
# Proceed with model selection in the usual fashion. First random effects, then fixed
# effects. However, remember to maintain a full fixed effects structure while comparing
# different random effects structures.
#
# For this interaction model, investigate the need for a random deprivation slope. How are
# the results different from the example in the slides? What could be an explanation...?
#
##############################################################

# First we read and scale the data properly

sleep2 <- read.csv("C:/Myfolder/subfolder/.../sleep_plus.csv")
sleep2$Age <- scale(sleep2$Age)
sleep2$Deprivation <- scale(sleep2$Deprivation)
sleep2$Bodytemp <- scale(sleep2$Bodytemp)

contrasts(sleep2$Gender) <- contr.sum(2)
contrasts(sleep2$Gender)

# Next we select a random effects structure (REML), keeping fixed effects constant.
# This time there is an inclusion of age by deprivation interaction.

mod1 <- lmer(Attention~Gender+Age+Bodytemp+Deprivation+Age:Deprivation+(1|Subject),data=sleep2)
mod2 <- lmer(Attention~Gender+Age+Bodytemp+Deprivation+Age:Deprivation+(1+Deprivation|Subject),data=sleep2)
mod3 <- lmer(Attention~Gender+Age+Bodytemp+Deprivation+Age:Deprivation+(1+Deprivation||Subject),data=sleep2)
mod4 <- lmer(Attention~Gender+Age+Bodytemp+Deprivation+Age:Deprivation+(1+Bodytemp|Subject),data=sleep2)
mod5 <- lmer(Attention~Gender+Age+Bodytemp+Deprivation+Age:Deprivation+(1+Bodytemp||Subject),data=sleep2)
mod6 <- lmer(Attention~Gender+Age+Bodytemp+Deprivation+Age:Deprivation+(1+Deprivation+Bodytemp|Subject),data=sleep2)
mod7 <- lmer(Attention~Gender+Age+Bodytemp+Deprivation+Age:Deprivation+(1+Deprivation+Bodytemp||Subject),data=sleep2)

AIC(mod1) ; AIC(mod2) ; AIC(mod3) ; AIC(mod4) ; AIC(mod5) ; AIC(mod6) ; AIC(mod7)

# Again, the best model has a random intercept and a random deprivation slope for subjects.
# This time the difference in AIC between this model and the random intercept-only model is 
# somewhat smaller, however. This could point to the fact that the inclusion of an age:deprivation
# interaction accounts to some extent for the random variation in deprivation slopes among
# subjects.

final <- lmer(Attention~Gender+Age+Bodytemp+Deprivation+Age:Deprivation+(1+Deprivation|Subject),data=sleep2,REML=FALSE)
anova(final)
summary(final)

# Next we visualize the interaction with the lattice library. For clarity, I create a 
# categorical version of the age variable. These are databased plots. An alternative would 
# be to generate model-based plots. Think about which ones would be most informative (and when)...

mysettings <- list(strip.background=list(col=c("lightsteelblue")),strip.border=list(col="black"))
sleep2$Agecat <- cut(sleep2$Age,breaks=3,labels=c("Lower","Mid","Higher"))
xyplot(Attention~Deprivation|Agecat,data=sleep2,panel=function(x,y) {panel.xyplot(x, y,pch=3,col="grey60"); panel.lmline(x, y,lwd=2,col="darkcyan")},par.settings=mysettings)

# Although the effect is subtle, we can see a slight increase in steepness of the deprivation
# slope for increasing age. This indicates---as per the coefficient estimates---that attention
# declines relatively faster for older people, for increasing sleep deprivation.



##############################################################
## EX3. RESTAURANTS DATA
##############################################################
#
# For the restaurants study, find out how to conduct pairwise comparisons between conditions
# as a follow-up to the overall ANOVA. Remember that these pairwise comparisons should
# correct for the covariance structure fitted by the random effects (no regular t-tests!).
#
# The summary output could provide a solution. Depending on the contrast coding of the
# independents, we can test specific hypotheses.
#
# Check how the functions "contrasts" and "contr.treatment" can be used to conduct pair-
# wise comparisons. For help on any function, simply type ?function
#
##############################################################

# Reading the data and creating the categorical star variable

resto <- read.csv("C:/Myfolder/subfolder/.../restaurants.csv")
resto$Starcat <- as.factor(resto$Stars)

# First we replicate the basic ANOVA for the final model that was fitted during class.

mod <- lmer(Quality~Starcat*Criterion+(1|Restaurant)+(1|Critic),data=resto,REML=FALSE)
anova(mod)

# Since we have a significant interaction, we would like to conduct pairwise comparisons
# for selected conditions. Here, the primary interest would be to contrast types of
# quality criteria within each star category (e.g., food vs service for 0 stars). We
# can achieve this by manipulating the contrast coding of our factors. This time the
# most useful type of coding is 0/1 coding, which is called treatment coding in R and
# is the default coding for factors. Also by default, the coding will take the first
# level of the factor as the "reference" level.

contrasts(resto$Starcat)

# If we want to tests contrasts within 0 star restaurants, we therefore do not have to
# change the default coding for the "Starcat" variable right now. For the criteria:

contrasts(resto$Criterion)

# Since "ambience" is the reference level for the "Criterion" coding, we can get all 
# contrasts between "ambience" and the other criteria (for 0 star restaurants) from the main
# effects coefficients tests of the model we just fitted

coef(summary(mod))[4:6,]

# For the other contrasts we simply have to recode the reference level of the
# "Criterion" factor. For "creativity":

contrasts(resto$Criterion) <- contr.treatment(4,base=2)
contrasts(resto$Criterion)
mod <- lmer(Quality~Starcat*Criterion+(1|Restaurant)+(1|Critic),data=resto,REML=FALSE)
coef(summary(mod))[4:6,]

# For "food":

contrasts(resto$Criterion) <- contr.treatment(4,base=3)
contrasts(resto$Criterion)
mod <- lmer(Quality~Starcat*Criterion+(1|Restaurant)+(1|Critic),data=resto,REML=FALSE)
coef(summary(mod))[4:6,]

# We can still recode for the "service" level too although we actually got those
# contrasts from the previous outputs already, so strictly speaking this is redundant.
# The conclusion for 0-star restaurants is that the average quality rating for "food"
# is higher than the average quality ratings for "ambience", "creativity", and
# "service". No significant differences were found for the remaining pairwise contrasts.
# This conclusion confirms the visual trends that we observed in our barchart (see
# slides).
# The procedure above can be repeated for the other Star categories by first changing
# the reference level for that variable, e.g.:

contrasts(resto$Starcat) <- contr.treatment(3,base=2)
contrasts(resto$Starcat)
contrasts(resto$Criterion) <- contr.treatment(4,base=1)
contrasts(resto$Criterion)

mod <- lmer(Quality~Starcat*Criterion+(1|Restaurant)+(1|Critic),data=resto,REML=FALSE)
coef(summary(mod))[4:6,]

contrasts(resto$Criterion) <- contr.treatment(4,base=2)
mod <- lmer(Quality~Starcat*Criterion+(1|Restaurant)+(1|Critic),data=resto,REML=FALSE)
coef(summary(mod))[4:6,]

contrasts(resto$Criterion) <- contr.treatment(4,base=3)
mod <- lmer(Quality~Starcat*Criterion+(1|Restaurant)+(1|Critic),data=resto,REML=FALSE)
coef(summary(mod))[4:6,]

# The conclusion here is that, for 1-star restaurants, there are no significant
# differences in quality ratings between the four criteria (unlike 0-star restaurants).
# Finally, we can conduct pairwise comparisons between criteria ratings for the
# 2-star restaurants

contrasts(resto$Starcat) <- contr.treatment(3,base=3)

contrasts(resto$Criterion) <- contr.treatment(4,base=1)
mod <- lmer(Quality~Starcat*Criterion+(1|Restaurant)+(1|Critic),data=resto,REML=FALSE)
coef(summary(mod))[4:6,]

contrasts(resto$Criterion) <- contr.treatment(4,base=2)
mod <- lmer(Quality~Starcat*Criterion+(1|Restaurant)+(1|Critic),data=resto,REML=FALSE)
coef(summary(mod))[4:6,]

contrasts(resto$Criterion) <- contr.treatment(4,base=3)
mod <- lmer(Quality~Starcat*Criterion+(1|Restaurant)+(1|Critic),data=resto,REML=FALSE)
coef(summary(mod))[4:6,]

# We reach the same conclusion as for 1-star restaurants. No significant differences
# between types of quality criteria.



##############################################################
## EX4. AFFECTIVE PRIMING
##############################################################
#
# Conduct a classic repeated measures (M)ANOVA on the affective priming data. To do this,
# use the Excel version of the data. Average the trial-level RTs per subject and per
# condition using the pivot table function in Excel, and transform the data to wide format.
#
# 1. Load these data in SPSS/Statistica and conduct a PRIME x TARGET repeated measures
#    (M)ANOVA.
#
# 2. Export the wide format data back to "csv" format and load them into R. If you know
#    how to conduct a repeated measures (M)ANOVA in R, run it here.
#
# How are the results of the classic approaches different from the HLM approach? How are the
# results different between the two classic approaches (MANOVA vs ANOVA), if at all?
#
# Which analysis would have your preference and why?
#
##############################################################

# Reading the data
priming <- read.csv("C:/Myfolder/subfolder/.../priming.csv")

# Here I will demonstrate an R-approach to reshaping data to wide format, although
# pivot table in Excel is surely the faster/smoother approach. Pivot table will
# simultaneously average data across trials AND change the layout to the wide format.
# In R this is a two-step procedure. First we have to average data using the 
# aggregate() function. Then we can reshape using the reshape() function.

primave <- aggregate(RT~Prime+Target+Subject,data=priming,FUN=mean)

# Note how the aggregate function uses the same formula interace as the lmer()
# function. The specification above averages out all variables in the data set that 
# are not mentioned in the independent part of the formula: trials, prime word, 
# and target word. The specified function (FUN) for data aggregation was "mean", 
# but this can be changed to "median", or "count", for example. Next, we reshape
# the data to wide format.

primave$Cond <- paste(primave$Prime,primave$Target,sep="_")
primwide <- reshape(primave,direction="wide",v.names="RT",timevar=c("Cond"),idvar="Subject",drop=c("Prime","Target"))
primwide

# Note how we first need to create an explicit condition variable. This is because,
# (unfortunately) the reshape function cannot handle multiple condition variables 
# simultaneously (e.g., Prime + Target). Next we tell the reshape function the 
# direction of the formatting ("wide"), the name of the dependent ("RT"), the name 
# of the within-subject variable ("Cond"), the subject identifier ("Subject"), and 
# which variables to drop from the new wide-format data.

# Now that the data are in the canonical format for repeated measures (M)ANOVA,
# we can proceed with the analysis. First we rename our columns slightly to
# reduce the amount of text in the R code:

names(primwide) <- c("Subject","NN","NP","PN","NN")

# Next we fit the data to a multivariate regression model. This model has the four
# condition columns with RTs as dependents, and only an intercept as the independent.
# Although this may seem a very strange model, this is how the repeated measures 
# MANOVA "translates/interprets" repeated measures data. All tests of effects in 
# this model are performed by first transforming the matrix of dependents, and then 
# testing whether the intercept in the model differs significantly from 0.
# 
# For example, for a paired t-test, we could compute difference scores between the 
# two paired conditions, and enter these difference scores as the dependent in a 
# regression with only an intercept. The test of the intercept tells us whether the 
# mean of the dependent is significantly different from 0, which is what we want to 
# find out about the difference scores. A repeated measures MANOVA is an extension of 
# this principle.

mlm <- lm(cbind(NN,NP,PN,NN)~1,data=primwide)

# Next we have to create a design matrix that we use later to tell R about the within
# design of the data. This matrix basically encodes how the columns in the wide
# format data are ordered (compare to SPSS within-specification).

design <- data.frame(Prime=c("Negative","Negative","Positive","Positive"),Target=c("Negative","Positive","Negative","Positive"))
design

# Finally, we run the repeated measures (M)ANOVA. For this we need the "Anova()" function
# from the "car" library. Note that this function is different from the default "anova"
# function in R (and from the "anova" function supplied by lmerTest for lmer objects)!!

library(car)
Anova(mlm,test="Wilks",type=3,idata=design,idesign=~Prime*Target)

# We have specified that R uses Wilks' lambda as the test statistic, that R should
# return type III ANOVA results, and what the within-design is. The latter requires
# a design matrix (supplied by the design object) and a formula without a 
# dependent (~Prime*Target), and independents corresponding to the named columns
# of the design object.

summary(Anova(mlm,test="Wilks",type=3,idata=design,idesign=~Prime*Target))

# If we run the summary function on this Anova object, we can also obtain the 
# repeated measures ANOVA output. For these data, the ANOVA and MANOVA do not
# differ because all within-factors have only 2 levels. Both analyses reach the same
# conclusion, which is that there is a significant interaction between
# prime and target on RT. Compare now again with:

anova(lmer(RT~Prime*Target+(1|Subject)+(1|Pword)+(1|Tword),data=priming,REML=FALSE))

# Although the HLM analysis reaches the same conclusion of the repeated measures
# (M)ANOVA, the HLM test for the interaction has less degrees of freedom. This is because
# we have taken into account explicitly random variation in RTs due to subjects and
# due to specific stimuli. In the repeated measures (M)ANOVA, the latter influence
# is completely ignored. The analysis simply assumes that the results can be generalized
# to any other set of positive-negative words. Given the low number of unique stimuli 
# and the (relatively) low number of repeats per prime-target combination, this 
# would clearly be an overconfident estimate.




##############################################################
## EX5. ROBOT PONIES
##############################################################
#
# Investigate the effect of "Province" and/or "Location" for the robot ponies data. Can
# the location variable potentially explain why there are random sales trends between
# stores following the advertising campaign?
#
# Add an explicit "Advertising" variable (2 levels: pre or post) to the dataset and 
# investigate how it can be used in the trend modelling. In what way are interactions 
# between "Advertising" and "Time" different from the spline model approach?
#
# Tip: use the "ifelse" function in R to create a binary variable
#
# Average the data for the two advertising conditions (pre or post) and run a simple paired
# t-test on the data. Do you obtain the same information as the more complicated HLM?
# If so, what are the arguments pro and con against either approach?
#
# Tip: use the "aggregate" function in R to average data. The function has a formula
# interface similar to "lmer"!
#
##############################################################

# Reading the data

ponies <- read.csv("C:/Myfolder/subfolder/.../ponies.csv")
ponies <- ponies[complete.cases(ponies),]

# First we create the new "Advertising" variable that codes for the days before
# and after the start of the advertising campaign. This can be achieved by a simple
# if-else logical comparison. As well, we create a standardized version of the
# time variable. For the interaction exercise this is especially important, since
# unstandardized variables tend to be collinear with their interaction effects.
# Standardization reduces this problem somewhat.

ponies$Advertising <- as.factor(ifelse(ponies$Time>29,"Post","Pre"))
contrasts(ponies$Advertising) <- contr.treatment(2,base=2)
ponies$Time.z <- scale(ponies$Time)

# Next we refit our HLM and set the right random effects structure

mod1 <- lmer(Sales~Advertising*Time.z+(1|Store),data=ponies)
mod2 <- lmer(Sales~Advertising*Time.z+(1+Time.z|Store),data=ponies)
mod3 <- lmer(Sales~Advertising*Time.z+(1+Advertising|Store),data=ponies)
mod4 <- lmer(Sales~Advertising*Time.z+(1+Time.z+Advertising|Store),data=ponies)
mod5 <- lmer(Sales~Advertising*Time.z+(1+Time.z*Advertising|Store),data=ponies)
mod6 <- lmer(Sales~Advertising*Time.z+(1+Time.z*Advertising||Store),data=ponies)

AIC(mod1) ; AIC(mod2) ; AIC(mod3) ; AIC(mod4) ; AIC(mod5) ; AIC(mod6)

# Evidence for a random time by advertising interaction. Since the model with
# uncorrelated random effects (mod6) is only marginally worse in terms of AIC, we
# continue with that model (because it has 2 fewer covariance parameters).

mod6 <- lmer(Sales~Advertising*Time.z+(1+Time.z*Advertising||Store),data=ponies)
summary(mod6)

# The coefficient estimates indicate (as expected) that there is a negative sales
# trend before advertising ("Time.z" coefficient), equal to -5.16. After advertising
# the sales trend changes direction ("Advertising1:Time.z" coefficient), adding 12.97
# to the previous slope.
# In contrast to the spline model that we fitted in class, however, the interaction
# model also includes a change in the intercept after advertising ("Advertising
# coefficient"). We can plot the model's predictions as follows:

plot(Sales~I(scale(Time)),data=ponies,pch="+",col="plum4",ylim=c(0,50),xlab="Standardized time",ylab="Number of Robot Ponies sold")
lines(aggregate(fitted(mod6)~ponies$Time.z,FUN=mean),lwd=3,col="violetred4")
lines(fitted(mod6)[ponies$Store=="S20"]~ponies$Time.z[ponies$Store=="S20"],lwd=2,col="darkblue")
lines(fitted(mod6)[ponies$Store=="S27"]~ponies$Time.z[ponies$Store=="S27"],lwd=2,col="darkgoldenrod")
abline(v=0.03,lty=2)
legend("topleft",legend=c("Population trend","Store 20 trend","Store 27 trend","Start of campaign"),
 lwd=c(3,3,3,1),seg.len=2.5,col=c("violetred4","darkblue","darkgoldenrod","black"),lty=c(1,1,1,2),bty="n")


# Visually the difference seems negligible compared to the spline model. However, due
# to the fact that R automatically connects points for lines, the jump in intercept
# from pre- to post-advertising, is somewhat less noticeable. For the individual
# sales trend of Store 27 this is the most evident.

# Finally, we try a simple paired t-test approach for these data. First we aggregate
# the sales data per store, before and after advertising:

salesmean <- aggregate(Sales~Store+Advertising,data=ponies,FUN=mean)

# Next we run a paired t-test for these data

t.test(Sales~Advertising,data=salesmean,paired=TRUE)
aggregate(Sales~Advertising,data=ponies,FUN=mean)

# The result shows that sales are significantly higher following advertising than
# before. The effect is rather small, however, and clearly we have lost much
# information by collapsing the data over time. The paired t-test completely ignores 
# any random differences or trends between stores.



