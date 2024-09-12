use credit_risk_sql;

-- Drop the table if it already exists
DROP TABLE IF EXISTS creditrisk;

-- Recreate the table
CREATE TABLE creditrisk (
    Id INT PRIMARY KEY,
    person_age INT,
    person_income INT,
    person_home_ownership VARCHAR(45),
    person_emp_length INT,
    loan_intent VARCHAR(45),
    loan_grade VARCHAR(15),
    loan_amnt INT,
    loan_int_rate DOUBLE,
    loan_status int,
    loan_percent_income DOUBLE,
    cb_person_default_on_file VARCHAR(10),
    cb_person_cred_hist_length INT
);
                         
select * from creditrisk;
SELECT COUNT(*) AS total_rows
FROM creditrisk;

SELECT COUNT(DISTINCT Id) AS total_distinct_borrowers
FROM creditrisk;

-- Quick Summary of age, income, loan amount, interest rate
SELECT
    AVG(person_age) AS avg_age,
    AVG(person_income) AS avg_income,
    AVG(loan_amnt) AS avg_loan_amount,
    AVG(loan_int_rate) AS avg_interest_rate,
	AVG(person_emp_length) AS avg_emplnt_len
FROM creditrisk;

-- Important Business Insights: 

-- Find the highest age of loan defaulters for each combination of loan grade, along with the default rate and average income
SELECT 
    loan_grade,
    MAX(CASE WHEN loan_status = 1 THEN person_age ELSE NULL END) AS highest_age_of_defaulters,
    COUNT(CASE WHEN loan_status = 1 THEN 1 ELSE NULL END) / COUNT(*) AS default_rate, # Calculates the default rate by dividing the number of defaulted loans by the total number of loans within each loan grade.
    AVG(person_income) AS avg_income
FROM 
    creditrisk
GROUP BY 
    loan_grade 
ORDER BY
	default_rate DESC;

-- Distribution of Loan Status
-- Check the distribution of loans and loan_type that have defaulted versus non-defaulted loans.
SELECT loan_status, COUNT(*) AS total_loans,
	   loan_grade 
FROM creditrisk
GROUP BY loan_status, loan_grade;

-- Count of Home Ownership Types
-- How many people own, rent, or have a mortgage?

SELECT person_home_ownership, COUNT(*) AS count
FROM creditrisk
GROUP BY person_home_ownership
ORDER BY count DESC;

-- Income and Loan Amount Relationship
-- Analyze how loan amounts relate to income levels.
SELECT
    person_income,
    AVG(loan_amnt) AS avg_loan_amount,
    COUNT(*) AS num_loans
FROM creditrisk
GROUP BY person_income
ORDER BY person_income DESC;

-- Default Rate by Loan Grade
-- Check which loan grades have the highest default rate.

