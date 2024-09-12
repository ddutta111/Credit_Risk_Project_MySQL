# Credit_Risk_Project_MySQL

## **Project Overview**

This project demonstrates the use of SQL skills and techniques typically employed by data analysts to explore and analyze credit risk data. The aim is to provide clear insights and actionable recommendations addressing key business problems related to loan borrowers and default rates.

## **Key Objectives:**

**Database Setup:** Creating a creditrisk database for efficient storage and retrieval of credit risk data.
**Exploratory Data Analysis (EDA):** Leveraging SQL to perform advanced data exploration, identifying patterns and trends among borrowers.
**Business Insights:** Answering specific business questions via SQL queries to provide the business owner with critical insights into borrower behaviors and default rates.

## **Dataset**

The dataset, sourced from Kaggle, focuses on loan borrowers, their characteristics, and their likelihood of defaulting. Missing values in the dataset were pre-processed using Microsoft Excel by imputing the mean for loan_amount and interest_rate columns. The modified data was then imported into SQL for advanced analysis.

## **Data Description:**

Id - Borrower's Id (Added this column in the beginningg of teh dataset by using ato-increment function in excel and used it as Primary Key in MySql creditrisk table)
person_age	- Age of the borrower
person_income	- Annual income of the borrower
person_home_ownership	- Home ownership status
person_emp_length	- Length of employment (in years)
loan_intent	- Purpose of the loan
loan_grade	- Loan grade assigned to the borrower
loan_amnt	- Loan amount
loan_int_rate	- Interest rate applied to the loan
loan_status	- Loan status (0 = non-default, 1 = default)
loan_percent_income	- Percentage of income allocated to the loan
cb_person_default_on_file	- Historical record of default
cb_person_cred_hist_length - Length of the borrower's credit history

## **Database setup, Table creation and Business Analysis:**

