####################################
# Code chunk 15
#

vot <- read.delim('/Users/evapool/Documents/projects/Personal_learning/R_mixed_model/module_2/votPOA.txt') # read in dataset
voiced <- vot [vot$Voicing=="voiced",]
tapply (voiced$VOT,list(voiced$POA),mean)

vot$POA.Treatment <- factor(vot$POA, levels =c("bilabial","alveolar","velar"))  # define a new predictor, with a factor ordering: bilabial, baseline, alveolar, treatment 1, and velar, treatment 2

voiced <- vot [vot$Voicing=="voiced",]

####################################
# Code chunk 16
#

vot$POA.Contrasts <- vot$POA # make a new column that is a copy of the POA column
contrasts(vot$POA.Contrasts) <- cbind ("bilabial vs. lingual"=c(1/4,-1/2,1/4),"alveolar vs. velar"=c(-1/2,0,1/2)) # define contrasts for this new factor; the first compares the middle group to the first and third groups, the second compares the first and third groups. Note that the number of the group = its alphabetical order (alveolar, bilabial, velar)

####################################
# Code chunk 17
#

library(languageR)  # load in languageR library
data(verbs) # load verb dataset
verbSubset = verbs[verbs$AnimacyOfTheme=="inanimate",] # focus on inanimate themes

countsVerbs = table(verbSubset$RealizationOfRec,verbSubset$AnimacyOfRec) # build a 2-way contingency table of realization of recipient (NP/PP) by animacy of recipient (animate/inanimate)

propVerbs = prop.table(countsVerbs,2) # convert numbers into proportions within each column (column specified by second argument, the dimension of the table to calculate proportions over; 1= rows, 2= columns)

propVerbs

####################################
# Code chunk 18
#
verb.glm = glm(RealizationOfRec~AnimacyOfRec,data=verbSubset,family="binomial") #build a logistic regression, predicting odds of using a prepositional phrase given recipient animacy
summary(verb.glm) # print summary of model

contrasts(verbSubset$RealizationOfRec) # check contrast coding of dependent measure
contrasts(verbSubset$AnimacyOfRec) # check contrast coding of predictor
