
<?php

header('Content-Type: application/json; charset=UTF-8');
header('Access-Control-Allow-Origin: http://localhost:5173');
header('Access-Control-Allow-Methods: PATCH, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'PATCH') {
    http_response_code(405);
    echo json_encode([
        'success' => false,
        'error' => 'Metodo no permitido'
    ]);
    exit;
}

// Leer JSON
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
if (!isset($datos['unidad_id']) || !isset($datos['ocupacion'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => 'Se requieren unidad_id y ocupacion'
    ]);
    exit;
}

// Validar ID
$unidadId = filter_var(
    $datos['unidad_id'],
    FILTER_VALIDATE_INT,
    ['options' => ['min_range' => 1]]
);

if ($unidadId === false) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => 'El ID de unidad no es valido'
    ]);
    exit;
}

// Validar ocupación
$ocupacionesPermitidas = ['normal', 'llena'];

if (
    !is_string($datos['ocupacion']) ||
    !in_array($datos['ocupacion'], $ocupacionesPermitidas, true)
) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'error' => 'La ocupacion debe ser normal o llena'
    ]);
    exit;
}

try {
    $pdo = require __DIR__ . '/../config/database.php';

    $sql = "
        UPDATE unidades
        SET ocupacion = :ocupacion
        WHERE id = :unidad_id
    ";

    $stmt = $pdo->prepare($sql);

    $stmt->execute([
        ':ocupacion' => $datos['ocupacion'],
        ':unidad_id' => $unidadId
    ]);

    // rowCount puede ser 0 si ya tenía ese mismo valor.
    // Por eso comprobamos la existencia por separado.
    $sqlComprobar = "
        SELECT id, codigo, ocupacion
        FROM unidades
        WHERE id = :unidad_id
    ";

    $stmtComprobar = $pdo->prepare($sqlComprobar);
    $stmtComprobar->execute([
        ':unidad_id' => $unidadId
    ]);

    $unidad = $stmtComprobar->fetch();

    if (!$unidad) {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'error' => 'La unidad no existe'
        ]);
        exit;
    }

    echo json_encode([
        'success' => true,
        'message' => 'Ocupacion actualizada correctamente',
        'data' => [
            'id' => (int) $unidad['id'],
            'codigo' => $unidad['codigo'],
            'ocupacion' => $unidad['ocupacion']
        ]
    ]);

} catch (Throwable $e) {
    error_log('Error en ocupacion.php: ' . $e->getMessage());

    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Error interno del servidor'
    ]);
}
