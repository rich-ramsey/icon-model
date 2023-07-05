rm(list = ls())
#------------------------
######
# In this sim, we re-run the **imitation** task using the noise disruption to the
#  face stim. THis is to show that the effects of the noise disruption are 
#  task-specific (ie affecting aa but not imitation)
##############
library(iac)

nnfile = 'sims/5x5_hub.yaml'
nn = read_net(nnfile, verbose = FALSE) 
nn = reset(nn)

#' Experiment parameters
set.seed(55)
nsims = 50 #' number of trials in each condition (congr and incon)
ncycles = 200 #' max duration of trial

#' Input parameters
vis_input = .5  #' the external input from visual stimuli to the feature maps
hub_input = .5
spatial_bias = .1  #' tonic bias towards the screen center: location (3,3): "BASE" = .1
animacy_bias = .1  #' tonic bias towards animate stimuli (ie fingers and faces)

#' DAMAGE
#' In this case disruption is specific to the processing of valenced stimuli
noisy_units = c("fh", "fa") #' happy and angry faces
unit_noise = .5

#' CONGRUENT
#' The target = A (requiring index finger=h1), and an index finger distrator are presented
#' The external inputs include a spatial bias to screen centre (where the target is
#'  presented), and a bias for animate objects (in this case fingers)
nn = reset(nn)
nn = clear_external(nn)
nn = set_external(nn, 
                  units = c('fA33', 'fI32', 'h1', 'h2', 's33', 'fI', 'fM', 'fa', 'fh'), 
                  act =   c(vis_input, vis_input, hub_input, hub_input, 
                            spatial_bias, 
                            animacy_bias, animacy_bias, animacy_bias, animacy_bias))
out_congr = sim_batch_noisy(nn, nsims=nsims, ncycles =ncycles,
                            noisy_units = noisy_units,
                            xtra_unit_noise = unit_noise)
out_congr = cbind(data.frame(task = 'congr'), out_congr)

#' INCONGRUENT
#' #' Exactly like congruent, except that a middle finger distractor is presented
nn = reset(nn)
nn = clear_external(nn)
nn = set_external(nn, 
                  units = c('fA33', 'fM32', 'h1', 'h2', 's33', 'fI', 'fM', 'fa', 'fh'), 
                  act =   c(vis_input, vis_input, hub_input, hub_input, 
                            spatial_bias, 
                            animacy_bias, animacy_bias, animacy_bias, animacy_bias))
out_incon = sim_batch_noisy(nn, nsims=nsims, ncycles =ncycles,
                            noisy_units = noisy_units,
                            xtra_unit_noise = unit_noise)
out_incon = cbind(data.frame(task = 'incon'), out_incon)

out = rbind(out_congr, out_incon)

#' explicitly identify the activations representing the correct and incorrect
#'  responses for the next step of RT and accuracy analysis
out$correct_resp = out$index
out$incorrect_resp = out$middle

#' save the data with a unique filename
if(nsims > 10) {
  save_filename = sprintf("sims/app_avoid/data/rdata/aa_imitate_noisy_faces(%02d)_%s-%s.RData", 
                         unit_noise*100, Sys.Date(), format(Sys.time(),"%H%M"))
  save(nn, out, file = save_filename)
}

