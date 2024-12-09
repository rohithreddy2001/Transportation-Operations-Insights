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
