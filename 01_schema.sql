-- ============================================================
-- HR ANALYTICS PROJECT - DATABASE SCHEMA
-- Author: [Your Name]
-- Database: MySQL 8.0+
-- Description: Real-world HR Analytics database for tracking
--              employee lifecycle, attrition, performance & salary
-- ============================================================

CREATE DATABASE IF NOT EXISTS hr_analytics;
USE hr_analytics;

-- ─────────────────────────────────────────
-- TABLE 1: DEPARTMENTS
-- ─────────────────────────────────────────
CREATE TABLE departments (
    dept_id      INT PRIMARY KEY AUTO_INCREMENT,
    dept_name    VARCHAR(50)     NOT NULL UNIQUE,
    manager_name VARCHAR(100),
    location     VARCHAR(50),
    budget       DECIMAL(15,2),
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ─────────────────────────────────────────
-- TABLE 2: JOB ROLES
-- ─────────────────────────────────────────
CREATE TABLE job_roles (
    role_id    INT PRIMARY KEY AUTO_INCREMENT,
    role_name  VARCHAR(100) NOT NULL,
    dept_id    INT,
    min_salary DECIMAL(10,2),
    max_salary DECIMAL(10,2),
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

-- ─────────────────────────────────────────
-- TABLE 3: EMPLOYEES (Core Table)
-- ─────────────────────────────────────────
CREATE TABLE employees (
    emp_id             INT PRIMARY KEY AUTO_INCREMENT,
    emp_code           VARCHAR(20) UNIQUE NOT NULL,
    first_name         VARCHAR(50) NOT NULL,
    last_name          VARCHAR(50) NOT NULL,
    gender             ENUM('Male','Female','Other'),
    age                INT,
    date_of_birth      DATE,
    email              VARCHAR(100) UNIQUE,
    phone              VARCHAR(15),
    city               VARCHAR(50),
    state              VARCHAR(50),

    dept_id            INT,
    role_id            INT,
    education          VARCHAR(50),
    education_field    VARCHAR(50),

    date_joined        DATE NOT NULL,
    date_left          DATE,
    status             ENUM('Active','Left','Terminated') DEFAULT 'Active',
    exit_reason        VARCHAR(100),

    salary             DECIMAL(10,2),
    salary_hike_pct    DECIMAL(5,2),
    experience_years   INT,
    years_at_company   INT,

    work_mode          ENUM('Remote','Hybrid','On-site') DEFAULT 'Hybrid',
    marital_status     ENUM('Single','Married','Divorced'),
    distance_from_home INT,

    created_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (dept_id) REFERENCES departments(dept_id),
    FOREIGN KEY (role_id) REFERENCES job_roles(role_id)
);

-- ─────────────────────────────────────────
-- TABLE 4: PERFORMANCE REVIEWS
-- ─────────────────────────────────────────
CREATE TABLE performance_reviews (
    review_id          INT PRIMARY KEY AUTO_INCREMENT,
    emp_id             INT NOT NULL,
    review_year        INT NOT NULL,
    review_quarter     INT,
    performance_score  INT CHECK (performance_score BETWEEN 1 AND 5),
    manager_rating     INT CHECK (manager_rating BETWEEN 1 AND 5),
    self_rating        INT,
    promotion_flag     BOOLEAN DEFAULT FALSE,
    training_hours     INT,
    review_notes       TEXT,
    reviewed_at        DATE,
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);

-- ─────────────────────────────────────────
-- TABLE 5: ATTENDANCE
-- ─────────────────────────────────────────
CREATE TABLE attendance (
    att_id        INT PRIMARY KEY AUTO_INCREMENT,
    emp_id        INT NOT NULL,
    att_month     INT NOT NULL,  -- 1-12
    att_year      INT NOT NULL,
    days_present  INT DEFAULT 0,
    days_absent   INT DEFAULT 0,
    leaves_taken  INT DEFAULT 0,
    overtime_hrs  DECIMAL(5,2) DEFAULT 0,
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id),
    UNIQUE KEY uq_emp_month_year (emp_id, att_month, att_year)
);

-- ─────────────────────────────────────────
-- TABLE 6: SALARY HISTORY
-- ─────────────────────────────────────────
CREATE TABLE salary_history (
    history_id     INT PRIMARY KEY AUTO_INCREMENT,
    emp_id         INT NOT NULL,
    old_salary     DECIMAL(10,2),
    new_salary     DECIMAL(10,2),
    hike_pct       DECIMAL(5,2),
    effective_date DATE,
    reason         VARCHAR(100),
    changed_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);

-- ─────────────────────────────────────────
-- TABLE 7: RECRUITMENT
-- ─────────────────────────────────────────
CREATE TABLE recruitment (
    recruit_id       INT PRIMARY KEY AUTO_INCREMENT,
    emp_id           INT,
    source           VARCHAR(50),  -- LinkedIn, Naukri, Referral, Campus
    applied_date     DATE,
    interview_rounds INT,
    offer_date       DATE,
    joining_date     DATE,
    offer_accepted   BOOLEAN,
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);
