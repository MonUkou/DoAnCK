<?php

class Account {
    private int $id;
    private string $user;
    private string $pass;
    private string $email;
    private string $tel;
    private int $role;
    private string $img;

    private ?Watchlist $watchlist = null; // Dấu ? nghĩa là có thể null
    private array $feedbacks = [];

    // Hàm khởi tạo
    public function __construct(int $id, string $user, string $pass, string $email, string $tel, int $role) {
        $this->id = $id;
        $this->user = $user;
        $this->pass = $pass;
        $this->email = $email;
        $this->tel = $tel;
        $this->role = $role;
        $this->img = $img;
    }

    // --- Các phương thức từ sơ đồ ---
    public function login(): bool {
        // Xử lý kiểm tra user/pass với Database
        return true; 
    }

    public function logout(): void {
        // Hủy session đăng nhập
    }

    public function updateProfile(string $email, string $tel): void {
        $this->email = $email;
        $this->tel = $tel;
    }

    // --- Getter / Setter cho các thuộc tính cần thiết ---
    public function getId(): int { return $this->id; }
    public function getUser(): string { return $this->user; }
    
    // Gán Watchlist cho Account
    public function setWatchlist(Watchlist $watchlist): void {
        $this->watchlist = $watchlist;
    }

    // Thêm Feedback vào danh sách của user
    public function addFeedback(Feedback $feedback): void {
        $this->feedbacks[] = $feedback;
    }

    // --- Phương thức gọi SP sp_InsertAccount ---
    public static function insertAccount($db, $id, $user, $pass, $role, $mail, $tel, $img) {
        $sql = "CALL sp_InsertAccount(?, ?, ?, ?, ?, ?, ?)";
        $stmt = $db->prepare($sql);
        return $stmt->execute([$id, $user, $pass, $role, $mail, $tel, $img]);
    }

    // --- Phương thức gọi SP sp_UpdateAccount ---
    public function save($db) {
        $sql = "CALL sp_UpdateAccount(?, ?, ?, ?, ?, ?, ?)";
        $stmt = $db->prepare($sql);
        return $stmt->execute([
            $this->id, 
            $this->user, 
            $this->pass, 
            $this->role, 
            $this->email, 
            $this->tel, 
            $this->img
        ]);
    }
}
?>
