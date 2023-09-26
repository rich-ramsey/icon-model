Readme

This is a readme file for the 5x5 ICON model that accompanies the Ward and Ramsey paper entitled “An Interactive activation and competition model for the Control Of actioN (ICON)”.

**Note 1:** If you’re reading this on the OSF, then go to GitHub to get the code (it’s much easier):  https://github.com/rich-ramsey/icon-model.git

**Note 2:** The OSF page is still useful though as it contains data and figures, some of which were too big for GitHub. Therefore, download the code from GitHub and run the sims on your own machine. This will create all of the data. Or, alternatively, copy data files from the OSF, if you’d prefer, and run some of the analysis files on your machine. If you get the code from GitHub, you will need to create a /data/ and a /figures/ folder in each of the three sims folders. 

**Note 3:** Package management in R. This project uses renv to manage packages. The 'packages.Rmd' file is an attempt to efficiently manage R packages using renv. It is technically unnecessary, as one could just install and load packages as one normally does and then use the R scripts that are contained in these folders. 


**Folder structure**

The basic folder structure is as follows.

The **/renv/** folder contains files/folders relevant to package management through
renv (see here: https://rstudio.github.io/renv/articles/renv.html). 

The **/sims/** folder contains the following files and folders:

1. 5x5_hub.yaml.

This file contains basic settings for the computational model.

2. making figures.txt

This file lists and labels the figures produced in the 'R script' workflow 
(see below for the workflow options).

3. RTs.R

An R script file that converts activations over cycles into response times.

4. Three simulation folders, which correspond to the three main tasks that 
were simulated in the project (i.e., approach-avoid, imitation and visual search).

**/app_avoid/**

**/imitation/**

**/search/**


Each of these folders has a similar layout.

First, there are a set of .R files.

4a. *_task.R

This file sets up the speicfic task settings and structure.

4b. *_run.R

This file runs the simulations.

4c. *_analysis.R

The files analyses the output of the simulations.

4d. *_plot.R

This file creates plots.


Note: Within each simulation folder, there may be other variants of these files 
(i.e., files 4b, 4c and 4d), which run different simulations or plot different 
data, but they will all be from one of the above categories and have a similar 
function e.g., run a sim / analysis / plot.


Second, there are two .Rmarkdown files. These RMarkdown files are unnecessary 
in a functional sense, as all of the sims and analyses can be done with R scripts.
However, the project has two workflows at play here, so we give folks two 
different options (see the section below on workflows for more details). 

4e. *_sim.Rmd

This file runs all of the simulations for the task in question.

4f. *_analysis.Rmd

This file runs all of the analyses for the task and data in question.


**There are two possible workflows to adopt when using these scripts**

This distinction basically follows the preferences of the two authors on the extent
to which they use base R or a tidyverse plus ggplot2 workflow. We leave it up to 
the user to choose how they would like to proceed. 

**Workflow 1)** Use the R scripts and base R code to plot and load packages as you 
need them.

*An example workflow would be:* execute 'E1_imi_run.R' to run the basic imitation
simulation. Then execute 'imitation_analysis.R' to analyse the data that was
produced.


**Workflow 2)** Use the R markdown (.Rmd) files and tidyverse plus ggplot2 for 
wrangling and plotting and load packages at the start in one go. Of course,
you could also use Workflow 2) and load packages as you go, we just found it 
easier to do it in one go in this project and update the renv lockfile once, 
whenever you needed to. 

*An example workflow would be:* choose which part/s (i.e., which specific sims) of 
'sim.Rmd' file that you want to run and execute them. Then use 'analysis.Rmd' to 
analyse the data that was produced.