calculate_dependency <- function(df){

subjects <- unique(df$subject)
numSubjs <- length(subjects)
dependency <- data.frame(matrix(0, nrow = numSubjs*3, ncol = 3))
names(dependency) <- c("SubID", "Pair", "Difference")
row <- 0
for (idx in 1:length(subjects)) {
  
  myData <- subset(df, subject == subjects[idx])
  
  for (pair in 1:3) {
    if (pair == 1) {
      name = 'Person-Obj1_x_Person-Obj2'
      curAcc <- cbind(myData$`person-objOne`, myData$`person-objTwo`)
    } else if (pair == 2) {
      name = 'Person-Obj1_x_Object-Object'
      curAcc <- cbind(myData$`person-objOne`, myData$`object-object`)
    } else if (pair == 3) {
      name = 'Person-Obj2-Object-Object'
      curAcc <- cbind(myData$`person-objTwo`, myData$`object-object`)
    }
    
    row = row + 1
    dependency$SubID[row]   = as.character(myData$subject[1])
    dependency$Pair[row]    = name
    data  = sum(!rowSums(curAcc) == 1)/nrow(curAcc) #actual dependency of the data (proportion of times both remembered or forgotten)
    sumAcc <- colMeans(curAcc)
    independent = (sumAcc[1]*sumAcc[2])+((1-sumAcc[1])*(1-sumAcc[2])) #dependency of data expected based on performance (assuming actually independent)
    dependency$Difference[row] = data - independent #degree to which features are more/less dependent in memory than expected by chance (based on performance)
  }
}#end of loop through subjects

personDependency <- dependency

}