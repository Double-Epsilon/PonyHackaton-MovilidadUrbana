<?php

$config = require __DIR__ . '/database.local.php';

$dsn = sprintf(
    'mysql:host=%s;dbname=%s;charset=%s',
    $config['host'],
    $config['database'],
    $config['charset']
);

try {
    $pdo = new PDO(
        $dsn,
        $config['username'],
        $config['password'],
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false
        ]
    );
    return $pdo;

} catch (PDOException $e) {
    error_log('Error de conexion MySQL: ' . $e->getMessage());

    throw new RuntimeException(
        'No se pudo establecer la conexion con la base de datos.'
    );
}
