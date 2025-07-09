Question Set 1 – Easy

Q1 Who is the senior most employee based on job title?

SELECT * FROM employee 
ORDER BY levels DESC
LIMIT 1


Q2 Which country have the most invoices?

SELECT COUNT(*) AS c, billing_country
FROM invoice 
GROUP BY billing_country
ORDER BY c desc


Q3 What are top 3 values of total invoice?

SELECT total 
FROM invoice
ORDER BY total DESC
LIMIT 3



Q4 Which city has the best customers? We would like to throw a promotional Music 
Festival in the city we made the most money. Write a query that returns one city that 
has the highest sum of invoice totals. Return both the city name & sum of all invoice 
totals


SELECT SUM(total) as invoice_total, billing_city
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total desc
LIMIT 1




Q5 Who is the best customer? The customer who has spent the most money will be
declared the best customer. Write a query that returns the person who has spent the
most money

SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) as total
FROM customer c
JOIN invoice i
ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total DESC
LIMIT 1


Question Set 2 – Moderate


Q1 Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A.

SELECT DISTINCT email, first_name, last_name
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
WHERE track_id IN(
                   SELECT track_id FROM track t
				   JOIN genre g ON t.genre_id = g.genre_id
				   WHERE g.name LIKE 'Rock'
				   )
ORDER BY email;


Q2 let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands
				   

SELECT a.artist_id, a.Name, COUNT(a.artist_id) as number_of_songs FROM track t
JOIN album al ON al.album_id = t.album_id
JOIN artist a ON a.artist_id = al.artist_id
JOIN genre g ON g.genre_id = t.genre_id
WHERE g.name LIKE 'Rock'
GROUP BY a.artist_id
ORDER BY number_of_songs DESC
LIMIT 10


Q3 Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first


SELECT name, milliseconds
FROM track
WHERE milliseconds > (
          SELECT AVG(Milliseconds) AS avgsong_length
		  FROM track)
ORDER BY milliseconds  DESC



Question Set 3 – Advance


1. Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent


WITH best_selling_artist AS (
         SELECT a.artist_id as artist_id , a.name as artist_name, 
		 SUM(il.unit_price * il.quantity) AS total_spent
		 FROM invoice_line il
		 JOIN track t ON t.track_id = il.track_id
		 JOIN album al ON al.album_id = t.album_id
		 JOIN artist a ON a.artist_id = al.artist_id
		 GROUP BY 1
		 ORDER BY 3 DESC
		 LIMIT 1
		 
)


SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name , SUM(il.unit_price * il.quantity) AS total_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album al ON al.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = al.artist_id
GROUP BY 1, 2,3,4
ORDER BY 5 DESC


Q2 We want to find out the most popular music Genre for each country. We determine the 
most popular genre as the genre with the highest amount of purchases. Write a query 
that returns each country along with the top Genre. For countries where the maximum 
number of purchases is shared return all Genres

WITH popular_genre AS
(     
          SELECT COUNT(il.quantity) as purchase, c.country, g.genre_id, g.name,
		  ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity)DESC) AS rowno
		  FROM invoice_line il
		  JOIN invoice i ON i.invoice_id = il.invoice_id
	      JOIN customer c ON c.customer_id = i.customer_id
	      JOIN track t ON t.track_id = il.track_id
	      JOIN genre g ON g.genre_id = t.genre_id
	      GROUP BY 2,3,4
	      ORDER BY 2 ASC, 1 DESC

)

SELECT * FROM popular_genre WHERE RowNo <= 1


Q3 Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount

WITH RECURSIVE
    customer_with_country AS(
          SELECT c.customer_id, billing_country, first_name,last_name, SUM(Total) AS total_spent
	      FROM invoice i     
	      JOIN customer c ON c.customer_id = i.customer_id
		  GROUP BY 1,2,3,4
		  ORDER BY 3,4 DESC),

    country_max_spending AS(
          SELECT billing_country, MAX(total_spent) AS max_spending
		  FROM customer_with_country
		  GROUP BY billing_country)	  

SELECT cc.billing_country, cc.total_spent, cc.first_name, cc.last_name, cc.customer_id
FROM customer_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spent = ms.max_spending
ORDER BY 1;


		  
