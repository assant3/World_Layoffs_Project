# World Layoffs: Data Cleaning and EDA in MySQL

## Table of Contents

1. [Project Overview](#project-overview)
2. [Data Cleaning](#data-cleaning)
3. [Analysis Scope](#analysis-scope)
4. [Exploratory Data Analysis](#exploratory-data-analysis)
5. [Key Findings](#key-findings)
6. [Recommendations](#recommendations)
7. [Limitations](#limitations)
8. [References](#references)

## Project Overview
**Goal:**
- Clean a messy layoffs dataset, explore layoff trends throughout the years and possibly identify contributing factors to the layoffs using MySQL.
  
**Data:**
- Layoffs (2361 rows, 9 columns; Alex the Analyst, GitHub).
  
**Tools:**
- MySQL 9, MySQL Workbench
  
**Files:** `layoffs.csv`, `World_Layoffs_Data_Cleaning_Project.sql`, `World_Layoffs_EDA_Project.sql`

## Data cleaning

| Issue | Before | After |
 |---|---|---|
 | Certain columns contained duplicates |Columns look like duplicates but certain rows differ |Duplicates identified with CTE and values were removed |
| Whitespaces in company column | Rows with whitespaces | Whitespaces removed |
| Industry column has 2 names for Crypto | Crypto Currency | Crypto |
| Country column has 2 names for United States | United States. | United States |
| Date column structure is incorrect | m/d/y | d/m/y |
| Date column data type is incorrect | text | date |
| NULL values | NULL and blank values | Values populated by creating duplicate table |
| Column with too many missing values| total_laid_off and percentage_laid_off with many NULL values | NULL values deleted |

The raw table (`layoffs`) was never modified.

## Analysis scope

- Using layoff data of employees across different companies in different industries across the world from 2020-2023.

## Exploratory Data Analysis

### Highest amount of employees laid off and highest percentage
```
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;
```
- The highest amount employees laid off from one company is 12000 which was presumably a big company that could still be functional without them.
- The highest percentage of employees laid off which likely means that the company had to close its doors.
  
### Companies with 100% laid off staff, ranked by funds
```
SELECT COUNT(*)
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
```
- 116 companies laid off all of their employees, most likely leading them to stop operating.

### Number of layoffs per year 
  ```
  SELECT YEAR(`date`), SUM(total_laid_off)
  FROM layoffs_staging2
  GROUP BY YEAR(`date`)
  ORDER BY 1 DESC;
  ```
- 80998 employees were laid off in 2020 and increased to 125677 in 2023. The layoffs in 2020 may be contributed to Covid-19 which pushed companies to decrease their expenses. In 2023 companies may have not been able to get back on their feet due to the economic damage of COVID-19 throughout the years.

### Progression of layoffs per month
```
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC

)
SELECT `MONTH`, total_off,
SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total; 
```
- Rolling total was calculated with the use of a CTE with the total being 383159

## Estimated company size
```
SELECT company, total_laid_off, percentage_laid_off,
ROUND(total_laid_off / percentage_laid_off) AS est_company_size
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
AND percentage_laid_off IS NOT NULL
AND percentage_laid_off > 0
ORDER BY est_company_size DESC;
```
- The company size is estimated using the total_laid_off and percentage_laid_off

## Key Findings
1. **Top companies per year laid off:** The companies with the most layoffs per year are Uber(2020), Bytedance(2021), Meta(2022) and Google(2023).
Uber being the top company in 2021 may be contributed to the 2021 worldwide Covid-19 shutdown which restricted their customers from using their service the way it was prior.
The 3 Tech companies in 2021, 2022 and 2023 layoffs may have been impacted by the aftermath of Covid-19 and would have had to adjust back to a functional society which would mean getting more technical equipment for employees that worked from home which may have not been budgeted for.

2. **Layoffs per year:** 2021 (15823 employees) had the least amount of layoffs whereas in 2022 (160661 employees) had the most amount of layoffs between 2020 and 2023. This could be due to employees coming back to office from being remote and in 2022 companies realised that they cannot afford to have that many employees in office.

3. **Top industries with layoffs per year:** Transportation (2020), Consumer (2021), Retail (2022), Other (2023).
Transportation industry may have decreased in demand due to the global shutdown during Covid-19 shutdown.
Consumer industry may have decreased in demand due to customers not being able to afford certain goods anymore.
Retail industry may have decreased in demand due to customer being accustomed to shopping online after the shutdown so sales in-store decrease significantly.
Other may have the highest layoffs in 2023 due to companies not being able to rebuild what had been lost due to Covid-19 over the years.

## Recommendations
- Companies may need to adjust their marketing, services or products to increase their revenue post pandemic.
  
## Limitations
- The years are only from 2020-2023 so I cannot analyse whether current affairs may be affecting the layoffs of these companies.
- The total number of employees in each company is not given so the magnitude of how many employees were laid off cannot be grasped.
  
## References 
- [Alex The Analyst](https://www.youtube.com/watch?v=cnjhHZNJEDk&t=70320s)



