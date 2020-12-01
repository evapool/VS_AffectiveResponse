## R code for FOR BMS PLOT
## last modified on December 2020 by David MUNOZ TORD

# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse)

# SETUP ------------------------------------------------------------------

task = 'PIT'

# Set working directory
path <- file.path(paste('~/REWOD/DERIVATIVES/GLM/', task, '/BMS', sep = '')) 

setwd(path)

suppressWarnings(PIT_BMS <- read_csv(paste('~/REWOD/DERIVATIVES/GLM/', task, '/BMS/', task, '_BMS.csv', sep = ''),    col_types = cols(X4 = col_skip())))
PIT_BMS$glm = c('04', '03', '09', '13')
# PIT plot from MACS average results in the striatum


PIT_BMS$glm = as.factor(PIT_BMS$glm)
pl = ggplot(PIT_BMS, aes(x = glm, y = mean, fill = I('gray40'), color = I('black'))) +
  geom_bar( stat = "identity", alpha = .3, width=0.5) +
  geom_errorbar(aes(ymax = mean + sd, ymin = mean - sd), width=0.05,  alpha=1)

plt = pl + 
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,1, by = 0.2)), limits = c(0,1)) +
  scale_x_discrete(labels=c("GLM 03", "GLM 04", "GLM 09", "GLM 13")) +
  #coord_fixed(ratio=0.9) +
  theme_bw() +
  theme(#aspect.ratio = 1.7/1,
    plot.margin = unit(c(1, 1, 1, 1), units = "cm"),
    plot.title = element_text(hjust = 0.5),
    #plot.caption = element_text(hjust = 0.5),
    panel.grid.major.x = element_blank() ,
    panel.grid.major.y = element_line(size=.2, color="lightgrey") ,
    axis.text.x =  element_text(size=10,  colour = "black"), #element_blank(), #element_text(size=10,  colour = "black", vjust = 0.5),
    axis.text.y = element_text(size=10,  colour = "black"),
    axis.title.x =  element_text(size=16), 
    axis.title.y = element_text(size=16),   
    axis.line.x = element_blank(),
    legend.position = "none",
    strip.background = element_rect(fill="white"))+ 
  labs(title = bquote(atop(bold('Bayesian Model Selection'), ~ '\nPavlovian Instrumental Transfer')),
       y =  "Average Exceedance Probability", x = "Model") #,


plot(plt)

cairo_pdf(file.path(path,paste(task,'PIT.pdf',  sep = "_")),
          width = 5.5,
          height = 6)

plot(plt)
dev.off()

# SETUP ------------------------------------------------------------------

task = 'hedonic'

# Set working directory
path <- file.path(paste('~/REWOD/DERIVATIVES/GLM/', task, '/BMS', sep = '')) 

setwd(path)

suppressWarnings(HED_BMS <- read_csv(paste('~/REWOD/DERIVATIVES/GLM/', task, '/BMS/', task, '_BMS.csv', sep = ''),    col_types = cols(X3 = col_skip())))

HED_BMS$glm = c('04', '15', '18')

# HED plot from MACS average results in the striatum

pl = ggplot(HED_BMS, aes(x = glm, y = mean, fill = I('gray40'), color = I('black'))) +
  geom_bar( stat = "identity", alpha = .3, width=0.5) +
  geom_errorbar(aes(ymax = mean + sd, ymin = mean - sd), width=0.05,  alpha=1)

plt = pl + 
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,1, by = 0.2)), limits = c(0,1)) +
  scale_x_discrete(labels=c("GLM 04", "GLM 15", "GLM 18")) +
  #coord_fixed(ratio=0.9) +
  theme_bw() +
  theme(#aspect.ratio = 1.7/1,
    plot.margin = unit(c(1, 1, 1, 1), units = "cm"),
    plot.title = element_text(hjust = 0.5, size=14),
    #plot.caption = element_text(hjust = 0.5),
    panel.grid.major.x = element_blank() ,
    panel.grid.major.y = element_line(size=.2, color="lightgrey") ,
    axis.text.x =  element_text(size=10,  colour = "black"), #element_blank(), #element_text(size=10,  colour = "black", vjust = 0.5),
    axis.text.y = element_text(size=10,  colour = "black"),
    axis.title.x =  element_text(size=16), 
    axis.title.y = element_text(size=16),   
    axis.line.x = element_blank(),
    legend.position = "none",
    strip.background = element_rect(fill="white"))+ 
  labs(title = bquote(atop(bold('Bayesian Model Selection'), ~ '\n Hedonic Reactivity')),
       y =  "Average Exceedance Probability", x = "Model") #,


plot(plt)

cairo_pdf(file.path(path,paste(task,'HED.pdf',  sep = "_")),
          width = 5.5,
          height = 6)

plot(plt)
dev.off()
