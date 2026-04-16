<?php
namespace App\Controllers\MonUkou;

class WatchlistController {
    // Thêm phim vào Watchlist của người dùng hiện tại
    public function addWatchlist($db) {
        if (!isset($_SESSION['user_obj'])) {
            die("Bạn chưa đăng nhập!");
        }

        $movieId = (int)$_POST['movie_id'];
        $userAccount = $_SESSION['user_obj']; // Lấy đối tượng Account từ Session

        // Giả định bạn đã set Watchlist cho Account này trước đó
        // Gọi hàm addMovie trong Watchlist.php của bạn
        $watchlist = new \Watchlist(1, "My Watchlist", new \DateTime(), $userAccount); 
        
        $result = $watchlist->addMovie($db, $movieId);

        if ($result) {
            echo "Đã thêm phim vào danh sách xem sau!";
        } else {
            echo "Thêm thất bại.";
        }
    }
}
