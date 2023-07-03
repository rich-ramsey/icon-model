
library(dplyr)
library(lattice)
load('sims/imitation/out_basic_2023-06-27-1112.RData')
e1_basic = RTs_generate(out, task1 = "congr", task2 = "incon",
                       accuracy_required = .98, epsilon = .005)[[1]]

load('sims/app_avoid/aa_imitate_noisy_faces(50)_2023-06-28-1541.RData')
e1_noisy_faces = RTs_generate(out, task1 = "congr", task2 = "incon",
                              accuracy_required = .98, epsilon = .005)[[1]]

e1_basic$cond = "Baseline"
e1_noisy_faces$cond = "Face Disruption"
e_compare = rbind(e1_basic, e1_noisy_faces)
bwplot(cycle ~ task | cond, e_compare) %>% print()
