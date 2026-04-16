<?php
class HomeController {
    private $db;
    private $mysqli;

    public function __construct($db) {
        $this->db = $db;
        $this->mysqli = Database::getInstance()->getMysqliConnection();
    }

    public function index($page = 1) {
        $limit = 6;
        $offset = ($page - 1) * $limit;
        $newsList = $this->getNewsList($offset, $limit);
        $totalNews = $this->getTotalNews();
        $totalPages = ceil($totalNews / $limit);

        $GLOBALS['newsList'] = $newsList;
        $GLOBALS['totalPages'] = $totalPages;
        $GLOBALS['pageNum'] = $page;
        $GLOBALS['pageTitle'] = 'Tin tức mới nhất';

        include 'App/Views/Member/home.php';
    }

    public function movies($page = 1) {
        $limit = 6;
        $offset = ($page - 1) * $limit;
        $newsList = $this->getMoviesList($offset, $limit);
        $totalNews = $this->getTotalMovies();
        $totalPages = ceil($totalNews / $limit);

        $GLOBALS['newsList'] = $newsList;
        $GLOBALS['totalPages'] = $totalPages;
        $GLOBALS['pageNum'] = $page;
        $GLOBALS['pageTitle'] = '🎬 Tin phim hot nhất';
        $GLOBALS['categoryFilter'] = 'Phim ảnh';

        include 'App/Views/Member/home.php';
    }

    public function showNewsDetail($id) {
        $news = $this->getNewsById($id);
        if (!$news) {
            $_SESSION['error'] = 'Tin tức không tồn tại!';
            header('Location: index.php');
            exit;
        }

        $comments = $this->getComments($id);
        $relatedNews = $this->getRelatedNews($id, 4);

        $GLOBALS['news'] = $news;
        $GLOBALS['comments'] = $comments;
        $GLOBALS['relatedNews'] = $relatedNews;
        $GLOBALS['pageTitle'] = $news['New_Title'];

        include 'App/Views/Member/news-detail.php';
    }

    public function search($keyword) {
        $keyword = "%$keyword%";
        $sql = "SELECT n.*, a.Username 
                FROM tbl_new n 
                LEFT JOIN tbl_account a ON n.Account_ID = a.Account_ID 
                WHERE n.New_Status = 'Publish' 
                AND (n.New_Title LIKE ? OR n.New_Description LIKE ? OR n.New_Content LIKE ?)
                ORDER BY n.New_PublishDate DESC";
        
        $stmt = $this->mysqli->prepare($sql);
        $stmt->bind_param("sss", $keyword, $keyword, $keyword);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $GLOBALS['newsList'] = [];
        while ($row = $result->fetch_assoc()) {
            $row['short_desc'] = substr(strip_tags($row['New_Description'] ?? $row['New_Content'] ?? ''), 0, 150) . '...';
            $GLOBALS['newsList'][] = $row;
        }
        
        $GLOBALS['searchKeyword'] = $_GET['keyword'] ?? '';
        $GLOBALS['pageTitle'] = 'Tìm kiếm: ' . ($_GET['keyword'] ?? '');
        include 'App/Views/Member/home.php';
    }

