# 🍕 Pizzería Don Piccolo — Sistema de Gestión de Pedidos y Domicilios

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

<<<<<<< HEAD
`sp_actualizar_estado_pedido(id_pedido, nuevo_estado)` — procedimiento que
cambia el estado de un pedido, pero **valida primero** que no esté cancelado;
si lo está, rechaza el cambio con un error controlado
(`SIGNAL SQLSTATE '45000'`). Esto evita que, por error, se reactive o
modifique un pedido que ya fue cancelado.
=======
El sistema tiene **10 tablas**. El siguiente diagrama entidad-relación muestra su
estructura y las llaves foráneas que las conectan:

![Diagrama entidad-relación de la base de datos](imagenes/diagrama_er.png)

| Tabla | Descripción | Relaciones principales |
|-------|-------------|------------------------|
| **clientes** | Datos del cliente (nombre, teléfono, dirección, correo). | 1:N con `pedidos`. |
| **pizzas** | Catálogo (nombre, tamaño, precio base, tipo). | N:M con `ingredientes`; 1:N con `detalle_pedido`. |
| **ingredientes** | Inventario con `stock`, `stock_minimo` y `costo_unitario`. | N:M con `pizzas`. |
| **pizza_ingredientes** | Receta: cantidad de cada ingrediente por pizza. | FK a `pizzas` y a `ingredientes`. |
| **repartidores** | Nombre, zona y estado (disponible / no_disponible). | 1:N con `pedidos`. |
| **pedidos** | Encabezado del pedido (cliente, fecha, método de pago, estado, total). | FK a `clientes` y `repartidores`; 1:N con `detalle_pedido`; 1:1 con `domicilios`; 1:N con `pagos`. |
| **detalle_pedido** | Líneas del pedido: pizza, cantidad y precio unitario. | FK a `pedidos` y `pizzas`. |
| **domicilios** | Logística de entrega (salida, entrega, distancia, costo). | 1:1 con `pedidos`. |
| **pagos** | Pago asociado a un pedido. | FK a `pedidos`. |
| **historial_precios** | Auditoría de cambios de precio de pizzas (la llena un trigger). | FK a `pizzas`. |

### Relaciones clave
- Un **cliente** hace muchos **pedidos** (1:N).
- Un **pedido** contiene muchas **pizzas** a través de `detalle_pedido` (N:M).
- Una **pizza** se compone de muchos **ingredientes** a través de `pizza_ingredientes` (N:M).
- Un **pedido** tiene un solo **domicilio** (1:1) y puede tener uno o varios **pagos** (1:N).
- Un **repartidor** atiende muchos **pedidos** (1:N).

---

## 4. Funciones, procedimientos y triggers

**Funciones**
- `fn_total_pedido(id_pedido)` → total = Σ(precio × cantidad) + envío + IVA (8 %).
- `fn_ganancia_neta_diaria(fecha)` → ventas del día − costo de ingredientes.

**Procedimiento**
- `sp_registrar_entrega(id_pedido, hora_entrega)` → registra la entrega y cambia el estado del pedido a `entregado`.

**Triggers**
- `trg_actualizar_stock` — descuenta ingredientes al vender.
- `trg_historial_precios` — audita cambios de precio de pizzas.
- `trg_repartidor_disponible` — libera al repartidor al registrar la entrega.
- `trg_repartidor_ocupado` *(apoyo)* — ocupa al repartidor al salir el domicilio.

---

## 5. Consultas incluidas y evidencias

A continuación las 7 consultas requeridas con su evidencia de ejecución:

### 5.1. Clientes con pedidos entre dos fechas — `BETWEEN`
![Consulta 1 - clientes por fecha](imagenes/consulta_1_clientes_por_fecha.png)

### 5.2. Pizzas más vendidas — `GROUP BY` + `COUNT` / `SUM`
![Consulta 2 - pizzas más vendidas](imagenes/consulta_2_pizzas_mas_vendidas.png)

### 5.3. Pedidos por repartidor — `JOIN`
![Consulta 3 - pedidos por repartidor](imagenes/consulta_3_pedidos_por_repartidor.png)

### 5.4. Promedio de tiempo de entrega por zona — `AVG` + `JOIN`
![Consulta 4 - promedio de entrega por zona](imagenes/consulta_4_promedio_entrega_zona.png)

### 5.5. Clientes que gastaron más de un monto — `HAVING`
![Consulta 5 - clientes con mayor gasto](imagenes/consulta_5_clientes_mayor_gasto.png)

### 5.6. Búsqueda parcial por nombre de pizza — `LIKE`
![Consulta 6 - búsqueda por nombre de pizza](imagenes/consulta_6_busqueda_pizza.png)

### 5.7. Clientes frecuentes (> 5 pedidos mensuales) — `SUBCONSULTA`
![Consulta 7 - clientes frecuentes](imagenes/consulta_7_clientes_frecuentes.png)

---

## 6. Vistas (`vistas.sql`)
- `vista_resumen_pedidos_cliente` — nombre del cliente, cantidad de pedidos y total gastado.
- `vista_desempeno_repartidores` — número de entregas, tiempo promedio y zona.
- `vista_stock_bajo` — ingredientes cuyo stock está por debajo del mínimo.

---

## 7. Instrucciones para ejecutar el script

**Opción A — Consola / Workbench (SOURCE):**
>>>>>>> b965c8bea0f7c75458da94603346b8329e51b083

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




---

**Autor:** vladimir acelas · Proyecto Pizzería Don Piccolo
