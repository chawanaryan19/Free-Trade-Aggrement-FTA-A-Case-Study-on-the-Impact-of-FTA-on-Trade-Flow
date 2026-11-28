## Installed Packages

# install.packages("readxl")
library(readxl)
# install.packages("writexl")
library(writexl)
# install.packages("dplyr")
library(dplyr)
# install.packages("ggplot2")
library(ggplot2)
# install.packages("tseries")
library(tseries)
# install.packages("tidyr")
library(tidyr)
# install.packages("strucchange")   
library(strucchange)
# install.packages("rugarch")
library(rugarch)
# install.packages("forecast")
library(forecast)
# install.packages("zoo")   
library(zoo)
# install.packages("FinTS")   
library(FinTS)


# Changed the names of columns manually
data_final=read_xlsx("C:\\Users\\chawa\\Documents\\DDA2\\OGDATASET\\Countries\\Japan_Data.xlsx")
data_final$Country <- "Japan"
data_final$Period <- as.Date(data_final$Period)  # Converting to date

## Variables
# Trade Balance
data_final$`Import(US Million $)`<-as.numeric(data_final$`Import(US Million $)`)
data_final$`Export(US Million $)`<-as.numeric(data_final$`Export(US Million $)`)
data_final$`Trade Balance(US Million $)`<-as.numeric(data_final$`Trade Balance(US Million $)`)
data_final$`Total Trade(US Million $)`<-as.numeric(data_final$`Total Trade(US Million $)`)

# Log variables
data_final$log_tb  <- log(abs(data_final$`Trade Balance(US Million $)`))
data_final$log_tt  <- log(abs(data_final$`Total Trade(US Million $)`))
data_final$GDP=as.numeric(data_final$GDP)
data_final$log_gdp <- log(data_final$GDP)
data_final$`Exchange Rate`<-as.numeric(data_final$`Exchange Rate`)
data_final$log_er  <- log(data_final$`Exchange Rate`)


# Stationary series
data_final$dlog_tb <- c(NA, diff(data_final$log_tb))
data_final$dlog_tt <- c(NA, diff(data_final$log_tt))

# Create FTA Dummy
data_final$FTA_Group <- ifelse(data_final$Period < as.Date("2011-08-01"), 0, 1)

#### Stationarity Check for Export
ggplot(data_final, aes(x = Period, y = `Export(US Million $)`)) +
  geom_line(color = "blue", linewidth = 1) +
  labs(title = "India Exports to Japan",x = "Period",y = "Exports (US Million $)") +
  theme_minimal()

data_final$'Log export'=log(data_final$`Export(US Million $)`)

data_final$dlog_exports <- c(NA, diff(data_final$`Log export`))
adf.test(na.omit(data_final$dlog_exports),k=1)
# p-value = 0.01.  p-value < 0.05. Stationarity 

ggplot(data_final, aes(x = Period, y = dlog_exports)) +
  geom_line(color = "blue", linewidth = 1) +
  labs(title = "Log Export Plot",x = "Period",y = "Log Exports") +
  theme_minimal()

kpss.test(data_final$dlog_exports)
# p-value = 0.1.  p-value > 0.05 → Stationary 

#### Stationarity check for Import
ggplot(data_final, aes(x = Period, y = `Import(US Million $)`)) +
  geom_line(color = "red", linewidth = 1) +
  labs(title = "India Imports to Japan",x = "Period",y = "Import (US Million $)") +
  theme_minimal()

data_final$'Log import'=log(data_final$`Import(US Million $)`)

data_final$dlog_imports <- c(NA, diff(data_final$`Log import`))
adf.test(na.omit(data_final$dlog_imports),k=1)
# p-value = 0.01.  p-value < 0.05. Stationarity 

ggplot(data_final, aes(x = Period, y = dlog_imports)) +
  geom_line(color = "red", linewidth = 1) +
  labs(title = "Log Import Plot",x = "Period",y = " Log Imports") +
  theme_minimal()

kpss.test(data_final$dlog_imports)
#  p-value =0.1.  p-value > 0.05 → Stationary 

# Remove NA
data_final <- na.omit(data_final)
data <- data_final                # Entire data
data_final <- data_final[data_final$Period <= as.Date("2024-12-31"), ]   # Till 2024
# ==============================
# OBJECTIVE 1 : To analyze the stability of India’s trade flows before and after the implementation of FTAs.
# ===============================

