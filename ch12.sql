SET SERVEROUTPUT ON

CREATE OR REPLACE PACKAGE hr_pkg2 IS

  FUNCTION fn_get_dep_name ( pn_department_id IN NUMBER )
     RETURN VARCHAR2;

  PROCEDURE new_dep_proc ( ps_dep_name   IN VARCHAR2,
                           pn_parent_id  IN NUMBER,
                           pn_manager_id IN NUMBER );

  PROCEDURE del_dep_proc ( pn_department_id IN NUMBER );

END hr_pkg2;
/

CREATE OR REPLACE PACKAGE BODY hr_pkg2 IS

  FUNCTION fn_get_dep_name ( pn_department_id IN NUMBER )
     RETURN VARCHAR2
  IS
    vs_dep_name departments.department_name%TYPE;
  BEGIN
    SELECT department_name
      INTO vs_dep_name
      FROM departments
     WHERE department_id = pn_department_id;

    RETURN vs_dep_name;

  EXCEPTION WHEN OTHERS THEN
    RETURN '해당 부서 없음';
  END fn_get_dep_name;

  PROCEDURE new_dep_proc ( ps_dep_name   IN VARCHAR2,
                           pn_parent_id  IN NUMBER,
                           pn_manager_id IN NUMBER )
  IS
    vn_max_dep_id departments.department_id%TYPE;
    vn_cnt        NUMBER := 0;
  BEGIN
    SELECT COUNT(*)
      INTO vn_cnt
      FROM departments
     WHERE department_name = ps_dep_name;

    IF vn_cnt > 0 THEN
       DBMS_OUTPUT.PUT_LINE(ps_dep_name || ' 라는 부서가 이미 존재합니다!');
       RETURN;
    END IF;

    SELECT NVL(MAX(department_id), 0) + 1
      INTO vn_max_dep_id
      FROM departments;

    INSERT INTO departments (department_id, department_name, parent_id, manager_id, create_date, update_date)
    VALUES (vn_max_dep_id, ps_dep_name, pn_parent_id, pn_manager_id, SYSDATE, SYSDATE);

    COMMIT;

  EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
    ROLLBACK;
  END new_dep_proc;

  PROCEDURE del_dep_proc ( pn_department_id IN NUMBER )
  IS
    vn_cnt1 NUMBER := 0;
    vn_cnt2 NUMBER := 0;
  BEGIN
    SELECT COUNT(*)
      INTO vn_cnt1
      FROM departments
     WHERE department_id = pn_department_id;

    IF vn_cnt1 = 0 THEN
       DBMS_OUTPUT.PUT_LINE(pn_department_id || ' 부서가 존재하지 않습니다!');
       RETURN;
    END IF;

    SELECT COUNT(*)
      INTO vn_cnt2
      FROM employees
     WHERE department_id = pn_department_id
       AND retire_date IS NULL;

    IF vn_cnt2 > 0 THEN
       DBMS_OUTPUT.PUT_LINE(pn_department_id || ' 부서에 속한 사원이 존재하므로 삭제할 수 없습니다');
       RETURN;
    END IF;

    DELETE departments
     WHERE department_id = pn_department_id;

    COMMIT;

  EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
    ROLLBACK;
  END del_dep_proc;

END hr_pkg2;
/

SELECT hr_pkg2.fn_get_dep_name(10) FROM DUAL;

EXEC hr_pkg2.del_dep_proc(10);




CREATE OR REPLACE PACKAGE ch12_seq_pkg IS
    FUNCTION get_nextval RETURN NUMBER;
END ch12_seq_pkg;
/

CREATE OR REPLACE PACKAGE BODY ch12_seq_pkg IS
    cv_seq NUMBER := 0;

    FUNCTION get_nextval RETURN NUMBER
    IS
    BEGIN
       cv_seq := cv_seq + 1;
       RETURN cv_seq;
    END get_nextval;
END ch12_seq_pkg;
/

SELECT ch12_seq_pkg.get_nextval FROM DUAL;
SELECT ch12_seq_pkg.get_nextval FROM DUAL;
SELECT ch12_seq_pkg.get_nextval FROM DUAL;




SET SERVEROUTPUT ON

