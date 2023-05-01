-- QUERY 1. Which months experienced the most shipment delays?
SELECT shipment_month, shipment_year, late_shipments FROM view_query_1;

-- QUERY 3. How many shipments were late per year?  How many late deliveries by per vendor?
SELECT * FROM view_query_3;

-- QUERY 4. What percentage of shipments were late for all 3 years?
SELECT percent FROM view_query_4;

-- QUERY 6. Which port outputs the most shipments per year?
SELECT avg FROM view_query_6;

-- QUERY 7. What are the top 3 Ports by Traffic for Each Month in 2019?
-- RUN ME -> 1:00 to Complete
SELECT * FROM view_query_7;

-- QUERY 10. By how much did timeliness improve in 2020 compared to 2019?
SELECT average19, average20, improvement FROM view_query_10;



-- 1. Which months experienced the most shipment delays?
CREATE OR REPLACE VIEW view_query_1 AS
	SELECT DATE_PART('month', estimated_arrival_date::timestamp) AS shipment_month,
			DATE_PART('year', estimated_arrival_date::timestamp) AS shipment_year,
			COUNT(identifier) AS late_shipments
	FROM (
		SELECT h.identifier, h.port_of_unlading, h.estimated_arrival_date, h.actual_arrival_date,
			h.actual_arrival_date::timestamp - h.estimated_arrival_date::timestamp AS days_late
		FROM headers h
		WHERE to_date(h.estimated_arrival_date, 'yyyy-MM-DD') < to_date(h.actual_arrival_date, 'yyyy-MM-DD')
		AND h.estimated_arrival_date::timestamp > '2017-12-31'::timestamp
		AND h.estimated_arrival_date::timestamp < '2021-01-01'::timestamp
	) sq
	GROUP BY DATE_PART('year', estimated_arrival_date::timestamp), DATE_PART('month', estimated_arrival_date::timestamp)
	ORDER BY late_shipments DESC
	LIMIT 3;



