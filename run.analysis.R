# Load non-basic libraries that the script will use.
library(data.table)
library(data.table)
library(qdap)

# Load  data into R from local files
# The files are stored in the working directory hence do not access via directory path
X_test_data <- read.table("X_test.txt")
X_train_data <- read.table("X_train.txt")
features <- read.table("features.txt")
Activity_labels <- read.table("activity_labels.txt")
subj_train <- read.table("subject_train.txt")
subj_test <- read.table("subject_test.txt")
y_test <- read.table("y_test.txt")
y_train <- read.table("y_train.txt")
colnames(Activity_labels)<- c("Activity_ID","Activity")

# Step 1: Combing test and training files and then merging them together to produce a single data file
combined_test_data <- cbind(setnames(subj_test, "V1", "Subject_ID"), setnames(y_test, "V1", "Activity_ID"), X_test_data)
combined_train_data <- cbind(setnames(subj_train, "V1", "Subject_ID"), setnames(y_train, "V1", "Activity_ID"), X_train_data)
Merged_data = rbind(combined_test_data, combined_train_data)
# Assigning the features columns by the actual names as in features.txt file
names(Merged_data)[3:563] <- as.character(features[, 2])

# step 2: Extracting the measurements that are only on the mean and standard deviation of each measurement
mean_std_only_data <- cbind( Merged_data[, 1:2], Merged_data[grep("-mean()\\>|-std()\\>" , names(Merged_data))])

# Step 3: Adding Descriptive activity names by merging the extract mean-std data with activity labels
mean_std_only_data <- merge(mean_std_only_data, Activity_labels, by = "Activity_ID")
# rearranging the order of columns to improve the dataset readability 
mean_std_only_data <- cbind(mean_std_only_data$Subject_ID, mean_std_only_data$Activity, mean_std_only_data[, 3:68])
colnames(mean_std_only_data)[1:2] = c("Subject_ID", "Activity")

# Step 4: Create descriptive variable names by using a pattern (pv) and replacement (rv) vectors to clean column names 
pv <- c("tBodyAcc",  "fBodyAcc" , "-mean()-", "-std()-", "-mean()", "-std()", "tBodyGyro", "fBodyGyro", "tBodyAccMag", "fBodyAccMag", "tGravityAcc", "tGravityAccMag", "fBodyBodyAccJerkMag", "fBodyBodyGyroMag", "fBodyBodyGyroJerkMag", "Jerk" )
rv = c("Body Accelerometer (time)", "Body Accelerometer (frequency)",  " Mean ",  " STD ", " Mean",  " STD", "Body Gyroscope (time)", "Body Gyroscope (frequency)", "Body Accelerometer Magnitude (time)", "Body Accelerometer Magnitude (frequency)", " Gravity Accelerometer (time)", "Gravity Accelerometer Magnitude (time)", "Body Accelerometer Jerk Magnitude (frequency)", "Body Gyroscope Magnitude (frequency)", "Body Gyroscope Jerk Magnitude", "Jerk")
names(mean_std_only_data) = mgsub(pv, rv, names(mean_std_only_data))

# Step 5 : creates a second tidy data set with the average of each variable for each activity and each subject
tidy_data <- tbl_df(mean_std_only_data)
tidy_data <- aggregate(. ~Subject_ID + Activity, tidy_data, mean)
# ordering the data by subject and activity variables
tidy_data_ordered <- arrange(tidy_data, Subject_ID, Activity)
write.table(tidy_data_ordered, file = "tidy_data.txt", row.names = FALSE)
