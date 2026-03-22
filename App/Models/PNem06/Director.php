<?php
require_once __DIR__ . '/../../Config/database.php';
class Director{
    private $conn;
    private $id;
    private $name;
    private $info;
    private $social;
    public function __construct($conn){
        $this->conn = Database::getInstance()->getConnection();
    }
    public function setDirector($id,$name,$info,$social){
        $this->id = $id;
        $this->name = $name;
        $this->info = $info;
        $this->social = $social;
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
    public function getSocial(){
        return $this->social;
    }
    // CALL Stored Procedure
    public function getMoviesByDirector($director_id){
        try {
            if (!isset($director_id) || !is_numeric($director_id)) {
                return [];
            }
            $director_id = (int)$director_id;

            $sql = "CALL sp_GetMoviesByDirector(:director_id)";
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':director_id', $director_id, PDO::PARAM_INT);
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