    private function getRelatedNews($newsId, $limit = 4) {
        $news = $this->getNewsById($newsId);
        if (!$news) return [];
        
        $category = $news['New_Category'] ?? 'Movie';
        $title = strtolower(trim(strip_tags($news['New_Title'] ?? '')));
        
        $keywords = $this->extractKeywords($title);
        $mainKeyword = !empty($keywords) ? $keywords[0] : '';
        $searchPattern = $mainKeyword ? "%$mainKeyword%" : '%';
        
        $sql = "SELECT n.New_ID, n.New_Title, n.New_PublishDate, n.New_Category, 
                       a.Username, a.Account_img,
                       (CASE 
                            WHEN n.New_Category = ? THEN 20 
                            WHEN n.New_Title LIKE ? OR n.New_Description LIKE ? THEN 15
                            ELSE 1 END) as score
                FROM tbl_new n 
                LEFT JOIN tbl_account a ON n.Account_ID = a.Account_ID
                WHERE n.New_ID != ? AND n.New_Status = 'Publish'
                HAVING score > 10
                ORDER BY score DESC, n.New_PublishDate DESC 
                LIMIT ?";
        
        $stmt = $this->mysqli->prepare($sql);
        $stmt->bind_param("ssssi", $category, $searchPattern, $searchPattern, $newsId, $limit);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $newsList = [];
        while ($row = $result->fetch_assoc()) {
            $row['short_desc'] = substr(strip_tags($row['New_Description'] ?? ''), 0, 100) . '...';
            $row['category_label'] = $row['New_Category'] === 'Actor' ? '👥 Diễn viên' : '🎬 Phim ảnh';
            $newsList[] = $row;
        }
        
        if (count($newsList) < $limit) {
            $fallback = $this->getFallbackRelatedNews($newsId, $category, $limit - count($newsList));
            $newsList = array_merge($newsList, $fallback);
        }
        
        return array_slice($newsList, 0, $limit);
    }

    private function getFallbackRelatedNews($newsId, $category, $limit) {
        $sql = "SELECT n.New_ID, n.New_Title, n.New_PublishDate, n.New_Category, 
                       a.Username, a.Account_img
                FROM tbl_new n LEFT JOIN tbl_account a ON n.Account_ID = a.Account_ID
                WHERE n.New_ID != ? AND n.New_Category = ? AND n.New_Status = 'Publish'
                ORDER BY n.New_PublishDate DESC LIMIT ?";
        
        $stmt = $this->mysqli->prepare($sql);
        $stmt->bind_param("isi", $newsId, $category, $limit);
        $stmt->execute();
        $result = $stmt->get_result();
        $news = [];
        
        while ($row = $result->fetch_assoc()) {
            $row['short_desc'] = substr(strip_tags($row['New_Description'] ?? ''), 0, 100) . '...';
            $row['category_label'] = $row['New_Category'] === 'Actor' ? '👥 Diễn viên' : '🎬 Phim ảnh';
            $news[] = $row;
        }
        return $news;
    }

    private function extractKeywords($text) {
        $text = strtolower(trim(preg_replace('/[^\p{L}\s]/u', ' ', $text)));
        $words = explode(' ', $text);
        $stopwords = ['the', 'and', 'for', 'are', 'but', 'not', 'you', 'all', 'can', 'had', 'her', 'was', 'one', 'our', 'out', 'day', 'get', 'và', 'của', 'là', 'trong', 'cho', 'có', 'từ'];
        
        $keywords = array_filter($words, function($word) use ($stopwords) {
            return strlen($word) > 3 && !in_array($word, $stopwords);
        });
        
        return array_unique(array_slice($keywords, 0, 3));}

public function actors($page = 1) {
    $limit = 6;
    $offset = ($page - 1) * $limit;
    $newsList = $this->getActorsList($offset, $limit);
    $totalNews = $this->getTotalActorsNews();
    $totalPages = ceil($totalNews / $limit);

    $GLOBALS['newsList'] = $newsList;
    $GLOBALS['totalPages'] = $totalPages;
    $GLOBALS['pageNum'] = $page;
    $GLOBALS['pageTitle'] = '👥 Tin diễn viên hot nhất';
    $GLOBALS['categoryFilter'] = 'Diễn viên';

    include 'App/Views/Member/home.php';
}

    private function getActorsList($offset, $limit) {
    $sql = "SELECT n.*, a.Username, a.Account_img 
            FROM tbl_new n 
            LEFT JOIN tbl_account a ON n.Account_ID = a.Account_ID 
            WHERE n.New_Status = 'Publish' AND n.New_Category = 'Actor'
            ORDER BY n.New_PublishDate DESC 
            LIMIT ? OFFSET ?";
    $stmt = $this->mysqli->prepare($sql);
    $stmt->bind_param("ii", $limit, $offset);
    $stmt->execute();
    $result = $stmt->get_result();
    $news = [];
    while ($row = $result->fetch_assoc()) {
        $row['short_desc'] = substr(strip_tags($row['New_Description'] ?? $row['New_Content'] ?? ''), 0, 150) . '...';
        $row['category_label'] = '👥 Diễn viên';
        $news[] = $row;
    }
    return $news;
}

