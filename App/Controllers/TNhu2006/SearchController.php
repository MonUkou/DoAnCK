<?php
namespace App\Controllers\TNhu2006;

require_once __DIR__ . '/../../../Config/database.php';

class SearchController {
    private $mysqli;

    public function __construct() {
        $this->mysqli = \Database::getInstance()->getMysqliConnection();
    }

    public function ajax() {
        if (ob_get_level()) {
            ob_clean();
        }

        header('Content-Type: application/json; charset=utf-8');

        $context = $_GET['context'] ?? 'global';
        $keyword = trim($_GET['keyword'] ?? '');
        $requestedLimit = max(1, min(20, (int) ($_GET['limit'] ?? 0)));

        if ($keyword === '') {
            echo json_encode([]);
            exit;
        }

        $like = '%' . $keyword . '%';
        $results = [];

        try {
            if ($context === 'home') {
                $results = array_merge(
                    $this->searchMovies($like, $requestedLimit > 0 ? min($requestedLimit, 8) : 5),
                    $this->searchActors($like, $requestedLimit > 0 ? min($requestedLimit, 6) : 4),
                    $this->searchNews($like, $requestedLimit > 0 ? min($requestedLimit, 6) : 3)
                );
            } elseif ($context === 'movies') {
                $results = $this->searchMovies($like, $requestedLimit ?: 12);
            } elseif ($context === 'actors') {
                $results = $this->searchActors($like, $requestedLimit ?: 12);
            } elseif ($context === 'movie') {
                $results = $this->searchMovies($like, $requestedLimit ?: 10);
            } elseif ($context === 'actor') {
                $results = $this->searchActors($like, $requestedLimit ?: 10);
            } elseif ($context === 'news') {
                $results = $this->searchNewsByCategory($like, $requestedLimit ?: 10);
            }

            echo json_encode($results, JSON_UNESCAPED_UNICODE);
        } catch (\Exception $e) {
            echo json_encode(['error' => $e->getMessage()]);
        }
        exit;
    }

    public function cards() {
        if (ob_get_level()) {
            ob_clean();
        }

        header('Content-Type: application/json; charset=utf-8');

        $keyword = trim($_GET['keyword'] ?? '');
        $context = $_GET['context'] ?? 'home';
        $limit = max(1, min(24, (int) ($_GET['limit'] ?? 12)));

        if ($keyword === '') {
            echo json_encode([
                'success' => true,
                'keyword' => '',
                'results' => []
            ], JSON_UNESCAPED_UNICODE);
            exit;
        }

        $like = '%' . $keyword . '%';
        $sql = "SELECT n.New_ID, n.New_Title, n.New_Description, n.New_Content, n.New_Img,
                       n.New_Category, n.New_PublishDate, a.Username
                FROM tbl_new n
                LEFT JOIN tbl_account a ON n.Account_ID = a.Account_ID
                WHERE n.New_Status = 'Publish'
                  AND n.New_Title LIKE ?";

        if ($context === 'movies') {
            $sql .= " AND n.New_Category = 'Movie'";
        } elseif ($context === 'actors') {
            $sql .= " AND n.New_Category = 'Actor'";
        }

        $sql .= " ORDER BY n.New_PublishDate DESC LIMIT ?";

        $stmt = $this->mysqli->prepare($sql);
        $stmt->bind_param('si', $like, $limit);
        $stmt->execute();
        $res = $stmt->get_result();

        $results = [];
        while ($row = $res->fetch_assoc()) {
            $shortDesc = trim(substr(strip_tags($row['New_Description'] ?: $row['New_Content'] ?: ''), 0, 150));
            $results[] = [
                'id' => (int) $row['New_ID'],
                'title' => $row['New_Title'],
                'image' => $row['New_Img'] ?? '',
                'category' => $row['New_Category'] ?? 'Movie',
                'category_label' => ($row['New_Category'] ?? 'Movie') === 'Actor' ? 'Diễn viên' : 'Phim ảnh',
                'description' => $shortDesc !== '' ? $shortDesc . '...' : '...',
                'publish_date' => $row['New_PublishDate'],
                'username' => $row['Username'] ?? ''
            ];
        }

        echo json_encode([
            'success' => true,
            'keyword' => $keyword,
            'results' => $results
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    private function searchNewsByCategory($like, $limit = 10) {
        $results = [];
        $sql = "SELECT New_ID, New_Title, New_Category
                FROM tbl_new
                WHERE New_Title LIKE ? AND New_Status = 'Publish'
                ORDER BY New_PublishDate DESC
                LIMIT ?";
        $stmt = $this->mysqli->prepare($sql);
        $stmt->bind_param("si", $like, $limit);
        $stmt->execute();
        $res = $stmt->get_result();

        while ($row = $res->fetch_assoc()) {
            $type = $row['New_Category'] === 'Actor' ? 'Tin sao' : 'Tin phim';
            $results[] = [
                'title' => $row['New_Title'],
                'type' => $type,
                'link' => 'index.php?controller=news&action=showDetail&id=' . $row['New_ID']
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
                'title' => $row['Movie_Title'],
                'type' => 'Phim',
                'link' => 'index.php?controller=movie&action=showDetail&id=' . $row['Movie_ID']
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
                'title' => $row['Actor_Name'],
                'type' => 'Diễn viên',
                'link' => 'index.php?controller=actor&action=showProfile&id=' . $row['Actor_ID']
            ];
        }
        return $results;
    }

    private function searchNews($like, $limit = 10) {
        $results = [];
        $sql = "SELECT New_ID, New_Title FROM tbl_new WHERE New_Title LIKE ? AND New_Status = 'Publish' ORDER BY New_PublishDate DESC LIMIT ?";
        $stmt = $this->mysqli->prepare($sql);
        $stmt->bind_param("si", $like, $limit);
        $stmt->execute();
        $res = $stmt->get_result();

        while ($row = $res->fetch_assoc()) {
            $results[] = [
                'title' => $row['New_Title'],
                'type' => 'Tin tức',
                'link' => 'index.php?controller=news&action=showDetail&id=' . $row['New_ID']
            ];
        }
        return $results;
    }
}
