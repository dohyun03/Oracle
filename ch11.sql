SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE my_dep_hier_proc (
               p_parent_id  departments.department_id%TYPE DEFAULT NULL,
               p_level      NUMBER DEFAULT 1 )
IS
  CURSOR c1 IS
    SELECT department_id, department_name
      FROM departments
     WHERE ( p_parent_id IS NULL AND parent_id IS NULL )
        OR parent_id = p_parent_id
     ORDER BY department_id;
BEGIN
  FOR rec IN c1
  LOOP
     DBMS_OUTPUT.PUT_LINE( rec.department_id || ' ' ||
                           LPAD(' ', 3 * (p_level - 1)) || rec.department_name || ' ' ||
                           p_level );
     my_dep_hier_proc ( rec.department_id, p_level + 1 );
  END LOOP;
END;
/

EXEC my_dep_hier_proc;






SET SERVEROUTPUT ON

DECLARE
   TYPE av_type IS TABLE OF employees.email%TYPE INDEX BY employees.emp_name%TYPE;

   vav_test  av_type;
BEGIN
  FOR rec IN ( SELECT emp_name, email
                 FROM employees )
  LOOP
     vav_test(rec.emp_name) := rec.email;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE( 'Elizabeth Bates 의 이메일 주소는 ' || vav_test('Elizabeth Bates'));
  DBMS_OUTPUT.PUT_LINE( 'Kimberely Grant 의 이메일 주소는 ' || vav_test('Kimberely Grant'));
END;
/



CREATE OR REPLACE TYPE nt_ch11_emp IS TABLE OF VARCHAR2(80);
/






SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE ch11_emp_proc ( p_dep_id departments.department_id%TYPE )
IS
  CURSOR c1 IS
    SELECT a.employee_id, a.emp_name, b.department_name
      FROM employees a,
           departments b
     WHERE a.department_id = b.department_id;

  TYPE nt_emp_type IS TABLE OF c1%ROWTYPE;

  vnt_test nt_emp_type;
BEGIN
    SELECT a.employee_id, a.emp_name, b.department_name
    BULK COLLECT INTO vnt_test
      FROM employees a,
           departments b
     WHERE a.department_id = b.department_id
       AND a.department_id = p_dep_id;

  FOR i IN vnt_test.FIRST .. vnt_test.LAST
  LOOP
      DBMS_OUTPUT.PUT_LINE (
           vnt_test(i).employee_id || ' ' ||
           vnt_test(i).emp_name || ', ' ||
           vnt_test(i).department_name
      );
  END LOOP;
END;
/

EXEC ch11_emp_proc(30);