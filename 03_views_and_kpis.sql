-- ============================================================
-- HR ANALYTICS - VIEWS & KPI QUERIES FOR POWER BI
-- ============================================================
USE hr_analytics;

-- ─────────────────────────────────────────────────────────────
-- VIEW 1: Employee Full Profile (main Power BI table)
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_employee_profile AS
SELECT
    e.emp_id,
    e.emp_code,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    e.gender,
    e.age,
    e.city,
    e.state,
    d.dept_name                            AS department,
    j.role_name                            AS job_role,
    e.education,
    e.education_field,
    e.date_joined,
    e.date_left,
    e.status,
    e.exit_reason,
    e.salary,
    e.salary_hike_pct,
    e.experience_years,
    e.years_at_company,
    e.work_mode,
    e.marital_status,
    e.distance_from_home,
    YEAR(e.date_joined)                    AS joining_year,
    MONTH(e.date_joined)                   AS joining_month,
    CASE
        WHEN e.age < 25 THEN 'Under 25'
        WHEN e.age < 30 THEN '25-30'
        WHEN e.age < 35 THEN '30-35'
        WHEN e.age < 40 THEN '35-40'
        ELSE '40+'
    END                                    AS age_band,
    CASE
        WHEN e.salary < 60000  THEN '< 60K'
        WHEN e.salary < 100000 THEN '60K - 1L'
        WHEN e.salary < 150000 THEN '1L - 1.5L'
        WHEN e.salary < 200000 THEN '1.5L - 2L'
        ELSE '> 2L'
    END                                    AS salary_band,
    CASE
        WHEN e.experience_years <= 1 THEN '0-1 yr'
        WHEN e.experience_years <= 3 THEN '1-3 yr'
        WHEN e.experience_years <= 6 THEN '3-6 yr'
        WHEN e.experience_years <= 10 THEN '6-10 yr'
        ELSE '10+ yr'
    END                                    AS experience_band
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
JOIN job_roles   j ON e.role_id = j.role_id;


