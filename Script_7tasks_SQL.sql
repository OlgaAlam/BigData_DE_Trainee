--Task 1. Output the number of movies in each category, sorted descending
SELECT 
  c.name, 
  count(film_id) AS num_films
FROM 
  category c INNER JOIN film_category fc ON c.category_id = fc.category_id 
GROUP BY fc.category_id, c.name
ORDER BY num_films DESC;


--Task 2. Output the 10 actors whose movies rented the most, sorted in descending order.
WITH most_rented AS (
    SELECT  
        a.actor_id,
        a.first_name,
        a.last_name,
        COUNT(*) AS rental_count
    FROM actor a
       JOIN film_actor fa ON a.actor_id = fa.actor_id
       JOIN film f ON fa.film_id = f.film_id
       JOIN inventory i ON f.film_id = i.film_id
       JOIN rental r ON i.inventory_id = r.inventory_id
    GROUP BY a.actor_id, a.first_name, a.last_name
    ORDER BY rental_count DESC 
    )
SELECT 
    first_name,
    last_name
FROM most_rented
LIMIT 10;


--Task 3. Output the category of movies on which the most money was spent
WITH cost_max AS (
    SELECT 
      c.name, 
      sum(f.replacement_cost) AS cost
    FROM
       film f 
       JOIN film_category fc ON f.film_id = fc.film_id 
       JOIN category c ON fc.category_id = c.category_id
    GROUP BY 
       c.category_id,
       c.name
    ORDER BY cost DESC
    )
SELECT name
FROM cost_max
LIMIT 1;


--Task 4. Print the names of movies that are not in the inventory. 
-- Write a query without using the IN operator.
SELECT
   f.title
FROM 
   film f
WHERE NOT EXISTS
   (
    SELECT * FROM inventory i
    WHERE f.film_id = i.film_id
   );


--Task 5. Output the top 3 actors who have appeared the most in movies in the “Children” category. 
-- If several actors have the same number of movies, output all of them.
WITH most_child AS (
    SELECT
	  a.first_name,
      a.last_name,
	  dense_rank() OVER (ORDER BY count(*) DESC) AS rank_actors
    FROM
	  actor a
      JOIN film_actor fa ON a.actor_id = fa.actor_id
      JOIN film_category fc ON fa.film_id = fc.film_id
      JOIN category c ON fc.category_id = c.category_id
   WHERE
	    c.name = 'Children'
   GROUP BY
	    a.first_name,
	    a.last_name,
	    a.actor_id,
	    c.name
	)
SELECT
	first_name,
	last_name
FROM
	most_child
WHERE
	rank_actors <= 3;


--Task 6. Output cities with the number of active and inactive customers (active - customer.active = 1). 
-- Sort by the number of inactive customers in descending order.
SELECT
  c.city,
  SUM(CASE WHEN c2.active = 1 THEN 1 ELSE 0 END) AS active_count,
  SUM(CASE WHEN  c2.active = 0 THEN 1 ELSE 0 END) AS inactive_count
FROM city c
  JOIN address a ON c.city_id = a.city_id
  JOIN customer c2 ON a.address_id = c2.address_id
GROUP BY c.city_id, c.city
ORDER BY inactive_count DESC;


--Task 7. Output the category of movies that have the highest number of total rental hours in the city 
-- (customer.address_id in this city). and that start with the letter “a”. Do the same for cities that have a “-” in them. 
WITH rent_h AS (
    SELECT
        c2.name AS film_category,   
        c.city,
	    ROUND(SUM(EXTRACT(epoch FROM r.return_date - r.rental_date)) / 3600, 1) AS total_rent_hours
    FROM
	    city c 
        JOIN address a ON c.city_id = a.city_id
	    JOIN customer c1 ON a.address_id = c1.address_id
        JOIN rental r ON c1.customer_id = r.customer_id
        JOIN inventory i ON r.inventory_id = i.inventory_id
        JOIN film_category fc ON i.film_id = fc.film_id
        JOIN category c2 ON fc.category_id = c2.category_id
     WHERE
        c.city LIKE 'A%'
	    OR c.city LIKE '%-%'
	    AND r.return_date IS NOT NULL
     GROUP BY
	     c.city,
	     c2.name
	 ORDER BY
	    total_rent_hours DESC
	    ),
-- Find TOP-1 category with cities 'A' at the beginning
	   sample_A AS (
    SELECT
	    'A' AS title,
	    rh.city,
	    rh.film_category,
	    rh.total_rent_hours AS max_rent_hours
    FROM rent_h rh
    WHERE rh.city LIKE 'A%'
    ORDER BY total_rent_hours DESC
    LIMIT 1
    ),
---- Find TOP-1 category with cities containing '-'
sample_D AS (
    SELECT
	    '-' AS title,
	    rh.city,
	    rh.film_category,
	    rh.total_rent_hours AS max_rent_hours
    FROM rent_h rh
    WHERE rh.city LIKE '%-%'
    ORDER BY total_rent_hours DESC
    LIMIT 1
    )
SELECT * FROM sample_A
UNION ALL 
SELECT * FROM sample_D;