library(InteractiveComplexHeatmap)
library(ComplexHeatmap)
args = commandArgs(T)
obj_path = args[1]
load(obj_path)
ht_shiny(ht_out)
