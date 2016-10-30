# Getting and Cleansing Data Course Project #
____________________________________________
## Run_Analysis.R :  An R Script for merging  the Human Activity Recognition Using Smartphones Dataset  ##

This README file explains how the above script merges the test and training datasets and creates a new and tidy dataset containing the mean and standard deviation variables for each measurement as per the requirement of the Getting and Cleansing Data Course Project. The following paragraphs explain the different parts of the script and how each step of the project is accomplished in the scrip.

### Part1 ###

The first part (below) of the script loads all necessary non-basic libraries used in the script.



    library(data.table)
    library(data.table)
    library(qdap)


### Part2  ###

The next part of the script (below) loads all necessary files to be included in the merged data into R. Understandably the files are first copied into the R working directory hence bypassing the  requirement of including directory paths.  


    X_test_data <- read.table("X_test.txt")
    X_train_data <- read.table("X_train.txt")
    features <- read.table("features.txt")
    Activity_labels <- read.table("activity_labels.txt")
    subj_train <- read.table("subject_train.txt")
    subj_test <- read.table("subject_test.txt")
    y_test <- read.table("y_test.txt")
    y_train <- read.table("y_train.txt")


### Part 3 (Step 1)	###

This part of the script is where the actual data processing starts and corresponds to Step  1 of the project deliverables. In it, the test and training files are combined then merged to form one data set. 

    combined_test_data <- cbind(setnames(subj_test, "V1", "Subject_ID"), setnames(y_test, "V1", "Activity_ID"), X_test_data)
    combined_train_data <- cbind(setnames(subj_train, "V1", "Subject_ID"), setnames(y_train, "V1", "Activity_ID"), X_train_data)
    Merged_data = rbind(combined_test_data, combined_train_data)
    names(Merged_data)[3:563] <- as.character(features[, 2])


### Part 4 (step 2) ###

This part of the script extracts the variables about the mean and standard deviation of the measurements.  To achieve this, the regular expression: "-mean()\\>|-std()\\>" is used while maintaining the first two columns, which are on the subject and the activities.  This reduces the original 561 variables before the extraction to 68 variables (excluding subject and activity variables).


    mean_st_only_data <- cbind( Merged_data[, 1:2], Merged_data[grep("-mean()\\>|-std()\\>" , names(Merged_data))])


### Part 5 (Step 3) ###
This part of the code adds descriptive activity names to the data set. This is done by merging the extracted mean and standard deviation only data with activity labels and then rearranging the data frame columns so that the first two columns represent the subject and activity variables to ease  the subsequent processing of the dataset. 

    mean_std_only_data <- merge(mean_std_only_data, Activity_labels, by = "Activity_ID")
    mean_std_only_data <- cbind(mean_std_only_data$Subject_ID, mean_std_only_data$Activity, mean_std_only_data[, 3:68])
    colnames(mean_std_only_data)[1:2] = c("Subject_ID", "Activity")



### Part 6 (Step 4) ###
This section of the script creates descriptive variable names than the present ones. This is done by first building two vectors, one containing the patterns to be matched and another consisting the replacements. In the following, the pv is the pattern vector while the rv is the replacement vector.  The mgsub function from gdap library is used to make the replacements.

    pv <- c("tBodyAcc",  "fBodyAcc" , "-mean()-", "-std()-", "-mean()", "-std()", "tBodyGyro", "fBodyGyro", "tBodyAccMag", "fBodyAccMag", "tGravityAcc", "tGravityAccMag", "fBodyBodyAccJerkMag", "fBodyBodyGyroMag", "fBodyBodyGyroJerkMag", "Jerk" )

    rv = c("Body Accelerometer (time)", "Body Accelerometer (frequency)",  " Mean ",  " STD ", " Mean",  " STD", "Body Gyroscope (time)", "Body Gyroscope (frequency)", "Body Accelerometer Magnitude (time)", "Body Accelerometer Magnitude (frequency)", " Gravity Accelerometer (time)", "Gravity Accelerometer Magnitude (time)", "Body Accelerometer Jerk Magnitude (frequency)", "Body Gyroscope Magnitude (frequency)", "Body Gyroscope Jerk Magnitude", "Jerk")

    names(mean_std_only_data) = mgsub(pv, rv, names(mean_std_only_data))


### Part 7 (Step 5) ###
This is the final part of the script and its function is to  create a second tidy data set with the average of each variable for each activity and each subject. The aggregate function is used to achieve this. The tidy data is then ordered before it  is written to a tabulated text file. 

    tidy_data <- tbl_df(mean_std_only_data)
    tidy_data <- aggregate(. ~Subject_ID + Activity, tidy_data, mean)
    tidy_data_ordered <- arrange(tidy_data, Subject_ID, Activity)
    write.table(tidy_data_ordered, file = "tidy_data.txt", row.names = FALSE)



_Thank you for reading and reviewing this work._

