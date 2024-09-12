# Credit_Risk_Project_MySQL

## **Project Overview**

This project demonstrates the use of SQL skills and techniques typically employed by data analysts to explore and analyze credit risk data. The aim is to provide clear insights and actionable recommendations addressing key business problems related to loan borrowers and default rates.

## **Key Objectives:**

**Database Setup:** Creating a creditrisk database for efficient storage and retrieval of credit risk data.
**Exploratory Data Analysis (EDA):** Leveraging SQL to perform advanced data exploration, identifying patterns and trends among borrowers.
**Business Insights:** Answering specific business questions via SQL queries to provide the business owner with critical insights into borrower behaviors and default rates.

## **Dataset**

The dataset, sourced from Kaggle, focuses on loan borrowers, their characteristics, and their likelihood of defaulting. Missing values in the dataset were pre-processed using Microsoft Excel by imputing the mean for loan_int_rate column. The modified data was then imported into SQL for advanced analysis.

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

To interpret the loan status distribution briefly:

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

8. The rolling average of loan amounts, calculated over a 3-month period, shows how the average loan amount for each person changes over time. Here's a brief interpretation of the results:

- Consistent Average: Most entries show a rolling average of $1000, indicating that many people have consistent loan amounts.

- Variation in Average: Some individuals have varying rolling averages. For instance, entries like $1200, $1300, and up to $1966.67 reflect fluctuations in the loan amounts over the period.

- Higher Averages: People with higher loan amounts show higher rolling averages, such as $1500 or $1800, often associated with higher incomes and loan amounts.

- Extreme Values: Extreme rolling averages (e.g., $1800 or $1966.67) likely indicate high loan amounts or significant increases in the loan amount over the recent months.

In summary, the rolling average gives a smoothed view of loan amounts, highlighting trends and variations in borrowing behavior over the 3-month period.

9. Borrower segmentation by Risk Analysis Insight:
   
- Low Risk Borrowers:

Income: Generally higher, often above $50,000.
Loan Grade: Predominantly A to D.
Employment Length: Varies, but many have longer employment lengths.
Defaults: None or very few (not defaulted on file).
Examples: Income from $9,900 to $500,000; loan grades A to E; employment length from 0 to 10 years.

- Moderate Risk Borrowers:

Income: Varies, but often lower than low-risk borrowers, with several cases around $50,000 to $120,000.
Loan Grade: B to E.
Employment Length: Varies, but some with shorter lengths.
Defaults: Some historical defaults (indicated by 'Y' for default on file).
Examples: Income from $10,000 to $306,000; loan grades B to E; employment length from 0 to 10 years.

- High Risk Borrowers:

Income: Varied, often higher, but not necessarily as high as low-risk borrowers.
Loan Grade: Typically E to F.
Employment Length: Often shorter or variable.
Defaults: Generally have historical defaults (indicated by 'Y' for default on file).
Examples: Income from $11,000 to $300,000; loan grades E to F; employment length from 0 to 10 years.

Summary:

Low Risk Borrowers: Higher income, better loan grades, longer employment, no default history.
Moderate Risk Borrowers: Moderate income, mixed loan grades, varying employment length, occasional default history.
High Risk Borrowers: Variable income, lower loan grades, shorter employment, and more frequent default history.

- The majority of the borrower base is categorized as Low Risk, suggesting a relatively stable overall profile (74.79%)
- Moderate Risk borrowers represent a significant but smaller segment, indicating some level of concern.(17.47%)
- High Risk borrowers are the least common, but they still represent a crucial area for risk management and mitigation efforts.(7.73%)

Additional Insights:
    
11. The age groups distribution analysis with the highest number of High Risk and Moderate Risk borrowers are as follows: -

- High Risk Borrowers
Age 24: 275 borrowers
Age 22: 274 borrowers
Age 23: 267 borrowers
Interpretation: The ages 22, 23, and 24 have the highest number of High Risk borrowers. This suggests that individuals in their early to mid-20s are significantly overrepresented in the High Risk category. This could be due to factors like financial inexperience, higher debt-to-income ratios, or instability in early career stages.

