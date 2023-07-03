########

# Search task : Find the target letter A in the field of distractor B's and then
# touch the target location. Two set sizes are used, 3 (1 target + 2
# distractors) and 10 (1 target + 9 distractors). There is always a target
# present. The correct response is activating the touch action map for the
# target location.
#######
library(iac)

search_task = function(network, nsims, ncycles) {
  #' Input parameters
  vis_input = .5  #' the external input from visual stimuli to the feature maps
  hub_input = .5
  spatial_bias = .1  #' tonic bias towards the screen center: location (3,3)
  animacy_bias = .1  #' tonic bias towards animate stimuli (ie fingers and faces)
  
  #' search -- set size = 10
  network = reset(network)
  network = clear_external(network)
  network = set_external(network, 
                    units = c('fB11', 'fB12', 'fB13', 'fB14', 'fB15',
                              'fB51', 'fB52', 'fA53', 'fB54', 'fB55',
                              'h11', 's33'),
                    act =   c(vis_input, vis_input, vis_input, vis_input, vis_input, 
                              vis_input, vis_input, vis_input, vis_input, vis_input, 
                              hub_input, spatial_bias))
  
  out_search10 = sim_batch(network, nsims=nsims, ncycles =ncycles)
  out_search10$setsize = 10
  
  #' search -- set size = 3
  network = reset(network)
  network = clear_external(network)
  network = set_external(network, 
                    units = c('fB11', 'fB15', 'fA53',
                              'h11', 's33'),
                    act =   c(vis_input, vis_input, vis_input, 
                              hub_input, spatial_bias))
  out_search03 = sim_batch(network, nsims=nsims, ncycles = ncycles)
  out_search03$setsize = 3
  
  
  out = rbind(out_search03, out_search10)
  out$task = as.factor(out$setsize)
  return(out)
}
