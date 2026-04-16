<?php

class HomeController {
    private $db;
    private $mysqli;

    public function __construct($db) {
        $this->db = $db;
        $this->mysqli = Database::getInstance()->getMysqliConnection();
    }

    public function index($page = 1) {
        $keyword = trim($_GET['keyword'] ?? '');
        $this->renderNewsPage($page, null, 'TIN TỨC MỚI NHẤT', $keyword);

        include 'App/Views/member/home.php';
    }

    public function movies($page = 1) {
        $keyword = trim($_GET['keyword'] ?? '');
        $this->renderNewsPage($page, 'Movie', 'Tin phim hot nhất', $keyword, 'Phim ảnh');

        include 'App/Views/member/home.php';
    }

    public function actors($page = 1) {
        $keyword = trim($_GET['keyword'] ?? '');
        $this->renderNewsPage($page, 'Actor', 'Tin diễn viên hot nhất', $keyword, 'Diễn viên');

        include 'App/Views/member/home.php';
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

        include 'App/Views/member/news-detail.php';
    }

    public function search($keyword) {
        $page = max(1, (int) ($_GET['page'] ?? 1));
        $scope = $_GET['scope'] ?? 'news';

        if ($scope === 'movies') {
            $this->renderNewsPage($page, 'Movie', 'Tin phim hot nhất', trim($keyword), 'Phim ảnh');
        } elseif ($scope === 'actors') {
            $this->renderNewsPage($page, 'Actor', 'Tin diễn viên hot nhất', trim($keyword), 'Diễn viên');
        } else {
            $this->renderNewsPage($page, null, 'TIN TỨC MỚI NHẤT', trim($keyword));
        }

        include 'App/Views/member/home.php';
    }

    private function renderNewsPage($page, $category = null, $pageTitle = 'TIN TỨC MỚI NHẤT', $keyword = '', $categoryFilter = '') {
        $limit = 6;
        $offset = ($page - 1) * $limit;
        $newsList = $this->getNewsListFiltered($offset, $limit, $keyword, $category);
        $totalNews = $this->getTotalNewsFiltered($keyword, $category);
        $totalPages = max(1, (int) ceil($totalNews / $limit));

        $GLOBALS['newsList'] = $newsList;
        $GLOBALS['totalPages'] = $totalPages;
        $GLOBALS['pageNum'] = $page;
        $GLOBALS['pageTitle'] = $pageTitle;
        $GLOBALS['totalNews'] = $totalNews;
        $GLOBALS['categoryFilter'] = $categoryFilter;

        if ($keyword !== '') {
            $GLOBALS['searchKeyword'] = $keyword;
        } else {
            unset($GLOBALS['searchKeyword']);
        }
    }

    private function getRelatedNews($newsId, $limit = 4) {
        $news = $this->getNewsById($newsId);
        if (!$news) {
            return [];
        }

        $category = $news['New_Category'] ?? 'Movie';
        $title = strtolower(trim(strip_tags($news['New_Title'] ?? '')));
        $keywords = $this->extractKeywords($title);
        $mainKeyword = !empty($keywords) ? $keywords[0] : '';
        $searchPattern = $mainKeyword ? "%$mainKeyword%" : '%';

        $sql = "SELECT n.New_ID, n.New_Title, n.New_Description, n.New_PublishDate, n.New_Category,
                       n.New_Img, a.Username, a.Account_img,
                       (CASE
                            WHEN n.New_Category = ? THEN 20
                            WHEN n.New_Title LIKE ? THEN 15
                            ELSE 1 END) AS score
                FROM tbl_new n
                LEFT JOIN tbl_account a ON n.Account_ID = a.Account_ID
                WHERE n.New_ID != ? AND n.New_Status = 'Publish'
                HAVING score > 10
                ORDER BY score DESC, n.New_PublishDate DESC
                LIMIT ?";

        $stmt = $this->mysqli->prepare($sql);
        $stmt->bind_param('ssii', $category, $searchPattern, $newsId, $limit);
        $stmt->execute();
        $result = $stmt->get_result();

        $newsList = [];
        while ($row = $result->fetch_assoc()) {
            $row['short_desc'] = $this->makeShortText($row['New_Description'] ?? '', 100);
            $row['category_label'] = $row['New_Category'] === 'Actor' ? 'Diễn viên' : 'Phim ảnh';
            $newsList[] = $row;
        }

        if (count($newsList) < $limit) {
            $fallback = $this->getFallbackRelatedNews($newsId, $category, $limit - count($newsList));
            $newsList = array_merge($newsList, $fallback);
        }

        return array_slice($newsList, 0, $limit);
    }

