--Task 1
select 
  c.name, 
  count(film_id) as num_films
from 
  category c inner join film_category fc
  on c.category_id = fc.category_id 
group by fc.category_id, c.name
order by num_films desc;


--Task 2
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
limit 10;


--Task 3
select
   c.name as films_category, 
   sum(f.replacement_cost) as cost
from
   film f 
   inner join film_category fc on f.film_id = fc.film_id
   inner join category c on fc.category_id = c.category_id
group by films_category
order by cost desc
limit 1;


--Task 4
select
   f.film_id, f.title
from 
   film f
where not exists
   (
    select * from inventory i
    where f.film_id = i.film_id
   );


--Task 5
select 
   a.first_name,
   a.last_name,
   count(a.actor_id) as freq
from
   actor a
   inner join film_actor fa on
     a.actor_id = fa.actor_id
   inner join film_category fc on
     fa.film_id = fc.film_id
   inner join category c on
     fc.category_id = c.category_id
where c.name = 'Children'
group by
    a.actor_id, a.first_name, a.last_name
order by freq desc
fetch first 3 rows with ties;


--Task 6
select
  c.city_id,
  c.city,
  SUM(case when c2.active = 1 then 1 else 0 end) as active_count,
  SUM(case when  c2.active = 0 then 1 else 0 end) as inactive_count
from city c
  join address a on c.city_id = a.city_id
  join customer c2 on a.address_id = c2.address_id
group by c.city_id, c.city
order by inactive_count desc;


--Task 7
with rental_stats as (
    select 
        c.name as category_name,
        c3.city,
        SUM(f.rental_duration) as total_rental_hours
    from category c
    join film_category fc on c.category_id = fc.category_id
    join film f on fc.film_id = f.film_id
    join inventory i on f.film_id = i.film_id
    join customer c2 on i.store_id = c2.store_id
    join address a on c2.address_id = a.address_id
    join city c3 on a.city_id = c3.city_id
    group by c.name, c3.city
),
max_a as (
    select category_name, city, total_rental_hours
    from rental_stats
    where city like 'A%'
    order by total_rental_hours desc 
    limit 1
),
max_dash as (
    select category_name, city, total_rental_hours
    from rental_stats
    where city like '%-%'
    order by total_rental_hours desc 
    limit 1
)
select 'Cities starting with A' as description, * 
from max_a
union all 
select 'Cities containing -' as description, * 
from max_dash;
