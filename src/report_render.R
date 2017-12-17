# AUTHOR: Johannes Harmse
#
# Date created: 12-2017
#
# DOCUMENTATION

# The purpose of this code is to automate the rendering process of the Rmd report to knitted formats.

# installing/loading the package:
if(!require(installr)) { install.packages("installr"); require(installr)} #load / install+load installr

# Installing pandoc
install.pandoc(use_regex = FALSE)

library('rmarkdown')
rmarkdown::render("results/Google_Data_Analysis_Report.Rmd")