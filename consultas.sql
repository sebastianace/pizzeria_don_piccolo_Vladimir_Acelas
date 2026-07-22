-- =====================================================================
--  PROYECTO: Pizzería Don Piccolo
--  ARCHIVO : consultas.sql
--  CONTENIDO: Consultas SQL requeridas por el negocio.
--    Operadores y técnicas: BETWEEN, GROUP BY, COUNT, JOIN, AVG,
--    HAVING, LIKE y subconsultas.
--  NOTA: ejecutar DESPUÉS de database.sql, funciones.sql y triggers.sql.
-- =====================================================================
USE pizzeria_don_piccolo;

-- 3) CONSULTAS DE GESTIÓN (para el gerente)
-- ---------------------------------------------------------------------

-- 3.1) consulta de pedidos por cliente y por metodo de pago
SELECT p.id_pedido, c.nombre AS cliente, p.fecha_hora,
       p.metodo_pago, p.estado, p.total
  FROM pedidos p
  JOIN clientes c ON c.id_cliente = p.id_cliente
 ORDER BY p.fecha_hora DESC;


-- 3.3) Pedidos pendientes o en preparación (lo que el gerente atiende HOY)
SELECT p.id_pedido, c.nombre AS cliente, p.fecha_hora, p.estado
  FROM pedidos p
  JOIN clientes c ON c.id_cliente = p.id_cliente
 WHERE p.estado IN ('pendiente', 'en_preparacion')
 ORDER BY p.fecha_hora;

-- 3.4) Cantidad de pedidos y total vendido, agrupado por estado
SELECT estado, COUNT(*) AS cantidad_pedidos, SUM(total) AS total_por_estado
  FROM pedidos
 GROUP BY estado;

-- 3.5) Pizzas más pedidas (para saber qué preparar con anticipación)
SELECT pz.nombre, SUM(dp.cantidad) AS unidades_pedidas
  FROM detalle_pedido dp
  JOIN pizzas pz ON pz.id_pizza = dp.id_pizza
 GROUP BY pz.id_pizza, pz.nombre
 ORDER BY unidades_pedidas DESC;

-- 3.6) Clientes mas frecuentes (HAVING) — útil para fidelización
SELECT c.nombre, COUNT(p.id_pedido) AS pedidos, SUM(p.total) AS total_gastado
  FROM clientes c
  JOIN pedidos p ON p.id_cliente = c.id_cliente
 WHERE p.estado <> 'cancelado'
 GROUP BY c.id_cliente, c.nombre
HAVING SUM(p.total) > 50000
 ORDER BY total_gastado DESC;