data_final$Trend <- 1:nrow(data_final)
head(data_final)

## FTA implementation year
break_point <- which(data_final$Year == 2011 & data_final$Month == 8)
print(break_point)          #breakpoint=185


# ==============================
# For Exports
# ===============================

model <- lm(`Log export`~ Trend, data = data_final)
summary(model)

chow_test <- sctest(model,
                    type = "Chow",
                    point = break_point)

print(chow_test)
# p-value < 0.05 (structural break exist)
# “Export did not remain structurally stable throughout the entire sample period.

# plot of chow
plot(data_final$Trend, data_final$`Log export`, type = "l", lwd = 2,
     xlab = "Time",
     ylab = "Trade Flow",
     col ="blue",
     main = "Trade Flow Before and After FTA(Export)")
abline(v = break_point, lty = 2, lwd = 2)

#CUSUM test
cusum_test <- efp(`Log export` ~ Trend,
                  type = "Rec-CUSUM",
                  data = data_final)
print(cusum_test)

plot(cusum_test,col="cyan4",lwd=2,
     main = "CUSUM Test - Export",ylab="Export")


cusum_result <- sctest(cusum_test)
print(cusum_result)
# p value < 0.05 
# Trade flow model is not stable over time

# ==============================
# For Imports
# ===============================
par(mfrow=c(3,1))
model <- lm(`Log import`~ Trend, data = data_final)
summary(model)

chow_test <- sctest(model,
                    type = "Chow",
                    point = break_point)

print(chow_test)
#pvalue < 0.05 (structural break exist)
#“Export did not remain structurally stable throughout the entire sample period.

#plot of chow
plot(data_final$Trend, data_final$`Log import`, type = "l", lwd = 2,
     xlab = "Time",
     ylab = "Log Import",
     col="blue",
     main = "Chow Test for Import")
abline(v = break_point, lty = 2, lwd = 2)

#CUSUM test
cusum_test <- efp(`Log import` ~ Trend,
                  type = "Rec-CUSUM",
                  data = data_final)
print(cusum_test)

plot(cusum_test,
     main = "CUSUM Test-Import",col="cyan4",lwd=2)

cusum_result <- sctest(cusum_test)
print(cusum_result)
# p value < 0.05 
# Trade flow model is not stable over time

## Bai - Perron

# Export Model
bp_model <- breakpoints(`Log import`~ Trend, data = data_final)

# Summary of breakpoints
summary(bp_model)

# Extract breakpoints
break_dates <- breakdates(bp_model)
break_dates

# Plot with breakpoints
plot(`Log import` ~ Trend, data = data_final, type = "l",
     main = "Bai-Perron - Export",col="red",
     xlab = "Time", ylab = "Export")

# Add vertical lines at breakpoints
abline(v = bp_model$breakpoints, col = "blue", lty = 2, lwd = 2)
abline(v = break_point, lty = 2, lwd = 2)

data.frame(
  Breakpoint_Index = bp_model$breakpoints,
  Breakpoint_Period = data_final$Period[bp_model$breakpoints]
)



# Import Model
bp_model <- breakpoints(`Log import`~ Trend, data = data_final)

# Summary of breakpoints
summary(bp_model)

# Extract breakpoints
break_dates <- breakdates(bp_model)
break_dates

# Plot with breakpoints
plot(`Log import` ~ Trend, data = data_final, type = "l",lwd=2,col="red",
     main = "Bai-Perron - Import",
     xlab = "Time", ylab = "Log Import")

# Add vertical lines at breakpoints
abline(v = bp_model$breakpoints, col = "blue", lty = 2, lwd = 2)
abline(v = break_point, lty = 2, lwd = 2)

data.frame(
  Breakpoint_Index = bp_model$breakpoints,
  Breakpoint_Period = data_final$Period[bp_model$breakpoints]
)





# ==============================
# OBJECTIVE 2: 
# ===============================

# =======================================================
# Entire Data
# =======================================================

# ===============================================================================================
# For volatility part
# ============================================================================================== 

# 12-month rolling volatility for exports
data_final$export_roll_vol <- rollapply(data_final$dlog_exports,
                                        width = 12,
                                        FUN = sd,
                                        fill = NA,
                                        align = "right")

