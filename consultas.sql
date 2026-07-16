-- =====================================================================
--  PROYECTO: Pizzería Don Piccolo
--  ARCHIVO : consultas.sql
--  CONTENIDO: Consultas SQL requeridas por el negocio.
--    Operadores y técnicas: BETWEEN, GROUP BY, COUNT, JOIN, AVG,
--    HAVING, LIKE y subconsultas.
--  NOTA: ejecutar DESPUÉS de database.sql, funciones.sql y triggers.sql.
-- =====================================================================
USE pizzeria_don_piccolo;

-- ---------------------------------------------------------------------
-- CONSULTA 1: Clientes con pedidos entre dos fechas  (BETWEEN)
--   Lista los clientes y sus pedidos realizados en un rango de fechas.
-- ---------------------------------------------------------------------
SELECT c.id_cliente,
       c.nombre,
       p.id_pedido,
       p.fecha_hora,
       p.total
  FROM clientes c
  JOIN pedidos  p ON p.id_cliente = c.id_cliente
 WHERE p.fecha_hora BETWEEN '2026-07-05 00:00:00' AND '2026-07-08 23:59:59'
 ORDER BY p.fecha_hora;

-- ---------------------------------------------------------------------
-- CONSULTA 2: Pizzas más vendidas  (GROUP BY + COUNT/SUM)
--   Cantidad total de unidades vendidas por pizza, de mayor a menor.
-- ---------------------------------------------------------------------
SELECT pz.id_pizza,
       pz.nombre,
       COUNT(dp.id_detalle)   AS veces_pedida,
       SUM(dp.cantidad)       AS unidades_vendidas
  FROM pizzas pz
  JOIN detalle_pedido dp ON dp.id_pizza = pz.id_pizza
 GROUP BY pz.id_pizza, pz.nombre
 ORDER BY unidades_vendidas DESC;

-- ---------------------------------------------------------------------
-- CONSULTA 3: Pedidos por repartidor  (JOIN)
--   Número de pedidos gestionados por cada repartidor.
-- ---------------------------------------------------------------------
SELECT r.id_repartidor,
       r.nombre,
       r.zona,
       COUNT(p.id_pedido) AS total_pedidos
  FROM repartidores r
  LEFT JOIN pedidos p ON p.id_repartidor = r.id_repartidor
 GROUP BY r.id_repartidor, r.nombre, r.zona
 ORDER BY total_pedidos DESC;

-- ---------------------------------------------------------------------
-- CONSULTA 4: Promedio de tiempo de entrega por zona  (AVG + JOIN)
--   Minutos promedio entre la salida y la entrega, agrupado por zona.
-- ---------------------------------------------------------------------
SELECT r.zona,
       COUNT(d.id_domicilio) AS entregas,
       ROUND(AVG(TIMESTAMPDIFF(MINUTE, d.hora_salida, d.hora_entrega)), 1)
           AS minutos_promedio
  FROM domicilios  d
  JOIN pedidos     p ON p.id_pedido     = d.id_pedido
  JOIN repartidores r ON r.id_repartidor = p.id_repartidor
 WHERE d.hora_salida IS NOT NULL
   AND d.hora_entrega IS NOT NULL
 GROUP BY r.zona
 ORDER BY minutos_promedio;

-- ---------------------------------------------------------------------
-- CONSULTA 5: Clientes que gastaron más de un monto  (HAVING)
--   Total gastado por cliente, filtrando solo los que superan $80.000.
-- ---------------------------------------------------------------------
SELECT c.id_cliente,
       c.nombre,
       SUM(p.total) AS total_gastado
  FROM clientes c
  JOIN pedidos  p ON p.id_cliente = c.id_cliente
 WHERE p.estado <> 'cancelado'
 GROUP BY c.id_cliente, c.nombre
HAVING SUM(p.total) > 80000
 ORDER BY total_gastado DESC;

-- ---------------------------------------------------------------------
-- CONSULTA 6: Búsqueda parcial por nombre de pizza  (LIKE)
--   Busca pizzas cuyo nombre contenga el texto 'pe' (ej. Pepperoni).
-- ---------------------------------------------------------------------
SELECT id_pizza,
       nombre,
       tamano,
       precio_base,
       tipo
  FROM pizzas
 WHERE nombre LIKE '%pe%';

-- ---------------------------------------------------------------------
-- CONSULTA 7: Clientes frecuentes  (SUBCONSULTA)
--   Clientes con más de 5 pedidos dentro del mes actual.
--   La subconsulta cuenta los pedidos del mes por cliente.
-- ---------------------------------------------------------------------
SELECT c.id_cliente,
       c.nombre,
       c.telefono
  FROM clientes c
 WHERE c.id_cliente IN (
        SELECT p.id_cliente
          FROM pedidos p
         WHERE MONTH(p.fecha_hora) = MONTH(CURRENT_DATE)
           AND YEAR(p.fecha_hora)  = YEAR(CURRENT_DATE)
         GROUP BY p.id_cliente
        HAVING COUNT(p.id_pedido) > 5
 );


-- =====================================================================
--  FIN consultas.sql
-- =====================================================================
