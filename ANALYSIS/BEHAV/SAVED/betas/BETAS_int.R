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
taskHED = 'hedonic'
taskPIT = 'PIT'
con_name = 'AMY'
con_name2 = 'Od_NoOd'
con1 = 'CSp-CSm'
con2 = 'Odor-NoOdor'
mod1 = 'eff'
mod2 = 'int'
mod3 = 'lik'



## R code for FOR REWOD_HED
# Set working directory -------------------------------------------------


analysis_path <- file.path('~/REWOD/DERIVATIVES/ANALYSIS') 
setwd(analysis_path)

# open dataset 
BETAS_O_N <- read.delim(file.path(analysis_path, taskHED, 'ROI', paste('extracted_betas_', con_name2,'.txt',sep="")), header = T, sep ='\t') # read in dataset

INT_O_N <- read.delim(file.path(analysis_path, taskHED, 'GLM-04', 'group_covariates', paste(con2,'_', mod2, '_meancent.txt',sep="")), header = T, sep ='\t')  # read in dataset

LIK_O_N <- read.delim(file.path(analysis_path, taskHED, 'GLM-04', 'group_covariates', paste(con2,'_', mod3, '_meancent.txt',sep="")), header = T, sep ='\t')  # read in dataset



O_N_df = merge(BETAS_O_N, INT_O_N, by.x = "ID", by.y = "subj", all.x = TRUE)
O_N_df = merge(O_N_df, LIK_O_N, by.x = "ID", by.y = "subj", all.x = TRUE)

# define factors
O_N_df$ID <- factor(O_N_df$ID)

k =2
n =24




# open dataset 
BETAS_CSp_CSm <- read.delim(file.path(analysis_path, taskPIT, 'ROI', paste('extracted_betas_',con1 ,'_via_', con_name2, '.txt',sep="")), header = T, sep ='\t') # read in dataset

EFF <- read.delim(file.path(analysis_path, taskPIT, 'GLM-04', 'group_covariates', paste(con1,'_', mod1, '_rank.txt',sep="")), header = T, sep ='\t') # read in dataset


# merge
CSp_CSm_df = merge(BETAS_CSp_CSm, EFF, by.x = "ID", by.y = "subj", all.x = TRUE)


# define factors
CSp_CSm_df$ID <- factor(CSp_CSm_df$ID)

# zscore
CSp_CSm_df$eff = zscore(CSp_CSm_df$eff)

O_N_df$int = zscore(O_N_df$int )
O_N_df$lik = zscore(O_N_df$lik )




# PLOT FUNCTIONS --------------------------------------------------------------------


ggplotRegression <- function (fit) {
  
  ggplot(fit$model, aes_string(x = names(fit$model)[2], y = names(fit$model)[1])) + 
    geom_point() +
    stat_smooth(method = "lm", col = "red") +
    labs(title = paste("  R2 = ",signif(summary(fit)$r.squared, 5),
                       #"Intercept =",signif(fit$coef[[1]],5 ),
                       #" Slope =",signif(fit$coef[[2]], 5),
                       "  &  P =",signif(summary(fit)$coef[2,4], 5)))+
    theme(plot.title = element_text(size = 10, hjust =1))
  
}


# signif ------------------------------------------------------------------
perm = summary(lmperm(O_N_df$AMY_AAA_betas~O_N_df$int))
p_par = perm$`parametric Pr(>|t|)`[2]
p_per = perm$`permutation Pr(>|t|)`[2]
rob = rlm(O_N_df$AMY_AAA_betas~O_N_df$int)
rsq = signif(summary(lmRob(O_N_df$AMY_AAA_betas~O_N_df$int))$r.squared,1)

weights = rob$w #estimated weights!
rob_sum = summary(rob)
t = rob_sum$coefficients[6]
df = rob_sum$df[2]
p_rob = 2*(1-pt(t, df))
# kind of similar 
p_par
p_per
p_rob

O_N_df$AMYweights = weights
O_N_df$AMYweights = I(O_N_df$AMYweights)



# PLOT PIRIF ~int rob ---------------------------------------------------------------

P1 <- ggplot(O_N_df, aes(int, AMY_AAA_betas)) + #A2
  geom_point(aes(alpha=O_N_df$AMYweights)) +
  geom_smooth(method = "rlm",  col = "orange") +
  #geom_smooth(lm(CSp_df$LEFT_BLVP_betas~CSp_df$eff, w = 1/CSp_df$LEFT_BLVP_betas^2)
  scale_x_continuous(name="Perceived intensity", expand = c(0, 0), limits=c(-2, 3)) +
  scale_y_continuous(expression(paste(beta, "  Odor > No Odor")), expand = c(0, 0), limits=c(-0.8, 2.2), breaks=c(seq.int(-0.8,2.2, by = 0.6))) +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), legend.position = "none", panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)

