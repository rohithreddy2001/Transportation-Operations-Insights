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