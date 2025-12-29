BEGIN;

-- 【Debug need】清空数据
TRUNCATE TABLE
  allocation,
  planned_activity,
  employee,
  department,
  course_instance,
  course_layout,
  job_title,
  activity_type,
  period
RESTART IDENTITY CASCADE;

-- Period数据，这个反正都得做，算是初始化
INSERT INTO period VALUES ('P1'),('P2'),('P3'),('P4');

-- Activity Factor
INSERT INTO activity_type(activity_name, factor) VALUES
('Lecture', 3.60),
('Lab', 2.40),
('Tutorial', 2.40),
('Seminar', 1.80),
('Other', 1.00);

-- Title
INSERT INTO job_title VALUES
('Ass. Professor'),('Lecturer'),('TA'),('PhD Student'),('Manager');

-- Department
INSERT INTO department(department_name) VALUES
('CS'),('Math'),('EE');

-- CourseLayout
INSERT INTO course_layout(course_code, course_name, hp, min_students, max_students) VALUES
('IV1351','Data Storage Paradigms',7.5,50,250),
('IX1500','Discrete Mathematics',7.5,50,150),
('ID2214','Distributed Systems',7.5,30,200),
('IV1350','Database Technology',7.5,40,220),
('ID2202','Compiler Construction',7.5,30,180),
('DD1338','Algorithms and Data Structures',7.5,40,300),
('EQ2010','Signals and Systems',7.5,30,200),
('SF1688','Discrete Mathematics II',7.5,30,180);

-- Employees
INSERT INTO employee(full_name,email,phone,department_id,title_name,salary_ksek,supervisor_employment_id) VALUES
('Paris Carbone','paris@uni.se',NULL,(SELECT department_id FROM department WHERE department_name='CS'),'Ass. Professor',70,NULL),
('Maja Nilsson','maja@uni.se',NULL,(SELECT department_id FROM department WHERE department_name='Math'),'Manager',75,NULL),
('Erik Svensson','erik@uni.se',NULL,(SELECT department_id FROM department WHERE department_name='EE'),'Manager',78,NULL);


INSERT INTO employee(full_name,email,phone,department_id,title_name,salary_ksek,supervisor_employment_id) VALUES
('Leif Linbäck','leif@uni.se',NULL,(SELECT department_id FROM department WHERE department_name='CS'),'Lecturer',55,1),
('Niharika Gauraha','niharika@uni.se',NULL,(SELECT department_id FROM department WHERE department_name='CS'),'Lecturer',55,1),
('Brian','brian@uni.se',NULL,(SELECT department_id FROM department WHERE department_name='CS'),'PhD Student',35,1),
('Adam','adam@uni.se',NULL,(SELECT department_id FROM department WHERE department_name='CS'),'TA',25,4),

('Anna Berg','anna@uni.se',NULL,(SELECT department_id FROM department WHERE department_name='Math'),'Lecturer',54,2),
('Oskar Lind','oskar@uni.se',NULL,(SELECT department_id FROM department WHERE department_name='Math'),'TA',25,8),

('Sofia Chen','sofia@uni.se',NULL,(SELECT department_id FROM department WHERE department_name='EE'),'Lecturer',58,3),
('Jonas Karl','jonas@uni.se',NULL,(SELECT department_id FROM department WHERE department_name='EE'),'PhD Student',36,3),
('Elin Wu','elin@uni.se',NULL,(SELECT department_id FROM department WHERE department_name='EE'),'TA',25,10);

-- Department.manager
UPDATE department
SET manager_employment_id = (SELECT employment_id FROM employee WHERE full_name='Paris Carbone')
WHERE department_name='CS';

UPDATE department
SET manager_employment_id = (SELECT employment_id FROM employee WHERE full_name='Maja Nilsson')
WHERE department_name='Math';

UPDATE department
SET manager_employment_id = (SELECT employment_id FROM employee WHERE full_name='Erik Svensson')
WHERE department_name='EE';

-- Course Instance
INSERT INTO course_instance(instance_id, course_code, study_year, period_code, num_students) VALUES
('2025-50273','IV1351',2025,'P2',200),
('2025-50413','IX1500',2025,'P1',150),
('2025-50341','ID2214',2025,'P2',120),
('2025-60104','IV1350',2025,'P3',180),
('2025-70111','ID2202',2025,'P4',140),
('2025-70112','DD1338',2025,'P1',220),
('2025-70113','EQ2010',2025,'P3',160),
('2025-70114','SF1688',2025,'P4',110);

-- Planned Hours
-- IV1351 P2
INSERT INTO planned_activity VALUES
('2025-50273','Lecture',20),
('2025-50273','Tutorial',80),
('2025-50273','Lab',40),
('2025-50273','Seminar',80),
('2025-50273','Other',650);

