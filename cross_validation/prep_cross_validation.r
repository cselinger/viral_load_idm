#################################################################################################
## prep_cross_validation.r

## DESCRIPTION: Split the dataset into 10 parts. In 10 different folders, save each part
##              (testing dataset), plus the remaining 9 parts (training dataset). Do this ten 
##              times, for a total of 100 different validation datasets.
## 
#################################################################################################

#setup
rm(list=ls())
set.seed(strtoi("0xCAFE"))

library(foreign)
library(data.table)
library(reshape2)
require(bit64)
setwd("C:/Users/abertozz/Dropbox (IDM)/viral_load/cascade/code/")
#setwd("C:/Users/cselinger/Dropbox (IDM)/viral_load (1)/cascade/code")

main_dir <- ("../data/")
setwd(main_dir) 

#load all data 
load("alldata.rdata")
patients <- unique(alldata$patient_id)
split_size <- ceiling(length(patients)/10)

summary <- data.table(iteration=numeric(), split=numeric(), type=character(), mar=numeric(), aids=numeric(), death=numeric()) 

#rename alldata because the subsets must be named "alldata"
fulldata <- copy(alldata)
setkeyv(fulldata, "patient_id")

for (iteration in 1:10){
  print(paste("iteration", iteration))
  #split into ten groups of patients
  shuffled <- sample(patients)
  startval <- 1
  
  for (split in 1:10){
    print(paste("split", split))
    endval <- split_size*split
    test_patients <- shuffled[startval:endval]
    train_patients <- shuffled[!shuffled %in% test_patients]
    test_data <- fulldata[J(test_patients)]
    alldata <- fulldata[J(train_patients)]
    
    #spot checks: tell me how many mar vs AIDS vs death events there are
    for (type in c("test", "train")){
      if (type=="test") thisdata <- copy(test_data) else thisdata <- copy(alldata)
      mar <- length(unique(thisdata[event_type=="mar"]$patient_id))
      aids <- length(unique(thisdata[event_type=="aids"]$patient_id))
      death <- length(unique(thisdata[event_type=="death"]$patient_id))
      summary <- rbind(summary, list(iteration, split, type, mar, aids, death))
    }
    
    
    save(alldata, file=paste0("cross_validation/", iteration, "/", split, "/alldata.rdata"))
    save(test_data, file=paste0("cross_validation/", iteration, "/", split, "/test_data.rdata"))
    startval <- startval+split_size
  }
}

