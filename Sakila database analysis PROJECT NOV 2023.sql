-- staff members who have handled more than 200 rentals and their respective rental counts

SELECT first_name, last_name, Count(*) rental_total
FROM rental
JOIN staff
ON rental.staff_id = staff.staff_id
GROUP BY first_name, last_name
HAVING rental_total > 200
;

-- Most popular film categories based on the number of rentals made
SELECT c.category_id, name, count(rental_id) total_rentals
FROM rental r
JOIN inventory i
ON i.inventory_id = r.inventory_id
JOIN film_category fc
ON fc.film_id = i.film_id
JOIN category c
ON c.category_id = fc.category_id
GROUP BY category_id,name 
ORDER BY total_rentals DESC
LIMIT 5;

-- Rental durations of movies that lasted longer than 5 days and which films fall under this category
SELECT title films, rental_duration
FROM film
WHERE rental_duration > 5;

-- Which films have a rating of "PG - 13", and how many times have they been rented?
SELECT f.film_id, title film, rating, count(rental_id) no_times_rented
FROM film f
JOIN inventory i
ON i.film_id = f.film_id
JOIN rental r 
ON r.inventory_id = i.inventory_id
WHERE rating = "PG-13"
GROUP BY film_id, film;

-- What are the top 10 highest-grossing films in terms of rental revenue?
SELECT title film, SUM(amount) rental_revenue
FROM film f
JOIN inventory i
ON f.film_id = i.film_id
JOIN rental r
ON r.inventory_id = i.inventory_id
JOIN payment p
ON p.rental_id = r.rental_id
GROUP BY film
ORDER BY rental_revenue DESC
LIMIT 10;

