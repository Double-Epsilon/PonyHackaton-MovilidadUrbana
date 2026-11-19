<?php

// ==========================================
// CONFIGURACION DE LA API
// ==========================================

header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Origin: http://localhost:5173');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Manejar solicitudes OPTIONS (CORS)
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

// Solo permitir GET
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    http_response_code(405);

    echo json_encode([
        'success' => false,
        'error' => 'Metodo no permitido'
    ]);

    exit;
}


// ==========================================
// CONEXION Y CONSULTA
// ==========================================

try {
    $pdo = require __DIR__ . '/../config/database.php';

    // ==========================================
    // 1. OBTENER LAS RUTAS
    // ==========================================

    $sqlRutas = "
        SELECT
            id,
            nombre,
            color
        FROM rutas
        ORDER BY id
    ";

    $stmtRutas = $pdo->prepare($sqlRutas);
    $stmtRutas->execute();

    $resultadosRutas = $stmtRutas->fetchAll();

    // ==========================================
    // 2. OBTENER TODOS LOS PUNTOS DEL RECORRIDO
    // ==========================================

    $sqlPuntos = "
        SELECT
            puntos.ruta_id,
            puntos.punto_id,
            puntos.nombre,
            puntos.lat,
            puntos.lng,
            puntos.orden,
            puntos.tipo
        FROM (
            SELECT
                ruta_id,
                id AS punto_id,
                nombre,
                lat,
                lng,
                orden,
                'parada' AS tipo
            FROM paradas

            UNION ALL

            SELECT
                ruta_id,
                id AS punto_id,
                NULL AS nombre,
                lat,
                lng,
                orden,
                'intermedio' AS tipo
            FROM trazo_ruta
        ) AS puntos

        ORDER BY puntos.ruta_id, puntos.orden
    ";

    $stmtPuntos = $pdo->prepare($sqlPuntos);
    $stmtPuntos->execute();

    $resultadosPuntos = $stmtPuntos->fetchAll();

    // ==========================================
    // 3. ORGANIZAR LAS RUTAS
    // ==========================================

    $rutas = [];

    // Crear las rutas y sus arreglos vacíos
    foreach ($resultadosRutas as $fila) {

        $rutaId = (int) $fila['id'];

        $rutas[$rutaId] = [
            'id' => $rutaId,
            'nombre' => $fila['nombre'],
            'color' => $fila['color'],
            'paradas' => [],
            'trazo' => []
        ];
    }

    // ==========================================
    // 4. AGREGAR LOS PUNTOS A CADA RUTA
    // ==========================================

    foreach ($resultadosPuntos as $fila) {

        $rutaId = (int) $fila['ruta_id'];

        // Comprobar que la ruta exista
        if (!isset($rutas[$rutaId])) {
            continue;
        }

        $punto = [
            'id' => (int) $fila['punto_id'],
            'lat' => (float) $fila['lat'],
            'lng' => (float) $fila['lng'],
            'orden' => (int) $fila['orden'],
            'tipo' => $fila['tipo']
        ];

        // Si es una parada real, agregar su nombre
        if ($fila['tipo'] === 'parada') {

            $punto['nombre'] = $fila['nombre'];

            // Guardar en el arreglo de paradas visibles
            $rutas[$rutaId]['paradas'][] = [
                'id' => $punto['id'],
                'nombre' => $punto['nombre'],
                'lat' => $punto['lat'],
                'lng' => $punto['lng'],
                'orden' => $punto['orden']
            ];
        }

        // Todos los puntos forman parte del trazo
        $rutas[$rutaId]['trazo'][] = $punto;
    }


    // ==========================================
    // 5. RESPUESTA JSON
    // ==========================================

    echo json_encode([
        'success' => true,
        'data' => array_values($rutas)
    ]);

} catch (Throwable $e) {

    error_log('Error en rutas.php: ' . $e->getMessage());

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'error' => 'Error interno del servidor'
    ]);
}
