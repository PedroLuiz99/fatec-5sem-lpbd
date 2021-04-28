DROP TABLE IF EXISTS trip_packages;
DROP TABLE IF EXISTS trip;
DROP TABLE IF EXISTS truck;
DROP TABLE IF EXISTS travel_plan_step;
DROP TABLE IF EXISTS travel_plan;
DROP TABLE IF EXISTS invoice_item;
DROP TABLE IF EXISTS invoice;
DROP TABLE IF EXISTS package;
DROP TABLE IF EXISTS employee_department;
DROP TABLE IF EXISTS department_manager;
DROP TABLE IF EXISTS department;
DROP TABLE IF EXISTS salary;
DROP TABLE IF EXISTS payroll_item;
DROP TABLE IF EXISTS payroll;
DROP TABLE IF EXISTS driver;
DROP TABLE IF EXISTS employee;
DROP TABLE IF EXISTS third_company;
DROP TABLE IF EXISTS contract;
DROP TABLE IF EXISTS company_contact;
DROP TABLE IF EXISTS partnership;
DROP TABLE IF EXISTS partner_stop_point;
DROP TABLE IF EXISTS agency;
DROP TABLE IF EXISTS contact_phone;
DROP TABLE IF EXISTS user_address;
DROP TABLE IF EXISTS document;
DROP TABLE IF EXISTS "user";
DROP TABLE IF EXISTS role;
DROP TABLE IF EXISTS location;
DROP TABLE IF EXISTS city;

DROP TYPE IF EXISTS contact_phone_type;
DROP TYPE IF EXISTS package_status;
DROP TYPE IF EXISTS travel_step_status;
DROP TYPE IF EXISTS truck_status;
DROP TYPE IF EXISTS driver_status;
DROP TYPE IF EXISTS address_type;
DROP TYPE IF EXISTS invoice_status;

CREATE TABLE city
(
    id      SERIAL PRIMARY KEY,
    name    VARCHAR(255) NOT NULL,
    zipcode VARCHAR(8)
);

CREATE TABLE location
(
    id                SERIAL PRIMARY KEY,
    primary_address   TEXT       NOT NULL,
    secondary_address TEXT,
    neighborhood      VARCHAR(100),
    zipcode           VARCHAR(8),
    city              INTEGER    NOT NULL,
    state             VARCHAR(2) NOT NULL,
    geolocation       GEOMETRY   NOT NULL,

    CONSTRAINT fk_location_city FOREIGN KEY (city)
        REFERENCES city (id)
);

