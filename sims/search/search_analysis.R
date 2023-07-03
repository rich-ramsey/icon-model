library(dplyr)
library(tidyr)

source("sims/RTs.R")

# In the search task, unlike the other sims, there are many alternative
# responses -- any location in the touch action map is a valid response
# (although only the target location is correct). The RTs_generate function
# needs to know about all these possibilities
# This gets all the unitnames in the touch action map (at11..at55). The correct
# response is always at53
at_units = colnames(out)[grep("at..", colnames(out))]

#' With all the response alternatives, it's useful to vary the criterion
#' relatively slowly, by using a small epsilon incremental value
rt_data = RTs_generate(out, accuracy_required = .98, 
                       alternatives = at_units, target = "at53", 
                       epsilon = .001)

# some basic RT comparisons follow
rt_overview(rt_data)


