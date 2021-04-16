/*
TODO LIST:

	EDUARDO:
      exames do motorista,
      documentos do motorista,
      contratos,
      parcerias,
      voucher,
      stops,
    
    PEDRO:
      valor_do_frete,
      fatura,
      itens da fatura,
      funcionarios, departamentos e salarios, (FEITO)
      pagamento de funcionarios,
      controle_de_entrada,
      horario_de_trabalho,
  
Acertar relacionamentos e revisar normalização
*/

CREATE TABLE city (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    zipcode VARCHAR(8)
);

CREATE TABLE location (
    id SERIAL PRIMARY KEY,
    primary_address TEXT NOT NULL,
    secondary_address TEXT,
    neighborhood VARCHAR(100),
  	zipcode VARCHAR(8),
    city INTEGER NOT NULL,
    state VARCHAR(2) NOT NULL,
    geolocation GEOMETRY NOT NULL,
    
    CONSTRAINT fk_location_city FOREIGN KEY (city)
        REFERENCES city (id)
);

CREATE TABLE role (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE user (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    role_id INTEGER NOT NULL,
    email VARCHAR(255) NOT NULL,
    enabled BOOLEAN NOT NULL,
    cpf VARCHAR(16) NOT NULL,
    
    CONSTRAINT fk_user_role FOREIGN KEY (role_id)
        REFERENCES role (id)
);

CREATE TYPE contact_phone_type AS ENUM(
    'cellphone',
    'residential',
    'work'
);

CREATE TABLE contact_phone(
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    type contact_phone_type NOT NULL,
    number VARCHAR(64) NOT NULL,
    
    CONSTRAINT fk_phone_user FOREIGN KEY (user_id)
        REFERENCES user (id)
);

CREATE TABLE employee (
	id SERIAL PRIMARY KEY,
  	user_id INTEGER NOT NULL,
  	hire_date DATE NOT NULL,
  	demission_date DATE NOT NULL,
);

CREATE TABLE department (
	id SERIAL PRIMARY KEY,
  	agency_id INTEGER NOT NULL,
  	name VARCHAR(128) NOT NULL,
  
  	CONSTRAINT fk_department_agency FOREIGN KEY
  		REFERENCES agency (id)
);

CREATE TABLE departament_manager (
	id SERIAL NOT NULL,
	employee_id INTEGER NOT NULL,
   	department_id INTEGER NOT NULL,
   	from_date DATE NOT NULL,
   	to_date DATE,
  
   	CONSTRAINT fk_department_manager_employee FOREIGN KEY (employee_id)
  		REFERENCES employee (id),
  
   	CONSTRAINT fk_department_manager_department FOREIGN KEY (department_id) 
  		REFERENCES department (id)
); 

CREATE TABLE employee_department (
  	id SERIAL NOT NULL,
    employee_id INTEGER NOT NULL,
    department_id INTEGER NOT NULL,
   	from_date DATE NOT NULL,
   	to_date DATE,
  
   	CONSTRAINT fk_employe_department_employee FOREIGN KEY (employee_id)
  		REFERENCES employee (id),
  
   	CONSTRAINT fk_employee_department_department FOREIGN KEY (department_id) 
  		REFERENCES department (id)
);

CREATE TABLE salaries (
	id INTEGER NOT NULL,
  	employee_id INTEGER NOT NULL,
  	salary DECIMAL NOT NULL,
    from_date DATE NOT NULL,
   	to_date DATE,
  
    CONSTRAINT fk_employe_department_employee FOREIGN KEY (employee_id)
      REFERENCES employee (id),
);

-- Para o Pedro do futuro: Fazer tabela de salários pagos

CREATE TYPE package_status AS ENUM (
    'delivered',
    'refused',
    'returned',
    'posted',
    'in_transit',
    'lost'
);

CREATE TABLE package (
    id SERIAL PRIMARY KEY,
    recipient_id INTEGER NOT NULL,
    sender_id INTEGER NOT NULL,
    due_date DATE NOT NULL,
  	source INTEGER NOT NULL,
  	destination INTEGER NOT NULL,
    x_size DECIMAL NOT NULL,
    y_size DECIMAL NOT NULL,
    z_size DECIMAL NOT NULL,
    weight DECIMAL NOT NULL,
    description VARCHAR(255),
  	status package_status,	
  	
	CONSTRAINT fk_package_source FOREIGN KEY (source)
  		REFERENCES location (id),
  
  	CONSTRAINT fk_package_destination FOREIGN KEY (destination)
  		REFERENCES location (id),
  
  	CONSTRAINT fk_package_recipient FOREIGN KEY (recipient_id)
        REFERENCES user (id),

  	CONSTRAINT fk_package_sender FOREIGN KEY (sender_id)
        REFERENCES user (id)
);

CREATE TABLE agency (
    id SERIAL PRIMARY KEY,
    location INTEGER NOT NULL,
    owner INTEGER NOT NULL,
    
    CONSTRAINT fk_owner_user FOREIGN KEY (owner) 
        REFERENCES user (id)
);

CREATE TABLE travel_plan (
    id SERIAL PRIMARY KEY,
    package_id INTEGER NOT NULL,
  	
  	CONSTRAINT fk_travel_plan_package FOREIGN KEY (package_id)
  		REFERENCES package (id)
);

CREATE TYPE travel_step_status AS ENUM(
    'waiting',
    'in_transit',
    'canceled',
    'redirected',
    'returned',
    'completed'
);

CREATE TABLE travel_plan_step (
    id SERIAL NOT NULL,
    travel_plan_id INTEGER NOT NULL,
    step_number INTEGER NOT NULL,
    step_started DATETIME,
    step_finished DATETIME,
    source INTEGER NOT NULL,
    destination INTEGER NOT NULL,
    notes TEXT,
    description VARCHAR(255) NOT NULL,
    status travel_step_status NOT NULL,
    
    CONSTRAINT fk_travel_plan_step_travel_plan FOREIGN KEY (travel_plan_id)
        REFERENCES travel_plan (id)
);

CREATE TYPE truck_status AS ENUM(
    'dispatched',
    'on_hold',
    'sold'
);

CREATE TABLE truck (
    id SERIAL PRIMARY KEY,
    bed_volume DECIMAL NOT NULL,
    max_weight INTEGER NOT NULL,
    description VARCHAR(255),
    status truck_status
);

CREATE TYPE driver_status AS ENUM (
    'working',
    'not_working',
    'vacation'
);

CREATE TABLE driver (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
  	status driver_status
);

CREATE TABLE trip (
    id SERIAL PRIMARY KEY,
    truck_id INTEGER NOT NULL,
  	driver_id INTEGER NOT NULL,
    from_id INTEGER NOT NULL,
    to_id INTEGER NOT NULL,
    description VARCHAR(255),
    
    CONSTRAINT fk_trip_truck FOREIGN KEY (truck_id)
        REFERENCES truck (id),
  	CONSTRAINT fk_trip_driver FOREIGN KEY (driver_id)
        REFERENCES driver (id)
);

CREATE TABLE trip_packages (
    id SERIAL PRIMARY KEY,
    trip_id,
    package_id,
    step_id,
);

-- ---------------------------------------------- WIP: EDUARDO

CREATE TABLE exam {
    id SERIAL PRIMARY KEY,
    driver_id INTEGER NOT NULL,

    CONSTRAINT fk_exam_driver FOREIGN KEY (driver_id)
        REFERENCES driver (id)
}

CREATE TABLE document {
    id SERIAL PRIMARY KEY,
    file BYTEA NOT NULL,
    user_id INTEGER NOT NULL,
    description VARCHAR(255),

    CONSTRAINT fk_document_user FOREIGN KEY (user_id)
        REFERENCES user (id)
}

CREATE TABLE contract {
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    file BYTEA NOT NULL,
    description VARCHAR(255),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
}

CREATE TABLE company {
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(255),
}

CREATE TABLE partnership {
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    company_id INTEGER NOT NULL,
    description VARCHAR(255) NOT NULL,

    CONSTRAINT fk_partnership_company FOREIGN KEY (company_id)
        REFERENCES company (id)
}

CREATE TABLE voucher {
    id SERIAL PRIMARY KEY,
    driver_id INTEGER NOT NULL,
    description VARCHAR(255),
    value INTEGER NOT NULL,
}

CREATE TABLE stop {
    id SERIAL PRIMARY KEY,
    description VARCHAR(255),
    location_id INTEGER NOT NULL,
}
