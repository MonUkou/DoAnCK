<?php if (!isset($_SESSION['user_obj']) || $_SESSION['user_obj']->getRole() != 1): ?>
    <?php header("Location: index.php"); exit; ?>
<?php endif; ?>
<?php
require_once __DIR__ . '/../../../Config/config.php';
require_once __DIR__ . '/../../../Config/database.php';

$mysqli = Database::getInstance()->getMysqliConnection();
$postId = isset($_GET['id']) ? intval($_GET['id']) : 0;
$post = null;
$error = null;
$success = null;

if ($postId <= 0) {
    $error = 'ID bài viết không hợp lệ.';
} else {
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['delete_post'])) {
        $deleteStmt = $mysqli->prepare('DELETE FROM tbl_new WHERE New_ID = ?');
        if ($deleteStmt) {
            $deleteStmt->bind_param('i', $postId);
            if ($deleteStmt->execute()) {
                $deleteStmt->close();
                header('Location: index.php?controller=admin&action=dashboard&deleted=1');
                exit;
            }
            $error = 'Xóa bài viết thất bại: ' . $mysqli->error;
            $deleteStmt->close();
        } else {
            $error = 'Lỗi chuẩn bị truy vấn xóa: ' . $mysqli->error;
        }
    }

    $stmt = $mysqli->prepare(
        'SELECT n.New_ID, n.New_Title, n.New_Description, n.New_Content, n.New_Img,
                n.New_Category, n.New_Status, n.New_PublishDate, n.New_View,
                a.Username
         FROM tbl_new n
         LEFT JOIN tbl_account a ON n.Account_ID = a.Account_ID
         WHERE n.New_ID = ?
         LIMIT 1'
    );

    if ($stmt) {
        $stmt->bind_param('i', $postId);
        $stmt->execute();
        $result = $stmt->get_result();
        $post = $result ? $result->fetch_assoc() : null;
        $stmt->close();

        if (!$post) {
            $error = 'Không tìm thấy bài viết.';
        }
    } else {
        $error = 'Lỗi truy vấn: ' . $mysqli->error;
    }
}

function escape($value) {
    return htmlspecialchars($value, ENT_QUOTES, 'UTF-8');
}

function formatDate($value) {
    $timestamp = strtotime($value);
    return $timestamp ? date('d/m/Y', $timestamp) : '-';
}
?>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết bài viết - Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            --panel-bg: rgba(255, 255, 255, 0.94);
            --panel-border: rgba(255, 255, 255, 0.18);
            --text-main: #1f2937;
        }

        body {
            min-height: 100vh;
            background: var(--primary-gradient);
            color: var(--text-main);
        }

        .dashboard-shell {
            padding: 32px 0;
        }

        .glass-panel {
            background: var(--panel-bg);
            border: 1px solid var(--panel-border);
            border-radius: 24px;
            box-shadow: 0 24px 50px rgba(15, 23, 42, 0.18);
            backdrop-filter: blur(18px);
        }

        .sidebar-panel {
            padding: 28px 22px;
            position: sticky;
            top: 24px;
        }

        .brand-mark {
            width: 52px;
            height: 52px;
            border-radius: 16px;
            background: var(--primary-gradient);
            color: #fff;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 16px 30px rgba(102, 126, 234, 0.35);
        }

        .sidebar-link {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 14px;
            border-radius: 16px;
            color: var(--text-main);
            text-decoration: none;
            transition: all 0.25s ease;
        }

        .sidebar-link:hover,
        .sidebar-link.active {
            background: rgba(102, 126, 234, 0.12);
            color: #4f46e5;
            transform: translateX(4px);
        }

        .content-panel {
            padding: 30px;
        }

        .post-image {
            max-width: 100%;
            border-radius: 18px;
            object-fit: cover;
            height: auto;
            margin-bottom: 24px;
        }

        .badge-category {
            background: #eef2ff;
            color: #4338ca;
        }

        .badge-status {
            background: #eefdf3;
            color: #166534;
        }

        .badge-status.draft {
            background: #fef3c7;
            color: #92400e;
        }

        .btn-delete {
            min-width: 150px;
            border-width: 1.5px;
        }

        .metadata dt {
            font-size: 0.95rem;
            color: #475569;
        }

        .metadata dd {
            margin-bottom: 12px;
            font-size: 1rem;
        }

        @media (max-width: 991px) {
            .sidebar-panel { position: static; }
        }
    </style>
