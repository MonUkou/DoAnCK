<?php

class Feedback {
    private int $id;
    private string $data;
    private DateTime $date;
    private Account $account;
    private Movie $movie;

    public function __construct(int $id, string $data, DateTime $date, Account $account, Movie $movie) {
        $this->id = $id;
        $this->data = $data;
        $this->date = $date;
        
        // Thiết lập mối quan hệ 2 chiều (Tùy chọn nhưng tốt cho logic)
        $this->account = $account;
        $this->account->addFeedback($this); // Thêm feedback này vào danh sách của Account
        
        $this->movie = $movie;
    }

    // --- Các phương thức từ sơ đồ ---
    public function getDetails(): string {
        return "Feedback ID: {$this->id} - User: {$this->account->getUser()} - Content: {$this->data}";
    }

    public function getAvgRating(): float {
        // Trong sơ đồ, getAvgRating nằm ở Feedback hơi lạ về mặt logic thực tế 
        // (thường nó nên nằm ở Movie). 
        // Nếu ở đây, có thể nó truy xuất điểm từ Movie.
        return 4.5; // Ví dụ trả về điểm giả định
    }

    // --- Getter ---
    public function getData(): string { return $this->data; }
    public function getDate(): DateTime { return $this->date; }

    // --- Phương thức gọi SP sp_getMovieFeedbackList ---
    public static function getListByMovie($db, $movieId) {
        $sql = "CALL sp_getMovieFeedbackList(?)";
        $stmt = $db->prepare($sql);
        $stmt->execute([$movieId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC); 
    }

    // --- Phương thức gọi SP sp_DeleteFeedback ---
    public static function delete($db, $feedbackId) {
        $sql = "CALL sp_DeleteFeedback(?)";
        $stmt = $db->prepare($sql);
        return $stmt->execute([$feedbackId]);
    }
}
?>
