DROP TABLE IF EXISTS containers CASCADE;
DROP TABLE IF EXISTS headers CASCADE;
DROP TABLE IF EXISTS cargodescs CASCADE;
DROP TABLE IF EXISTS shippers CASCADE;

CREATE TABLE headers (
	identifier BIGINT PRIMARY KEY UNIQUE,
	vessel_name VARCHAR(100),
	port_of_unlading VARCHAR(200),
	estimated_arrival_date VARCHAR(200),
	foreign_port_of_lading VARCHAR(200),
	manifest_unit VARCHAR(200),
	manifest_quantity BIGINT,
	weight BIGINT,
	port_of_destination VARCHAR(200),
	actual_arrival_date VARCHAR(200)
);
CREATE TABLE containers (
	identifier BIGINT PRIMARY KEY,
	container_number VARCHAR(100),
	container_type VARCHAR(200),
	load_status VARCHAR(200),
	CONSTRAINT fk_headers_identifier
		FOREIGN KEY(identifier)
			REFERENCES headers(identifier)
);
CREATE TABLE cargodescs (
	identifier BIGINT PRIMARY KEY,
	container_number VARCHAR(100),
	piece_count FLOAT,
	description_text VARCHAR(400),
	CONSTRAINT fk_headers_identifier
		FOREIGN KEY(identifier)
			REFERENCES headers(identifier)
);
CREATE TABLE shippers (
	identifier BIGINT PRIMARY KEY,
	shipper_party_name VARCHAR(200),
	shipper_party_address_1 VARCHAR(200),
	shipper_party_address_2 VARCHAR(200),
	shipper_party_address_3 VARCHAR(200),
	shipper_party_address_4 VARCHAR(200),
	CONSTRAINT fk_headers_identifier
		FOREIGN KEY(identifier)
			REFERENCES headers(identifier)
);