<?php

// ==========================================
// CONFIGURACION DE LA API
// ==========================================

header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Origin: http://localhost:5173');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Manejar solicitudes OPTIONS
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
            u.id,
            u.codigo,
            u.ruta_id,
            r.nombre AS ruta_nombre,
            r.color AS ruta_color,
            u.progreso,
            u.estado

        FROM unidades u

        INNER JOIN rutas r
            ON u.ruta_id = r.id

        ORDER BY u.ruta_id, u.id
    ";

    $stmt = $pdo->prepare($sql);
    $stmt->execute();

    $unidades = $stmt->fetchAll();


// ==========================================
// ORGANIZAR RESULTADOS
// ==========================================

    foreach ($unidades as &$unidad) {
        $unidad['id'] = (int) $unidad['id'];
        $unidad['ruta_id'] = (int) $unidad['ruta_id'];
        $unidad['progreso'] = (float) $unidad['progreso'];

    }

    unset($unidad);


// ==========================================
// RESPUESTA JSON
// ==========================================

    echo json_encode([
        'success' => true,
        'data' => $unidades
    ]);

} catch (Throwable $e) {
    error_log('Error en unidades.php: ' . $e->getMessage());

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'error' => 'Error interno del servidor'
    ]);
}