- Moderate Risk Borrowers
Age 22: 621 borrowers
Age 23: 605 borrowers
Age 24: 602 borrowers
Interpretation: Similarly, the ages 22, 23, and 24 also have the highest number of Moderate Risk borrowers. This indicates that young adults are also prevalent in the Moderate Risk category. This trend supports the idea that this age group is a key demographic for risk management, reflecting potential issues such as job stability or financial management skills.

Summary -
High Risk Borrowers: Younger age groups, particularly around 22 to 24 years, show the highest concentration, highlighting a critical area for targeted risk assessment and intervention.
Moderate Risk Borrowers: The same age range also represents a large portion of Moderate Risk borrowers, suggesting that early adulthood is a period with considerable variability in financial risk.
The overlap in age groups between High and Moderate Risk categories underscores the importance of focusing on financial education and risk management strategies for younger individuals.

12.  Loan segments based on the loan amount and interest rate clustering analysis insight:

- High Loan, High Interest and Low Loan, High Interest segments together represent a significant portion of the borrower base, with potential for financial stress due to high interest rates.
- Low Loan, Low Interest segment represents borrowers in a more favorable financial position, with both manageable loan amounts and interest rates.
- High Loan, Low Interest segment, while smaller, suggests that high loan amounts are being mitigated somewhat by lower interest rates.

Overall, the clustering highlights how different combinations of loan amounts and interest rates impact borrower risk profiles and financial strain. Understanding these segments can help in tailoring risk management strategies and financial products.

13. To understand whether the percentage of income spent on a loan (loan_percent_income) is a strong indicator of default, let's analyze the default rate relative to the percentage of income used for the loan

Key Observations:

- High Loan Percent of Income and High Default Rate:

For high percentages of income allocated to the loan (e.g., 0.5 or above), the default rates are generally higher. For instance:
At 0.53 loan_percent_income, the default rate is 0.79.
At 0.42 loan_percent_income, the default rate is 0.77.
At 0.35 loan_percent_income, the default rate is 0.61.
This suggests a trend where higher loan payments relative to income are associated with higher default rates.

- Low Loan Percent of Income and Low Default Rate:

As the percentage of income used for the loan decreases, the default rates also tend to decrease. For example:
At 0.10 loan_percent_income, the default rate is 0.12.
At 0.01 loan_percent_income, the default rate is 0.05.
This trend indicates that borrowers who spend a smaller percentage of their income on loan repayments are less likely to default.

- Strong Correlation:

The result shows a clear inverse relationship between loan_percent_income and default rate: as the percentage of income used for the loan decreases, the default rate also tends to decrease.

High percentages (e.g., 0.30 and above) correlate with high default rates, while lower percentages (e.g., 0.10 and below) correlate with lower default rates.

Summary -

Loan percent of income is a strong indicator of default. Borrowers who allocate a larger portion of their income to loan repayments are more likely to default, while those who allocate a smaller portion tend to have lower default rates. This suggests that managing loan payments to be a smaller fraction of income can reduce default risk, supporting the use of loan percent of income as a key factor in default prediction.

## **Recommendations**

Based on the detailed analysis and findings from this SQL credit risk project, here are several vital recommendations for the business or bank we can suggest:

1. Refine Risk-Based Pricing
Adjust Interest Rates Based on Loan Grade: Given the correlation between loan grade and default rates, consider implementing more nuanced interest rate adjustments. Higher-grade loans (e.g., Grade A) should continue to receive lower interest rates, while lower-grade loans (e.g., Grade G) could be priced higher to reflect their risk.
Incorporate Loan Percent of Income: Use the percentage of income spent on loan repayments as a factor in setting interest rates and determining loan eligibility. Higher percentages should trigger higher interest rates or stricter lending criteria.

2. Enhance Credit Risk Scoring Models
Incorporate Home Ownership: Since home ownership correlates with lower default rates, include home ownership status in your credit risk scoring models. Fully owning a home could be an indicator of financial stability.
Factor in Age and Employment Length: Adjust credit scoring to consider age and employment length more heavily. Younger borrowers and those with shorter employment histories show higher default risks.