</head>
<body>
    <div class="container-fluid dashboard-shell">
        <div class="container-xxl">
            <div class="row g-4">
                <div class="col-lg-3">
                    <aside class="glass-panel sidebar-panel h-100">
    <div class="d-flex align-items-center gap-3 mb-4">
        <div class="brand-mark"><i class="fas fa-film"></i></div>
        <div>
            <h4 class="mb-0 fw-bold">Admin Panel</h4>
            <div class="text-muted small">Điện ảnh & Sao</div>
        </div>
    </div>
    <div class="d-grid gap-2">
        <a class="sidebar-link" href="index.php?controller=admin&action=dashboard">
            <i class="fas fa-chart-line"></i><span>Dashboard</span>
        </a>
        <a class="sidebar-link" href="index.php?controller=admin&action=addpost">
            <i class="fas fa-plus"></i><span>Thêm bài viết</span>
        </a>
        <a class="sidebar-link active" href="index.php?controller=admin&action=detailpost&id=<?= $GLOBALS['post']['New_ID'] ?>">
            <i class="fas fa-eye"></i><span>Chi tiết bài viết</span>
        </a>
    </div>
</aside>
                </div>
                <div class="col-lg-9">
                    <main class="glass-panel content-panel">
                        <div class="d-flex flex-column flex-lg-row justify-content-between align-items-lg-center gap-3 mb-4">
                            <div>
                                <p class="text-uppercase small mb-2 opacity-75">Quản trị bài viết</p>
                                <h1 class="h3 fw-bold mb-2">Chi tiết bài viết</h1>
                                <p class="mb-0 opacity-75">Xem chi tiết bài viết và trạng thái đăng trên dashboard.</p>
                            </div>
                            <div class="d-flex gap-2">
                                <a class="btn btn-outline-secondary rounded-pill px-4" href="dashboard.php">
                                    <i class="fas fa-arrow-left me-2"></i>Quay lại
                                </a>
                                <?php if ($post): ?>
                                    <a class="btn btn-outline-warning rounded-pill px-4" href="editpost.php?id=<?= escape($post['New_ID']) ?>">
                                        <i class="fas fa-pen me-2"></i>Chỉnh sửa
                                    </a>
                                    <form method="post" class="d-inline" onsubmit="return confirm('Bạn có chắc chắn muốn xóa bài viết này?');">
                                        <button type="submit" name="delete_post" class="btn btn-outline-danger rounded-pill btn-delete px-4">
                                            <i class="fas fa-trash me-2"></i>Xóa bài viết
                                        </button>
                                    </form>
                                <?php endif; ?>
                            </div>
                        </div>

                        <?php if ($error): ?>
                            <div class="alert alert-danger rounded-4 mb-4"><?= escape($error) ?></div>
                        <?php elseif ($success): ?>
                            <div class="alert alert-success rounded-4 mb-4"><?= escape($success) ?></div>
                        <?php endif; ?>
                        <?php if (!$error && $post): ?>
                            <?php if (!empty($post['New_Img'])): ?>
                                <img src="<?= escape($post['New_Img']) ?>" alt="<?= escape($post['New_Title']) ?>" class="post-image w-100">
                            <?php endif; ?>

                            <div class="mb-4">
                                <span class="badge badge-category px-3 py-2 rounded-pill me-2">
                                    <?= escape($post['New_Category'] === 'Actor' ? 'Diễn viên' : 'Phim ảnh') ?>
                                </span>
                                <span class="badge badge-status <?= $post['New_Status'] !== 'Publish' ? 'draft' : '' ?> px-3 py-2 rounded-pill">
                                    <?= escape($post['New_Status']) ?>
                                </span>
                            </div>

                            <h2 class="fw-bold mb-3"><?= escape($post['New_Title']) ?></h2>

                            <?php if (!empty($post['New_Description'])): ?>
                                <p class="lead text-muted mb-4"><?= escape($post['New_Description']) ?></p>
                            <?php endif; ?>

                            <dl class="row metadata mb-4">
                                <dt class="col-sm-4">Ngày đăng</dt>
                                <dd class="col-sm-8"><?= escape(formatDate($post['New_PublishDate'])) ?></dd>

                                <dt class="col-sm-4">Người đăng</dt>
                                <dd class="col-sm-8"><?= escape($post['Username'] ?? 'Admin') ?></dd>

                                <dt class="col-sm-4">Số lượt xem</dt>
                                <dd class="col-sm-8"><?= (int) $post['New_View'] ?></dd>
                            </dl>

                            <div class="border rounded-4 p-4 bg-light text-dark" style="white-space: pre-wrap;">
                                <?= nl2br(escape($post['New_Content'])) ?>
                            </div>
                        <?php endif; ?>
                    </main>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
