## R code for FOR REWOD GENERAL
# last modified on August 2019 by David




# -----------------------  PRELIMINARY STUFF ----------------------------------------
# load libraries
pacman::p_load(robust, permuco, MASS, ggplot2, dplyr, plyr, tidyr, reshape, reshape2, Hmisc, corrplot, ggpubr, gridExtra, mosaic, psychometric)

if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}

#SETUP
task = 'hedonic'
con_name1 = 'Reward_NoReward_4'
con_name2 = 'CSp_CSm'



con1 = 'Reward_NoReward'
con2 = 'CSp-CSm'


mod1 = 'lik'
mod2 = 'eff'


k = 2
n = 24


#

## R code for FOR REWOD_HED
# Set working directory -------------------------------------------------


analysis_path <- file.path('~/REWOD/DERIVATIVES/ANALYSIS', task) 
setwd(analysis_path)

# open dataset 
BETAS_Lik <- read.delim(file.path(analysis_path, 'ROI', paste('extracted_betas_',con_name1,'.txt',sep="")), header = T, sep ='\t') # read in dataset


LIK_Lik <- read.delim(file.path(analysis_path, 'GLM-04', 'group_covariates', paste(con1,'_', mod1, '_meancent.txt',sep="")), header = T, sep ='\t') # read in dataset


analysis_path <- file.path('~/REWOD/DERIVATIVES/ANALYSIS/PIT') 

BETAS_CS <- read.delim(file.path(analysis_path, 'ROI', paste('extracted_betas_',con2, '_via_', con_name1, '.txt',sep="")), header = T, sep ='\t') # read in dataset
EFF_CS    <- read.delim(file.path(analysis_path, 'GLM-04', 'group_covariates', paste(con2,'_', mod2, '_rank.txt',sep="")), header = T, sep ='\t') # read in dataset


# merge
R_NoR_df = merge(BETAS_Lik, LIK_Lik, by.x = "ID", by.y = "subj", all.x = TRUE)
#CSp_CSp = merge(CSp_CSp, INT_CSp, by.x = "ID", by.y = "subj", all.x = TRUE)

CSp_df = merge(BETAS_CS, EFF_CS, by.x = "ID", by.y = "subj", all.x = TRUE)



# define factors
R_NoR_df$ID <- factor(R_NoR_df$ID)
CSp_df$ID <- factor(CS_df$ID)
#CSp_CSp$ID <- factor(CSp_CSp$ID)



# PLOT FUNCTIONS --------------------------------------------------------------------


ggplotRegression <- function (fit) {
  
  ggplot(fit$model, aes_string(x = names(fit$model)[2], y = names(fit$model)[1])) + 
    geom_point() +
    stat_smooth(method = "lm", col = "blue") +
    labs(title = paste("  R2 = ",signif(summary(fit)$r.squared, 5),
                       #"Intercept =",signif(fit$coef[[1]],5 ),
                       #" Slope =",signif(fit$coef[[2]], 5),
                       "  &  P =",signif(summary(fit)$coef[2,4], 5)))+
    theme(plot.title = element_text(size = 10, hjust =1))
  
}




#  Plot for odor-Lik  ----------------------------------------------------------


lik = R_NoR_df$lik
lik = zscore(lik)
R_NoR_df$lik = zscore(lik)
A1 <- ggplotRegression(lm(R_NoR_df[[2]]~lik)) + rremove("x.title")
A2 <- ggplotRegression(lm(R_NoR_df[[3]]~lik)) + rremove("x.title")
A3 <- ggplotRegression(lm(R_NoR_df[[4]]~lik)) + rremove("x.title")
A4 <- ggplotRegression(lm(R_NoR_df[[5]]~lik)) + rremove("x.title")
A5 <- ggplotRegression(lm(R_NoR_df[[6]]~lik)) + rremove("x.title")




