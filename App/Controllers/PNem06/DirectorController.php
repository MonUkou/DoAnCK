<?php
require_once __DIR__ . '/../Models/Director.php';
require_once __DIR__ . '/../Config/database.php';

class DirectorController {
    private $directorModel;
    
    public function __construct() {
        $this->directorModel = new Director();
    }
    
    /** Hiển thị danh sách phim của đạo diễn */
    public function showMovies($director_id) {
        // Lấy thông tin đạo diễn
        $director = $this->getDirectorById($director_id);
        
        if (!$director) {
            die('Đạo diễn không tồn tại');
        }
        
        // Lấy danh sách phim (dùng stored procedure có sẵn)
        $movies = $this->directorModel->getMoviesByDirector($director_id);
        
        // Load view
        include_once __DIR__ . '/../Views/director/movies.php';
    }
    
    /** Lấy thông tin đạo diễn theo ID */
    private function getDirectorById($director_id) {
        try {
            $conn = Database::getInstance()->getConnection();
            $sql = "SELECT * FROM tbl_director WHERE Director_ID = :director_id";
            $stmt = $conn->prepare($sql);
            $stmt->bindParam(':director_id', $director_id, PDO::PARAM_INT);
            $stmt->execute();
            return $stmt->fetch(PDO::FETCH_OBJ);
        } catch (PDOException $e) {
            error_log($e->getMessage());
            return null;
        }
    }
}
