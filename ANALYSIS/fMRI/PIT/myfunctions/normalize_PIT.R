
library("RNOmni")

analysis_path <-'~/REWOD/DERIVATIVES/GLM/PIT/GLM-04/group_covariates/'

setwd(analysis_path)


CSp_CSm <- read.delim(file.path(analysis_path, "CSp_CSm_eff_meancent.txt"))



# COVARIATE RANKNORM ------------------------------------------------------



# Draw from chi-1 distribution
CSp_CSm$eff = RankNorm(CSp_CSm$eff)

# Plot density of transformed measurement
#plot(density(Z));

write.table(CSp_CSm, (file.path(analysis_path, "CSp-CSm_eff_rank_old.txt")), row.names = F, sep="\t")

