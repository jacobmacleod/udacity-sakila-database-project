/* Which actors are in the most films */
/* Just the top 10 actors */
SELECT ac.actor_id,
       CONCAT(ac.first_name, ' ', ac.last_name) AS full_name,
	     COUNT(*) AS film_count
  FROM actor ac
  JOIN film_actor fa
    ON ac.actor_id = fa.actor_id
 GROUP BY ac.actor_id, full_name
 ORDER BY film_count DESC
 LIMIT 10;

/* Which category of film makes the most money for each store */
/* Select total payments per category
   and percentage of total payments overall */
SELECT c.category_id, c.name,
       SUM(p.amount) AS category_payments,
       SUM(p.amount) / (SELECT SUM(amount)
          FROM payment) * 100 AS percentage
  FROM payment AS p
  JOIN rental AS r
    ON p.rental_id = r.rental_id
  JOIN inventory AS i
    ON r.inventory_id = i.inventory_id
  JOIN film AS f
    ON i.film_id = f.film_id
  JOIN film_category AS fc
    ON f.film_id = fc.film_id
  JOIN category c
    ON fc.category_id = c.category_id
 GROUP BY c.category_id, c.name
 ORDER BY category_payment DESC;

/* How do rental durations of family-friendly films compare to the durations
   of all film rentals? */
SELECT category, COUNT(category)
  FROM (SELECT f.title film_title, c.name category,
 	             NTILE(4) OVER(ORDER BY f.rental_duration) AS quartile
 	        FROM film f
 	        JOIN film_category fc
 	          ON f.film_id = fc.film_id
 	        JOIN category c
 	          ON fc.category_id = c.category_id
 	       GROUP BY f.film_id, c.name) t1
 WHERE category IN ('Animation', 'Children', 'Classics', 'Comedy', 'Family', 'Music')
 GROUP BY category, quartile;

/* How much did the top paying customer spend ? */
SELECT DATE_TRUNC('month', p.payment_date) AS pay_mon,
       CONCAT(c.first_name, ' ', c.last_name) AS fullname,
       SUM(p.amount) pay_amount
  FROM customer c
  JOIN payment p
    ON c.customer_id = p.customer_id
 WHERE c.customer_id IN (SELECT top_customer
  FROM (SELECT c.customer_id top_customer,
	             SUM(p.amount) total_spent
	        FROM customer c
	        JOIN payment p
	          ON c.customer_id = p.customer_id
	       GROUP BY c.customer_id
	       ORDER BY total_spent DESC
	       LIMIT 1) t1)
GROUP BY 1, 2
ORDER BY 1;
