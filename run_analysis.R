##capture the current directory
old.dir<-getwd()

##set up the data directory
if(!file.exists("./data")){dir.create("./data")}

## download the data set
datasetUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(datasetUrl,destfile = "./data/dataset.zip",mode="wb")

##unzip the dataset
unzip("./data/dataset.zip",exdir = "./data")

##change working directory
setwd("./data/UCI HAR Dataset")

##using the README document describing the data files
##read the datasets from /test and /train
##and since the files are text files use read.table rather than read.csv

activitylabel <- read.table("activity_labels.txt") ##there are 6 rows
featureslist <- read.table("features.txt")  ##there are 561 rows

##labels = activity
testactivity<-read.table("./test/y_test.txt")  ##there are 2947 rows
trainingactivity<-read.table("./train/y_train.txt")  ##there are 7352 rows

##sets = features 
testset<-read.table("./test/X_test.txt")  ##there are 2947 rows
trainingset<-read.table("./train/X_train.txt") ##there are 7352 rows

##subject = identifies the subjects who performed the activity for each window sample. 
testsubject<-read.table("./test/subject_test.txt")    ##there are 2947 rows
trainingsubject<-read.table("./train/subject_train.txt") ##there are 7352 rows

##now combine the analagous data sets together via rbind()
activities <- rbind(testactivity,trainingactivity)  ##there are 10299 rows
features <- rbind(testset,trainingset)              ##there are 10299 rows
subjects <- rbind(testsubject,trainingsubject)      ##there are 10299 rows

##convert the activity values to readable factors
##do this by linking the class labels with their activity name
activities$V1 <- factor(activities$V1, levels = activitylabel$V1, labels = activitylabel$V2)

##now give headers to the data sets
names(activities) <- "activity"
names(subjects) <- "subject"
names(features) <- featureslist$V2

##now get the features that contains means and standard deviations for each measurement
##per features_info.txt look for "mean()" or "std()" within the feature name 
##note cannot use the $ metacharacter because some features have 3 axial signals 
## thus ending in -xyz
featureswithmeanstddev <- as.character(featureslist$V2[grep("mean\\(\\)|std\\(\\)", featureslist$V2)])
featuressubset <- subset(features,select=featureswithmeanstddev)  ##length = 66, rows 10299

##now create a second independent dataset using the featuressubset with the
##average of each variable for each activity and subject
##start with binding the activity and subject together
subjectbyactivity <- cbind(subjects, activities) ##10299 rows, 2 columns

##then bind the features to the subject+activity
combinedata <- cbind(featuressubset,subjectbyactivity)  ##10299 rows, 68 columns

##now find the averages (i.e.means) for each variable
by1 <- combinedata$subject
by2 <- combinedata$activity
tidydata <- aggregate(x=combinedata, by = list(by1, by2), FUN = "mean",drop=TRUE)  ##180 rows,70 cols

##cleanup the headings i,e. rename the columns used by the list
colnames(tidydata)[1:2] <- c("subject","activity")
colnames(tidydata)[3:68] <- gsub("^t","time",colnames(tidydata)[3:68])
colnames(tidydata)[3:68] <- gsub("^f","frequency",colnames(tidydata)[3:68])
colnames(tidydata)[3:68] <- sub("\\-mean\\(\\)\\-","Mean",colnames(tidydata)[3:68])
colnames(tidydata)[3:68] <- sub("\\-mean\\(\\)","Mean",colnames(tidydata)[3:68])
colnames(tidydata)[3:68] <- sub("\\-std\\(\\)\\-","Std",colnames(tidydata)[3:68])
colnames(tidydata)[3:68] <- sub("\\-std\\(\\)","Std",colnames(tidydata)[3:68])

##then get rid of the columns at the end as they were not part of the mean calculations
tidydata<-tidydata[1:68] ##180 rows,68 cols

##now write to file in the data directory
setwd(old.dir)
write.table(tidydata, file='./data/tidydata.txt')