ggarrange(A1,A2,A3,A4,A5,
          labels = c(    "cmOFC_cluster_betas"   ,    "cm_OFC_MNI_betas"      ,    "cm_OFC_Right_betas"    ,    "cm_OFC_Right_sphere_betas",
                         "cm_OFC_sphere_betas"   ),
          ncol = 2, nrow = 3,
          vjust=3, hjust=0) 


#cm_OFC_sphere_betas = anatomical sphere 6mm
# LIKING ________________ NOW --------------------------------------------------------------
lik = R_NoR_df$lik
lik = zscore(lik)
R_NoR_df$lik = zscore(lik)


# STATS cm_OFC LIK--------------------------------------------------------------

par = summary(lm(R_NoR_df$cm_OFC_Right_sphere_betas~R_NoR_df$lik))
p_par = par$coefficients[8]

rob = rlm(R_NoR_df$cm_OFC_Right_sphere_betas~R_NoR_df$lik)
rsq = summary(lmRob(R_NoR_df$cm_OFC_Right_sphere_betas~R_NoR_df$lik))$r.squared
# .rsq <- 1 - (1 - rsq) * ((n - 1)/(n-k-1))

weights = rob$w #estimated weights!
rob_sum = summary(rob)
t = rob_sum$coefficients[6]
df = rob_sum$df[2]
p_rob = 2*(1-pt(t, df))
# kind of similar 
p_par

p_rob

#weights

R_NoR_df$weights = weights
R_NoR_df$weights = I(R_NoR_df$weights)


# check = lmRob(R_NoR_df$cm_OFC_Right_sphere_betas~R_NoR_df$lik)
# summary(check)  #this one is not conservator at all it just leaves out the points



# PLOT cm_OFC LIK RLM -----------------------------------------------------------

