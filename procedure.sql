DELIMITER $$

DROP PROCEDURE IF EXISTS top10FilmesMaisAlugadosPorLojaECategoria$$

CREATE PROCEDURE top10FilmesMaisAlugadosPorLojaECategoria(
    IN p_categoria VARCHAR(100),
    IN p_loja_id INT
)
BEGIN
	-- Lança um erro se a categoria estiver vazia
	IF p_categoria IS NULL OR TRIM(p_categoria) = '' THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'O campo de categoria está vazio!' ;
	END IF;
	
	-- Lança um erro se a categoria não existir
	IF NOT EXISTS (
		SELECT 1 FROM category 
		WHERE name LIKE CONCAT('%', p_categoria, '%')
	) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Essa categoria não existe!' ;
	END IF;

	-- Lança um erro caso a loja não exista na tabela store
	IF NOT EXISTS (SELECT 1 FROM store WHERE store_id = p_loja_id) THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = "Essa loja não existe!";
	END IF;
	
	-- Consulta
    SELECT
        f.title AS filme,
        COUNT(r.rental_id) AS total_alugueis,
        p_categoria AS categoria,
        i.store_id  AS id_loja
    FROM rental r
    INNER JOIN inventory i ON r.inventory_id = i.inventory_id
    INNER JOIN film f ON i.film_id = f.film_id
    INNER JOIN film_category fc ON f.film_id = fc.film_id
    INNER JOIN category c ON fc.category_id = c.category_id
    WHERE c.name LIKE CONCAT('%', p_categoria, '%') AND i.store_id = p_loja_id
    GROUP BY f.film_id, f.title
    ORDER BY total_alugueis DESC, filme ASC
    LIMIT 10;
END$$

DELIMITER ;