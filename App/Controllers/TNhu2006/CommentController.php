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
        header('Content-Type: application/json; charset=utf-8');

        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            echo json_encode(['success' => false, 'message' => 'Invalid request']);
            exit;
        }

        $news_id = (int) ($_POST['news_id'] ?? 0);
        $account_id = (int) ($_POST['account_id'] ?? 0);
        $comment_data = trim($_POST['comment_data'] ?? '');

        if (!$news_id || !$account_id || $comment_data === '') {
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
                'content' => htmlspecialchars($comment_data, ENT_QUOTES, 'UTF-8'),
                'time' => date('H:i d/m')
            ]);
        } else {
            echo json_encode(['success' => false, 'message' => 'Lỗi DB']);
        }

        exit;
    }

    public function deleteComment() {
        header('Content-Type: application/json; charset=utf-8');

        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            echo json_encode(['success' => false, 'message' => 'Phương thức không hợp lệ']);
            exit;
        }

        if (!isset($_SESSION['user_obj']) || (int) $_SESSION['user_obj']->getRole() !== 1) {
            echo json_encode(['success' => false, 'message' => 'Bạn không có quyền xóa bình luận']);
            exit;
        }

        $comment_id = (int) ($_POST['comment_id'] ?? 0);

        if (!$comment_id) {
            echo json_encode(['success' => false, 'message' => 'ID bình luận không hợp lệ']);
            exit;
        }

        $this->commentModel->setId($comment_id);

        if ($this->commentModel->delete()) {
            echo json_encode([
                'success' => true,
                'comment_id' => $comment_id,
                'message' => 'Đã xóa bình luận'
            ]);
            exit;
        }

        echo json_encode(['success' => false, 'message' => 'Xóa bình luận thất bại']);
        exit;
    }

    private function getMysqliConnection() {
        return Database::getInstance()->getMysqliConnection();
    }
}
