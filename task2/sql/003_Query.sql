-- 【To TA: debugging use, to reset the DB】
ROLLBACK;

BEGIN;

-- 首先，形式上补全，但是实际上Query1不需要这两个
INSERT INTO activity_type (activity_name, factor) VALUES 
('Admin', 1.00),
('Exam', 1.00)
ON CONFLICT (activity_name) DO NOTHING;

-- 补全数据，就假设了一下，似乎Project中也没写要怎么搞
-- IV1351 (P2) Admin=83, Exam=177 (基于200学生, 7.5HP)
INSERT INTO allocation (employment_id, instance_id, activity_name, allocated_hours)
VALUES 
( (SELECT employment_id FROM employee WHERE full_name='Paris Carbone'), '2025-50273', 'Admin', 83 ),
( (SELECT employment_id FROM employee WHERE full_name='Paris Carbone'), '2025-50273', 'Exam', 177 );

-- IX1500 (P1) Admin=73, Exam=141 (基于150学生, 7.5HP)
INSERT INTO allocation (employment_id, instance_id, activity_name, allocated_hours)
VALUES 
( (SELECT employment_id FROM employee WHERE full_name='Anna Berg'), '2025-50413', 'Admin', 73 ),
( (SELECT employment_id FROM employee WHERE full_name='Anna Berg'), '2025-50413', 'Exam', 141 );

-- ID2214 (P2) Admin=67, Exam=119 (基于120学生, 7.5HP)
INSERT INTO allocation (employment_id, instance_id, activity_name, allocated_hours)
VALUES 
( (SELECT employment_id FROM employee WHERE full_name='Niharika Gauraha'), '2025-50341', 'Admin', 67 ),
( (SELECT employment_id FROM employee WHERE full_name='Paris Carbone'), '2025-50341', 'Exam', 119 );

COMMIT;

-- Query 1
CREATE OR REPLACE VIEW view_planned_course_report as --满足未来Discussion中的view的要求
SELECT 
    cl.course_code AS "Course Code",
    ci.instance_id AS "Instance ID",
    cl.hp AS "HP",
    ci.period_code AS "Period",
    ci.num_students AS "# Students",
    -- factor计算乘积
    ROUND(SUM(CASE WHEN pa.activity_name = 'Lecture' THEN pa.planned_hours * act.factor ELSE 0 END), 1) AS "Lecture",
    ROUND(SUM(CASE WHEN pa.activity_name = 'Tutorial' THEN pa.planned_hours * act.factor ELSE 0 END), 1) AS "Tutorial",
    ROUND(SUM(CASE WHEN pa.activity_name = 'Lab' THEN pa.planned_hours * act.factor ELSE 0 END), 1) AS "Lab",
    ROUND(SUM(CASE WHEN pa.activity_name = 'Seminar' THEN pa.planned_hours * act.factor ELSE 0 END), 1) AS "Seminar",
    ROUND(SUM(CASE WHEN pa.activity_name = 'Other' THEN pa.planned_hours * act.factor ELSE 0 END), 1) AS "Other",
    
    -- derive attribute
    -- Admin = 2*HP + 28 + 0.2*Students
    ROUND((2 * cl.hp) + 28 + (0.2 * ci.num_students), 1) AS "Admin",
    -- Exam = 32 + 0.725*Students
    ROUND(32 + (0.725 * ci.num_students), 1) AS "Exam",

    -- 总工时计算
    ROUND(
        COALESCE(SUM(pa.planned_hours * act.factor), 0) + 
        ((2 * cl.hp) + 28 + (0.2 * ci.num_students)) + 
        (32 + (0.725 * ci.num_students))
    , 1) AS "Total Hours"

FROM course_instance ci
JOIN course_layout cl ON ci.course_code = cl.course_code
LEFT JOIN planned_activity pa ON ci.instance_id = pa.instance_id
LEFT JOIN activity_type act ON pa.activity_name = act.activity_name
WHERE ci.study_year = 2025
GROUP BY cl.course_code, ci.instance_id, cl.hp, ci.period_code, ci.num_students --这样就能确定是同一个课啦
ORDER BY ci.period_code, cl.course_code; -- 美化


SELECT * FROM view_planned_course_report


