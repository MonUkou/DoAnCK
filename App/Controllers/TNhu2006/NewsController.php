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
    $model = new News($this->mysqli);
    $newsList = $model->getLatest(12);

    foreach ($newsList as &$row) {
        $row['short_content'] = substr(strip_tags($row['New_Content'] ?? ''), 0, 120) . '...';
        $row['category_label'] = ($row['New_Category'] === 'Actor')
            ? '👥 Diễn viên'
            : '🎬 Phim ảnh';
    }

    $GLOBALS['newsList'] = $newsList;
    $GLOBALS['pageTitle'] = 'Tin tức điện ảnh';
    $GLOBALS['totalPages'] = 1;
    $GLOBALS['pageNum'] = 1;

    include __DIR__ . '/../../../App/Views/Member/home.php';
}

    public function showDetail($news_id) {
    $model = new News($this->mysqli);

    $news = $model->getById($news_id);

    if (!$news) {
        $_SESSION['error'] = 'Tin tức không tồn tại!';
        header('Location: index.php');
        exit;
    }

    $model->increaseView($news_id);

    $comments = $model->getComments($news_id);

    $relatedNews = $model->getRelated(
        $news_id,
        $news['New_Category'],
        4
    );

    $GLOBALS['news'] = $news;
    $GLOBALS['comments'] = $comments;
    $GLOBALS['relatedNews'] = $relatedNews;
    $GLOBALS['pageTitle'] = $news['New_Title'];

    include __DIR__ . '/../../../App/Views/Member/news-detail.php';
}
}
