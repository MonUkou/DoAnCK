<?php
require_once __DIR__ . '/../../../Config/config.php';
require_once __DIR__ . '/../../../Config/database.php';

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
    
    public function getActorsPaginated($offset, $limit) {
        try {
            $sql = "CALL sp_GetActorsPaginated(:offset, :limit)";
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':offset', $offset, PDO::PARAM_INT);
            $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
            $stmt->execute();

            $data = $stmt->fetchAll(PDO::FETCH_OBJ);
            $stmt->closeCursor();

            return $data ?: [];
        } catch (PDOException $e) {
            error_log("Actor getActorsPaginated: " . $e->getMessage());
            return [];
        }
    }
    
    public function getTotalActors() {
        try {
            $sql = "CALL sp_GetTotalActors()";
            $stmt = $this->conn->prepare($sql);
            $stmt->execute();

            $result = $stmt->fetch(PDO::FETCH_OBJ);
            $stmt->closeCursor();

            return $result->total ?? 0;
        } catch (PDOException $e) {
            error_log("Actor getTotalActors: " . $e->getMessage());
            return 0;
        }
    }
    
    public function getMoviesByActor($actor_id) {
    try {
        $sql = "CALL sp_GetMoviesByActor(:actor_id)";
        $stmt = $this->conn->prepare($sql);
        $stmt->bindParam(':actor_id', $actor_id, PDO::PARAM_INT);
        $stmt->execute();

        $data = $stmt->fetchAll(PDO::FETCH_OBJ);

        $stmt->closeCursor(); 

        return $data;
    } catch (PDOException $e) {
        error_log($e->getMessage());
        return [];
    }
}
    
    public function getMovieCount($actor_id) {
        try {
            $sql = "CALL sp_GetMovieCountByActor(:actor_id)";
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':actor_id', $actor_id, PDO::PARAM_INT);
            $stmt->execute();

            $result = $stmt->fetch(PDO::FETCH_OBJ);
            $stmt->closeCursor();

            return $result->count ?? 0;
        } catch (PDOException $e) {
            error_log("Actor getMovieCount: " . $e->getMessage());
            return 0;
        }
    }

    public function getActorById($actor_id) {
        try {
            $sql = "CALL sp_GetActorById(:actor_id)";
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':actor_id', $actor_id, PDO::PARAM_INT);
            $stmt->execute();

            $data = $stmt->fetch(PDO::FETCH_OBJ);
            $stmt->closeCursor();

            return $data ? $data : null;

        } catch (PDOException $e) {
            error_log("Actor getActorById: " . $e->getMessage());
            return null;
        }
    }

    public function getActorsWithMovieCount($offset, $limit) {
        try {
            $sql = "CALL sp_GetActorsWithMovieCount(:offset, :limit)";
            $stmt = $this->conn->prepare($sql);
            $stmt->bindParam(':offset', $offset, PDO::PARAM_INT);
            $stmt->bindParam(':limit', $limit, PDO::PARAM_INT);
            $stmt->execute();

            $data = $stmt->fetchAll(PDO::FETCH_OBJ);
            $stmt->closeCursor();

            return $data ?: [];
        } catch (PDOException $e) {
            error_log("Actor getActorsWithMovieCount: " . $e->getMessage());
            return [];
        }
    }

    public function searchActorsWithMovieCount($keyword, $offset, $limit) {
        try {
            $sql = "SELECT a.*,
                           COUNT(DISTINCT c.Movie_ID) AS movie_count
                    FROM tbl_actor a
                    LEFT JOIN tbl_character c ON a.Actor_ID = c.Actor_ID
                    WHERE a.Actor_Name LIKE :keyword
                    GROUP BY a.Actor_ID
                    ORDER BY a.Actor_Name ASC
                    LIMIT :limit OFFSET :offset";

            $stmt = $this->conn->prepare($sql);
            $stmt->bindValue(':keyword', '%' . $keyword . '%', PDO::PARAM_STR);
            $stmt->bindValue(':limit', (int) $limit, PDO::PARAM_INT);
            $stmt->bindValue(':offset', (int) $offset, PDO::PARAM_INT);
            $stmt->execute();

            return $stmt->fetchAll(PDO::FETCH_OBJ) ?: [];
        } catch (PDOException $e) {
            error_log("Actor searchActorsWithMovieCount: " . $e->getMessage());
            return [];
        }
    }

    public function countActorsByKeyword($keyword) {
        try {
            $sql = "SELECT COUNT(*) AS total
                    FROM tbl_actor
                    WHERE Actor_Name LIKE :keyword";

            $stmt = $this->conn->prepare($sql);
            $stmt->bindValue(':keyword', '%' . $keyword . '%', PDO::PARAM_STR);
            $stmt->execute();

            $result = $stmt->fetch(PDO::FETCH_OBJ);
            return $result->total ?? 0;
        } catch (PDOException $e) {
            error_log("Actor countActorsByKeyword: " . $e->getMessage());
            return 0;
        }
    }
public function getMoviesByActorWithCount($actor_id) {
    try {
        $sql = "CALL sp_GetMoviesByActorWithCount(:actor_id)"; // Nếu có SP này
        $stmt = $this->conn->prepare($sql);
        $stmt->bindParam(':actor_id', $actor_id, PDO::PARAM_INT);
        $stmt->execute();

        $data = $stmt->fetchAll(PDO::FETCH_OBJ);
        $stmt->closeCursor();

        return $data ?: [];
    } catch (PDOException $e) {
        error_log("Error in getMoviesByActorWithCount: " . $e->getMessage());
        
        $sql = "SELECT m.*, 
                       (SELECT COUNT(*) FROM tbl_character c2 WHERE c2.Actor_ID = :actor_id2) as movie_count
                FROM tbl_character c
                JOIN tbl_movie m ON c.Movie_ID = m.Movie_ID
                WHERE c.Actor_ID = :actor_id
                ORDER BY m.Movie_ReleaseDate DESC";
        
        $stmt = $this->conn->prepare($sql);
        $stmt->bindParam(':actor_id', $actor_id, PDO::PARAM_INT);
        $stmt->bindParam(':actor_id2', $actor_id, PDO::PARAM_INT);
        $stmt->execute();
        
        return $stmt->fetchAll(PDO::FETCH_OBJ);
    }
}
}
