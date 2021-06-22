CREATE OR REPLACE VIEW view_people_costs AS
SELECT DATE_PART('MONTH', payment_date) AS pay_month,
       DATE_PART('YEAR', payment_date)  AS pay_year,
       COUNT(*)                         AS employees_count,
       SUM(amount)                      AS paid
FROM payroll
GROUP BY pay_month, pay_year
ORDER BY pay_year, pay_month;


CREATE OR REPLACE VIEW view_people_costs_by_agency AS
SELECT DATE_PART('MONTH', payment_date) AS pay_month,
       DATE_PART('YEAR', payment_date)  AS pay_year,
       a.description                    AS agency,
       COUNT(p.*)                       AS employees_count,
       SUM(amount)                      AS paid
FROM payroll p
         JOIN employee_department ed ON (p.employee_id = ed.employee_id)
         JOIN department d ON (ed.department_id = d.id)
         JOIN agency a ON (a.id = d.agency_id)
GROUP BY pay_month, pay_year, a.description
ORDER BY pay_year, pay_month;


CREATE OR REPLACE VIEW view_receipts AS
SELECT DATE_PART('MONTH', due_date) AS pay_month,
       DATE_PART('YEAR', due_date)  AS pay_year,
       SUM(amount)                  AS receipt
FROM invoice
WHERE status = 'paid'
GROUP BY pay_month, pay_year
ORDER BY pay_year, pay_month;


CREATE OR REPLACE VIEW view_consolidated_staff_info AS
SELECT u.name,
       u.email,
       u.cpf,
       e.hire_date,
       s.salary      AS salary,
       d.name        AS department,
       a.description AS agency
FROM "user" u
         JOIN employee e ON (u.id = e.user_id)
         JOIN salary s ON (e.id = s.employee_id AND to_date IS NULL)
         JOIN employee_department ed ON (e.id = ed.employee_id)
         JOIN department d ON (ed.department_id = d.id)
         JOIN agency a ON (a.id = d.agency_id);


CREATE OR REPLACE VIEW view_sent_packages_by_month AS
SELECT DATE_PART('MONTH', step_started) AS sent_month,
       DATE_PART('YEAR', step_started)  AS sent_year,
       COUNT(*)
FROM travel_plan
WHERE step_number = 1
GROUP BY sent_month, sent_year
ORDER BY sent_year, sent_month;


CREATE OR REPLACE VIEW view_delivered_packages_by_month AS
SELECT DATE_PART('MONTH', receipt_date) AS sent_month,
       DATE_PART('YEAR', receipt_date)  AS sent_year,
       COUNT(*)
FROM package
WHERE status = 'delivered'
GROUP BY sent_month, sent_year
ORDER BY sent_year, sent_month;


CREATE OR REPLACE VIEW view_travel_consolidated_info AS
SELECT u.name                                                                              AS driver_name,
       tr.license_plate                                                                    AS truck,
       CONCAT(lf.primary_address, ' - ', lf.neighborhood, ' - ', lf.city, ' - ', lf.state) AS travel_start,
       CONCAT(lt.primary_address, ' - ', lt.neighborhood, ' - ', lt.city, ' - ', lt.state) AS travel_end,
       t.departure,
       t.arrival,
       COUNT(tp.id)                                                                        AS package_count
FROM travel t
         JOIN location lf ON (t.from_id = lf.id)
         JOIN location lt ON (t.to_id = lt.id)
         JOIN driver d ON (t.driver_id = d.id)
         JOIN truck tr ON (t.truck_id = tr.id)
         JOIN employee e ON (d.employee_id = e.id)
         JOIN "user" u ON (e.user_id = u.id)
         RIGHT JOIN travel_packages tp ON (t.id = tp.travel_id)
GROUP BY tp.id, driver_name, truck, travel_start, travel_end, departure, arrival;


CREATE OR REPLACE VIEW view_phone_numbers AS
SELECT u.id, u.name, pn.phone_numbers
FROM "user" u
         JOIN(
                SELECT user_id, string_agg(number, ',') AS phone_numbers
                FROM contact_phone
                GROUP BY 1
             ) AS pn ON (u.id = pn.user_id)
ORDER BY u.name;

CREATE OR REPLACE VIEW view_packages_in_transit AS
SELECT
       p.id AS package_id,
       p.description AS package_description,
       CONCAT(lf.primary_address, ' - ', lf.neighborhood, ' - ', lf.city, ' - ', lf.state) AS coming_from,
       CONCAT(lt.primary_address, ' - ', lt.neighborhood, ' - ', lt.city, ' - ', lt.state) AS going_to,
       departure
FROM package p
JOIN travel_packages tp on (p.id = tp.package_id)
JOIN travel t ON (t.id = tp.travel_id AND departure IS NOT NULL AND arrival IS NULL)
JOIN location lf ON (t.from_id = lf.id)
JOIN location lt ON (t.to_id = lt.id);