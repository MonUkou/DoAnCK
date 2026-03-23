<?php

class Watchlist {
    private int $id;
    private string $name;
    private DateTime $date;
    private Account $account;
    private array $movies = []; // Khởi tạo mảng rỗng chứa các đối tượng Movie

    public function __construct(int $id, string $name, DateTime $date, Account $account) {
        $this->id = $id;
        $this->name = $name;
        $this->date = $date;
        $this->account = $account;
    }

    // --- Các phương thức từ sơ đồ ---

    // Đồng bộ danh sách phim từ Database vào thuộc tính $movies
    public function loadMoviesFromDb($db): void {
        try {
            $sql = "CALL sp_GetMoviesInWatchlist(?)";
            $stmt = $db->prepare($sql);
            $stmt->execute([$this->id]);
            
            // Nạp dữ liệu vào mảng (trả về danh sách phim từ bảng tbl_movie)
            $this->movies = $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            error_log("Lỗi load Watchlist: " . $e->getMessage());
            $this->movies = [];
        }
    }
    
    // Thêm phim vào danh sách
    public function addMovie($db, int $movieId): bool {
        try {
            // SP: sp_AddMovieToWatchlist(p_Movie_ID, p_Watchlist_ID)
            $sql = "CALL sp_AddMovieToWatchlist(?, ?)";
            $stmt = $db->prepare($sql);
            $result = $stmt->execute([$movieId, $this->id]);
            
            if ($result) {
                $this->loadMoviesFromDb($db); // Refresh lại danh sách
            }
            return $result;
        } catch (PDOException $e) {
            error_log("Lỗi thêm phim vào Watchlist: " . $e->getMessage());
            return false;
        }
    }

    // Xóa phim khỏi danh sách
    public function removeMovie($db, int $movieId): bool {
        try {
            // SP: sp_RemoveMovieFromWatchlist(p_Movie_ID, p_Watchlist_ID)
            $sql = "CALL sp_RemoveMovieFromWatchlist(?, ?)";
            $stmt = $db->prepare($sql);
            $result = $stmt->execute([$movieId, $this->id]);
            
            if ($result) {
                $this->loadMoviesFromDb($db); // Refresh lại danh sách
            }
            return $result;
        } catch (PDOException $e) {
            error_log("Lỗi xóa phim khỏi Watchlist: " . $e->getMessage());
            return false;
        }
    }

    // --- Getter ---
    public function getId(): int { return $this->id; }
    public function getName(): string { return $this->name; }
    public function getMovies(): array { return $this->movies; }
}
?>