    private function getTotalActorsNews() {
    $result = $this->mysqli->query("SELECT COUNT(*) as total FROM tbl_new WHERE New_Status = 'Publish' AND New_Category = 'Actor'");
    return $result->fetch_assoc()['total'] ?? 0;
}

    private function getNewsList($offset, $limit) {
        $sql = "SELECT n.*, a.Username, a.Account_img 
                FROM tbl_new n 
                LEFT JOIN tbl_account a ON n.Account_ID = a.Account_ID 
                WHERE n.New_Status = 'Publish' 
                ORDER BY n.New_PublishDate DESC 
                LIMIT ? OFFSET ?";
        $stmt = $this->mysqli->prepare($sql);
        $stmt->bind_param("ii", $limit, $offset);
        $stmt->execute();
        $result = $stmt->get_result();
        $news = [];
        while ($row = $result->fetch_assoc()) {
            $row['short_desc'] = substr(strip_tags($row['New_Description'] ?? $row['New_Content'] ?? ''), 0, 150) . '...';
            $row['category_label'] = $row['New_Category'] === 'Actor' ? '👥 Diễn viên' : '🎬 Phim ảnh';
            $news[] = $row;
        }
        return $news;
    }

    private function getMoviesList($offset, $limit) {
        $sql = "SELECT n.*, a.Username, a.Account_img 
                FROM tbl_new n 
                LEFT JOIN tbl_account a ON n.Account_ID = a.Account_ID 
                WHERE n.New_Status = 'Publish' AND n.New_Category = 'Movie'
                ORDER BY n.New_PublishDate DESC 
                LIMIT ? OFFSET ?";
        $stmt = $this->mysqli->prepare($sql);
        $stmt->bind_param("ii", $limit, $offset);
        $stmt->execute();
        $result = $stmt->get_result();
        $news = [];
        while ($row = $result->fetch_assoc()) {
            $row['short_desc'] = substr(strip_tags($row['New_Description'] ?? $row['New_Content'] ?? ''), 0, 150) . '...';
            $row['category_label'] = '🎬 Phim ảnh';
            $news[] = $row;
        }
        return $news;
    }

    private function getTotalNews() {
        $result = $this->mysqli->query("SELECT COUNT(*) as total FROM tbl_new WHERE New_Status = 'Publish'");
        return $result->fetch_assoc()['total'] ?? 0;
    }

    private function getTotalMovies() {
        $result = $this->mysqli->query("SELECT COUNT(*) as total FROM tbl_new WHERE New_Status = 'Publish' AND New_Category = 'Movie'");
        return $result->fetch_assoc()['total'] ?? 0;
    }

    private function getNewsById($id) {
        $sql = "SELECT n.*, a.Username, a.Account_img 
                FROM tbl_new n LEFT JOIN tbl_account a ON n.Account_ID = a.Account_ID 
                WHERE n.New_ID = ? AND n.New_Status = 'Publish'";
        $stmt = $this->mysqli->prepare($sql);
        $stmt->bind_param("i", $id);
        $stmt->execute();
        return $stmt->get_result()->fetch_assoc();
    }

    private function getComments($newsId) {
        $sql = "SELECT c.Comment_ID, c.Comment_Data, c.Comment_Date, c.Account_ID, c.New_ID, 
                   a.Username, a.Account_img 
                FROM tbl_comment c 
                JOIN tbl_account a ON c.Account_ID = a.Account_ID 
                WHERE c.New_ID = ? 
                ORDER BY c.Comment_Date DESC";
        $stmt = $this->mysqli->prepare($sql);
        $stmt->bind_param("i", $newsId);
        $stmt->execute();
        $result = $stmt->get_result();
        $comments = [];
        while ($row = $result->fetch_assoc()) {
            $comments[] = $row;
        }
        return $comments;
    }
}
?>