#anatomicaly defined left BLVP ~ effort
figure1 <- annotate_figure(P1,
                           top = text_grob(paste("Robust: anatomicaly defined left pirif ~ int: p", p_rob), color = "black", face = "bold", size = 14),
                           bottom = "Figure 2", fig.lab.face = "bold")
P1



CI =CI.Rsq(rsq, n, k, level = 0.9)
paste("r²   = ", signif(rsq,3),  ", 90% CI [", signif(CI$LCL,3), ",", signif(CI$UCL,3), "]", ", p = ", round(p_rob, 5))


# PLOT PIRIF ~int  ---------------------------------------------------------------

P2 <- ggplot(O_N_df, aes(int, AMY_AAA_betas)) + #A2
  geom_point() +
  geom_smooth(method = "lm",  col = "orange") +
  #geom_smooth(lm(CSp_df$LEFT_BLVP_betas~CSp_df$eff, w = 1/CSp_df$LEFT_BLVP_betas^2)
  scale_x_continuous(name="Perceived intensity", expand = c(0, 0), limits=c(-2, 3)) +
  scale_y_continuous(expression(paste(beta, "  Odor > No Odor")), expand = c(0, 0), limits=c(-0.8, 2.2), breaks=c(seq.int(-0.8,2.2, by = 0.6))) +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), legend.position = "none", panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)

#anatomicaly defined left BLVP ~ effort
figure2 <- annotate_figure(P1,
                           top = text_grob(paste("no robust: anatomicaly defined left pirif ~ int: p", p_rob), color = "black", face = "bold", size = 14),
                           bottom = "Figure 2", fig.lab.face = "bold")
P2


#  _R2_ = pirif _ int
rsq = summary(lm(O_N_df$AMY_AAA_betas~O_N_df$int))$r.squared

CI =CI.Rsq(rsq, n, k, level = 0.9)
paste("r²   = ", signif(rsq,3),  ", 90% CI [", signif(CI$LCL,3), ",", signif(CI$UCL,3), "]", ", p = ", round(p_par, 5))




# #LIKING -----------------------------------------------------------------

# signif ------------------------------------------------------------------
perm = summary(lmperm(O_N_df$AMY_AAA_betas~O_N_df$lik))
p_par = perm$`parametric Pr(>|t|)`[2]
p_per = perm$`permutation Pr(>|t|)`[2]
rob = rlm(O_N_df$AMY_AAA_betas~O_N_df$lik)
rsq = summary(lmRob(O_N_df$AMY_AAA_betas~O_N_df$lik))$r.squared

weights = rob$w #estimated weights!
rob_sum = summary(rob)
t = rob_sum$coefficients[6]
df = rob_sum$df[2]
p_rob = 2*(1-pt(t, df))
# kind of similar 
p_par
p_per
p_rob

O_N_df$AMYweights = weights
O_N_df$AMYweights = I(O_N_df$AMYweights)

# PLOT PIRIF ~lik rob ---------------------------------------------------------------

P3 <- ggplot(O_N_df, aes(lik, AMY_AAA_betas)) + #A2
  geom_point(aes(alpha=O_N_df$AMYweights)) +
  geom_smooth(method = "rlm",  col = "red") +
  #geom_smooth(lm(CSp_df$LEFT_BLVP_betas~CSp_df$eff, w = 1/CSp_df$LEFT_BLVP_betas^2)
  scale_x_continuous(name="Hedonic experience", expand = c(0, 0), limits=c(-2.5, 3)) +
  scale_y_continuous(expression(paste(beta, "  Odor > No Odor")), expand = c(0, 0), limits=c(-0.8, 2), breaks=c(seq.int(-0.8,2, by = 0.5))) +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), legend.position = "none", panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)

#anatomicaly defined left BLVP ~ effort
figure3 <- annotate_figure(P1,
                           top = text_grob(paste("Robust: anatomicaly defined left pirif ~ lik: p", p_rob), color = "black", face = "bold", size = 14),
                           bottom = "Figure 2", fig.lab.face = "bold")
P3



CI =CI.Rsq(rsq, n, k, level = 0.9)
paste("r²   = ", signif(rsq,3),  ", 90% CI [", signif(CI$LCL,3), ",", signif(CI$UCL,3), "]", ", p = ", round(p_rob, 5))


# PLOT PIRIF ~lik  ---------------------------------------------------------------

P4 <- ggplot(O_N_df, aes(lik, AMY_AAA_betas)) + #A2
  geom_point() +
  geom_smooth(method = "lm",  col = "red") +
  #geom_smooth(lm(CSp_df$LEFT_BLVP_betas~CSp_df$eff, w = 1/CSp_df$LEFT_BLVP_betas^2)
  scale_x_continuous(name="Hedonic experience", expand = c(0, 0), limits=c(-2.5, 3)) +
  scale_y_continuous(expression(paste(beta, "  Odor > No Odor")), expand = c(0, 0), limits=c(-0.8, 2), breaks=c(seq.int(-0.8,2, by = 0.5))) +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), legend.position = "none", panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)

