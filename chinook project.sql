-- Objective Question 1
-- Ans for objective 1
Select * 
from album
where album_id is null;  

Select album_id, Count(*)
from album
group by album_id
having count(*) > 1;

Select *
from artist                  
where artist_id is null;

Select artist_id, Count(*)
from artist
group by artist_id
having count(*) > 1;

Select * from customer
where customer_id is null;

Select customer_id, count(*)
from customer
group by customer_id
having count(*) > 1;

Select * from employee
where employee_id is null;

Select employee_id, count(*)
from employee
group by employee_id
having count(*) > 1;

Select * from genre
where genre_id is null;

Select genre_id, count(*)
from genre
group by genre_id
having count(*) > 1;

Select * from invoice
where invoice_id is null;

Select invoice_id, count(*)
from invoice
group by invoice_id
having count(*) > 1;

 Select * from invoice_line
 where invoice_line_id is null;
 
 Select invoice_line_id, count(*)
 from invoice_line
 group by invoice_line_id
 having count(*) > 1;
 
 Select * from media_type
 where media_type_id is null;
 
 Select media_type_id, count(*)
 from media_type
 group by media_type_id
 having count(*) > 1;
 
 Select * from playlist
 where playlist_id is null;

Select playlist_id, count(*)
from playlist
group by playlist_id
having count(*) > 1;

Select * from playlist_track
where playlist_id is null;

Select playlist_id, track_id, count(*)
from playlist_track
group by playlist_id, track_id
having count(*) > 1;

Select * from track
where track_id is null;

Select track_id, count(*)
from track
group by track_id
having count(*) > 1;

Select * from customer;
Select * from employee;
------------------------------------------------------------------------------------------------------------------------------------
-- Objective Question 2
-- Ans for objective 2
-- Top Selling Tracks in the USA
SELECT t.name AS track_name, a.name, SUM(il.quantity * il.unit_price) AS total_sales
FROM invoice_line il
JOIN track t ON il.track_id = t.track_id
JOIN album al ON t.album_id = al.album_id
JOIN artist a ON al.artist_id = a.artist_id
JOIN invoice i ON il.invoice_id = i.invoice_id
JOIN customer c ON i.customer_id = c.customer_id
WHERE i.billing_country = 'USA'
GROUP BY t.track_id, t.name, a.name
ORDER BY total_sales DESC
LIMIT 10;  

-- Top Artist in the USA
SELECT a.name, SUM(il.quantity * il.unit_price) AS total_sales
FROM artist a
JOIN album al ON a.artist_id = al.artist_id
JOIN track t ON al.album_id = t.album_id
JOIN invoice_line il ON t.track_id = il.track_id
JOIN invoice i ON il.invoice_id = i.invoice_id
JOIN customer c ON i.customer_id = c.customer_id
WHERE i.billing_country = 'USA'
GROUP BY a.artist_id, a.name
ORDER BY total_sales DESC
LIMIT 1;  -- Top artist

-- Most famous Genres in the USA
SELECT g.name AS genre_name, SUM(il.quantity * il.unit_price) AS total_sales
FROM genre g
JOIN track t ON g.genre_id = t.genre_id
JOIN invoice_line il ON t.track_id = il.track_id
JOIN invoice i ON il.invoice_id = i.invoice_id
JOIN customer c ON i.customer_id = c.customer_id
WHERE i.billing_country = 'USA'
GROUP BY g.genre_id, g.name
ORDER BY total_sales DESC
LIMIT 5;  -- Top 5 genres by track sales

-- Famous Genres for the Top Artist in the USA
SELECT g.name AS genre_name, SUM(il.quantity * il.unit_price) AS total_sales
FROM genre g
JOIN track t ON g.genre_id = t.genre_id
JOIN invoice_line il ON t.track_id = il.track_id
JOIN invoice i ON il.invoice_id = i.invoice_id
JOIN customer c ON i.customer_id = c.customer_id
JOIN album al ON t.album_id = al.album_id
JOIN artist a ON al.artist_id = a.artist_id
WHERE i.billing_country = 'USA'
AND a.artist_id = (
    SELECT a.artist_id
    FROM artist a
    JOIN album al ON a.artist_id = al.artist_id
    JOIN track t ON al.album_id = t.album_id
    JOIN invoice_line il ON t.track_id = il.track_id
    JOIN invoice i ON il.invoice_id = i.invoice_id
    WHERE i.billing_country = 'USA'
    GROUP BY a.artist_id
    ORDER BY SUM(il.quantity * il.unit_price) DESC
    LIMIT 1
)
GROUP BY g.genre_id, g.name
ORDER BY total_sales DESC;

