library(dplyr)
library(tidyr)
library(lattice)

# load and label baseline and disrupted conditions
message("Loading saved files and generated RT data, will take a moment...")
load('sims/app_avoid/aa_sim_2023-06-28-1326.RData')
baseline = RTs_generate(out, accuracy_required = .98, epsilon = .005, verbose = FALSE)[[1]]
load('sims/app_avoid/aa_intent_noise(50)_2023-06-28-1505.RData')
intents = RTs_generate(out, accuracy_required = .98, epsilon = .005, verbose = FALSE)[[1]]
load('sims/app_avoid/aa_stim_noise(50)_2023-06-28-1444.RData')
stims = RTs_generate(out, accuracy_required = .98, epsilon = .005, verbose = FALSE)[[1]]
baseline$disruption = "Baseline"
intents$disruption = "Intentions"
stims$disruption = "Stimuli"
E2 = rbind(baseline, intents, stims)
bwplot(cycle ~ task | disruption, E2, layout = c(3,1), 
       xlab = "Task", ylab = "RT (cycles)")


