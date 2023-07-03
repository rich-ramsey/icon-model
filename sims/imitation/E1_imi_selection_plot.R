
library(dplyr)
library(lattice)
# We are plotting the timecourse for the basic imitation task (E1), looking at
# the average for all trials. Select the relevant columns showing an
# object-oriented selection
load('sims/imitation/out_basic_2023-06-27-1112.RData')

toplot = out %>% 
  select(cycle, "T.feat.array" = fA33, "T.salience" = s33, "T.identity" = fA,
         "D.feat.array" = fI, "D.salience" = s32, "D.identity" = fI)

# "zooming" in on earlier cycles to see differences in timecourse
plot_acts(toplot, roi = 2:7, cycles = 0:90, 
          col = 'black', lwd = c(2,1,2,2,1,2),
          lty = c(1,1,2,1,1,2),
          xlim = c(0, 160))
# saved manually as a 4"x 4" pdf