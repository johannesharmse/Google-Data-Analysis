location?="UBC"
zoom?=11
alpha?=0.1
plot_period?="weekly"
search_filter?=c("YouTube")

all: data_import data_cleaning data_viz report_render

data_import:
	Rscript src/data_import.R

data_cleaning:
	Rscript src/data_cleaning.R

data_viz:
	Rscript src/data_visualization.R

report_render:
	Rscript src/report_render.R

clean:
	find results/* ! -name '*.Rmd' -exec rm -f {} +
	rm -f data/R_temp/*
