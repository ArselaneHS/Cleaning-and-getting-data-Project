library(dplyr)
library(tidyr)
library(utils)

### Downloed and exractign the data folder
url<- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url,destfile="./UCI HAR Dataset.zip")
unzip("./UCI HAR Dataset.zip")
rm(url)
### Loading the data sets

#### data sets that contain informations we will use :
integer_activity<-read.table("./UCI HAR Dataset/activity_labels.txt") #data frame, 2 columns, 6 rows
names(integer_activity)<-c("integer","activity")
variable_names<-read.table("./UCI HAR Dataset/features.txt") #data frame, 2 columns, 561 rows
names(variable_names)<-c("integer","variable_name")

#### data sets relative to the test group :
test_data<-read.table("./UCI HAR Dataset/test/X_test.txt") #data frame, 561 columns, 2947 rows 
test_activity<-read.table("./UCI HAR Dataset/test/y_test.txt") #data frame, 1 column, 2947 rows
test_subjects<-read.table("./UCI HAR Dataset/test/subject_test.txt") #data frame, 1 column, 2947 rows

#### data sets relative to the training group :
train_data<-read.table("./UCI HAR Dataset/train/X_train.txt") #data frame, 561 columns, 7352 rows 
train_activity<-read.table("./UCI HAR Dataset/train/y_train.txt") #data frame, 561 columns, 7352 rows 
train_subjects<-read.table("./UCI HAR Dataset/train/subject_train.txt") #data frame, 561 columns, 7352 rows 



### Updating test_data and train_data to include the activity and the subjects of the observation
test_data<-mutate(test_data,activity=test_activity[[1]],subject=test_subjects[[1]],.before=1) #added 2 columns, now have 563 columns
train_data<-mutate(train_data,activity=train_activity[[1]],subject=train_subjects[[1]],.before=1) #added 2 columns, now have 563 column
rm(test_activity,test_subjects,train_activity,train_subjects) #removing variables we won't need anymore


### Merging the 2 data sets :
data<-merge(test_data,train_data, all=TRUE) #data frame, 563 columns, 2947+7352=10299 rows
rm(test_data,train_data)


### Tiding the results i.e give descriptive variable and value names :

#### Giving descriptive variable names for the 'data' data-frame :
names(data)<-c("activity","subject",variable_names$variable_name) 

#### Giving descriptive names for th activity values :
data$activity<-sapply(data$activity, function(i) integer_activity$activity[i])


### Sub-setting the data to get the means and standard deviations :
cols<-grepl("-mean()",names(data),fixed=TRUE) | grepl("-std()",names(data),fixed=TRUE) 
cols[1:2]<-c(TRUE,TRUE) #This is to keep the activity and subject variable ( the 2 first variables)
means_and_standard_devs<-data[, cols] #data frame, 5à columns, 10299 rows
rm(cols)

### Creating a data frame that contains the averages and tidying it
n<-length(names(means_and_standard_devs)) #n is the number of variables (ie columns)
averages<-means_and_standard_devs %>% pivot_longer(cols=3:n,names_to="variable",values_to="value") %>% group_by(activity,subject,variable)%>% dplyr::summarise(average=mean(value)) # data frame with 4 columns : "activity" "subject" "variable" "average"
averages<-pivot_wider(averages, names_from=variable,values_from = average) #data frame, 68 columns, 180 rows
rm(n)

### Exporting the final result
write.table(averages,"./averages_of_means_and_stds.txt",row.name=FALSE)