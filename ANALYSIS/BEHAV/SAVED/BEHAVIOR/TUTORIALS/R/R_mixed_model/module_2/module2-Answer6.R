# Problem 6

model.treatment <- lm(VOT~POA,data=vot[vot$Voicing=="voiced",]) #linear model for voiced stops
summary(model.treatment)

model.treatment$coefficients[1] #intercept: predicted VOT for alveolars
model.treatment$coefficients[1] + model.treatment$coefficients[2] #intercept + second coefficient: predicted VOT for bilabials
model.treatment$coefficients[1]+ model.treatment$coefficients[3] #intercept + third coefficient: predicted VOT for velars

with(vot[vot$Voicing=="voiced",],tapply(VOT,list(POA),mean)) # actual means

# Actual means = predicted means