SELECT
    loan_grade,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS defaults,
    COUNT(*) AS total_loans,
    ROUND(SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS default_rate
FROM creditrisk
GROUP BY loan_grade
ORDER BY default_rate DESC;

-- Credit History and Defaults
-- Find if people with shorter credit histories tend to default more.

SELECT
    cb_person_cred_hist_length AS credit_history_length,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS defaults,
    COUNT(*) AS total_loans,
    ROUND(SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS default_rate
FROM creditrisk
GROUP BY cb_person_cred_hist_length
ORDER BY credit_history_length DESC;

-- Average Loan Amount by Employment Length to understand how the loan amounts vary by the number of years a person has been employed.
SELECT
    person_emp_length,
    AVG(loan_amnt) AS avg_loan_amount
FROM creditrisk
GROUP BY person_emp_length
ORDER BY person_emp_length;

-- Loan Intent and Default Rate Determine: which loan intents (e.g., personal, medical) have the highest default rate.
SELECT
    loan_intent,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS num_defaults,
    COUNT(*) AS total_loans,
    ROUND(SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS default_rate
FROM creditrisk
GROUP BY loan_intent
ORDER BY default_rate DESC;

-- Loan Grade vs Interest Rate to compare the average interest rates across different loan grades.
SELECT
    loan_grade,
    AVG(loan_int_rate) AS avg_interest_rate
FROM creditrisk
GROUP BY loan_grade
ORDER BY avg_interest_rate DESC;

-- Default Rate by Home Ownership in order to analyze default rates based on home ownership (e.g., rent, own, mortgage).
SELECT
    person_home_ownership,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS num_defaults,
    COUNT(*) AS total_loans,
    ROUND(SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS default_rate
FROM creditrisk
GROUP BY person_home_ownership
ORDER BY default_rate DESC;

-- Credit Risk Score Calculation
-- Create a simple credit risk score by combining factors such as loan amount, interest rate, and historical defaults.

SELECT
    person_age,
    person_income,
    loan_amnt,
    loan_int_rate,
    cb_person_cred_hist_length,
    loan_status,
    CASE
        WHEN loan_status = 1 THEN 
            (loan_amnt * 0.3 + loan_int_rate * 0.4 + cb_person_cred_hist_length * 0.3)
        ELSE
            (loan_amnt * 0.2 + loan_int_rate * 0.3 + cb_person_cred_hist_length * 0.5)
    END AS credit_risk_score
FROM creditrisk;

-- Compute a rolling average of the loan amount for each person, based on employment length.
SELECT
    person_emp_length,
    loan_amnt,
    AVG(loan_amnt) OVER (PARTITION BY person_emp_length ORDER BY loan_amnt ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_avg_loan_amount
FROM creditrisk;

-- Additional analysis: 

-- Find the TOP 10 deafaulters of loan
SELECT
    id,  -- Assuming 'id' is your unique identifier
    person_age,
    person_income,
    loan_amnt,
    loan_int_rate,
    loan_status
FROM creditrisk
WHERE loan_status = 1  -- Filtering only the defaulters
ORDER BY loan_amnt DESC  -- Sorting by loan amount in descending order
LIMIT 100;

-- Window Segmentation (Rolling Average)
-- Compute a 3-month rolling average of loan amounts for each person’s credit history.

SELECT
    person_age,
    person_income,
    loan_amnt,
    cb_person_cred_hist_length,
    AVG(loan_amnt) OVER (PARTITION BY cb_person_cred_hist_length ORDER BY loan_amnt ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_avg_loan_amount
FROM creditrisk;

-- Segmenting Borrowers by Risk
-- Segment borrowers into risk categories based on loan grade, income, person's employment length and historical defaults.

SELECT
    person_income,
    loan_grade,
    person_emp_length,
    cb_person_default_on_file,
    CASE
        WHEN cb_person_default_on_file = 'Y' AND loan_grade IN ('D', 'E', 'F', 'G') THEN 'High Risk Borrower'
        WHEN cb_person_default_on_file = 'N' AND loan_grade IN ('A', 'B', 'C') THEN 'Low Risk Borrower'
        ELSE 'Moderate Risk Borrower'
    END AS risk_category
FROM creditrisk;

-- Calculate the Total Number of High Risk Borrower, Low Risk Borrower ad Moderate Risk Borrower.
SELECT 
    risk_category,
    COUNT(*) AS total_borrowers,
    ROUND((COUNT(*) * 100.0 / total_count.total_borrowers), 2) AS percentage
FROM (
    SELECT
        person_income,
        loan_grade,
        person_emp_length,
        cb_person_default_on_file,
        CASE
            WHEN cb_person_default_on_file = 'Y' AND loan_grade IN ('D', 'E', 'F', 'G') THEN 'High Risk Borrower'
            WHEN cb_person_default_on_file = 'N' AND loan_grade IN ('A', 'B', 'C') THEN 'Low Risk Borrower'
            ELSE 'Moderate Risk Borrower'
        END AS risk_category
    FROM creditrisk
) AS categorized_borrowers
CROSS JOIN (
    SELECT COUNT(*) AS total_borrowers
    FROM creditrisk
) AS total_count
GROUP BY risk_category, total_count.total_borrowers;

-- Find the age with the highest number of high and moderate risk borrowers, listed separately for each risk category.
SELECT
    risk_category,
    person_age,
    COUNT(*) AS total_borrowers
FROM (
    SELECT
        person_age,
        CASE
            WHEN cb_person_default_on_file = 'Y' AND loan_grade IN ('D', 'E', 'F', 'G') THEN 'High Risk Borrower'
            WHEN cb_person_default_on_file = 'N' AND loan_grade IN ('A', 'B', 'C') THEN 'Low Risk Borrower'
            ELSE 'Moderate Risk Borrower'
        END AS risk_category
    FROM creditrisk
) AS categorized_borrowers
WHERE risk_category IN ('High Risk Borrower', 'Moderate Risk Borrower')
GROUP BY risk_category, person_age
ORDER BY risk_category, total_borrowers DESC;

-- Loan Amount and Interest Rate Clustering: Cluster borrowers into segments based on the loan amount and interest rate.
SELECT
	    CASE
        WHEN loan_amnt <= 10000 AND loan_int_rate < 10 THEN 'Low Loan, Low Interest'
        WHEN loan_amnt <= 10000 AND loan_int_rate >= 10 THEN 'Low Loan, High Interest'
        WHEN loan_amnt > 10000 AND loan_int_rate < 10 THEN 'High Loan, Low Interest'
        ELSE 'High Loan, High Interest'
    END AS loan_segment,
    COUNT(*) AS num_borrowers
FROM creditrisk
GROUP BY loan_segment;

-- Default Prediction Based on Loan Percent of Income: Explore whether loan percent of income is a strong indicator of default.
SELECT
    loan_percent_income,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS defaults,
    COUNT(*) AS total_loans,
    ROUND(SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS default_rate
FROM creditrisk
GROUP BY loan_percent_income
ORDER BY loan_percent_income DESC;







