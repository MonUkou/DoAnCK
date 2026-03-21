<?php
require_once __DIR__ . '/../../Config/database.php';
class Actor {
    private $conn;
    private $id;
    private $name;
    private $info;
    public function __construct(){
    $this->conn = Database::getInstance()->getConnection();
}
    public function setActor($id,$name,$info){
        $this->id = $id;
        $this->name = $name;
        $this->info = $info;
    }
    public function getId(){
        return $this->id;
    }
    public function getName(){
        return $this->name;
    }
    public function getInfo(){
        return $this->info;
    }
    public function getActorsByMovie($movie_id){
    try {
        if (!isset($movie_id) || !is_numeric($movie_id)) {
            return [];
        }

        $movie_id = (int)$movie_id;

        $sql = "CALL sp_GetActorsByMovie(:movie_id)";
        $stmt = $this->conn->prepare($sql);
        $stmt->bindParam(':movie_id', $movie_id, PDO::PARAM_INT);
        $stmt->execute();

        $data = $stmt->fetchAll(PDO::FETCH_OBJ);
        $stmt->closeCursor();

        // loại trùng actor (many-many)
        $unique = [];
        foreach ($data as $actor) {
            $unique[$actor->Actor_ID] = $actor;
        }

        return !empty($unique) ? array_values($unique) : [];

    } catch (PDOException $e) {
        error_log($e->getMessage());
        return [];
    }
}
}
?>