# 12-month rolling volatility for imports
data_final$import_roll_vol <- rollapply(data_final$dlog_imports,
                                        width = 12,
                                        FUN = sd,
                                        fill = NA,
                                        align = "right")

summary(data_final$export_roll_vol)
#export volatility is moderate,fluctuations are not extremely extreme,So exports look okay.

summary(data_final$import_roll_vol)
par(mfrow=c(1,1))
plot(data_final$export_roll_vol, type = "l",
     main = "12-Month Rolling Volatility of Exports",
     ylab = "Export Volatility",
     xlab = "Time",col="magenta3",lwd=2,lty=1)
abline(v = break_point, lty = 2, lwd = 2)


sort(data_final$import_roll_vol, decreasing = TRUE)[1:10]
sort(data_final$dlog_imports, decreasing = FALSE)[1:10]

plot(data_final$import_roll_vol, type = "l",
     main = "12-Month Rolling Volatility of Imports",
     ylab = "Import Volatility",
     xlab = "Time")
abline(v = break_point, lty = 2, lwd = 2)
#At the beginning, import volatility is extremely high
#After that, volatility drops sharply
#Then for most of the period, import volatility remains relatively low and stable
#A few small fluctuations are visible later, but nothing close to the early spike
#very unstable at first
#more stable later

# --------------------------------
# Step 3: Compare Pre-FTA and Post-FTA Volatility
# --------------------------------

pre_fta  <- data_final[data_final$FTA_Group == 0, ]
post_fta <- data_final[data_final$FTA_Group == 1, ]

# Export volatility comparison
mean_export_pre  <- mean(pre_fta$export_roll_vol, na.rm = TRUE)
mean_export_post <- mean(post_fta$export_roll_vol, na.rm = TRUE)

# Import volatility comparison
mean_import_pre  <- mean(pre_fta$import_roll_vol, na.rm = TRUE)
mean_import_post <- mean(post_fta$import_roll_vol, na.rm = TRUE)

mean_export_pre
mean_export_post
# Post > Pre . FTA increased uncertainty in export
# Trade became more unstable after FTA
# More fluctuations
# Less predictable

mean_import_pre
mean_import_post
# Pre > Post . FTA decresed uncertanity in import
# Trade became more stable after FTA
# Less fluctuation
# More predictable

## Check for autocorrelation 
par(mfrow=c(2,1))
Acf(data_final$dlog_exports, main = "ACF - Export Returns")
Acf(data_final$dlog_imports, main = "ACF - Import Returns")

Pacf(data_final$dlog_exports, main = "PACF - Export Returns")
Pacf(data_final$dlog_imports, main = "PACF - Import Returns")

Box.test(data_final$dlog_exports, lag = 12, type = "Ljung-Box")
Box.test(data_final$dlog_imports, lag = 12, type = "Ljung-Box")
### P-value is <0.05 . So autocoreetaion is present. So we apply ARIMA


#########################
#ARCH Effect
#######################


# for Export Returns
model1=auto.arima(data_final$dlog_exports)
plot(model1$residuals,col="magenta3")
abline(v=break_point,lty=2,lwd=2)
ArchTest(model1$residuals)
res_exp <- na.omit(model1$residuals)
res_exp <- res_exp[is.finite(res_exp)]

garch_spec <- ugarchspec(
  variance.model = list(
    model = "sGARCH",        # standard GARCH
    garchOrder = c(1, 1)     # GARCH(1,1)
  ),
  mean.model = list(
    armaOrder = c(0, 0),     # mean already handled by ARIMA
    include.mean = FALSE     # important since we use residuals
  ),
  distribution.model = "norm"
)


garch_export <- ugarchfit(spec = garch_spec, data = res_exp)
garch_export
# Since the joint statistic si sless that asympotoics crytical vale and the indiviual statistic is less than the threshold value. therefore we can say that each varibles are stable
#Plot
plot(garch_export, type = "l",
     main = "GARCH Conditional Volatility of Exports",
     ylab = "Export Volatility", xlab = "Time",which='all')


# ARCH LM Test for Import Returns
model2=auto.arima(data_final$dlog_imports)
plot(model2$residuals)
abline(v=break_point,lty=2,lwd=2)
ArchTest(model2$residuals)
# No ARCH effect is present
# trade uncertainty is not systematic or persistent, but rather random



