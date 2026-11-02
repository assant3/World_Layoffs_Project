-- Exploratory Data Analysis
USE world_layoffs_v2;

SELECT *
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET total_laid_off = NULL 
WHERE total_laid_off = '' OR total_laid_off = 'NULL';

ALTER TABLE layoffs_staging2
MODIFY COLUMN total_laid_off INT;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2; #12000 people/100% layed off README

#Companies with 100% laid off staff, ranked by funds
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC; 

SELECT COUNT(*)
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC; #116 companies README

#Sum of total laid off README
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC; 

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

SELECT *
FROM layoffs_staging2;

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2; #README


SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

SELECT company, SUM(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC; #not as relevant 

# Rolling total (Progression of layoff) README
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC; 

# Layoffs per month with rolling total README
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

# Total laid off
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY company ASC;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

-- 1. What are the Top 5 companies per year laid off README
WITH Company_Year (company, industry, years, total_laid_off) AS
(
SELECT company, industry, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, industry, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *, 
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5; 

-- 2. How many layoffs per year? README

SELECT *
FROM layoffs_staging2;

SELECT YEAR(`date`) AS yr, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY yr
ORDER BY yr DESC;

-- 3. What are the Top industries per year README

WITH industry_year AS(
SELECT industry, YEAR(`date`) AS years, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE `date` IS NOT NULL AND industry IS NOT NULL
GROUP BY industry, YEAR(`date`)
)
SELECT *,
	DENSE_RANK() OVER(PARTITION BY years ORDER BY total_off DESC) AS ranking
FROM industry_year
WHERE total_off IS NOT NULL
ORDER BY years, ranking;

-- 4. What are the companies with multiple layoffs 

SELECT company, COUNT(*) as rounds, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
GROUP BY company
HAVING COUNT(*) > 1
ORDER BY rounds DESC, total_off DESC;

-- 5. Average layoff size and share of company laid off by industry

SELECT industry,
	COUNT(*) AS events, 
    ROUND(AVG(total_laid_off)) AS avg_laid_off,
    ROUND(AVG(percentage_laid_off), 2) AS avg_pct
FROM layoffs_staging2
GROUP BY industry
ORDER BY events DESC;

#Estimated company size README 

SELECT company, total_laid_off, percentage_laid_off,
ROUND(total_laid_off / percentage_laid_off) AS est_company_size
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
AND percentage_laid_off IS NOT NULL
AND percentage_laid_off > 0
ORDER BY est_company_size DESC;

#Checking if funding relates to layoffs README

SELECT stage,
COUNT(*) AS events,
ROUND(AVG(funds_raised_millions)) AS avg_funds,
ROUND(AVG(percentage_laid_off), 2) AS avg_pct_laid_off
FROM layoffs_staging2
GROUP BY stage
ORDER BY avg_funds DESC;








































