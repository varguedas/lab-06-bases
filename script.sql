CREATE DATABASE IF NOT EXISTS hashy;
USE hashy;

DELIMITER $$

DROP FUNCTION IF EXISTS fn_cernidor $$
CREATE FUNCTION fn_cernidor(p_id INT)
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE v_es_primo BOOLEAN DEFAULT TRUE;
    DECLARE v_divisor INT DEFAULT 2;
    DECLARE v_limite INT DEFAULT 0;
    DECLARE v_resultado BOOLEAN DEFAULT FALSE;

    IF p_id IS NULL THEN
        SET v_resultado = FALSE;
    ELSE
        IF p_id <= 1 THEN
            SET v_es_primo = FALSE;
        ELSE
            SET v_limite = FLOOR(SQRT(p_id));

            WHILE v_divisor <= v_limite DO
                IF MOD(p_id, v_divisor) = 0 THEN
                    SET v_es_primo = FALSE;
                    SET v_divisor = v_limite + 1;
                ELSE
                    SET v_divisor = v_divisor + 1;
                END IF;
            END WHILE;
        END IF;

        SET v_resultado = v_es_primo;
    END IF;

    RETURN v_resultado;
END $$

DELIMITER ;