SELECT * FROM view_query_3;

-- Database is used to provide aggregated analysis on the port shipment timeliness
-- and port accountability.

-- 1. Which months experienced the most shipment delays for each year?
-- 2. Which port receives the most shipments during (MONTHS FROM QUESTION 1)?
-- 3. How many shipments were late per year?  How many late deliveries by per vendor?
-- 4. What percentage of shipments were late for all 3 years?
-- 5. How late are late shipments on average?
-- 6. Which port outputs the most shipments?
-- 7. What are the top 3 Ports by Traffic for Each Month?
-- 8. Which out port creates the most late shipments for 2020?
-- 9. Which port receives the most late shipments?
-- 10. By how much did timeliness improve from 2019 to 2020?



-- 1. Which months experienced the most shipment delays?
-- A: August, December, and October
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

-- Improved Query 1
SELECT h.shipment_month, h.shipment_year, COUNT(identifier) as late_shipments
FROM headers h
WHERE h.was_late=true
GROUP BY h.shipment_month, h.shipment_year
ORDER BY late_shipments DESC
LIMIT 3;



-- 2. Which port receives the most shipments during August, December, and October?
-- A: Los Angeles, California
SELECT DATE_PART('month', estimated_arrival_date::timestamp) AS shipment_month,
		port_of_unlading,
		COUNT(estimated_arrival_date) as number_of_shipments
FROM (
	SELECT h.identifier, h.port_of_unlading, h.estimated_arrival_date, h.actual_arrival_date,
		h.actual_arrival_date::timestamp - h.estimated_arrival_date::timestamp AS days_late
	FROM headers h
	WHERE h.estimated_arrival_date::timestamp > '2017-12-31'::timestamp
		AND h.estimated_arrival_date::timestamp < '2021-01-01'::timestamp
) sq
WHERE DATE_PART('month', estimated_arrival_date::timestamp) IN (8, 12, 10)
GROUP BY DATE_PART('month', estimated_arrival_date::timestamp), port_of_unlading
ORDER BY number_of_shipments DESC
LIMIT 10;



-- 3. How many shipments were late per year?  How many late deliveries by per vendor?
-- A: 2018: 12,123,046,  2019: 10,044,505,  2020: 8,134,386
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



-- 4. What percentage of shipments were late for all 3 years?
-- A: 56.26%
WITH late_count AS
(
	SELECT COUNT(*) AS late FROM (
		SELECT h.identifier, h.port_of_unlading, h.estimated_arrival_date, h.actual_arrival_date,
			h.actual_arrival_date::timestamp - h.estimated_arrival_date::timestamp AS days_late
		FROM headers h
		WHERE to_date(h.estimated_arrival_date, 'yyyy-MM-DD') < to_date(h.actual_arrival_date, 'yyyy-MM-DD')
		AND h.estimated_arrival_date::timestamp > '2017-12-31'::timestamp
		AND h.estimated_arrival_date::timestamp < '2021-01-01'::timestamp
) sq),
total_count AS
(
	SELECT COUNT(*) AS total
	FROM headers h
	WHERE h.estimated_arrival_date::timestamp > '2017-12-31'::timestamp
		AND h.estimated_arrival_date::timestamp < '2021-01-01'::timestamp
)
SELECT ROUND(late::numeric * 100 / total::numeric, 2) AS percent
FROM late_count, total_count;



-- 5. How late are late shipments on average?
-- A: 3 Days
SELECT AVG(days_late) FROM (
	SELECT h.identifier, h.port_of_unlading, h.estimated_arrival_date, h.actual_arrival_date,
		h.actual_arrival_date::timestamp - h.estimated_arrival_date::timestamp AS days_late
	FROM headers h
	WHERE to_date(h.estimated_arrival_date, 'yyyy-MM-DD') < to_date(h.actual_arrival_date, 'yyyy-MM-DD')
	AND h.estimated_arrival_date::timestamp > '2019-12-31'::timestamp
	AND h.estimated_arrival_date::timestamp < '2021-01-01'::timestamp
) sq



-- 6. Which port outputs the most shipments per year?
-- A: Shanghai & Yantian
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



-- 7. What are the top 3 Ports by Traffic for Each Month in 2019?
-- A: 1:00 to Run
-- Top 3 Ports per Month
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



-- 8. Which out port puts out the most late shipments for 2020?
-- A: Shanghai, China (Mainland) with 30,260 Shipments
SELECT foreign_port_of_lading, COUNT(foreign_port_of_lading) AS num_shipments
FROM (
	SELECT h.foreign_port_of_lading,
		h.actual_arrival_date::timestamp - h.estimated_arrival_date::timestamp AS days_late
	FROM headers h
	WHERE h.estimated_arrival_date::timestamp > '2017-12-31'::timestamp
		AND h.estimated_arrival_date::timestamp < '2021-01-01'::timestamp
	GROUP BY foreign_port_of_lading, h.estimated_arrival_date, h.actual_arrival_date
	ORDER BY days_late DESC
) sq
GROUP BY foreign_port_of_lading
ORDER BY num_shipments DESC
LIMIT 1;



-- 9. Which port receives the most late shipments?
-- A: New York/Newark Area
SELECT port_of_unlading, COUNT(*) AS late_shipments FROM (
	SELECT h.identifier, h.port_of_unlading, h.estimated_arrival_date, h.actual_arrival_date,
		h.actual_arrival_date::timestamp - h.estimated_arrival_date::timestamp AS days_late
	FROM headers h
	WHERE to_date(h.estimated_arrival_date, 'yyyy-MM-DD') < to_date(h.actual_arrival_date, 'yyyy-MM-DD')
	AND h.estimated_arrival_date::timestamp > '2017-12-31'::timestamp
	AND h.estimated_arrival_date::timestamp < '2021-01-01'::timestamp
) sq
GROUP BY port_of_unlading
ORDER BY late_shipments DESC
LIMIT 3;



-- 10. By how much did timeliness improve in 2020 compared to 2019?
-- A: 6 hours, 25 minutes faster
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


