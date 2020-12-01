#load libraries
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}

pacman::p_load(RNOmni, tidyverse, dplyr, plyr)

home   <- '~/REWOD'
#home       <- '/Users/evapool/mountpoint2'

#declare variables
GLM = "GLM-04"

s = c("01", "02", "03", "04", "05", "06", "07", "09", "10", "11", "12", "13","14", "15", "16", "17","18", "20", "21", "22","23", "24","25", "26")

taskDIR = "PIT"

analysis_path <- paste(home,'/DERIVATIVES/GLM/PIT/',GLM, '/group_covariates/', sep = '')

setwd(analysis_path)

data_path <- file.path(home,'DERIVATIVES/BEHAV') 



df = cbind(s, 1:length(s))
l = 0
for(i in s) {
  l = l + 1
  subj = paste('sub-', i, sep = '')
  covpath = paste(home, '/DERIVATIVES/GLM/',taskDIR, '/' , GLM , '/', subj , '/timing/', sep = '')
  cov_minus <- read.delim(file.path(covpath, paste(GLM, '_task-PIT_PIT_CS_CSm.txt', sep = '')), header = F, sep ='\t') # read in dataset
  cov_plus <- read.delim(file.path(covpath, paste(GLM, '_task-PIT_PIT_CS_CSp.txt', sep = '')), header = F, sep ='\t') # read in dataset
  
  CSp_CSm = cov_plus - cov_minus
  df[l,2] = mean(CSp_CSm[,3])
}
  
colnames(df) = c('id', 'n_grips')
df = as_tibble(df)
df$id = as.numeric(as.character(df$id))
df$n_grips = as.numeric(as.character(df$n_grips))

# COVARIATE  ------------------------------------------------------
#centered
df$n_gripsC = scale(df$n_grips, scale = F)
plot(density(df$n_gripsC)) #skewed
diffC = select(df, c(id, n_gripsC))

#z-scored
df$n_gripsZ = scale(df$n_grips)
plot(density(df$n_gripsZ)) #skewed
diffZ = select(df, c(id, n_gripsZ))

# Ranked
df$n_gripsR = rank(df$n_gripsZ)
plot(density(df$n_gripsR))
diffR = select(df, c(id, n_gripsR))

# RankNorm (Draw from chi-1 distribution)
df$n_gripsT = RankNorm(df$n_gripsZ[,])
plot(density(df$n_gripsT))
diffT = select(df, c(id, n_gripsT))

write.table(diffC, (file.path(analysis_path, "CSp-CSm_eff_c.txt")), row.names = F, sep="\t") 
write.table(diffZ, (file.path(analysis_path, "CSp-CSm_eff_z.txt")), row.names = F, sep="\t")
write.table(diffR, (file.path(analysis_path, "CSp-CSm_eff_rank.txt")), row.names = F, sep="\t")
write.table(diffT, (file.path(analysis_path, "CSp-CSm_eff_ranknorm.txt")), row.names = F, sep="\t")