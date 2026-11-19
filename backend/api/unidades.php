
<?php

header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Origin: http://localhost:5173');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Permitir solicitudes preflight de CORS
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

try {
    $pdo = require __DIR__ . '/../config/database.php';

    $sql = "
        SELECT
            u.id,
            u.codigo,
            u.ruta_id,
            r.nombre AS ruta_nombre,
            r.color AS ruta_color,
            u.lat,
            u.lng,
            u.progreso,
            u.estado,
            u.ocupacion
        FROM unidades u
        INNER JOIN rutas r ON r.id = u.ruta_id
        ORDER BY u.id
    ";

    $stmt = $pdo->query($sql);
    $unidades = $stmt->fetchAll();

    foreach ($unidades as &$unidad) {
        $unidad['id'] = (int) $unidad['id'];
        $unidad['ruta_id'] = (int) $unidad['ruta_id'];
        $unidad['lat'] = $unidad['lat'] !== null
            ? (float) $unidad['lat'] : null;
        $unidad['lng'] = $unidad['lng'] !== null
            ? (float) $unidad['lng'] : null;
        $unidad['progreso'] = (float) $unidad['progreso'];
    }
    unset($unidad);

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