-- 3. How many shipments were late per year?  How many late deliveries by per vendor?
CREATE OR REPLACE VIEW view_query_3 AS
	SELECT sq.port_of_unlading, sq.shipment_year, sq.trips,
			SUM(sq.trips) OVER (PARTITION BY sq.shipment_year
							   ORDER BY sq.shipment_year, sq.trips
							   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulation
	FROM (
		SELECT h.port_of_unlading, h.shipment_year, COUNT(h.identifier) AS trips
		FROM headers h
		WHERE h.shipment_year IN ('2018', '2019', '2020')
			AND was_late = true
		GROUP BY h.shipment_year, h.port_of_unlading) sq
	GROUP BY sq.shipment_year, sq.trips, sq.port_of_unlading
	ORDER BY sq.shipment_year, sq.trips



-- Creating a View for Query 4: What percentage of shipments were late for all 3 years?
CREATE OR REPLACE VIEW view_query_4 AS
	WITH late_count AS
	(
		SELECT COUNT(identifier) AS late FROM (
			SELECT h.identifier, h.port_of_unlading, h.estimated_arrival_date, h.actual_arrival_date,
				h.actual_arrival_date::timestamp - h.estimated_arrival_date::timestamp AS days_late
			FROM headers h
			WHERE to_date(h.estimated_arrival_date, 'yyyy-MM-DD') < to_date(h.actual_arrival_date, 'yyyy-MM-DD')
			AND h.estimated_arrival_date::timestamp > '2017-12-31'::timestamp
			AND h.estimated_arrival_date::timestamp < '2021-01-01'::timestamp
	) sq),
	total_count AS
	(
		SELECT COUNT(identifier) AS total
		FROM headers h
		WHERE h.estimated_arrival_date::timestamp > '2017-12-31'::timestamp
			AND h.estimated_arrival_date::timestamp < '2021-01-01'::timestamp
	)
	SELECT ROUND(late::numeric * 100 / total::numeric, 2) AS percent
	FROM late_count, total_count;
	
	
-- SIMPLER version of Query 4
-- CREATE OR REPLACE VIEW view_query_4 AS
-- 	WITH late_count AS(
-- 		SELECT COUNT(identifier) AS late
-- 		FROM headers
-- 		WHERE was_late = true),
-- 		total_count AS(
-- 		SELECT COUNT(identifier) AS total
-- 		FROM headers)
-- 	SELECT ROUND(late * 100 / total, 2) AS percent
-- 	FROM late_count, total_count;


-- 6. Which port outputs the most shipments per year?
CREATE OR REPLACE VIEW view_query_6 AS
	SELECT sq2.*
	FROM (
		SELECT sq.foreign_port_of_lading, sq.shipment_year, sq.shipments,
				rank() OVER (PARTITION BY sq.shipment_year ORDER BY shipments DESC) AS rnk
		FROM (
			SELECT h.foreign_port_of_lading, h.shipment_year, COUNT(h.identifier) AS shipments
			FROM headers h
			WHERE h.shipment_year IN ('2018', '2019', '2020')
			GROUP BY h.foreign_port_of_lading, h.shipment_year
			ORDER BY h.shipment_year, shipments DESC
			) sq
		GROUP BY sq.foreign_port_of_lading, sq.shipment_year, sq.shipments
		ORDER BY sq.shipment_year, sq.shipments DESC
		) sq2
	WHERE sq2.rnk < 2



-- 7. What are the top 3 Ports by Traffic for Each Month?
CREATE OR REPLACE VIEW view_query_7 AS
	SELECT sq2.* FROM (
		SELECT sq.port_of_unlading, sq.month, sq.trips,
				rank() OVER (PARTITION BY sq.month ORDER BY trips DESC) as rnk
		FROM (
			SELECT port_of_unlading, TO_CHAR(estimated_arrival_date::timestamp, 'Month') as month,
				count(port_of_unlading) AS trips
			FROM headers
			WHERE shipment_year = '2019'
			GROUP BY port_of_unlading, TO_CHAR(estimated_arrival_date::timestamp, 'Month')
			) sq
		GROUP BY sq.port_of_unlading, sq.month, sq.trips
	) sq2
	WHERE rnk < 4
	GROUP BY sq2.port_of_unlading, sq2.month, sq2.trips, sq2.rnk
	ORDER BY sq2.month, rnk



-- Creating a View for Query 10: By how much did timeliness improve in 2020 compared to 2019?
CREATE OR REPLACE VIEW view_query_10 AS
	SELECT sq.average19, sq2.average20, sq.average19 - sq2.average20 AS improvement
	FROM (
		SELECT AVG(days_late) as average19 FROM (
			SELECT h.identifier, h.port_of_unlading, h.estimated_arrival_date, h.actual_arrival_date,
				h.actual_arrival_date::timestamp - h.estimated_arrival_date::timestamp AS days_late
			FROM headers h
			WHERE to_date(h.estimated_arrival_date, 'yyyy-MM-DD') < to_date(h.actual_arrival_date, 'yyyy-MM-DD')
			AND h.estimated_arrival_date::timestamp > '2018-12-31'::timestamp
			AND h.estimated_arrival_date::timestamp < '2020-01-01'::timestamp
		) ssq
	) sq,
	(
		SELECT AVG(days_late) as average20  FROM (
			SELECT h.identifier, h.port_of_unlading, h.estimated_arrival_date, h.actual_arrival_date,
				h.actual_arrival_date::timestamp - h.estimated_arrival_date::timestamp AS days_late
			FROM headers h
			WHERE to_date(h.estimated_arrival_date, 'yyyy-MM-DD') < to_date(h.actual_arrival_date, 'yyyy-MM-DD')
			AND h.estimated_arrival_date::timestamp > '2019-12-31'::timestamp
			AND h.estimated_arrival_date::timestamp < '2021-01-01'::timestamp
		) ssq2
	) sq2;