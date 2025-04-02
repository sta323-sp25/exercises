SELECT count(*) 
FROM read_parquet("/data/nyctaxi/yellow_*.parquet");

DESCRIBE SELECT *
FROM read_parquet("/data/nyctaxi/yellow_*.parquet");

## Tip percentage

SELECT AVG(tip_amount / fare_amount), payment_type 
FROM read_parquet("/data/nyctaxi/yellow_*.parquet")
GROUP BY payment_type
ORDER by payment_type;

SUMMARIZE SELECT fare_amount 
FROM  read_parquet("/data/nyctaxi/yellow_*.parquet");

SELECT ROUND(AVG(tip_amount / fare_amount),4), payment_type 
FROM read_parquet("/data/nyctaxi/yellow_*.parquet")
WHERE tip_amount >= 0 AND fare_amount > 0
GROUP BY payment_type
ORDER by payment_type;

EXPLAIN ANALYZE SELECT ROUND(AVG(tip_amount / fare_amount),4), payment_type 
FROM read_parquet("/data/nyctaxi/yellow_*.parquet")
WHERE tip_amount >= 0 AND fare_amount > 0
GROUP BY payment_type
ORDER by payment_type;




CREATE VIEW taxi AS SELECT * 
FROM read_parquet("/data/nyctaxi/yellow_*.parquet");

SELECT * FROM (
  SELECT 
    PULocationID pickup_zone,
    AVG(fare_amount / trip_distance) fare_per_mile,
    COUNT(*) num_rides 
  FROM taxi
  WHERE trip_distance > 0
  GROUP BY PULocationID
  ORDER BY PULocationID
) NATURAL LEFT JOIN (
 SELECT LocationID AS pickup_zone, * FROM read_csv("/data/nyctaxi/taxi_zone_lookup.csv")
) ORDER BY fare_per_mile DESC;

