rm(list = ls())
#------------------------
library(iac)
####
# Source the global experiment parameters to avoid inconsistencies between
# the runs of E1 (basic aa) and E2 (noise disruption)
source('sims/app_avoid/aa_task.R')

# DAMAGE
# In this case disruption is specific to the processing of faces
# fa = angry, fh = happy 
G$noisy_units = c("fh", "fa") 
G$unit_noise = .0



set.seed(55)

run_aa_noise_sims = function(network, label, ext_units) {
  network = reset(network)
  network = clear_external(network)
  ext_units = G[[ext_units]]
  network = set_external(network, units = ext_units, act = G[['ext_acts']])
  out = sim_batch_noisy(network, nsims = G[['nsims']], ncycles = G[['ncycles']],
                        noisy_units = G[['noisy_units']], 
                        xtra_unit_noise = G[['unit_noise']])
  out = cbind(data.frame(task = label), out)
  return(out)
}

nn = read_net(G[['nnfile']], verbose = FALSE)
nn$params$noise = .05

congr_out = run_aa_noise_sims(nn, "congr", 'congr_task')
incon_out = run_aa_noise_sims(nn, "incon", 'incon_task')
out = rbind(congr_out, incon_out)

# Explicitly identify the activations representing the correct and incorrect
# responses for the next step of RT and accuracy analysis
out$correct_resp = out$aa13
out$incorrect_resp = out$aa53
message('Finished.')

#' save the data with a unique filename
if(G[['nsims']] > 10) {
  save_filename = sprintf("sims/app_avoid/aa_stimglob_noise(%02d_%03d)_%s-%s.RData", 
                          100*G$unit_noise, 1000*nn$params$noise,
                          Sys.Date(), format(Sys.time(),"%H%M"))
  save(nn, out, file = save_filename)
  message(sprintf("Simulation output and network saved as file %s", 
                  save_filename))
}

# a quick overview of results (currently stored in variable "out")
source("sims/app_avoid/aa_analysis.R")
