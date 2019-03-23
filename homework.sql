USE sakila;
-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. 
-- Name the column Actor Name.
SELECT CONCAT(first_name, ' ', last_name) AS 'Actor Name' FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, 
-- of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name FROM actor
WHERE first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT * FROM actor
WHERE last_name LIKE "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:
SELECT * FROM actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: 
-- Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");

-- 3a. You want to keep a description of each actor. 
-- You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB 
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor
ADD COLUMN description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
-- Delete the description column.
ALTER TABLE actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(last_name) FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
SELECT a.last_name, a.`count(last_name)`
FROM (
	SELECT last_name, count(last_name) FROM actor
	GROUP BY last_name
    ) a
WHERE a.`count(last_name)` > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
-- Write a query to fix the record.
UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
-- It turns out that GROUCHO was the correct name after all! In a single query, 
-- if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO"

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
CREATE TABLE IF NOT EXISTS address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
-- Use the tables staff and address:
SELECT first_name, last_name, address FROM staff
INNER JOIN address ON staff.address_id = address.address_id;

-- 6b. PLACEHOLDER Use JOIN to display the total amount rung up by each staff member in August of 2005. 
-- Use tables staff and payment.
SELECT payment.staff_id, staff.first_name, staff.last_name, SUM(amount) FROM payment
LEFT JOIN staff ON staff.staff_id = payment.staff_id
WHERE substring(payment.payment_date, 1, 7) = '2005-08'
GROUP BY payment.staff_id;

-- 6c. List each film and the number of actors who are listed for that film.
-- Use tables film_actor and film. Use inner join.
SELECT title, count(title) FROM film
INNER JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(inventory.film_id), title FROM inventory
LEFT JOIN film ON film.film_id = inventory.film_id
where title = 'Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
SELECT customer.first_name, customer.last_name, SUM(payment.amount) FROM customer
INNER JOIN payment ON payment.customer_id = customer.customer_id
GROUP BY customer.customer_id;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title FROM film
WHERE language_id = (
	SELECT language_id FROM language
	where name = 'english'
    )
    AND
    ((substring(title, 1, 1) = 'K') OR substring(title, 1, 1) = 'Q');
    
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name FROM actor
WHERE actor_id IN (SELECT actor_id FROM film_actor
	WHERE film_id = (
		SELECT film_id FROM film
		WHERE title = 'Alone Trip'
		));

-- 7c. You want to run an email marketing campaign in Canada, 
-- for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.

SELECT first_name, last_name, email FROM customer
WHERE address_id IN (
	SELECT address_id FROM address
	WHERE city_id IN (
		SELECT city_id FROM city
		WHERE country_id = (SELECT country_id FROM country
			WHERE country = 'Canada'
		)));

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
SELECT * FROM film
	WHERE film_id IN (SELECT film_id FROM film_category
	WHERE category_id = (SELECT category_id FROM category
		WHERE name = 'Family'
		));
        
-- 7e. Display the most frequently rented movies in descending order.
SELECT title, `SUM(cid)` FROM FILM
INNER JOIN (
		SELECT film_id, SUM(cid) FROM (
		SELECT * FROM inventory
		INNER JOIN (SELECT inventory_id AS inv_id, count(inventory_id) AS cid FROM rental
			GROUP BY inventory_id
			ORDER BY count(inventory_id) DESC) c ON inventory.inventory_id = c.inv_id
			GROUP BY inventory.inventory_id) AS gr
		GROUP BY film_id
    ) AS big ON big.film_id = film.film_id
    ORDER BY `SUM(CID)` DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store_id, SUM(amount) FROM payment
INNER JOIN customer ON payment.customer_id = customer.customer_id
GROUP BY store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country FROM store
INNER JOIN address ON store.address_id = address.address_id
INNER JOIN city ON city.city_id = address.city_id
INNER JOIN country ON city.country_id = country.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT name, SUM(amount) FROM film_category
LEFT JOIN category ON film_category.category_id = category.category_id
RIGHT JOIN inventory ON inventory.film_id = film_category.film_id
RIGHT JOIN rental ON rental.inventory_id = inventory.inventory_id
INNER JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY name
ORDER BY `SUM(amount)` DESC;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing 
-- the Top five genres by gross revenue. Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top5 AS 
SELECT name, SUM(amount) FROM film_category
LEFT JOIN category ON film_category.category_id = category.category_id
RIGHT JOIN inventory ON inventory.film_id = film_category.film_id
RIGHT JOIN rental ON rental.inventory_id = inventory.inventory_id
INNER JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY name
ORDER BY `SUM(amount)` DESC
LIMIT 0,5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top5;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top5;