-- Objective Question 3
-- Ans for objective 3
-- No. of customers from each country 
SELECT country, COUNT(customer_id) AS customer_count
FROM customer
GROUP BY country
ORDER BY customer_count DESC;

-- No. of customers from each country by each city
SELECT country, city, COUNT(customer_id) AS customer_count
FROM customer
GROUP BY country, city
ORDER BY customer_count DESC;

-- No. of customers from  each city
SELECT city, COUNT(customer_id) AS customer_count
FROM customer
GROUP BY  city
ORDER BY customer_count DESC;
-------------------------------------------------------------------------------------------------------------------------------------------

-- Objective Question 4

select * from invoice;
select * from customer;
-- Ans for objective 4
SELECT 
    c.country,
    c.state,
    c.city,
    COUNT(i.invoice_id) AS number_of_invoices,
    SUM(i.total) AS total_revenue
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.country, c.state, c.city
ORDER BY c.country, c.state, c.city;
-------------------------------------------------------------------------------------------------

-- Objective Question 5
-- Ans for objective 5
WITH CustomerRevenue AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        c.country,
        SUM(i.total) AS total_revenue,
        RANK() OVER (PARTITION BY c.country ORDER BY SUM(i.total) DESC) AS ranks
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.country
)
SELECT 
    customer_id,
    first_name,
    last_name,
    country,
    total_revenue
FROM CustomerRevenue
WHERE ranks <= 5
ORDER BY country, total_revenue DESC;

--------------------------------------------------------------------------------------------------------------
-- Objective Question 6
Select * from track;
Select * from invoice_line;
Select * from invoice;
-- Ans for objective 6
WITH CustomerTrackSales AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        t.track_id,
        t.name AS track_name,
        SUM(il.quantity * il.unit_price) AS total_spent
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN track t ON il.track_id = t.track_id
    GROUP BY c.customer_id, c.first_name, c.last_name, t.track_id, t.name
),
TopSellingTracks AS (
    SELECT 
        customer_id,
        first_name,
        last_name,
        track_name,
        total_spent,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY total_spent DESC) AS ranks
    FROM CustomerTrackSales
)
SELECT 
    customer_id,
    first_name,
    last_name,
    track_name AS top_selling_track,
    total_spent AS track_sales
FROM TopSellingTracks
WHERE ranks = 1
ORDER BY customer_id;

----------------------------------------------------------------------------------------------------------------

-- Objective Question 7
Select * from invoice;
Select * from invoice_line;
Select * from customer;
-- Ans for objective 7
-- Frequency of Puchases by Customers
SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    COUNT(i.invoice_id) AS purchase_count
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY purchase_count DESC;

-- Prefered Payments Methods
-- since there is no column for payment methods we cannot find this

-- Average order value
SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    ROUND(AVG(i.total),2) AS average_order_value
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY average_order_value DESC;

-----------------------------------------------------------------------------------------------------

-- Objective Question 8
Select * from customer;
Select * from invoice;
-- Ans for objective 8
WITH Active_Customers AS (
    SELECT 
        c.customer_id,
        DATE_FORMAT(i.invoice_date, '%Y') AS purchase_year
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, purchase_year
),
Churned_Customers AS (
    SELECT 
        ac1.purchase_year AS previous_year,
        COUNT(DISTINCT ac1.customer_id) AS churned_customers
    FROM Active_Customers ac1
    LEFT JOIN Active_Customers ac2
        ON ac1.customer_id = ac2.customer_id 
        AND ac2.purchase_year = ac1.purchase_year + 1 
    WHERE ac2.customer_id IS NULL
    GROUP BY ac1.purchase_year
),
Total_Customers AS (
    SELECT 
        purchase_year,
        COUNT(DISTINCT customer_id) AS total_customers
    FROM Active_Customers
    GROUP BY purchase_year
)
SELECT 
    ch.previous_year,
    ch.churned_customers,
    t.total_customers AS total_customers_last_year,
    (ch.churned_customers / t.total_customers) * 100 AS churn_rate
FROM Churned_Customers ch
JOIN Total_Customers t ON ch.previous_year = t.purchase_year
ORDER BY ch.previous_year;

