
<?php

header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Origin: http://localhost:5173');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'error' => 'Metodo no permitido'
    ]);
    exit;
}

// Leer y validar JSON
$contenido = file_get_contents('php://input');
$datos = json_decode($contenido, true);

if (json_last_error() !== JSON_ERROR_NONE || !is_array($datos)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => 'El JSON enviado no es valido'
    ]);
    exit;
}

// Validar campos
$campos = ['tipo', 'lat', 'lng'];

foreach ($campos as $campo) {
    if (!array_key_exists($campo, $datos)) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'error' => "Falta el campo: $campo"
        ]);
        exit;
    }
}

// Validar tipo
$tiposPermitidos = [
    'unidad_llena',
    'parada_no_recomendada'
];

if (
    !is_string($datos['tipo']) ||
    !in_array($datos['tipo'], $tiposPermitidos, true)
) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => 'Tipo de reporte no valido'
    ]);
    exit;
}

// Validar coordenadas
if (!is_numeric($datos['lat']) || !is_numeric($datos['lng'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => 'Las coordenadas deben ser numericas'
    ]);
    exit;
}

$lat = (float) $datos['lat'];
$lng = (float) $datos['lng'];

if (
    !is_finite($lat) ||
    !is_finite($lng) ||
    $lat < -90 || $lat > 90 ||
    $lng < -180 || $lng > 180
) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => 'Las coordenadas estan fuera de rango'
    ]);
    exit;
}

$tipo = $datos['tipo'];

// Distancia máxima para encontrar una unidad (metros)
$distanciaMaxima = 500;

try {
    $pdo = require __DIR__ . '/../config/database.php';

    $pdo->beginTransaction();

    $unidadId = null;

    // Si el reporte es de unidad llena,
    // buscar la unidad más cercana.
    if ($tipo === 'unidad_llena') {

        $sqlUnidad = "
            SELECT
                id,
                codigo,
                ST_Distance_Sphere(
                    POINT(lng, lat),
                    POINT(:usuario_lng, :usuario_lat)
                ) AS distancia
            FROM unidades
            WHERE lat IS NOT NULL
              AND lng IS NOT NULL
            ORDER BY distancia ASC
            LIMIT 1
            FOR UPDATE
        ";

        $stmtUnidad = $pdo->prepare($sqlUnidad);

        $stmtUnidad->execute([
            ':usuario_lng' => $lng,
            ':usuario_lat' => $lat
        ]);

        $unidad = $stmtUnidad->fetch();

        // No existen unidades con coordenadas
        if (!$unidad) {
            $pdo->rollBack();

            http_response_code(404);
            echo json_encode([
                'success' => false,
                'error' => 'No hay unidades con ubicacion disponible'
            ]);
            exit;
        }

        // Comprobar distancia máxima
        if ((float) $unidad['distancia'] > $distanciaMaxima) {
            $pdo->rollBack();

            http_response_code(422);
            echo json_encode([
                'success' => false,
                'error' => 'No hay unidades suficientemente cerca',
                'distancia_maxima' => $distanciaMaxima
            ]);
            exit;
        }

        $unidadId = (int) $unidad['id'];

        // Marcar unidad como llena
        $sqlActualizar = "
            UPDATE unidades
            SET ocupacion = 'llena'
            WHERE id = :unidad_id
        ";

        $stmtActualizar = $pdo->prepare($sqlActualizar);

        $stmtActualizar->execute([
            ':unidad_id' => $unidadId
        ]);
    }

    // Registrar el reporte
    $sqlReporte = "
        INSERT INTO reportes (
            tipo,
            unidad_id,
            lat,
            lng
        )
        VALUES (
            :tipo,
            :unidad_id,
            :lat,
            :lng
        )
    ";

    $stmtReporte = $pdo->prepare($sqlReporte);

    $stmtReporte->execute([
        ':tipo' => $tipo,
        ':unidad_id' => $unidadId,
        ':lat' => $lat,
        ':lng' => $lng
    ]);

    $reporteId = (int) $pdo->lastInsertId();

    $pdo->commit();

    http_response_code(201);

    echo json_encode([
        'success' => true,
        'message' => 'Reporte registrado correctamente',
        'data' => [
            'id' => $reporteId,
            'tipo' => $tipo,
            'unidad_id' => $unidadId,
            'lat' => $lat,
            'lng' => $lng
        ]
    ]);

} catch (Throwable $e) {

    if (isset($pdo) && $pdo->inTransaction()) {
        $pdo->rollBack();
    }

    error_log('Error en reporte.php: ' . $e->getMessage());

    http_response_code(500);

    echo json_encode([
        'success' => false,
        'error' => 'Error interno del servidor'
    ]);
}