**1. Database and Table Setup**
```sql
-- Use the database
USE credit_risk_sql;

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
    loan_status INT,
    loan_percent_income DOUBLE,
    cb_person_default_on_file VARCHAR(10),
    cb_person_cred_hist_length INT
);'
```
2. **Basic Data Exploration**
```sql
-- View all data

SELECT * FROM creditrisk;

-- Count total rows

SELECT COUNT(*) AS total_rows FROM creditrisk;

-- Count distinct Borrowers

SELECT COUNT(DISTINCT Id) AS total_distinct_customers FROM creditrisk;
```
3. **Summary Statistics**
```sql
-- Quick summary of age, income, loan amount, and interest rate

SELECT
    AVG(person_age) AS avg_age,
    AVG(person_income) AS avg_income,
    AVG(loan_amnt) AS avg_loan_amount,
    AVG(loan_int_rate) AS avg_interest_rate,
    AVG(person_emp_length) AS avg_emplnt_len
FROM creditrisk;
```
4. **Loan Defaulter Analysis**
```sql
-- Highest age of loan defaulters and default rate by loan grade

SELECT 
    loan_grade,
    MAX(CASE WHEN loan_status = 1 THEN person_age ELSE NULL END) AS highest_age_of_defaulters,
    COUNT(CASE WHEN loan_status = 1 THEN 1 ELSE NULL END) / COUNT(*) AS default_rate,
    AVG(person_income) AS avg_income
FROM creditrisk
GROUP BY loan_grade 
ORDER BY default_rate DESC;

-- Distribution of loan status by loan grade: Check the distribution of loans and loan_type that have defaulted versus non-defaulted loans.

SELECT loan_status, COUNT(*) AS total_loans, loan_grade
FROM creditrisk
GROUP BY loan_status, loan_grade;
```
## **5. Home Ownership and Loan Relationships**
```sql
-- Count of home ownership types: How many people own, rent, or have a mortgage?

SELECT person_home_ownership, COUNT(*) AS count
FROM creditrisk
GROUP BY person_home_ownership
ORDER BY count DESC;

-- Analyze relationship between income and loan amount
SELECT
    person_income,
    AVG(loan_amnt) AS avg_loan_amount,
    COUNT(*) AS num_loans
FROM creditrisk
GROUP BY person_income
ORDER BY person_income DESC;
```
## 6. Default Rates by Loan Grade, Credit History, and Employment Length
```sql
-- Default rate by loan grade: Check which loan grades have the highest default rate.

SELECT
    loan_grade,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS defaults,
    COUNT(*) AS total_loans,
    ROUND(SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS default_rate
FROM creditrisk
GROUP BY loan_grade
ORDER BY default_rate DESC;

-- Credit history length and default rates: Find if people with shorter credit histories tend to default more.

SELECT
    cb_person_cred_hist_length AS credit_history_length,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS defaults,
    COUNT(*) AS total_loans
    ROUND(SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS default_rate
FROM creditrisk
GROUP BY cb_person_cred_hist_length
ORDER BY credit_history_length DESC;

-- Average loan amount by employment length: to understand how the loan amounts vary by the number of years a person has been employed.

SELECT
    person_emp_length,
    AVG(loan_amnt) AS avg_loan_amount
FROM creditrisk
GROUP BY person_emp_length
ORDER BY person_emp_length;
```
## **7. Loan Intent and Default Rates**
```sql
-- Default rate by loan intent: which loan intents (e.g., personal, medical) have the highest default rate?

SELECT
    loan_intent,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS num_defaults,
    COUNT(*) AS total_loans,
    ROUND(SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS default_rate
FROM creditrisk
GROUP BY loan_intent
ORDER BY default_rate DESC;

-- Loan grade vs interest rate

SELECT
    loan_grade,
    AVG(loan_int_rate) AS avg_interest_rate
FROM creditrisk
GROUP BY loan_grade
ORDER BY avg_interest_rate DESC;
```
## **8. Home Ownership and Default Rates**
```sql
-- Default rate by home ownership: To analyze default rates based on home ownership (e.g., rent, own, mortgage)

SELECT
    person_home_ownership,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS num_defaults,
    COUNT(*) AS total_loans,
    ROUND(SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS default_rate
FROM creditrisk
GROUP BY person_home_ownership
ORDER BY default_rate DESC;
```
## **9. Credit Risk Score Calculation**
```sql
-- Calculate a credit risk score
SELECT
    person_age,
    person_income,
    loan_amnt,
    loan_int_rate,
    cb_person_cred_hist_length,
    loan_status,
    CASE
        WHEN loan_status = 1 THEN (loan_amnt * 0.3 + loan_int_rate * 0.4 + cb_person_cred_hist_length * 0.3)
        ELSE (loan_amnt * 0.2 + loan_int_rate * 0.3 + cb_person_cred_hist_length * 0.5)
    END AS credit_risk_score
FROM creditrisk;
```
## **10. Rolling Average and Window Segmentation**
```sql
-- Rolling average of loan amounts for each person, based on employment length

SELECT
    person_emp_length,
    loan_amnt,
    AVG(loan_amnt) OVER (PARTITION BY person_emp_length ORDER BY loan_amnt ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_avg_loan_amount
FROM creditrisk;

-- 3-month rolling average of loan amounts by credit history

SELECT
    person_age,
    person_income,
    loan_amnt,
    cb_person_cred_hist_length,
    AVG(loan_amnt) OVER (PARTITION BY cb_person_cred_hist_length ORDER BY loan_amnt ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS rolling_avg_loan_amount
FROM creditrisk;
```
## **11. Borrower Segmentation by Risk**
```sql
-- Segment borrowers by three risk categories

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

-- Total number of borrowers of each risk categories

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
```
## **12. Additional Analyses: To have better insight on default rate, loan as percent of income, top borrowers and their age distribution**
```sql
-- Find the age with the highest number of high and moderate risk borrowers, listed separately for each risk category

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

-- Loan amount and interest rate clustering: Cluster borrowers into segments based on the loan amount and interest rate.

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

-- Default prediction based on loan percent of income: Explore whether loan percent of income is a strong indicator of default.

SELECT
    loan_percent_income,
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS defaults,
    COUNT(*) AS total_loans,
    ROUND(SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS default_rate
FROM creditrisk
GROUP BY loan_percent_income
ORDER BY loan_percent_income DESC;

-- Find the TOP 10 defaulters of loans

SELECT
    Id,  -- Assuming 'Id' is your unique identifier
    person_age,
    person_income,
    loan_amnt,
    loan_int_rate,
    loan_status
FROM creditrisk
WHERE loan_status = 1  -- Filtering only the defaulters
ORDER BY loan_amnt DESC  -- Sorting by loan amount in descending order
LIMIT 10;
```
## **Reorts & Findings**

1. Summary of statistics shows that the dataset has 31686 distinct customers or borrowers. The average borrower age is between 27 and 28, and their average income is $66691 along with average employment length is 4.8 years and average loan amunt by borrowers taken in $9661.31 with average interest rate 11.04%.

2. Loan Defaulter analysis

- The highest age of borrowers are 70 and default rate is 0.5877 with loan grade D and 0.0956 with loan grade A.

**Loan Status Default Distribution:** 

To interpret the loan status distribution data briefly:

Loan Status (1 = Defaulted, 0 = Not Defaulted)
Total_loans: Number of loans in that category.
Loan_grade: The credit grade of the loan.
Here’s a summary of the distribution:

Grade A:

Defaulted: 991 loans
Not Defaulted: 9380 loans
Interpretation: Grade A loans have a higher count of non-defaulted loans compared to defaulted ones.

Grade B:

Defaulted: 1622 loans
Not Defaulted: 8564 loans
Interpretation: Grade B loans also have more non-defaulted loans compared to defaulted ones, but the ratio is closer than in Grade A.

Grade C:

Defaulted: 1283 loans
Not Defaulted: 5038 loans
Interpretation: Grade C has fewer non-defaulted loans relative to defaulted loans compared to Grades A and B.

Grade D:

Defaulted: 2090 loans
Not Defaulted: 1466 loans
Interpretation: Grade D has a higher number of defaulted loans compared to non-defaulted loans.

Grade E:

