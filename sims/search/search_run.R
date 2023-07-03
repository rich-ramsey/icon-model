rm(list = ls())
#------------------------
library(iac)
source("sims/search/search_task.R")

# baseline search conditions, standard network
nnfile = 'sims/5x5_hub.yaml'
nn = read_net(nnfile) 

# Experiment parameters
set.seed(55)
nsims = 50 #' number of trials in each condition (congr and incon)
ncycles = 200 #' max duration of trial

# run the task -- sourced to keep consistency for the search variants
# run at the top level rather than as a 
out = search_task(nn, nsims, ncycles)

#' save the data with a unique filename
if(nsims > 10) {
  save_filename = sprintf("sims/search/search_base_%s-%s.RData", 
                          Sys.Date(), format(Sys.time(),"%H%M"))
  save(nn, out, file = save_filename)
}


