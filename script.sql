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

DROP FUNCTION IF EXISTS fn_reloj_arena $$
CREATE FUNCTION fn_reloj_arena(p_fecha DATE, p_meses INT)
RETURNS VARCHAR(10)
DETERMINISTIC
BEGIN
    DECLARE v_fecha_actual DATE;
    DECLARE v_fecha_vencimiento DATE;
    DECLARE v_estado VARCHAR(10);

    SET v_fecha_actual = CURDATE();

    IF p_fecha IS NULL OR p_meses IS NULL THEN
        SET v_estado = 'Expirado';
    ELSE
        SET v_fecha_vencimiento = DATE_ADD(p_fecha, INTERVAL p_meses MONTH);

        IF v_fecha_vencimiento > v_fecha_actual THEN
            SET v_estado = 'Fresco';
        ELSE
            SET v_estado = 'Expirado';
        END IF;
    END IF;

    RETURN v_estado;
END $$

DELIMITER ;

--Persona B
--LLAVE 3
CREATE DATABASE IF NOT EXISTS hashy;
USE hashy;

DROP FUNCTION IF EXISTS fn_espia_tortuga;
DROP FUNCTION IF EXISTS fn_purificador;

DELIMITER $$

CREATE FUNCTION fn_espia_tortuga(
    p_categoria VARCHAR(100),
    p_precio_finca DECIMAL(10,2)
)
RETURNS DECIMAL(3,2)
DETERMINISTIC
BEGIN
    DECLARE v_precio_referencia DECIMAL(10,2);
    DECLARE v_factor DECIMAL(3,2);

    IF p_categoria IS NULL OR p_precio_finca IS NULL THEN
        SET v_factor = 1.0;
    ELSE
        SELECT AVG(precio_referencia)
        INTO v_precio_referencia
        FROM mercado_negro
        WHERE categoria = p_categoria;

        IF v_precio_referencia IS NULL THEN
            SET v_factor = 1.0;
        ELSE
            IF p_precio_finca > v_precio_referencia THEN
                SET v_factor = 1.2;
            ELSE
                SET v_factor = 0.8;
            END IF;
        END IF;
    END IF;

    RETURN v_factor;
END $$

CREATE FUNCTION fn_purificador(
    p_nombre_sucio TEXT
)
RETURNS TEXT
DETERMINISTIC
BEGIN
    DECLARE v_texto_limpio TEXT;
    DECLARE v_resultado TEXT;

    IF p_nombre_sucio IS NULL THEN
        SET v_resultado = '';
    ELSE
        SET v_texto_limpio = REGEXP_REPLACE(p_nombre_sucio, '[^A-Za-z]', '');
        SET v_resultado = TRIM(v_texto_limpio);
    END IF;

    RETURN v_resultado;
END $$

DELIMITER ;