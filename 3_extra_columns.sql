-- Adding Column to Tables for Understanding Queries Better
ALTER TABLE headers ALTER COLUMN 
shipment_month TYPE varchar(10);

ALTER TABLE headers ADD COLUMN
shipment_year INT NULL;

ALTER TABLE headers ADD COLUMN
was_late BOOLEAN NULL;

-- Inserting Data Into New Columns
UPDATE headers
SET shipment_month = TO_CHAR(estimated_arrival_date::timestamp, 'Month');

UPDATE headers
SET shipment_year = DATE_PART('year', estimated_arrival_date::timestamp);

UPDATE headers
SET was_late = TRUE
WHERE identifier IN (
	SELECT h.identifier
	FROM headers h
	WHERE to_date(h.estimated_arrival_date, 'yyyy-MM-DD') < to_date(h.actual_arrival_date, 'yyyy-MM-DD')
	AND h.estimated_arrival_date::timestamp > '2017-12-31'::timestamp
	AND h.estimated_arrival_date::timestamp < '2021-01-01'::timestamp
);
UPDATE headers
SET was_late = false
WHERE was_late IS NULL;



-- Adding Indexes
-- 30 seconds improvement
CREATE INDEX idx_headers_actual_arrival_date
ON headers(actual_arrival_date);

CREATE INDEX idx_headers_estimated_arrival_date
ON headers(estimated_arrival_date);
