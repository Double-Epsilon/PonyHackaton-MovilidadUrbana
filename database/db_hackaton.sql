-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 19-11-2026 a las 20:42:05
-- Versión del servidor: 10.11.16-MariaDB
-- Versión de PHP: 8.5.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `db_hackaton`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `paradas`
--

CREATE TABLE `paradas` (
  `id` int(11) NOT NULL,
  `ruta_id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `lat` decimal(10,7) NOT NULL,
  `lng` decimal(10,7) NOT NULL,
  `orden` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `paradas`
--

INSERT INTO `paradas` (`id`, `ruta_id`, `nombre`, `lat`, `lng`, `orden`) VALUES
(1, 1, 'Catedral de Morelia', 19.7022000, -101.1926000, 1),
(2, 1, 'Palacio de Gobierno', 19.7019000, -101.1886000, 4),
(3, 1, 'Mercado Independencia', 19.7062000, -101.1921000, 7),
(4, 2, 'Madero Oriente - Parada 1', 19.7018000, -101.1900000, 1),
(5, 2, 'Madero Oriente - Parada 2', 19.7015000, -101.1820000, 4),
(6, 2, 'Madero Oriente - Parada 3', 19.7000000, -101.1740000, 7);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `reportes`
--

CREATE TABLE `reportes` (
  `id` int(11) NOT NULL,
  `ruta_id` int(11) NOT NULL,
  `tipo` enum('unidad_llena','unidad_pasando','incidencia_accesibilidad') NOT NULL,
  `lat` decimal(10,7) NOT NULL,
  `lng` decimal(10,7) NOT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `reportes`
--

INSERT INTO `reportes` (`id`, `ruta_id`, `tipo`, `lat`, `lng`, `creado_en`) VALUES
(1, 1, 'unidad_llena', 19.7021000, -101.1912667, '2026-11-19 19:20:42'),
(2, 1, 'incidencia_accesibilidad', 19.7033333, -101.1897667, '2026-11-19 19:15:42'),
(3, 2, 'unidad_pasando', 19.7016000, -101.1846667, '2026-11-19 19:21:42'),
(4, 2, 'unidad_llena', 19.7010000, -101.1793333, '2026-11-19 19:18:42');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rutas`
--

CREATE TABLE `rutas` (
  `id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `color` varchar(7) NOT NULL DEFAULT '#1e88e5'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `rutas`
--

INSERT INTO `rutas` (`id`, `nombre`, `color`) VALUES
(1, 'Ruta 1 - Centro', '#e53935'),
(2, 'Ruta 2 - Madero Oriente', '#1e88e5');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `trazo_ruta`
--

CREATE TABLE `trazo_ruta` (
  `id` int(11) NOT NULL,
  `ruta_id` int(11) NOT NULL,
  `lat` decimal(10,7) NOT NULL,
  `lng` decimal(10,7) NOT NULL,
  `orden` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `trazo_ruta`
--

INSERT INTO `trazo_ruta` (`id`, `ruta_id`, `lat`, `lng`, `orden`) VALUES
(2, 1, 19.7021000, -101.1912667, 2),
(3, 1, 19.7020000, -101.1899333, 3),
(5, 1, 19.7033333, -101.1897667, 5),
(6, 1, 19.7047667, -101.1909333, 6),
(9, 2, 19.7017000, -101.1873333, 2),
(10, 2, 19.7016000, -101.1846667, 3),
(12, 2, 19.7010000, -101.1793333, 5),
(13, 2, 19.7005000, -101.1766667, 6);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `unidades`
--

CREATE TABLE `unidades` (
  `id` int(11) NOT NULL,
  `ruta_id` int(11) NOT NULL,
  `codigo` varchar(20) NOT NULL,
  `lat` decimal(10,7) DEFAULT NULL,
  `lng` decimal(10,7) DEFAULT NULL,
  `progreso` decimal(5,4) NOT NULL DEFAULT 0.0000,
  `estado` enum('en_movimiento','detenida') NOT NULL DEFAULT 'en_movimiento'
) ;

--
-- Volcado de datos para la tabla `unidades`
--

INSERT INTO `unidades` (`id`, `ruta_id`, `codigo`, `lat`, `lng`, `progreso`, `estado`) VALUES
(1, 1, 'R1-01', NULL, NULL, 0.1500, 'en_movimiento'),
(2, 1, 'R1-02', NULL, NULL, 0.6000, 'en_movimiento'),
(3, 2, 'R2-01', NULL, NULL, 0.2000, 'en_movimiento'),
(4, 2, 'R2-02', NULL, NULL, 0.7000, 'detenida');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `paradas`
--
ALTER TABLE `paradas`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_parada_orden` (`ruta_id`,`orden`);

--
-- Indices de la tabla `reportes`
--
ALTER TABLE `reportes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_reportes_ruta` (`ruta_id`);

--
-- Indices de la tabla `rutas`
--
ALTER TABLE `rutas`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `trazo_ruta`
--
ALTER TABLE `trazo_ruta`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_trazo_orden` (`ruta_id`,`orden`);

--
-- Indices de la tabla `unidades`
--
ALTER TABLE `unidades`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_unidad_codigo` (`codigo`),
  ADD KEY `fk_unidades_ruta` (`ruta_id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `paradas`
--
ALTER TABLE `paradas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `reportes`
--
ALTER TABLE `reportes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `rutas`
--
ALTER TABLE `rutas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `trazo_ruta`
--
ALTER TABLE `trazo_ruta`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `unidades`
--
ALTER TABLE `unidades`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `paradas`
--
ALTER TABLE `paradas`
  ADD CONSTRAINT `fk_paradas_ruta` FOREIGN KEY (`ruta_id`) REFERENCES `rutas` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `reportes`
--
ALTER TABLE `reportes`
  ADD CONSTRAINT `fk_reportes_ruta` FOREIGN KEY (`ruta_id`) REFERENCES `rutas` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `trazo_ruta`
--
ALTER TABLE `trazo_ruta`
  ADD CONSTRAINT `fk_trazo_ruta` FOREIGN KEY (`ruta_id`) REFERENCES `rutas` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `unidades`
--
ALTER TABLE `unidades`
  ADD CONSTRAINT `fk_unidades_ruta` FOREIGN KEY (`ruta_id`) REFERENCES `rutas` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
