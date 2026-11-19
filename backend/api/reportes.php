
<?php

header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Origin: http://localhost:5173');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

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
            id,
            tipo,
            lat,
            lng,
            creado_en
        FROM reportes
        WHERE tipo = 'parada_no_recomendada'
        ORDER BY creado_en DESC
    ";

    $stmt = $pdo->query($sql);
    $reportes = $stmt->fetchAll();

    foreach ($reportes as &$reporte) {
        $reporte['id'] = (int) $reporte['id'];
        $reporte['lat'] = (float) $reporte['lat'];
        $reporte['lng'] = (float) $reporte['lng'];
    }
    unset($reporte);

    echo json_encode([
        'success' => true,
        'data' => $reportes
    ]);

} catch (Throwable $e) {
    error_log('Error en reportes.php: ' . $e->getMessage());

    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Error interno del servidor'
    ]);
}
