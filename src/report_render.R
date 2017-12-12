# AUTHOR: Johannes Harmse
#
# Date created: 12-2017
#
# DOCUMENTATION

# The purpose of this code is to automate the rendering process of the Rmd report to knitted formats.

library('rmarkdown')
rmarkdown::render("results/Google_Data_Analysis_Report.Rmd")