########################################################################
# Post FTA
##############################################################

data_final1 <- data_final[data_final$FTA_Group==1,]

data_final1$export_roll_vol <- rollapply(data_final1$dlog_exports,
                                        width = 12,
                                        FUN = sd,
                                        fill = NA,
                                        align = "right")

# 12-month rolling volatility for imports
data_final1$import_roll_vol <- rollapply(data_final1$dlog_imports,
                                        width = 12,
                                        FUN = sd,
                                        fill = NA,
                                        align = "right")

summary(data_final1$export_roll_vol)
#export volatility is moderate,fluctuations are not extremely extreme,So exports look okay.

summary(data_final1$import_roll_vol)
#Max = 3.93834  That is very high compared to:
#median = 0.13730,3rd quartile = 0.16976
#there is likely a huge outlier / extreme shock in imports.
#Because if most values are around 0.12–0.17, but one value jumps to 3.93, that is abnormally large.

plot(data_final1$export_roll_vol, type = "l",
     main = "12-Month Rolling Volatility of Exports",
     ylab = "Export Volatility",
     xlab = "Time")


#Export volatility remains moderate and time-varying
#In the early period, volatility is relatively lower and smoother
#Around the middle period, volatility starts increasing
#There are several spikes later, indicating periods of higher fluctuation
#Toward the end, volatility declines somewhat again
#exports were not equally stable throughout
#some periods had greater fluctuations
#trade stability may have been affected by: external shocks,policy changes,demand/supply disturbances,exchange rate changes


sort(data_final1$import_roll_vol, decreasing = TRUE)[1:10]
sort(data_final1$dlog_imports, decreasing = FALSE)[1:10]

plot(data_final1$import_roll_vol, type = "l",
     main = "12-Month Rolling Volatility of Imports",
     ylab = "Import Volatility",
     xlab = "Time")

#At the beginning, import volatility is extremely high
#After that, volatility drops sharply
#Then for most of the period, import volatility remains relatively low and stable
#A few small fluctuations are visible later, but nothing close to the early spike
#very unstable at first
#more stable later

## Check for autocorrelation 
Acf(data_final1$dlog_exports, main = "ACF - Export Returns")
Acf(data_final1$dlog_imports, main = "ACF - Import Returns")

Pacf(data_final1$dlog_exports, main = "PACF - Export Returns")
Pacf(data_final1$dlog_imports, main = "PACF - Import Returns")

Box.test(data_final1$dlog_exports, lag = 12, type = "Ljung-Box")
Box.test(data_final1$dlog_imports, lag = 12, type = "Ljung-Box")
### P-value is <0.05 . So autocoreetaion is present. So we apply ARIMA

#########################
#ARCH Effect
#######################

# install.packages("FinTS")   
library(FinTS)
# for Export Returns
model1=auto.arima(data_final1$dlog_exports)
plot(model1$residuals)
ArchTest(model1$residuals)
# p-value = 0.756 > 0.05. No ARCH Effect is present


# For Import Returns
model2=auto.arima(data_final1$dlog_imports)
plot(model2$residuals)
ArchTest(model2$residuals)
# No ARCH effect is present
# trade uncertainty is not systematic or persistent, but rather random

#=================================================
#OBJECTIVE 3
#=================================================
#==============================
# Entire Data
#==============================
#=======================
# ARIMA Codes for Export
#=======================

# Make sure data is sorted by date
data <- data[order(data$Period), ]

# -------------------------------
# Training data: up to 2024 only
# -------------------------------
data_2024 <- data[data$Period <= as.Date("2024-12-31"), ]

# Actual 2025 data
data_2025 <- data[data$Period >= as.Date("2025-01-01") &
                    data$Period <= as.Date("2025-12-31"), ]

# Check that 2025 has 12 months
nrow(data_2025)

# -------------------------------
# Create time series
# -------------------------------
export_ts <- ts(data_2024$`Export(US Million $)`,start = c(1996,4), frequency = 12)

# Log transform
log_export_ts <- log(export_ts)

# Fit ARIMA on full data till 2024
library(forecast)
arima_export <- auto.arima(log_export_ts)

