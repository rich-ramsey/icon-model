library(dplyr)
options(dplyr.summarise.inform = FALSE)
library(tidyr)

source('sims/RTs.R')
# The output from each simulation is stored in a variable called "out"
# This variable has columns for the activations of every unit on every cycle
# of every simulation. The colnames will be:
# task -- all the sims are a 2-condition design
# simno -- simulation number
# cycle 
# unitnames of every unit in the network

# RTs_generate converts activations and a specification of the possible
# responses into latency, based on the minimum threshold difference between
# responses that meets the accuracy_required criterion. It is explained further
# in the RTs_generate comments. In this case, the default response alternatives,
# (correct_response, incorrect_response) were created in imitation_task.R 
rt_data = RTs_generate(out, task1 = "congr", task2 = "incon",
                       accuracy_required = .98, epsilon = .005)

# some basic RT comparisons follow
rt_overview(rt_data)

