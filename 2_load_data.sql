-- 2018_Shipping_Data CSVs Loader Script
COPY headers(identifier,vessel_name,port_of_unlading,estimated_arrival_date,foreign_port_of_lading,manifest_unit,manifest_quantity,weight,port_of_destination,actual_arrival_date)
FROM '/Users/matthew/Desktop/final_silver_layer/header/header_2018.csv'
DELIMITER ','
CSV HEADER;
COPY cargodescs(identifier,container_number,piece_count,description_text)
FROM '/Users/matthew/Desktop/final_silver_layer/cargodesc/cargodesc_2018.csv'
DELIMITER ','
CSV HEADER;
COPY containers(identifier,container_number,container_type,load_status)
FROM '/Users/matthew/Desktop/final_silver_layer/container/container_2018.csv'
DELIMITER ','
CSV HEADER;
COPY shippers(identifier,shipper_party_name,shipper_party_address_1,shipper_party_address_2,shipper_party_address_3,shipper_party_address_4)
FROM '/Users/matthew/Desktop/final_silver_layer/shipper/shipper_2018.csv'
DELIMITER ','
CSV HEADER;



-- 2019_Shipping_Data CSVs Loader Script
COPY headers(identifier,vessel_name,port_of_unlading,estimated_arrival_date,foreign_port_of_lading,manifest_unit,manifest_quantity,weight,port_of_destination,actual_arrival_date)
FROM '/Users/matthew/Desktop/final_silver_layer/header/header_2019.csv'
DELIMITER ','
CSV HEADER;
COPY cargodescs(identifier,container_number,piece_count,description_text)
FROM '/Users/matthew/Desktop/final_silver_layer/cargodesc/cargodesc_2019.csv'
DELIMITER ','
CSV HEADER;
COPY containers(identifier,container_number,container_type,load_status)
FROM '/Users/matthew/Desktop/final_silver_layer/container/container_2019.csv'
DELIMITER ','
CSV HEADER;
COPY shippers(identifier,shipper_party_name,shipper_party_address_1,shipper_party_address_2,shipper_party_address_3,shipper_party_address_4)
FROM '/Users/matthew/Desktop/final_silver_layer/shipper/shipper_2019.csv'
DELIMITER ','
CSV HEADER;



-- 2020_Shipping_Data CSVs Loader Script
COPY headers(identifier,vessel_name,port_of_unlading,estimated_arrival_date,foreign_port_of_lading,manifest_unit,manifest_quantity,weight,port_of_destination,actual_arrival_date)
FROM '/Users/matthew/Desktop/final_silver_layer/header/header_2020.csv'
DELIMITER ','
CSV HEADER;
COPY cargodescs(identifier,container_number,piece_count,description_text)
FROM '/Users/matthew/Desktop/final_silver_layer/cargodesc/cargodesc_2020.csv'
DELIMITER ','
CSV HEADER;
COPY containers(identifier,container_number,container_type,load_status)
FROM '/Users/matthew/Desktop/final_silver_layer/container/container_2020.csv'
DELIMITER ','
CSV HEADER;





