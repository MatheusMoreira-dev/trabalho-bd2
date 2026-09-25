CREATE VIEW vw_alugueis_detalhados AS

SELECT
    r.rental_date AS data_aluguel,
    c.first_name AS nome_cliente,
    c.last_name AS sobrenome_cliente,
    f.title AS filme,
    cat.name AS categoria,
    p.amount AS valor

FROM rental r

JOIN customer c
    ON r.customer_id = c.customer_id

JOIN inventory i
    ON r.inventory_id = i.inventory_id

JOIN film f
    ON i.film_id = f.film_id

JOIN film_category fc
    ON f.film_id = fc.film_id

JOIN category cat
    ON fc.category_id = cat.category_id

JOIN payment p
    ON r.rental_id = p.rental_id;
