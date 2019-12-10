## R code for FOR REWOD GENERAL
# last modified on August 2019 by David




# -----------------------  PRELIMINARY STUFF ----------------------------------------
pacman::p_load(robust, permuco, MASS, ggplot2, dplyr, plyr, tidyr, reshape, reshape2, Hmisc, corrplot, ggpubr, gridExtra, mosaic)

if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}


#SETUP
task = 'hedonic'
con_name1 = 'R_NoR'
con_name2 = 'CSp'
conEFF = 'CSp_CSm'
con2 = 'Reward_NoReward'
mod1 = 'lik'
mod2 = 'int'
mod3 = 'eff'

#

## R code for FOR REWOD_HED
# Set working directory -------------------------------------------------


analysis_path <- file.path('~/REWOD/DERIVATIVES/ANALYSIS', task) 
setwd(analysis_path)

# open dataset 
BETAS_R_NoR <- read.delim(file.path(analysis_path, 'ROI', paste('extracted_betas_',con_name1,'.txt',sep="")), header = T, sep ='\t') # read in dataset



LIK_R_NoR <- read.delim(file.path(analysis_path, 'GLM-04', 'group_covariates', paste(con2,'_', mod1, '_rank.txt',sep="")), header = T, sep ='\t') # read in dataset



analysis_path <- file.path('~/REWOD/DERIVATIVES/ANALYSIS/PIT') 
BETAS_CSp <- read.delim(file.path(analysis_path, 'ROI', paste('extracted_betas_', conEFF, '_via_', con_name1 , '.txt',sep="")), header = T, sep ='\t') # read in dataset
EFF_R_NoR <- read.delim(file.path(analysis_path, 'GLM-04', 'group_covariates', paste('CSp-CSm_', mod3, '_rank.txt',sep="")), header = T, sep ='\t')  # read in dataset


# merge
#R_NoR_CSp = merge(BETAS_R_NoR_CSp, LIK_R_NoR, by.x = "ID", by.y = "subj", all.x = TRUE)
#R_NoR_CSp = merge(R_NoR_CSp, INT_R_NoR, by.x = "ID", by.y = "subj", all.x = TRUE)

R_NoR_df = merge(BETAS_R_NoR, LIK_R_NoR, by.x = "ID", by.y = "subj", all.x = TRUE)
CSp_df = merge(BETAS_CSp, EFF_R_NoR, by.x = "ID", by.y = "subj", all.x = TRUE)


# define factors
R_NoR_df$ID <- factor(R_NoR_df$ID)
CSp_df$ID <- factor(CSp_df$ID)
#R_NoR_CSp$ID <- factor(R_NoR_CSp$ID)



# PLOT FUNCTIONS --------------------------------------------------------------------


ggplotRegression <- function (fit) {
  
  ggplot(fit$model, aes_string(x = names(fit$model)[2], y = names(fit$model)[1])) + 
    geom_point() +
    stat_smooth(method = "lm", col = "red") +
    labs(title = paste("Adj R2 = ",signif(summary(fit)$adj.r.squared, 5),
                       #"Intercept =",signif(fit$coef[[1]],5 ),
                       #" Slope =",signif(fit$coef[[2]], 5),
                       "  &  P =",signif(summary(fit)$coef[2,4], 5)))+
    theme(plot.title = element_text(size = 10, hjust =1))
  
}




#  Plot for R_NoR  ----------------------------------------------------------

# For liking
#R_NoR_df <- filter(R_NoR_df, ID != "21") # or not !!!
lik = zscore(R_NoR_df$lik)
R_NoR_df$lik = zscore(lik)
A1 <- ggplotRegression(lm(R_NoR_df[[2]]~lik)) + rremove("x.title")
A2 <- ggplotRegression(lm(R_NoR_df[[4]]~lik)) + rremove("x.title")
A3 <- ggplotRegression(lm(R_NoR_df[[5]]~lik)) + rremove("x.title")
A4 <- ggplotRegression(lm(CSp_df[[2]]~CSp_df$eff)) + rremove("x.title")
A5 <- ggplotRegression(lm(CSp_df[[4]]~CSp_df$eff)) + rremove("x.title")


figure <- ggarrange(A1,A2,A3,
                     labels = c( "cmOFC_cluster_betas"  ,     "cm_OFC_Right_betas"    ,    "cm_OFC_Right_sphere_betas"),
                     ncol = 2, nrow = 2,
                     vjust=3, hjust=0) 



# STATS cmOFC LIK--------------------------------------------------------------

par = summary(lm(R_NoR_df$cm_OFC_Right_sphere_betas~R_NoR_df$lik))
p_par2 = par$coefficients[8]


rob = rlm(R_NoR_df$cm_OFC_Right_sphere_betas~R_NoR_df$lik)
weights = rob$w #estimated weights!
rob_sum = summary(rob)
t = rob_sum$coefficients[6]
df = rob_sum$df[2]
p_rob = 2*(1-pt(t, df))
# kind of similar 
p_par2

p_rob

#weights

R_NoR_df$OFCweights = weights^2
R_NoR_df$OFCweights = I(R_NoR_df$OFCweights)


# check = lmRob(R_NoR_df$cm_OFC_Right_sphere_betas~R_NoR_df$lik)
# summary(check)  #this one is not conservator at all it just leaves out the points