CREATE TABLE role
(
    id   SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE "user"
(
    id      SERIAL PRIMARY KEY,
    name    VARCHAR(255) NOT NULL,
    role_id INTEGER      NOT NULL,
    email   VARCHAR(255) NOT NULL,
    cpf     VARCHAR(16)  NOT NULL,
    enabled BOOLEAN      NOT NULL,

    CONSTRAINT fk_user_role FOREIGN KEY (role_id)
        REFERENCES role (id)
);

CREATE TYPE address_type AS ENUM (
    'residential',
    'business',
    'other'
    );

CREATE TABLE user_address
(
    id          SERIAL PRIMARY KEY,
    user_id     INTEGER      NOT NULL,
    location_id INTEGER      NOT NULL,
    type        address_type NOT NULL,

    CONSTRAINT fk_user_address_user FOREIGN KEY (user_id)
        REFERENCES "user" (id),

    CONSTRAINT fk_user_address_location FOREIGN KEY (location_id)
        REFERENCES location (id)
);

CREATE TYPE contact_phone_type AS ENUM (
    'cellphone',
    'residential',
    'work'
    );

CREATE TABLE contact_phone
(
    id      SERIAL PRIMARY KEY,
    user_id INTEGER            NOT NULL,
    type    contact_phone_type NOT NULL,
    number  VARCHAR(64)        NOT NULL,

    CONSTRAINT fk_phone_user FOREIGN KEY (user_id)
        REFERENCES "user" (id)
);

CREATE TABLE agency
(
    id          SERIAL PRIMARY KEY,
    location_id INTEGER NOT NULL,
    owner_id    INTEGER NOT NULL,

    CONSTRAINT fk_owner_user FOREIGN KEY (owner_id)
        REFERENCES "user" (id)
);

CREATE TABLE employee
(
    id             SERIAL PRIMARY KEY,
    user_id        INTEGER NOT NULL,
    hire_date      DATE    NOT NULL,
    demission_date DATE    NOT NULL
);

CREATE TABLE department
(
    id        SERIAL PRIMARY KEY,
    agency_id INTEGER      NOT NULL,
    name      VARCHAR(128) NOT NULL,

    CONSTRAINT fk_department_agency FOREIGN KEY (agency_id)
        REFERENCES agency (id)
);

CREATE TABLE department_manager
(
    id            SERIAL  NOT NULL,
    employee_id   INTEGER NOT NULL,
    department_id INTEGER NOT NULL,
    from_date     DATE    NOT NULL,
    to_date       DATE,

    CONSTRAINT fk_department_manager_employee FOREIGN KEY (employee_id)
        REFERENCES employee (id),

    CONSTRAINT fk_department_manager_department FOREIGN KEY (department_id)
        REFERENCES department (id)
);

CREATE TABLE employee_department
(
    id            SERIAL  NOT NULL,
    employee_id   INTEGER NOT NULL,
    department_id INTEGER NOT NULL,
    from_date     DATE    NOT NULL,
    to_date       DATE,

    CONSTRAINT fk_employe_department_employee FOREIGN KEY (employee_id)
        REFERENCES employee (id),

    CONSTRAINT fk_employee_department_department FOREIGN KEY (department_id)
        REFERENCES department (id)
);

CREATE TABLE salary
(
    id          INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    salary      DECIMAL NOT NULL,
    from_date   DATE    NOT NULL,
    to_date     DATE,

    CONSTRAINT fk_employee_department_employee FOREIGN KEY (employee_id)
        REFERENCES employee (id)
);

CREATE TABLE payroll
(
    id           SERIAL PRIMARY KEY,
    employee_id  INTEGER NOT NULL,
    amount       DECIMAL NOT NULL,
    paid         BOOLEAN,
    payment_date DATE    NOT NULL,

    CONSTRAINT fk_payroll_employee FOREIGN KEY (employee_id)
        REFERENCES employee (id)
);

CREATE TABLE payroll_item
(
    id          SERIAL PRIMARY KEY,
    payroll_id  INTEGER NOT NULL,
    description VARCHAR(255),
    type        VARCHAR(64),
    amount      DECIMAL NOT NULL,

    CONSTRAINT fk_payroll_items_payroll FOREIGN KEY (payroll_id)
        REFERENCES payroll (id)
);

CREATE TYPE package_status AS ENUM (
    'delivered',
    'refused',
    'returned',
    'posted',
    'in_transit',
    'lost'
    );

CREATE TABLE package
(
    id           SERIAL PRIMARY KEY,
    recipient_id INTEGER NOT NULL,
    sender_id    INTEGER NOT NULL,
    due_date     DATE    NOT NULL,
    source       INTEGER NOT NULL,
    destination  INTEGER NOT NULL,
    x_size       DECIMAL NOT NULL,
    y_size       DECIMAL NOT NULL,
    z_size       DECIMAL NOT NULL,
    weight       DECIMAL NOT NULL,
    description  VARCHAR(255),
    status       package_status,

    CONSTRAINT fk_package_source FOREIGN KEY (source)
        REFERENCES location (id),

    CONSTRAINT fk_package_destination FOREIGN KEY (destination)
        REFERENCES location (id),

    CONSTRAINT fk_package_recipient FOREIGN KEY (recipient_id)
        REFERENCES "user" (id),

    CONSTRAINT fk_package_sender FOREIGN KEY (sender_id)
        REFERENCES "user" (id)
);

CREATE TYPE invoice_status AS ENUM (
    'draft',
    'unpaid',
    'paid',
    'canceled',
    'refunded'
    );

CREATE TABLE invoice
(
    id       SERIAL PRIMARY KEY,
    user_id  INTEGER        NOT NULL,
    due_date DATE           NOT NULL,
    amount   DECIMAL        NOT NULL,
    status   invoice_status NOT NULL,

    CONSTRAINT fk_invoice_user FOREIGN KEY (user_id)
        REFERENCES "user" (id)
);

CREATE TABLE invoice_item
(
    id         SERIAL PRIMARY KEY,
    invoice_id INTEGER NOT NULL,
    package_id INTEGER,
    type       VARCHAR(64),
    amount     DECIMAL NOT NULL,
    notes      VARCHAR(255),

    CONSTRAINT fk_invoice_item_invoice FOREIGN KEY (invoice_id)
        REFERENCES invoice (id),

    CONSTRAINT fk_invoice_item_package FOREIGN KEY (package_id)
        REFERENCES package (id)
);

CREATE TABLE travel_plan
(
    id         SERIAL PRIMARY KEY,
    package_id INTEGER NOT NULL,

    CONSTRAINT fk_travel_plan_package FOREIGN KEY (package_id)
        REFERENCES package (id)
);

CREATE TYPE travel_step_status AS ENUM (
    'waiting',
    'in_transit',
    'canceled',
    'redirected',
    'returned',
    'completed'
    );

CREATE TABLE travel_plan_step
(
    id             SERIAL PRIMARY KEY,
    travel_plan_id INTEGER            NOT NULL,
    step_number    INTEGER            NOT NULL,
    step_started   TIMESTAMP,
    step_finished  TIMESTAMP,
    source         INTEGER            NOT NULL,
    destination    INTEGER            NOT NULL,
    notes          TEXT,
    description    VARCHAR(255)       NOT NULL,
    status         travel_step_status NOT NULL,

    CONSTRAINT fk_travel_plan_step_travel_plan FOREIGN KEY (travel_plan_id)
        REFERENCES travel_plan (id)
);

CREATE TYPE truck_status AS ENUM (
    'dispatched',
    'on_hold',
    'sold'
    );

CREATE TABLE truck
(
    id            SERIAL PRIMARY KEY,
    license_plate DECIMAL NOT NULL,
    box_volume    DECIMAL NOT NULL,
    max_weight    INTEGER NOT NULL,
    description   VARCHAR(255),
    status        truck_status
);

CREATE TYPE driver_status AS ENUM (
    'working',
    'not_working',
    'vacation'
    );

CREATE TABLE driver
(
    id                      SERIAL PRIMARY KEY,
    employee_id             INTEGER     NOT NULL,
    driver_license          VARCHAR(64) NOT NULL,
    license_issuer          VARCHAR(32) NOT NULL,
    license_type            VARCHAR(16) NOT NULL,
    license_expiration_date DATE        NOT NULL,
    status                  driver_status,

    CONSTRAINT fk_driver_employee FOREIGN KEY (employee_id)
        REFERENCES employee (id)
);

CREATE TABLE trip
(
    id          SERIAL PRIMARY KEY,
    truck_id    INTEGER NOT NULL,
    driver_id   INTEGER NOT NULL,
    from_id     INTEGER NOT NULL,
    to_id       INTEGER NOT NULL,
    departure   TIMESTAMP,
    arrival     TIMESTAMP,
    description VARCHAR(255),

    CONSTRAINT fk_trip_truck FOREIGN KEY (truck_id)
        REFERENCES truck (id),
    CONSTRAINT fk_trip_driver FOREIGN KEY (driver_id)
        REFERENCES driver (id)
);

CREATE TABLE trip_packages
(
    id         SERIAL PRIMARY KEY,
    trip_id    INTEGER NOT NULL,
    package_id INTEGER NOT NULL,
    step_id    INTEGER NOT NULL,

    CONSTRAINT fk_trip_packages_trip FOREIGN KEY (trip_id)
        REFERENCES trip (id),
    CONSTRAINT fk_trip_packages_package FOREIGN KEY (package_id)
        REFERENCES package (id),
    CONSTRAINT fk_trip_packages_step FOREIGN KEY (step_id)
        REFERENCES travel_plan_step (id)
);

-- ---------------------------------------------- WIP: EDUARDO

-- CREATE TABLE exam
-- (
--     id        SERIAL PRIMARY KEY,
--     driver_id INTEGER NOT NULL,
--
--     CONSTRAINT fk_exam_driver FOREIGN KEY (driver_id)
--         REFERENCES driver (id)
-- );
--
CREATE TABLE document
(
    id          SERIAL PRIMARY KEY,
    file        BYTEA   NOT NULL,
    user_id     INTEGER NOT NULL,
    description VARCHAR(255),

    CONSTRAINT fk_document_user FOREIGN KEY (user_id)
        REFERENCES "user" (id)
);

CREATE TABLE third_company
(
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(255) NOT NULL,
    register    VARCHAR(64)  NOT NULL,
    description VARCHAR(255)
);

CREATE TABLE third_company_contact
(
    id         SERIAL PRIMARY KEY,
    contact_id INTEGER NOT NULL,
    company_id INTEGER NOT NULL,
    notes      VARCHAR(255),

    CONSTRAINT fk_third_company_contact_user FOREIGN KEY (contact_id)
        REFERENCES "user" (id),

    CONSTRAINT fk_third_company_contact_third_company FOREIGN KEY (company_id)
        REFERENCES third_company (id)
);

CREATE TABLE contract
(
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(255) NOT NULL,
    file        BYTEA        NOT NULL,
    description VARCHAR(255),
    start_date  DATE         NOT NULL,
    end_date    DATE         NOT NULL,
    active      BOOLEAN      NOT NULL
);

CREATE TABLE partnership
(
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(255) NOT NULL,
    company_id  INTEGER      NOT NULL,
    contract_id INTEGER      NOT NULL,
    description TEXT         NOT NULL,

    CONSTRAINT fk_partnership_third_company FOREIGN KEY (company_id)
        REFERENCES third_company (id)
);

CREATE TABLE partner_stop_point
(
    id          SERIAL PRIMARY KEY,
    description VARCHAR(255),
    partner_id  INTEGER NOT NULL,
    location_id INTEGER NOT NULL,

    CONSTRAINT fk_partner_stop_point FOREIGN KEY (partner_id)
        REFERENCES partnership (id),

    CONSTRAINT fk_partner_stop_point_location FOREIGN KEY (location_id)
        REFERENCES location (id)
);
