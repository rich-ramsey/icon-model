# clear everything
rm(list=ls())

library(iac)

# E2 salience manipulation
# Relative salience of the distractor is DECREASED

animacy_bias = .05
save_filename = sprintf("sims/imitation/out_animacy(%02d)_%s-%s.RData", 
                       100*animacy_bias, Sys.Date(), format(Sys.time(),"%H%M"))

# to ensure consistency between E2 comparisons, the experiment is sourced
source("sims/imitation/imitation_task.R")

# a quick overview of results (currently stored in variable "out")
source("sims/imitation/imitation_analysis.R")