#anatomicaly defined left BLVP ~ effort
figure4 <- annotate_figure(P1,
                           top = text_grob(paste("no robust: anatomicaly defined left pirif ~ lik: p", p_rob), color = "black", face = "bold", size = 14),
                           bottom = "Figure 2", fig.lab.face = "bold")
P4


#  _R2_ = pirif _ lik
rsq = summary(lm(O_N_df$AMY_AAA_betas~O_N_df$lik))$r.squared

CI =CI.Rsq(rsq, n, k, level = 0.9)
paste("r²   = ", signif(rsq,3),  ", 90% CI [", signif(CI$LCL,3), ",", signif(CI$UCL,3), "]", ", p = ", round(p_par, 5))





# # EFFORT ----------------------------------------------------------------

# signif ------------------------------------------------------------------
perm = summary(lmperm(CSp_CSm_df$AMY_AAA_betas~CSp_CSm_df$eff))
p_par = perm$`parametric Pr(>|t|)`[2]
p_per = perm$`permutation Pr(>|t|)`[2]
rob = rlm(CSp_CSm_df$AMY_AAA_betas~CSp_CSm_df$eff)
rsq = summary(lmRob(CSp_CSm_df$AMY_AAA_betas~CSp_CSm_df$eff))$r.squared

weights = rob$w #estimated weights!
rob_sum = summary(rob)
t = rob_sum$coefficients[6]
df = rob_sum$df[2]
p_rob = 2*(1-pt(t, df))
# kind of similar 
p_par
p_per
p_rob

CSp_CSm_df$AMYweights = weights
CSp_CSm_df$AMYweights = I(CSp_CSm_df$AMYweights)

# PLOT PIRIF ~eff rob ---------------------------------------------------------------

P5 <- ggplot(CSp_CSm_df, aes(eff, AMY_AAA_betas)) + #A2
  geom_point(aes(alpha=CSp_CSm_df$AMYweights)) +
  geom_smooth(method = "rlm",  col = "blue") +
  #geom_smooth(lm(CSp_df$LEFT_BLVP_betas~CSp_df$eff, w = 1/CSp_df$LEFT_BLVP_betas^2)
  scale_x_continuous(name="Mobilized effort", expand = c(0, 0), limits=c(-2.5, 2.5)) +
  scale_y_continuous(expression(paste(beta, "  CS+ > CS-")), expand = c(0, 0), limits=c(-0.30, 0.30), breaks= c(-0.3,-0.2,-0.1, 0, 0.1, 0.2, 0.3)) +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), legend.position = "none", panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)

#anatomicaly defined left BLVP ~ effort
figure5 <- annotate_figure(P1,
                           top = text_grob(paste("Robust: anatomicaly defined left pirif ~ eff: p", p_rob), color = "black", face = "bold", size = 14),
                           bottom = "Figure 2", fig.lab.face = "bold")
P5

CI =CI.Rsq(rsq, n, k, level = 0.9)
paste("r²   = ", signif(rsq,3),  ", 90% CI [", signif(CI$LCL,3), ",", signif(CI$UCL,3), "]", ", p = ", round(p_rob, 5))


# PLOT PIRIF ~eff  ---------------------------------------------------------------

P6 <- ggplot(CSp_CSm_df, aes(eff, AMY_AAA_betas)) + #A2
  geom_point() +
  geom_smooth(method = "lm",  col = "blue") +
  #geom_smooth(lm(CSp_df$LEFT_BLVP_betas~CSp_df$eff, w = 1/CSp_df$LEFT_BLVP_betas^2)
  scale_x_continuous(name="Mobilized effort", expand = c(0, 0), limits=c(-2.5, 2.5)) +
  scale_y_continuous(expression(paste(beta, "  CS+ > CS-")), expand = c(0, 0), limits=c(-0.30, 0.30), breaks= c(-0.3,-0.2,-0.1, 0, 0.1, 0.2, 0.3)) +
  theme(plot.subtitle = element_text(size = 8, vjust = -90, hjust =1), panel.grid.major = element_blank(), legend.position = "none", panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"), margin = NULL, aspect.ratio=1)

#anatomicaly defined left BLVP ~ effort
figure6 <- annotate_figure(P1,
                           top = text_grob(paste("no robust: anatomicaly defined left pirif ~ eff: p", p_rob), color = "black", face = "bold", size = 14),
                           bottom = "Figure 2", fig.lab.face = "bold")
P6


#  _R2_ = pirif _ eff
rsq =summary(lm(CSp_CSm_df$AMY_AAA_betas~CSp_CSm_df$eff))$r.squared

CI =CI.Rsq(rsq, n, k, level = 0.9)
paste("r²   = ", signif(rsq,3),  ", 90% CI [", signif(CI$LCL,3), ",", signif(CI$UCL,3), "]", ", p = ", round(p_par, 5))