    private function getFallbackRelatedNews($newsId, $category, $limit) {
        $sql = "SELECT n.New_ID, n.New_Title, n.New_Description, n.New_PublishDate, n.New_Category,
                       n.New_Img, a.Username, a.Account_img
                FROM tbl_new n
                LEFT JOIN tbl_account a ON n.Account_ID = a.Account_ID
                WHERE n.New_ID != ? AND n.New_Category = ? AND n.New_Status = 'Publish'
                ORDER BY n.New_PublishDate DESC
                LIMIT ?";

        $stmt = $this->mysqli->prepare($sql);
        $stmt->bind_param('isi', $newsId, $category, $limit);
        $stmt->execute();
        $result = $stmt->get_result();

        $news = [];
        while ($row = $result->fetch_assoc()) {
            $row['short_desc'] = $this->makeShortText($row['New_Description'] ?? '', 100);
            $row['category_label'] = $row['New_Category'] === 'Actor' ? 'Diễn viên' : 'Phim ảnh';
            $news[] = $row;
        }

        return $news;
    }

    private function extractKeywords($text) {
        $text = strtolower(trim(preg_replace('/[^\p{L}\s]/u', ' ', $text)));
        $words = explode(' ', $text);
        $stopwords = ['the', 'and', 'for', 'are', 'but', 'not', 'you', 'all', 'can', 'had', 'her', 'was', 'one', 'our', 'out', 'day', 'get', 'va', 'cua', 'la', 'trong', 'cho', 'co', 'tu'];

        $keywords = array_filter($words, function ($word) use ($stopwords) {
            return strlen($word) > 3 && !in_array($word, $stopwords, true);
        });

        return array_unique(array_slice($keywords, 0, 3));
    }

    private function getNewsListFiltered($offset, $limit, $keyword = '', $category = null) {
        $sql = "SELECT n.*, a.Username, a.Account_img
                FROM tbl_new n
                LEFT JOIN tbl_account a ON n.Account_ID = a.Account_ID
                WHERE n.New_Status = 'Publish'";
        $types = '';
        $params = [];

        if ($category !== null) {
            $sql .= " AND n.New_Category = ?";
            $types .= 's';
            $params[] = $category;
        }

        if ($keyword !== '') {
            $like = '%' . $keyword . '%';
            $sql .= " AND n.New_Title LIKE ?";
            $types .= 's';
            $params[] = $like;
        }

        $sql .= " ORDER BY n.New_PublishDate DESC LIMIT ? OFFSET ?";
        $types .= 'ii';
        $params[] = $limit;
        $params[] = $offset;

        $stmt = $this->mysqli->prepare($sql);
        $stmt->bind_param($types, ...$params);
        $stmt->execute();
        $result = $stmt->get_result();

        $news = [];
        while ($row = $result->fetch_assoc()) {
            $row['short_desc'] = $this->makeShortText($row['New_Description'] ?? ($row['New_Content'] ?? ''), 150);
            $row['category_label'] = $row['New_Category'] === 'Actor' ? 'Diễn viên' : 'Phim ảnh';
            $news[] = $row;
        }

        return $news;
    }

    private function getTotalNewsFiltered($keyword = '', $category = null) {
        $sql = "SELECT COUNT(*) AS total FROM tbl_new WHERE New_Status = 'Publish'";
        $types = '';
        $params = [];

        if ($category !== null) {
            $sql .= " AND New_Category = ?";
            $types .= 's';
            $params[] = $category;
        }

        if ($keyword !== '') {
            $like = '%' . $keyword . '%';
            $sql .= " AND New_Title LIKE ?";
            $types .= 's';
            $params[] = $like;
        }

        $stmt = $this->mysqli->prepare($sql);
        if ($types !== '') {
            $stmt->bind_param($types, ...$params);
        }
        $stmt->execute();
        $result = $stmt->get_result();

        return (int) ($result->fetch_assoc()['total'] ?? 0);
    }

    private function getNewsById($id) {
        $sql = "SELECT n.*, a.Username, a.Account_img
                FROM tbl_new n
                LEFT JOIN tbl_account a ON n.Account_ID = a.Account_ID
                WHERE n.New_ID = ? AND n.New_Status = 'Publish'";
        $stmt = $this->mysqli->prepare($sql);
        $stmt->bind_param('i', $id);
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
        $stmt->bind_param('i', $newsId);
        $stmt->execute();
        $result = $stmt->get_result();

        $comments = [];
        while ($row = $result->fetch_assoc()) {
            $comments[] = $row;
        }

        return $comments;
    }

    private function makeShortText($text, $length) {
        $clean = trim(strip_tags((string) $text));
        if ($clean === '') {
            return '...';
        }

        if (function_exists('mb_strlen') && function_exists('mb_substr')) {
            return mb_strlen($clean) > $length ? mb_substr($clean, 0, $length) . '...' : $clean;
        }

        return strlen($clean) > $length ? substr($clean, 0, $length) . '...' : $clean;
    }
}
?>
