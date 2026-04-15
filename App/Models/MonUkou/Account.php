<?php

class Account {
    private int $id;
    private string $user;
    private string $pass;
    private string $email;
    private string $tel;
    private int $role;
    private string $img;

    private ?Watchlist $watchlist = null;
    private array $feedbacks = [];

    // Hàm khởi tạo - ĐÃ SỬA: thêm $img
    public function __construct(int $id, string $user, string $pass, string $email, string $tel, int $role, string $img = '') {
        $this->id = $id;
        $this->user = $user;
        $this->pass = $pass;
        $this->email = $email;
        $this->tel = $tel;
        $this->role = $role;
        $this->img = $img;
    }

    // --- Phương thức xử lý Session (KHÔNG dùng Cookie) ---

    /**
     * Đăng nhập - Trả về true nếu thành công và lưu vào session
     */
    public function login(PDO $db, string $username, string $password): bool {
        $sql = "SELECT * FROM tbl_account WHERE Username = ? AND Password = ?";
        $stmt = $db->prepare($sql);
        $stmt->execute([$username, $password]);
        $userData = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($userData) {
            // Lưu thông tin vào SESSION
            $_SESSION['user'] = [
                'id'    => (int)$userData['Account_ID'],
                'name'  => $userData['Username'],
                'email' => $userData['Mail'],
                'tel'   => $userData['Tel'] ?? '',
                'role'  => (int)$userData['Role'],
                'img'   => $userData['Account_Img'] ?? ''
            ];
            return true;
        }
        return false;
    }

    /**
     * Đăng xuất - Xóa session
     */
    public static function logout(): void {
        session_unset();
        session_destroy();
    }

    /**
     * Kiểm tra đã đăng nhập chưa
     */
    public static function isLoggedIn(): bool {
        return isset($_SESSION['user']);
    }

    /**
     * Lấy thông tin user hiện tại từ session
     */
    public static function getCurrentUser(): ?array {
        return $_SESSION['user'] ?? null;
    }

    /**
     * Cập nhật profile
     */
    public function updateProfile(string $email, string $tel): void {
        $this->email = $email;
        $this->tel = $tel;
    }

    // --- Getter / Setter ---
    public function getId(): int { return $this->id; }
    public function getUser(): string { return $this->user; }
    public function getEmail(): string { return $this->email; }
    public function getRole(): int { return $this->role; }

    public function setWatchlist(Watchlist $watchlist): void {
        $this->watchlist = $watchlist;
    }

    public function addFeedback(Feedback $feedback): void {
        $this->feedbacks[] = $feedback;
    }

    // --- Gọi Stored Procedure - ĐÃ SỬA thứ tự tham số ---

    /**
     * Đăng ký tài khoản mới
     */
    public static function insertAccount(PDO $db, string $user, string $pass, string $mail, string $tel, string $img, int $role): bool {
        $sql = "CALL sp_InsertAccount(?, ?, ?, ?, ?, ?)";
        $stmt = $db->prepare($sql);
        return $stmt->execute([$user, $pass, $mail, (int)$tel, $img, $role]);
    }

    /**
     * Cập nhật tài khoản (cần sửa procedure hoặc dùng UPDATE trực tiếp)
     */
    public function save(PDO $db): bool {
        // Dùng UPDATE trực tiếp vì sp_UpdateAccount chưa có tham số ID
        $sql = "UPDATE tbl_account SET 
                    Username = ?, 
                    Password = ?, 
                    Mail = ?, 
                    Tel = ?, 
                    Account_Img = ?, 
                    Role = ? 
                WHERE Account_ID = ?";
        $stmt = $db->prepare($sql);
        return $stmt->execute([
            $this->user,
            $this->pass,
            $this->email,
            (int)$this->tel,
            $this->img,
            $this->role,
            $this->id
        ]);
    }
}
?>
