CREATE TABLE rental_audit_log (
    audit_id INT NOT NULL AUTO_INCREMENT,
    event_timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    db_user VARCHAR(255) NOT NULL,
    operation VARCHAR(20) NOT NULL,
    customer_id SMALLINT UNSIGNED NOT NULL,
    rental_id INT NULL,
    problem_description VARCHAR(500) NOT NULL,
    PRIMARY KEY (audit_id)
);

DELIMITER $$

CREATE TRIGGER trg_rental_before_insert
BEFORE INSERT ON rental
FOR EACH ROW
BEGIN
    DECLARE qtd_alugueis_abertos INT DEFAULT 0;

    SELECT COUNT(*)
    INTO qtd_alugueis_abertos
    FROM rental
    WHERE customer_id = NEW.customer_id
      AND return_date IS NULL;

    IF qtd_alugueis_abertos > 0 THEN

        INSERT INTO rental_audit_log (
            db_user,
            operation,
            customer_id,
            rental_id,
            problem_description
        )
        VALUES (
            CURRENT_USER(),
            'INSERT',
            NEW.customer_id,
            NULL,
            'Tentativa de realizar novo aluguel enquanto o cliente ainda possui um aluguel em aberto.'
        );

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'OPERACAO BLOQUEADA: o cliente possui um aluguel em aberto.';

    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_rental_before_update
BEFORE UPDATE ON rental
FOR EACH ROW
BEGIN
    DECLARE qtd_alugueis_abertos INT DEFAULT 0;

    IF NEW.return_date IS NULL THEN

        SELECT COUNT(*)
        INTO qtd_alugueis_abertos
        FROM rental
        WHERE customer_id = NEW.customer_id
          AND return_date IS NULL
          AND rental_id <> OLD.rental_id;

        IF qtd_alugueis_abertos > 0 THEN

            INSERT INTO rental_audit_log (
                db_user,
                operation,
                customer_id,
                rental_id,
                problem_description
            )
            VALUES (
                CURRENT_USER(),
                'UPDATE',
                NEW.customer_id,
                NEW.rental_id,
                'Tentativa de criar um segundo aluguel em aberto para o mesmo cliente.'
            );

            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
            'OPERACAO BLOQUEADA: o cliente ja possui outro aluguel em aberto.';

        END IF;

    END IF;
END$$

DELIMITER ;
