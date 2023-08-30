/* Analysis 1: Identifying the Senior Most Employee Based on Job Title
This query is used to find the senior-most employee based on their job title. It helps in identifying the employee with the highest job title level, indicating their seniority. */

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1;

/* Analysis 2: Determining Countries with the Most Invoices
This query analyzes which countries have the most invoices. It can provide insights into regions with high sales activity, helping with marketing and inventory management decisions. */

SELECT COUNT(*) AS invoice_count, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY invoice_count DESC;

/* Analysis 3: Finding the Top 3 Total Invoice Values
This query is used to identify the top 3 total invoice values. It helps in understanding which transactions contribute the most revenue to the business. */

SELECT total 
FROM invoice
ORDER BY total DESC
LIMIT 3;

/* Analysis 4: This query identifies the city with the highest sum of invoice totals. It can help in deciding where to host a promotional Music Festival to maximize revenue. */

SELECT billing_city, SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;

/* Analysis 5: This query is used to determine the best customer, i.e., the customer who has spent the most money. It helps in recognizing and rewarding valuable customers. */

SELECT customer.customer_id, first_name, last_name, SUM(total) AS total_spending
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_spending DESC
LIMIT 1;

/* Analysis 6: These queries help identify customers who listen to Rock music. It can be valuable for targeted marketing or playlist recommendations. */

SELECT DISTINCT email, first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoiceline ON invoice.invoice_id = invoiceline.invoice_id
WHERE track_id IN (
    SELECT track_id 
    FROM track
    JOIN genre ON track.genre_id = genre.genre_id
    WHERE genre.name LIKE 'Rock'
)
ORDER BY email;

/* Analysis 7: This query helps identify the top 10 rock bands by the number of tracks they have produced. It can be useful for music promotion and artist collaborations. */

SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;

/* Analysis 8: This query identifies tracks with song lengths longer than the average song length. It can help in creating playlists or organizing music by duration. */

SELECT name, milliseconds
FROM track
WHERE milliseconds > (
    SELECT AVG(milliseconds) AS avg_track_length
    FROM track
)
ORDER BY milliseconds DESC;

/* Analysis 9: This query calculates how much each customer has spent on artists, specifically the artist with the highest sales. It helps in identifying top-spending customers. */

WITH best_selling_artist /* Subquery to find the best-selling artist by total sales */
AS (
    SELECT artist.artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
    FROM invoice_line
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN album ON album.album_id = track.album_id
    JOIN artist ON artist.artist_id = album.artist_id
    GROUP BY artist.artist_id
    ORDER BY total_sales DESC
    LIMIT 1
)
SELECT 
/* Main query to find customer spending on the best-selling artist */
c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY amount_spent DESC;

/* Analysis 10: This query finds the most popular music genre in each country, based on the highest number of purchases. It provides insights into music preferences across different regions. */

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
    ROW_NUMBER() OVER (PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
    JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN customer ON customer.customer_id = invoice.customer_id
    JOIN track ON track.track_id = invoice_line.track_id
    JOIN genre ON genre.genre_id = track.genre_id
    GROUP BY customer.country, genre.name, genre.genre_id
)
SELECT * FROM popular_genre WHERE RowNo <= 1;

/* Analysis 11: This query determines the customer who has spent the most on music for each country. It provides insights into the highest spending customers in different countries, potentially useful for targeted marketing or loyalty programs. */

WITH CustomersWithCountry AS (
    SELECT
        customer.customer_id,
        first_name,
        last_name,
        billing_country,
        SUM(total) AS total_spending,
        ROW_NUMBER() OVER (PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo
    FROM
        invoice
    JOIN customer ON customer.customer_id = invoice.customer_id
    GROUP BY 1, 2, 3, 4
    ORDER BY 4 ASC, 5 DESC
)
SELECT * FROM CustomersWithCountry WHERE RowNo <= 1;










