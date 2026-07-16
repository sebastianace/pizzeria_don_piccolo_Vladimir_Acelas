-- =====================================================================
--  PROYECTO: Pizzería Don Piccolo   |   ARCHIVO: triggers.sql
--  Triggers. Ejecutar DESPUÉS de database.sql y funciones.sql.
-- =====================================================================
USE pizzeria_don_piccolo;

-- 1) Descuenta stock de ingredientes al vender
DROP TRIGGER IF EXISTS trg_actualizar_stock;
DELIMITER //
CREATE TRIGGER trg_actualizar_stock
AFTER INSERT ON detalle_pedido
FOR EACH ROW
BEGIN
    UPDATE ingredientes ing
      JOIN pizza_ingredientes pi ON pi.id_ingrediente = ing.id_ingrediente
       SET ing.stock = ing.stock - (pi.cantidad * NEW.cantidad)
     WHERE pi.id_pizza = NEW.id_pizza;
END //
DELIMITER ;

-- 2) Auditoría: registra cambios de precio de pizzas
DROP TRIGGER IF EXISTS trg_historial_precios;
DELIMITER //
CREATE TRIGGER trg_historial_precios
AFTER UPDATE ON pizzas
FOR EACH ROW
BEGIN
    IF NEW.precio_base <> OLD.precio_base THEN
        INSERT INTO historial_precios (id_pizza, precio_anterior, precio_nuevo)
        VALUES (OLD.id_pizza, OLD.precio_base, NEW.precio_base);
    END IF;
END //
DELIMITER ;

-- 3) Libera al repartidor cuando se registra la entrega
DROP TRIGGER IF EXISTS trg_repartidor_disponible;
DELIMITER //
CREATE TRIGGER trg_repartidor_disponible
AFTER UPDATE ON domicilios
FOR EACH ROW
BEGIN
    IF NEW.hora_entrega IS NOT NULL
       AND (OLD.hora_entrega IS NULL OR OLD.hora_entrega <> NEW.hora_entrega) THEN
        UPDATE repartidores r
          JOIN pedidos p ON p.id_repartidor = r.id_repartidor
           SET r.estado = 'disponible'
         WHERE p.id_pedido = NEW.id_pedido;
    END IF;
END //
DELIMITER ;

-- (Apoyo) Ocupa al repartidor al crear un domicilio con hora de salida
DROP TRIGGER IF EXISTS trg_repartidor_ocupado;
DELIMITER //
CREATE TRIGGER trg_repartidor_ocupado
AFTER INSERT ON domicilios
FOR EACH ROW
BEGIN
    IF NEW.hora_salida IS NOT NULL AND NEW.hora_entrega IS NULL THEN
        UPDATE repartidores r
          JOIN pedidos p ON p.id_repartidor = r.id_repartidor
           SET r.estado = 'no_disponible'
         WHERE p.id_pedido = NEW.id_pedido;
    END IF;
END //
DELIMITER ;
-- ============================ FIN triggers.sql =====================