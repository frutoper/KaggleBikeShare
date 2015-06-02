library(randomForest)
library(rpart)
library(foreach)
library(doParallel)
library(gbm)

workers <- makeCluster(3) # My computer has 8 cores
registerDoParallel(workers)

setwd("E:\\Kaggle\\Bike_Share")

#import datasets
train <- read.csv("Data\\train.csv") #use nrows=1000 rows for speed during feature engineering
test <- read.csv("Data\\test.csv") #use nrows=1000 rows for speed during feature engineering

#tr <- train[1:round((dim(train)[1]*.7),0),]
#val <- train[(round((dim(train)[1]*.7),0)+1):dim(train)[1],]


#####Feature Engineering function: accepts data frame, returns data frame
featureEngineer <- function(df) {
        
        #convert season, holiday, workingday and weather into factors
        names <- c("season", "holiday", "workingday", "weather")
        df[,names] <- lapply(df[,names], factor)
        
        #Convert datetime into timestamps (split day and hour)
        df$datetime <- as.character(df$datetime)
        df$datetime <- strptime(df$datetime, format="%Y-%m-%d %T", tz="EST") #tz removes timestamps flagged as "NA"
        
        #convert hours to factors in separate feature
        df$hour <- as.integer(substr(df$datetime, 12,13))
        df$hour <- as.factor(df$hour)
        
        #Day of the week
        df$weekday <- as.factor(weekdays(df$datetime))
        df$weekday <- factor(df$weekday, levels = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")) #order factors
        
        #something that represents yearly growth:
        #extract year from date and convert to factor
        df$year <- as.integer(substr(df$datetime, 1,4))
        df$year <- as.factor(df$year)
        
        #something that represents monthly seasonality:
        #extract month from date and convert to factor
        df$month <- as.integer(substr(df$datetime, 6,7))
        df$month <- as.factor(df$month)
        
        #More Weather Vars
        df$temp2 <- df$temp^2
        df$temp3 <- df$temp^3
        df$templog <- log(df$temp)
        df$atemp2 <- df$atemp^2
        df$atemp3 <- df$atemp^3
        df$atemplog <- log(df$atemp)
 
        df$humidity2 <- df$humidity^2
        df$humiditylog <- log(df$humidity)     
        df$windspeed2 <- df$windspeed^2
        df$windspeedlog <- log(df$windspeed)
        
        df$temp_humid <- df$temp * df$humidity
        df$temp_wind <- df$temp * df$windspeed
    

        #return full featured data frame
        return(df)
}


######MAIN######
#Build features for train and Test set
train <- featureEngineer(train)
test <- featureEngineer(test)
#tr <- featureEngineer(tr)
#val <- featureEngineer(val)

train$logCasual <- log(train$casual + 1)
train$logRegistered <- log(train$registered + 1)
train$logCount <- log(train$count + 1)



formulaC <- logCasual     ~ hour + year + humidity + temp + atemp + season + weather + workingday + weekday + windspeed +
                                temp2 + temp3 + templog +  atemp2 + atemp3 + atemplog + humidity2 + humiditylog + temp_humid + temp_wind + windspeed2 + windspeedlog
formulaR <- logRegistered ~ hour + year + humidity + temp + atemp + season + weather + workingday + weekday + windspeed +
                                temp2 + temp3 + templog +  atemp2 + atemp3 + atemplog + humidity2 + humiditylog + temp_humid + temp_wind + windspeed2 + windspeedlog


############################################################################
# GBM
###########################################################################

# best hyperparameters: tree= 20000, depth = 20, shrinkage = .001

fit.gbmC <- gbm(formulaC , data=train, dist="gaussian", n.tree = 20000,
    interaction.depth = 20, shrinkage = .001)
test$casual <- exp(predict(fit.gbmC, newdata = test, type = "response", n.tree = 20000))

fit.gbmR <- gbm(formulaR, data=train, dist="gaussian", n.tree = 20000,
    interaction.depth = 20, shrinkage = .001)
test$registered <- exp(predict(fit.gbmR, newdata = test, type = "response", n.tree = 20000))

test$count <- round((test$registered + test$casual), 0)

submit <- data.frame (datetime = test$datetime, count = test$count)
write.csv(submit, file = "GBM_20000_no_month_log_exp_more_weather2.csv", row.names=FALSE)





