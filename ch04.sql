SELECT employee_id,
       LPAD(SUBSTR(phone_number, 5), 12, '(02)') phone_number
  FROM employees;
  

SELECT employee_id 사원번호, emp_name 사원명, hire_date 입사일자,
       ROUND((SYSDATE - hire_date) / 365) 근속년수
  FROM employees
 WHERE ROUND((SYSDATE - hire_date) / 365) >= 10
 ORDER BY 근속년수 DESC;
 
SELECT cust_name, cust_main_phone_number,
       REPLACE(cust_main_phone_number, '-', '/') new_phone_number
  FROM customers;
  
  
SELECT cust_name, cust_main_phone_number,
       TRANSLATE(cust_main_phone_number, '0123456789', 'acielsifke') new_phone_number
  FROM customers;
  
  
SELECT cust_name,
       cust_year_of_birth,
       DECODE( TRUNC((TO_CHAR(SYSDATE, 'YYYY') - cust_year_of_birth) / 10), 3, '30대',
                                                                          4, '40대',
                                                                          5, '50대',
                                                                          '기타') generation
  FROM customers;
  
  
SELECT cust_name,
       cust_year_of_birth,
       CASE WHEN TRUNC((TO_CHAR(SYSDATE, 'YYYY') - cust_year_of_birth) / 10) = 1 THEN '10대'
            WHEN TRUNC((TO_CHAR(SYSDATE, 'YYYY') - cust_year_of_birth) / 10) = 2 THEN '20대'
            WHEN TRUNC((TO_CHAR(SYSDATE, 'YYYY') - cust_year_of_birth) / 10) = 3 THEN '30대'
            WHEN TRUNC((TO_CHAR(SYSDATE, 'YYYY') - cust_year_of_birth) / 10) = 4 THEN '40대'
            WHEN TRUNC((TO_CHAR(SYSDATE, 'YYYY') - cust_year_of_birth) / 10) = 5 THEN '50대'
            WHEN TRUNC((TO_CHAR(SYSDATE, 'YYYY') - cust_year_of_birth) / 10) = 6 THEN '60대'
            WHEN TRUNC((TO_CHAR(SYSDATE, 'YYYY') - cust_year_of_birth) / 10) = 7 THEN '70대'
            WHEN TRUNC((TO_CHAR(SYSDATE, 'YYYY') - cust_year_of_birth) / 10) = 8 THEN '80대'
            WHEN TRUNC((TO_CHAR(SYSDATE, 'YYYY') - cust_year_of_birth) / 10) = 9 THEN '90대'
            ELSE '기타' END AS new_generation
  FROM customers;