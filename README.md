# Cleaning-and-getting-data-Project

In this file we will explain all the steps and script variables in the run_analysis.R script. The *Code Book.Rmd* file will contain an explanation of the experiment, all the folders and files, and the variables names of the data sets that are present in the project.

### Loading the data sets 
In this part we loaded all the data sets that we will need in the form of a data frame.  
these are :

#### data sets that contain informations we will use :
-**integer_activity** : a data frame with 6 rows and 2 columns, it corresponds to the *UCI HAR Dataset/activity_labels.txt* file. the first column contains integers from 1 to 6 and the second contains the activity corresponding to it (walking...) in the form of a string.    
-**variable_names** : a data frame with 2 columns and 561 rows identifying the 561 variables that were measured, it corresponds to the *UCI HAR Dataset/features.txt* file. The first column contains the number of the variable (from 1 to 561) and the second contains the corresponding name of the variable.        
We will use these two data frames later to give descriptive names to the activities (instead of integers as it is currently) and to the variables of the training and test data sets (instead of V1 V2...)

#### data sets relative to the test group :
-**test_data** : a data frame with 2947 rows and 561 columns corresponding to the 561 variables that were measured,it corresponds to the *UCI HAR Dataset/test/X_test.txt* file. This is the main data frame for the test group as it contains all the measurements for all the variables. It column names are V1 V2.. they will be given descriptive names using **variable_names** (described previously).  
-**test_activity** : a data frame with 1 column and 2947 rows, it corresponds to the *UCI HAR Dataset/test/X_test.txt* file. It values are integers from 1 to 6 that identify the activities, so that the n-th row gives the activity for the n-th observation in **test_data**. we will replace those integers with descriptive names of the activities using the **integer_activity** data frame.   
-**test_subjects** : a data frame with 1 column and 2947 rows,it corresponds to the *UCI HAR Dataset/test/subject_test.txt* file. it values are integers from 1 to 30 identifying which of the 30 subjects the observation was made, so that the n-th row gives the subject of the n-th observation in **test_data**.   
These two last uni-column data frames will be merged with the **test_data** data frame in order to have a comprehensive final data set that contains all the informations about the test group.

#### data sets relative to the training group :
here are the corresponding data frames for the training group, they have the same role :  
-**train_data** : a data frame with 561 columns and 7352 rows. it corresponds to the */UCI HAR Dataset/train/X_train.txt* file.  
-**train_activity** : a data frame with 1 column and 7352 rows. it corresponds to the */UCI HAR Dataset/train/y_train.txt* file.  
-**train_subjects** : a data frame with 1 column and 7352 rows. it corresponds to the */UCI HAR Dataset/train/train_subjects.txt* file.   

Therefore we have 2947+7352=10299 total observations, later we will merge **test_data** and **train_data** to have all the 10299 observations in one data frame.