----------------------------------------------------------------------------------------------------------------------------------

-- Objective Question 9

Select * from genre;
Select * from customer;
select * from invoice;
select * from invoice_line;
select * from artist;
select * from track;
-- Ans for objective 9
WITH US_Sales AS (
    SELECT 
        i.invoice_id,
        il.track_id,
        il.unit_price * il.quantity AS total_sales
    FROM invoice i
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN customer c ON i.customer_id = c.customer_id
    WHERE c.country = 'USA'
),
Genre_Sales AS (
    SELECT 
        g.genre_id,
        g.name AS genre_name,
        SUM(us.total_sales) AS genre_sales
    FROM US_Sales us
    JOIN track t ON us.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    GROUP BY g.genre_id, g.name
),
Total_Sales AS (
    SELECT SUM(genre_sales) AS total_sales FROM Genre_Sales
),
Artist_Sales AS (
    SELECT 
        ar.artist_id,
        ar.name AS artist_name,
        SUM(us.total_sales) AS artist_sales
    FROM US_Sales us
    JOIN track t ON us.track_id = t.track_id
    JOIN album al ON t.album_id = al.album_id
    JOIN artist ar ON al.artist_id = ar.artist_id
    GROUP BY ar.artist_id, ar.name
)
SELECT 
    gs.genre_name,
    gs.genre_sales,
    (gs.genre_sales / ts.total_sales) * 100 AS genre_sales_percentage,
    ar.artist_name,
    ar.artist_sales
FROM Genre_Sales gs
JOIN Total_Sales ts ON 1=1
LEFT JOIN (
    SELECT artist_name, MAX(artist_sales) AS artist_sales FROM Artist_Sales GROUP BY artist_name
) ar ON ar.artist_sales = (
    SELECT MAX(artist_sales) FROM Artist_Sales WHERE artist_sales > 0
)
ORDER BY (gs.genre_sales / ts.total_sales) * 100 DESC;

-------------------------------------------------------------------------------------------------------------------------

-- Objective Question 10
SELECT * FROM customer;
SELECT * FROM invoice;
SELECT * FROM invoice_line;
SELECT * FROM track;
SELECT * FROM genre;
-- Ans for Objective 10
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT g.genre_id) AS genres_purchased
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT g.genre_id) >= 3
ORDER BY genres_purchased DESC;

-----------------------------------------------------------------------------------------------------------

-- Objective Question 11
SELECT * FROM invoice;
SELECT * FROM invoice_line;
SELECT * FROM track;
SELECT * FROM genre;
-- Ans for Objective 11
SELECT g.name AS genre_name,
       SUM(il.unit_price * il.quantity) AS total_sales,
	   RANK() OVER (ORDER BY SUM(il.unit_price * il.quantity) DESC) AS sales_rank
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE i.billing_country = 'USA'
GROUP BY g.name
ORDER BY total_sales DESC;

-----------------------------------------------------------------------------------------------------

-- Objective Question 12
SELECT * FROM customer;
SELECT * FROM invoice;
-- Ans for Objective 12
WITH Last_Purchase AS (
    SELECT
        c.customer_id,
        MAX(i.invoice_date) AS last_purchase_date
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
),
Customers_Not_Purchased AS (
    SELECT
        lp.customer_id,
        lp.last_purchase_date
    FROM Last_Purchase lp
    WHERE lp.last_purchase_date < DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
)
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    cn.last_purchase_date
FROM customer c
JOIN Customers_Not_Purchased cn ON c.customer_id = cn.customer_id
ORDER BY cn.last_purchase_date DESC;

----------------------------------------------------------------------------------------------------------------

-- Subjective Question 1

SELECT * FROM album;
-- Ans for subjective 1
WITH US_Sales AS (
    SELECT 
        i.invoice_id,
        il.track_id,
        il.unit_price * il.quantity AS total_sales
    FROM invoice i
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN customer c ON i.customer_id = c.customer_id
    WHERE c.country = 'USA'
),
Genre_Sales AS (
    SELECT 
        g.genre_id,
        g.name AS genre_name,
        SUM(us.total_sales) AS genre_sales
    FROM US_Sales us
    JOIN track t ON us.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    GROUP BY g.genre_id, g.name
),
Total_Sales AS (
    SELECT SUM(genre_sales) AS total_sales FROM Genre_Sales
),
Album_Sales AS (
    SELECT 
        al.album_id,
        al.title,
        ar.artist_id,
        ar.name AS artist_name,
        SUM(us.total_sales) AS album_sales,
        g.genre_id
    FROM US_Sales us
    JOIN track t ON us.track_id = t.track_id
    JOIN album al ON t.album_id = al.album_id
    JOIN artist ar ON al.artist_id = ar.artist_id
    JOIN genre g ON t.genre_id = g.genre_id
    GROUP BY al.album_id, al.title, ar.artist_id, ar.name, g.genre_id
)
SELECT 
    gs.genre_name,
    ast.title,
    ast.artist_name,
    ast.album_sales