-- IX1500 P1
INSERT INTO planned_activity VALUES
('2025-50413','Lecture',44),
('2025-50413','Seminar',64),
('2025-50413','Other',200);

-- ID2214 P2
INSERT INTO planned_activity VALUES
('2025-50341','Lecture',28),
('2025-50341','Tutorial',30),
('2025-50341','Seminar',20),
('2025-50341','Other',120);

-- IV1350 P3
INSERT INTO planned_activity VALUES
('2025-60104','Lecture',32),
('2025-60104','Lab',36),
('2025-60104','Seminar',18),
('2025-60104','Other',180);

-- ID2202 P4
INSERT INTO planned_activity VALUES
('2025-70111','Lecture',40),
('2025-70111','Tutorial',20),
('2025-70111','Lab',20),
('2025-70111','Other',160);

-- DD1338 P1
INSERT INTO planned_activity VALUES
('2025-70112','Lecture',36),
('2025-70112','Tutorial',24),
('2025-70112','Lab',18),
('2025-70112','Other',220);

-- EQ2010 P3
INSERT INTO planned_activity VALUES
('2025-70113','Lecture',30),
('2025-70113','Tutorial',18),
('2025-70113','Lab',20),
('2025-70113','Other',140);

-- SF1688 P4
INSERT INTO planned_activity VALUES
('2025-70114','Lecture',26),
('2025-70114','Seminar',30),
('2025-70114','Other',100);

-- Allocations
-- 【To TA: I have made the condition that contains the same teacher teaches multiple course.】

-- P2: IV1351
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-50273', 'Lecture', 20 FROM employee WHERE full_name='Paris Carbone';
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-50273', 'Seminar', 40 FROM employee WHERE full_name='Leif Linbäck';
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-50273', 'Seminar', 40 FROM employee WHERE full_name='Niharika Gauraha';
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-50273', 'Lab', 20 FROM employee WHERE full_name='Brian';
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-50273', 'Lab', 20 FROM employee WHERE full_name='Adam';
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-50273', 'Other', 100 FROM employee WHERE full_name='Paris Carbone';

-- P1: IX1500
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-50413', 'Lecture', 44 FROM employee WHERE full_name='Anna Berg';
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-50413', 'Seminar', 30 FROM employee WHERE full_name='Oskar Lind';
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-50413', 'Other', 80 FROM employee WHERE full_name='Anna Berg';

-- P2: ID2214
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-50341', 'Lecture', 28 FROM employee WHERE full_name='Niharika Gauraha';
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-50341', 'Tutorial', 18 FROM employee WHERE full_name='Leif Linbäck';
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-50341', 'Seminar', 20 FROM employee WHERE full_name='Brian';
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-50341', 'Other', 40 FROM employee WHERE full_name='Paris Carbone';

-- P3: IV1350
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-60104', 'Lecture', 32 FROM employee WHERE full_name='Leif Linbäck';
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-60104', 'Lab', 18 FROM employee WHERE full_name='Adam';
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-60104', 'Lab', 18 FROM employee WHERE full_name='Brian';
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-60104', 'Other', 50 FROM employee WHERE full_name='Paris Carbone';

-- P4: ID2202
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-70111', 'Lecture', 40 FROM employee WHERE full_name='Paris Carbone';
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-70111', 'Tutorial', 20 FROM employee WHERE full_name='Niharika Gauraha';
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-70111', 'Lab', 20 FROM employee WHERE full_name='Brian';
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-70111', 'Other', 60 FROM employee WHERE full_name='Leif Linbäck';

-- P1: DD1338
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-70112', 'Lecture', 36 FROM employee WHERE full_name='Sofia Chen';
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-70112', 'Tutorial', 24 FROM employee WHERE full_name='Jonas Karl';
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-70112', 'Lab', 18 FROM employee WHERE full_name='Elin Wu';
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-70112', 'Other', 90 FROM employee WHERE full_name='Sofia Chen';

-- P3: EQ2010
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-70113', 'Lecture', 30 FROM employee WHERE full_name='Sofia Chen';
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-70113', 'Lab', 20 FROM employee WHERE full_name='Elin Wu';
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-70113', 'Tutorial', 18 FROM employee WHERE full_name='Jonas Karl';
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-70113', 'Other', 60 FROM employee WHERE full_name='Erik Svensson';

-- P4: SF1688
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-70114', 'Lecture', 26 FROM employee WHERE full_name='Anna Berg';
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-70114', 'Seminar', 30 FROM employee WHERE full_name='Oskar Lind';
INSERT INTO allocation(employment_id, instance_id, activity_name, allocated_hours)
SELECT employment_id, '2025-70114', 'Other', 40 FROM employee WHERE full_name='Maja Nilsson';

COMMIT;