# PLOT OFC LIK -----------------------------------------------------------
P1 <- ggplot(R_NoR_df, aes(lik, cm_OFC_Right_sphere_betas)) + #A2
  geom_point(alpha = R_NoR_df$OFCweights) +
  geom_smooth(method = "rlm",  col = "red") +
  #geom_smooth(lm(R_NoR_df$cm_OFC_Right_sphere_betas~R_NoR_df$lik, w = 1/R_NoR_df$cm_OFC_Right_sphere_betas^2)
  scale_x_continuous(name="Hedonic experience", expand = c(0, 0), limits=c(-2.5, 2.5), breaks=c(seq.int(-2.5,2.5, by = 1))) +
  scale_y_continuous(expression(paste(beta, "  Reward > No Reward")), expand = c(0, 0), limits=c(-0.8, 1), breaks=c(seq.int(-0.8,1, by = 0.2))) +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), legend.position = "none", panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)

#anatomicaly defined left pcore ~ likort
figure1 <- annotate_figure(P1,
                           top = text_grob(paste("Robust: anatomicaly defined left cmOFC (Sphere masked 6mm) ~ lik: p", round(p_rob,5)), color = "black", face = "bold", size = 14))




# norlm lm OFC LIk----------------------------------------------------------------
par = summary(lm(R_NoR_df$cm_OFC_Right_sphere_betas$lik))
p_par = par$coefficients[8]

P2 <- ggplot(R_NoR_df, aes(lik, cm_OFC_Right_sphere_betas)) + #A2
  geom_point() +
  geom_smooth(method = "lm",  col = "red") +
  #geom_smooth(lm(CSp_df$cm_OFC_Right_sphere_betas~CSp_df$eff, w = 1/CSp_df$cm_OFC_Right_sphere_betas^2)
  scale_x_continuous(name="Hedonic experience", expand = c(0, 0), limits=c(-2.5, 2.5), breaks=c(seq.int(-2.5,2.5, by = 1))) +
  scale_y_continuous(expression(paste(beta, "  Reward > No Reward")), expand = c(0, 0), limits=c(-0.8, 1), breaks=c(seq.int(-0.8,1, by = 0.2))) +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), legend.position = "none", panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)

#anatomicaly defined left pcore ~ effort
figure2 <- annotate_figure(P2,
                           top = text_grob(paste("Regular: anatomicaly defined left cmOFC (Sphere masked 6mm) ~ lik: p", p_par), color = "black", face = "bold", size = 14))




# EFFORT NOW --------------------------------------------------------------

# sats eff ----------------------------------------------------------------


par = summary(lm(CSp_df$cm_OFC_Right_sphere_betas~CSp_df$eff))
p_par2 = par$coefficients[8]


rob = rlm(CSp_df$cm_OFC_Right_sphere_betas~CSp_df$eff)
weights = rob$w #estimated weights!
rob_sum = summary(rob)
t = rob_sum$coefficients[6]
df = rob_sum$df[2]
p_rob = 2*(1-pt(-t, df))
# kind of similar 
p_par2

p_rob

#weights

CSp_df$OFCweights = weights^2
CSp_df$OFCweights = I(CSp_df$OFCweights)


# check = lmRob(CSp_df$cm_OFC_Right_sphere_betas~CSp_df$eff)
# summary(check)  #this one is not conservator at all it just leaves out the points

# PLOT pCore eff -----------------------------------------------------------
P3 <- ggplot(CSp_df, aes(eff, cm_OFC_Right_sphere_betas)) + #A2
  geom_point(alpha = CSp_df$OFCweights) +
  geom_smooth(method = "rlm",  col = "blue") +
  #scale_x_continuous(name="Mobilized effort", expand = c(0, 0), limits=c(-2.5, 3)) +
  #scale_y_continuous(expression(paste(beta, "  CS+ > CS-")), expand = c(0, 0), limits=c(-0.3, 0.4), breaks=c(seq.int(-0.5,0.4, by = 0.1))) +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), legend.position = "none", panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)

#anatomicaly defined left pcore ~ effort
figure3 <- annotate_figure(P3,
                           top = text_grob(paste("Robust: anatomicaly defined left cmOFC (Sphere masked 6mm) ~ eff: p", round(p_rob,5)), color = "black", face = "bold", size = 14))




# norlm lm ----------------------------------------------------------------


P4 <- ggplot(CSp_df, aes(eff, cm_OFC_Right_sphere_betas)) + #A2
  geom_point() +
  geom_smooth(method = "lm",  col = "blue") +
  #scale_x_continuous(name="Mobilized effort", expand = c(0, 0), limits=c(-2.5, 3)) +
  #scale_y_continuous(expression(paste(beta, "  CS+ > CS-")), expand = c(0, 0), limits=c(-0.3, 0.4), breaks=c(seq.int(-0.5,0.4, by = 0.1))) +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), legend.position = "none", panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)

#anatomicaly defined left pcore ~ effort
figure4 <- annotate_figure(P4,
                           top = text_grob(paste("Regular: anatomicaly defined left cmOFC (Sphere masked 6mm) ~ eff: p", round(p_par2,5)), color = "black", face = "bold", size = 14))




# FINAL FIGURES -----------------------------------------------------------


figure1  #rob OFC LIK
figure2   #reg OFC LIK
figure3  #rob OFC EFF
figure4   #reg OFC EFF

