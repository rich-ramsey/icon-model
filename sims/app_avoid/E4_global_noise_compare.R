library(dplyr)
library(tidyr)
library(lattice)
source('sims/RTs.R')
# load and label baseline and disrupted conditions
message('Calculating RTs for baseline...')
load('sims/app_avoid/aa_sim_2023-06-28-1326.RData')
nonoise = RTs_generate(out, accuracy_required = .98, epsilon = .001, verbose = TRUE)[[1]]

message('Calculating RTs for specific stimulus noise...')
load('sims/app_avoid/aa_stim_noise(10)_2023-07-24-1628.RData')
stimnoise = RTs_generate(out, accuracy_required = .98, epsilon = .001, verbose = TRUE)[[1]]

message('Calculating RTs for global noise...')
load('sims/app_avoid/aa_stimglob_noise(00_040)_2023-07-28-1745.RData')
globnoise = RTs_generate(out, accuracy_required = .98, epsilon = .001, verbose = TRUE)[[1]]

message('Calculating RTs for combined global and stim noise...')
load('sims/app_avoid/aa_stimglob_noise(10_040)_2023-07-28-1727.RData')
bignoise = RTs_generate(out, accuracy_required = .98, epsilon = .001, verbose = TRUE)[[1]]


nonoise$disruption = "Baseline"
globnoise$disruption = "Global"
stimnoise$disruption = "Stimuli"
bignoise$disruption = "Global\\Stim"
E5 = rbind(nonoise, globnoise, stimnoise, bignoise)
E5$disruption = factor(E5$disruption, 
                       levels = c('Baseline', 'Stimuli', 'Global', 'Global\\Stim'))
E5$task = ifelse(E5$task == 'congr', 'Congr', 'Incon')

bwplot(cycle ~ task | disruption, E5, layout = c(4,1), ylim = c(0, 200),
       panel = function(..., box.ratio) {
         panel.bwplot(..., box.ratio)
         # panel.text(1.5,210,labels=condacc[panel.number()])
       } ) %>% print()