FROM Genre_Sales gs
JOIN Album_Sales ast ON gs.genre_id = ast.genre_id
ORDER BY gs.genre_sales DESC, ast.album_sales DESC
limit 3;

--------------------------------------------------------------------------------------------------------

-- Subjective Question 2

-- Ans for subjective 2
WITH Non_USA_Sales AS (
    SELECT 
        i.invoice_id,
        il.track_id,
        il.unit_price * il.quantity AS total_sales,
        c.country
    FROM invoice i
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN customer c ON i.customer_id = c.customer_id
    WHERE c.country <> 'USA'
),
Genre_Sales_By_Country AS (
    SELECT 
        g.genre_id,
        g.name AS genre_name,
        ns.country,
        SUM(ns.total_sales) AS genre_sales
    FROM Non_USA_Sales ns
    JOIN track t ON ns.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    GROUP BY g.genre_id, g.name, ns.country
),
Top_Genres_Per_Country AS (
    SELECT
        country,
        genre_name,
        genre_sales,
        RANK() OVER (PARTITION BY country ORDER BY genre_sales DESC) AS ranks
    FROM Genre_Sales_By_Country
)
-- Extract the top 3 genres per country
SELECT country, genre_name, genre_sales
FROM Top_Genres_Per_Country
WHERE ranks <= 3
ORDER BY country, ranks;

---------------------------------------------------------------------------------------------------------
-- Subjective Question 3

SELECT
    c.customer_id,
    COUNT(DISTINCT i.invoice_id) AS total_orders, 
    SUM(il.quantity) AS total_items_purchased, 
    (SUM(il.quantity) / COUNT(DISTINCT i.invoice_id)) AS average_basket_size 
FROM
    customer c
JOIN
    invoice i ON c.customer_id = i.customer_id
JOIN
    invoice_line il ON i.invoice_id = il.invoice_id
GROUP BY
    c.customer_id;



-- Ans for subjective 3
WITH CustomerFirstPurchase AS (
    -- Get the first purchase date for each customer
    SELECT 
        c.customer_id,
        MIN(i.invoice_date) AS first_purchase_date
    FROM 
        customer c
    JOIN 
        invoice i ON c.customer_id = i.customer_id
    GROUP BY 
        c.customer_id
),
CustomerCategory AS (
    -- Categorize customers as 'New' or 'Long-Term'
    SELECT
        c.customer_id,
        CASE 
            WHEN YEAR(f.first_purchase_date) = YEAR(CURDATE()) THEN 'New'
            ELSE 'Long-Term'
        END AS customer_type
    FROM 
        customer c
    JOIN 
        CustomerFirstPurchase f ON c.customer_id = f.customer_id
),
CustomerMetrics AS (
    -- Calculate frequency, basket size, and spending for each customer
    SELECT
        c.customer_id,
        cat.customer_type,
        COUNT(DISTINCT i.invoice_id) AS purchase_frequency, 
        SUM(il.quantity) AS total_items_purchased,
        (SUM(il.quantity) / COUNT(DISTINCT i.invoice_id)) AS average_basket_size, 
        SUM(i.total) AS total_spending, 
        (SUM(i.total) / COUNT(DISTINCT i.invoice_id)) AS average_spending_per_order 
    FROM 
        customer c
    JOIN 
        invoice i ON c.customer_id = i.customer_id
    JOIN 
        invoice_line il ON i.invoice_id = il.invoice_id
    JOIN 
        CustomerCategory cat ON c.customer_id = cat.customer_id
    GROUP BY 
        c.customer_id, cat.customer_type
)
-- Final aggregation to compare new vs long-term customers
SELECT
    customer_type,
    AVG(purchase_frequency) AS avg_frequency,
    AVG(average_basket_size) AS avg_basket_size,
    AVG(total_spending) AS avg_total_spending,
    AVG(average_spending_per_order) AS avg_spending_per_order
