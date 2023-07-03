# clear everything
rm(list=ls())

library(iac)

# Basic imitation task, used for analysis in E1, and as baseline condition
# in E2 salience manipulation

animacy_bias = .1
save_filename = sprintf("sims/imitation/out_imi_basic_%s-%s.RData", 
                       Sys.Date(), format(Sys.time(),"%H%M"))

# to ensure consistency between E2 comparisons, the experiment is sourced
# This is run at the top level rather than as a function so that the resulting
# network and simulation results are accessible in the global environment for
# easy investigating
source("sims/imitation/imitation_task.R")

# a quick overview of results (currently stored in variable "out")
source("sims/imitation/imitation_analysis.R")

