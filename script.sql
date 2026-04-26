--LAB 6 
--JIMENA MARIN GOMEZ, DIANA SOLANO RETANA, VICTORIA ARGUEDAS CHACON

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
DELIMITER $$
DROP FUNCTION IF EXISTS fn_espia_tortuga $$
DROP FUNCTION IF EXISTS fn_purificador $$


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

--Persona C
--LLAVE 5
DELIMITER $$
DROP FUNCTION IF EXISTS fn_escultor $$



CREATE FUNCTION fn_escultor(
    p_texto TEXT,
    p_factor DECIMAL(3,2)
)
RETURNS TEXT
DETERMINISTIC
BEGIN
    DECLARE v_texto_base TEXT;
    DECLARE v_texto_transformado TEXT;
    DECLARE v_sufijo VARCHAR(50);
    DECLARE v_resultado TEXT;

    IF p_texto IS NULL THEN
        SET v_texto_base = '';
    ELSE
        SET v_texto_base = p_texto;
    END IF;

    IF p_factor IS NULL THEN
        SET p_factor = 1.0;
    END IF;

    IF p_factor > 1 THEN
        SET v_texto_transformado = UPPER(v_texto_base);
        SET v_sufijo = ' - ALTA PRIORIDAD';
    ELSE
        SET v_texto_transformado = LOWER(v_texto_base);
        SET v_sufijo = ' - baja prioridad';
    END IF;

    SET v_resultado = CONCAT(v_texto_transformado, v_sufijo);

    RETURN v_resultado;
END $$

DELIMITER ;

--Llave 6
DELIMITER $$
DROP FUNCTION IF EXISTS fn_notario $$



CREATE FUNCTION fn_notario(
    p_texto TEXT
)
RETURNS TEXT
DETERMINISTIC
MODIFIES SQL DATA
BEGIN
    DECLARE v_usuario VARCHAR(100);
    DECLARE v_mensaje TEXT;
    DECLARE v_resultado TEXT;

    IF p_texto IS NULL THEN
        SET v_resultado = '';
    ELSE
        SET v_resultado = p_texto;
    END IF;

    SET v_usuario = CURRENT_USER();
    SET v_mensaje = CONCAT('Texto procesado: ', v_resultado);

    INSERT INTO logs_hashy (
        nombre_funcion,
        fecha_ejecucion,
        mensaje_accion,
        usuario_db
    )
    VALUES (
        'fn_notario',
        CURRENT_TIMESTAMP,
        v_mensaje,
        v_usuario
    );

    RETURN v_resultado;
END $$

DELIMITER ;

--Llave 7
DELIMITER $$
DROP FUNCTION IF EXISTS fn_gran_sello $$



CREATE FUNCTION fn_gran_sello(
    p_texto TEXT
)
RETURNS VARCHAR(255)
DETERMINISTIC
BEGIN
    DECLARE v_texto_base TEXT;
    DECLARE v_hash VARCHAR(255);
    DECLARE v_resultado VARCHAR(255);

    IF p_texto IS NULL THEN
        SET v_texto_base = '';
    ELSE
        SET v_texto_base = p_texto;
    END IF;

    SET v_hash = MD5(v_texto_base);
    SET v_resultado = v_hash;

    RETURN v_resultado;
END $$

DELIMITER ;
USE hashy;
--Consulta maestra final
SELECT 
GROUP_CONCAT(
    fn_gran_sello(
        fn_notario(
            fn_escultor(
                fn_purificador(ip.nombre_sucio),
                fn_espia_tortuga(ip.categoria, ip.precio_finca)
            )
        )
    )
) AS resultado_final
FROM inventario_pirata ip
WHERE 
    fn_cernidor(ip.id) = TRUE
    AND fn_reloj_arena(ip.fecha_ingreso, ip.meses_validez) = 'Fresco';

--Fin del script
