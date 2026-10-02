USE DataWarehouse;
GO

SELECT * 
FROM bronze.crm_cust_info;

SELECT 
cst_id
FROM bronze.crm_cust_info
GROUP BY (cst_id)
HAVING COUNT(*) > 1 OR cst_id IS NULL

SELECT 
cst_firstname AS firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

SELECT 
cst_lastname AS lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

TRUNCATE TABLE silver.crm_cust_info
INSERT INTO silver.crm_cust_info (
cst_id, 
cst_key,
cst_firstname,
cst_lastname,
cst_gndr,
cst_marital_status,
cst_create_date,
dwh_create_date
)

SELECT 
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname,
TRIM(cst_lastname)AS cst_lastname,
CASE 
WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
ELSE 'n/a'
END AS cst_gndr,

CASE 
WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
ELSE 'n/a'
END AS cst_marital_status,

cst_create_date,

GETDATE()

FROM (
SELECT 
*,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM bronze.crm_cust_info
WHERE cst_id IS NOT NULL
)t 
WHERE flag_last = 1

SELECT 
* 
FROM silver.crm_cust_info


