# Problem 7

vot$POA.Treatment.New <- factor(vot$POA, levels =c("velar","alveolar","bilabial"))
model.treatment.new <- lm(VOT~POA.Treatment.New,data=vot[vot$Voicing=="voiced",])
summary(model.treatment.new)

model.treatment.new$coefficients[1] #intercept: predicted VOT for velars
model.treatment.new$coefficients[1] + model.treatment.new$coefficients[2] #intercept + second coefficient: predicted VOT for alveolars
model.treatment.new$coefficients[1]+ model.treatment.new$coefficients[3] #intercept + third coefficient: predicted VOT for bilabials

# actual means = predicted means