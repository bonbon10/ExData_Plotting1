# Assumes the data are in the current working directory 

# Read in first 100 rows to see summary of data and variable names
dat.sum <- read.table("household_power_consumption.txt", nrows=100, header=TRUE, sep=";")
str(dat.sum)

# For this project, we are only interested in data from the dates 2007-02-01 and 2007-02-02. Therefore, we can read in only these data to save memory and processing time. However, it appears that dates are in the form day/month/year. We can verify this by only reading in the Date column from the data
dat.date <- read.table("household_power_consumption.txt", colClasses=c("factor",rep("NULL",8)), header=TRUE, sep=";")
levels(dat.date$Date)

# Use the sqldf package to use sql code to specify the dates needed
library(sqldf)
subdat <- read.csv.sql("household_power_consumption.txt", sql= 'select * from file where(Date in ("1/2/2007","2/2/2007"))', sep=";")
closeAllConnections()
str(subdat)

# Check: each date should have 60*24=1440 records, since data has a one-minute sampling rate
table(subdat$Date)

# Convert date to date class
subdat$Date1 <- as.Date(subdat$Date, "%d/%m/%Y")
table(subdat$Date1); class(subdat$Date1)

# Combine date and time to POSIXlt class
subdat$Date.Time <- as.POSIXct(strptime(paste(subdat$Date, subdat$Time, sep=" "), format="%d/%m/%Y %H:%M:%S"))

# Check new date/time variable
class(subdat$Date.Time)
subdat$Date.Time[1:10]

# Plot 4: 4 different plots in a 2x2 matrix
png(filename="plot4.png")

par(mfrow=c(2,2))

#1: Line graph of Global Active Power (weekday on x-axis)
with(subdat, plot(Date.Time, Global_active_power, type="l", xlab="", ylab="Global Active Power"))

#2: Line graph of Voltage (weekday on x-axis)
with(subdat, plot(Date.Time, Voltage, type="l", xlab="datetime", ylab="Voltage"))

#3: Same as Plot 3
with(subdat, plot(Date.Time, Sub_metering_1, type="l", xlab="", ylab="Energy sub metering"))
with(subdat, lines(Date.Time, Sub_metering_2, col="red"))
with(subdat, lines(Date.Time, Sub_metering_3, col="blue"))
legend("topright",lty=c(1,1,1), col=c("black","red","blue"), legend=c("Sub_metering_1","Sub_metering_2","Sub_metering_3"), bty="n")

#4: Line graph of Global Reactive Power (weekday on x-axis)
with(subdat, plot(Date.Time, Global_reactive_power, type="l", xlab="datetime"))

dev.off()
