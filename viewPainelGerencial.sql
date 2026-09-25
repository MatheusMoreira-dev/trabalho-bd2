CREATE VIEW vw_painel_gerencial AS

SELECT
    cat.name AS categoria,
    COUNT(r.rental_id) AS quantidade_alugueis,
    SUM(p.amount) AS receita_total,
    AVG(p.amount) AS ticket_medio

FROM rental r

JOIN inventory i
    ON r.inventory_id = i.inventory_id

JOIN film f
    ON i.film_id = f.film_id

JOIN film_category fc
    ON f.film_id = fc.film_id

JOIN category cat
    ON fc.category_id = cat.category_id

JOIN payment p
    ON r.rental_id = p.rental_id

GROUP BY cat.name;
