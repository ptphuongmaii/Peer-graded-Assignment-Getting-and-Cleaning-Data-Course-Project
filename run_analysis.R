# 1. Download and unzip data if not already present
if (!file.exists("UCI HAR Dataset")) {
  url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(url, "dataset.zip", mode = "wb")
  unzip("dataset.zip")
}

library(dplyr)

# 2. Read data
features        <- read.table("UCI HAR Dataset/features.txt", col.names = c("n", "feature"))
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("code", "activity"))

subject_test  <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
x_test        <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$feature)
y_test        <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "code")

subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
x_train       <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$feature)
y_train       <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "code")

# 3. Merge training and test sets
subject <- rbind(subject_train, subject_test)
x       <- rbind(x_train, x_test)
y       <- rbind(y_train, y_test)
merged_data <- cbind(subject, y, x)

# 4. Extract mean and standard deviation measurements
tidy_data <- merged_data %>% 
  select(subject, code, contains("mean"), contains("std"))

# 5. Use descriptive activity names
tidy_data$code <- activity_labels[tidy_data$code, 2]

# 6. Appropriately label the data set with descriptive variable names (Concise version)
names(tidy_data)[2] <- "activity"
names(tidy_data) <- names(tidy_data) %>%
  gsub("^t", "Time", .) %>%
  gsub("^f", "Frequency", .) %>%
  gsub("()-", "_", .) %>%
  gsub("[()]", "", .)

# 7. Create second independent tidy dataset with averages
final_data <- tidy_data %>%
  group_by(subject, activity) %>%
  summarise(across(everything(), mean))

# Write output
write.table(final_data, "FinalData.txt", row.name = FALSE)