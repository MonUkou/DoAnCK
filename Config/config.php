<?php
if (!defined('HOST')) define("HOST", getenv('MYSQLHOST') ?: "localhost");
if (!defined('DB')) define("DB", getenv('MYSQLDATABASE') ?: "db_web2");
if (!defined('USER')) define("USER", getenv('MYSQLUSER') ?: "root");
if (!defined('PASSWORD')) define("PASSWORD", getenv('MYSQLPASSWORD') ?: "");

return [
    'db' => [
        'host' => HOST,
        'name' => DB,
        'user' => USER,
        'pass' => PASSWORD
    ]
];
?>
