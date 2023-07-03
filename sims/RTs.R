############################
# Generating and comparing RT distributions from iac simulations
############################
library(dplyr)
library(tidyr)


#' Convert activations over cycles into response times 
#' 
#' There are many possible ways to convert a series of activations 
#'  into an RT. The approach I'm using here assumes:
#'  1. The units representing the possible response alternatives are monitored for
#'  their differences in activity over time
#'  2 A response is selected when the unit representing that response meets or
#'  exceeds a threshold activation difference relative to all the 
#'  alternative response units
#'  3. The "agent" is able to flexibly set their threshold to achieve a 
#'  required level of accuracy (criterion). That is, the threshold is adjusted so that 
#'  accuracy over the entire task meets the accuracy criterion. 
#'  Raising the threshold will naturally have the effect of increasing certainty 
#'  that the correct response will be selected, but at a cost to speed: The 
#'  agent will have to wait longer for a higher threshold to be crossed
#'  
#'  For the algorithim below, a dataframe (dat) containing the cycle-by-cycle 
#'  activations for the network over many trials is analysed. This would normally
#'  be a network log file or output from a sim_batch(). 
#'  The function runs through a set of possible criterio moving from lower (faster,
#'  less accurate) criteria to higher (slower, more accurate), increasing according
#'  to the epsilon paramter. The first criterion value meeting the required_accuracy
#'  is used to generate RTs -- the number of cycles required on that trial to reach 
#'  the threshold difference

