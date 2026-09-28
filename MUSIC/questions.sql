-- Who is the senior most employee based on job title?
select * from employee order by levels desc limit 1;

-- Which countries have the most invoices?
select billing_country, count(*) from invoice group by billing_country order by count(*) desc limit 1;

-- What are top 3 values of total invoice?
select * from invoice order by total desc limit 3;

-- Which city have best cutomers, return city name and sum of invoices with the largest value?
select billing_city, sum(total) from invoice group by billing_city order by sum(total) desc limit 1;

-- person who spent the most money?
select i.customer_id, c.first_name, c.last_name ,sum(i.total) from invoice i join 
customer c on i.customer_id = c.customer_id group by i.customer_id, c.first_name, c.last_name
order by sum(i.total) desc limit 1;

-- return email, first name, last name, genre if all the rock music listeners, order by email
select c.email, c.first_name, c.last_name, g.name from customer c 
join invoice i on c.customer_id = i.customer_id 
join invoice_line il on i.invoice_id = il.invoice_id 
join track t on il.track_id = t.track_id
join genre g on t.genre_id = g.genre_id 
where g.name like 'Rock'
group by c.email, c.first_name, c.last_name, g.name
order by c.email;

-- write a query tp return artist who have written the most rock music top 10?
select a.name, count(*) as count_track from artist a
join album2 al on a.artist_id = al.artist_id
join track t on al.album_id = t.album_id
join genre g on t.genre_id = g.genre_id 
where g.name like 'Rock'
group by a.name
order by count_track desc limit 10;

-- return all the track names whose length is greater than average length in millisocond order by length desc?
select `name`, milliseconds from track where milliseconds >
(select avg(milliseconds) from track) 
order by milliseconds desc;

-- find how much amount spent by each customer on artists
with best_selling_artist as
(select a.artist_id as artist_id, a.name as artist_name,
sum(il.unit_price* il.quantity) as total 
from artist a
join album2 al on a.artist_id = al.artist_id
join track t on al.album_id = t.album_id
join invoice_line il on t.track_id = il.track_id
group by artist_id, artist_name
order by total desc  limit 1)
select c.customer_id as id, c.first_name as first_name, c.last_name as last_name,
bsa.artist_name,
sum(il.unit_price* il.quantity) as invoice_list from 
customer c join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
join track t on il.track_id = t.track_id
join album2 al on t.album_id = al.album_id
join artist a on al.artist_id = a.artist_id
join best_selling_artist bsa on a.artist_id = bsa.artist_id
group by 1,2,3,4
order by invoice_list desc;

-- most popular genre in each country (most popular is most amount of purchases)
with cte as (
select count(il.quantity), c.country, g.genre_id, g.name ,
row_number() over (partition by c.country order by count(il.quantity) desc)	 row_num
from genre g join track t on g.genre_id = t.genre_id
join invoice_line il on t.track_id = il.track_id
join invoice i on il.invoice_id = i.invoice_id
join customer c on i.customer_id = c.customer_id
group by 2,3,4 
order by 1 desc, 4
)
select * from cte where row_num <= 1;

-- determine customers who spent most from each country (returns country and the customer name and the amount they spent)
with cte2 as (
select sum(i.total) as total, i.billing_country, c.first_name, c.last_name, c.customer_id,
row_number() over (partition by i.billing_country order by sum(i.total) desc) as row_num
from invoice i
join customer c on i.customer_id = c.customer_id
group by 2,3,4,5
order by 2 asc, 1 desc)
select * from cte2 where row_num <= 1;