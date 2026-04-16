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
        $keyword = trim($_GET['keyword'] ?? '');

        $movies = $this->getMoviesPaginated($offset, $limit, $keyword);
        $totalMovies = $this->getTotalMovies($keyword);
        $totalPages = max(1, (int) ceil($totalMovies / $limit));

        $GLOBALS['movies'] = $movies;
        $GLOBALS['totalPages'] = $totalPages;
        $GLOBALS['currentPage'] = $page;
        $GLOBALS['totalMovies'] = $totalMovies;
        $GLOBALS['pageTitle'] = 'Danh sách tất cả phim';

        if ($keyword !== '') {
            $GLOBALS['searchKeyword'] = $keyword;
        } else {
            unset($GLOBALS['searchKeyword']);
        }

        include __DIR__ . '/../../Views/Member/movie/list.php';
    }

    public function showDetail($movie_id) {
        require_once __DIR__ . '/../../Models/birb109/Movie.php';
        $movieModel = new Movie();

        $movie = $movieModel->getFullDetail($movie_id);
        if (!$movie) {
            $_SESSION['error'] = 'Phim  không tồn tại!';
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

    private function getMoviesPaginated($offset, $limit, $keyword = '') {
        try {
            $sql = "SELECT m.*, a.Username, a.Account_img
                    FROM tbl_movie m
                    LEFT JOIN tbl_account a ON m.Account_ID = a.Account_ID";
            $params = [];

            if ($keyword !== '') {
                $sql .= " WHERE m.Movie_Title LIKE :keyword";
                $params[':keyword'] = '%' . $keyword . '%';
            }

            $sql .= " ORDER BY m.Movie_ReleaseDate DESC, m.Movie_ID DESC
                      LIMIT :limit OFFSET :offset";

            $stmt = $this->db->prepare($sql);
            foreach ($params as $name => $value) {
                $stmt->bindValue($name, $value, PDO::PARAM_STR);
            }
            $stmt->bindValue(':limit', (int) $limit, PDO::PARAM_INT);
            $stmt->bindValue(':offset', (int) $offset, PDO::PARAM_INT);
            $stmt->execute();

            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            error_log('Error in getMoviesPaginated: ' . $e->getMessage());
            return [];
        }
    }

    private function getTotalMovies($keyword = '') {
        try {
            if ($keyword === '') {
                $stmt = $this->db->query("SELECT COUNT(*) AS total FROM tbl_movie");
            } else {
                $stmt = $this->db->prepare("SELECT COUNT(*) AS total
                                            FROM tbl_movie
                                            WHERE Movie_Title LIKE :keyword");
                $stmt->bindValue(':keyword', '%' . $keyword . '%', PDO::PARAM_STR);
                $stmt->execute();
            }

            return (int) ($stmt->fetch(PDO::FETCH_ASSOC)['total'] ?? 0);
        } catch (PDOException $e) {
            error_log('Error in getTotalMovies: ' . $e->getMessage());
            return 0;
        }
    }
}
?>
