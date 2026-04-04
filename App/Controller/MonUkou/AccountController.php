<?php
namespace App\Controllers\MonUkou;

use Account; // Hoặc đường dẫn đúng tới file Model Account.php

class AccountController {
    // Xử lý Đăng nhập
    public function login($db) {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $user_input = $_POST['username'] ?? '';
            $pass_input = $_POST['password'] ?? '';

            if (empty($user_input) || empty($pass_input)) {
                die("Vui lòng điền đầy đủ thông tin!");
            }

            // Theo Model của bạn, cần viết thêm logic lấy Account từ DB 
            // Ở đây mình hướng dẫn cách gọi SP để check đăng nhập (giả định bạn có SP này)
            $sql = "SELECT * FROM tbl_account WHERE Username = ? AND Password = ?";
            $stmt = $db->prepare($sql);
            $stmt->execute([$user_input, $pass_input]);
            $userData = $stmt->fetch(\PDO::FETCH_ASSOC);

            if ($userData) {
                // Khởi tạo đối tượng Account từ dữ liệu DB
                $_SESSION['user_obj'] = new Account(
                    $userData['Account_ID'],
                    $userData['Username'],
                    $userData['Password'],
                    $userData['Mail'],
                    $userData['Tel'] ?? '',
                    1 // Role mặc định
                );
                echo "Đăng nhập thành công!";
            } else {
                echo "Sai tài khoản hoặc mật khẩu.";
            }
        }
    }

    // Xử lý Đăng ký (Gọi đúng sp_InsertAccount trong Model của bạn)
    public function register($db) {
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $user = $_POST['username'];
            $pass = $_POST['password'];
            $mail = $_POST['email'];
            $tel  = $_POST['tel'];
            $role = 1; // Mặc định là member
            $img  = "default.png";

            // Gọi phương thức static insertAccount trong Model Account.php
            $result = Account::insertAccount($db, 0, $user, $pass, $role, $mail, $tel, $img);

            if ($result) {
                echo "Đăng ký thành công!";
            } else {
                echo "Lỗi đăng ký!";
            }
        }
    }
}
