## R code for FOR REWOD model selection
# last modified on August 2020 by David

# -----------------------  PRELIMINARY STUFF ----------------------------------------
# load libraries
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(readr, dplyr, reshape, reshape2, Rmisc, corrplot, ggpubr, gridExtra, grid, mosaic, psychometric, RNOmni)

LBF_comp <- read_csv("~/REWOD/DERIVATIVES/BMS/PIT/LBF_comp.csv")

ID = c('01','02','03','04','05','06','07','09','10','11','12','13','14','15','16','17','18','20','21','22','23','24','25','26') #, 'mean')
mod_comp = tibble(cbind(LBF_comp, ID))


diff = ggplot(data=mod_comp, aes(x=ID, y=LBF_m)) +
  geom_bar(fill = 'red', stat="identity", position=position_dodge())

#geom_errorbar(aes(ymax = LBF_m+LBF_sd, ymin = LBF_m-LBF_sd), width=0.1,  alpha=1, size=0.4, position = position_dodge(width = 0.5))


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
  labs( y = "Average voxel-wise log Bayes factor in the ventral striatum\nModel 2 (Within) - Model 1 (Between) ",
        title = "Model Comparison - PIT") #,

