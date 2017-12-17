# Author: Johannes
# Date Created: 12-12-2017
# Last Modified: 17-12-2017

# DOCUMENTATION
#
# The purpose of the makefile is to automate the analytics process by calling the scripts in the correct sequence.
#
# The arguments that can be specified by the user within the different scripts can also be speicified when running the makefile.
# This will be implemented in the near future.
# At the moment the variables are still hard-coded as input to the functions.
#
# All files created by the makefile when running `make`, can be deleted by running `make clean`. 

# declare future user input variables and default values
location?="UBC"
zoom?=11
alpha?=0.1
plot_period?="weekly"
search_filter?=c("YouTube")

# running of scripts in sequence when make is called
all: data_import data_cleaning data_viz report_render

# command for running data import script
data_import:
	Rscript src/data_import.R

# command for running data cleaning script
data_cleaning:
	Rscript src/data_cleaning.R

# command for running data data_visualization script
data_viz:
	Rscript src/data_visualization.R

# command for running report rendering script
report_render:
	Rscript src/report_render.R

# cleaning process - deletes all newly created files
clean:
	find results/* ! -name '*.Rmd' -exec rm -f {} +
	rm -f data/R_temp/*
