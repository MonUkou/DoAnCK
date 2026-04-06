<?php
require_once 'config.php';

class Movie {
    private $conn;
    private $table_name = "tbl_movie";

    private $Movie_ID;
    private $Movie_Title;
    private $Movie_Description;
    private $Movie_Img;
    private $Genre_ID;
    private $Movie_ReleaseDate;
    private $Movie_StreamingDate;
    private $Studio_ID;
    private $Director_ID;
    private $Actor_ID;
    private $Account_ID;  

    public function __construct() {
        $database = new Database();
        $this->conn = $database->getConnection();
    }

    // Setter 
    public function setMovie($id, $title, $desc=null, $img, $genre_id, $relDate=null, $streamDate = null, $studio_id, $director_id, $actor_id, $account_id) {  
        $this->Movie_ID = $id;
        $this->Movie_Title = $title;
        $this->Movie_Description = $desc;
        $this->Movie_Img = $img;
        $this->Genre_ID = $genre_id;
        $this->Movie_ReleaseDate = $relDate;
        $this->Movie_StreamingDate = $streamDate;
        $this->Studio_ID = $studio_id;
        $this->Director_ID = $director_id;
        $this->Actor_ID = $actor_id;
        $this->Account_ID = $account_id;  
    }

    // Getter methods 
    public function getMovie_ID() {
        return $this->Movie_ID;
    }

    public function getMovie_Title() {
        return htmlspecialchars($this->Movie_Title);
    }

    public function getMovie_Description() {
        return nl2br(htmlspecialchars($this->Movie_Description));
    }

    public function getMovie_Img() {
        return !empty($this->Movie_Img) ? $this->Movie_Img : 'default-movie.jpg';
    }

    public function getGenre_ID() {
        return $this->Genre_ID;
    }

    public function getGenreArray() {
        return explode(',', $this->Genre_ID);
    }

    public function getMovie_ReleaseDate($format = 'Y-m-d') {
        if($this->Movie_ReleaseDate) {
            return date($format, strtotime($this->Movie_ReleaseDate));
        }
        return null;
    }

    public function getMovie_StreamingDate($format = 'Y-m-d') {
        if($this->Movie_StreamingDate) {
            return date($format, strtotime($this->Movie_StreamingDate));
        }
        return null;
    }

    public function getStudio_ID() {
        return $this->Studio_ID;
    }

    public function getStudioArray() {
        return explode(',', $this->Studio_ID);
    }

    public function getDirector_ID() {
        return $this->Director_ID;
    }

    public function getDirectorArray() {
        return explode(',', $this->Director_ID);
    }

    public function getActor_ID() {
        return $this->Actor_ID;
    }

    public function getActorArray() {
        return explode(',', $this->Actor_ID);
    }

    public function getAccount_ID() {
        return $this->Account_ID;
    }