#'  @param sims The output from a sim_batch(). This will have columns for
#'    *simno* (simulation number), *cycle*, *task*, and unitnames. The dataframe
#'    gives activation values for the units on each cycle of the different
#'    simulations.
#'  @param required_accuracy The required accuracy over
#'    all trials. The criterion (threshold difference) will be raised until
#'    required_accuracy is met.
#'  @param alternatives A vector of unitnames providing the full set of possible
#'  responses
#'  @param target The correct response alternative
#'  @param task1,task2 If specified (default=NULL), then the difference 
#'      of task2 - task1 is calculated and report for each criterion tested
#'  @param epsilon The increment to the criterion during search to meet 
#'       criterion accuracy (default = .01). 
#'  @param deadline If no response made by the cycle deadline,  the trial is scored 
#'       as incorrect. When deadline = NULL (default) the last cycle is the
#'       deadline
#'  @param critmax The search stops when the criterion hits this value 
#'       (default = 1)
#'  @param fastepsilon Once accuracy_required is achieved, we keep going at a 
#'       faster rate in order to generate a full ROC curve
#'  @param verbose Give a running update of achieved accuracy and RT as the
#'       criterion is increased
#'  @returns A list {rts = the generated RTs for each sim; roc = the latency,
#'  accuracy, and (if task1 and task2 are specified) ce = the task2-task1 difference
#'  for each tested value of the criterion; accuracy_required is also stored  }. 
#'  This structure is used here for various plots and tests, shown in "see also"
#'  @seealso plot_ROC(), plot_ce_acc(), task_effects()
#'  
RTs_generate = function(sims, accuracy_required, 
                        alternatives = c("correct_resp", "incorrect_resp"),
                        target = "correct_resp", 
                        task1 = NULL, task2 = NULL,
                        epsilon = .01, 
                        deadline = NULL,
                        critmax = 1, 
                        fastepsilon = .1,
                        verbose = TRUE) {
  
  # top2 - helper. for each row of df, find the two highest values among
  # the provided alternatives. Store the column names associated with these
  # high values; their difference; and whether or not the high value was
  # > 0
  top2 = function(df, alternatives = c('correct_resp', 'incorrect_resp')) {
    newcolnames = c('alt_1', 'alt_2', 'value_1', 'value_2', 'diff')
    if(any(alternatives %in% newcolnames)) {
      stop("The network unitnames overlap with what will be created by the analysis")
    }
    # df$rownum will be used to sort the df back to its original form after all 
    #. the messing around below
    df[['rownum']] = 1:nrow(df) 
    top2 = df[, c("rownum", alternatives)] %>% 
      tidyr::pivot_longer(cols = all_of(alternatives), 
                   names_to = "alt", values_to = 'value') %>% 
      dplyr::arrange(desc(value)) %>% 
      dplyr::group_by(rownum) %>% 
      dplyr::slice(1:2) %>% 
      dplyr::ungroup() %>% 
      dplyr::mutate(maxv = rep(1:2, nrow(df))) %>% 
      tidyr::pivot_wider(id_cols = "rownum", names_from = "maxv", 
                  values_from = c("alt", "value")) %>% 
      dplyr::mutate(diff = value_1 - value_2) 
    df = merge(df, top2, by = "rownum")
    return(df)
  }
  
  stopifnot(target %in% alternatives) # the target must be included in the possible alternative responses
  deadline = ifelse(is.null(deadline), max(sims$cycle), deadline)
  sims = as.data.frame(sims)
  # dat$rownum will be used to sort the dat back to its original form after all 
  #. the messing around below
  sims$rownum = 1:nrow(sims) 
  # First job is to determine the highest 2 values among the 
  # response alternative columns, and the difference between them,
  # for every cycle of every sim
  sims = top2(sims, alternatives)
  # score each row as potentially accurate or not
  sims$acc = ifelse(sims$alt_1 == target & sims$value_1 > 0, 1, 0)
  # trials that reach the deadline are always an incorrect "no decision"
  sims$acc[which(sims$cycle >= deadline)] = 0
  # now ready to move from low criterion to high, to see if the top2 diff 
  #  meets or exceeds criterion
  roc = {}
  found = FALSE #' have we found a criterion that achieves required_accuracy
  bestsofar = 0
  criterion = 0
  repeat {
    criterion = min(criterion + epsilon, critmax)
    # roc_entry stores accuracy and RT for all trials with this criterion
    if(!is.null(task1) & !is.null(task2)) {
      roc_entry = data.frame(criterion = criterion, acc = NA, rt = NA,
                             task1 = NA, task2 = NA, taskdiff = NA)
    } else {
      roc_entry = data.frame(criterion = criterion, acc = NA, rt = NA)
    }
    # get the first cycle for each sim where the threshold difference is reached
    decisions = sims %>% 
      dplyr::filter(diff >= criterion) %>% 
      dplyr::group_by(task, simno) %>%
      dplyr::slice(1) 
    if(nrow(decisions) == 0) {
      break
    }
    roc_entry$acc = mean(decisions$acc)
    roc_entry$rt = mean(decisions$cycle)
    if(!is.null(task1) & !is.null(task2)) {
      roc_entry$task1 = mean(subset(decisions, task == task1)$cycle)
      roc_entry$task2 = mean(subset(decisions, task == task2)$cycle)
      roc_entry$taskdiff = roc_entry$task2 - roc_entry$task1
    }
    accuracy_achieved = roc_entry$acc
    
    if(accuracy_achieved > bestsofar)  {
      bestsofar = accuracy_achieved
      if(verbose) {
        message(sprintf("criterion %.3f: accuracy achieved: %.2f (mean RT: %.2f)",
                        roc_entry$criterion, roc_entry$acc, roc_entry$rt))
      }
      if(!found & accuracy_achieved >= accuracy_required) {
        if(verbose) {
          message('--- Achieved required accuracy')
        }
        found = TRUE
        rts = decisions %>% 
          dplyr::select(task, simno, cycle, acc)
        # even though RTs for criterion found, we keep going to generate ROC
        # although with increased epsilon
        epsilon = fastepsilon
      }
    }
    # add the roc entry regardless of achieved accuracy, that's what ROC is for
    roc = rbind(roc, roc_entry)
    
    if(criterion >= critmax) {
      break
    }
  }
  if(bestsofar < accuracy_required) {
    if(verbose) {
      message(sprintf("Best accuracy achieved (%.2f) less than accuracy_required (%.2f)",
                      bestsofar, accuracy_required))
    }
  }

  return(list(rts=rts, roc=roc, accuracy_required = accuracy_required))
}



