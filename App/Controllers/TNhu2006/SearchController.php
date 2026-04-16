<?php
namespace App\Controllers\TNhu2006;

require_once __DIR__ . '/../../../Config/database.php';

class SearchController {
    private $mysqli;

    public function __construct() {
        $this->mysqli = \Database::getInstance()->getMysqliConnection();
    }

    public function ajax() {
    if (ob_get_level()) ob_clean();
    header('Content-Type: application/json; charset=utf-8');
    header('Access-Control-Allow-Origin: *');
    
    $context = $_GET['context'] ?? 'global';
    $keyword = trim($_GET['keyword'] ?? '');

    if (empty($keyword)) {
        echo json_encode([]);
        exit;
    }

    $like = '%' . $keyword . '%';
    $results = [];

    try {
        if ($context === 'home') {
            $results = array_merge(
                $this->searchMovies($like, 5),
                $this->searchActors($like, 4),
                $this->searchNews($like, 3)
            );
        }
        elseif ($context === 'movies') {
            $results = $this->searchMovies($like, 12);
        } 
        elseif ($context === 'actors') {
            $results = $this->searchActors($like, 12);
        }
        elseif ($context === 'movie') {
            $results = $this->searchMovies($like, 10);
        }
        elseif ($context === 'actor') {
            $results = $this->searchActors($like, 10);
        }
        elseif ($context === 'news') {
            $results = $this->searchNewsByCategory($like, 10);
        }

        echo json_encode($results, JSON_UNESCAPED_UNICODE);
    } catch (Exception $e) {
        echo json_encode(['error' => $e->getMessage()]);
    }
    exit;
}
private function searchNewsByCategory($like, $limit = 10) {
    $results = [];
    $sql = "SELECT New_ID, New_Title, New_Category FROM tbl_new 
            WHERE New_Title LIKE ? AND New_Status = 'Publish' 
            ORDER BY New_PublishDate DESC LIMIT ?";
    $stmt = $this->mysqli->prepare($sql);
    $stmt->bind_param("si", $like, $limit);
    $stmt->execute();
    $res = $stmt->get_result();
    
    while ($row = $res->fetch_assoc()) {
        $type = $row['New_Category'] === 'Actor' ? '📰 Tin sao' : '📰 Tin phim';
        $results[] = [
            "title" => $row['New_Title'],
            "type" => $type,
            "link" => "index.php?controller=news&action=showDetail&id=" . $row['New_ID']
        ];
    }
    return $results;
}

    private function searchMovies($like, $limit = 10) {
        $results = [];
        $sql = "SELECT Movie_ID, Movie_Title FROM tbl_movie WHERE Movie_Title LIKE ? ORDER BY Movie_Title LIMIT ?";
        $stmt = $this->mysqli->prepare($sql);
        $stmt->bind_param("si", $like, $limit);
        $stmt->execute();
        $res = $stmt->get_result();
        
        while ($row = $res->fetch_assoc()) {
            $results[] = [
                "title" => $row['Movie_Title'],
                "type" => "🎬 Phim", 
                "link" => "index.php?controller=movie&action=showDetail&id=" . $row['Movie_ID']
            ];
        }
        return $results;
    }

    private function searchActors($like, $limit = 10) {
        $results = [];
        $sql = "SELECT Actor_ID, Actor_Name FROM tbl_actor WHERE Actor_Name LIKE ? ORDER BY Actor_Name LIMIT ?";
        $stmt = $this->mysqli->prepare($sql);
        $stmt->bind_param("si", $like, $limit);
        $stmt->execute();
        $res = $stmt->get_result();
        
        while ($row = $res->fetch_assoc()) {
            $results[] = [
                "title" => $row['Actor_Name'],
                "type" => "👤 Diễn viên",
                "link" => "index.php?controller=actor&action=showProfile&id=" . $row['Actor_ID']
            ];
        }
        return $results;
    }

    private function searchNews($like, $limit = 10) {
        $results = [];
        $sql = "SELECT New_ID, New_Title FROM tbl_new WHERE New_Title LIKE ? ORDER BY New_Title LIMIT ?";
        $stmt = $this->mysqli->prepare($sql);
        $stmt->bind_param("si", $like, $limit);
        $stmt->execute();
        $res = $stmt->get_result();
        
        while ($row = $res->fetch_assoc()) {
            $results[] = [
                "title" => $row['New_Title'],
                "type" => "📰 Tin tức",
                "link" => "index.php?controller=news&action=showDetail&id=" . $row['New_ID']
            ];
        }
        return $results;
    }
}
?>
