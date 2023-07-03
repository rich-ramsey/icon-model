#####
# Save the global experiment parameters here and source them to avoid
# inconsistencies between the runs of E1 (basic aa) and E2 (noise disruption)

# Run the task from E1_aa_run.R, E2_aa_noisy_stims.R, etc


###############################################
#' On each trial a valenced face (happy or angry) is presented side by side with 
#'  a neutral stimulu (in this case the letter B). On approach trials you touch 
#'  or otherwise approach the face. On avoid trials you touch the neutral stimulus.
#'  Congruent conditions = approach happy or avoid angry face
#'  Incongruent = approach angry or avoid happy
#' This experiment simulates the approach conditions. That means the correct response
#'  in both congruent and incongruent conditions is to approach the valenced stimuli,
#'  not the neutral one

#' THe relevant hub units: h5 and h5 = congr; h7 and h8 = incon conditions
# {from:  h5, to: [fh, approach], weight: *hub_weight, directives: oneway},
# {from:  h6, to: [fa, avoid], weight: *hub_weight, directives: oneway},
# {from:  h7, to: [fh, avoid], weight: *hub_weight, directives: oneway},
# {from:  h8, to: [fa, approach], weight: *hub_weight, directives: oneway},

# global parameters for aa task
G = list(
  nnfile = 'sims/5x5_hub.yaml',
  ncycles = 200,
  nsims = 50,
  vis_input = .5,
  hub_input = .5,
  spatial_bias = .1,
  animacy_bias = .1, 
  # CONGRUENT TASK SPEC
  # external inputs: happy on the left, neutral on the right and the hub units
  # representing the congruent task. The bias towards the screen centre and
  # towards both animate objects (faces) is there for consistency, even though
  # nothing appears in the centre and only face is present on each trial The
  # units need to be specified in this order to align with G$ext_acts
  congr_task = c('fh13', 'fB53', 'h5', 'h6', 's33', 'fa', 'fh'),
  # INCONGRUENT TASK
  # Similar but angry face to be presented and approached. 
  incon_task = c('fa13', 'fB53', 'h7', 'h8', 's33', 'fa', 'fh')
)
# The external inputs are ordered for both tasks: two stimuli (target and
# distractor), two hub units (the approach and avoid task), and biases
# representing the bias to screen centre and the bias to the faces as animate
# objects:
G$ext_acts = c(G$vis_input, G$vis_input, G$hub_input, G$hub_input,
           G$spatial_bias, G$animacy_bias, G$animacy_bias)
