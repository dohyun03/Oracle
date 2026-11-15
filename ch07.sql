SELECT department_id,
       SUBSTR(SYS_CONNECT_BY_PATH(emp_name, ','), 2) empnames
  FROM ( SELECT emp_name,
                department_id,
                COUNT(*) OVER ( PARTITION BY department_id ) cnt,
                ROW_NUMBER() OVER ( PARTITION BY department_id ORDER BY emp_name ) rowseq
           FROM employees
          WHERE department_id IS NOT NULL )
 WHERE rowseq = cnt
 START WITH rowseq = 1
CONNECT BY PRIOR rowseq + 1 = rowseq
       AND PRIOR department_id = department_id;
       
SELECT employee_id, emp_name, hire_date,
       LEAD(hire_date) OVER ( PARTITION BY job_id ORDER BY hire_date ) AS retire_date
  FROM employees
 WHERE job_id = 'SH_CLERK'
 ORDER BY hire_date;
 
 
WITH basis AS ( SELECT WIDTH_BUCKET(TO_CHAR(SYSDATE, 'YYYY') - b.cust_year_of_birth, 10, 90, 8) AS old_seg,
                       s.amount_sold
                  FROM sales s,
                       customers b
                 WHERE s.sales_month = '200112'
                   AND s.cust_id = b.cust_id
              ),
     real_data AS ( SELECT old_seg * 10 || '대' AS 연령대,
                           SUM(amount_sold) AS 매출금액
                      FROM basis
                     GROUP BY old_seg
              )
SELECT *
  FROM real_data
 ORDER BY 연령대;
 
 
 
WITH basis AS ( SELECT c.country_region, s.sales_month, SUM(s.amount_sold) AS amt
                  FROM sales s,
                       customers b,
                       countries c
                 WHERE s.cust_id = b.cust_id
                   AND b.country_id = c.country_id
                 GROUP BY c.country_region, s.sales_month
              ),
     real_data AS ( SELECT sales_month,
                           country_region,
                           amt,
                           RANK() OVER ( PARTITION BY sales_month ORDER BY amt ) ranks
                      FROM basis
              )
SELECT sales_month 매출월, country_region 지역, amt 매출금액
  FROM real_data
 WHERE ranks = 1
 ORDER BY sales_month;
 
 
WITH basis AS (
SELECT region, gubun,
       SUM(amt1) AS amt1,
       SUM(amt2) AS amt2,
       SUM(amt3) AS amt3,
       SUM(amt4) AS amt4,
       SUM(amt5) AS amt5,
       SUM(amt6) AS amt6,
       SUM(amt7) AS amt7
  FROM (
         SELECT region,
                gubun,
                CASE WHEN period = '201111' THEN loan_jan_amt ELSE 0 END amt1,
                CASE WHEN period = '201112' THEN loan_jan_amt ELSE 0 END amt2,
                CASE WHEN period = '201210' THEN loan_jan_amt ELSE 0 END amt3,
                CASE WHEN period = '201211' THEN loan_jan_amt ELSE 0 END amt4,
                CASE WHEN period = '201212' THEN loan_jan_amt ELSE 0 END amt5,
                CASE WHEN period = '201310' THEN loan_jan_amt ELSE 0 END amt6,
                CASE WHEN period = '201311' THEN loan_jan_amt ELSE 0 END amt7
           FROM kor_loan_status
       )
 GROUP BY region, gubun
)
SELECT region 지역,
       gubun 대출종류,
       amt1 || '( ' || ROUND(RATIO_TO_REPORT(amt1) OVER ( PARTITION BY region ), 2) * 100 || '% )' AS "201111",
       amt2 || '( ' || ROUND(RATIO_TO_REPORT(amt2) OVER ( PARTITION BY region ), 2) * 100 || '% )' AS "201112",
       amt3 || '( ' || ROUND(RATIO_TO_REPORT(amt3) OVER ( PARTITION BY region ), 2) * 100 || '% )' AS "201210",
       amt4 || '( ' || ROUND(RATIO_TO_REPORT(amt4) OVER ( PARTITION BY region ), 2) * 100 || '% )' AS "201211",
       amt5 || '( ' || ROUND(RATIO_TO_REPORT(amt5) OVER ( PARTITION BY region ), 2) * 100 || '% )' AS "201212",
       amt6 || '( ' || ROUND(RATIO_TO_REPORT(amt6) OVER ( PARTITION BY region ), 2) * 100 || '% )' AS "201310",
       amt7 || '( ' || ROUND(RATIO_TO_REPORT(amt7) OVER ( PARTITION BY region ), 2) * 100 || '% )' AS "201311"
  FROM basis
 ORDER BY region;