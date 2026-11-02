USE world_layoffs_v2;

SELECT COUNT(*) FROM layoffs;

LOAD DATA LOCAL INFILE '/Users/assante/Downloads/layoffs.csv'
INTO TABLE layoffs
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM layoffs;
SHOW WARNINGS;

TRUNCATE TABLE layoffs;

-- Data Cleaning 

USE world_layoffs_v2;

 SELECT *
 FROM layoffs;
 
 CREATE TABLE layoffs_staging
 LIKE layoffs;
 
 SELECT *
 FROM layoffs_staging;
 
 INSERT layoffs_staging
 SELECT *
 FROM layoffs;
 
 -- Cleaning duplicates
 SELECT *,
 ROW_NUMBER() OVER(
 PARTITION BY company, industry, 
 total_laid_off, percentage_laid_off, `date`,
 stage, country, funds_raised_millions) AS row_num
 FROM layoffs_staging; #row_num above 1 is dupilcate
 
 #creating cte to identify duplicates 
 WITH duplicate_cte AS
 (
 SELECT *,
 ROW_NUMBER() OVER(
 PARTITION BY company, location, industry,
 total_laid_off, percentage_laid_off, `date`,
 stage, country, funds_raised_millions) AS row_num
 FROM layoffs_staging
 )
 
 SELECT *
 FROM duplicate_cte
 WHERE row_num > 1;
 
 DROP TABLE IF EXISTS layoffs_staging2;

#creating a new table  
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` text,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2
SELECT *,
 ROW_NUMBER() OVER(
 PARTITION BY company, location, industry,
 total_laid_off, percentage_laid_off, `date`,
 stage, country, funds_raised_millions) AS row_num
 FROM layoffs_staging;

#deleting duplicates 
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

SET SQL_SAFE_UPDATES = 0;

DELETE
FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2;

-- Standardizing data

#removing whitespaces in rows 
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

#renaming industry with same names
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%'; 

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%'; #crypto currency -> crypto

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

#renaming countries with same name 
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country
FROM layoffs_staging2
WHERE country LIKE 'United States%'
ORDER BY 1;
 
 SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
 FROM layoffs_staging2
 ORDER BY 1;
 
 UPDATE layoffs_staging2
 SET country = TRIM(TRAILING '.' FROM country)
 WHERE country LIKE 'United States%'; #united states. -> united states
 
 #changing the structure and data type of the date 
 SELECT `date`,
 STR_TO_DATE(`date`, '%m/%d/%Y')
 FROM layoffs_staging2;
 
 UPDATE layoffs_staging2
 SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y'); #12/25/2020 -> 25/12/2020
 
 #text to date
 SELECT `date`
 FROM layoffs_staging2;
 
 ALTER TABLE layoffs_staging2
 MODIFY COLUMN `date` DATE; # text to date
 
 
 -- Dealing with NULL values
 
 SELECT *
 FROM layoffs_staging2
 WHERE total_laid_off IS NULL
 AND percentage_laid_off IS NULL; #both null = useless 
 
 
 #updating blanks to null 
 UPDATE layoffs_staging2
 SET industry = NULL 
 WHERE industry = '';
 
 
 SELECT *
 FROM layoffs_staging2
 WHERE industry IS NULL
 OR industry = '';
 
 SELECT *
 FROM layoffs_staging2
 WHERE company = 'Airbnb';
 
 SELECT *
 FROM layoffs_staging2
 WHERE company LIKE 'Bally%';
 
 
 SELECT *
 FROM layoffs_staging2 t1
 JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL; #populating values of t2 where t1 is blank/ 3 rows affected


-- Removing rows or columns

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;



 
 
 
 
 
 
 
 
 
 
 
 