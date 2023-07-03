library(dplyr)
library(tidyr)
library(lattice)

source('sims/RTs.R')
# In the search task, unlike the other sims, there are many alternative
# responses -- any location in the touch action map is a valid response
# (although only the target location is correct). The RTs_generate function
# needs to know about all these possibilities

# This gets all the unitnames in the touch action map (at11..at55). The correct
# response is always at53
touch_locations = colnames(out)[grep("at..", colnames(out))]

# Now load and label the different conditions
load('sims/search/search_easy_2023-06-29-0957.RData')
# With all the response alternatives, it's useful to vary the criterion relatively
# slowly, by using a small epsilon incremental value
easy = RTs_generate(out, accuracy_required = .98, 
                              alternatives = touch_locations, target = "at53", 
                              epsilon = .001)[[1]]
easy$cond = "Easy (High Salience)"

load('sims/search/search_hard_2023-06-29-1011.RData')
hard = RTs_generate(out, accuracy_required = .98, 
                    alternatives = touch_locations, target = "at53", 
                    epsilon = .001)[[1]]
hard$cond = "Hard (Low Salience)"

# For speed accuracy trade-off, we use the same activarion data generated in the
# hard condition, but specify a lower level of required accuracy
hardsao = RTs_generate(out, accuracy_required = .85, 
                       alternatives = touch_locations, target = "at53", 
                       epsilon = .001)[[1]]
hardsao$cond = "Hard but trading accuracy for speed"

searchdat = rbind(easy, hard, hardsao)
bwplot(cycle ~ task | cond, searchdat, layout = c(3,1), 
       xlab = "Set Size", ylab = "RT (cycles)")


