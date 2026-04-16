<?php if (!isset($_SESSION['user_obj']) || $_SESSION['user_obj']->getRole() != 1): ?>
    <?php header("Location: index.php"); exit; ?>
<?php endif; ?>
<?php
require_once __DIR__ . '/../../../Config/config.php';
require_once __DIR__ . '/../../../Config/database.php';

$mysqli = Database::getInstance()->getMysqliConnection();
$selectedFilter = $_GET['filter'] ?? 'all';
$allowedFilters = ['all', 'movie', 'actor', 'draft', 'comments'];

if (!in_array($selectedFilter, $allowedFilters, true)) {
    $selectedFilter = 'all';
}

$stats = [
    'total_news' => 0,
    'movie_news' => 0,
    'actor_news' => 0,
    'total_comments' => 0,
];

$newsList = [];
$commentList = [];
$latestPosts = [];
$dbError = null;

$page = max(1, intval($_GET['page'] ?? 1));
$itemsPerPage = 9;

try {
    $countQueries = [
        'total_news' => "SELECT COUNT(*) AS total FROM tbl_new",
        'movie_news' => "SELECT COUNT(*) AS total FROM tbl_new WHERE New_Category = 'Movie'",
        'actor_news' => "SELECT COUNT(*) AS total FROM tbl_new WHERE New_Category = 'Actor'",
        'total_comments' => "SELECT COUNT(*) AS total FROM tbl_comment",
    ];

    foreach ($countQueries as $key => $sql) {
        $result = $mysqli->query($sql);
        if ($result) {
            $stats[$key] = (int) ($result->fetch_assoc()['total'] ?? 0);
        }
    }

    $whereClause = '';
    if ($selectedFilter === 'movie') {
        $whereClause = "WHERE n.New_Category = 'Movie'";
    } elseif ($selectedFilter === 'actor') {
        $whereClause = "WHERE n.New_Category = 'Actor'";
    } elseif ($selectedFilter === 'draft') {
        $whereClause = "WHERE n.New_Status <> 'Publish'";
    }

    $isCommentView = $selectedFilter === 'comments';
    if ($isCommentView) {
        $countSql = "SELECT COUNT(*) AS total FROM tbl_comment";
    } else {
        $countSql = "SELECT COUNT(*) AS total FROM tbl_new n $whereClause";
    }

    $countResult = $mysqli->query($countSql);
    $totalItems = 0;
    if ($countResult) {
        $totalItems = (int) ($countResult->fetch_assoc()['total'] ?? 0);
    }

    $totalPages = max(1, (int) ceil($totalItems / $itemsPerPage));
    if ($page > $totalPages) {
        $page = $totalPages;
    }
    $offset = ($page - 1) * $itemsPerPage;

    if ($isCommentView) {
        $commentSql = "SELECT c.Comment_ID, c.Comment_Data, c.Comment_Date, c.New_ID,
                              a.Username, n.New_Title
                       FROM tbl_comment c
                       LEFT JOIN tbl_account a ON c.Account_ID = a.Account_ID
                       LEFT JOIN tbl_new n ON c.New_ID = n.New_ID
                       ORDER BY c.Comment_Date DESC
                       LIMIT {$offset}, {$itemsPerPage}";
        $commentResult = $mysqli->query($commentSql);
        if ($commentResult) {
            while ($row = $commentResult->fetch_assoc()) {
                $commentList[] = $row;
            }
        }
    } else {
        $newsSql = "SELECT n.New_ID, n.New_Title, n.New_Description, n.New_Content, n.New_Img,
                           n.New_Category, n.New_Status, n.New_PublishDate, n.New_View,
                           a.Username
                    FROM tbl_new n
                    LEFT JOIN tbl_account a ON n.Account_ID = a.Account_ID
                    $whereClause
                    ORDER BY n.New_PublishDate DESC, n.New_ID DESC
                    LIMIT {$offset}, {$itemsPerPage}";
        $newsResult = $mysqli->query($newsSql);

        if ($newsResult) {
            while ($row = $newsResult->fetch_assoc()) {
                $summary = trim(substr(strip_tags($row['New_Description'] ?: $row['New_Content'] ?: ''), 0, 120));
                $row['short_desc'] = $summary !== '' ? $summary . '...' : 'Chưa có mô tả cho bài viết này.';
                $newsList[] = $row;
            }
        }
    }

    $latestSql = "SELECT New_ID, New_Title, New_PublishDate
                  FROM tbl_new
                  ORDER BY New_PublishDate DESC, New_ID DESC
                  LIMIT 5";
    $latestResult = $mysqli->query($latestSql);
    if ($latestResult) {
        $latestPosts = $latestResult->fetch_all(MYSQLI_ASSOC);
    }
} catch (Throwable $e) {
    $dbError = $e->getMessage();
}
?>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard quan tri</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            --panel-bg: rgba(255, 255, 255, 0.94);
            --panel-border: rgba(255, 255, 255, 0.18);
            --text-main: #1f2937;
            --text-soft: #64748b;
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

        .hero-banner {
            background: var(--primary-gradient);
            color: #fff;
            border-radius: 24px;
            padding: 28px;
            box-shadow: 0 22px 40px rgba(76, 81, 191, 0.28);
        }

        .stat-card {
            border-radius: 22px;
            padding: 22px;
            background: rgba(255, 255, 255, 0.95);
            box-shadow: 0 18px 35px rgba(15, 23, 42, 0.10);
            height: 100%;
            transition: transform 0.25s ease, box-shadow 0.25s ease;
        }

        .stat-card:hover,
        .news-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 24px 45px rgba(15, 23, 42, 0.16);
        }

        .stat-icon {
            width: 54px;
            height: 54px;
            border-radius: 18px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            font-size: 1.1rem;
        }

        .icon-news { background: linear-gradient(135deg, #f59e0b 0%, #f97316 100%); }
        .icon-movie { background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%); }
        .icon-actor { background: linear-gradient(135deg, #10b981 0%, #059669 100%); }
        .icon-comment { background: linear-gradient(135deg, #8b5cf6 0%, #7c3aed 100%); }

        .filter-bar .btn {
            border-radius: 999px;
            padding: 10px 16px;
        }

        .news-card {
            border: none;
            border-radius: 24px;
            overflow: hidden;
            background: rgba(255, 255, 255, 0.96);
            box-shadow: 0 18px 40px rgba(15, 23, 42, 0.10);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            height: 100%;
        }

        .news-cover {
            height: 210px;
            background: var(--primary-gradient);
            position: relative;
            overflow: hidden;
        }

        .news-cover img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .news-cover-fallback {
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: rgba(255, 255, 255, 0.85);
            font-size: 3rem;
        }

        .badge-floating {
            position: absolute;
            top: 16px;
            right: 16px;
        }

        .news-meta {
            color: var(--text-soft);
            font-size: 0.92rem;
        }
        .news-card .card-body,
        .news-card h3,
        .news-card p,
        .news-meta,
        .table-mini li {
            overflow-wrap: anywhere;
            word-break: break-word;
        }

        .status-badge {
            border-radius: 999px;
            padding: 6px 12px;
            font-weight: 600;
        }

        .table-mini li + li {
            border-top: 1px solid rgba(148, 163, 184, 0.18);
        }

        @media (max-width: 991px) {
            .sidebar-panel {
                position: static;
            }
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
        <div class="brand-mark">
            <i class="fas fa-film"></i>
        </div>
        <div>
            <h4 class="mb-0 fw-bold">Admin Panel</h4>
            <div class="text-muted small">Điện ảnh & Sao</div>
        </div>
    </div>

    <div class="d-grid gap-2">
        <a class="sidebar-link <?= ($GLOBALS['selectedFilter'] ?? 'all') === 'all' ? 'active' : '' ?>" 
           href="index.php?controller=admin&action=dashboard&filter=all">
            <i class="fas fa-chart-line"></i>
            <span>Tổng quan</span>
        </a>
        <a class="sidebar-link <?= ($GLOBALS['selectedFilter'] ?? '') === 'movie' ? 'active' : '' ?>" 
           href="index.php?controller=admin&action=dashboard&filter=movie">
            <i class="fas fa-film"></i>
            <span>Tin phim</span>
        </a>
        <a class="sidebar-link <?= ($GLOBALS['selectedFilter'] ?? '') === 'actor' ? 'active' : '' ?>" 
           href="index.php?controller=admin&action=dashboard&filter=actor">
            <i class="fas fa-user"></i>
            <span>Tin diễn viên</span>
        </a>
        <a class="sidebar-link <?= ($GLOBALS['selectedFilter'] ?? '') === 'comments' ? 'active' : '' ?>" 
           href="index.php?controller=admin&action=dashboard&filter=comments">
            <i class="fas fa-comments"></i>
            <span>Bình luận</span>
        </a>
        <a class="sidebar-link <?= ($GLOBALS['selectedFilter'] ?? '') === 'draft' ? 'active' : '' ?>" 
           href="index.php?controller=admin&action=dashboard&filter=draft">
            <i class="fas fa-edit"></i>
            <span>Bản nháp</span>
        </a>
        <a class="sidebar-link" href="index.php?controller=admin&action=addpost">
            <i class="fas fa-plus"></i>
            <span>Thêm bài viết</span>
        </a>
    </div>

    <!-- Latest posts -->
    <div class="mt-4 pt-3 border-top">
        <div class="small text-muted mb-2">Bài viết mới nhất</div>
        <ul class="list-unstyled mb-0 table-mini">
            <?php if (empty($GLOBALS['latestPosts'] ?? [])): ?>
                <li class="py-2 text-muted">Chưa có dữ liệu.</li>
            <?php else: ?>
                <?php foreach ($GLOBALS['latestPosts'] as $post): ?>
                    <li class="py-2">
                        <div class="fw-semibold small"><?= htmlspecialchars($post['New_Title']) ?></div>
                        <div class="text-muted small"><?= date('d/m/Y', strtotime($post['New_PublishDate'])) ?></div>
                    </li>
                <?php endforeach; ?>
            <?php endif; ?>
        </ul>
    </div>
</aside>
                </div>

                <div class="col-lg-9">
                    <main class="glass-panel content-panel">
                        <section class="hero-banner mb-4">
                            <div class="d-flex flex-column flex-lg-row justify-content-between align-items-lg-center gap-3">
                                <div>
                                    <p class="text-uppercase small mb-2 opacity-75">Bảng điều khiển quản trị</p>
                                    <h1 class="h3 fw-bold mb-2">Quản lý nội dung đồng bộ với giao diện trang chủ</h1>
                                    <p class="mb-0 opacity-75">Theo dõi nhanh tình trạng bài viết, danh mục và tương tác từ cùng một màn hình.</p>
                                </div>
                                <a class="btn btn-warning btn-lg rounded-pill px-4" href="index.php?controller=admin&action=addpost">
                                    <i class="fas fa-plus me-2"></i>Tạo bài viết
                                </a>
                            </div>
                        </section>

                        <?php if ($dbError): ?>
                            <div class="alert alert-danger rounded-4 mb-4">
                                Không tải được dữ liệu từ database: <?= htmlspecialchars($dbError) ?>
                            </div>
                        <?php endif; ?>

                        <section class="row g-3 mb-4">
                            <div class="col-md-6 col-xl-3">
                                <div class="stat-card">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <div class="text-muted small text-uppercase mb-2">Tổng bài viết</div>
                                            <div class="display-6 fw-bold"><?= number_format($stats['total_news']) ?></div>
                                        </div>
                                        <div class="stat-icon icon-news">
                                            <i class="fas fa-newspaper"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6 col-xl-3">
                                <div class="stat-card">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <div class="text-muted small text-uppercase mb-2">Tin phim</div>
                                            <div class="display-6 fw-bold"><?= number_format($stats['movie_news']) ?></div>
                                        </div>
                                        <div class="stat-icon icon-movie">
                                            <i class="fas fa-clapperboard"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6 col-xl-3">
                                <div class="stat-card">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <div class="text-muted small text-uppercase mb-2">Tin diễn viên</div>
                                            <div class="display-6 fw-bold"><?= number_format($stats['actor_news']) ?></div>
                                        </div>
                                        <div class="stat-icon icon-actor">
                                            <i class="fas fa-users"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-6 col-xl-3">
                                <div class="stat-card">
                                    <div class="d-flex justify-content-between align-items-start">
                                        <div>
                                            <div class="text-muted small text-uppercase mb-2">Bình luận</div>
                                            <div class="display-6 fw-bold"><?= number_format($stats['total_comments']) ?></div>
                                        </div>
                                        <div class="stat-icon icon-comment">
                                            <i class="fas fa-comments"></i>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </section>

                        <section class="d-flex flex-column flex-lg-row justify-content-between align-items-lg-center gap-3 mb-4">
                            <div>
                                <h2 class="h4 fw-bold mb-1"><?= $selectedFilter === 'comments' ? 'Danh sách bình luận' : 'Danh sách bài viết' ?></h2>
                            </div>
                            <div class="filter-bar d-flex flex-wrap gap-2">
                                <a class="btn <?= ($GLOBALS['selectedFilter'] ?? '') === 'all' ? 'btn-dark' : 'btn-outline-dark' ?>" 
                                href="index.php?controller=admin&action=dashboard&filter=all">Tất cả</a>
                                <a class="btn <?= ($GLOBALS['selectedFilter'] ?? '') === 'movie' ? 'btn-primary' : 'btn-outline-primary' ?>" 
                                href="index.php?controller=admin&action=dashboard&filter=movie">Tin phim</a>
                                <a class="btn <?= ($GLOBALS['selectedFilter'] ?? '') === 'actor' ? 'btn-success' : 'btn-outline-success' ?>" 
                                href="index.php?controller=admin&action=dashboard&filter=actor">Diễn viên</a>
                                <a class="btn <?= ($GLOBALS['selectedFilter'] ?? '') === 'comments' ? 'btn-info text-white' : 'btn-outline-info' ?>" 
                                href="index.php?controller=admin&action=dashboard&filter=comments">Bình luận</a>
                                <a class="btn <?= ($GLOBALS['selectedFilter'] ?? '') === 'draft' ? 'btn-warning' : 'btn-outline-warning' ?>" 
                                href="index.php?controller=admin&action=dashboard&filter=draft">Bản nháp</a>
                            </div>
                        </section>

                        <section class="row g-4">
                            <?php if ($selectedFilter === 'comments'): ?>
                                <?php if (empty($commentList)): ?>
                                    <div class="col-12">
                                        <div class="stat-card text-center py-5">
                                            <i class="fas fa-inbox fa-3x mb-3 text-muted"></i>
                                            <h3 class="h5 fw-bold">Không có bình luận</h3>
                                            <p class="text-muted mb-0">Hãy kiểm tra lại dữ liệu hoặc chờ bình luận mới.</p>
                                        </div>
                                    </div>
                                <?php else: ?>
                                    <?php foreach ($commentList as $comment): ?>
                                        <div class="col-md-6 col-xl-4">
                                            <article class="news-card">
                                                <div class="card-body p-4">
                                                    <div class="d-flex justify-content-between align-items-center mb-3">
                                                        <span class="badge bg-info text-dark">Bình luận</span>
                                                        <span class="news-meta"><i class="fas fa-calendar me-1"></i><?= date('d/m/Y H:i', strtotime($comment['Comment_Date'] ?? '')) ?></span>
                                                    </div>
                                                    <h3 class="h5 fw-bold mb-3"><?= htmlspecialchars($comment['Username'] ?? 'Người dùng ẩn danh') ?></h3>
                                                    <p class="text-muted mb-4"><?= nl2br(htmlspecialchars($comment['Comment_Data'] ?? '')) ?></p>
                                                    <div class="news-meta d-flex justify-content-between align-items-center mb-4">
                                                        <span><i class="fas fa-newspaper me-1"></i><?= htmlspecialchars($comment['New_Title'] ?? 'Bài viết đã xóa') ?></span>
                                                        <span><i class="fas fa-hashtag me-1"></i>ID <?= (int) $comment['Comment_ID'] ?></span>
                                                    </div>
                                                    <div class="d-flex gap-2">
                                                        <a href="index.php?controller=admin&action=detailpost&id=<?= (int)$comment['New_ID'] ?>" class="btn btn-outline-primary rounded-pill flex-fill">Xem tin</a>
                                                    </div>
                                                </div>
                                            </article>
                                        </div>
                                    <?php endforeach; ?>
                                <?php endif; ?>
                            <?php else: ?>
                                <?php if (empty($newsList)): ?>
                                    <div class="col-12">
                                        <div class="stat-card text-center py-5">
                                            <i class="fas fa-inbox fa-3x mb-3 text-muted"></i>
                                            <h3 class="h5 fw-bold">Không có bài viết phù hợp</h3>
                                            <p class="text-muted mb-0">Hãy đổi bộ lọc hoặc thêm dữ liệu trong database.</p>
                                        </div>
                                    </div>
                                <?php else: ?>
                                    <?php foreach ($newsList as $news): ?>
                                        <?php
                                        $isActor = ($news['New_Category'] ?? '') === 'Actor';
                                        $isPublished = ($news['New_Status'] ?? '') === 'Publish';
                                        $badgeClass = $isActor ? 'bg-info text-dark' : 'bg-warning text-dark';
                                        $statusClass = $isPublished ? 'bg-success-subtle text-success' : 'bg-secondary-subtle text-secondary';
                                        ?>
                                        <div class="col-md-6 col-xl-4">
                                            <article class="news-card">
                                                <div class="news-cover">
                                                    <?php if (!empty($news['New_Img'])): ?>
                                                        <img src="uploads/news/<?= htmlspecialchars($news['New_Img']) ?>" alt="<?= htmlspecialchars($news['New_Title']) ?>">
                                                    <?php else: ?>
                                                        <div class="news-cover-fallback">
                                                            <i class="fas <?= $isActor ? 'fa-user-astronaut' : 'fa-film' ?>"></i>
                                                        </div>
                                                    <?php endif; ?>

                                                    <span class="badge rounded-pill <?= $badgeClass ?> badge-floating px-3 py-2">
                                                        <?= $isActor ? 'Diễn viên' : 'Phim ảnh' ?>
                                                    </span>
                                                </div>

                                                <div class="card-body p-4">
                                                    <div class="d-flex justify-content-between align-items-center mb-3">
                                                        <span class="status-badge <?= $statusClass ?>">
                                                            <?= $isPublished ? 'Published' : htmlspecialchars($news['New_Status'] ?? 'Draft') ?>
                                                        </span>
                                                        <span class="news-meta">
                                                            <i class="fas fa-eye me-1"></i><?= number_format((int) ($news['New_View'] ?? 0)) ?>
                                                        </span>
                                                    </div>

                                                    <h3 class="h5 fw-bold mb-3"><?= htmlspecialchars($news['New_Title']) ?></h3>
                                                    <p class="text-muted mb-3"><?= htmlspecialchars($news['short_desc']) ?></p>

                                                    <div class="news-meta d-flex justify-content-between align-items-center mb-4">
                                                        <span><i class="fas fa-user me-1"></i><?= htmlspecialchars($news['Username'] ?? 'Chua ro tac gia') ?></span>
                                                        <span><i class="fas fa-calendar me-1"></i><?= !empty($news['New_PublishDate']) ? date('d/m/Y', strtotime($news['New_PublishDate'])) : '--/--/----' ?></span>
                                                    </div>

                                                    <div class="d-flex gap-2">
                                                        <a href="index.php?controller=admin&action=detailpost&id=<?= (int)$news['New_ID'] ?>" class="btn btn-outline-primary rounded-pill flex-fill">
                                                            Xem
                                                        </a>
                                                        <a href="index.php?controller=admin&action=editpost&id=<?= (int) $news['New_ID'] ?>" class="btn btn-outline-warning rounded-pill flex-fill">
                                                            Sửa
                                                        </a>
                                                    </div>
                                                </div>
                                            </article>
                                        </div>
                                    <?php endforeach; ?>
                                <?php endif; ?>
                            <?php endif; ?>
                        </section>

                        <?php if (($GLOBALS['totalPages'] ?? 1) > 1): ?>
                            <nav aria-label="Phân trang bài viết" class="mt-4">
                                <ul class="pagination justify-content-center flex-wrap">
                                    <?php for ($pageIndex = 1; $pageIndex <= $GLOBALS['totalPages']; $pageIndex++): ?>
                                        <?php $query = 'index.php?controller=admin&action=dashboard&filter=' . urlencode($GLOBALS['selectedFilter']) . '&page=' . $pageIndex; ?>
                                        <li class="page-item <?= $pageIndex === $GLOBALS['page'] ? 'active' : '' ?>">
                                            <a class="page-link" href="<?= htmlspecialchars($query) ?>"><?= $pageIndex ?></a>
                                        </li>
                                    <?php endfor; ?>
                                </ul>
                            </nav>
                        <?php endif; ?>
                    </main>
                </div>
            </div>
        </div>
    </div>

</body>
</html>