    // Hiển thị danh sách phim 
    public function getAllMovies() {
        $query = "SELECT m.*, g.Genre_Name, s.Studio_Name, d.Director_Name, a.Username 
                  FROM " . $this->table_name . " m
                  LEFT JOIN tbl_genre g ON FIND_IN_SET(g.Genre_ID, m.Genre_ID)
                  LEFT JOIN tbl_studio s ON m.Studio_ID = s.Studio_ID
                  LEFT JOIN tbl_director d ON m.Director_ID = d.Director_ID
                  LEFT JOIN tbl_account a ON m.Account_ID = a.Account_ID
                  GROUP BY m.Movie_ID
                  ORDER BY m.Movie_ReleaseDate DESC";
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // Chi tiết phim 
    public function getDetails() {
        $query = "SELECT m.*, s.Studio_Name, s.Studio_Info, d.Director_Name, d.Director_Info, a.Username, a.Account_img
                  FROM " . $this->table_name . " m
                  LEFT JOIN tbl_studio s ON m.Studio_ID = s.Studio_ID
                  LEFT JOIN tbl_director d ON m.Director_ID = d.Director_ID
                  LEFT JOIN tbl_account a ON m.Account_ID = a.Account_ID
                  WHERE m.Movie_ID = :id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $this->Movie_ID);
        $stmt->execute();
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    // Search phim theo ten gan dung
    public function searchMovies($keyword) {
        $query = "SELECT m.*, s.Studio_Name 
                  FROM " . $this->table_name . " m
                  LEFT JOIN tbl_studio s ON m.Studio_ID = s.Studio_ID
                  WHERE m.Movie_Title LIKE :keyword 
                     OR m.Movie_Description LIKE :keyword
                  ORDER BY m.Movie_ReleaseDate DESC";
        $stmt = $this->conn->prepare($query);
        $keyword = "%{$keyword}%";
        $stmt->bindParam(':keyword', $keyword);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // Lấy thể loại của phim
    public function getGenres() {
        $query = "SELECT g.* FROM tbl_genre g
                  WHERE FIND_IN_SET(g.Genre_ID, (
                      SELECT Genre_ID FROM tbl_movie WHERE Movie_ID = :id
                  ))";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $this->Movie_ID);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // Lọc phim theo thể loại
    public function getMovieByGenre($genre_id) {
        $query = "SELECT m.* FROM " . $this->table_name . " m
                  WHERE FIND_IN_SET(:genre_id, m.Genre_ID)
                  ORDER BY m.Movie_ReleaseDate DESC";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':genre_id', $genre_id);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // Lấy danh sách diễn viên của phim
    public function getActors() {
        $query = "SELECT a.*, c.Character_Name 
                  FROM htbl_actor a
                  INNER JOIN tbl_charactor c ON a.Actor_ID = c.Actor_ID
                  WHERE c.Movie_ID = :id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $this->Movie_ID);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // Lấy bình luận về phim
    public function getComments() {
        $query = "SELECT c.*, a.Username, a.Account_img 
                  FROM tbl_comment c
                  INNER JOIN tbl_account a ON c.Account_ID = a.Account_ID
                  WHERE c.Movie_ID = :id
                  ORDER BY c.Comment_Date DESC";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $this->Movie_ID);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    // Phương thức tiện ích: lấy tất cả
    public function getAllData() {
        return [
            'id' => $this->getMovie_ID(),
            'title' => $this->getMovie_Title(),
            'description' => $this->getMovie_Description(),
            'img' => $this->getMovie_Img(),
            'genre_ids' => $this->getGenre_ID(),
            'genre_array' => $this->getGenreArray(),
            'release_date' => $this->getMovie_ReleaseDate('d/m/Y'),
            'streaming_date' => $this->getMovie_StreamingDate('d/m/Y'),
            'studio_id' => $this->getStudio_ID(),
            'director_id' => $this->getDirector_ID(),
            'actor_ids' => $this->getActor_ID(),
            'account_id' => $this->getAccount_ID()
        ];
    }

    // sp_GetAllMovies()
    public function getAllMovies(): array {
        try {
            $stmt = $this->pdo->prepare("CALL sp_GetAllMovies()");
            $stmt->execute();
            return $stmt->fetchAll(PDO::FETCH_OBJ) ?: [];
        } catch(PDOException $e) {
            error_log("Error in getAllMovies: " . $e->getMessage());
            return [];
        }
    }

    // sp_SearchMovieByName(IN keyword VARCHAR(128))
    public function searchMovieByName(string $keyword): array {
        try {
            $stmt = $this->pdo->prepare("CALL sp_SearchMovieByName(?)");
            $stmt->execute([$keyword]);
            return $stmt->fetchAll(PDO::FETCH_OBJ) ?: [];
        } catch(PDOException $e) {
            error_log("Error in searchMovieByName: " . $e->getMessage());
            return [];
        }
    }

    // sp_AddMovie() - 10 parameters theo SP definition
    public function addMovie(array $data): bool {
        try {
            $stmt = $this->pdo->prepare("CALL sp_AddMovie(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)");
            return $stmt->execute([
                $data['title'] ?? '',
                $data['description'] ?? '',
                $data['img'] ?? '',
                (int)($data['genre_id'] ?? 0),
                $data['release_date'] ?? null,
                $data['streaming_date'] ?? null,
                (int)($data['studio_id'] ?? 0),
                (int)($data['director_id'] ?? 0),
                (int)($data['actor_id'] ?? 0),
                (int)($data['account_id'] ?? 0)
            ]);
        } catch(PDOException $e) {
            error_log("Error in addMovie: " . $e->getMessage());
            return false;
        }
    }

    // sp_GetLatestMovies()
    public function getLatestMovies(): array {
        try {
            $stmt = $this->pdo->prepare("CALL sp_GetLatestMovies()");
            $stmt->execute();
            return $stmt->fetchAll(PDO::FETCH_OBJ) ?: [];
        } catch(PDOException $e) {
            error_log("Error in getLatestMovies: " . $e->getMessage());
            return [];
        }
    }

    // sp_TopMoviesByViews(IN p_Limit INT)
    public function getTopMoviesByViews(int $limit = 10): array {
        try {
            $stmt = $this->pdo->prepare("CALL sp_TopMoviesByViews(?)");
            $stmt->execute([$limit]);
            return $stmt->fetchAll(PDO::FETCH_OBJ) ?: [];
        } catch(PDOException $e) {
            error_log("Error in getTopMoviesByViews: " . $e->getMessage());
            return [];
        }
    }
}
?>