-- Query 2
SELECT 
    cl.course_code AS "Course Code",
    ci.instance_id AS "Instance ID",
    cl.hp AS "HP",
    e.full_name AS "Teacher",
    e.title_name AS "Designation",
    -- 各项活动分配 (Time * Factor)
    ROUND(SUM(CASE WHEN al.activity_name = 'Lecture' THEN al.allocated_hours * act.factor ELSE 0 END), 1) AS "Lecture",
    ROUND(SUM(CASE WHEN al.activity_name = 'Tutorial' THEN al.allocated_hours * act.factor ELSE 0 END), 1) AS "Tutorial",
    ROUND(SUM(CASE WHEN al.activity_name = 'Lab' THEN al.allocated_hours * act.factor ELSE 0 END), 1) AS "Lab",
    ROUND(SUM(CASE WHEN al.activity_name = 'Seminar' THEN al.allocated_hours * act.factor ELSE 0 END), 1) AS "Seminar",
    ROUND(SUM(CASE WHEN al.activity_name = 'Other' THEN al.allocated_hours * act.factor ELSE 0 END), 1) AS "Other",
    ROUND(SUM(CASE WHEN al.activity_name = 'Admin' THEN al.allocated_hours * act.factor ELSE 0 END), 1) AS "Admin",
    ROUND(SUM(CASE WHEN al.activity_name = 'Exam' THEN al.allocated_hours * act.factor ELSE 0 END), 1) AS "Exam",
    -- 个人总和
    ROUND(SUM(al.allocated_hours * act.factor), 1) AS "Total"
FROM allocation al
JOIN course_instance ci ON al.instance_id = ci.instance_id
JOIN course_layout cl ON ci.course_code = cl.course_code
JOIN employee e ON al.employment_id = e.employment_id
JOIN activity_type act ON al.activity_name = act.activity_name
WHERE ci.instance_id = '2025-50273' -- 指定查询 IV1351 的一个instance
GROUP BY cl.course_code, ci.instance_id, cl.hp, e.full_name, e.title_name
ORDER BY "Total" DESC;


-- Query 3
SELECT 
    cl.course_code AS "Course Code",
    ci.instance_id AS "Instance ID",
    cl.hp,
    ci.period_code AS "Period",
    e.full_name AS "Teacher",
    
    ROUND(SUM(CASE WHEN al.activity_name = 'Lecture' THEN al.allocated_hours * act.factor ELSE 0 END), 1) AS "Lecture",
    ROUND(SUM(CASE WHEN al.activity_name = 'Tutorial' THEN al.allocated_hours * act.factor ELSE 0 END), 1) AS "Tutorial",
    ROUND(SUM(CASE WHEN al.activity_name = 'Lab' THEN al.allocated_hours * act.factor ELSE 0 END), 1) AS "Lab",
    ROUND(SUM(CASE WHEN al.activity_name = 'Seminar' THEN al.allocated_hours * act.factor ELSE 0 END), 1) AS "Seminar",
    ROUND(SUM(CASE WHEN al.activity_name = 'Other' THEN al.allocated_hours * act.factor ELSE 0 END), 1) AS "Other",
    ROUND(SUM(CASE WHEN al.activity_name = 'Admin' THEN al.allocated_hours * act.factor ELSE 0 END), 1) AS "Admin",
    ROUND(SUM(CASE WHEN al.activity_name = 'Exam' THEN al.allocated_hours * act.factor ELSE 0 END), 1) AS "Exam",
    
    ROUND(SUM(al.allocated_hours * act.factor), 1) AS "Total"
FROM allocation al
JOIN course_instance ci ON al.instance_id = ci.instance_id
JOIN course_layout cl ON ci.course_code = cl.course_code
JOIN employee e ON al.employment_id = e.employment_id
JOIN activity_type act ON al.activity_name = act.activity_name
WHERE e.full_name = 'Paris Carbone' AND ci.study_year = 2025
GROUP BY cl.course_code, ci.instance_id, cl.hp, ci.period_code, e.full_name
ORDER BY ci.period_code;


-- Query 4
SELECT 
    e.employment_id AS "Emp ID",
    e.full_name AS "Teacher Name",
    ci.period_code AS "Period",
    COUNT(DISTINCT ci.instance_id) AS "No of Courses"
FROM allocation al
JOIN employee e ON al.employment_id = e.employment_id
JOIN course_instance ci ON al.instance_id = ci.instance_id
WHERE ci.study_year = 2025
GROUP BY e.employment_id, e.full_name, ci.period_code
HAVING COUNT(DISTINCT ci.instance_id) > 1
ORDER BY "No of Courses" DESC;

-- Performance Analysis for Query 2
EXPLAIN ANALYZE
SELECT 
    cl.course_code,
    e.full_name,
    SUM(al.allocated_hours * act.factor) AS total_hours
FROM allocation al
JOIN course_instance ci ON al.instance_id = ci.instance_id
JOIN course_layout cl ON ci.course_code = cl.course_code
JOIN employee e ON al.employment_id = e.employment_id
JOIN activity_type act ON al.activity_name = act.activity_name
WHERE ci.instance_id = '2025-50273'
GROUP BY cl.course_code, e.full_name;