# Forecast 12 months = 2025
forecast_export <- forecast(arima_export, h = 12)

# Create actual 2025 time series with correct time alignment
actual_2025_ts <- ts(log(data_2025$`Export(US Million $)`),
                     start = c(2025, 1), frequency = 12)

# -------------------------------
# Plot forecast + actual 2025
# -------------------------------
plot(forecast_export, main = "ARIMA Forecast – Exports (2025)")
lines(actual_2025_ts, col = "green", lwd = 2)

legend("topleft",
       legend = c("Forecast 2025", "Actual 2025"),
       col = c("blue", "green"),
       lwd = 2)

# -------------------------------
# Accuracy check
# -------------------------------
accuracy_export_2025_1 <- accuracy(forecast_export, actual_2025_ts)
accuracy_export_2025_1


#############################################
# ARIMAX
#############################################


# -----------------------------------
# Arrange data by date
# -----------------------------------
data <- data[order(data$Period), ]

# -----------------------------------
# Training data: till 2024
# -----------------------------------
data_2024 <- data[data$Period <= as.Date("2024-12-31"), ]

# Actual 2025 data
data_2025 <- data[data$Period >= as.Date("2025-01-01") &
                    data$Period <= as.Date("2025-12-31"), ]

# -----------------------------------
# Export series till 2024
# -----------------------------------
export_train_ts <- ts(data_2024$`Export(US Million $)`,
                      start = c(1996, 4), frequency = 12)

log_export_train_ts <- log(export_train_ts)

# -----------------------------------
# XREG for training and 2025 forecast
# -----------------------------------
xreg_train <- cbind(
  GDP = data_2024$log_gdp,
  ER  = data_2024$log_er
)

xreg_test <- cbind(
  GDP = data_2025$log_gdp,
  ER  = data_2025$log_er
)

# Scale training xreg
scale_xreg <- scale(xreg_train)
xreg_train_scaled <- scale_xreg

# Scale 2025 xreg using training mean and sd
xreg_test_scaled <- scale(xreg_test,
                          center = attr(scale_xreg, "scaled:center"),
                          scale  = attr(scale_xreg, "scaled:scale"))

# -----------------------------------
# Fit ARIMAX model
# -----------------------------------
library(forecast)

arimax_export <- auto.arima(
  log_export_train_ts,
  xreg = xreg_train_scaled,
  seasonal = TRUE
)

# Summary
summary(arimax_export)

# -----------------------------------
# Forecast 12 months of 2025
# -----------------------------------
forecast_arimax <- forecast(
  arimax_export,
  xreg = xreg_test_scaled,
  h = 12
)

# -----------------------------------
# Actual 2025 exports for comparison
# -----------------------------------
actual_2025_ts <- ts(log(data_2025$`Export(US Million $)`),
                     start = c(2025, 1), frequency = 12)

# -----------------------------------
# Plot forecast vs actual 2025
# -----------------------------------
plot(forecast_arimax, main = "ARIMAX Forecast – Exports (2025)")
lines(actual_2025_ts, col = "green", lwd = 2)

legend("topleft",
       legend = c("Forecast 2025", "Actual 2025"),
       col = c("blue", "green"),
       lwd = 2)

# -----------------------------------
# Accuracy for 2025
# -----------------------------------
accuracy_export_arimax_2025_2 <- accuracy(forecast_arimax, actual_2025_ts)
accuracy_export_arimax_2025_2

accuracy_export_2025_1

# by refering to RMSE we can say that ARIMAX is better

#########################################################################


#========================================
# ARIMA Codes for Import
#=========================================

# Make sure data is sorted by date
data <- data[order(data$Period), ]

# -------------------------------
# Training data: up to 2024 only
# -------------------------------
data_2024 <- data[data$Period <= as.Date("2024-12-31"), ]

# Actual 2025 data
data_2025 <- data[data$Period >= as.Date("2025-01-01") &
                    data$Period <= as.Date("2025-12-31"), ]

# Check that 2025 has 12 months
nrow(data_2025)

# -------------------------------
# Create time series
# -------------------------------
import_ts <- ts(data_2024$`Import(US Million $)`,start = c(1996,4), frequency = 12)

# Log transform
log_import_ts <- log(import_ts)

