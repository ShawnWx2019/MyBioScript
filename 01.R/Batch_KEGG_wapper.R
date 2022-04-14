
# db and input file -------------------------------------------------------------------------

## input database file
db = read.table("~/08.CommUsedData/KEGG_Compound_db.xls",header = T,sep = "\t")

## input file with customizedID in 1st column and compound name in 2nd column
input = read.table("~/07.tmp/tmp.txt",header = T,sep = "\t")

# out put file path
outpath = "~/07.tmp/testout.txt"


# functions ---------------------------------------------------------------


KEGG_wapper = function(db,input){
  colnames(input) = c("CustomizedID","Compound")
  x = inner_join(input,db,by = "Compound")
  return(x)
}


# result ------------------------------------------------------------------

## run
out = tryCatch(
  KEGG_wapper(db = db, input = input)
)

## save
if (is.null(out)) {
  print("no compound matched")
} else {
  print(paste0(length(unique(out$Compound))," compounds were matched with kegg database"))
  write.csv(out,outpath)
}
