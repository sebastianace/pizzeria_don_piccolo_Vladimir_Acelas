-- =====================================================================
--  PROYECTO: Pizzería Don Piccolo   |   ARCHIVO: vistas.sql
--  Vistas de reporte. Ejecutar DESPUÉS de database.sql y funciones.sql.
-- =====================================================================
USE pizzeria_don_piccolo;

-- 1) Resumen de pedidos por cliente
DROP VIEW IF EXISTS vista_resumen_pedidos_cliente;
CREATE VIEW vista_resumen_pedidos_cliente AS
SELECT c.id_cliente, c.nombre,
       COUNT(p.id_pedido) AS cantidad_pedidos,
       COALESCE(SUM(p.total), 0) AS total_gastado
  FROM clientes c
  LEFT JOIN pedidos p ON p.id_cliente = c.id_cliente AND p.estado <> 'cancelado'
 GROUP BY c.id_cliente, c.nombre;

-- 2) Desempeño de repartidores
DROP VIEW IF EXISTS vista_desempeno_repartidores;
CREATE VIEW vista_desempeno_repartidores AS
SELECT r.id_repartidor, r.nombre, r.zona,
       COUNT(d.id_domicilio) AS numero_entregas,
       ROUND(AVG(TIMESTAMPDIFF(MINUTE, d.hora_salida, d.hora_entrega)), 1) AS tiempo_promedio_min
  FROM repartidores r
  LEFT JOIN pedidos    p ON p.id_repartidor = r.id_repartidor
  LEFT JOIN domicilios d ON d.id_pedido = p.id_pedido AND d.hora_entrega IS NOT NULL
 GROUP BY r.id_repartidor, r.nombre, r.zona;

-- 3) Ingredientes por debajo del mínimo
DROP VIEW IF EXISTS vista_stock_bajo;
CREATE VIEW vista_stock_bajo AS
SELECT id_ingrediente, nombre, stock, stock_minimo, unidad,
       (stock_minimo - stock) AS faltante
  FROM ingredientes
 WHERE stock <= stock_minimo;

-- SELECT * FROM vista_resumen_pedidos_cliente ORDER BY total_gastado DESC;
-- SELECT * FROM vista_desempeno_repartidores;
-- SELECT * FROM vista_stock_bajo;
-- ============================ FIN vistas.sql =======================