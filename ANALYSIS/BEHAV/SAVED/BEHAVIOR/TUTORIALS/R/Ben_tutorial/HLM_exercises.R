###############################
# BEN MEULEMAN
# HLM WORKSHOP
#
# CISA - UNIVERSITY OF GENEVA
# 29.01.2016
###############################
# EXERCISES
###############################



## EX1. RESULTS REPLICATION
###############################
#
# Try to replicate the analyses conducted during the theory class for the sleep data. 
# Use the scripts HLM_sleep.r and HLM_sleep_plus.r as a basis for this.
#


## EX2. SLEEP PLUS DATA
###############################
#
# For the extended sleep deprivation study, researchers hypothesized that there would
# be an interaction between age and hours of sleep deprivation, such that for older
# people attention would decline faster for increasing deprivation. How can you test this
# hypothesis?
#
# Proceed with model selection in the usual fashion. First random effects, then fixed
# effects. However, remember to maintain a full fixed effects structure while comparing
# different random effects structures.
#
# For this interaction model, investigate the need for a random deprivation slope. How are
# the results different from the example in the slides? What could be an explanation...?
#


## EX3. RESTAURANTS DATA
###############################
#
# For the restaurants study, find out how to conduct pairwise comparisons between conditions
# as a follow-up to the overall ANOVA. Remember that these pairwise comparisons should
# correct for the covariance structure fitted by the random effects (no regular t-tests!).
#
# The summary output could provide a solution. Depending on the contrast coding of the
# independents, we can test specific hypotheses.
#
# Check how the functions "contrasts" and "contr.treatment" can be used to conduct pair-
# wise comparisons. For help on any function, simply type ?function
#


## EX4. AFFECTIVE PRIMING
###############################
#
# Conduct a classic repeated measures (M)ANOVA on the affective priming data. To do this,
# use the Excel version of the data. Average the trial-level RTs per subject and per
# condition using the pivot table function in Excel, and transform the data to wide format.
#
# 1. Load these data in SPSS/Statistica and conduct a PRIME x TARGET repeated measures
#    (M)ANOVA.
#
# 2. Export the wide format data back to "csv" format and load them into R. If you know
#    how to conduct a repeated measures (M)ANOVA in R, run it here.
#
# How are the results of the classic approaches different from the HLM approach? How are the
# results different between the two classic approaches (MANOVA vs ANOVA), if at all?
#
# Which analysis would have your preference and why?
#


## EX5. ROBOT PONIES
###############################
#
# Investigate the effect of "Province" and/or "Location" for the robot ponies data. Can
# the location variable potentially explain why there are random sales trends between
# stores following the advertising campaign?
#
# Add an explicit "Advertising" variable (2 levels: pre or post) to the dataset and 
# investigate how it can be used in the trend modelling. In what way are interactions 
# between "Advertising" and "Time" different from the spline model approach?
#
# Tip: use the "ifelse" function in R to create a binary variable
#
# Average the data for the two advertising conditions (pre or post) and run a simple paired
# t-test on the data. Do you obtain the same information as the more complicated HLM?
# If so, what are the arguments pro and con against either approach?
#
# Tip: use the "aggregate" function in R to average data. The function has a formula
# interface similar to "lmer"!
#

