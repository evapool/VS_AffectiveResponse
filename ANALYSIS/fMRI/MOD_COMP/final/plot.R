## R code for FOR BMS PLOT
## last modified on September 2020 by David MUNOZ TORD

# PRELIMINARY STUFF ----------------------------------------
if(!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}
pacman::p_load(tidyverse, Cairo)

# SETUP ------------------------------------------------------------------

task = 'BMS'

# Set working directory
analysis_path <- file.path('~/REWOD/DERIVATIVES/BMS') 
figures_path  <- file.path('~/REWOD/DERIVATIVES/FIGURES/BMS') 

setwd(analysis_path)

# PIT plot from MACS average results in the striatum
glm = c(0, 1)
ave = c(0.6288,0.3712)
sd = c(0.0889,0.0889)

data = cbind(glm,ave,sd)

data = as_tibble(data)
data$glm = as.factor(data$glm)
pl = ggplot(data, aes(x = glm, y = ave, fill = I('gray40'), color = I('black'))) +
  geom_bar( stat = "identity", alpha = .3, width=0.5) +
  geom_errorbar(aes(ymax = ave + sd, ymin = ave - sd), width=0.05,  alpha=1)

plt = pl + 
      scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,1, by = 0.2)), limits = c(0,1)) +
      scale_x_discrete(labels=c("GLM I (base)", "GLM II (parametric)")) +
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

cairo_pdf(file.path(figures_path,paste(task,'PIT.pdf',  sep = "_")),
          width = 5.5,
          height = 6)

plot(plt)
dev.off()

# HED plot from MACS average results in the striatum
glm = c(0, 1)
ave = c(0.1056, 0.8944)
sd = c(0.0764,0.0764)

data = cbind(glm,ave,sd)

data = as_tibble(data)
data$glm = as.factor(data$glm)
pl = ggplot(data, aes(x = glm, y = ave, fill = I('gray40'), color = I('black'))) +
  geom_bar( stat = "identity", alpha = .3, width=0.5) +
  geom_errorbar(aes(ymax = ave + sd, ymin = ave - sd), width=0.05,  alpha=1)

plt = pl + 
  scale_y_continuous(expand = c(0, 0), breaks = c(seq.int(0,1, by = 0.2)), limits = c(0,1)) +
  scale_x_discrete(labels=c("GLM I (base)", "GLM II (parametric)")) +
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

cairo_pdf(file.path(figures_path,paste(task,'HED.pdf',  sep = "_")),
          width = 5.5,
          height = 6)

plot(plt)
dev.off()