<?php
namespace App\Models\MonUkou;

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

    // ===== CONSTRUCTOR =====
    public function __construct(
        int $id, 
        string $user, 
        string $pass, 
        string $email, 
        string $tel, 
        int $role, 
        string $img = 'default.png'
    ) {
        $this->id = $id;
        $this->user = $user;
        $this->pass = $pass;
        $this->email = $email;
        $this->tel = $tel;
        $this->role = $role;
        $this->img = $img;
    }

    // ===== ROLE =====
    public function getRole(): int {
        return $this->role;
    }

    // ===== LOGIN / LOGOUT =====
    public function login(): bool {
        return true;
    }

    public function logout(): void {
        session_destroy();
    }

    // ===== UPDATE PROFILE =====
    public function updateProfile(string $email, string $tel, ?string $img = null): void {
    $this->email = $email;
    $this->tel = $tel;

    if ($img !== null) {
        $this->img = $img;
    }
}

    // ===== GETTER =====
    public function getId(): int { return $this->id; }
    public function getUser(): string { return $this->user; }
    public function getEmail(): string { return $this->email; }
    public function getTel(): string { return $this->tel; }
    public function getImg(): string { return $this->img; }

    // ===== WATCHLIST =====
    public function setWatchlist(Watchlist $watchlist): void {
        $this->watchlist = $watchlist;
    }

    // ===== FEEDBACK =====
    public function addFeedback(Feedback $feedback): void {
        $this->feedbacks[] = $feedback;
    }

    // ===== STORED PROCEDURE =====
    public static function insertAccount($db, $id, $user, $pass, $role, $mail, $tel, $img) {
        $sql = "CALL sp_InsertAccount(?, ?, ?, ?, ?, ?, ?)";
        $stmt = $db->prepare($sql);
        return $stmt->execute([$id, $user, $pass, $role, $mail, $tel, $img]);
    }

    public function save($db) {
    $sql = "CALL sp_UpdateAccountFull(?, ?, ?, ?)";
        $stmt = $db->prepare($sql);
        return $stmt->execute([
            $this->id,
            $this->email,
            $this->tel,
            $this->img
        ]);
    }


}
