<?php
require_once __DIR__ . '/../../../Config/database.php';

class MovieController {
    private $db;
    
    public function __construct($db = null) {
        $this->db = $db ?? Database::getInstance()->getConnection();
    }
    
    
    public function index($page = 1) {
        $limit = 6;
        $offset = ($page - 1) * $limit;
        
        $movies = $this->getMoviesPaginated($offset, $limit);
        $totalMovies = $this->getTotalMovies();
        $totalPages = ceil($totalMovies / $limit);
        
        $GLOBALS['movies'] = $movies;
        $GLOBALS['totalPages'] = $totalPages;
        $GLOBALS['currentPage'] = $page;
        $GLOBALS['totalMovies'] = $totalMovies;
        $GLOBALS['pageTitle'] = '🎬 Danh sách tất cả phim';
        
        include __DIR__ . '/../../Views/Member/movie/list.php';
    }
   
    public function showDetail($movie_id) {
        require_once __DIR__ . '/../../Models/birb109/Movie.php';
        $movieModel = new Movie();

        $movie = $movieModel->getFullDetail($movie_id);
        if (!$movie) {
            $_SESSION['error'] = 'Phim không tồn tại!';
            header('Location: index.php?controller=movie');
            exit;
        }

        $genres = $movieModel->getGenresByMovie($movie_id);
        $actors = $movieModel->getActorsByMovieWithCount($movie_id);  
        $directors = $movieModel->getDirectorsByMovie($movie_id);
        $studios = $movieModel->getStudiosByMovie($movie_id);

        $GLOBALS['movie'] = $movie;
        $GLOBALS['genres'] = $genres;
        $GLOBALS['actors'] = $actors;
        $GLOBALS['directors'] = $directors;
        $GLOBALS['studios'] = $studios;
        $GLOBALS['pageTitle'] = $movie['Movie_Title'];

        include __DIR__ . '/../../Views/Member/movie/detail.php';
    }
    
    // ================= PRIVATE METHODS =================
    
    private function getMoviesPaginated($offset, $limit) {
        try {
            $sql = "SELECT m.*, a.Username, a.Account_img
                    FROM tbl_movie m
                    LEFT JOIN tbl_account a ON m.Account_ID = a.Account_ID
                    ORDER BY m.Movie_ReleaseDate DESC, m.Movie_ID DESC
                    LIMIT ? OFFSET ?";
            
            $stmt = $this->db->prepare($sql);
            $stmt->execute([$limit, $offset]);
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            error_log("Error in getMoviesPaginated: " . $e->getMessage());
            return [];
        }
    }
    
    private function getTotalMovies() {
        try {
            $stmt = $this->db->query("SELECT COUNT(*) as total FROM tbl_movie");
            return $stmt->fetch(PDO::FETCH_ASSOC)['total'] ?? 0;
        } catch (PDOException $e) {
            error_log("Error in getTotalMovies: " . $e->getMessage());
            return 0;
        }
    }
    
    private function getMovieById($movie_id) {
        try {
            $sql = "SELECT m.*, a.Username, a.Account_img
                    FROM tbl_movie m
                    LEFT JOIN tbl_account a ON m.Account_ID = a.Account_ID
                    WHERE m.Movie_ID = ?";
            
            $stmt = $this->db->prepare($sql);
            $stmt->execute([intval($movie_id)]);
            return $stmt->fetch(PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            error_log("Error in getMovieById: " . $e->getMessage());
            return null;
        }
    }
    
    private function getCharactersByMovie($movie_id) {
        try {
            $sql = "SELECT c.Character_Name, a.Actor_ID, a.Actor_Name, a.Actor_Info
                    FROM tbl_character c
                    JOIN tbl_actor a ON c.Actor_ID = a.Actor_ID
                    WHERE c.Movie_ID = ?
                    ORDER BY c.Character_ID";
            
            $stmt = $this->db->prepare($sql);
            $stmt->execute([intval($movie_id)]);
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            error_log("Error in getCharactersByMovie: " . $e->getMessage());
            return [];
        }
    }
}
?>