#' Plot ROC curve
#' 
#' Response Operating Characteristic shows how speed and accuracy co-vary
#' This plot shows the resulting accuracy and speed for each criterion value 
#' used RTs_generate() during its search
#' @param RTs The output direct from RTs_generate()
#' @param ... Other graphic parameters, eg axis labels
#' 
plot_ROC = function(RTs, ...) {
  roc = RTs[['roc']]
  rts = RTs[['rts']]
  reqacc = RTs[['accuracy_required']]
  meanrt = mean(rts$cycle)
  meanacc = mean(rts$acc)
  
  plot(roc$rt, roc$acc, type = 'l', lwd = 1,
       xlab = 'RT (cycles)', ylab = 'Accuracy (%c)',
       ylim = c(0, 1.1), ...)
  points(meanrt, meanacc)
  abline(v=meanrt, col='blue', xpd = FALSE)
  text(meanrt, .25, sprintf("mean RT=%.1f", meanrt), col='blue')
  abline(h=meanacc, col='red', xpd = FALSE)
  text(max(roc$rt)*.5, meanacc + .05, sprintf("mean acc=%.2f", meanacc), col='red')
}

#' Plot and summarise basic task effects
#' 
#' Graphic and t-test for the effect of "task"
#' 
#' @param RTs The output direct from RTs_generate(). The params task1 and task2
#' must have been specified.
#' @param correct_only Limit the analysis to correct trials only (default=FALE)
#' 
task_effect = function(RTs, correct_only = FALSE, ...) {
  rts = RTs[['rts']]
  if (correct_only) {
    rts = subset(rts, acc == 1)
  }
  tstat = t.test(formula = cycle ~ task, data=rts) 
  print(tstat)
  boxplot(cycle ~ task, data=rts, xlab = "Task", ylab = "RT (cycles)", ...)
}


#' Plot compatibility effect against accuracy
#' 
#' See how changes in required_accuracy change task differences,
#'  usually called congruency effect or compatibility effect (CE)
#'
#' @param RTs The output direct from RTs_generate(). The params task1 and task2
#' must have been specified.
plot_ce_acc = function(RTs, ...) {
  # magic spell to allow default but overridable xlab, ylab, ylim
  plothelper = function(RTs, 
                           xlab="Task Difference (cycles)",
                           ylab = "Accuracy (%c)",
                           ylim = c(0, 1.1), 
                           ...) {
    roc = RTs[['roc']]
    rts = RTs[['rts']]
    reqacc = RTs[['accuracy_required']]
    taskdiff = subset(roc, acc >= reqacc)$taskdiff[1]
    
    meanrt = mean(rts$cycle)
    meanacc = mean(rts$acc)
    
    plot(roc$taskdiff, roc$acc, type = 'p', 
         xlab = xlab, ylab = ylab, ylim=ylim, ...)
    points(meanrt, meanacc)
    abline(v=taskdiff, col='blue', xpd = FALSE)
    abline(h=reqacc, col='red', xpd = FALSE)
  }
  
  plothelper(RTs, ...)

}

#' Quick summary from RTs_generate()
#' 
#' Basic plots of activation and task effects. It assumes the RTs hold exactly
#' two levels within a column "task" (e.g., "congr", "incon"; or "3", "10")
#' 
#' @param RTs #' @param RTs The output direct from RTs_generate(). The params
#'   task1 and task2 must have been specified.
#' 
rt_overview = function(RTs, correct_only = FALSE) {
  rts = RTs[[1]]
  roc = RTs[[2]]
  tasks = attr(table(rts$task), "dimnames")[[1]]
  if(correct_only & 
     (nrow(subset(RTs[[1]], task == tasks[1] & acc == 1)) < 1 |
     nrow(subset(RTs[[1]], task == tasks[2] & acc == 1)) < 1)) {
    stop("correct_only is TRUE but there are no correct trials in some conditions")
  }

  #  basic summary data
  rts %>% group_by(task) %>% 
    summarise('%corr' = mean(acc), mean_rt=mean(cycle), sd_rt=sd(cycle), n = n(), ) %>% 
    print()
  
  if(all(c('correct_resp', 'incorrect_resp') %in% colnames(out))) {
    plot_acts(out, roi = c('correct_resp', 'incorrect_resp'), 
              cond = 'task', cycles = 0:150, 
              xlim = c(0,200), col='black', lwd=2)
  }
  
  # ROC curve
  plot_ROC(RTs)
  
  # Compare tasks if the number of correct trials allows
  task_effect(RTs, correct_only = correct_only)
  
  # plot the CE against accuracy achieved, if tasks have been specified
  if ("taskdiff" %in% colnames(roc)) {
    plot_ce_acc(RTs)
  }
}