CREATE OR REPLACE PACKAGE ch12_exacur_pkg IS

  -- ROWTYPE형 커서 헤더선언
  CURSOR pc_depname_cur ( dep_id IN departments.department_id%TYPE )
      RETURN departments%ROWTYPE;

  PROCEDURE cur_example_proc ( p_parent_id IN NUMBER );

END ch12_exacur_pkg;
/

CREATE OR REPLACE PACKAGE BODY ch12_exacur_pkg IS

  CURSOR pc_depname_cur ( dep_id IN departments.department_id%TYPE )
      RETURN departments%ROWTYPE
  IS
     SELECT *
       FROM departments
      WHERE parent_id = dep_id;

  PROCEDURE cur_example_proc ( p_parent_id IN NUMBER )
  IS
    dep_cur  ch12_exacur_pkg.pc_depname_cur%ROWTYPE;
  BEGIN
    IF ch12_exacur_pkg.pc_depname_cur%ISOPEN THEN
       CLOSE ch12_exacur_pkg.pc_depname_cur;
    END IF;

    OPEN ch12_exacur_pkg.pc_depname_cur(p_parent_id);

    LOOP
      FETCH ch12_exacur_pkg.pc_depname_cur INTO dep_cur;
      EXIT WHEN ch12_exacur_pkg.pc_depname_cur%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE ( dep_cur.department_id || ' - ' || dep_cur.department_name );
    END LOOP;

    CLOSE ch12_exacur_pkg.pc_depname_cur;
  END cur_example_proc;

END ch12_exacur_pkg;
/

EXEC ch12_exacur_pkg.cur_example_proc(10);













SET SERVEROUTPUT ON

CREATE OR REPLACE PACKAGE ch12_exam4_pkg IS

    PROCEDURE get_dep_hierarchy_proc ( p_dep_id IN NUMBER );

    PROCEDURE get_dep_hierarchy_proc ( p_dep_id IN NUMBER,
                                       p_par_id IN NUMBER );

END ch12_exam4_pkg;
/

CREATE OR REPLACE PACKAGE BODY ch12_exam4_pkg IS

    PROCEDURE get_dep_hierarchy_proc ( p_dep_id IN NUMBER )
    IS
      vn_dep_id    departments.department_id%TYPE;
      vs_dep_name  departments.department_name%TYPE;
    BEGIN
      SELECT department_id, department_name
        INTO vn_dep_id, vs_dep_name
        FROM departments
       WHERE department_id = p_dep_id;

      DBMS_OUTPUT.PUT_LINE('부서번호: ' || vn_dep_id);
      DBMS_OUTPUT.PUT_LINE('부서명 : ' || vs_dep_name);
    END get_dep_hierarchy_proc;

    PROCEDURE get_dep_hierarchy_proc ( p_dep_id IN NUMBER,
                                       p_par_id IN NUMBER )
    IS
      vn_dep_id    departments.department_id%TYPE;
      vs_dep_name  departments.department_name%TYPE;

      CURSOR my_dep ( p_par_id departments.parent_id%TYPE ) IS
        SELECT department_id AS dep_id, LPAD(' ', 3 * (LEVEL - 1)) || department_name AS dep_nm
          FROM departments
         START WITH parent_id = p_par_id
       CONNECT BY PRIOR department_id = parent_id;
    BEGIN
      SELECT department_id, department_name
        INTO vn_dep_id, vs_dep_name
        FROM departments
       WHERE department_id = p_dep_id;

      DBMS_OUTPUT.PUT_LINE('부서번호: ' || vn_dep_id);
      DBMS_OUTPUT.PUT_LINE('부서명 : ' || vs_dep_name);

      FOR rec IN my_dep(p_par_id)
      LOOP
         DBMS_OUTPUT.PUT_LINE( rec.dep_id || ' - ' || rec.dep_nm );
      END LOOP;
    END get_dep_hierarchy_proc;

END ch12_exam4_pkg;
/

EXEC ch12_exam4_pkg.get_dep_hierarchy_proc(10);

EXEC ch12_exam4_pkg.get_dep_hierarchy_proc(10, 10);





SELECT DBMS_METADATA.GET_DDL('PACKAGE', 'DBMS_OUTPUT', 'SYS')
  FROM DUAL;