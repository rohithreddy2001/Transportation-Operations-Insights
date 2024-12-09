create table monthly_performance_vs_target_for_new_passengers as (
SELECT 
    city.city_name,
    MONTHNAME(passengers.month) AS month_name,
    SUM(passengers.new_passengers) AS total_new_passengers,
    ROUND(AVG(target_passengers.target_new_passengers), 0) AS target_new_passengers,
    CASE
        WHEN SUM(passengers.new_passengers) > ROUND(AVG(target_passengers.target_new_passengers), 0) THEN 'Target Exceeded'
        WHEN SUM(passengers.new_passengers) < ROUND(AVG(target_passengers.target_new_passengers), 0) THEN 'Target Missed'
        ELSE 'Target Met'
    END AS performance_status,
    CONCAT(ROUND(
        ((SUM(passengers.new_passengers) - ROUND(AVG(target_passengers.target_new_passengers), 0)) 
        / ROUND(AVG(target_passengers.target_new_passengers), 0)) * 100, 2), ' %') AS percentage_difference
FROM
    trips_db.dim_city city
        LEFT JOIN
    targets_db.monthly_target_new_passengers target_passengers ON city.city_id = target_passengers.city_id
        LEFT JOIN
    trips_db.fact_passenger_summary passengers ON city.city_id = passengers.city_id
        AND MONTHNAME(passengers.month) = MONTHNAME(target_passengers.month)
GROUP BY city.city_name , MONTHNAME(passengers.month)
ORDER BY city.city_name
)