### Updating test_data and train_data to include the activity and the subjects of the observation
In this part we simply add the **test_activity** and **test_subjects** columns to the **test_data** data frame, so that we have one data frame containing all the information about the test group:   
```{r setup, include=FALSE} 
test_data<-mutate(test_data,activity=test_activity[[1]],subject=test_subjects[[1]],.before=1) 
```
we add .before=1 so the the activity and subject column are put at the start of the data frame. The new updated **test_data** data frame now have the same number of rows and 561+2=563 columns ("activity" "subject" "V1 "V2"...).  

and we do the same thing with the training data :  
```{r setup, include=FALSE} 
train_data<-mutate(train_data,activity=train_activity[[1]],subject=train_subjects[[1]],.before=1)   
```
**train_data**  now have the same number of rows and  563 columns ("activity" "subject" "V1 "V2"...).   
and we remove the **test_activity**, **test_subject**, **train_activity**, **train_subject** as we don't need them anymore :   
 ```{r setup, include=FALSE} 
 rm(test_activity,test_subjects,train_activity,train_subjects) 
 ```
 
### Merging the 2 data sets :
 Next we merge **test_data** and **train_data** to have one final data frame with all the observations :    


 ```{r setup, include=FALSE}
 data<-merge(test_data,train_data, all=TRUE)
 ```
 We don't need to specify by which column the function should merge as all the variables in the two data frames have the same name and correspond to the same measurement. We add all=TRUE to tell the function to keep the rows who have no matching in the other data frame (otherwise we would have a data frame with 0 rows).   
 
 **data** is now a data frame with 563 columns and 2947+7352=10299 rows. It columns are "activity" "subject" "V1" "V2"... and it contains all the observations of the experiment.   
 
 We can then remove the **test_data** and **train_data** as we won't need them anymore :   
```{r setup, include=FALSE}
rm(test_data,train_data)
```

### Tiding the results i.e give descriptive variable and value names :
 
#### Giving descriptive variable names for the **data** data-frame :
 The variable names (ie columns) of **data** are as such : "activity" "subject" "V1" "V2"..."V561". The second column (variable_name) of **variable_names** identifies names for "V1"..."V561" (variable_names$variable_name[i] is the name of the variable Vi), so we can replace them with their names using the following command :   
 ```{r setup, include=FALSE}
 names(data)<-c("activity","subject",variable_names$variable_name)
 ```
 
 now names(data) prints : "activity" "subject" "tBodyAcc-mean()-X" "tBodyAcc-mean()-Y" ...
 
#### Giving descriptive names for the activity values :
 Now, the activity column have integers as values instead of the name of the activity. We will replace each integer by the corresponding activity name using the **integer_activity** data frame: if i is an integer, the activity corresponding is integer_activity\$activity(i). So we can parse through data\$activity and apply the function f(i)=integer_activity$activity(i) :   
 ```{r setup, include=FALSE}
 data\$activity<-sapply(data\$activity,function(i) integer_activity\$activity[i])
```

### Sub-setting the data to get the means and standard deviations :
Next we will subset **data** to get only the variables of the means and standard deviations.   
As explained in the *UCI HAR Dataset/features_info.txt* and *Code Book.Rmd* files, those are the variables that contain "-mean()-" and "-std()-" in their name. So we will create a vector of logical value that have TRUE where there is such a variable and FALSE when it is not the case, to do that we use the grepl function :   
```{r setup, include=FALSE}
cols<-grepl("-mean()-",names(data),fixed=TRUE) | grepl("-std()-",names(data),fixed=TRUE) 
```    
We also set :   
```{r include=TRUE}
cols[1:2]<-c(TRUE,TRUE) 
```  
in order to keep the first two columns ("activity" and "subject").   
Now all we need to do is to subset **data** and store the result in a new variable :
```{r setup, include=FALSE}
means_and_standard_devs<-data[, cols]
```
**means_and_standard_devs** is a data frame with 10299 rows and 68 columns ("activity" "subject" and 66 other variables representing the means and standard deviations)

### Creating a data frame that contains the averages and tidying it:
We now want to create a data frame, that we will call **averages**, containing all the averages of the variables for each activity and each subject.   
We can do this in 3 steps :   
- **First :** We take the **means_and_standard_devs** data frame and we collapse all the columns containing the means and standards deviations into one column called "variable" and put their values in a column called value, The result is a longer and skinnier data frame with 4 variables : "activity" "subject" "variable" "value", for each activity subject and variable we can see the value of that variable for that subject and activity in the "value"" column.      
- **then : **  we group the result by the "variable"" column so that each group is in fact one of the columns in **means_and_standard_devs** containing means or standard deviations.    
- **finally :** we summarize the result, The summary will be the mean of the "value" column and we will put the results in a new column called average 
We can do all this (collapse>group_by>summarise) in one chain and store it in a new data frame called **averages**
```{r setup, include=FALSE}
averages<-means_and_standard_devs %>% pivot_longer(cols=3:n,names_to="variable",values_to="value") %>% group_by(activity,subject,variable)%>% dplyr::summarise(average=mean(value))
```   

The result **averages** is a data frame with 4 columns: "activity", "subject", "variable" and "average". for a given activity, subject and variable we have the average of that variable for that activity and subject in the "average"" column.   

This is a satisfying result but we can do better by un-collapsing the "variable" column so that for each activity and subject we can see the average of all the means and standard deviations :    
```{r setup, include=FALSE}
averages<-pivot_wider(averages, names_from=variable,values_from = average)
```
Now **averages** contain 68 columns : "activity", "subject" and 66 columns corresponding to the 66 measurements of the means and standard deviations.









