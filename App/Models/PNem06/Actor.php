<?php
require_once __DIR__ . '/../../Config/database.php';
class Actor {
    private $conn;
    private $id;
    private $name;
    private $info;
    public function __construct($conn){
      // dùng Singleton PDO
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
    // Lấy danh sách diễn viên theo Movie (CALL Stored Procedure)
    public function getActorsByMovie($movie_id){
        try {
            if (!$movie_id) return [];
            $sql = "CALL sp_GetActorsByMovie(:movie_id)";
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':movie_id', $movie_id, PDO::PARAM_INT);
            $stmt->execute();
            $data = $stmt->fetchAll(PDO::FETCH_OBJ);
            $stmt->closeCursor();
            return $data ?: [];
        } catch (PDOException $e) {
            error_log($e->getMessage());
            return [];
        }
    }
}
?>
