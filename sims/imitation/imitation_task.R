###################
# Imitation task, similar to Brass
###################
# These variables need to be set before sourcing this file
# NB animacy_bias is varied in E2 and so must be set here
stopifnot(exists("save_filename"))
stopifnot(exists("animacy_bias"))

# The imitation task:
# An A or B target letter appears in center location 3,3
# If an A, make index finger response, if B make middle response
# There is also a task-irrelevant finger stimulus at 3,2
#  with a prepotent SR association (defined in the network files)
# The presence of these stimuli is made by external activation of the appropriate
#  locations in the different feature maps. The letter A at location 3,3 means
#  activation of fA33 (feature map for A, location 3,3), An index finger
#  stimulus at location 3,2 means activation of fI32
# Congruent: the prepotent response is the same as the required response
# Incongruent: prepotent response conflicts with required response
# For the simulation, it is always an A target, so always looking for activation
#  of the index-finger response
# Congruent trials the distractor is an index finger, incongruent a middle finger
# 
# hub units code the arbitrary task response:
# {from:  h1, to: [fA, button_press, index],  weight: *hub_weight, directives: oneway},
# {from:  h2, to: [fB, button_press, middle], weight: *hub_weight, directives: oneway},
# The nohub version of the task is exactly the same but because the weights 
#  from the hub units to other units is set to 0, there is no way for the 
#  hub to do anything, ie no hub. Without an effective hub, there is no
#  way to make an arbitrary response to the target letter. So essentially, 
#  the "participant" in the no-hub task is staring at the screen without a 
#  task to execute

# Standardised experiment and input parameters

nnfile = 'sims/5x5_hub.yaml'
set.seed(55)
nsims = 50
ncycles = 200
vis_input = .5  # the external input from visual stimuli to the feature maps
hub_input = .5
spatial_bias = .1  # tonic bias towards the screen center: location (3,3)

nn = read_net(nnfile) 


# CONGRUENT
# The target = A (requiring index finger=h1), and an index finger distrator are
# presented The external inputs include a spatial bias to screen centre (where
# the target is presented), and a bias for animate objects (in this case
# fingers)
nn = reset(nn)
nn = clear_external(nn)
nn = set_external(nn, 
                  units = c('fA33', 'fI32', 's33', 'fI', 'fM', 'h1', 'h2'), 
                  act =   c(vis_input, vis_input, spatial_bias, 
                            animacy_bias, animacy_bias, hub_input, hub_input))

out_congr = sim_batch(nn, nsims=nsims, ncycles =ncycles)
out_congr = cbind(data.frame(task = 'congr'), out_congr)

# INCONGRUENT
# # Exactly like congruent, except that a middle finger distractor is presented
nn = reset(nn)
nn = clear_external(nn)
nn = set_external(nn, 
                  units = c('fA33', 'fM32', 's33', 'fI', 'fM', 'h1', 'h2'), 
                  act =   c(vis_input, vis_input, spatial_bias, 
                            animacy_bias, animacy_bias, hub_input, hub_input))
out_incon = sim_batch(nn, nsims=nsims, ncycles =ncycles)
out_incon = cbind(data.frame(task = 'incon'), out_incon)

out = rbind(out_congr, out_incon)

# explicitly identify the activations representing the correct and incorrect
#  responses for the next step of RT and accuracy analysis
out$correct_resp = out$index
out$incorrect_resp = out$middle

message("Finished.")
# save the network and data with a unique filename (unless it's just a test run:
# ie nsims <= 10)
if(nsims > 10) {
  save(nn, out, file = save_filename)
  message("Simulation output and network saved as file %s", save_filename)
}
