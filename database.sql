-- =====================================================================
--  PROYECTO: Pizzería Don Piccolo
--  ARCHIVO : database.sql
--  OBJETIVO: Creación de la base de datos, tablas, llaves foráneas, restricciones y datos de ejemplo.

-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. CREACIÓN DE LA BASE DE DATOS
-- ---------------------------------------------------------------------
SET SQL_SAFE_UPDATES = 0;   -- evita el Error 1175 en Workbench

DROP DATABASE IF EXISTS pizzeria_don_piccolo;
CREATE DATABASE pizzeria_don_piccolo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE pizzeria_don_piccolo;

CREATE TABLE clientes (
    id_cliente     INT AUTO_INCREMENT PRIMARY KEY,
    nombre         VARCHAR(100)  NOT NULL,
    telefono       VARCHAR(20)   NOT NULL,
    direccion      VARCHAR(200)  NOT NULL,
    correo         VARCHAR(120)  UNIQUE,
    fecha_registro DATE          NOT NULL DEFAULT (CURRENT_DATE)
) ENGINE=InnoDB;

CREATE TABLE pizzas (
    id_pizza     INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,
    tamano       ENUM('personal','mediana','familiar') NOT NULL,
    precio_base  DECIMAL(10,2) NOT NULL CHECK (precio_base >= 0),
    tipo         ENUM('vegetariana','especial','clasica') NOT NULL
) ENGINE=InnoDB;

CREATE TABLE ingredientes (
    id_ingrediente INT AUTO_INCREMENT PRIMARY KEY,
    nombre         VARCHAR(80) NOT NULL,
    stock          DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (stock >= 0),
    stock_minimo   DECIMAL(10,2) NOT NULL DEFAULT 0,
    unidad         VARCHAR(20)  NOT NULL DEFAULT 'unidad',
    costo_unitario DECIMAL(10,2) NOT NULL DEFAULT 0
) ENGINE=InnoDB;

