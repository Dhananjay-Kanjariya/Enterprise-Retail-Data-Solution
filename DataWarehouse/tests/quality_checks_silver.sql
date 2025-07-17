-- ====================================================================
-- Quality Checks for 'silver.crm_cust_info'
-- ====================================================================

-- Check for NULLs or Duplicate Customer IDs (Primary Key Violation)
-- Expectation: No duplicate or NULL values in 'cst_id'
SELECT  
    cst_id,
    COUNT(*) 
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for Unwanted Leading/Trailing Spaces in 'cst_key'
-- Expectation: All keys should be trimmed
SELECT 
    cst_key 
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- Check for Consistency in Marital Status Values
-- Expectation: Limited, standardized set of values (e.g., Single, Married, etc.)
SELECT DISTINCT 
    cst_marital_status 
FROM silver.crm_cust_info;


-- ====================================================================
-- Quality Checks for 'silver.crm_prd_info'
-- ====================================================================

-- Check for NULLs or Duplicate Product IDs
-- Expectation: No duplicate or NULL values in 'prd_id'
SELECT 
    prd_id,
    COUNT(*) 
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for Unwanted Spaces in Product Names
-- Expectation: All 'prd_nm' values should be trimmed
SELECT 
    prd_nm 
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for NULLs or Negative Product Costs
-- Expectation: 'prd_cost' must be non-negative and non-null
SELECT 
    prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Review Distinct Product Line Values for Standardization
-- Expectation: Controlled vocabulary of product lines
SELECT DISTINCT 
    prd_line 
FROM silver.crm_prd_info;

-- Check for Invalid Product Date Ranges (start date after end date)
-- Expectation: 'prd_start_dt' should be earlier than 'prd_end_dt'
SELECT 
    * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


-- ====================================================================
-- Quality Checks for 'silver.crm_sales_details'
-- ====================================================================

-- Check for Invalid Date Values in 'sls_due_dt'
-- Expectation: Valid 8-digit integers within realistic date range
SELECT 
    NULLIF(sls_due_dt, 0) AS sls_due_dt 
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0 
    OR LEN(sls_due_dt) != 8 
    OR sls_due_dt > 20500101 
    OR sls_due_dt < 19000101;

-- Check for Logical Inconsistencies in Dates (Order > Ship/Due)
-- Expectation: 'sls_order_dt' should be on or before 'sls_ship_dt' and 'sls_due_dt'
SELECT 
    * 
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;

-- Validate Sales Amount Calculation (sales = quantity × price)
-- Expectation: Accurate and positive values; no NULLs
SELECT DISTINCT 
    sls_sales,
    sls_quantity,
    sls_price 
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;


-- ====================================================================
-- Quality Checks for 'silver.erp_cust_az12'
-- ====================================================================

-- Check for Out-of-Range or Future Birthdates
-- Expectation: Birthdates should be between 1924 and today
SELECT DISTINCT 
    bdate 
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' 
   OR bdate > GETDATE();

-- Review Gender Values for Standardization
-- Expectation: Consistent set of values (e.g., Male, Female, Other)
SELECT DISTINCT 
    gen 
FROM silver.erp_cust_az12;


-- ====================================================================
-- Quality Checks for 'silver.erp_loc_a101'
-- ====================================================================

-- Review Country Codes or Names for Consistency
-- Expectation: No duplicates, standard ISO codes or full country names
SELECT DISTINCT 
    cntry 
FROM silver.erp_loc_a101
ORDER BY cntry;


-- ====================================================================
-- Quality Checks for 'silver.erp_px_cat_g1v2'
-- ====================================================================

-- Check for Unwanted Spaces in Category/Subcategory/Maintenance Fields
-- Expectation: All values should be trimmed
SELECT 
    * 
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
   OR subcat != TRIM(subcat) 
   OR maintenance != TRIM(maintenance);

-- Review Distinct Maintenance Values for Standardization
-- Expectation: Controlled vocabulary (e.g., Active, Inactive)
SELECT DISTINCT 
    maintenance 
FROM silver.erp_px_cat_g1v2;
