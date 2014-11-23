############################################################################
# check requred packages
if (!require("data.table")) {
  install.packages("data.table")
}
if (!require("reshape2")) {
  install.packages("reshape2")
}
require("data.table")
require("reshape2")

##############################################################################
#Checks for data directory and creates one if it doesn't exist

if (!file.exists("data")) {
  message("Creating data directory")
  dir.create("data")
}
if (!file.exists("data/UCI HAR Dataset")) {
  # download the data
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  zipfile="data/UCI_HAR_data.zip"
  message("Downloading data")
  download.file(fileURL, destfile=zipfile, method="auto")
  unzip(zipfile, exdir="data")
}

#########################################################################
# Reading all needed data from files 

message("Reading data files...")
x_train<-read.table("data\\UCI HAR Dataset\\train\\X_train.txt")
x_test<-read.table("data\\UCI HAR Dataset\\test\\X_test.txt")

features<-read.table("data\\UCI HAR Dataset\\features.txt")

subject_train<-read.table("data\\UCI HAR Dataset\\train\\subject_train.txt")
subject_test<-read.table("data\\UCI HAR Dataset\\test\\subject_test.txt")

y_train<-read.table("data\\UCI HAR Dataset\\train\\y_train.txt")
y_test<-read.table("data\\UCI HAR Dataset\\test\\y_test.txt")

activity_labels<-read.table("data\\UCI HAR Dataset\\activity_labels.txt") 
activity_labels<-factor(activity_labels$V2)


########################################################################
# Merge the training and the test sets to create one data set.
message("Merging the training and the test data sets...")
full_dataset<-rbind(x_train,x_test)
# set colnames
colnames(full_dataset)<-features$V2

##########################################################################
# Extracts only the measurements on the mean and standard deviation for each measurement. 
message("Grep required columns...") 
mean_and_std_features<-grep("std\\(\\)|mean\\(\\)",features$V2)
# extracts from general dataset only requred columns
full_dataset<-full_dataset[,mean_and_std_features]


########################################################################
# merge Subject and Activity data and add them to general dataset
message("Merge Subject and Activity data")
#merge subject_train and subject_test
subject<-rbind(subject_train,subject_test)
#Set colname for summurized subject vector
colnames(subject)<-c("Subject")

#merge activity vectors y_train and y_test
activity<-rbind(y_train,y_test)
#Set colname for summurized activity vector
colnames(activity)<-c("Activity")

# append columns 'Subject' and 'Activity' to general dataset
full_dataset<-cbind(full_dataset,subject)
full_dataset<-cbind(full_dataset,activity)

########################################################################
# Set descriptive activity names to name the activities in the data set
message("Set descriptive activity names")
full_dataset$Activity<-activity_labels[full_dataset$Activity]

########################################################################
#  Creates a second, independent tidy data set 
# with the average of each variable for each activity and each subject.
message("Creates a second, independent tidy data set")
DT <- data.table(full_dataset)
tidy<-DT[,lapply(.SD,mean),by="Subject,Activity"]
message("Writting result to the file...")
write.table(tidy,file="tidy_data.txt",row.names = FALSE)

#id_labels = c("Subject","Activity")
#data_labels = setdiff(colnames(full_dataset), id_labels)
#melt_data = melt(full_dataset, id = id_labels, measure.vars = data_labels)
## Apply mean function to dataset using dcast function
#tidy_data = dcast(melt_data, Subject + Activity ~ variable, mean)
#write.table(tidy_data, file = "./tidy_data.txt",row.name=FALSE)
