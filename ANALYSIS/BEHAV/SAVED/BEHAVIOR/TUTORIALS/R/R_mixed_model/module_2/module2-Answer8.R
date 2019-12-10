# Problem 8

vot$POA.Contrasts <- vot$POA
contrasts(vot$POA.Contrasts) <- cbind ("bilabial vs. lingual"=c(1/4,-1/2,1/4),"alveolar vs. velar"=c(-1/2,0,1/2))
model.contrasts <- lm(VOT~POA.Contrasts,data=vot[vot$Voicing=="voiced",])
summary(model.contrasts)

model.contrasts$coefficients[1] + .25*model.contrasts$coefficients[2] - .5 * model.contrasts$coefficients[3]#predicted VOT for alveolars
model.contrasts$coefficients[1] - .5*model.contrasts$coefficients[2] + 0 * model.contrasts$coefficients[3]#predicted VOT for bilabials
model.contrasts$coefficients[1] + .25*model.contrasts$coefficients[2] + .5 * model.contrasts$coefficients[3]#predicted VOT for velars


# actual means = predicted means