# Fit ARIMA on full data till 2024
library(forecast)
arima_import <- auto.arima(log_import_ts)

# Forecast 12 months = 2025
forecast_import <- forecast(arima_import, h = 12)

# Create actual 2025 time series with correct time alignment
actual_2025_ts <- ts(log(data_2025$`Import(US Million $)`),
                     start = c(2025, 1), frequency = 12)

# -------------------------------
# Plot forecast + actual 2025
# -------------------------------
plot(forecast_import, main = "ARIMA Forecast – Imports (2025)")
lines(actual_2025_ts, col = "green", lwd = 2)

legend("topleft",
       legend = c("Forecast 2025", "Actual 2025"),
       col = c("blue", "green"),
       lwd = 2)

# -------------------------------
# Accuracy check
# -------------------------------
accuracy_import_2025_3 <- accuracy(forecast_import, actual_2025_ts)
accuracy_import_2025_3


#############################################
# ARIMAX
#############################################


# -----------------------------------
# Arrange data by date
# -----------------------------------
data <- data[order(data$Period), ]

# -----------------------------------
# Training data: till 2024
# -----------------------------------
data_2024 <- data[data$Period <= as.Date("2024-12-31"), ]

# Actual 2025 data
data_2025 <- data[data$Period >= as.Date("2025-01-01") &
                    data$Period <= as.Date("2025-12-31"), ]

# -----------------------------------
# Import series till 2024
# -----------------------------------
import_train_ts <- ts(data_2024$`Import(US Million $)`,
                      start = c(1996, 4), frequency = 12)

log_import_train_ts <- log(import_train_ts)

# -----------------------------------
# XREG for training and 2025 forecast
# -----------------------------------
xreg_train <- cbind(
  GDP = data_2024$log_gdp,
  ER  = data_2024$log_er
)

xreg_test <- cbind(
  GDP = data_2025$log_gdp,
  ER  = data_2025$log_er
)

# Scale training xreg
scale_xreg <- scale(xreg_train)
xreg_train_scaled <- scale_xreg

# Scale 2025 xreg using training mean and sd
xreg_test_scaled <- scale(xreg_test,
                          center = attr(scale_xreg, "scaled:center"),
                          scale  = attr(scale_xreg, "scaled:scale"))

# -----------------------------------
# Fit ARIMAX model
# -----------------------------------
library(forecast)

arimax_import <- auto.arima(
  log_import_train_ts,
  xreg = xreg_train_scaled,
  seasonal = TRUE
)

# Summary
summary(arimax_import)

# -----------------------------------
# Forecast 12 months of 2025
# -----------------------------------
forecast_arimax <- forecast(
  arimax_import,
  xreg = xreg_test_scaled,
  h = 12
)

# -----------------------------------
# Actual 2025 exports for comparison
# -----------------------------------
actual_2025_ts <- ts(log(data_2025$`Import(US Million $)`),
                     start = c(2025, 1), frequency = 12)

# -----------------------------------
# Plot forecast vs actual 2025
# -----------------------------------
plot(forecast_arimax, main = "ARIMAX Forecast – Imports (2025)")
lines(actual_2025_ts, col = "green", lwd = 2)

legend("topleft",
       legend = c("Forecast 2025", "Actual 2025"),
       col = c("blue", "green"),
       lwd = 2)

# -----------------------------------
# Accuracy for 2025
# -----------------------------------
accuracy_import_arimax_2025_4 <- accuracy(forecast_arimax, actual_2025_ts)
accuracy_import_arimax_2025_4

accuracy_import_2025_3

### For imports ARIMA is better with respect to RMSE


##############################################################################
# ARIMA Codes for Export after FTA
###

# Make sure data is sorted by date
data <- data[order(data$Period), ]

# -------------------------------
# Training data: up to 2024 only
# -------------------------------
data_2024 <- data[data$Period>=as.Date("2011-08-01") &
                    data$Period <= as.Date("2024-12-31"), ]

# Actual 2025 data
data_2025 <- data[data$Period >= as.Date("2025-01-01") &
                    data$Period <= as.Date("2025-12-31"), ]

# Check that 2025 has 12 months
nrow(data_2025)

# -------------------------------
# Create time series
# -------------------------------
export_ts <- ts(data_2024$`Export(US Million $)`,start = c(2011,8), frequency = 12)

