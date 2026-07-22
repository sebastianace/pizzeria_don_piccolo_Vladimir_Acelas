-- =====================================================================
--  PROYECTO: Pizzería Don Piccolo   |   ARCHIVO: funciones.sql
--  Funciones y procedimiento almacenado. Ejecutar DESPUÉS de database.sql.
-- =====================================================================
USE pizzeria_don_piccolo;

-- Evita el Error 1175 (safe update mode) de MySQL Workbench.
SET SQL_SAFE_UPDATES = 0;

-- FUNCIÓN 1: total del pedido = pizzas + envío + IVA (8%)
DROP FUNCTION IF EXISTS fn_total_pedido;
DELIMITER //
CREATE FUNCTION fn_total_pedido(p_id_pedido INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_subtotal DECIMAL(10,2) DEFAULT 0;
    DECLARE v_envio    DECIMAL(10,2) DEFAULT 0;
    DECLARE v_iva      DECIMAL(10,2) DEFAULT 0;
    DECLARE v_tasa_iva DECIMAL(4,2)  DEFAULT 0.08;
    SELECT COALESCE(SUM(precio_unitario * cantidad), 0) INTO v_subtotal
      FROM detalle_pedido WHERE id_pedido = p_id_pedido;
    SELECT COALESCE(SUM(costo_envio), 0) INTO v_envio
      FROM domicilios WHERE id_pedido = p_id_pedido;
    SET v_iva = v_subtotal * v_tasa_iva;
    RETURN v_subtotal + v_envio + v_iva;
END //
DELIMITER ;

-- FUNCIÓN 2: ganancia neta diaria = ventas - costo de ingredientes
DROP FUNCTION IF EXISTS fn_ganancia_neta_diaria;
DELIMITER //
CREATE FUNCTION fn_ganancia_neta_diaria(p_fecha DATE)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_ventas DECIMAL(12,2) DEFAULT 0;
    DECLARE v_costos DECIMAL(12,2) DEFAULT 0;
    SELECT COALESCE(SUM(fn_total_pedido(p.id_pedido)), 0) INTO v_ventas
      FROM pedidos p
     WHERE DATE(p.fecha_hora) = p_fecha AND p.estado <> 'cancelado';
    SELECT COALESCE(SUM(dp.cantidad * pi.cantidad * ing.costo_unitario), 0) INTO v_costos
      FROM pedidos p
      JOIN detalle_pedido dp     ON dp.id_pedido = p.id_pedido
      JOIN pizza_ingredientes pi ON pi.id_pizza  = dp.id_pizza
      JOIN ingredientes ing      ON ing.id_ingrediente = pi.id_ingrediente
     WHERE DATE(p.fecha_hora) = p_fecha AND p.estado <> 'cancelado';
    RETURN v_ventas - v_costos;
END //
DELIMITER ;

-- PROCEDIMIENTO: registra la hora de entrega y marca el pedido 'entregado'
DROP PROCEDURE IF EXISTS sp_registrar_entrega;
DELIMITER //
CREATE PROCEDURE sp_registrar_entrega(IN p_id_pedido INT, IN p_hora_entrega DATETIME)
BEGIN
    UPDATE domicilios SET hora_entrega = p_hora_entrega WHERE id_pedido = p_id_pedido;
    UPDATE pedidos    SET estado = 'entregado'          WHERE id_pedido = p_id_pedido;
END //
DELIMITER ;

-- Rellenar la columna 'total' de los pedidos ya cargados.
-- CORRECCIÓN Error 1175: el WHERE por clave primaria evita el safe update mode.
UPDATE pedidos SET total = fn_total_pedido(id_pedido) WHERE id_pedido > 0;

-- FUNCION ADICIONAL DEL EXAMEN: 
-- Total de cada pedido = suma de (precio_unitario * cantidad)
UPDATE pedidos p
   SET p.total = (
        SELECT COALESCE(SUM(dp.precio_unitario * dp.cantidad), 0)
          FROM detalle_pedido dp
         WHERE dp.id_pedido = p.id_pedido
   )
 WHERE p.id_pedido > 0;
-- ============================ FIN funciones.sql ====================