## R code for FOR REWOD model selection
# last modified on August 2020 by David

# -----------------------  PRELIMINARY STUFF ----------------------------------------
# load libraries
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(readr, dplyr, reshape, reshape2, Rmisc, corrplot, ggpubr, gridExtra, grid, mosaic, psychometric, RNOmni)

analysis_path <- file.path('~/REWOD/DERIVATIVES/BEHAV') 
figures_path  <- file.path('~/REWOD/DERIVATIVES/FIGURES/BEHAV') 

setwd(analysis_path)

#mod1 <- read_csv("~/REWOD/DERIVATIVES/BMS/hedonic/GoF_NAcc/GLM-04.csv")
mod1 <- read_csv("~/REWOD/DERIVATIVES/BMS/PIT/GoF_NAcc/GLM-04.csv")
mod1 <- tibble::rowid_to_column(mod1, "ID")
mod1[is.na(mod1)] <- 'mod1'

#mod2 <- read_csv("~/REWOD/DERIVATIVES/BMS/hedonic/GoF_NAcc/GLM-15.csv")
mod2 <- read_csv("~/REWOD/DERIVATIVES/BMS/PIT/GoF_NAcc/GLM-03.csv")
mod2 <- tibble::rowid_to_column(mod2, "ID")
mod2[is.na(mod2)] <- 'mod2'

df_full = rbind(mod1, mod2)

AVG <- df_full %>%
  group_by(X4) %>%
  dplyr::select(R2, R2adj, AIC) %>% # select variables to summarise %LME, AIC, BIC,
  summarise_each(funs(m = mean))

# AVG = cbind(AVG, c('AVG', 'AVG'))
# 
# AVG = AVG[c("c(\"AVG\", \"AVG\")",  "R2adj_m", "R2_m" ,     "X3" )] #"AIC_m", "BIC_m", "LME_m" , 
# 
# df <- data.table::rbindlist(list(df_full, AVG))
# df$ID <- as.factor(df$ID)
# df$GLM <- as.factor(df$X3)

# # R2
# R2 = ggplot(data=df, aes(x=ID, y=R2, fill=GLM)) +
#   geom_bar(stat="identity", position=position_dodge())
# R2


#plot diff
#diff = mod2$R2 - mod1$R2
#diffadj = mod2$R2adj - mod1$R2adj
diffAIC = mod2$AIC - mod1$AIC

#diff <- append(diff, mean(diff))
ID = c('01','02','03','04','05','06','07','09','10','11','12','13','14','15','16','17','18','20','21','22','23','24','25','26') #, 'mean')

mod_comp = tibble(cbind(diffAIC, ID))

# R2 -diff in favor of mod2
diff = ggplot(data=mod_comp, aes(x=ID, y=diffAIC)) +
  geom_bar(fill = 'blue', stat="identity", position=position_dodge())

diff +  #details to make it look good
  theme_bw() +
  theme(plot.margin = unit(c(1, 1, 1.2, 1), units = "cm"),
        plot.title = element_text(hjust = 0.5),
        panel.grid.major.x = element_line( size=.2, color="lightgrey") ,
        panel.grid.major.y = element_line( size=.2, color="lightgrey") ,
        axis.text.x = element_text(angle = 90, size=10,  colour = "black", vjust = 0.5),
        axis.text.y = element_text(size=10,  colour = "black"),
        axis.title.x =  element_blank(), 
        axis.title.y = element_text(size=12),   
        legend.position = 'none', #c(0.475, -0.2), 
        legend.title=element_blank(),
        legend.direction = "horizontal", #legend.spacing.x = unit(1, 'cm'),
        axis.line.x = element_blank(),
        strip.background = element_rect(fill="white"))+ 
  labs( y = "\u0394 AIC \nModel 2 (Within) - Model 1 (Between) ",
        title = "Model Comparison - PIT") #,







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
