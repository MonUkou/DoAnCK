<?php
$news = $GLOBALS['news'] ?? [
    'New_Title' => '',
    'New_Description' => '',
    'New_Content' => '',
    'New_Img' => '',
    'New_Category' => 'Movie',
    'New_Status' => 'Under Review',
];
$error = $GLOBALS['error'] ?? null;
$availableStatusOptions = $GLOBALS['availableStatusOptions'] ?? ['Under Review', 'Publish', 'Banned'];
$hasCategoryField = $GLOBALS['hasCategoryField'] ?? true;

function escape($value) {
    return htmlspecialchars((string) $value, ENT_QUOTES, 'UTF-8');
}
?>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thêm bài viết - Admin</title>
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
            overflow-wrap: anywhere;
        }
        .form-control,
        .form-select,
        textarea {
            max-width: 100%;
        }
        textarea.form-control {
            white-space: pre-wrap;
            overflow-wrap: anywhere;
            word-break: break-word;
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
                            <a class="sidebar-link active" href="index.php?controller=admin&action=addpost">
                                <i class="fas fa-plus"></i><span>Thêm bài viết</span>
                            </a>
                            <a class="sidebar-link" href="index.php">
                                <i class="fas fa-house"></i><span>Trang chủ</span>
                            </a>
                        </div>
                    </aside>
                </div>
                <div class="col-lg-9">
                    <main class="glass-panel content-panel">
                        <div class="d-flex flex-column flex-lg-row justify-content-between align-items-lg-center gap-3 mb-4">
                            <div>
                                <p class="text-uppercase small mb-2 opacity-75">Danh sách bài viết</p>
                                <h1 class="h3 fw-bold mb-2">Thêm bài viết mới</h1>
                                <p class="mb-0 opacity-75"></p>
                            </div>
                            <a class="btn btn-outline-secondary rounded-pill px-4" href="index.php?controller=admin&action=dashboard">
                                <i class="fas fa-arrow-left me-2"></i>Quay lại
                            </a>
                        </div>
                        <?php if ($error): ?>
                            <div class="alert alert-danger rounded-4 mb-4"><?= escape($error) ?></div>
                        <?php endif; ?>
                        <form method="post" enctype="multipart/form-data" class="row g-4">
                            <div class="col-12">
                                <label class="form-label fw-semibold">Tiêu đề</label>
                                <input type="text" name="New_Title" class="form-control form-control-lg" value="<?= escape($news['New_Title']) ?>" required>
                            </div>
                            <div class="col-12">
                                <label class="form-label fw-semibold">Mô tả ngắn</label>
                                <textarea name="New_Description" rows="3" class="form-control"><?= escape($news['New_Description']) ?></textarea>
                            </div>
                            <div class="col-12">
                                <label class="form-label fw-semibold">Nội dung đầy đủ</label>
                                <textarea name="New_Content" rows="8" class="form-control" required><?= escape($news['New_Content']) ?></textarea>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-semibold">Ảnh bài viết</label>
                                <input type="file" name="New_Img" class="form-control" accept="image/*">
                                <div class="form-text"></div>
                            </div>
                            <?php if ($hasCategoryField): ?>
                            <div class="col-md-3">
                                <label class="form-label fw-semibold">Danh mục</label>
                                <select name="New_Category" class="form-select">
                                    <option value="Movie" <?= $news['New_Category'] === 'Movie' ? 'selected' : '' ?>>Phim ảnh</option>
                                    <option value="Actor" <?= $news['New_Category'] === 'Actor' ? 'selected' : '' ?>>Diễn viên</option>
                                </select>
                            </div>
                            <?php endif; ?>
                            <div class="col-md-3">
                                <label class="form-label fw-semibold">Trang thái</label>
                                <select name="New_Status" class="form-select">
                                    <?php foreach ($availableStatusOptions as $statusOption): ?>
                                        <option value="<?= escape($statusOption) ?>" <?= $news['New_Status'] === $statusOption ? 'selected' : '' ?>><?= escape($statusOption) ?></option>
                                    <?php endforeach; ?>
                                </select>
                            </div>
                            <div class="col-12 d-flex gap-2 justify-content-end">
                                <button type="submit" class="btn btn-primary rounded-pill px-4">Lưu bài viết</button>
                                <a href="index.php?controller=admin&action=dashboard" class="btn btn-outline-secondary rounded-pill px-4">Hủy</a>
                            </div>
                        </form>
                    </main>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
