<?php
require_once __DIR__ . '/../../../Config/database.php';
require_once __DIR__ . '/../../Models/TNhu2006/News.php';
require_once __DIR__ . '/../../Models/TNhu2006/Comment.php';

class NewsController {
    private $mysqli;

    public function __construct() {
        $this->mysqli = Database::getInstance()->getMysqliConnection();
    }

    public function index() {
        $keyword = trim($_GET['keyword'] ?? '');
        $GLOBALS['newsList'] = [];

        if ($keyword === '') {
            $model = new News($this->mysqli);
            $result = $model->getLatest(12);

            while ($row = $result->fetch_assoc()) {
                $row['short_content'] = substr(strip_tags($row['New_Content'] ?? ''), 0, 120) . '...';
                $row['short_desc'] = substr(strip_tags($row['New_Description'] ?? $row['New_Content'] ?? ''), 0, 150) . '...';
                $row['category_label'] = ($row['New_Category'] === 'Actor') ? 'Dien vien' : 'Phim anh';
                $GLOBALS['newsList'][] = $row;
            }
        } else {
            $like = '%' . $keyword . '%';
            $sql = "SELECT n.*, a.Username, a.Account_img
                    FROM tbl_new n
                    LEFT JOIN tbl_account a ON n.Account_ID = a.Account_ID
                    WHERE n.New_Status = 'Publish'
                      AND n.New_Title LIKE ?
                    ORDER BY n.New_PublishDate DESC";
            $stmt = $this->mysqli->prepare($sql);
            $stmt->bind_param('s', $like);
            $stmt->execute();
            $result = $stmt->get_result();

            while ($row = $result->fetch_assoc()) {
                $row['short_content'] = substr(strip_tags($row['New_Content'] ?? ''), 0, 120) . '...';
                $row['short_desc'] = substr(strip_tags($row['New_Description'] ?? $row['New_Content'] ?? ''), 0, 150) . '...';
                $row['category_label'] = ($row['New_Category'] === 'Actor') ? 'Dien vien' : 'Phim anh';
                $GLOBALS['newsList'][] = $row;
            }

            $GLOBALS['searchKeyword'] = $keyword;
        }

        $GLOBALS['pageTitle'] = 'Tin tuc dien anh';
        $GLOBALS['totalPages'] = 1;
        $GLOBALS['pageNum'] = 1;
        $GLOBALS['totalNews'] = count($GLOBALS['newsList']);

        include __DIR__ . '/../../../App/Views/member/home.php';
    }

    public function showDetail($news_id) {
        $model = new News($this->mysqli);
        $news = $model->getById($news_id);

        if (!$news) {
            $_SESSION['error'] = 'Tin tuc khong ton tai!';
            header('Location: index.php');
            exit;
        }

        $model->increaseView($news_id);

        $commentsResult = $model->getComments($news_id);
        $comments = [];
        if ($commentsResult) {
            while ($row = $commentsResult->fetch_assoc()) {
                $comments[] = $row;
            }
        }

        $relatedResult = $model->getRelated($news_id, $news['New_Category'], 4);
        $relatedNews = [];
        if ($relatedResult) {
            while ($row = $relatedResult->fetch_assoc()) {
                $relatedNews[] = $row;
            }
        }

        $GLOBALS['news'] = $news;
        $GLOBALS['comments'] = $comments;
        $GLOBALS['relatedNews'] = $relatedNews;
        $GLOBALS['pageTitle'] = $news['New_Title'];

        include __DIR__ . '/../../../App/Views/member/news-detail.php';
    }
}
?>
