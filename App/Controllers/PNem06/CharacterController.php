<?php
require_once __DIR__ . '/../Config/database.php';

class CharacterController {
    private $conn;
    
    public function __construct() {
        $this->conn = Database::getInstance()->getConnection();
    }
    public function getCharactersByMovie($movie_id) {
        try {
            $sql = "SELECT 
                        c.Character_ID,
                        c.Character_Name,
                        c.Movie_ID,
                        a.Actor_ID,
                        a.Actor_Name,
                        a.Actor_Info,
                        a.Actor_Social
                    FROM tbl_character c
                    JOIN tbl_actor a ON c.Actor_ID = a.Actor_ID
                    WHERE c.Movie_ID = :movie_id";
            
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':movie_id', $movie_id, PDO::PARAM_INT);
            $stmt->execute();
            
            $characters = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            // Map dữ liệu nhân vật để trả về cho chi tiết phim
            $result = [];
            foreach ($characters as $char) {
                $result[] = [
                    'character_id' => $char['Character_ID'],
                    'character_name' => $char['Character_Name'],
                    'actor' => [
                        'id' => $char['Actor_ID'],
                        'name' => $char['Actor_Name'],
                        'info' => $char['Actor_Info'],
                        'social' => $char['Actor_Social']
                    ]
                ];
            }
            
            return $result;
        } catch (PDOException $e) {
            error_log($e->getMessage());
            return [];
        }
    }
    
    /* Lấy thông tin chi tiết 1 nhân vật */
    public function getCharacterDetail($character_id) {
        try {
            $sql = "SELECT 
                        c.Character_ID,
                        c.Character_Name,
                        c.Movie_ID,
                        a.Actor_ID,
                        a.Actor_Name,
                        a.Actor_Info,
                        a.Actor_Social,
                        m.Movie_Title
                    FROM tbl_character c
                    JOIN tbl_actor a ON c.Actor_ID = a.Actor_ID
                    JOIN tbl_movie m ON c.Movie_ID = m.Movie_ID
                    WHERE c.Character_ID = :character_id";
            
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':character_id', $character_id, PDO::PARAM_INT);
            $stmt->execute();
            
            return $stmt->fetch(PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            error_log($e->getMessage());
            return null;
        }
    }
}
