WITH alugueis_mes AS (
    SELECT 
        YEAR(rental.rental_date) AS ano,
        MONTH(rental.rental_date) AS mes,
        inventory.film_id,
        film.title,
        COUNT(*) AS total_aluguel_filme

    FROM rental
    JOIN inventory 
        ON rental.inventory_id = inventory.inventory_id
    JOIN film
        ON inventory.film_id = film.film_id

    GROUP BY 
        YEAR(rental.rental_date),
        MONTH(rental.rental_date),
        inventory.film_id,
        film.title
),

ranking_filmes AS (
    SELECT
        ano,
        mes,
        film_id,
        title,
        total_aluguel_filme,

        DENSE_RANK() OVER (
            PARTITION BY ano, mes
            ORDER BY total_aluguel_filme DESC
        ) AS ranking,
        
        SUM(total_aluguel_filme) OVER (
            PARTITION BY ano 
            ORDER BY mes
        ) AS acumulado_alugueis

    FROM alugueis_mes
)

SELECT
    ano,
    mes,
    film_id,
    title,
    total_aluguel_filme,
    ranking,
    acumulado_alugueis

FROM ranking_filmes

WHERE ranking <= 3

ORDER BY
    ano ASC,
    mes ASC,
    ranking ASC,
    total_aluguel_filme DESC;