FROM 
    CustomerMetrics
GROUP BY 
    customer_type;
    
-------------------------------------------------------------------------------------------------------------------------

-- Subjective Question 4
-- Ans for subjective 4
-- Query to Analyze Genre Affinities
SELECT g1.name AS genre_1,
       g2.name AS genre_2,
       COUNT(*) AS purchase_count
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g1 ON t.genre_id = g1.genre_id
JOIN invoice_line il2 ON i.invoice_id = il2.invoice_id
JOIN track t2 ON il2.track_id = t2.track_id
JOIN genre g2 ON t2.genre_id = g2.genre_id
WHERE g1.genre_id <> g2.genre_id
GROUP BY g1.name, g2.name
ORDER BY purchase_count DESC
LIMIT 10;

-- Query to Analyze Artist Affinities
SELECT a1.name AS artist_1,
       a2.name AS artist_2,
       COUNT(*) AS purchase_count
FROM invoice_line il1
JOIN track t1 ON il1.track_id = t1.track_id
JOIN album al1 ON t1.album_id = al1.album_id
JOIN artist a1 ON al1.artist_id = a1.artist_id
JOIN invoice_line il2 ON il1.invoice_id = il2.invoice_id
JOIN track t2 ON il2.track_id = t2.track_id
JOIN album al2 ON t2.album_id = al2.album_id
JOIN artist a2 ON al2.artist_id = a2.artist_id
WHERE a1.artist_id <> a2.artist_id  
GROUP BY a1.name, a2.name
ORDER BY purchase_count DESC
LIMIT 10;

-- Query to Analyze Album Affinities
SELECT al1.title AS album_1,
       al2.title AS album_2,
       COUNT(*) AS purchase_count
FROM invoice_line il1
JOIN track t1 ON il1.track_id = t1.track_id
JOIN album al1 ON t1.album_id = al1.album_id
JOIN invoice_line il2 ON il1.invoice_id = il2.invoice_id
JOIN track t2 ON il2.track_id = t2.track_id
JOIN album al2 ON t2.album_id = al2.album_id
WHERE al1.album_id <> al2.album_id 
GROUP BY al1.title, al2.title
ORDER BY purchase_count DESC
LIMIT 10;

-----------------------------------------------------------------------------------------------------------------------------------------------

-- Subjective Question 5

WITH Active_Customers AS (
    SELECT DISTINCT customer_id
    FROM invoice
    WHERE invoice_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
)
SELECT COUNT(*) AS active_customer_count
FROM Active_Customers;

WITH Churned_Customers AS (
    SELECT DISTINCT c.customer_id
    FROM customer c
    LEFT JOIN invoice i ON c.customer_id = i.customer_id
    WHERE i.invoice_date IS NULL OR i.invoice_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
)
SELECT COUNT(*) AS churned_customer_count
FROM Churned_Customers;

-- Ans for subjective 5
WITH Total_Purchases AS (
    SELECT c.customer_id,
           c.city,
           c.state,
           c.country,
           COUNT(i.invoice_id) AS total_purchases,
           SUM(i.total) AS total_spending
    FROM customer c
    LEFT JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
),
Active_Customers AS (
    SELECT DISTINCT customer_id
    FROM invoice
    WHERE invoice_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
),
Churned_Customers AS (
    SELECT DISTINCT c.customer_id
    FROM customer c
    LEFT JOIN invoice i ON c.customer_id = i.customer_id
    WHERE i.invoice_date IS NULL OR i.invoice_date < DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
)
SELECT t.country,
       t.city,
       t.state,
       COUNT(DISTINCT a.customer_id) AS active_customers,
       COUNT(DISTINCT ch.customer_id) AS churned_customers,
       COUNT(DISTINCT a.customer_id) + COUNT(DISTINCT ch.customer_id) AS total_customers,
       SUM(t.total_purchases) AS total_purchases,
       AVG(i.total) AS avg_spending,
    CASE 
        WHEN (COUNT(DISTINCT a.customer_id) + COUNT(DISTINCT ch.customer_id)) = 0 THEN 0
        ELSE COUNT(DISTINCT ch.customer_id) / (COUNT(DISTINCT a.customer_id) + COUNT(DISTINCT ch.customer_id)) * 100 
    END AS churn_rate