# Log transform
log_export_ts <- log(export_ts)

# Fit ARIMA on full data till 2024
library(forecast)
arima_export <- auto.arima(log_export_ts)

# Forecast 12 months = 2025
forecast_export <- forecast(arima_export, h = 12)

# Create actual 2025 time series with correct time alignment
actual_2025_ts <- ts(log(data_2025$`Export(US Million $)`),
                     start = c(2025, 1), frequency = 12)

# -------------------------------
# Plot forecast + actual 2025
# -------------------------------
plot(forecast_export, main = "ARIMA Forecast – Exports (2025)")
lines(actual_2025_ts, col = "green", lwd = 2)

legend("topleft",
       legend = c("Forecast 2025", "Actual 2025"),
       col = c("blue", "green"),
       lwd = 2)

# -------------------------------
# Accuracy check
# -------------------------------
accuracy_export_2025_5 <- accuracy(forecast_export, actual_2025_ts)
accuracy_export_2025_5


#############################################
# ARIMAX
#############################################


# -----------------------------------
# Arrange data by date
# -----------------------------------
data <- data[order(data$Period), ]

# -----------------------------------
# Training data: till 2024
# -----------------------------------
data_2024 <- data[data$Period>=as.Date("2011-08-01") &
                    data$Period <= as.Date("2024-12-31"), ]

# Actual 2025 data
data_2025 <- data[data$Period >= as.Date("2025-01-01") &
                    data$Period <= as.Date("2025-12-31"), ]

# -----------------------------------
# Export series till 2024
# -----------------------------------
export_train_ts <- ts(data_2024$`Export(US Million $)`,
                      start = c(2011, 8), frequency = 12)

log_export_train_ts <- log(export_train_ts)

# -----------------------------------
# XREG for training and 2025 forecast
# -----------------------------------
xreg_train <- cbind(
  GDP = data_2024$log_gdp,
  ER  = data_2024$log_er
)

xreg_test <- cbind(
  GDP = data_2025$log_gdp,
  ER  = data_2025$log_er
)

# Scale training xreg
scale_xreg <- scale(xreg_train)
xreg_train_scaled <- scale_xreg

# Scale 2025 xreg using training mean and sd
xreg_test_scaled <- scale(xreg_test,
                          center = attr(scale_xreg, "scaled:center"),
                          scale  = attr(scale_xreg, "scaled:scale"))

# -----------------------------------
# Fit ARIMAX model
# -----------------------------------
library(forecast)

arimax_export <- auto.arima(
  log_export_train_ts,
  xreg = xreg_train_scaled,
  seasonal = TRUE
)

# Summary
summary(arimax_export)

# -----------------------------------
# Forecast 12 months of 2025
# -----------------------------------
forecast_arimax <- forecast(
  arimax_export,
  xreg = xreg_test_scaled,
  h = 12
)

# -----------------------------------
# Actual 2025 exports for comparison
# -----------------------------------
actual_2025_ts <- ts(log(data_2025$`Export(US Million $)`),
                     start = c(2025, 1), frequency = 12)

# -----------------------------------
# Plot forecast vs actual 2025
# -----------------------------------
plot(forecast_arimax, main = "ARIMAX Forecast – Exports (2025)")
lines(actual_2025_ts, col = "green", lwd = 2)

legend("topleft",
       legend = c("Forecast 2025", "Actual 2025"),
       col = c("blue", "green"),
       lwd = 2)

# -----------------------------------
# Accuracy for 2025
# -----------------------------------
accuracy_export_arimax_2025_6 <- accuracy(forecast_arimax, actual_2025_ts)
accuracy_export_arimax_2025_6

accuracy_export_2025_5

## ARIMAX is better than ARIMA





##################
# ARIMA Codes for Import after FTA
###

# Make sure data is sorted by date
data <- data[order(data$Period), ]

# -------------------------------
# Training data: up to 2024 only
# -------------------------------
data_2024 <- data[data$Period>=as.Date("2011-08-01") &
                    data$Period <= as.Date("2024-12-31"), ]

# Actual 2025 data
data_2025 <- data[data$Period >= as.Date("2025-01-01") &
                    data$Period <= as.Date("2025-12-31"), ]

# Check that 2025 has 12 months
nrow(data_2025)

