### Introduction

This file describes the data, the variables, and the work that has been performed to clean up the data.

### Data Set Description

The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain. 

#### For each record it is provided:

* Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
* Triaxial Angular velocity from the gyroscope. 
* A 561-feature vector with time and frequency domain variables. 
* Its activity label. 
* An identifier of the subject who carried out the experiment.

#### The dataset includes the following files:

* 'features_info.txt': Shows information about the variables used on the feature vector.
* 'features.txt': List of all features.
* 'activity_labels.txt': Links the class labels with their activity name.
* 'train/X_train.txt': Training set.
* 'train/y_train.txt': Training labels.
* 'test/X_test.txt': Test set.
* 'test/y_test.txt': Test labels.
* 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 
* 'train/Inertial Signals/total_acc_x_train.txt': The acceleration signal from the smartphone accelerometer X axis in standard gravity units 'g'. Every row shows a 128 element vector. The same description applies for the 'total_acc_x_train.txt' and 'total_acc_z_train.txt' files for the Y and Z axis. 
* 'train/Inertial Signals/body_acc_x_train.txt': The body acceleration signal obtained by subtracting the gravity from the total acceleration. 
* 'train/Inertial Signals/body_gyro_x_train.txt': The angular velocity vector measured by the gyroscope for each window sample. The units are radians/second. 

### Variables

The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. These time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. Similarly, the acceleration signal was then separated into body and gravity acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low pass Butterworth filter with a corner frequency of 0.3 Hz. 

Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag). 

Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain signals). 

These signals were used to estimate variables of the feature vector for each pattern:  
'-XYZ' is used to denote 3-axial signals in the X, Y and Z directions.

### Work/Transformations

#### Load test and training sets and the activities

The data set has been stored in the `data/UCI HAR Dataset/` directory.

The CDN url provided by the instructor is used instead of the original location, to offload the traffic to the UCI server.

The `unzip` function is used to extract the zip file in this directory.

```
 fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  zipfile="data/UCI_HAR_data.zip"
  message("Downloading data")
  download.file(fileURL, destfile=zipfile, method="auto")
  unzip(zipfile, exdir="data")
```

`read.table` is used to load the data to R environment.

```
x_train<-read.table("data\\UCI HAR Dataset\\train\\X_train.txt")
x_test<-read.table("data\\UCI HAR Dataset\\test\\X_test.txt")
features<-read.table("data\\UCI HAR Dataset\\features.txt")
subject_train<-read.table("data\\UCI HAR Dataset\\train\\subject_train.txt")
subject_test<-read.table("data\\UCI HAR Dataset\\test\\subject_test.txt")
y_train<-read.table("data\\UCI HAR Dataset\\train\\y_train.txt")
y_test<-read.table("data\\UCI HAR Dataset\\test\\y_test.txt")
activity_labels<-read.table("data\\UCI HAR Dataset\\activity_labels.txt") 
```

Training and the test data sets  are merged to create general data set.

```
full_dataset<-rbind(x_train,x_test)

colnames(full_dataset)<-features$V2
```


Extract the measurements on the mean and standard deviation for each measurement. 
```
mean_and_std_features<-grep("std\\(\\)|mean\\(\\)",features$V2)

full_dataset<-full_dataset[,mean_and_std_features]
```


Merge Subject and Activity data and add them to general dataset.
```
subject<-rbind(subject_train,subject_test)
colnames(subject)<-c("Subject")

#merge activity vectors y_train and y_test
activity<-rbind(y_train,y_test)
#Set colname for summurized activity vector
colnames(activity)<-c("Activity")

# append columns 'Subject' and 'Activity' to general dataset
full_dataset<-cbind(full_dataset,subject)
full_dataset<-cbind(full_dataset,activity)
```

Set descriptive activity names to name the activities in the data set

```
full_dataset$Activity<-activity_labels[full_dataset$Activity]
```

Creates a second, independent tidy data set  with the average of each variable for each activity and each subject.
```
DT <- data.table(full_dataset)
tidy<-DT[,lapply(.SD,mean),by="Subject,Activity"]
```

Data is stored to tidy_data.txt file.
```
write.table(tidy,file="tidy_data.txt",row.names = FALSE)
```


