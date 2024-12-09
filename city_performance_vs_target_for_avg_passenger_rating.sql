create table city_performance_vs_target_for_avg_passenger_rating as (
SELECT 
    city.city_name,
    ROUND(AVG(trips.passenger_rating),2) AS avg_passenger_rating,
    ROUND(AVG(target_rating.target_avg_passenger_rating), 2) AS target_avg_passenger_rating,
    CASE
        WHEN AVG(trips.passenger_rating) > ROUND(AVG(target_rating.target_avg_passenger_rating), 1) THEN 'Target Exceeded'
        WHEN AVG(trips.passenger_rating) < ROUND(AVG(target_rating.target_avg_passenger_rating), 1) THEN 'Target Missed'
        ELSE 'Target Met'
    END AS performance_status,
    CONCAT(ROUND(
        ((AVG(trips.passenger_rating) - ROUND(AVG(target_rating.target_avg_passenger_rating), 1))
        / ROUND(AVG(target_rating.target_avg_passenger_rating), 1)) * 100, 2), ' %') AS percentage_difference
FROM
    trips_db.dim_city city
        LEFT JOIN
    targets_db.city_target_passenger_rating target_rating ON city.city_id = target_rating.city_id
        LEFT JOIN
    trips_db.fact_trips trips ON city.city_id = trips.city_id
GROUP BY city.city_name 
ORDER BY city.city_name
)