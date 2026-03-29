<?php
require_once 'config.php';

class Studio {
    private $conn;
    private $table_name = "tbl_studio";

    private $Studio_ID;
    private $Studio_Name;
    private $Studio_Info;
    private $Studio_Social;  

    public function __construct() {
        $database = new Database();
        $this->conn = $database->getConnection();
    }

    // Setter 
    public function setStudio($id, $name, $info = null, $social = null) {
        $this->Studio_ID = $id;
        $this->Studio_Name = $name;
        $this->Studio_Info = $info;
        $this->Studio_Social = $social;  
    }

    // Getter methods
    public function getStudio_ID() {
        return $this->Studio_ID;
    }

    public function getStudio_Name() {
        return htmlspecialchars($this->Studio_Name);
    }

    public function getStudio_Info() {
        return nl2br(htmlspecialchars($this->Studio_Info));
    }

    public function getStudio_Info_Short($length = 100) {
        return substr(htmlspecialchars($this->Studio_Info), 0, $length) . '...';
    }

    public function getStudio_Social() {
        return htmlspecialchars($this->Studio_Social);
    }

    public function getStudio_Social_Url() {
        if(!empty($this->Studio_Social)) {
            // Thêm https:// nếu chưa có
            if(!preg_match('/^https?:\/\//', $this->Studio_Social)) {
                return 'https://' . $this->Studio_Social;
            }
            return $this->Studio_Social;
        }
        return null;
    }

    // Lấy tất cả hãng sản xuất
    public function getAllStudios() {
        $query = "SELECT * FROM " . $this->table_name . " ORDER BY Studio_Name";
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // Lấy thông tin chi tiết hãng
    public function getDetails() {
        $query = "SELECT * FROM " . $this->table_name . " WHERE Studio_ID = :id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $this->Studio_ID);
        $stmt->execute();
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // Lấy danh sách phim của hãng
    public function getProducedMovies() {
        $query = "SELECT * FROM tbl_movie 
                  WHERE Studio_ID = :id 
                  ORDER BY Movie_ReleaseDate DESC";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $this->Studio_ID);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // Tìm kiếm studio theo tên
    public function searchByName($keyword) {
        $query = "SELECT * FROM " . $this->table_name . " WHERE Studio_Name LIKE :keyword ORDER BY Studio_Name";
        $stmt = $this->conn->prepare($query);
        $keyword = "%{$keyword}%";
        $stmt->bindParam(':keyword', $keyword);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // Phương thức tiện ích: lấy tất cả
    public function getAllData() {
        return [
            'id' => $this->getStudio_ID(),
            'name' => $this->getStudio_Name(),
            'info' => $this->getStudio_Info(),
            'social' => $this->getStudio_Social(),
            'social_url' => $this->getStudio_Social_Url()
        ];
    }
     // Chờ SP: sp_GetMoviesByStudio(?)
    public function getMoviesByStudio(int $studioId): array {
        try {
            // TODO: Thay bằng CALL sp_GetMoviesByStudio(?) khi có SP
            $stmt = $this->pdo->prepare("CALL sp_GetMoviesByStudio(?)");
            $stmt->execute([$studioId]);
            return $stmt->fetchAll(PDO::FETCH_OBJ) ?: [];
        } catch(PDOException $e) {
            error_log("Error in getMoviesByStudio: " . $e->getMessage());
            return [];
        }
    }
}
?>
