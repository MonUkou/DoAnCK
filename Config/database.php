<?php
class Database {
    private static $instance = null;
    private $conn;

    private function __construct() {
        $host = defined('HOST') ? HOST : 'localhost';
        $dbname = defined('DB') ? DB : 'db_web2';
        $user = defined('USER') ? USER : 'root';
        $pass = defined('PASSWORD') ? PASSWORD : '';

        try {
            $dsn = "mysql:host=$host;dbname=$dbname;charset=utf8mb4";
            
            $this->conn = new PDO(
                $dsn,
                $user,
                $pass,
                [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                    PDO::ATTR_EMULATE_PREPARES => false
                ]
            );
            
        } catch (PDOException $e) {
            die("❌ Lỗi kết nối: " . $e->getMessage() . 
                "<br>Config: HOST=$host, DB=$dbname, USER=$user");
        }
    }
    public static function getInstance() {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    public function getConnection() {
        return $this->conn;
    }

    public function getMysqliConnection() {
        $host = defined('HOST') ? HOST : 'localhost';
        $dbname = defined('DB') ? DB : 'db_web2';
        $user = defined('USER') ? USER : 'root';
        $pass = defined('PASSWORD') ? PASSWORD : '';

        $mysqli = new mysqli($host, $user, $pass, $dbname);
        if ($mysqli->connect_error) {
            die("MySQLi error: " . $mysqli->connect_error);
        }
        $mysqli->set_charset("utf8mb4");
        return $mysqli;
    }
}
?>