# -------------------------------
# Create time series
# -------------------------------
import_ts <- ts(data_2024$`Import(US Million $)`,start = c(2011,8), frequency = 12)

# Log transform
log_import_ts <- log(import_ts)

# Fit ARIMA on full data till 2024
library(forecast)
arima_import <- auto.arima(log_import_ts)

# Forecast 12 months = 2025
forecast_import <- forecast(arima_import, h = 12)

# Create actual 2025 time series with correct time alignment
actual_2025_ts <- ts(log(data_2025$`Import(US Million $)`),
                     start = c(2025, 1), frequency = 12)

# -------------------------------
# Plot forecast + actual 2025
# -------------------------------
plot(forecast_import, main = "ARIMA Forecast – Imports (2025)")
lines(actual_2025_ts, col = "green", lwd = 2)

legend("topleft",
       legend = c("Forecast 2025", "Actual 2025"),
       col = c("blue", "green"),
       lwd = 2)

# -------------------------------
# Accuracy check
# -------------------------------
accuracy_import_2025_7 <- accuracy(forecast_import, actual_2025_ts)
accuracy_import_2025_7


#############################################
# ARIMAX
#############################################


# -----------------------------------
# Arrange data by date
# -----------------------------------
data <- data[order(data$Period), ]

# -----------------------------------
# Training data: till 2024
# -----------------------------------
data_2024 <- data[data$Period>=as.Date("2011-08-01") &
                    data$Period <= as.Date("2024-12-31"), ]

# Actual 2025 data
data_2025 <- data[data$Period >= as.Date("2025-01-01") &
                    data$Period <= as.Date("2025-12-31"), ]

# -----------------------------------
# Export series till 2024
# -----------------------------------
import_train_ts <- ts(data_2024$`Import(US Million $)`,
                      start = c(2011,8), frequency = 12)

log_import_train_ts <- log(import_train_ts)

# -----------------------------------
# XREG for training and 2025 forecast
# -----------------------------------
xreg_train <- cbind(
  GDP = data_2024$log_gdp,
  ER  = data_2024$log_er
)

xreg_test <- cbind(
  GDP = data_2025$log_gdp,
  ER  = data_2025$log_er
)

# Scale training xreg
scale_xreg <- scale(xreg_train)
xreg_train_scaled <- scale_xreg

# Scale 2025 xreg using training mean and sd
xreg_test_scaled <- scale(xreg_test,
                          center = attr(scale_xreg, "scaled:center"),
                          scale  = attr(scale_xreg, "scaled:scale"))

# -----------------------------------
# Fit ARIMAX model
# -----------------------------------
library(forecast)

arimax_import <- auto.arima(
  log_import_train_ts,
  xreg = xreg_train_scaled,
  seasonal = TRUE
)

# Summary
summary(arimax_import)

# -----------------------------------
# Forecast 12 months of 2025
# -----------------------------------
forecast_arimax <- forecast(
  arimax_import,
  xreg = xreg_test_scaled,
  h = 12
)

# -----------------------------------
# Actual 2025 exports for comparison
# -----------------------------------
actual_2025_ts <- ts(log(data_2025$`Import(US Million $)`),
                     start = c(2025, 1), frequency = 12)

# -----------------------------------
# Plot forecast vs actual 2025
# -----------------------------------
plot(forecast_arimax, main = "ARIMAX Forecast – Imports (2025)")
lines(actual_2025_ts, col = "green", lwd = 2)

legend("topleft",
       legend = c("Forecast 2025", "Actual 2025"),
       col = c("blue", "green"),
       lwd = 2)

# -----------------------------------
# Accuracy for 2025
# -----------------------------------

accuracy_import_arimax_2025_8 <- accuracy(forecast_arimax, actual_2025_ts)
accuracy_import_arimax_2025_8

accuracy_import_2025_7
# Both models give almost the same prediction accuracy. Adding GDP and exchange rate does not significantly improve forecasting.
# So ARIMA


#### After doing it for all

# For Export
accuracy_export_arimax_2025_2  # For entire data
accuracy_export_arimax_2025_6  # For Post data
# Post-FTA model is clearly better

# For Import
accuracy_import_2025_3   # For entire data
accuracy_import_2025_7   # For Post data
# Entire data model is clearly better





