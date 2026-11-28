# Impact of Free Trade Agreements (FTA) on India's Trade Flows

## A Case Study on India–Japan and India–Singapore Trade

*Time series analysis project | Group 09 | Mentor: Dr. Leena Kulkarni*

---

## Table of Contents

- [1. Introduction](#1-introduction)
- [2. Problem Statement](#2-problem-statement)
- [3. Business and Research Objectives](#3-business-and-research-objectives)
- [4. What is an FTA?](#4-what-is-an-fta)
- [5. Data Description](#5-data-description)
- [6. Data Preparation](#6-data-preparation)
- [7. Techniques Used](#7-techniques-used)
- [8. Analysis and Interpretation: India–Japan](#8-analysis-and-interpretation-indiajapan)
- [9. Analysis Summary: India–Singapore](#9-analysis-summary-indiasingapore)
- [10. Conclusion](#10-conclusion)
- [11. Limitations and Future Scope](#11-limitations-and-future-scope)
- [12. How to Run the Code](#12-how-to-run-the-code)
- [13. Team](#13-team)
- [14. References](#14-references)

---

## 1. Introduction

When two countries sign a Free Trade Agreement, the usual promise is simple: trade becomes cheaper, easier and more predictable. But a promise on paper is not the same as a change in real numbers.

In this project we looked at **monthly trade between India and Japan** (and later India and Singapore) to see what actually happened to trade once the agreement came into force. We did not only look at whether trade went up. We also asked whether it became *more stable* or *more risky* for businesses, and whether macroeconomic factors like <u>GDP</u> and the <u>exchange rate</u> help us predict it.

---

## 2. Problem Statement

> **Do FTAs create real economic value, or are they just policy-level changes?**

To answer this, we split the question into two parts.


Does an FTA give companies a stable and predictable trade environment that they can plan around?


Can we find statistical proof of change (structural breaks), of risk (volatility), and of how well trade can be forecasted before and after the agreement?

---

## 3. Business and Research Objectives

### Business Objectives

1. To assess whether FTAs lead to stable and predictable trade environments for businesses.
2. To analyse how FTAs influence strategic decisions in trade, investment and market selection.
3. To evaluate how far FTAs improve market access and create business opportunities.

### Research Objectives

1. **Objective 1 (Stability):** analyse changes in trade flows before and after the FTA and detect structural breaks in trade patterns.
2. **Objective 2 (Volatility):** examine volatility and uncertainty in exports and imports.
3. **Objective 3 (Forecasting):** identify the role of economic factors (GDP and exchange rate) and compare forecasting performance.

---

## 4. What is an FTA?

An FTA is an agreement between countries to reduce trade barriers. It is meant to make trade cheaper, improve market access and boost economic activity.

One point matters a lot for this study:

> ***Signing an agreement is not the same as implementing it.***

Signing only means the agreement is made. Implementation is when real changes start. Trade effects can only be seen *after* implementation, so we use the **implementation date** as our break date and not the signing date.

| Country pair | Agreement | Date used in this study |
|---|---|---|
| India – Japan | Comprehensive Economic Partnership Agreement (CEPA) | 01 August 2011 |
| India – Singapore | Comprehensive Economic Cooperation Agreement (CECA) | 01 August 2005 |

---

## 5. Data Description

The data was collected from **IMF** and **WITS** (World Integrated Trade Solution).

| Item | Details |
|---|---|
| Frequency | Monthly |
| Period used for modelling | April 1996 to September 2025 (354 months) |
| Training period | Up to December 2024 |
| Testing period | January to September 2025 (9 months, because that is where the data ends) |
| Countries | Japan and Singapore |
| Trade variables | Imports, Exports, Trade Balance and Total Trade (US Million $) |
| Economic variables | GDP (quarterly) and Exchange Rate (India's rate divided by the partner's rate) |
| FTA dummy | 0 = before implementation, 1 = after implementation |

A small note on GDP: it is only available quarterly, so the same value is repeated for the three months of each quarter.

---

## 6. Data Preparation

These are the steps we followed, in order.

1. Collected trade data from WITS and GDP and exchange rate data from IMF.
2. Renamed the columns and put everything into one table for each country.
3. Filled the missing values using **LOESS** smoothing.
4. Took the **log** of trade, GDP and exchange rate. This reduces the size of big swings and makes growth easier to read.
5. Applied **differencing** (log of this month minus log of last month). This gives the monthly growth rate and removes the upward trend.
6. Checked <u>stationarity</u> using two tests that work in opposite ways, so that we do not depend on only one.
7. Created the **FTA dummy** from the implementation date.

| Test | Null hypothesis (H₀) | What we want to see |
|---|---|---|
| ADF | The series has a unit root (not stationary) | p-value below 0.05 |
| KPSS | The series is stationary | p-value above 0.05 |

For India–Japan, both exports and imports (after log and differencing) passed both tests. The ADF p-value was about 0.01 and the KPSS p-value was about 0.1, so the series are stationary and safe to model.

---

## 7. Techniques Used

| Part of the study | Technique | Why we used it |
|---|---|---|
| Objective 1 | Chow test | Checks for a break at a *known* date, here the FTA date |
| Objective 1 | CUSUM test | Checks whether the model stays stable over time, no date needed |
| Objective 1 | Bai–Perron test | Finds *multiple* break dates from the data itself |
| Objective 2 | 12-month rolling volatility | Shows how the uncertainty moves over time |
| Objective 2 | ACF, PACF and Ljung–Box test | Checks whether past values affect the current value |
| Objective 2 | ARCH test, then GARCH(1,1) | Checks whether volatility comes in clusters, and models it if it does |
| Objective 3 | ARIMA | Forecasts using only the history of the series |
| Objective 3 | ARIMAX | Forecasts using the history *plus* GDP and exchange rate |
| Objective 3 | RMSE, MAE, MASE | Compare forecast accuracy (lower is better) |

##### How the volatility part was planned

We started with the entire data (1996 to 2024) and also the post-FTA data. For each, we calculated the rolling volatility and checked for autocorrelation. Then we fitted an ARIMA model and tested its residuals for the ARCH effect. A GARCH model was fitted only where the ARCH effect was present. Finally we forecasted with ARIMA and ARIMAX and compared them.

---

## 8. Analysis and Interpretation: India–Japan

### 8.1 Objective 1: Is trade stable before and after the FTA?

#### Exports

| Test | Result | Decision | What it means |
|---|---|---|---|
| Chow test (August 2011) | p < 2.2e-16 | Reject H₀ | A structural break exists |
| CUSUM test | p = 4.414e-13 | Reject H₀ | The model is not stable over time |
| Bai–Perron test | Breaks at Dec 2003, May 2008, Oct 2012, Jan 2017 | – | Several shifts, and **Oct 2012 is the one closest to the FTA** |

#### Imports

| Test | Result | Decision | What it means |
|---|---|---|---|
| Chow test (August 2011) | p < 2.2e-16 | Reject H₀ | A structural break exists |
| CUSUM test | p = 0.02766 | Reject H₀ | The model is not stable over time |
| Bai–Perron test | Breaks at Jun 2000, Mar 2013 | – | **Mar 2013 is the one closest to the FTA** |

##### Interpretation

Both exports and imports **did not remain structurally stable** across the sample. The break dates closest to the FTA (October 2012 for exports and March 2013 for imports) come *after* August 2011. This suggests that the effect of an FTA does not show up on day one. It takes some time after implementation to appear in the numbers.

---

### 8.2 Objective 2: Did the FTA change volatility and uncertainty?

#### Rolling volatility, before and after the FTA

| Series | Before FTA | After FTA | What it means |
|---|---|---|---|
| Exports | Lower | **Higher** | Exports became less predictable |
| Imports | **Higher** | Lower | Imports became more stable |

#### Autocorrelation and ARCH tests

| Sample | Series | Ljung–Box p-value | ARCH p-value | ARCH effect present? |
|---|---|---|---|---|
| Entire data (1996–2024) | Exports | 8.327e-15 | 0.0321 | **Yes** (GARCH fitted) |
| Entire data (1996–2024) | Imports | 5.707e-14 | 1.000 | No |
| Post-FTA (2011–2024) | Exports | 2.716e-05 | 0.7724 | No |
| Post-FTA (2011–2024) | Imports | 1.606e-05 | 0.9261 | No |

##### Interpretation

- **Autocorrelation is present everywhere.** Every Ljung–Box p-value is below 0.05, so past values help explain current values. This is the reason ARIMA-type models are suitable.
- **Exports (entire data):** an ARCH effect exists, so we fitted a GARCH model. Export volatility is *time-varying and persistent*, which means a shock does not vanish quickly. The Nyblom stability statistics were below the critical values, so the GARCH parameters are stable.
- **Imports:** no ARCH effect. Import uncertainty is mostly *random* and not systematic. Imports were very volatile at the start of the sample, then settled down and stayed calm.
- **After the FTA:** no ARCH effect in either series. So the rise in average export volatility after the FTA is a change in *level*, not volatility clustering.

---

### 8.3 Objective 3: Can GDP and exchange rate improve the forecast?

Models were trained up to December 2024 and tested on 2025. Since the data ends in September 2025, the test set has **9 months**. The errors are on the log scale, and a lower value is better.

#### A. Entire period (1996–2024)

| Series | Metric | ARIMA | ARIMAX | Better model |
|---|---|---|---|---|
| Exports | RMSE | 0.1471579 | **0.1361909** | ARIMAX |
| Exports | MASE | 0.6088957 | **0.5725873** | ARIMAX |
| Exports | MAE | 0.1235007 | **0.1161364** | ARIMAX |
| Imports | RMSE | **0.1385284** | 0.2097312 | ARIMA |
| Imports | MASE | **0.4453468** | 0.7987511 | ARIMA |
| Imports | MAE | **0.1115087** | 0.1999962 | ARIMA |

#### B. Post-FTA period (2011–2024)

| Series | Metric | ARIMA | ARIMAX | Better model |
|---|---|---|---|---|
| Exports | RMSE | 0.1440020 | **0.1314863** | ARIMAX |
| Exports | MASE | 0.5808042 | **0.5312555** | ARIMAX |
| Exports | MAE | 0.1227455 | **0.1122740** | ARIMAX |
| Imports | RMSE | 0.1497068 | **0.1496255** | ARIMAX (very slightly) |
| Imports | MASE | **0.7398839** | 0.7418105 | ARIMA |
| Imports | MAE | **0.11896724** | 0.11927703 | ARIMA |

#### C. Entire period versus post-FTA (best model of each)

| Series | Entire period (RMSE) | Post-FTA (RMSE) | Better window |
|---|---|---|---|
| Exports (ARIMAX) | 0.1361909 | **0.1314863** | Post-FTA |
| Imports (ARIMA) | **0.1385284** | 0.1497068 | Entire period |

##### Interpretation

- **Exports depend on macro factors.** Adding GDP and exchange rate reduced all three errors in both windows. The best export forecast came from the post-FTA data, which tells us that export behaviour changed after the FTA and the new pattern is the one worth learning from.
- **Imports do not need extra variables.** Plain ARIMA was as good as, or better than, ARIMAX. For the entire period, adding GDP and exchange rate actually made the forecast worse.
- Using only post-FTA data did **not** improve the import forecast. So the FTA did not clearly make imports easier to predict, even though import volatility came down.

---

## 9. Analysis Summary: India–Singapore

We repeated the same steps for Singapore. The FTA came into force on **01 August 2005**, so the entire data covers 1996 to 2024 and the post-FTA data covers 2005 to 2024.

| Area | Exports | Imports |
|---|---|---|
| Chow test | Structural break exists | Structural break exists |
| Rolling volatility | Less stable | Highly fluctuating |
| ARCH test (entire and post-FTA) | No ARCH effect | No ARCH effect |
| ARIMA forecast | Accurate | Accurate |
| ARIMAX forecast (with GDP and exchange rate) | Accurate | Accurate |
| Most accurate overall | ARIMAX trained on post-FTA data | ARIMAX trained on post-FTA data |

The Singapore results point in the same general direction as Japan: a break around the FTA, no volatility clustering, and better forecasts when the post-FTA period and the macro variables are used.

---

## 10. Conclusion

### Research Conclusion

1. **Trade flows were not structurally stable.** The Chow, CUSUM and Bai–Perron tests all show clear breaks around the FTA period, so trade changed significantly after the agreement.
2. **The effect on volatility was uneven.** Export volatility *increased*, meaning more uncertainty, while import volatility *declined*, meaning more stable and predictable imports.
3. **Exports carry persistent risk; imports carry random risk.** The ARCH and GARCH results show export shocks stay for a while, whereas import shocks are mostly one-off and carry lower systematic risk.
4. **Forecasting.** ARIMAX improved the export forecast by adding GDP and exchange rate, while plain ARIMA was enough for imports.

### Business Conclusion

- Imports became more predictable, which helps with supply chain planning. In that sense Japan became a **reliable supplier** for India.
- Exports are still volatile. Businesses should not depend only on the FTA for stable export growth, because demand is linked to GDP and exchange rate movements.
- Japan became a more **complex and macro-driven market** for Indian exporters.
- FTAs open new markets but do not remove trade risk. Companies still need to watch economic conditions, diversify markets and keep resilient trade strategies.

> **Answer to our key question:** FTAs do create real change (the structural breaks prove it), but they do not automatically create a stable environment for both sides of trade.

---

## 11. Limitations and Future Scope

### Limitations

- Only two economic variables (GDP and exchange rate) were used.
- Trade was studied in total. There is no sector-wise breakdown.
- There is usually a gap between signing, implementation and the real adjustment, so effects may be delayed.
- ARIMA and ARIMAX depend on past patterns and cannot predict sudden shocks.
- GARCH models rely on strict statistical assumptions that may not match real trade behaviour fully.
- The test window is short (9 months of 2025), so the accuracy numbers should be read with some care.
- Global events such as the 2008 financial crisis and COVID-19 overlap with the study period and were not separated out.

### Future Scope

- Add tariff rates, inflation, oil prices and political indicators.
- Study sector-wise trade to see which industries gain the most.
- Look in more detail at the time lag between implementation and full impact.
- Control for global shocks to isolate the FTA effect better.
- Try non-linear and regime-switching models, and extend the study to more countries and FTAs for comparison.

---

## 12. How to Run the Code

The analysis was done in **R**. The packages used are `readxl`, `dplyr`, `ggplot2`, `tseries`, `strucchange`, `rugarch`, `forecast`, `zoo` and `FinTS`.

1. Open the project folder in RStudio and set it as the working directory.
2. Choose the country at the top of the script (Japan or Singapore).
3. Run the script from top to bottom. It follows the same order as this report: stationarity checks, structural breaks, volatility, and then forecasting.

---

## 13. Team

 1. Rudra Thakkar 
 2. Aryan Chawan 
 3. Gayatri Mahangade 
 4. Shaikh Iqra

 Mentor: *Dr. Leena Kulkarni*

---

## 14. References

1. Ghoshal, I. (2015). *Trade-growth relationship in India in the pre and post trade agreements regime.* Economics & Finance Conference 2015.
2. Febiyansah, P. T. (2021). *Does uncertainty matter for trade–economic growth nexus in Indonesia?* Indonesian Institute of Sciences.
3. Keck, A., Raubold, A., & Truppia, A. (2009). Forecasting international trade: A time series approach. *OECD Journal: Journal of Business Cycle Measurement and Analysis, 2009*(2).
4. Aronov, J. Z., Zharkova, A. A., & Rybakova, A. M. (2024). *Estimation of export effects based on the Chow test.*
5. Krugman, P. R., Obstfeld, M., & Melitz, M. J. (2018). *International economics: Theory and policy.* Pearson.
6. World Bank. (2020). *World development report 2020.*
7. Zeileis, A., Leisch, F., Hornik, K., & Kleiber, C. (2002). *strucchange* [R package]. CRAN.
8. Data sources: International Monetary Fund (IMF) and World Integrated Trade Solution (WITS), World Bank.
