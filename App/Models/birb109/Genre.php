<?php
require_once 'config.php';

class Genre {
    private $conn;
    private $table_name = "tbl_genre";

    private $Genre_ID;
    private $Genre_Name;

    public function __construct() {
        $database = new Database();
        $this->conn = $database->getConnection();
    }

    // Setter method
    public function setGenre($id, $name) {
        $this->Genre_ID = $id;
        $this->Genre_Name = $name;
    }

    // Getter methods
    public function getGenre_ID() {
        return $this->Genre_ID;
    }

    public function getGenre_Name() {
        return $this->Genre_Name;
    }

    // Lấy tất cả thể loại
    public function getAllGenres() {
        $query = "SELECT * FROM " . $this->table_name . " ORDER BY Genre_Name";
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
    //Search theo ten gandung
    public function getMovieByGenre($keyword) {
        $query = "SELECT * FROM " . $this->table_name . " WHERE Genre_Name LIKE :keyword ORDER BY Genre_Name";
        $stmt = $this->conn->prepare($query);
        $keyword = "%{$keyword}%";  // Thêm dấu % để tìm kiếm gaanf giong
        $stmt->bindParam(':keyword', $keyword);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // Lấy thông tin chi tiết thể loại
    public function getDetails() {
        $query = "SELECT * FROM " . $this->table_name . " WHERE Genre_ID = :id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $this->Genre_ID);
        $stmt->execute();
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // sp_GetMoviesByGenre 
    public function getMoviesByGenre(int $genreId): array {
        try {
            $stmt = $this->pdo->prepare("CALL sp_GetMoviesByGenre(?)");
            $stmt->execute([$genreId]);
            return $stmt->fetchAll(PDO::FETCH_OBJ) ?: [];
        } catch(PDOException $e) {
            error_log("Error in getMoviesByGenre: " . $e->getMessage());
            return [];
        }
    }
}
?>
