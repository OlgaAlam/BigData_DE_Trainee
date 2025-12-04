--Task 1. Output the number of movies in each category, sorted descending
select 
  c.name, 
  count(film_id) as num_films
from 
  category c inner join film_category fc
  on c.category_id = fc.category_id 
group by fc.category_id, c.name
order by num_films desc;


--Task 2. Output the 10 actors whose movies rented the most, sorted in descending order.
with most_rented as (
    select  
        a.actor_id,
        a.first_name,
        a.last_name,
        COUNT(*) as rental_count
    from actor a
       join film_actor fa on a.actor_id = fa.actor_id
       join film f on fa.film_id = f.film_id
       join inventory i on f.film_id = i.film_id
       join rental r on i.inventory_id = r.inventory_id
    group by a.actor_id, a.first_name, a.last_name
    order by rental_count desc 
    )
select 
    first_name,
    last_name
from most_rented
limit 10;


--Task 3. Output the category of movies on which the most money was spent
with cost_max as (
    select 
      c.name, 
      sum(f.replacement_cost) as cost
    from
       film f 
       join film_category fc on f.film_id = fc.film_id 
       join category c on fc.category_id = c.category_id
    group by 
       c.category_id,
       c.name
    order by cost desc
    )
select name
from cost_max
limit 1;


--Task 4. Print the names of movies that are not in the inventory. 
-- Write a query without using the IN operator.
select
   f.title
from 
   film f
where not exists
   (
    select * from inventory i
    where f.film_id = i.film_id
   );


--Task 5. Output the top 3 actors who have appeared the most in movies in the “Children” category. 
-- If several actors have the same number of movies, output all of them.
with most_child as (
    select
	  a.first_name,
      a.last_name,
	  dense_rank() over (order by count(*) desc) as rank_actors
    from
	  actor a
      join film_actor fa on a.actor_id = fa.actor_id
      join film_category fc on fa.film_id = fc.film_id
      join category c on fc.category_id = c.category_id
   where
	    c.name = 'Children'
   group by
	    a.first_name,
	    a.last_name,
	    a.actor_id,
	    c.name
	)
select
	first_name,
	last_name
from
	most_child
where
	rank_actors <= 3;


--Task 6. Output cities with the number of active and inactive customers (active - customer.active = 1). 
-- Sort by the number of inactive customers in descending order.
select
  c.city,
  SUM(case when c2.active = 1 then 1 else 0 end) as active_count,
  SUM(case when  c2.active = 0 then 1 else 0 end) as inactive_count
from city c
  join address a on c.city_id = a.city_id
  join customer c2 on a.address_id = c2.address_id
group by c.city_id, c.city
order by inactive_count desc;


--Task 7. Output the category of movies that have the highest number of total rental hours in the city 
-- (customer.address_id in this city). and that start with the letter “a”. Do the same for cities that have a “-” in them. 
with rent_h as (
    select
	    r.inventory_id,
	    c2.city,
	    SUM(extract(hour from r.return_date - r.rental_date)) over (partition by c2.city) as total_rent_hours
    from
	    rental r
        join customer c on r.customer_id = c.customer_id
        join address a on c.address_id = a.address_id
        join city c2 on a.city_id = c2.city_id
     where
	    c2.city like 'A%'
	    or c2.city like '%-%'
	    and r.return_date is not null
     group by
	    c2.city,
	    r.inventory_id,
	    r.return_date,
	    r.rental_date
      ),
sample_A as (
    select
	    'City with A at the beginning' as title,
	    rh.city,
	    c.name as category_film,
	    total_rent_hours as max_rent_hours
    from 
	    rent_h rh
        join inventory i on rh.inventory_id = i.inventory_id
        join film_category fc on i.film_id = fc.film_id
        join category c on fc.category_id = c.category_id
    where
	    rh.city like 'A%'
    order by
	    total_rent_hours desc
     limit 1
     ),
sample_D as (
    select
	    'City with dash' as title,
	    rh.city,
	    c.name as category_film,
	    total_rent_hours as max_rent_hours
    from
	    rent_h rh
        join inventory i on rh.inventory_id = i.inventory_id
        join film_category fc on i.film_id = fc.film_id
        join category c on fc.category_id = c.category_id
    where
	    rh.city like '%-%'
    order by
	    total_rent_hours desc
    limit 1
    )
select *
from sample_A
union all 
select *
from sample_D;