-- ─────────────────────────────────────────────────────────────
-- VIEW 2: Attrition Summary by Department
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_attrition_by_dept AS
SELECT
    d.dept_name                                                      AS department,
    COUNT(*)                                                         AS total_employees,
    SUM(CASE WHEN e.status = 'Active' THEN 1 ELSE 0 END)            AS active_count,
    SUM(CASE WHEN e.status = 'Left'   THEN 1 ELSE 0 END)            AS attrited_count,
    ROUND(
        SUM(CASE WHEN e.status = 'Left' THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2)                                       AS attrition_rate_pct,
    ROUND(AVG(e.salary), 0)                                          AS avg_salary,
    ROUND(AVG(e.experience_years), 1)                                AS avg_experience
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY d.dept_name;


-- ─────────────────────────────────────────────────────────────
-- VIEW 3: Monthly Hiring Trend
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_hiring_trend AS
SELECT
    YEAR(date_joined)                  AS hire_year,
    MONTH(date_joined)                 AS hire_month,
    MONTHNAME(date_joined)             AS month_name,
    COUNT(*)                           AS new_hires,
    SUM(CASE WHEN status='Left' THEN 1 ELSE 0 END) AS leavers,
    d.dept_name                        AS department
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY hire_year, hire_month, month_name, d.dept_name
ORDER BY hire_year, hire_month;


-- ─────────────────────────────────────────────────────────────
-- VIEW 4: Performance Summary
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_performance_summary AS
SELECT
    e.emp_id,
    CONCAT(e.first_name,' ',e.last_name)  AS employee_name,
    d.dept_name                            AS department,
    j.role_name                            AS job_role,
    e.status,
    pr.review_year,
    pr.performance_score,
    pr.manager_rating,
    pr.self_rating,
    pr.promotion_flag,
    pr.training_hours,
    CASE pr.performance_score
        WHEN 5 THEN 'Outstanding'
        WHEN 4 THEN 'Exceeds Expectations'
        WHEN 3 THEN 'Meets Expectations'
        WHEN 2 THEN 'Needs Improvement'
        ELSE 'Poor'
    END                                    AS performance_label
FROM employees e
JOIN departments      d  ON e.dept_id  = d.dept_id
JOIN job_roles        j  ON e.role_id  = j.role_id
JOIN performance_reviews pr ON e.emp_id = pr.emp_id;


-- ─────────────────────────────────────────────────────────────
-- VIEW 5: Salary Analysis
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_salary_analysis AS
SELECT
    d.dept_name                     AS department,
    j.role_name                     AS job_role,
    e.gender,
    e.education,
    e.work_mode,
    COUNT(*)                        AS headcount,
    ROUND(AVG(e.salary),0)          AS avg_salary,
    MIN(e.salary)                   AS min_salary,
    MAX(e.salary)                   AS max_salary,
    ROUND(AVG(e.salary_hike_pct),2) AS avg_hike_pct,
    ROUND(STDDEV(e.salary),0)       AS salary_stddev
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
JOIN job_roles   j ON e.role_id = j.role_id
WHERE e.status = 'Active'
GROUP BY d.dept_name, j.role_name, e.gender, e.education, e.work_mode;


-- ─────────────────────────────────────────────────────────────
-- VIEW 6: Attendance Summary
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_attendance_summary AS
SELECT
    e.emp_id,
    CONCAT(e.first_name,' ',e.last_name) AS employee_name,
    d.dept_name                           AS department,
    a.att_year                            AS year,
    a.att_month                           AS month,
    SUM(a.days_present)                   AS total_present,
    SUM(a.days_absent)                    AS total_absent,
    SUM(a.leaves_taken)                   AS total_leaves,
    SUM(a.overtime_hrs)                   AS total_overtime,
    ROUND(AVG(a.days_present / 23.0 * 100), 1) AS attendance_pct
FROM attendance a
JOIN employees   e ON a.emp_id  = e.emp_id
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY e.emp_id, employee_name, d.dept_name, a.att_year, a.att_month;


-- ─────────────────────────────────────────────────────────────
-- VIEW 7: Recruitment Source Analysis
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_recruitment_analysis AS
SELECT
    r.source                                AS recruitment_source,
    d.dept_name                             AS department,
    COUNT(*)                                AS total_hires,
    ROUND(AVG(r.interview_rounds), 1)       AS avg_rounds,
    ROUND(AVG(DATEDIFF(r.joining_date, r.applied_date)), 0) AS avg_days_to_join,
    SUM(CASE WHEN e.status='Left' THEN 1 ELSE 0 END)        AS attrited,
    ROUND(SUM(CASE WHEN e.status='Left' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS attrition_pct
FROM recruitment r
JOIN employees   e ON r.emp_id  = e.emp_id
JOIN departments d ON e.dept_id = d.dept_id
GROUP BY r.source, d.dept_name;


-- ─────────────────────────────────────────────────────────────
-- KPI QUERIES — use these directly in Power BI
-- ─────────────────────────────────────────────────────────────

-- KPI 1: Overall attrition rate
SELECT ROUND(SUM(CASE WHEN status='Left' THEN 1 ELSE 0 END)*100.0/COUNT(*),2)
       AS overall_attrition_pct FROM employees;

-- KPI 2: Active headcount
SELECT COUNT(*) AS active_employees FROM employees WHERE status='Active';

-- KPI 3: Average salary of active employees
SELECT ROUND(AVG(salary),0) AS avg_salary FROM employees WHERE status='Active';

-- KPI 4: Average tenure in years
SELECT ROUND(AVG(years_at_company),1) AS avg_tenure FROM employees WHERE status='Active';

-- KPI 5: High risk employees (low perf + low salary + far from office)
SELECT COUNT(*) AS high_risk_count
FROM employees e
JOIN performance_reviews pr ON e.emp_id = pr.emp_id
WHERE pr.performance_score <= 2
  AND e.distance_from_home > 30
  AND e.status = 'Active'
  AND pr.review_year = 2024;

-- KPI 6: Gender diversity ratio
SELECT gender, COUNT(*) AS count,
       ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM employees),1) AS pct
FROM employees GROUP BY gender;

-- KPI 7: Department with highest attrition
SELECT dept_name, attrition_rate_pct
FROM vw_attrition_by_dept
ORDER BY attrition_rate_pct DESC LIMIT 1;

-- KPI 8: Top exit reasons
SELECT exit_reason, COUNT(*) AS count
FROM employees
WHERE status = 'Left' AND exit_reason IS NOT NULL
GROUP BY exit_reason ORDER BY count DESC;
