CREATE OR REPLACE FUNCTION sp_set_delivered_package()
    RETURNS TRIGGER
    LANGUAGE PLPGSQL
AS
$$
DECLARE
    has_next_step INTEGER;
BEGIN
    IF (OLD.status = 'completed' OR NEW.status <> 'completed') THEN
        RETURN NEW;
    END IF;

    SELECT COUNT(*)
    INTO has_next_step
    FROM travel_plan
    WHERE package_id = NEW.package_id
      AND step_number > NEW.step_number;

    IF (has_next_step > 0) THEN
        RETURN NEW;
    END IF;

    UPDATE package SET status = 'delivered', receipt_date = NEW.step_finished WHERE id = NEW.package_id;
    RETURN NEW;
END;
$$;


CREATE OR REPLACE FUNCTION sp_release_truck_and_driver()
    RETURNS TRIGGER
    LANGUAGE PLPGSQL
AS
$$
BEGIN
    IF (NEW.arrival IS NULL) THEN
        RETURN NEW;
    END IF;
        UPDATE truck SET status = 'on_hold' WHERE id = NEW.truck_id;
        UPDATE driver SET status = 'not_working' WHERE id = NEW.driver_id;
    RETURN NEW;
END;
$$;


CREATE OR REPLACE FUNCTION sp_hold_truck_and_driver()
    RETURNS TRIGGER
    LANGUAGE PLPGSQL
AS
$$
BEGIN
    IF (NEW.departure IS NOT NULL AND NEW.arrival IS NULL) THEN
        UPDATE truck SET status = 'dispatched' WHERE id = NEW.truck_id;
        UPDATE driver SET status = 'working' WHERE id = NEW.driver_id;
    END IF;
    RETURN NEW;
END;
$$;



CREATE OR REPLACE FUNCTION sp_deprecate_old_salaries()
    RETURNS TRIGGER
    LANGUAGE PLPGSQL
AS
$$
BEGIN
    UPDATE salary SET to_date = NOW() WHERE to_date IS NULL AND employee_id = NEW.employee_id;
    RETURN NEW;
END;
$$;


CREATE OR REPLACE FUNCTION sp_resign_employee()
    RETURNS TRIGGER
    LANGUAGE PLPGSQL
AS
$$
BEGIN
    IF (OLD.demission_date IS NULL AND NEW.demission_date IS NOT NULL) THEN
        UPDATE "user" SET enabled = FALSE WHERE id = NEW.user_id;
        UPDATE salary SET to_date = NOW() WHERE employee_id = NEW.id AND to_date IS NULL;
        UPDATE employee_department SET to_date = NOW() WHERE employee_id = NEW.id AND to_date IS NULL;
        UPDATE driver SET status = 'fired' WHERE employee_id = NEW.id;
    END IF;
    RETURN NEW;
END;
$$;

-- -------------------------------------------------------------

DROP TRIGGER IF EXISTS tr_set_delivered_package ON travel_plan;
DROP TRIGGER IF EXISTS tr_release_truck_and_driver ON travel;
DROP TRIGGER IF EXISTS tr_hold_truck_and_driver ON travel;
DROP TRIGGER IF EXISTS tr_deprecate_old_salaries ON salary;
DROP TRIGGER IF EXISTS tr_resign_employee ON salary;


CREATE TRIGGER tr_set_delivered_package
    AFTER UPDATE
    ON travel_plan
    FOR EACH ROW
EXECUTE PROCEDURE sp_set_delivered_package();


CREATE TRIGGER tr_release_truck_and_driver
    AFTER UPDATE
    ON travel
    FOR EACH ROW
EXECUTE PROCEDURE sp_release_truck_and_driver();


CREATE TRIGGER tr_hold_truck_and_driver
    AFTER UPDATE
    ON travel
    FOR EACH ROW
EXECUTE PROCEDURE sp_hold_truck_and_driver();


CREATE TRIGGER tr_deprecate_old_salaries
    BEFORE INSERT
    ON salary
    FOR EACH ROW
EXECUTE PROCEDURE sp_deprecate_old_salaries();


CREATE TRIGGER tr_resign_employee
    BEFORE UPDATE
    ON employee
    FOR EACH ROW
EXECUTE PROCEDURE sp_resign_employee();