3. Segmented Risk Management Strategies
Target High Risk Age Groups: Focus on improving financial education and support for younger borrowers, particularly those aged 22 to 24. Consider offering financial counseling or tailored loan products to this demographic.
Develop Targeted Interventions for High-Risk Borrowers: Implement additional risk management strategies for borrowers with high loan percentages relative to income and those with lower-grade loans.

4. Optimize Loan Product Offerings
Balance Loan Amounts and Interest Rates: Create loan products with competitive interest rates for borrowers with lower loan amounts while offering flexible repayment terms to mitigate financial strain.
Expand Low Loan, Low Interest Products: Given the favorable position of borrowers in this segment, increase the availability of products that fit this profile, promoting financial stability.

5. Improve Default Prediction Models
Use Loan Percent of Income as a Key Predictor: Strengthen default prediction models by incorporating the percentage of income spent on loans as a primary predictor of default risk. Regularly update the model with new data to refine accuracy.

6. Enhance Borrower Segmentation
Detailed Segmentation Analysis: Use detailed borrower segments (e.g., low, moderate, high risk) to tailor marketing, loan offerings, and risk management strategies. Ensure that segmentation considers income, loan grade, and other risk factors.

7. Monitor and Adjust Based on Trends
Track Rolling Averages: Regularly monitor rolling averages of loan amounts to identify trends and potential issues. Use this information to adjust lending practices and identify borrowers who may be at risk of financial stress.

8. Strengthen Financial Education and Support
Financial Literacy Programs: Develop and promote financial literacy programs, particularly for younger and high-risk borrowers, to improve financial management skills and reduce default rates.

9. Regularly Review and Update Policies
Dynamic Policy Adjustments: Continuously review and update loan policies and risk management practices based on ongoing analysis and emerging trends. Ensure policies remain relevant and effective in mitigating default risk.

By implementing these recommendations, the bank or business can better manage risk, improve financial stability, and enhance borrower satisfaction.

## **Conclusion**

This credit risk analysis project has provided valuable insights into borrower behavior, loan performance, and default risk, which are crucial for enhancing the risk management strategies of the bank. By meticulously analyzing the dataset, several key findings and recommendations have emerged that can drive informed business decisions and improve overall financial stability.

Key Insights:

- Loan Grade and Default Rates: A clear relationship exists between loan grade and default rates, with lower-grade loans exhibiting significantly higher default rates. This insight underscores the importance of adjusting interest rates and lending criteria based on loan grades.

- Impact of Loan Percent of Income: The percentage of income allocated to loan repayments is a strong indicator of default risk. Higher percentages correlate with higher default rates, suggesting that managing loan payments relative to income is crucial for reducing default risk.

- Home Ownership Correlation: Borrowers who own their homes or have mortgages show lower default rates compared to renters. This correlation indicates that homeownership is associated with greater financial stability.

- Age and Employment Length Insights: Younger borrowers and those with shorter employment histories are more likely to default. Tailoring risk management strategies for these demographics can help mitigate potential losses.

- Segmentation and Purchasing Behavior: Clustering borrowers based on loan amounts and interest rates reveals varying risk profiles, helping to identify segments that may require targeted interventions or product adjustments.

- Credit Risk Scoring: The credit risk score effectively summarizes a borrower’s creditworthiness, influenced by factors such as income, loan amount, and interest rates. Utilizing this score in risk assessment and decision-making can enhance predictive accuracy.

By leveraging these key insights and above mentioned recommendations, the bank can enhance its risk management strategies, improve financial performance, and better serve its customers. The findings from this project offer a solid foundation for making data-driven decisions that can lead to more effective risk mitigation and optimized loan offerings.


## Author - Debolina Dutta

This project is part of my portfolio, showcasing the SQL skills essential for data analytics roles. 

*LinkedIn**: (https://www.linkedin.com/in/duttadebolina/)















   

   







