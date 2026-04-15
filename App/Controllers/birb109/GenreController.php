<?php
class GenreController {
    private $db;

    public function __construct($db) {
        $this->db = $db;
    }

    // filterMovies($genre_id): Lọc phim theo thể loại
    public function filterMovies($genre_id) {
        try {
            $sql = "CALL sp_GetMoviesByGenre(?)";
            $stmt = $this->db->prepare($sql);
            $stmt->execute([intval($genre_id)]);
            $movies = $stmt->fetchAll(PDO::FETCH_ASSOC);
            $stmt->closeCursor();

            return $movies;
        } catch (PDOException $e) {
            error_log("Error in GenreController@filterMovies: " . $e->getMessage());
            return [];
        }
    }
}
