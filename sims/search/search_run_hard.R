rm(list = ls())
#------------------------

library(iac)
source("sims/search/search_task.R")

# difficult search conditions
nnfile = 'sims/5x5_hub.yaml'
nn = read_net(nnfile) 
#' reduce the within-map inhibition
nn = connect_units(nn, weight = .25, from="feature_maps", to="feature_maps", 
                   from_dims = 1, to_dims = 1,
                   directives = c("add", "others"))

# Experiment parameters
set.seed(55)
nsims = 50 #' number of trials in each condition (congr and incon)
ncycles = 200 #' max duration of trial

# run the task -- sourced to keep consistency for the search variants
# run at the top level rather than as a 
out = search_task(nn, nsims, ncycles)

#' save the data with a unique filename
if(nsims > 10) {
  save_filename = sprintf("sims/search/data/rdata/search_hard_%s-%s.RData", 
                          Sys.Date(), format(Sys.time(),"%H%M"))
  save(nn, out, file = save_filename)
}