grob0 <- grobTree(textGrob("WLS:", x=0.8,  y=0.15, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob1 <- grobTree(textGrob(bquote(paste(r^2," = ",.(signif(rsq,2)))), x=0.8,  y=0.1, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob2 <- grobTree(textGrob(bquote(paste("p = ",.(signif(p_par,2)))), x=0.8,  y=0.05, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

P1 <- ggplot(R_NoR_df, aes(lik, cm_OFC_Right_sphere_betas)) + #A2
  geom_point(aes(alpha=R_NoR_df$weights)) +
  geom_smooth(method = "rlm",  col = "blue") +
  #geom_smooth(lm(R_NoR_df$cm_OFC_Right_sphere_betas~R_NoR_df$lik, w = 1/R_NoR_df$cm_OFC_Right_sphere_betas^2)
  scale_x_continuous(name="Pleasantness Index", expand = c(0, 0), limits=c(-2, 2)) +
  scale_y_continuous(expression(paste(beta, "  Reward > No Reward")), expand = c(0, 0), limits=c(-1, 1.5), breaks=c(seq.int(-1,1.5, by = 0.5))) +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), legend.position = "none", panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)  +
  annotation_custom(grob0)+
  annotation_custom(grob1)+
  annotation_custom(grob2)

#anatomicaly defined left cm_OFC ~ lik

P1





CI =CI.Rsq(rsq, n, k, level = 0.9)
stat_1 = paste("r² = ", signif(rsq,3),  ", 90% CI [", signif(CI$LCL,3), ",", signif(CI$UCL,3), "]", ", p = ", round(p_rob, 5))

# PLOT cmOFC LIK norm -----------------------------------------------------------

#  _R2_ 
rsq =summary(lm(R_NoR_df$cm_OFC_Right_sphere_betas~lik))$r.squared

grob0 <- grobTree(textGrob("WLS:", x=0.8,  y=0.15, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob1 <- grobTree(textGrob(bquote(paste(r^2," = ",.(signif(rsq,2)))), x=0.8,  y=0.1, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob2 <- grobTree(textGrob(bquote(paste("p = ",.(signif(p_par,2)))), x=0.8,  y=0.05, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

P2 <- ggplot(R_NoR_df, aes(lik, cm_OFC_Right_sphere_betas)) + #A2
  geom_point() +
  geom_smooth(method = "lm",  col = "blue") +
  #geom_smooth(lm(R_NoR_df$cm_OFC_Right_sphere_betas~R_NoR_df$lik, w = 1/R_NoR_df$cm_OFC_Right_sphere_betas^2)
  scale_x_continuous(name="Pleasantness Index", expand = c(0, 0), limits=c(-2, 2)) +
  scale_y_continuous(expression(paste(beta, "  Reward > No Reward")), expand = c(0, 0), limits=c(-1, 1.5), breaks=c(seq.int(-1,1.5, by = 0.5))) +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), legend.position = "none", panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)  +
  annotation_custom(grob0)+
  annotation_custom(grob1)+
  annotation_custom(grob2)

#anatomicaly defined left cmOFC ~ lik

P2



CI =CI.Rsq(rsq, n, k, level = 0.9)
stat_2 = paste("r² = ", signif(rsq,3),  ", 90% CI [", signif(CI$LCL,3), ",", signif(CI$UCL,3), "]", ", p = ", round(p_par, 5))





# STATS cm_OFC  for CSp ---------------------------------------------------------------
perm = summary(lmperm(CSp_df$cm_OFC_Right_sphere_betas~CSp_df$eff))
p_par = perm$`parametric Pr(>|t|)`[2]
p_per = perm$`permutation Pr(>|t|)`[2]
rob = rlm(CSp_df$cm_OFC_Right_sphere_betas~CSp_df$eff)
rsq = summary(lmRob(CSp_df$cm_OFC_Right_sphere_betas~CSp_df$eff))$r.squared

weights = rob$w #estimated weights!
rob_sum = summary(rob)
t = rob_sum$coefficients[6]
df = rob_sum$df[2]
p_rob = 2*pt(t, df)
# kind of similar 
p_par
p_per
p_rob


CSp_df$weights = weights
CSp_df$weights = I(CSp_df$weights)



# check = lmRob(CSp_df$cm_OFC_Right_sphere_betas~CSp_df$eff)
# summary(check)  #this one is not conservator at all it just leaves out the points

eff= CSp_df$eff
eff = zscore(eff)
CSp_df$lik = zscore(eff)


# PLOT cm_OFC rlm---------------------------------------------------------------

grob0 <- grobTree(textGrob("WLS:", x=0.8,  y=0.15, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob1 <- grobTree(textGrob(bquote(paste(r^2," = ",.(signif(rsq,2)))), x=0.8,  y=0.1, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob2 <- grobTree(textGrob(bquote(paste("p = ",.(signif(p_rob,2)))), x=0.8,  y=0.05, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

P3 <- ggplot(CSp_df, aes(eff, cm_OFC_Right_sphere_betas)) + #A2
  geom_point(aes(alpha=CSp_df$weights)) +
  geom_smooth(method = "rlm",  col = "mediumspringgreen") +
  #geom_smooth(lm(CSp_df$cm_OFC_Right_sphere_betas~CSp_df$eff, w = 1/CSp_df$cm_OFC_Right_sphere_betas^2)
  scale_x_continuous(name="Pavlovian-Instrumental Index", expand = c(0, 0), limits=c(-2.5, 2.5)) +
  scale_y_continuous(expression(paste(beta, "  CS+ > CS-")), expand = c(0, 0), limits=c(-0.2, 0.3), breaks=c(seq.int(-0.2,0.3, by = 0.1))) +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), legend.position = "none", panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)  +
  annotation_custom(grob0)+
  annotation_custom(grob1)+
  annotation_custom(grob2)

#anatomicaly defined left cm_OFC ~ effort


P3



CI =CI.Rsq(rsq, n, k, level = 0.9)
stat_3 = paste("r² = ", signif(rsq,3),  ", 90% CI [", signif(CI$LCL,3), ",", signif(CI$UCL,3), "]", ", p = ", round(p_rob, 5))



#  PLOT norlm lm cm_OFC----------------------------------------------------------------


# R2_ 
rsq =summary(lm(CSp_df$cm_OFC_Right_sphere_betas~eff))$r.squared

grob0 <- grobTree(textGrob("WLS:", x=0.8,  y=0.15, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob1 <- grobTree(textGrob(bquote(paste(r^2," = ",.(signif(rsq,2)))), x=0.8,  y=0.1, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob2 <- grobTree(textGrob(bquote(paste("p = ",.(signif(p_par,2)))), x=0.8,  y=0.05, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

P4 <- ggplot(CSp_df, aes(eff, cm_OFC_Right_sphere_betas)) + #A2
  geom_point() +
  geom_smooth(method = "lm",  col = "mediumspringgreen") +
  #geom_smooth(lm(CSp_df$cm_OFC_Right_sphere_betas~CSp_df$eff, w = 1/CSp_df$cm_OFC_Right_sphere_betas^2)
  scale_x_continuous(name="Pavlovian-Instrumental Index", expand = c(0, 0), limits=c(-2.5, 2.5)) +
  scale_y_continuous(expression(paste(beta, "  CS+ > CS-")), expand = c(0, 0), limits=c(-0.2, 0.3), breaks=c(seq.int(-0.2,0.3, by = 0.1))) +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), legend.position = "none", panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)  +
  annotation_custom(grob0)+
  annotation_custom(grob1)+
  annotation_custom(grob2)

#anatomicaly defined left pcore ~ effort


P4


CI =CI.Rsq(rsq, n, k, level = 0.9)
stat_4 = paste("r²  = ", signif(rsq,3),  ", 90% CI [", signif(CI$LCL,3), ",", signif(CI$UCL,3), "]", ", p = ", round(p_par, 5))





# AGAIN BUT WITH spgere = 4mm

# STATS cm_OFC LIK--------------------------------------------------------------

par = summary(lm(R_NoR_df$cm_OFC_sphere_betas~R_NoR_df$lik))
p_par = par$coefficients[8]

rob = rlm(R_NoR_df$cm_OFC_sphere_betas~R_NoR_df$lik)
rsq = summary(lmRob(R_NoR_df$cm_OFC_sphere_betas~R_NoR_df$lik))$r.squared

weights = rob$w #estimated weights!
rob_sum = summary(rob)
t = rob_sum$coefficients[6]
df = rob_sum$df[2]
p_rob = 2*(1-pt(t, df))
# kind of similar 
p_par

p_rob

#weights

R_NoR_df$weights = weights
R_NoR_df$weights = I(R_NoR_df$weights)



# PLOT cm_OFC LIK RLM -------------------------------------------- --------

grob0 <- grobTree(textGrob("WLS:", x=0.8,  y=0.15, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob1 <- grobTree(textGrob(bquote(paste(r^2," = ",.(signif(rsq,2)))), x=0.8,  y=0.1, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob2 <- grobTree(textGrob(bquote(paste("p = ",.(signif(p_rob,2)))), x=0.8,  y=0.05, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

P5 <- ggplot(R_NoR_df, aes(lik, cm_OFC_sphere_betas)) + #A2
  geom_point(aes(alpha=R_NoR_df$weights)) +
  geom_smooth(method = "rlm",  col = "blue") +
  #geom_smooth(lm(R_NoR_df$cm_OFC_sphere_betas~R_NoR_df$lik, w = 1/R_NoR_df$cm_OFC_sphere_betas^2)
  scale_x_continuous(name="Pleasantness Index", expand = c(0, 0), limits=c(-2, 2)) +
  scale_y_continuous(expression(paste(beta, "  Reward > No Reward")), expand = c(0, 0), limits=c(-0.8, 1.2), breaks=c(seq.int(-0.8,1.2, by = 0.5))) +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), legend.position = "none", panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)  +
  annotation_custom(grob0)+
  annotation_custom(grob1)+
  annotation_custom(grob2)

#anatomicaly defined left cm_OFC ~ lik

P5



CI =CI.Rsq(rsq, n, k, level = 0.9)
stat_5 = paste("r² = ", signif(rsq,3),  ", 90% CI [", signif(CI$LCL,3), ",", signif(CI$UCL,3), "]", ", p = ", round(p_rob, 5))

# PLOT cmOFC LIK norm -----------------------------------------------------------

#  _R2_ 
rsq =summary(lm(R_NoR_df$cm_OFC_sphere_betas~lik))$r.squared

grob0 <- grobTree(textGrob("WLS:", x=0.8,  y=0.15, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob1 <- grobTree(textGrob(bquote(paste(r^2," = ",.(signif(rsq,2)))), x=0.8,  y=0.1, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob2 <- grobTree(textGrob(bquote(paste("p = ",.(signif(p_par,2)))), x=0.8,  y=0.05, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))


P6 <- ggplot(R_NoR_df, aes(lik, cm_OFC_sphere_betas)) + #A2
  geom_point() +
  geom_smooth(method = "lm",  col = "blue") +
  #geom_smooth(lm(R_NoR_df$cm_OFC_sphere_betas~R_NoR_df$lik, w = 1/R_NoR_df$cm_OFC_sphere_betas^2)
  scale_x_continuous(name="Pleasantness Index", expand = c(0, 0), limits=c(-2, 2)) +
  scale_y_continuous(expression(paste(beta, "  Reward > No Reward")), expand = c(0, 0), limits=c(-0.8, 1.2), breaks=c(seq.int(-0.8,1.2, by = 0.5))) +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), legend.position = "none", panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)  +
  annotation_custom(grob0)+
  annotation_custom(grob1)+
  annotation_custom(grob2)


#anatomicaly defined left cmOFC ~ lik
figure6 <- annotate_figure(P6,
                           top = text_grob(paste("Regular: anatomicaly defined left cm_OFC~ lik: p", round(p_par,5)), color = "black", face = "bold", size = 14))

P6


CI =CI.Rsq(rsq, n, k, level = 0.9)
stat_6 = paste("r²   = ", signif(rsq,3),  ", 90% CI [", signif(CI$LCL,3), ",", signif(CI$UCL,3), "]", ", p = ", round(p_par, 5))





# STATS cm_OFC  for CSp -----------------------------------6 mm sphere----------------------------
perm = summary(lmperm(CSp_df$cm_OFC_sphere_betas~CSp_df$eff))
p_par = perm$`parametric Pr(>|t|)`[2]
p_per = perm$`permutation Pr(>|t|)`[2]
rob = rlm(CSp_df$cm_OFC_sphere_betas~CSp_df$eff)
rsq = summary(lmRob(CSp_df$cm_OFC_sphere_betas~CSp_df$eff))$r.squared

weights = rob$w #estimated weights!
rob_sum = summary(rob)
t = rob_sum$coefficients[6]
df = rob_sum$df[2]
p_rob = 2*pt(t, df)
# kind of similar 
p_par
p_per
p_rob


CSp_df$weights = weights
CSp_df$weights = I(CSp_df$weights)



# check = lmRob(CSp_df$cm_OFC_sphere_betas~CSp_df$eff)
# summary(check)  #this one is not conservator at all it just leaves out the points

eff= CSp_df$eff
eff = zscore(eff)
CSp_df$lik = zscore(eff)


# PLOT cm_OFC rlm---------------------------------------------------------------


grob0 <- grobTree(textGrob("WLS:", x=0.8,  y=0.15, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob1 <- grobTree(textGrob(bquote(paste(r^2," = ",.(signif(rsq,2)))), x=0.8,  y=0.1, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob2 <- grobTree(textGrob(bquote(paste("p = ",.(signif(p_rob,2)))), x=0.8,  y=0.05, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))


P7 <- ggplot(CSp_df, aes(eff, cm_OFC_sphere_betas)) + #A2
  geom_point(aes(alpha=CSp_df$weights)) +
  geom_smooth(method = "rlm",  col = "mediumspringgreen") +
  #geom_smooth(lm(CSp_df$cm_OFC_sphere_betas~CSp_df$eff, w = 1/CSp_df$cm_OFC_sphere_betas^2)
  scale_x_continuous(name="Pavlovian-Instrumental Index", expand = c(0, 0), limits=c(-2.5, 2.5)) +
  scale_y_continuous(expression(paste(beta, "  CS+ > CS-")), expand = c(0, 0), limits=c(-0.2, 0.3), breaks=c(seq.int(-0.2,0.3, by = 0.1))) +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), legend.position = "none", panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)  +
  annotation_custom(grob0)+
  annotation_custom(grob1)+
  annotation_custom(grob2)

#anatomicaly defined left cm_OFC ~ effort
figure7 <- annotate_figure(P7,
                           top = text_grob(paste("Robust: anatomicaly defined left cm_OFC ~ effort: p", p_rob), color = "black", face = "bold", size = 14),
                           bottom = "Figure 2", fig.lab.face = "bold")


P7



CI =CI.Rsq(rsq, n, k, level = 0.9)
stat_7 = paste("r²   = ", signif(rsq,3),  ", 90% CI [", signif(CI$LCL,3), ",", signif(CI$UCL,3), "]", ", p = ", round(p_rob, 5))



#  PLOT norlm lm cm_OFC----------------------------------------------------------------

#  _R2_ 
rsq =summary(lm(CSp_df$cm_OFC_sphere_betas~eff))$r.squared


grob0 <- grobTree(textGrob("WLS:", x=0.8,  y=0.15, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob1 <- grobTree(textGrob(bquote(paste(r^2," = ",.(signif(rsq,2)))), x=0.8,  y=0.1, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

grob2 <- grobTree(textGrob(bquote(paste("p = ",.(signif(p_par,2)))), x=0.8,  y=0.05, hjust=0,
                           gp=gpar(col="black", fontsize=9, fontface="italic")))

P8 <- ggplot(CSp_df, aes(eff, cm_OFC_sphere_betas)) + #A2
  geom_point() +
  geom_smooth(method = "lm",  col = "mediumspringgreen") +
  #geom_smooth(lm(CSp_df$cm_OFC_sphere_betas~CSp_df$eff, w = 1/CSp_df$cm_OFC_sphere_sphere_betas^2)
  scale_x_continuous(name="Pavlovian-Instrumental Index", expand = c(0, 0), limits=c(-2.5, 2.5)) +
  scale_y_continuous(expression(paste(beta, "  CS+ > CS-")), expand = c(0, 0), limits=c(-0.2, 0.3), breaks=c(seq.int(-0.2,0.3, by = 0.1))) +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), legend.position = "none", panel.grid.minor = element_blank(),
                panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)  +
  annotation_custom(grob0)+
  annotation_custom(grob1)+
  annotation_custom(grob2)

#anatomicaly defined left pcore ~ effort
figure8 <- annotate_figure(P8,
                           top = text_grob(paste("Regular: anatomicaly defined left cm_OFC ~ effort: p", p_par), color = "black", face = "bold", size = 14),
                           bottom = "Figure 2", fig.lab.face = "bold")



P8


CI =CI.Rsq(rsq, n, k, level = 0.9)
stat_8 = paste("r² = ", signif(rsq,3),  ", 90% CI [", signif(CI$LCL,3), ",", signif(CI$UCL,3), "]", ", p = ", round(p_par, 5))





# FINAL FIGURES -----------------------------------------------------------

#sphere big
#P1  #rob cm_OFC ~ lik 
#P2   #reg cm_OFC ~ lik
#P3  #rob pCore ~ eff
#P4  #reg pcore~ eff

# sphere small

#P5  #rob cm_OFC ~ lik 
#P6   #reg cm_OFC ~ lik
#P7  #rob pCore ~ eff
#P8  #reg pcore~ eff



stat_1
stat_2
stat_3
stat_4

# anat smal sphere
stat_5
stat_6
stat_7
stat_8
