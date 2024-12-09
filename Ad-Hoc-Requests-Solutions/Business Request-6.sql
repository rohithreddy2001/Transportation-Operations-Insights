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