<?php
namespace App\Controllers\MonUkou;

class FeedbackController {
    // Lưu đánh giá phim
    public function rateMovie($db) {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            if (!isset($_SESSION['user_obj'])) {
                die("Đăng nhập để đánh giá!");
            }

            $movieId = (int)$_POST['movie_id'];
            $content = $_POST['feedback_data'];
            
            // Theo SQL của bạn: tbl_feedback cần Account_ID, Movie_ID, Feedback_Data, Feedback_Date
            $sql = "INSERT INTO tbl_feedback (Feedback_Date, Feedback_Data, Account_ID, Movie_ID) 
                    VALUES (CURDATE(), ?, ?, ?)";
            
            $stmt = $db->prepare($sql);
            $result = $stmt->execute([
                $content, 
                $_SESSION['user_obj']->getId(), 
                $movieId
            ]);

            if ($result) {
                echo "Gửi feedback thành công!";
            } else {
                echo "Lỗi khi gửi feedback.";
            }
        }
    }

    // Xóa feedback (Gọi phương thức static delete trong Model Feedback.php)
    public function removeFeedback($db) {
        $id = (int)$_GET['id'];
        if (\Feedback::delete($db, $id)) {
            echo "Đã xóa feedback.";
        }
    }
}
