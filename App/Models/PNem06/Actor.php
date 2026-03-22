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
     // SP: Lấy diễn viên theo Movie + xử lý many-many 
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
            
            // XỬ LÝ MANY-MANY  (group dữ liệu)
            $result = [];
            foreach ($data as $row) {
                $actorId = $row->Actor_ID;
                if (!isset($result[$actorId])) {
                    $result[$actorId] = [
                        'Actor_ID' => $row->Actor_ID,
                        'Actor_Name' => $row->Actor_Name,
                        'Actor_Info' => $row->Actor_Info,
                        'Actor_Social' => $row->Actor_Social,
                        'movies' => [] // danh sách phim
                    ];
                }
                // lấy từ DB (KHÔNG hard-code)
                if (isset($row->Movie_ID)) {
                    $result[$actorId]['movies'][] = $row->Movie_ID;
                }
            }
            return array_values($result);
        } catch (PDOException $e) {
            error_log($e->getMessage());
            return [];
        }
    }
    
    // SP: Top diễn viên theo giải thưởng
    public function getTopActorsByAwards(){
        try {
            $sql = "CALL sp_TopActorsByAwards()";
            $stmt = $this->conn->prepare($sql);
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
