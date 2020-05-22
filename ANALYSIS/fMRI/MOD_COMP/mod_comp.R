## R code for FOR REWOD model selection
# last modified on August 2020 by David

# -----------------------  PRELIMINARY STUFF ----------------------------------------
# load libraries
pacman::p_load(robust, permuco, MASS, ggplot2, dplyr,data.table, plyr, tidyr, reshape, reshape2, Rmisc, corrplot, ggpubr, gridExtra, grid, mosaic, psychometric, RNOmni)

if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}

mod1 <- read_csv("REWOD/DERIVATIVES/BMS/hedonic/GoF_NAcc/GLM-04.csv")
mod1 <- tibble::rowid_to_column(mod1, "ID")
mod1[is.na(mod1)] <- 'mod1'

mod2 <- read_csv("REWOD/DERIVATIVES/BMS/hedonic/GoF_NAcc/GLM-15.csv")
mod2 <- tibble::rowid_to_column(mod2, "ID")

mod2[is.na(mod2)] <- 'mod2'

df_full = rbind(mod1, mod2)

AVG <- df_full %>%
  group_by(X6) %>%
  select(LME, AIC, BIC, R2, R2adj) %>% # select variables to summarise
  summarise_each(funs(m = mean))

AVG = cbind(AVG, c('AVG', 'AVG'))

AVG = AVG[c("c(\"AVG\", \"AVG\")",  "R2adj_m", "R2_m" ,  "AIC_m", "BIC_m", "LME_m" ,    "X6" )]

df <- rbindlist(list(df_full, AVG))
df$ID <- as.factor(df$ID)
df$GLM <- as.factor(df$X6)

# R2
R2 = ggplot(data=df, aes(x=ID, y=R2, fill=GLM)) +
  geom_bar(stat="identity", position=position_dodge())
R2


#plot diff
diff = mod2$R2 - mod1$R2
diff <- append(diff, mean(diff))
ID = c('01','02','03','04','05','06','07','09','10','11','12','13','14','15','16','17','18','20','21','22','23','24','25','26', 'mean')

mod_comp = tibble(cbind(diff, ID))

# R2 -diff in favor of mod2
R2_diff = ggplot(data=mod_comp, aes(x=ID, y=diff)) +
  geom_bar(stat="identity", position=position_dodge())
R2_diff





# 
# # R2 adj
# R2adj = ggplot(data=df, aes(x=ID, y=R2adj, fill=GLM)) +
#   geom_bar(stat="identity", position=position_dodge())
# R2adj
# 
# # AIC
# AIC = ggplot(data=df, aes(x=ID, y=AIC, fill=GLM)) +
#   geom_bar(stat="identity", position=position_dodge())
# AIC
# 
# # BIC
# BIC = ggplot(data=df, aes(x=ID, y=AIC, fill=GLM)) +
#   geom_bar(stat="identity", position=position_dodge())
# BIC
# 
# # LME
# LME = ggplot(data=df, aes(x=ID, y=LME, fill=GLM)) +
#   geom_bar(stat="identity", position=position_dodge())
# LME
# 
# 
# 