CREATE TABLE pizza_ingredientes (
    id_pizza       INT NOT NULL,
    id_ingrediente INT NOT NULL,
    cantidad       DECIMAL(10,2) NOT NULL DEFAULT 1,
    PRIMARY KEY (id_pizza, id_ingrediente),
    CONSTRAINT fk_pi_pizza FOREIGN KEY (id_pizza) REFERENCES pizzas(id_pizza)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_pi_ingrediente FOREIGN KEY (id_ingrediente) REFERENCES ingredientes(id_ingrediente)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE repartidores (
    id_repartidor INT AUTO_INCREMENT PRIMARY KEY,
    nombre        VARCHAR(100) NOT NULL,
    zona          VARCHAR(60)  NOT NULL,
    estado        ENUM('disponible','no_disponible') NOT NULL DEFAULT 'disponible'
) ENGINE=InnoDB;

CREATE TABLE pedidos (
    id_pedido     INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente    INT NOT NULL,
    id_repartidor INT NULL,
    fecha_hora    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    metodo_pago   ENUM('efectivo','tarjeta','app') NOT NULL,
    estado        ENUM('pendiente','en_preparacion','entregado','cancelado') NOT NULL DEFAULT 'pendiente',
    total         DECIMAL(10,2) NOT NULL DEFAULT 0,
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_pedido_repartidor FOREIGN KEY (id_repartidor) REFERENCES repartidores(id_repartidor)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE detalle_pedido (
    id_detalle      INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido       INT NOT NULL,
    id_pizza        INT NOT NULL,
    cantidad        INT NOT NULL DEFAULT 1 CHECK (cantidad > 0),
    precio_unitario DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_detalle_pedido FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_detalle_pizza FOREIGN KEY (id_pizza) REFERENCES pizzas(id_pizza)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE domicilios (
    id_domicilio INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido    INT NOT NULL UNIQUE,
    hora_salida  DATETIME NULL,
    hora_entrega DATETIME NULL,
    distancia_km DECIMAL(6,2) NOT NULL DEFAULT 0,
    costo_envio  DECIMAL(10,2) NOT NULL DEFAULT 0,
    CONSTRAINT fk_domicilio_pedido FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE pagos (
    id_pago    INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido  INT NOT NULL,
    monto      DECIMAL(10,2) NOT NULL CHECK (monto >= 0),
    metodo     ENUM('efectivo','tarjeta','app') NOT NULL,
    fecha_pago DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pago_pedido FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE historial_precios (
    id_historial    INT AUTO_INCREMENT PRIMARY KEY,
    id_pizza        INT NOT NULL,
    precio_anterior DECIMAL(10,2) NOT NULL,
    precio_nuevo    DECIMAL(10,2) NOT NULL,
    fecha_cambio    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario         VARCHAR(100) NOT NULL DEFAULT (CURRENT_USER()),
    CONSTRAINT fk_hist_pizza FOREIGN KEY (id_pizza) REFERENCES pizzas(id_pizza)
        ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ------------------------- DATOS DE EJEMPLO -------------------------
INSERT INTO clientes (nombre, telefono, direccion, correo, fecha_registro) VALUES
('Andrea Gómez',   '3001112233', 'Calle 10 # 5-20, Norte',  'andrea@mail.com',  '2026-07-01'),
('Bruno Díaz',     '3014445566', 'Cra 15 # 8-40, Centro',   'bruno@mail.com',   '2026-07-01'),
('Carla Ruiz',     '3027778899', 'Av 30 # 12-15, Sur',      'carla@mail.com',   '2026-07-02'),
('Diego Torres',   '3033334455', 'Calle 45 # 2-10, Este',   'diego@mail.com',   '2026-07-02'),
('Elena Marín',    '3046667788', 'Cra 7 # 22-30, Oeste',    'elena@mail.com',   '2026-07-03');

INSERT INTO pizzas (nombre, tamano, precio_base, tipo) VALUES
('Margarita',      'mediana',  25000, 'clasica'),
('Pepperoni',      'familiar', 38000, 'especial'),
('Vegetariana',    'mediana',  28000, 'vegetariana'),
('Hawaiana',       'familiar', 36000, 'especial'),
('Cuatro Quesos',  'personal', 20000, 'clasica');

INSERT INTO ingredientes (nombre, stock, stock_minimo, unidad, costo_unitario) VALUES
('Masa',        100, 20, 'unidad', 1500),
('Queso',       500, 100,'gramos',   30),
('Tomate',      300, 80, 'gramos',   10),
('Pepperoni',   200, 50, 'gramos',   40),
('Piña',        150, 40, 'gramos',   15),
('Champiñon',    80, 30, 'gramos',   25),
('Pimenton',     20, 25, 'gramos',   18);   -- inicia bajo el mínimo (demo vista_stock_bajo)

INSERT INTO pizza_ingredientes VALUES
(1,1,1),(1,2,120),(1,3,80),
(2,1,1),(2,2,180),(2,3,100),(2,4,120),
(3,1,1),(3,2,120),(3,3,90),(3,6,60),(3,7,50),
(4,1,1),(4,2,160),(4,3,90),(4,5,100),
(5,1,1),(5,2,200);

INSERT INTO repartidores (nombre, zona, estado) VALUES
('Luis Pérez',    'Norte',  'disponible'),
('Marta Silva',   'Centro', 'disponible'),
('Óscar Peña',    'Sur',    'disponible'),
('Paula Vega',    'Este',   'disponible');

INSERT INTO pedidos (id_cliente, id_repartidor, fecha_hora, metodo_pago, estado) VALUES
(1, 1, '2026-07-05 12:30:00', 'efectivo', 'entregado'),
(2, 2, '2026-07-05 13:00:00', 'tarjeta',  'entregado'),
(3, 3, '2026-07-06 19:15:00', 'app',      'entregado'),
(1, 1, '2026-07-07 20:00:00', 'efectivo', 'entregado'),
(4, 4, '2026-07-08 12:45:00', 'tarjeta',  'en_preparacion'),
(1, 2, '2026-07-09 13:20:00', 'app',      'entregado'),
(5, 3, '2026-07-10 18:30:00', 'efectivo', 'pendiente'),
(1, 1, '2026-07-11 12:10:00', 'app',      'entregado'),
(1, 2, '2026-07-12 19:40:00', 'tarjeta',  'entregado'),
(1, 4, '2026-07-12 20:30:00', 'efectivo', 'entregado');

INSERT INTO detalle_pedido (id_pedido, id_pizza, cantidad, precio_unitario) VALUES
(1, 1, 2, 25000),(1, 5, 1, 20000),
(2, 2, 1, 38000),
(3, 3, 2, 28000),
(4, 2, 1, 38000),(4, 4, 1, 36000),
(5, 1, 1, 25000),
(6, 5, 3, 20000),
(7, 3, 1, 28000),
(8, 2, 1, 38000),
(9, 4, 2, 36000),
(10,1, 1, 25000);

INSERT INTO domicilios (id_pedido, hora_salida, hora_entrega, distancia_km, costo_envio) VALUES
(1, '2026-07-05 12:45:00', '2026-07-05 13:05:00', 3.2, 4000),
(2, '2026-07-05 13:15:00', '2026-07-05 13:40:00', 5.0, 6000),
(3, '2026-07-06 19:30:00', '2026-07-06 19:55:00', 4.1, 5000),
(4, '2026-07-07 20:15:00', '2026-07-07 20:35:00', 2.8, 4000),
(6, '2026-07-09 13:35:00', '2026-07-09 13:55:00', 3.5, 5000),
(8, '2026-07-11 12:25:00', '2026-07-11 12:50:00', 4.6, 5500),
(9, '2026-07-12 19:55:00', '2026-07-12 20:20:00', 6.0, 7000),
(10,'2026-07-12 20:45:00', '2026-07-12 21:05:00', 2.0, 3500);

INSERT INTO pagos (id_pedido, monto, metodo) VALUES
(1, 74000, 'efectivo'),(2, 44000, 'tarjeta'),(3, 61000, 'app'),
(4, 78000, 'efectivo'),(6, 65000, 'app'),(8, 43500, 'app'),
(9, 79000, 'tarjeta'),(10,28500, 'efectivo');

-- --- Pedidos ADICIONALES para tener más clientes frecuentes ---
-- Bruno (2) y Carla (3) superan los 5 pedidos del mes actual.
INSERT INTO pedidos (id_cliente, id_repartidor, fecha_hora, metodo_pago, estado) VALUES
(2, 2, '2026-07-06 12:20:00', 'efectivo', 'entregado'),   -- id 11 Bruno
(2, 2, '2026-07-07 13:10:00', 'app',      'entregado'),   -- id 12 Bruno
(2, 1, '2026-07-08 19:05:00', 'tarjeta',  'entregado'),   -- id 13 Bruno
(2, 2, '2026-07-09 20:15:00', 'efectivo', 'entregado'),   -- id 14 Bruno
(2, 3, '2026-07-11 12:40:00', 'app',      'entregado'),   -- id 15 Bruno
(3, 3, '2026-07-06 18:30:00', 'tarjeta',  'entregado'),   -- id 16 Carla
(3, 3, '2026-07-07 19:20:00', 'efectivo', 'entregado'),   -- id 17 Carla
(3, 4, '2026-07-08 13:15:00', 'app',      'entregado'),   -- id 18 Carla
(3, 3, '2026-07-09 20:00:00', 'tarjeta',  'entregado'),   -- id 19 Carla
(3, 2, '2026-07-11 12:55:00', 'efectivo', 'entregado');   -- id 20 Carla

INSERT INTO detalle_pedido (id_pedido, id_pizza, cantidad, precio_unitario) VALUES
(11, 2, 1, 38000),(12, 1, 1, 25000),(13, 5, 2, 20000),(14, 3, 1, 28000),(15, 4, 1, 36000),
(16, 1, 1, 25000),(17, 2, 1, 38000),(18, 5, 1, 20000),(19, 4, 1, 36000),(20, 3, 2, 28000);

INSERT INTO domicilios (id_pedido, hora_salida, hora_entrega, distancia_km, costo_envio) VALUES
(11,'2026-07-06 12:35:00','2026-07-06 12:58:00',3.0,4000),
(13,'2026-07-08 19:20:00','2026-07-08 19:45:00',4.2,5000),
(16,'2026-07-06 18:45:00','2026-07-06 19:08:00',3.8,4500),
(18,'2026-07-08 13:30:00','2026-07-08 13:52:00',2.6,4000);

INSERT INTO pagos (id_pedido, monto, metodo) VALUES
(11,45040,'efectivo'),(13,48200,'tarjeta'),(16,29500,'tarjeta'),(18,25600,'app');
