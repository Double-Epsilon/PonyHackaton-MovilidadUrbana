<?php

$config = require __DIR__ . "/database.local.php";

try {
    $pdo = new PDO(
        "mysql:host={$config['host']};dbname={$config['database']};charset=utf8mb4",
        $config["username"],
        $config["password"],
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
        ]
    );
} catch (PDOException $e) {
    http_response_code(500);
    exit("Error de conexion con la base de datos");
}