Defaulted: 611 loans
Not Defaulted: 341 loans
Interpretation: Grade E has more defaulted loans than non-defaulted ones.

Grade F:

Defaulted: 166 loans
Not Defaulted: 70 loans
Interpretation: Grade F has a higher proportion of defaulted loans compared to non-defaulted loans.

Grade G:

Defaulted: 63 loans
Not Defaulted: 1 loan
Interpretation: Grade G has a significant imbalance with a majority of defaulted loans.

**Summary: As the loan grade deteriorates from A to G, the proportion of defaulted loans generally increases. Grade A loans are the least likely to default, while Grade G loans are predominantly defaulted.**

3. Home Ownership and Loan Relationships analysis shows that Renters (RENT) make up the largest group of borrowers, with 16,076 individuals. This could suggest that a significant proportion of loan borrowers do not own their homes, potentially indicating they might have less financial stability compared to homeowners or those with mortgages.

Borrowers with a Mortgage (MORTGAGE) are the second-largest group at 13,093. These individuals are likely paying off a home loan, indicating they own property but are still carrying debt related to it.

Homeowners (OWN) who fully own their homes (2,410 borrowers) form a much smaller group, implying that fewer borrowers come from fully paid-off homes, possibly because they have more financial stability and less need for loans.

Other: This small category of 107 borrowers likely includes less common forms of homeownership, such as living with family, in shared accommodations, or in unique housing arrangements.

Business Insight: The majority of loan borrowers are either renting or still paying a mortgage, which may indicate higher financial obligations, potentially increasing the risk of default. Fully owning a home appears to correlate with fewer loans taken out.

Again, From the relationship analysis between avg number of loans and income level we see that:

- Higher incomes generally correlate with lower average loan amounts (e.g., £6,000,000 income with a £5,000 loan).
- Multiple loans are more common among individuals with moderate to lower incomes (e.g., £1,200,000 income with 3 loans).
- Larger loans are often taken by those with lower incomes (e.g., £180,000 income with a £30,000 loan).
The result hints at diverse financial behavior, where high-income individuals tend to borrow less on average, while those with lower incomes might take on higher loans or more frequent loans.

4. Default Rates by Loan Grade, Credit History, and Employment Length result insights:

- Loan grade G has the highest default rate at 0.98, meaning 98% of loans in this grade default. This indicates that loans in grade G are extremely risky, with almost all borrowers failing to repay their loans.
- People with shorter credit histories (closer to 2–5 years) generally have slightly higher default rates, around 0.22–0.23. However, this trend isn't drastically different from those with longer histories (closer to 10–30 years), where default rates mostly range from 0.20–0.30. There is no clear, sharp increase in defaults for shorter credit histories.
- Loan amounts generally increase with longer employment lengths. People employed for around 0–10 years typically have loan amounts in the range of $8,500–$10,900. As employment length increases beyond 10 years, loan amounts fluctuate, peaking notably at 19–31 years (reaching up to $25,000), though there are some lower outliers. The highest average loan amounts are observed for very long employment lengths like 123 years, but this seems anomalous.

5. Loan Intent and Default Rates Insights:

- The loan intent with the highest default rate is DEBTCONSOLIDATION (28%), followed by MEDICAL (27%) and HOMEIMPROVEMENT (26%). VENTURE loans have the lowest default rate at 15%.
- The data shows that as loan grade improves from G to A, the average interest rate decreases. Lower-grade loans (like G) have a higher average interest rate (19.53%), while higher-grade loans (like A) have a much lower rate (7.69%), indicating that higher-risk loans tend to have higher interest rates.

6. Home Ownership and Default Rates analysis insight:

- The analysis shows that borrowers who rent or fall under the "other" category have the highest default rate (0.31), while those who own homes or have mortgages have significantly lower default rates, with homeowners having the lowest (0.07). This suggests that homeownership is associated with lower default risk.

7. Credit Risk Score Calculation interpretation:

The credit risk score is a numerical representation that assesses the likelihood of a borrower defaulting on a loan: -
  
- Higher Scores Indicate Lower Risk: Generally, higher credit risk scores suggest a lower probability of default. For instance, values such as 10509.30 and 10508.56 are associated with lower default risks, while values like 204.34 and 303.69 indicate higher risks.

- Income and Loan Amount Influence: Higher incomes and larger loan amounts do not necessarily correlate with higher credit risk scores. For example, individuals with high incomes and large loans can still have high credit risk scores, depending on other factors like loan interest rates and credit history.

- Age and Credit History: Younger individuals and those with shorter credit histories can sometimes have lower credit risk scores. For example, a 21-year-old with a credit risk score of 753.46 might face higher risk compared to a 26-year-old with a score of 10505.87.

- Loan Interest Rates: Higher interest rates might be associated with higher credit risk scores, reflecting the increased financial burden and potential for default.

In summary, the credit risk score provides a summary measure of the borrower’s creditworthiness, with higher scores generally indicating a lower risk of default. The score is influenced by a combination of factors including income, loan amount, interest rate, age, and credit history.

8. Rolling Average Calculation Insight:









   

   







