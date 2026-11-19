-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 19-11-2026 a las 22:58:36
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
(4, 2, 'Madero Oriente - Parada 1', 19.7018000, -101.1900000, 1),
(5, 2, 'Madero Oriente - Parada 2', 19.7015000, -101.1820000, 4),
(6, 2, 'Madero Oriente - Parada 3', 19.7000000, -101.1740000, 7);

INSERT INTO `paradas` (`id`, `ruta_id`, `nombre`, `lat`, `lng`, `orden`) VALUES
(7, 1, 'Parada 1', 19.7176760, -101.1886300, 2),
(8, 1, 'Parada 2', 19.7094880, -101.1894470, 6);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `reportes`
--

CREATE TABLE `reportes` (
  `id` int(11) NOT NULL,
  `tipo` enum('unidad_llena','parada_no_recomendada') NOT NULL,
  `unidad_id` int(11) DEFAULT NULL,
  `lat` decimal(10,7) NOT NULL,
  `lng` decimal(10,7) NOT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `reportes`
--

INSERT INTO `reportes` (`id`, `tipo`, `unidad_id`, `lat`, `lng`, `creado_en`) VALUES
(1, 'unidad_llena', 2, 19.7033333, -101.1897667, '2026-11-19 21:57:32');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `reportes_respaldo`
--

CREATE TABLE `reportes_respaldo` (
  `id` int(11) NOT NULL DEFAULT 0,
  `ruta_id` int(11) NOT NULL,
  `tipo` enum('unidad_llena','unidad_pasando','incidencia_accesibilidad') NOT NULL,
  `lat` decimal(10,7) NOT NULL,
  `lng` decimal(10,7) NOT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `reportes_respaldo`
--

INSERT INTO `reportes_respaldo` (`id`, `ruta_id`, `tipo`, `lat`, `lng`, `creado_en`) VALUES
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
(1, 2, 19.7217380, -101.1880340, 1),
(2, 2, 19.7211510, -101.1883840, 2),
(3, 2, 19.7209510, -101.1879150, 3),
(4, 2, 19.7193880, -101.1844560, 4),
(5, 2, 19.7189270, -101.1835610, 5),
(6, 2, 19.7188010, -101.1825900, 6),
(7, 2, 19.7190110, -101.1816590, 7),
(8, 2, 19.7194300, -101.1810060, 8),
(9, 2, 19.7197490, -101.1806250, 9),
(10, 2, 19.7201120, -101.1796100, 10),
(11, 2, 19.7200460, -101.1790450, 11),
(12, 2, 19.7196680, -101.1783850, 12),
(13, 2, 19.7194110, -101.1784772, 13),
(14, 2, 19.7135500, -101.1863010, 14),
(15, 2, 19.7123790, -101.1902790, 15),
(16, 2, 19.7122960, -101.1921610, 16),
(17, 2, 19.7135440, -101.1973770, 17),
(18, 2, 19.7224790, -101.1965500, 18),
(19, 2, 19.7227100, -101.1965930, 19),
(20, 2, 19.7228520, -101.1965290, 20),
(21, 2, 19.7230330, -101.1966100, 21);

INSERT INTO `trazo_ruta` (`id`, `ruta_id`, `lat`, `lng`, `orden`) VALUES
(22, 1, 19.7109710, -101.1881540, 1),
(24, 1, 19.7123220, -101.1881640, 3),
(25, 1, 19.7116050, -101.1882790, 4),
(26, 1, 19.7109350, -101.1886270, 5),
(28, 1, 19.7078220, -101.1904720, 7),
(29, 1, 19.7068100, -101.1906490, 8),
(30, 1, 19.7069220, -101.1908300, 9),
(31, 1, 19.7060150, -101.1911370, 10),
(32, 1, 19.7056600, -101.1912920, 11),
(33, 1, 19.7054920, -101.1913150, 12);

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
  `estado` enum('en_movimiento','detenida') NOT NULL DEFAULT 'en_movimiento',
  `ocupacion` enum('normal','llena') NOT NULL DEFAULT 'normal'
) ;

--
-- Volcado de datos para la tabla `unidades`
--

INSERT INTO `unidades` (`id`, `ruta_id`, `codigo`, `lat`, `lng`, `progreso`, `estado`, `ocupacion`) VALUES
(1, 1, 'R1-01', NULL, NULL, 0.1500, 'en_movimiento', 'normal'),
(2, 1, 'R1-02', NULL, NULL, 0.6000, 'en_movimiento', 'llena'),
(3, 2, 'R2-01', NULL, NULL, 0.2000, 'en_movimiento', 'normal'),
(4, 2, 'R2-02', NULL, NULL, 0.7000, 'detenida', 'normal');

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
  ADD KEY `fk_reporte_unidad` (`unidad_id`);

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
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

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
  ADD CONSTRAINT `fk_reporte_unidad` FOREIGN KEY (`unidad_id`) REFERENCES `unidades` (`id`) ON DELETE SET NULL;

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
