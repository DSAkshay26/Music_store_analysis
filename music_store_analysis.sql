use newschema;

Q1: who is the senior most employee?
select * from employee
order by levels desc;
Q2. which countries have the most invoices?
select count(*), billing_country as country 
from invoice
group by billing_country;

select count(*) as counts, billing_country as country 
from invoice
group by billing_country
order by counts desc;

Q3. what are the top three values of total invoice?
select* 
from invoice
order by total desc
limit 3

Q4. which city has the best customers? we would like to throw a promotional music 
festival in the city we made  the most money. 
write query that returns one city that has the highest sum of invoice totals. 
return both the city name and sum of all invoice totals
select billing_city as city, sum(total) as revenue from invoice
group by billing_city 
order by revenue desc
limit 1

Q4. who is the best customer? The customer who has spent the most money will be 
declared the best customer. write a query that returns the person who has spent 
the most money.
select c.customer_id, c.first_name, c.last_name, sum(i.total) as total
from customer as c
join invoice as i 
using(customer_id)
group by c.customer_id
order by total desc
limit 1

Q5. Write query to return the email, first name, last name, & Genre of all Rock Music
listeners. Return your list ordered alphabetically by email starting with A
select* from customer
select* from genre

select c.email, c.first_name, c.last_name, g.name
from customer as c
join invoice as i 
using(customer_id)
join invoice_line as il
using(invoice_id)
join track as t
using(track_id)
join genre as g
using(genre_id)
where g.name= 'rock'
order by c.email

we can do same using query as:
select c.email, c.first_name, c.last_name
from customer as c
join invoice as i 
using(customer_id)
join invoice_line as il
using(invoice_id)
where track_id in(
select track_id from track as t
join genre as g
using(genre_id)
where g.name  like "Rock"
)
order by c.email

Q6. Lets invite the artists who have written the most rock music in our dataset. Write a
query that returns the Artist name and total track count of the top 10 rock bands
select* from invoice

select artist.name, count(track_id) as top rock bands
from artist 
join album 
using(artist_id)
join track 
using(album_id)
join genre 
using(genre_id)
where genre.name like 'Rock'
order by  top rock bands desc

we can write as 
SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;


Q.6 Return all the track names that have a song length longer than the average song length. Return the Name and
 Milliseconds for each track. Order by the song length with the longest songs listed first
 select* from track
 select name, milliseconds, avg(milliseconds) as avg_song_length
 from track
 having milliseconds > avg_song_length
 order by milliseconds desc
 
 we can do this by 
 SELECT name,milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track )
ORDER BY milliseconds DESC;

or we can do this:
SELECT name, milliseconds, avg_song_length
FROM (
    SELECT name, milliseconds, AVG(milliseconds) OVER () AS avg_song_length
    FROM track
) AS subquery
WHERE milliseconds > avg_song_length
ORDER BY milliseconds DESC;

Q7. Find how much amount spent by each customer on artists? 
Write a query to return customer name, artist name and total spent
with best_selling_artist as (
select artist.artist_id, artist.name, sum(invoice_line.unit_price*invoice_line.quantity) as total_sales 
from invoice_line
join track using(track_id)
join album using(album_id)
join artist using(artist_id)
group by artist.name 
order by total_sales desc
limit 1
)
select c.customer_id, concat(c.first_name, c.last_name) as customer_name, bsa.artist_name,
sum(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

Q.7 We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries
where the maximum number of purchases is shared return all Genres
WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1



3. Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount 