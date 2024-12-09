SELECT 
    city.city_name,
    MONTHNAME(trips.date) AS month_name,
    COUNT(trips.trip_id) AS actual_trips,
    ROUND(AVG(target_trips.total_target_trips), 0) AS target_trips,
    CASE
        WHEN COUNT(trips.trip_id) > ROUND(AVG(target_trips.total_target_trips), 0) THEN 'Above Target'
        ELSE 'Below Target'
    END AS performance_status,
    CONCAT(ROUND((COUNT(trips.trip_id) - ROUND(AVG(target_trips.total_target_trips), 0)) / ROUND(AVG(target_trips.total_target_trips), 0) * 100, 2), ' %') AS percentage_difference
FROM
    trips_db.dim_city city
        LEFT JOIN
    targets_db.monthly_target_trips target_trips ON city.city_id = target_trips.city_id
        LEFT JOIN
    trips_db.fact_trips trips ON city.city_id = trips.city_id
        AND MONTHNAME(target_trips.date) = MONTHNAME(trips.date)
GROUP BY city.city_name , MONTHNAME(trips.date)
ORDER BY city.city_name;
