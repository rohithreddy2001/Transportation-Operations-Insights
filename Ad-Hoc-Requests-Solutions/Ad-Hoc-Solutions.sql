-- Business Request - 1

SELECT 
    city.city_name,
    COUNT(trips.trip_id) AS total_trips,
    ROUND(SUM(trips.fare_amount) / SUM(trips.distance_travelled_km),2) AS avg_fare_per_km,
    ROUND(SUM(trips.fare_amount) / COUNT(trips.trip_id),2) AS avg_fare_per_trip,
    CONCAT(ROUND((COUNT(trips.trip_id) / (SELECT COUNT(*) FROM fact_trips)) * 100.0, 2), ' %') AS percentage_contribution_to_total_trips
FROM
    dim_city city
        LEFT JOIN
    fact_trips trips ON city.city_id = trips.city_id
GROUP BY city.city_name;

-- Business Request - 2

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

-- Business Request - 3

SELECT 
    city.city_name,
    ROUND((SUM(CASE
                WHEN repeat_t.trip_count = '2-Trips' THEN repeat_passenger_count
                ELSE 0
            END) / SUM(repeat_t.repeat_passenger_count)) * 100,
            2) AS '2-Trips',
    ROUND((SUM(CASE
                WHEN repeat_t.trip_count = '3-Trips' THEN repeat_passenger_count
                ELSE 0
            END) / SUM(repeat_t.repeat_passenger_count)) * 100,
            2) AS '3-Trips',
    ROUND((SUM(CASE
                WHEN repeat_t.trip_count = '4-Trips' THEN repeat_passenger_count
                ELSE 0
            END) / SUM(repeat_t.repeat_passenger_count)) * 100,
            2) AS '4-Trips',
    ROUND((SUM(CASE
                WHEN repeat_t.trip_count = '5-Trips' THEN repeat_passenger_count
                ELSE 0
            END) / SUM(repeat_t.repeat_passenger_count)) * 100,
            2) AS '5-Trips',
    ROUND((SUM(CASE
                WHEN repeat_t.trip_count = '6-Trips' THEN repeat_passenger_count
                ELSE 0
            END) / SUM(repeat_t.repeat_passenger_count)) * 100,
            2) AS '6-Trips',
    ROUND((SUM(CASE
                WHEN repeat_t.trip_count = '7-Trips' THEN repeat_passenger_count
                ELSE 0
            END) / SUM(repeat_t.repeat_passenger_count)) * 100,
            2) AS '7-Trips',
    ROUND((SUM(CASE
                WHEN repeat_t.trip_count = '8-Trips' THEN repeat_passenger_count
                ELSE 0
            END) / SUM(repeat_t.repeat_passenger_count)) * 100,
            2) AS '8-Trips',
    ROUND((SUM(CASE
                WHEN repeat_t.trip_count = '9-Trips' THEN repeat_passenger_count
                ELSE 0
            END) / SUM(repeat_t.repeat_passenger_count)) * 100,
            2) AS '9-Trips',
    ROUND((SUM(CASE
                WHEN repeat_t.trip_count = '10-Trips' THEN repeat_passenger_count
                ELSE 0
            END) / SUM(repeat_t.repeat_passenger_count)) * 100,
            2) AS '10-Trips'
FROM
    dim_city city
        LEFT JOIN
    dim_repeat_trip_distribution repeat_t ON city.city_id = repeat_t.city_id
GROUP BY city.city_name;

-- Business Request - 4

WITH Top AS (SELECT 
    city.city_name, SUM(passenger.new_passengers) AS total_new_passengers,
    DENSE_RANK() OVER(ORDER BY SUM(passenger.new_passengers) DESC) AS ranking
FROM
    dim_city city
        LEFT JOIN
    fact_passenger_summary passenger ON city.city_id = passenger.city_id
GROUP BY city.city_name
),
Bottom AS (SELECT 
    city.city_name, SUM(passenger.new_passengers) AS total_new_passengers,
    DENSE_RANK() OVER(ORDER BY SUM(passenger.new_passengers) ASC) AS ranking
FROM
    dim_city city
        LEFT JOIN
    fact_passenger_summary passenger ON city.city_id = passenger.city_id
GROUP BY city.city_name
)
SELECT 
    Top.city_name,
    Top.total_new_passengers,
    CASE
        WHEN Top.ranking <= 3 THEN 'Top 3'
        WHEN Bottom.ranking <= 3 THEN 'Bottom 3'
    END AS city_category
FROM
    Top
        JOIN
    Bottom USING (city_name)
WHERE
    Top.ranking <= 3 OR Bottom.ranking <= 3;
    
-- Business Request - 5

WITH highest AS (
    SELECT 
        city.city_name, 
        MONTHNAME(trips.date) AS highest_revenue_month, 
        SUM(trips.fare_amount) AS revenue, 
        DENSE_RANK() OVER (
            PARTITION BY city.city_name 
            ORDER BY SUM(trips.fare_amount) DESC
        ) AS ranking
    FROM 
        dim_city city
    LEFT JOIN 
        fact_trips trips 
    USING (city_id)
    GROUP BY 
        city.city_name, 
        MONTHNAME(trips.date)
), 
city_revenue AS (
    SELECT 
        city.city_name, 
        SUM(trips.fare_amount) AS total_revenue
    FROM 
        dim_city city
    LEFT JOIN 
        fact_trips trips 
    USING (city_id)
    GROUP BY 
        city.city_name
)
SELECT 
    highest.city_name, 
    highest.highest_revenue_month, 
    highest.revenue,
    ROUND((highest.revenue / city_revenue.total_revenue) * 100, 2) AS percentage_contribution
FROM 
    highest
JOIN 
    city_revenue 
USING (city_name)
WHERE 
    ranking = 1;

-- Business Request - 6

WITH monthy_repeat_passengers AS (SELECT 
    city.city_name,
    MONTHNAME(passenger.month) AS month,
    SUM(passenger.total_passengers) AS total_passengers,
    SUM(passenger.repeat_passengers) AS repeat_passengers
FROM
    dim_city city
        LEFT JOIN
    fact_passenger_summary passenger USING (city_id)
GROUP BY city.city_name , MONTHNAME(passenger.month)
),
city_repeat_passengers AS (
SELECT 
    city.city_name,
    SUM(passengers.repeat_passengers) AS total_repeat_passengers,
    SUM(passengers.total_passengers) AS total_passengers,
    ROUND((SUM(passengers.repeat_passengers) / SUM(passengers.total_passengers)) * 100,
            2) AS city_repeat_passenger_rate
FROM
    dim_city city
        LEFT JOIN
    fact_passenger_summary passengers USING (city_id)
GROUP BY city.city_name
)

SELECT 
    monthly.city_name,
    monthly.month,
    monthly.total_passengers,
    monthly.repeat_passengers,
    ROUND((monthly.repeat_passengers / monthly.total_passengers) * 100,
            2) AS monthly_repeat_passenger_rate,
    city.city_repeat_passenger_rate
FROM
    monthy_repeat_passengers monthly
        JOIN
    city_repeat_passengers city USING (city_name);



