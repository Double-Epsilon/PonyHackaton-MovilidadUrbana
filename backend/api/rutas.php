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

    $sql = "
        SELECT
            r.id AS ruta_id,
            r.nombre AS ruta_nombre,
            r.color AS ruta_color,

            p.id AS parada_id,
            p.nombre AS parada_nombre,
            p.lat AS parada_lat,
            p.lng AS parada_lng,
            p.orden AS parada_orden
        FROM rutas r

        LEFT JOIN paradas p
            ON r.id = p.ruta_id

        ORDER BY r.id, p.orden
    ";

    $stmt = $pdo->prepare($sql);
    $stmt->execute();

    $resultados = $stmt->fetchAll();


// ==========================================
// ORGANIZAR RESULTADOS
// ==========================================

    $rutas = [];

    foreach ($resultados as $fila) {

        $rutaId = $fila['ruta_id'];

        // Crear la ruta si todavía no existe
        if (!isset($rutas[$rutaId])) {

            $rutas[$rutaId] = [
                'id' => (int) $rutaId,
                'nombre' => $fila['ruta_nombre'],
                'color' => $fila['ruta_color'],
                'paradas' => []
            ];
        }

        // Agregar parada si existe
        if ($fila['parada_id'] !== null) {

            $rutas[$rutaId]['paradas'][] = [
                'id' => (int) $fila['parada_id'],
                'nombre' => $fila['parada_nombre'],
                'lat' => (float) $fila['parada_lat'],
                'lng' => (float) $fila['parada_lng'],
                'orden' => (int) $fila['parada_orden']
            ];
        }
    }


// ==========================================
// RESPUESTA JSON
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
