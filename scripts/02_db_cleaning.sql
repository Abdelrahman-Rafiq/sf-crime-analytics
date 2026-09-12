
-- Exploring Data 
SELECT * FROM sfpd_incidents ORDER BY incident_id LIMIT 20;
SELECT * FROM sfpd_incidents LIMIT 20;
SELECT * FROM sfpd_incidents where report_type_description LIKE 'Coplogic%' ;


-- 0. Create a staging table
CREATE TABLE staging_table AS(
SELECT * 
FROM sfpd_incidents
);

-- 1. Removing Duplicates


SELECT *,
ROW_NUMBER() OVER(
partition by incident_id,
		incident_code,
		incident_category,
		police_district
) as ranking
FROM staging_table
ORDER BY ranking DESC;  -- NO Duplicates!


-- 2. Standardizing data

SELECT DISTINCT report_type_description
FROM staging_table
ORDER BY report_type_description ; -- nothing 


SELECT DISTINCT incident_category
FROM staging_table
ORDER BY incident_category ; -- Many things should be standardized


SELECT DISTINCT incident_category
FROM staging_table
WHERE incident_category LIKE 'Drug%'
ORDER BY incident_category;

UPDATE staging_table
SET incident_category = 'Drug Violation'
WHERE incident_category LIKE 'Drug%';


SELECT DISTINCT incident_category
FROM staging_table
WHERE incident_category LIKE 'Sex%'
ORDER BY incident_category;

UPDATE staging_table
SET incident_category = 'Sex Offenses'
WHERE incident_category LIKE 'Sex%';


SELECT DISTINCT incident_category
FROM staging_table
WHERE incident_category LIKE '%Commercial Sex Acts'
ORDER BY incident_category;

UPDATE staging_table
SET incident_category = 'Human Trafficking (A), Commercial Sex Acts'
WHERE incident_category LIKE '%Commercial Sex Acts';

SELECT DISTINCT incident_category
FROM staging_table
WHERE incident_category LIKE 'Suspicious%'
ORDER BY incident_category;

UPDATE staging_table
SET incident_category = 'Suspicious'
WHERE incident_category LIKE 'Suspicious%';

SELECT DISTINCT incident_category
FROM staging_table
WHERE (incident_category LIKE '%Miscellaneous%') OR (incident_category LIKE '%Other%')
ORDER BY incident_category;

UPDATE staging_table
SET incident_category = 'Other Offenses'
WHERE (incident_category LIKE '%Miscellaneous%') OR (incident_category LIKE '%Other%');


SELECT DISTINCT incident_category
FROM staging_table
WHERE incident_category LIKE 'Weapons Off%'
ORDER BY incident_category;

UPDATE staging_table
SET incident_category = 'Weapons Offence'
WHERE incident_category LIKE 'Weapons Off%';


SELECT DISTINCT incident_category
FROM staging_table
WHERE incident_category LIKE 'Motor Vehicle Theft%'
ORDER BY incident_category;

UPDATE staging_table
SET incident_category = 'Motor Vehicle Theft'
WHERE incident_category LIKE 'Motor Vehicle Theft%';

SELECT DISTINCT incident_category
FROM staging_table
ORDER BY incident_category ; -- Now this is clean

SELECT DISTINCT incident_subcategory
FROM staging_table
ORDER BY incident_subcategory ; -- Many things should be standardized

SELECT DISTINCT incident_subcategory
FROM staging_table
WHERE incident_subcategory LIKE '%From Vehicle'
ORDER BY incident_subcategory;

UPDATE staging_table
SET incident_subcategory = 'Theft From Vehicle'
WHERE incident_subcategory LIKE '%From Vehicle';

SELECT DISTINCT incident_subcategory
FROM staging_table
WHERE (incident_subcategory LIKE '%Miscellaneous%') OR (incident_subcategory LIKE 'Other%')
ORDER BY incident_subcategory;

UPDATE staging_table
SET incident_subcategory = 'Other Offenses'
WHERE (incident_subcategory LIKE '%Miscellaneous%') OR (incident_subcategory LIKE 'Other%');

SELECT DISTINCT incident_subcategory
FROM staging_table
ORDER BY incident_subcategory ; -- This is good now

SELECT DISTINCT resolution
FROM staging_table
ORDER BY resolution ; -- This is good

SELECT DISTINCT police_district
FROM staging_table
ORDER BY police_district ; -- This is good


SELECT DISTINCT supervisor_district
FROM staging_table
ORDER BY supervisor_district ; -- This is good

