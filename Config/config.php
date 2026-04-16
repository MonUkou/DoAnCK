<?php
if (!defined('HOST')) define("HOST", "localhost");
if (!defined('DB')) define("DB", "db_web2");
if (!defined('USER')) define("USER", "root");
if (!defined('PASSWORD')) define("PASSWORD", "");

return [
    'db' => [
        'host' => HOST,
        'name' => DB,
        'user' => USER,
        'pass' => PASSWORD
    ]
];
?>
