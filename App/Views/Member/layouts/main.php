<?php
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

require_once __DIR__ . '/../../../Models/MonUkou/Account.php';

if (!isset($_SESSION['user_obj'])) {
    $controller = $_GET['controller'] ?? '';
    if ($controller !== 'account') {
        header("Location: index.php?controller=account&action=login");
        exit;
    }
}

$heroCarouselSlides = $GLOBALS['heroCarouselSlides'] ?? [];
$avatarFile = 'pfp.png';
$avatarPath = 'uploads/accounts/' . $avatarFile;
$fallbackAvatarPath = 'uploads/accounts/pfp.png';

if (isset($_SESSION['user_obj'])) {
    $avatarFile = basename($_SESSION['user_obj']->getImg() ?: 'pfp.png');
    $avatarPath = 'uploads/accounts/' . $avatarFile;

    if (!is_file(__DIR__ . '/../../../../' . $avatarPath)) {
        $avatarPath = $fallbackAvatarPath;
    }
}
?>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= htmlspecialchars($GLOBALS['pageTitle'] ?? 'Điện ảnh & Sao', ENT_QUOTES, 'UTF-8') ?></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --navbar-offset: 80px;
            --site-bg: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }

        body {
            padding-top: var(--navbar-offset);
            background: var(--site-bg);
        }

        @media (max-width: 992px) {
            :root { --navbar-offset: 70px; }
        }

        @media (max-width: 768px) {
            :root { --navbar-offset: 65px; }
        }

        .navbar {
            z-index: 99999 !important;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            margin-bottom: 0 !important;
            border-bottom: 0 !important;
        }

        .navbar-brand {
            font-family: Georgia, serif;
        }

        .search-form .form-control {
            border-radius: 25px 0 0 25px;
            width: 300px;
        }

        .search-form .btn {
            border-radius: 0 25px 25px 0;
        }

        .user-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            object-fit: cover;
        }

        .hero-carousel-wrapper {
            margin-top: calc(-1 * var(--navbar-offset));
            line-height: 0;
        }

        .hero-carousel {
            width: 100%;
            box-shadow: 0 24px 60px rgba(0,0,0,0.28);
        }

        .hero-carousel .carousel-item {
            height: clamp(280px, 48vw, 520px);
        }

        .hero-carousel img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            filter: brightness(0.55);
        }

        .hero-carousel .carousel-caption {
            left: 8%;
            right: 8%;
            bottom: 12%;
            text-align: left;
            line-height: 1.4;
        }

        .hero-carousel .carousel-caption h2 {
            font-size: clamp(2rem, 4vw, 3.5rem);
            font-weight: 800;
            text-shadow: 0 10px 30px rgba(0,0,0,0.45);
        }

        .hero-carousel .carousel-caption p {
            max-width: 640px;
            font-size: clamp(1rem, 1.6vw, 1.2rem);
            text-shadow: 0 6px 24px rgba(0,0,0,0.45);
        }

        .hero-carousel .carousel-indicators [data-bs-target] {
            width: 12px;
            height: 12px;
            border-radius: 50%;
        }

        main {
            min-height: calc(100vh - var(--navbar-offset));
            padding: 2rem 0;
            position: relative;
            z-index: 1;
        }

        .card {
            transition: all 0.3s ease-in-out !important;
            border: none;
            border-radius: 15px !important;
            overflow: hidden;
        }

        .card:hover {
            transform: translateY(-10px) scale(1.02) !important;
            box-shadow: 0 20px 40px rgba(0,0,0,0.3) !important;
            z-index: 10;
        }

        .gradient-overlay {
            pointer-events: none;
        }

        #searchBox {
            position: absolute;
            top: calc(100% + 8px);
            left: 0;
            right: 0;
            background: #fff;
            border-radius: 16px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.2);
            max-height: 420px;
            overflow-y: auto;
            z-index: 10000;
            border: 1px solid #e8eaed;
            display: none;
        }

        .search-item:hover {
            background: linear-gradient(90deg, #f8faff 0%, #f0f7ff 100%) !important;
            border-left: 4px solid #1a73e8 !important;
            transform: translateX(4px) !important;
            box-shadow: inset 0 0 0 1px #e8f0fe !important;
        }

        .site-footer {
            background: rgba(8, 10, 20, 0.92);
            color: rgba(255,255,255,0.86);
            margin-top: 3rem;
            border-top: 1px solid rgba(255,255,255,0.08);
        }

        .site-footer h5 {
            color: #fff;
            font-weight: 700;
        }

        .site-footer a {
            color: rgba(255,255,255,0.86);
            text-decoration: none;
        }

        .site-footer a:hover {
            color: #ffc107;
        }

        .site-footer .footer-meta {
            color: rgba(255,255,255,0.6);
            font-size: 0.95rem;
        }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top">
        <div class="container">
            <a class="navbar-brand fw-bold fs-3" href="index.php">
                <i class="fas fa-film me-2 text-warning"></i>Điện ảnh & Sao
            </a>

            <ul class="navbar-nav me-auto">
                <li class="nav-item"><a class="nav-link" href="index.php">Trang chủ</a></li>
                <li class="nav-item"><a class="nav-link" href="index.php?controller=home&action=movies">Tin phim</a></li>
                <li class="nav-item"><a class="nav-link" href="index.php?controller=movie">Phim</a></li>
                <li class="nav-item"><a class="nav-link" href="index.php?controller=home&action=actors">Tin sao</a></li>
                <li class="nav-item"><a class="nav-link" href="index.php?controller=actor">Diễn viên</a></li>
            </ul>

            <form class="search-form d-flex me-3 position-relative" id="searchForm">
                <input class="form-control me-1"
                       type="search"
                       id="searchInput"
                       placeholder="Tìm phim, tin, diễn viên..."
                       autocomplete="off">
                <button class="btn btn-warning" type="submit">
                    <i class="fas fa-search"></i>
                </button>
                <div id="searchBox"></div>
            </form>

            <ul class="navbar-nav">
                <?php if (isset($_SESSION['user_obj'])): ?>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle d-flex align-items-center" href="#" role="button" data-bs-toggle="dropdown">
                            <img src="<?= htmlspecialchars($avatarPath, ENT_QUOTES, 'UTF-8') ?>" class="user-avatar me-2" alt="Avatar">
                            <span><?= htmlspecialchars($_SESSION['user_obj']->getUser(), ENT_QUOTES, 'UTF-8') ?></span>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end">
                            <li><a class="dropdown-item" href="index.php?controller=account&action=profile"><i class="fas fa-user me-2"></i>Tài khoản</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item text-danger" href="index.php?controller=account&action=logout"><i class="fas fa-sign-out-alt me-2"></i>Đăng xuất</a></li>
                        </ul>
                    </li>
                <?php else: ?>
                    <li class="nav-item">
                        <a class="nav-link" href="index.php?controller=account&action=login">
                            <i class="fas fa-sign-in-alt me-2"></i>Đăng nhập
                        </a>
                    </li>
                <?php endif; ?>
            </ul>
        </div>
    </nav>

    <?php if (!empty($heroCarouselSlides)): ?>
        <section class="hero-carousel-wrapper">
            <div id="homeHeroCarousel" class="carousel slide carousel-fade hero-carousel" data-bs-ride="carousel">
                <div class="carousel-indicators">
                    <?php foreach ($heroCarouselSlides as $index => $slide): ?>
                        <button type="button"
                                data-bs-target="#homeHeroCarousel"
                                data-bs-slide-to="<?= $index ?>"
                                class="<?= $index === 0 ? 'active' : '' ?>"
                                <?= $index === 0 ? 'aria-current="true"' : '' ?>
                                aria-label="Slide <?= $index + 1 ?>"></button>
                    <?php endforeach; ?>
                </div>
                <div class="carousel-inner">
                    <?php foreach ($heroCarouselSlides as $index => $slide): ?>
                        <div class="carousel-item <?= $index === 0 ? 'active' : '' ?>">
                            <img src="<?= htmlspecialchars($slide['image'], ENT_QUOTES, 'UTF-8') ?>" alt="<?= htmlspecialchars($slide['title'], ENT_QUOTES, 'UTF-8') ?>">
                            <div class="carousel-caption">
                                <span class="badge bg-warning text-dark rounded-pill px-3 py-2 mb-3">Điện ảnh & Sao</span>
                                <h2><?= htmlspecialchars($slide['title'], ENT_QUOTES, 'UTF-8') ?></h2>
                                <p class="mb-4"><?= htmlspecialchars($slide['text'], ENT_QUOTES, 'UTF-8') ?></p>
                                <a class="btn btn-warning btn-lg rounded-pill px-4" href="<?= htmlspecialchars($slide['link'], ENT_QUOTES, 'UTF-8') ?>">
                                    <?= htmlspecialchars($slide['button'], ENT_QUOTES, 'UTF-8') ?>
                                </a>
                            </div>
                        </div>
                    <?php endforeach; ?>
                </div>
                <button class="carousel-control-prev" type="button" data-bs-target="#homeHeroCarousel" data-bs-slide="prev">
                    <span class="carousel-control-prev-icon" aria-hidden="true"></span>
                    <span class="visually-hidden">Previous</span>
                </button>
                <button class="carousel-control-next" type="button" data-bs-target="#homeHeroCarousel" data-bs-slide="next">
                    <span class="carousel-control-next-icon" aria-hidden="true"></span>
                    <span class="visually-hidden">Next</span>
                </button>
            </div>
        </section>
    <?php endif; ?>

    <main class="container">
        <?= $content ?? '' ?>
    </main>

    <footer class="site-footer py-5">
        <div class="container">
            <div class="row g-4">
                <div class="col-md-6 col-lg-3">
                    <h5>Điện ảnh & Sao</h5>
                    <p class="mb-0">Cập nhật tin điện ảnh, diễn viên, phim mới và các chủ đề nổi bật mỗi ngày.</p>
                </div>
                <div class="col-md-6 col-lg-3">
                    <h5>Địa chỉ</h5>
                    <p class="mb-1">123 Nguyễn Văn Cừ, Quận 5</p>
                    <p class="mb-0">TP. Hồ Chí Minh, Việt Nam</p>
                </div>
                <div class="col-md-6 col-lg-3">
                    <h5>Liên lạc</h5>
                    <p class="mb-1"><a href="tel:0901234567">0901 234 567</a></p>
                    <p class="mb-0"><a href="mailto:support@dienanhvasao.vn">support@dienanhvasao.vn</a></p>
                </div>
                <div class="col-md-6 col-lg-3">
                    <h5>Hỗ trợ</h5>
                    <p class="mb-1"><a href="index.php">Trang chủ</a></p>
                    <p class="mb-1"><a href="index.php?controller=home&action=movies">Tin phim</a></p>
                    <p class="mb-0 footer-meta">Phục vụ từ 08:00 đến 22:00 mỗi ngày.</p>
                </div>
            </div>
            <div class="footer-meta mt-4 pt-3 border-top border-secondary-subtle">
                © <?= date('Y') ?> Điện ảnh & Sao. All rights reserved.
            </div>
        </div>
    </footer>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
    const input = document.getElementById('searchInput');
    const box = document.getElementById('searchBox');
    let timer = null;
    let latestSearchCache = {
        keyword: '',
        context: '',
        results: []
    };

    function getCurrentContext() {
        const params = new URLSearchParams(window.location.search);
        const controller = params.get('controller') || 'home';
        const action = params.get('action') || '';

        if (controller === 'home') {
            if (action === 'movies') return 'movies';
            if (action === 'actors') return 'actors';
            return 'home';
        }

        if (controller === 'movie') return 'movie';
        if (controller === 'actor') return 'actor';
        if (controller === 'news') return 'news';

        return 'home';
    }

    function getSearchHeader(context, keyword, count, isSubmit = false) {
        const labels = {
            home: 'Toàn trang',
            movies: 'Tin phim',
            actors: 'Tin diễn viên',
            movie: 'Phim',
            actor: 'Diễn viên',
            news: 'Tin tức'
        };
        const viewLabel = isSubmit ? 'Kết quả tìm kiếm' : 'Gợi ý';

        return `
            <div style="padding:12px 16px;background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);color:white;border-radius:10px 10px 0 0;font-size:13px;font-weight:500;">
                <i class="fas fa-search me-2"></i>${viewLabel}: "${keyword}"
                <span style="float:right;opacity:0.9;">${count} kết quả | ${labels[context] || labels.home}</span>
            </div>
        `;
    }

    function renderSearchResults(data, keyword, context, isSubmit = false) {
        latestSearchCache = {
            keyword,
            context,
            results: Array.isArray(data) ? data : []
        };

        if (!Array.isArray(data) || data.length === 0) {
            box.innerHTML = `
                <div style="padding:16px;color:#5f6368;text-align:center;font-style:italic;background:white;border-radius:16px;">
                    <i class="fas fa-search fa-2x mb-2 d-block text-muted"></i>
                    Không tìm thấy kết quả nào với "${keyword}"
                </div>
            `;
            box.style.display = 'block';
            return;
        }

        let html = getSearchHeader(context, keyword, data.length, isSubmit);

        data.forEach(item => {
            html += `
                <a href="${item.link}" class="search-item"
                   style="display:block;padding:14px 16px;border-bottom:1px solid #f1f3f4;text-decoration:none;color:#1a1a1a;transition:all 0.2s;background:white;">
                    <div style="font-weight:600;font-size:14.5px;margin-bottom:4px;line-height:1.3;">${item.title}</div>
                    <div style="color:#5f6368;font-size:13px;">${item.type}</div>
                </a>
            `;
        });

        box.innerHTML = html;
        box.style.display = 'block';
    }

    function renderSearchCards(keyword, results) {
        const grid = document.getElementById('newsGrid');
        const heading = document.getElementById('pageTitleHeading');
        const meta = document.getElementById('homeMetaText');
        const pagination = document.getElementById('homePagination');

        if (!grid || !heading) {
            return false;
        }

        const normalizedResults = Array.isArray(results) ? results : [];

        heading.textContent = `Kết quả tìm kiếm: "${keyword}"`;

        if (meta) {
            meta.innerHTML = `<i class="fas fa-list me-2"></i>Tìm thấy <strong>${normalizedResults.length}</strong> kết quả phù hợp`;
        }

        if (pagination) {
            pagination.style.display = 'none';
        }

        if (normalizedResults.length === 0) {
            grid.innerHTML = `
                <div class="col-12 text-center py-8">
                    <i class="fas fa-inbox fa-5x text-white-50 mb-4"></i>
                    <h3 class="text-white-50 mb-4">Không có tin nào</h3>
                    <p class="text-white-50 mb-4">Thử từ khóa khác: <strong>"${keyword}"</strong></p>
                    <a href="index.php" class="btn btn-outline-light btn-lg px-5 shadow-lg">
                        <i class="fas fa-home me-2"></i> Về trang chủ
                    </a>
                </div>
            `;
            return true;
        }

        grid.innerHTML = normalizedResults.map((item, index) => {
            const itemType = String(item.type || '').toLowerCase();
            let badgeClass = 'primary';
            let iconClass = 'fa-newspaper';
            let label = item.type || 'Tin tức';

            if (itemType.includes('diễn') || itemType.includes('actor')) {
                badgeClass = 'info';
                iconClass = 'fa-user';
                label = 'Diễn viên';
            } else if (itemType.includes('phim') || itemType.includes('movie')) {
                badgeClass = 'warning';
                iconClass = 'fa-film';
                label = 'Phim';
            }

            const hotBadge = index < 2 ? `
                <span class="position-absolute top-3 end-3 badge bg-danger border border-white shadow-lg px-3 py-2">
                    <i class="fas fa-fire me-1"></i>HOT
                </span>` : '';

            return `
                <div class="col-sm-6 col-lg-4">
                    <div class="card h-100 shadow-xl hover-shadow-lg border-0 overflow-hidden position-relative"
                         style="border-radius:24px;background:rgba(255,255,255,0.95);backdrop-filter:blur(20px);">
                        <div class="position-relative overflow-hidden" style="height:220px;background:linear-gradient(135deg,#1d2b64 0%,#f8cdda 100%);">
                            <div class="card-img-top h-100 d-flex align-items-center justify-content-center position-relative p-4">
                                <i class="fas ${iconClass} fa-4x text-white opacity-75 position-relative z-2"></i>
                                ${hotBadge}
                            </div>
                        </div>
                        <div class="card-body p-4 pb-3">
                            <span class="badge bg-${badgeClass} mb-2">${label}</span>
                            <h5 class="card-title mb-3 lh-sm">
                                <a href="${item.link}"
                                   class="text-decoration-none text-dark fw-bold hover-primary fs-5">
                                    ${item.title}
                                </a>
                            </h5>
                            <p class="card-text text-muted small lh-lg mb-3 flex-grow-1">Kết quả phù hợp với từ khóa tìm kiếm trong nhóm ${label.toLowerCase()}.</p>
                            <div class="d-flex justify-content-between align-items-end small text-muted">
                                <span><i class="fas fa-tag me-1"></i>${item.type || label}</span>
                                <a href="${item.link}" class="text-decoration-none fw-semibold text-primary">
                                    Xem chi tiết <i class="fas fa-arrow-right ms-1"></i>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            `;
        }).join('');

        return true;
    }

    async function fetchSearchResults(keyword, options = {}) {
        const context = getCurrentContext();
        const limit = options.limit || 10;
        const response = await fetch(`?controller=search&action=ajax&keyword=${encodeURIComponent(keyword)}&context=${context}&limit=${limit}`);

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}`);
        }

        const data = await response.json();
        renderSearchResults(data, keyword, context, !!options.isSubmit);
        return data;
    }

    input?.addEventListener('input', function () {
        clearTimeout(timer);
        const keyword = this.value.trim();

        if (keyword.length < 2) {
            box.style.display = 'none';
            return;
        }

        timer = setTimeout(async () => {
            try {
                await fetchSearchResults(keyword, { limit: 8 });
            } catch (error) {
                box.innerHTML = `
                    <div style="padding:14px;color:#d93025;background:#fce8e6;border-radius:10px;">
                        <i class="fas fa-exclamation-circle me-2"></i>Lỗi tìm kiếm! Vui lòng thử lại.
                    </div>
                `;
                box.style.display = 'block';
            }
        }, 300);
    });

    document.getElementById('searchForm')?.addEventListener('submit', async e => {
        e.preventDefault();
        const keyword = input?.value.trim() || '';
        const context = getCurrentContext();

        if (keyword.length < 2) {
            box.innerHTML = `
                <div style="padding:14px;color:#d93025;background:#fce8e6;border-radius:10px;">
                    <i class="fas fa-exclamation-circle me-2"></i>Nhập ít nhất 2 ký tự để tìm kiếm.
                </div>
            `;
            box.style.display = 'block';
            return;
        }

        const routes = {
            home: `index.php?controller=home&keyword=${encodeURIComponent(keyword)}`,
            movies: `index.php?controller=home&action=movies&keyword=${encodeURIComponent(keyword)}`,
            actors: `index.php?controller=home&action=actors&keyword=${encodeURIComponent(keyword)}`,
            movie: `index.php?controller=movie&keyword=${encodeURIComponent(keyword)}`,
            actor: `index.php?controller=actor&keyword=${encodeURIComponent(keyword)}`,
            news: `index.php?controller=news&keyword=${encodeURIComponent(keyword)}`
        };

        window.location.href = routes[context] || routes.home;
    });

    document.addEventListener('click', e => {
        if (input && !input.closest('form').contains(e.target)) {
            box.style.display = 'none';
        }
    });
    </script>
</body>
</html>
