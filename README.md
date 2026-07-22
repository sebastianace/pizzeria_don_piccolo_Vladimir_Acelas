# Examen — Módulo de Pedidos (Pizzería Don Piccolo)

## 1. Descripción del proyecto

La Pizzería Don Piccolo necesita controlar sus pedidos de forma más eficiente:
consultar, validar y actualizar el estado de las órdenes (pendiente, en
preparación, entregado, cancelado). Este módulo modela la tabla de **pedidos**
relacionada con **clientes** y **pizzas**, e incluye consultas orientadas a la
toma de decisiones del gerente.

## 2. Modelo de datos

| Tabla | Descripción | Relación |
|---|---|---|
| **clientes** | Quién hace el pedido. | 1:N con `pedidos`. |
| **pizzas** | Catálogo de productos disponibles. | 1:N con `detalle_pedido`. |
| **pedidos** | Encabezado: cliente, fecha, método de pago, estado y total. | FK a `clientes`; 1:N con `detalle_pedido`. |
| **detalle_pedido** | Pizzas incluidas en cada pedido, con cantidad y precio al momento de la venta. | FK a `pedidos` y `pizzas` (relación N:M pedido↔pizza). |

**Por qué este diseño:** un pedido puede incluir varias pizzas y una pizza
puede aparecer en muchos pedidos, por eso la relación es **N:M** y se resuelve
con la tabla intermedia `detalle_pedido`. Ahí se guarda `precio_unitario`
(no solo la referencia a `pizzas.precio_base`) para conservar el precio
histórico: si el precio de una pizza cambia después, los pedidos ya
facturados no se alteran.

## 3. Consultas incluidas

1. Listado de pedidos con cliente y total — `JOIN`, ordenado por fecha.
2. Detalle de pizzas de un pedido específico — `JOIN` triple (pedidos, detalle, pizzas).
3. Pedidos pendientes o en preparación — `WHERE ... IN (...)`, lo que el gerente atiende hoy.
4. Cantidad de pedidos y ventas por estado — `GROUP BY` + `SUM`.
5. Pizzas más pedidas — `GROUP BY` + `SUM`, para anticipar preparación.
6. Clientes que más gastan — `HAVING`, para fidelización.
7. Pedidos cancelados — para revisar pérdidas o motivos de cancelación.

## 4. Validación y actualización de pedidos

`sp_actualizar_estado_pedido(id_pedido, nuevo_estado)` — procedimiento que
cambia el estado de un pedido, pero **valida primero** que no esté cancelado;
si lo está, rechaza el cambio con un error controlado
(`SIGNAL SQLSTATE '45000'`). Esto evita que, por error, se reactive o
modifique un pedido que ya fue cancelado.

```sql
CALL sp_actualizar_estado_pedido(2, 'entregado');  -- funciona
CALL sp_actualizar_estado_pedido(4, 'entregado');  -- falla: pedido 4 está cancelado
```

## 5. Instrucciones para ejecutar

```bash
mysql -u root -p
SOURCE examen2_modulo_pedidos.sql;
```

El script crea las tablas (`IF NOT EXISTS`, no afecta un proyecto existente),
inserta datos de ejemplo, calcula los totales, corre las 7 consultas y crea
el procedimiento de validación.