FROM Total_Purchases t
LEFT JOIN Active_Customers a ON t.customer_id = a.customer_id
LEFT JOIN Churned_Customers ch ON t.customer_id = ch.customer_id
LEFT JOIN invoice i ON t.customer_id = i.customer_id
GROUP BY t.country, t.city, t.state
ORDER BY t.country, t.city, t.state;

------------------------------------------------------------------------------------------------------------------------------------------

-- Subjective Question 6

-- Ans for subjective 6
WITH Customer_Segments AS (
    SELECT 
        c.customer_id,
        c.city,
        c.country,
        COUNT(i.invoice_id) AS purchase_count,
        SUM(i.total) AS total_spending,
        DATEDIFF(CURDATE(), MAX(i.invoice_date)) AS days_since_last_purchase
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.city, c.country
),
Risk_Profiles AS (
    SELECT 
        cs.customer_id,
        cs.city,
        cs.country,
        cs.purchase_count,
        cs.total_spending,
        cs.days_since_last_purchase,
        CASE 
            WHEN cs.days_since_last_purchase > 365 THEN 'High Risk'
            WHEN cs.days_since_last_purchase BETWEEN 180 AND 365 THEN 'Moderate Risk'
            ELSE 'Low Risk'
        END AS churn_risk
    FROM Customer_Segments cs
)
SELECT 
    churn_risk,
    COUNT(customer_id) AS customer_count,
    AVG(total_spending) AS avg_spending,
    AVG(purchase_count) AS avg_purchase_count
FROM Risk_Profiles
GROUP BY churn_risk
ORDER BY FIELD(churn_risk, 'High Risk', 'Moderate Risk', 'Low Risk');


-----------------------------------------------------------------------------------------------------------------------------------

-- Subjective Question 7
 -- Ans for subjective 7
WITH Customer_Segments AS (
    SELECT 
        c.customer_id,
        c.city,
        c.country,
        DATEDIFF(CURDATE(), MIN(i.invoice_date)) AS customer_tenure, -- tenure in days
        COUNT(i.invoice_id) AS purchase_count, 
        SUM(i.total) AS total_spending, 
        SUM(i.total) / COUNT(i.invoice_id) AS avg_order_value, -
        DATEDIFF(CURDATE(), MAX(i.invoice_date)) AS days_since_last_purchase 
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id, c.city, c.country
),
CLV_Calculation AS (   -- Customer Lifetime Value Calculation
    SELECT 
        cs.customer_id,
        cs.city,
        cs.country,
        (cs.purchase_count / (cs.customer_tenure / 365)) AS purchase_frequency, -- purchase frequency per year
        cs.avg_order_value,
        CASE 
            WHEN cs.days_since_last_purchase > 365 THEN 'Churned'
            WHEN cs.days_since_last_purchase BETWEEN 180 AND 365 THEN 'At-Risk'
            ELSE 'Active'
        END AS customer_status,
        (cs.avg_order_value * cs.purchase_count) AS current_value, -- current total value
        (cs.avg_order_value * (cs.purchase_count / (cs.customer_tenure / 365)) * 5) AS predicted_clv -- predicted CLV over 5 years
    FROM Customer_Segments cs
)
SELECT 
    customer_status,
    COUNT(customer_id) AS customer_count,
    AVG(current_value) AS avg_current_value,
    AVG(predicted_clv) AS avg_predicted_clv
FROM CLV_Calculation
GROUP BY customer_status
ORDER BY FIELD(customer_status, 'Churned', 'At-Risk', 'Active');

--------------------------------------------------------------------------------------------------------------------------------------------
-- Subjective Question 10
-- Ans for subjective 10
ALTER TABLE album
ADD COLUMN ReleaseYear INT;

------------------------------------------------------------------------------------------------------------------------------------------------
-- Subjective Question 11
-- Ans for Subjective 11
WITH Customer_Purchases AS (
    SELECT
        c.country,
        c.customer_id,
        SUM(i.total) AS total_spent,
        COUNT(il.track_id) AS total_tracks
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    GROUP BY c.country, c.customer_id
)
SELECT 
    country,
    COUNT(customer_id) AS number_of_customers,
    AVG(total_spent) AS avg_total_spent,
    AVG(total_tracks) AS avg_tracks_purchased_per_customer
FROM Customer_Purchases
GROUP BY country
ORDER BY avg_total_spent DESC;
















































