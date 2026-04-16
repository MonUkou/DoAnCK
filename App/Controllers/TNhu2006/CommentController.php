<?php

require_once __DIR__ . '/../../Models/TNhu2006/Comment.php';
require_once __DIR__ . '/../../../Config/database.php';

class CommentController {
    private $commentModel;
    
    public function __construct() {
        $mysqli = $this->getMysqliConnection();
        $this->commentModel = new Comment($mysqli);
    }
    
    public function addComment() {
    header('Content-Type: application/json');

    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        echo json_encode(['success' => false, 'message' => 'Invalid request']);
        exit;
    }

    $news_id = (int)($_POST['news_id'] ?? 0);
    $account_id = (int)($_POST['account_id'] ?? 0);
    $comment_data = trim($_POST['comment_data'] ?? '');

    if (!$news_id || !$account_id || empty($comment_data)) {
        echo json_encode(['success' => false, 'message' => 'Thiếu dữ liệu']);
        exit;
    }

    $this->commentModel->setData($comment_data);
    $this->commentModel->setDate(date('Y-m-d H:i:s'));
    $this->commentModel->setAccount($account_id);
    $this->commentModel->setNews($news_id);

    if ($this->commentModel->writeComment()) {
        echo json_encode([
            'success' => true,
            'username' => $_SESSION['user_obj']->getUser(),
            'content' => htmlspecialchars($comment_data),
            'time' => date('H:i d/m')
        ]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Lỗi DB']);
    }

    exit;
}
    
    public function deleteComment() {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            die('Phương thức không hợp lệ');
        }
        
        $comment_id = isset($_POST['comment_id']) ? (int)$_POST['comment_id'] : 0;
        $news_id = isset($_POST['news_id']) ? (int)$_POST['news_id'] : 0;
        
        if (!$comment_id) {
            die('ID bình luận không hợp lệ');
        }
        
        $this->commentModel->setId($comment_id);
        $result = $this->commentModel->delete();
        
        if ($result) {
            header("Location: index.php?controller=news&action=showDetail&id=$news_id");
            exit();
        } else {
            die('Xóa bình luận thất bại');
        }
    }
    
    private function getMysqliConnection() {
    return Database::getInstance()->getMysqliConnection();
}
}
