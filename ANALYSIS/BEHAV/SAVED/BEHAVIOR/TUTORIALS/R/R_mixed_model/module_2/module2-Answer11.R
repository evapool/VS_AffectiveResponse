# Question 11

verb.glm = glm(RealizationOfRec~AnimacyOfRec,data=verbSubset,family="binomial")

exp(verb.glm$coefficients[1]) # odds of using PP for animates
exp(verb.glm$coefficients[1]+verb.glm$coefficients[2]) # odds of using PP for inanimates

# Same as empirical odds