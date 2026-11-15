SELECT TO_CHAR(hire_date, 'YYYY') AS hire_year,
       COUNT(*)
  FROM employees
 GROUP BY TO_CHAR(hire_date, 'YYYY')
 ORDER BY TO_CHAR(hire_date, 'YYYY');
 
 
SELECT period, region, SUM(loan_jan_amt)
  FROM kor_loan_status
 WHERE period LIKE '2012%'
 GROUP BY period, region
 ORDER BY period, region;
 
SELECT period, gubun, SUM(loan_jan_amt) totl_jan
  FROM kor_loan_status
 WHERE period LIKE '2013%'
 GROUP BY period, gubun
UNION
SELECT period, '', SUM(loan_jan_amt) totl_jan
  FROM kor_loan_status
 WHERE period LIKE '2013%'
 GROUP BY period;
 
 
 
 
SELECT period, SUM(loan_jan_amt) 주택담보대출액, 0 기타대출액
  FROM kor_loan_status
 WHERE period = '201311'
   AND gubun = '주택담보대출'
 GROUP BY period, gubun
UNION ALL
SELECT period, 0 주택담보대출액, SUM(loan_jan_amt) 기타대출액
  FROM kor_loan_status
 WHERE period = '201311'
   AND gubun = '기타대출'
 GROUP BY period, gubun;
 
 
SELECT region 지역,
       SUM(amt1) AS "201111",
       SUM(amt2) AS "201112",
       SUM(amt3) AS "201210",
       SUM(amt4) AS "201211",
       SUM(amt5) AS "201212",
       SUM(amt6) AS "201310",
       SUM(amt7) AS "201311"
  FROM (
         SELECT region,
                CASE WHEN period = '201111' THEN loan_jan_amt ELSE 0 END amt1,
                CASE WHEN period = '201112' THEN loan_jan_amt ELSE 0 END amt2,
                CASE WHEN period = '201210' THEN loan_jan_amt ELSE 0 END amt3,
                CASE WHEN period = '201211' THEN loan_jan_amt ELSE 0 END amt4,
                CASE WHEN period = '201212' THEN loan_jan_amt ELSE 0 END amt5,
                CASE WHEN period = '201310' THEN loan_jan_amt ELSE 0 END amt6,
                CASE WHEN period = '201311' THEN loan_jan_amt ELSE 0 END amt7
           FROM kor_loan_status
       )
 GROUP BY region
 ORDER BY region;