SELECT DISTINCT intersection
FROM staging_table 
ORDER BY intersection ; -- This is good

-- 3. Dealing with NULL values


SELECT * FROM staging_table;

SELECT COUNT(*),
	COUNT(*) - COUNT(incident_category) AS missing_category,
	COUNT(*) - COUNT(incident_subcategory) AS missing_subcategory,
	COUNT(*) - COUNT(resolution) AS missing_resolution,
	COUNT(*) - COUNT(incident_datetime) AS missing_incident_datetime,
	COUNT(*) - COUNT(police_district) AS missing_police_district,
	COUNT(*) - COUNT('intersection') AS missing_intersection,
	COUNT(*) - COUNT('point') AS missing_point
FROM staging_table; -- Less than 0.1% of the data records have null values in category/subcategory columns

-- Filling some null values in incident_category

SELECT DISTINCT incident_description
FROM staging_table
WHERE incident_category IS NULL AND incident_subcategory IS NULL ;

SELECT incident_category, incident_subcategory,incident_description
FROM staging_table
WHERE incident_description IN (
SELECT DISTINCT incident_description
FROM staging_table
WHERE incident_category IS NULL AND incident_subcategory IS NULL 
);

SELECT DISTINCT incident_description
FROM staging_table
WHERE incident_category IS NULL AND incident_subcategory IS NULL AND incident_description LIKE 'Sex%';


UPDATE staging_table
SET incident_category = 'Sex Offenses'
WHERE incident_category IS NULL AND incident_subcategory IS NULL AND incident_description LIKE 'Sex%';

UPDATE staging_table
SET incident_subcategory = 'Sex Offenses'
WHERE  incident_subcategory IS NULL AND incident_description LIKE 'Sex%';


SELECT DISTINCT incident_description
FROM staging_table
WHERE incident_category IS NULL AND incident_subcategory IS NULL AND incident_description LIKE 'Theft%';

UPDATE staging_table
SET incident_category = 'Larceny Theft'
WHERE incident_subcategory IS NULL AND incident_description LIKE 'Theft%';


UPDATE staging_table
SET incident_subcategory = 'Larceny - From Building'
WHERE incident_subcategory IS NULL AND incident_description LIKE 'Theft, Phone%';

UPDATE staging_table
SET incident_subcategory = 'Larceny Theft - Shoplifting'
WHERE incident_subcategory IS NULL AND incident_description = 'Theft, Organized Retail';

UPDATE staging_table
SET incident_subcategory = 'Larceny - Auto Parts'
WHERE incident_subcategory IS NULL AND incident_description = 'Theft, Catalytic Converter';

UPDATE staging_table
SET incident_subcategory = 'Larceny - Other'
WHERE incident_subcategory IS NULL AND incident_description LIKE 'Theft%';

SELECT DISTINCT incident_description
FROM staging_table
WHERE incident_description LIKE 'Assault, By%' 
OR incident_description LIKE 'Assault, Commission%'
OR incident_description LIKE 'SFMTA%';


UPDATE staging_table
SET incident_category = 'Assault' , incident_subcategory = 'Assault'
WHERE incident_description LIKE 'Assault, By%' 
OR incident_description LIKE 'Assault, Commission%'
OR incident_description LIKE 'SFMTA%';


UPDATE staging_table
SET incident_category = 'Non-Criminal'
WHERE incident_description IN(
'Business Inspection- 2805 CVC',
'Gun Violence Restraining Order',
'Gun Violence Restraining Order Violation',
'Public Health Order Violation, Notification',
'Vehicle, Seizure Order Service',
'Service of Documents Related to a Civil Drug Abatement and/or Public Nuisance Action'
);


-- DELETE records with missing category
SELECT incident_category, incident_subcategory,incident_description
FROM staging_table 
WHERE incident_category IS NULL;


DELETE FROM staging_table
WHERE incident_category IS NULL;

-- DELETE non-criminal records 
SELECT incident_category, incident_subcategory,incident_description
FROM staging_table 
WHERE incident_category = 'Non-Criminal';


DELETE FROM staging_table
WHERE incident_category = 'Non-Criminal';



-- EDA 


CREATE OR REPLACE VIEW v_crime_volume_analysis AS
SELECT 
    row_id,
    incident_id,
    incident_datetime,
    incident_date,
    incident_time,
    incident_year,
    incident_day_of_week,
    incident_category,
    incident_subcategory,
    police_district,
    intersection,       
    latitude,
    longitude,
    point               
FROM staging_table
WHERE report_type_description LIKE 'Initial%' 
   OR report_type_description LIKE '%Initial';



