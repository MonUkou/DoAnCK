<?php
namespace App\Controllers\MonUkou;

require_once __DIR__ . '/../../Models/MonUkou/Account.php';
require_once __DIR__ . '/../../../Config/database.php';

use App\Models\MonUkou\Account; // 🔥 THÊM DÒNG NÀY
class AccountController {

    public function showLogin() {
        include 'App/Views/login.php';
    }
    public function profile() {

    if (!isset($_SESSION['user_obj'])) {
        header("Location: index.php?controller=account&action=login");
        exit;
    }

    $GLOBALS['user'] = $_SESSION['user_obj'];

    include 'App/Views/member/profile.php';
}
    public function updateProfile() {
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {

        $user = $_SESSION['user_obj'];

        $email = $_POST['email'];
        $tel = $_POST['tel'];

        $imgName = $user->getImg(); // giữ ảnh cũ

        if (!empty($_FILES['avatar']['name'])) {

            $targetDir = "uploads/";
            $fileName = time() . "_" . basename($_FILES["avatar"]["name"]);
            $targetFile = $targetDir . $fileName;

            move_uploaded_file($_FILES["avatar"]["tmp_name"], $targetFile);

            $imgName = $fileName;
        }

$user->updateProfile($email, $tel, $imgName);

        // 🔥 XỬ LÝ UPLOAD AVATAR
        if (!empty($_FILES['avatar']['name'])) {

            $targetDir = "uploads/";
            $fileName = time() . "_" . basename($_FILES["avatar"]["name"]);
            $targetFile = $targetDir . $fileName;

            move_uploaded_file($_FILES["avatar"]["tmp_name"], $targetFile);

            $imgName = $fileName;
        }

        $user->updateProfile($email, $tel, $imgName);

        $user->save(\Database::getInstance()->getConnection());

        $_SESSION['user_obj'] = $user;
        $_SESSION['success'] = "Cập nhật thành công!";

        header("Location: index.php?controller=account&action=profile");
        exit;
    }
}
    public function logout() {
    session_unset();     // xóa dữ liệu session
    session_destroy();   // hủy session

    header("Location: index.php?controller=account&action=login");
    exit;
}

    public function login($db)
{
    $user_input = $_POST['username'] ?? '';
    $pass_input = $_POST['password'] ?? '';

    $sql = "SELECT * FROM tbl_account WHERE Username = ?";
    $stmt = $db->prepare($sql);
    $stmt->execute([$user_input]);

    $userData = $stmt->fetch(\PDO::FETCH_ASSOC);

    if (!$userData) {
        echo "Sai tài khoản";
        return;
    }

    // 🔥 FIX QUAN TRỌNG NHẤT
    if (md5($pass_input) !== $userData['Password']) {
        echo "Sai mật khẩu";
        return;
    }

    $_SESSION['user_obj'] = new Account(
        $userData['Account_ID'],
        $userData['Username'],
        $userData['Password'],
        $userData['Mail'],
        $userData['Tel'] ?? '',
        $userData['Role'],
        $userData['Account_Img'] ?? 'pfp.png'
    );

    if ((int)$userData['Role'] === 1) {
        header("Location: index.php?controller=admin&action=dashboard");
    } else {
        header("Location: index.php?controller=home&action=index");
    }
    exit;
}
}
