###################
#####  Prepare ####
###################

#load libraries
library(tidyverse)
library(here)

###################
## wrangle data ###
###################

##########################
##########  A. Import Data

#load data 1: log-trace data with read_csv from readr package
time_spent <- read_csv("data/log-data.csv")

#load data 1:log trace data with here package
time_spent <- read_csv(here("data", "log-data.csv"))

#inspect data
time_spent

#load data 2: Academic Achievement with here
gradebook <- read_csv(here("data","gradebook-summary.csv"))

#inspect data with glimpse
glimpse(gradebook)

#load data 3:Self-Report Survey
survey <- read_csv(here("data", "survey.csv"))

#inspect data with view - yes the "V" is capitalized
View(survey)

########################
##########  B. Tidy data

##### Data 1: TIME SPENT
# separate course_id variable in the time-spent
time_spent %>%
  separate(course_id,
           c("subject", "semester", "section"))


time_spent <- time_spent %>%
  separate(course_id,
           c("subject", "semester", "section"))

# mutate minutes to hours on time spent and save as new variable.
time_spent <- time_spent %>% 
  mutate(time_spent_hours = time_spent / 60)

##### Data 2: GRADEBOOK

# separate the course_id variable
gradebook <- gradebook %>% 
  separate(course_id, c("subject", "semester", "section"))

# Mutate to a proportion, take total points earned divide by total points. Save as new variable proportion_earned.
gradebook <- gradebook %>% 
  mutate(proportion_earned = (total_points_earned / total_points_possible))

#inspect data
gradebook

##### Data 3: SURVEY

#inspect data 
survey

# load janitor to clean variable names that do not match
library(janitor)

#clean column
survey <- clean_names(survey)

#inspect data to check for consistency with other data
survey

#######################
########## C. JOIN DATA

# use single joint to join data sets by student_id, subject, semester and section.
joined_data <- full_join(gradebook, time_spent, 
                         by = c("student_id", "subject", "semester", "section"))

# join together the grade_book and log_wrangled
data_to_explore <- full_join(joined_data, survey, by = c("student_id", "subject", "section"))

#Inspect data
data_to_explore

#mutate to change variable class from double or numeric to character
joined_data <- joined_data %>%
  mutate(student_id = as.character(student_id))

#inspect data
joined_data

#try again to together the grade_book and log_wrangled
data_to_explore <- full_join(joined_data, survey, by = c("student_id", "subject", "semester", "section"))

# inspect data
data_to_explore

###################
##### EXPLORE #####
###################

########################
###### A. TABLE SUMMARY

#install package if this is first time using Skimr
install.packages("skimr")

#load library
library(skimr)

#skim data
skim(data_to_explore)

# using the `select()` and `filter()` functions. In the code chunk below,look at descriptive for just `proportion_earned` , `time_spent` and `gender`, but only for the "OcnA" and "PhysA" subjects.

data_to_explore %>% 
  select(c('subject', 'gender', 'proportion_earned', 'time_spent')) %>% 
  filter(subject == "OcnA" | subject == "PhysA") %>%
  skim()

########################
########### B. DATA VIZ

# create a histogram
data_to_explore %>% 
  ggplot(aes(x = time_spent_hours)) +
  geom_histogram(bins = 30)

# create a scatter plot
ggplot(data_to_explore, aes(x = time_spent_hours, y = proportion_earned, color = enrollment_status)) +
  geom_point()

# scatter plot facet wrap
ggplot(data_to_explore, aes(x = time_spent_hours, y = proportion_earned, color = enrollment_status)) +
  geom_point() +
  facet_wrap(~ subject)

#################
##### Model #####
#################

##########################
########### A. MATHMATICAL

# Does time spent predict grade earned?
# Use linear regression model
lm(proportion_earned ~ time_spent_hours, 
   data = data_to_explore)


# Add predictor variable for science
lm(proportion_earned ~ time_spent_hours + int, 
   data = data_to_explore)

# save the model
m1 <- lm(proportion_earned ~ time_spent_hours + int, data = data_to_explore)

#run the summary
summary(m1)

# use the {apaTables} package to create a nice regression table that could be used for later publication.
apa.reg.table(m1, filename = "lm-table.doc")

###################
### Communicate ###
###################

data_to_explore %>% 
  ggplot(aes(x = time_spent_hours)) +
  geom_histogram(bins = 20, color = "black", fill = "white") +
  facet_wrap(~subject, ncol = 2)

# add a write up for communication

