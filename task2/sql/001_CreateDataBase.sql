CREATE DATABASE iv1351;

BEGIN;

-- 【To TA: This part is just for debug, you can ignore it. The comment is mainly written in Chinese, due to its convient for me to understand it when reviewing.】反复调试的时候这个方便，不然还得手动删表格
DROP TABLE IF EXISTS allocation CASCADE;
DROP TABLE IF EXISTS planned_activity CASCADE;
DROP TABLE IF EXISTS employee CASCADE;
DROP TABLE IF EXISTS department CASCADE;
DROP TABLE IF EXISTS course_instance CASCADE;
DROP TABLE IF EXISTS course_layout CASCADE;
DROP TABLE IF EXISTS job_title CASCADE;
DROP TABLE IF EXISTS activity_type CASCADE;
DROP TABLE IF EXISTS period CASCADE;

/* 首先建立各种需要的表格 */

-- 查询用的表格
CREATE TABLE period (
  period_code TEXT PRIMARY KEY   -- 'P1','P2','P3','P4'
);

CREATE TABLE activity_type (
  activity_name TEXT PRIMARY KEY,
  factor NUMERIC(6,2) NOT NULL CHECK (factor > 0) -- 希望Factor别太大，如果真太大了就改这里
);

CREATE TABLE job_title (
  title_name TEXT PRIMARY KEY
);

-- CourseLayout & CourseInstance
CREATE TABLE course_layout (
  course_code TEXT PRIMARY KEY,
  course_name TEXT NOT NULL,
  hp NUMERIC(4,1) NOT NULL CHECK (hp > 0),
  min_students INT NOT NULL CHECK (min_students >= 0),
  max_students INT NOT NULL CHECK (max_students >= min_students)
);

CREATE TABLE course_instance (
  instance_id TEXT PRIMARY KEY,        
  course_code TEXT NOT NULL REFERENCES course_layout(course_code),
  study_year INT NOT NULL CHECK (study_year >= 2000),
  period_code TEXT NOT NULL REFERENCES period(period_code),
  num_students INT NOT NULL CHECK (num_students >= 0),
  UNIQUE (course_code, study_year, period_code)
);

-- plannedActivities
CREATE TABLE planned_activity (
  instance_id TEXT NOT NULL REFERENCES course_instance(instance_id) ON DELETE CASCADE,
  activity_name TEXT NOT NULL REFERENCES activity_type(activity_name),
  planned_hours NUMERIC(10,2) NOT NULL CHECK (planned_hours >= 0),
  PRIMARY KEY (instance_id, activity_name)
);

-- Teacher相关信息
CREATE TABLE department (
  department_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  department_name TEXT NOT NULL UNIQUE
);

CREATE TABLE employee (
  employment_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  full_name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  department_id INT NOT NULL REFERENCES department(department_id),
  title_name TEXT NOT NULL REFERENCES job_title(title_name),
  salary_ksek NUMERIC(10,2) NOT NULL CHECK (salary_ksek >= 0),
  supervisor_employment_id INT REFERENCES employee(employment_id)
);

ALTER TABLE department -- 把这个以ADD的形式给出是因为得等着employee创建好才能
  ADD COLUMN manager_employment_id INT REFERENCES employee(employment_id);

-- CourseInstance <-> Teacher
CREATE TABLE allocation (
  employment_id INT NOT NULL REFERENCES employee(employment_id) ON DELETE CASCADE,
  instance_id TEXT NOT NULL REFERENCES course_instance(instance_id) ON DELETE CASCADE,
  activity_name TEXT NOT NULL REFERENCES activity_type(activity_name),
  allocated_hours NUMERIC(10,2) NOT NULL CHECK (allocated_hours >= 0),
  PRIMARY KEY (employment_id, instance_id, activity_name)
);

COMMIT;