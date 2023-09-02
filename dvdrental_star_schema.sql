-- creating dimension table for date

create table star_schema.dimDate(
	date_key integer not null primary key,
	date date not null,
	year smallint not null,
	quarter smallint not null,
	month smallint not null,
	day smallint not null,
	week smallint not null,
	is_weekend boolean
);

-- customer dimension table

create table star_schema.dimCustomer(

	customer_key serial primary key,
	customer_id smallint not null,
	first_name varchar(45) not null,
	last_name varchar(45) not null,
	email varchar(45) not null,
	address varchar(50) not null,
	country varchar(50) not null,
	city varchar(50) not null,
	active smallint not null,
	create_date timestamp not null,
	start_date date not null,
	end_date date not null
	
);


-- movie dimension table

create table star_schema.dimMovie(

	movie_key serial primary key,
	movie_id smallint not null,
	title varchar(255) not null,
	description text,
	release_year year,
	language_id varchar(20) not null,
	original_language varchar(20),
	rental_duration smallint not null,
	length smallint not null,
	rating varchar(5) not null,
	specail_feature varchar(60) not null
	
);


-- dimension table for storing store information

create table star_schema.dimStore(

	store_key serial primary key,
	store_id smallint not null,
	manager_first_name varchar(45) not null,
	manager_last_name varchar(45) not null,
	postal_code varchar(10),
	phone varchar(20),
	address varchar(50) not null,
	country varchar(50) not null,
	city varchar(50) not null,
	start_date date not null,
	end_date date not null
	
);


-- inserting data into date dim table

insert into star_schema.dimDate
(date_key,date,year,quarter,month,day,week,is_weekend)
select 
DISTINCT (TO_CHAR (payment_date :: DATE, 'yYYMMDD')::integer) as date_key,
date(payment_date) as date, 
extract(year from payment_date) as year,
extract(quarter from payment_date) as quarter,
extract(month from payment_date) as month,
extract(day from payment_date) as day,
extract(week from payment_date) as week,
case when extract(ISODOW from payment_date) in (6,7) then true
else false end
from payment;

select * from star_schema.dimDate;


-- inserting data into customer dim table

insert into star_schema.dimCustomer
(customer_key,customer_id,first_name,last_name,email,address,country,city,active,create_date,start_date,end_date)
select
	cus.customer_id as customer_key,
	cus.customer_id as customer_id,
	cus.first_name as first_name,
	cus.last_name as last_name,
	cus.email as email,
	ad.address as address,
	con.country as country,
	city.city as city,
	cus.active as active,
	cus.create_date as create_date,
	now() as start_date,
	now() as end_date
	
	from customer cus join address ad on cus.address_id=ad.address_id
	join city on city.city_id=ad.city_id
	join country con on con.country_id=city.country_id;
	
	
select * from star_schema.dimCustomer;
select * from Customer;


-- inseritng data in movie dim table

insert into star_schema.dimMovie(movie_key,movie_id,title,description,release_year,language_id,original_language,rental_duration,length,rating,specail_feature)
select 

	f.film_id as movie_key,
	f.film_id as movie_id,
	f.title as title,
	f.description as description,
	f.release_year as release_year,
	f.language_id as language_id,
	l.name as original_language,
	f.rental_duration as rental_duration,
	f.length as length,
	f.rating as rating,
	f.special_features as special_features
from film f
join language l on f.language_id=l.language_id;




-- inserting data in store dim table

insert into star_schema.dimStore
(store_key,store_id,manager_first_name,manager_last_name,postal_code,address,country,city,start_date,end_date)
select
str.store_id as store_key,
str.store_id as store_id,
stf.first_name as manager_first_name,
stf.last_name as manager_last_name,
ad.postal_code as postal_code,
ad.address as address,
city.city as city,
con.country as country,
now() as start_date,
now() as end_date

from store str join staff stf on str.manager_staff_id=stf.staff_id
join address ad on str.address_id=ad.address_id
join city on ad.city_id=city.city_id
join country con on city.country_id=con.country_id;


select * from star_schema.dimStore;



-- Craeting facts table

CREATE TABLE star_schema.factSales(
	sales_key SERIAL PRIMARY KEY, 
 	date_key integer REFERENCES star_schema.dimDate (date_key), 
 	customer_key integer REFERENCES star_schema.dimCustomer (customer_key), 
 	movie_key integer REFERENCES star_schema.dimMovie (movie_key), 
 	store_key integer REFERENCES star_schema.dimStore (store_key), 
 	sales_amount numeric
 );
 
 
 -- inserting into sales table

 insert into star_schema.factSales(date_key,customer_key,movie_key,store_key,sales_amount)
 select
 	TO_CHAR (p.payment_date :: DATE, 'yYYMMDD')::integer as date_key,
	p.customer_id as customer_key,
	i.film_id as movie_key,
	i.store_id as store_key,
	p.amount as sales_amount
	from payment p
	join rental r on p.rental_id=r.rental_id
	join inventory i on i.inventory_id=r.inventory_id;
	
	
select * from star_schema.factSales;






--QUERY TIME ANALYSIS


--fetching data from 3nf schema
SELECT f.title, EXTRACT (month FROM p.payment_date) as month, ci.city, sum (p.amount) as revenue
FROM payment p
JOIN rental r
ON ( p.rental_id = r.rental_id )
JOIN inventory i ON ( r.inventory_id = i.inventory_id )
JOIN film f ON ( i.film_id = f. film_id)
JOIN customer c ON ( p.customer_id = c.customer_id )
JOIN address a ON ( c.address_id = a.address_id )
JOIN city ci ON ( a.city_id = ci.city_id )
group by (f.title, month, ci.city)
order by f.title, month, ci.city, revenue desc;

--fetching data from star schema
SELECT dimMovie.title, dimDate.month, dimCustomer.city, sum(sales_amount) as revenue
FROM star_schema.factSales
JOIN star_schema.dimMovie on (dimMovie.movie_key=factSales.movie_key)
JOIN star_schema.dimDate on (dimDate.date_key=factSales.date_key)
JOIN star_schema.dimCustomer on (dimCustomer.customer_key=factSales.customer_key)
group by (dimMovie.title, dimDate.month, dimCustomer.city)
order by dimMovie.title, dimDate.month, dimCustomer.city, revenue desc;