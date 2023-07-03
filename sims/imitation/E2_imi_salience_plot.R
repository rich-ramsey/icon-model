
# This takes the results from 3 runs of the imitate experiment. The three runs
# differ in the salience of the distractor. It creates a plot of the CE effect
# with confidence intervals (and the data structure used to make the plot)
# The dataframe with this info is in salienceE2:
# > salienceE2
# # A tibble: 3 x 12
# # Groups:   cond [3]
# cond       rt_congr rt_incon var_congr var_incon n_congr n_incon    CE    sp margin  hi95  lo95
# <chr>         <dbl>    <dbl>     <dbl>     <dbl>   <int>   <int> <dbl> <dbl>  <dbl> <dbl> <dbl>
# 1 high         47.9     96.9      88.2     284.       50      50 48.9  186.    5.41 54.4  43.5 
# 2 baseline     41.3     60.7      80.8     130.       50      50 19.4  106.    4.08 23.5  15.4 
# 3 low          39.1     45.2      85.0      98.5      50      50  6.06  91.8   3.80  9.86  2.26


source("sims/RTs.R")
library(tidyr)
library(dplyr)

baseline_out_file = "sims/imitation/out_basic_2023-06-27-1112.RData"
hi_animacy_bias_file = "sims/imitation/out_animacy(20)_2023-06-27-2102.RData"
lo_animacy_bias_file = "sims/imitation/out_animacy(05)_2023-06-27-2028.RData"

accuracy_required = .98
load(baseline_out_file)
baseline = RTs_generate(out, accuracy_required)[[1]] %>% mutate(cond = "baseline")
load(hi_animacy_bias_file)
hi_animacy_bias = RTs_generate(out, accuracy_required)[[1]] %>% mutate(cond = "high")
load(lo_animacy_bias_file)
lo_animacy_bias = RTs_generate(out, accuracy_required)[[1]] %>% mutate(cond = "low")

# compute difference of means and 95% CI for plotting
salienceE2 = rbind(hi_animacy_bias, baseline, lo_animacy_bias) %>% 
  group_by(cond, task) %>% summarise(rt = mean(cycle), var = var(cycle), n = n()) %>% 
  pivot_wider(id_cols = "cond", names_from = c("task"), values_from = c("rt", "var", "n")) %>% 
  mutate(CE= rt_incon - rt_congr) %>% 
  mutate(sp = ((n_congr - 1) * var_congr + (n_incon-1) * var_incon) / 
           (n_congr + n_incon - 2)) %>% 
  mutate(margin = qt(0.975,df=(n_congr + n_incon - 1)) *
           sqrt(sp/n_incon + sp/n_congr)) %>% 
  mutate(hi95 = CE + margin, lo95 = CE - margin) %>% 
  arrange(desc(CE))

plot(1:3, salienceE2$CE, 
     xaxt = "n", xlab = "Distractor Salience", xlim = c(.75, 3.25),
     ylab = "Congruency Effect (cycles)", ylim = c(-5, 60))
arrows(1:3, salienceE2$hi95, 1:3, salienceE2$lo95, code=3, length=0.1, angle = 90)
axis(1, at=1:3, labels = c("High", "Baseline", "Low"))
# plot saved manually as protrait pdf 3"x4"
