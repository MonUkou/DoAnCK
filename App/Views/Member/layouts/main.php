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
?>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Điện ảnh & Sao</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        :root {
            --navbar-offset: 80px;
        }
        .navbar-brand { font-family: 'Georgia', serif; }
        .search-form .form-control {
            border-radius: 25px 0 0 25px;
            width: 300px;
        }
        .search-form .btn { border-radius: 0 25px 25px 0; }
        .user-avatar { width: 40px; height: 40px; border-radius: 50%; }
       
        body { padding-top: var(--navbar-offset); }
        @media (max-width: 992px) {
            :root { --navbar-offset: 70px; }
            body { padding-bottom: 0px; }
        }
        @media (max-width: 768px) {
            :root { --navbar-offset: 65px; }
            body { padding-bottom: 0px; }
        }
       
        /* Content chính */
        main {
            min-height: calc(100vh - 80px);
            padding: 2rem 0;
        }
        .hero-carousel-wrapper {
            padding-top: 0;
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
       
        .news-title {
            margin-top: 1rem !important;
            padding-top: 1rem !important;
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
  
    .card-img-top:hover {
        transform: scale(1.1);
        transition: transform 0.3s ease;
    }
  
    .card-title a:hover {
        color: #667eea !important;
        text-decoration: none;
    }
   
    .hover-shadow {
        transition: all 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94);
    }
   
    /* Responsive */
    @media (max-width: 768px) {
        .card:hover {
            transform: translateY(-5px) scale(1.01) !important;
        }
    }
.navbar {
    z-index: 99999 !important;
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    margin-bottom: 0 !important;
    border-bottom: none !important;
}

main {
    position: relative;
    z-index: 1;
}


.gradient-overlay {
    pointer-events: none;
}
nav.navbar {
    z-index: 999999 !important;
}
    </style>
</head>
<body style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
   
    <!-- NAVBAR -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top">
        <div class="container">
            <a class="navbar-brand fw-bold fs-3" href="index.php">
                <i class="fas fa-film me-2 text-warning"></i>Điện ảnh & Sao
            </a>
           
              <ul class="navbar-nav me-auto">
                            <li class="nav-item">
                <a class="nav-link" href="index.php">
                    Trang chủ
                </a>
            </li>

            <li class="nav-item">
                <a class="nav-link" href="index.php?controller=home&action=movies">
                    Tin phim
                </a>
            </li>

            <li class="nav-item">
                <a class="nav-link" href="index.php?controller=movie">
                    Phim
                </a>
            </li>

            <li class="nav-item">
                <a class="nav-link" href="index.php?controller=home&action=actors">
                    Tin sao
                </a>
            </li>

            <li class="nav-item">
                <a class="nav-link" href="index.php?controller=actor">
                    Diễn viên
                </a>
            </li>
            </ul>

            <!-- Search Form -->
            <form class="search-form d-flex me-3 position-relative" id="searchForm">
                <input class="form-control me-1"
                    type="search"
                    id="searchInput"
                    placeholder="Tìm phim, tin, diễn viên..."
                    autocomplete="off">

                <button class="btn btn-warning" type="submit">
                    <i class="fas fa-search"></i>
                </button>

                <div id="searchBox"
                    style="position:absolute; top:100%; left:0; right:0; background:white; z-index:9999; display:none; border-radius:10px;">
                </div>
            </form>

            <!-- User Menu -->
            <ul class="navbar-nav">
                <?php if (isset($_SESSION['user_obj'])): ?>
                    <?php
                        $avatarFile = basename($_SESSION['user_obj']->getImg() ?: 'default-avatar.png');
                        $avatarPath = 'uploads/accounts/' . $avatarFile;
                        $fallbackAvatarPath = 'uploads/accounts/default-avatar.png';

                        if (!is_file(__DIR__ . '/../../../../' . $fallbackAvatarPath)) {
                            $fallbackAvatarPath = 'uploads/accounts/image.png';
                        }

                        if (!is_file(__DIR__ . '/../../../../' . $avatarPath)) {
                            $avatarPath = $fallbackAvatarPath;
                        }
                    ?>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle d-flex align-items-center" href="#"
                           role="button" data-bs-toggle="dropdown">
                            <img src="<?= htmlspecialchars($avatarPath, ENT_QUOTES, 'UTF-8') ?>"
                                 class="user-avatar me-2" alt="Avatar">
                            <span><?= $_SESSION['user_obj']->getUser() ?></span>
                        </a>
                        <ul class="dropdown-menu dropdown-menu-end">
                            <li><a class="dropdown-item" href="index.php?controller=account&action=profile">
                                <i class="fas fa-user me-2"></i>Tài khoản
                            </a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item text-danger" href="index.php?controller=account&action=logout">
                                <i class="fas fa-sign-out-alt me-2"></i>Đăng xuất
                            </a></li>
                        </ul>
                    </li>
                <?php else: ?>
                    <li class="nav-item">
                        <a class="nav-link" href="index.php?controller=account&action=login">
                            <i class="fas fa-sign-in-alt me-2"></i>Đăng nhập
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link btn btn-outline-light ms-2" href="index.php?controller=account&action=register">
                            Đăng ký
                        </a>
                    </li>
                <?php endif; ?>
            </ul>
        </div>
    </nav>

    <?php $heroCarouselSlides = $GLOBALS['heroCarouselSlides'] ?? []; ?>
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
                        <img src="<?= htmlspecialchars($slide['image'], ENT_QUOTES, 'UTF-8') ?>"
                             alt="<?= htmlspecialchars($slide['title'], ENT_QUOTES, 'UTF-8') ?>">
                        <div class="carousel-caption">
                            <span class="badge bg-warning text-dark rounded-pill px-3 py-2 mb-3">Điện ảnh & Sao</span>
                            <h2><?= htmlspecialchars($slide['title'], ENT_QUOTES, 'UTF-8') ?></h2>
                            <p class="mb-4"><?= htmlspecialchars($slide['text'], ENT_QUOTES, 'UTF-8') ?></p>
                            <a class="btn btn-warning btn-lg rounded-pill px-4"
                               href="<?= htmlspecialchars($slide['link'], ENT_QUOTES, 'UTF-8') ?>">
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


    <!-- MAIN CONTENT  -->
    <main class="container">
        <?= $content ?? '' ?>
    </main>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
            <script>
            $(document).ready(function() {
                // Fix Search Form Submit
                $('#searchForm').submit(function(e) {
                    e.preventDefault();
                    let keyword = $('#searchInput').val().trim();
                    if (keyword) {
                        window.location.href = `index.php?controller=search&keyword=${encodeURIComponent(keyword)}`;
                    }
                    return false;
                });
            });
            </script>
   
</body>
</html>
<script>
const input = document.getElementById("searchInput");
const box = document.getElementById("searchBox");
let timer = null;

input.addEventListener("input", function () {
    clearTimeout(timer);
    const keyword = this.value.trim();

    if (keyword.length < 2) {
        box.style.display = "none";
        return;
    }


    timer = setTimeout(() => {
        const context = getCurrentContext();
       
        fetch(`?controller=search&action=ajax&keyword=${encodeURIComponent(keyword)}&context=${context}`)
        .then(res => {
            if (!res.ok) throw new Error(`HTTP ${res.status}`);
            return res.json();
        })
        .then(data => {
            console.log("✅ Search:", data.length, "items | Context:", context);
           
            const contextLabel = getContextLabel(context, keyword);
           
            if (!data || data.length === 0) {
                box.innerHTML = contextLabel.noResult;
                box.style.display = "block";
                return;
            }

            let html = contextLabel.header(data.length);
           
            data.forEach(item => {
                html += `
                    <a href="${item.link}" class="search-item"
                       style="display:block;padding:14px 16px;border-bottom:1px solid #f1f3f4;
                              text-decoration:none;color:#1a1a1a;transition:all 0.2s;">
                        <div style="font-weight:600;font-size:14.5px;margin-bottom:4px;line-height:1.3;">
                            ${item.title}
                        </div>
                        <div style="color:#5f6368;font-size:13px;">
                            ${item.type}
                        </div>
                    </a>
                `;
            });

            box.innerHTML = html;
            box.style.display = "block";
        })
        .catch(error => {
            console.error("❌ Search error:", error);
            box.innerHTML = `
                <div style="padding:14px;color:#d93025;background:#fce8e6;border-radius:10px;">
                    <i class="fas fa-exclamation-circle me-2"></i>
                    Lỗi tìm kiếm! Vui lòng thử lại.
                </div>
            `;
            box.style.display = "block";
        });
    }, 300);
});

document.addEventListener("click", e => {
    if (!input.closest("form").contains(e.target)) {
        box.style.display = "none";
    }
});

function getCurrentContext() {
    const params = new URLSearchParams(window.location.search);
    const controller = params.get("controller") || 'home';
    const action = params.get("action") || '';

    if (controller === 'home') {
        if (action === 'movies') return 'movies';     // TIN PHIM
        if (action === 'actors') return 'actors';     // TIN SAO
        return 'home';                               // TRANG CHỦ
    }
   
    return controller; 
   
    if (controller === 'movie') return 'movie';
    if (controller === 'actor') return 'actor';
    if (controller === 'news') return 'news';
   
    return 'home';}

function getContextLabel(context, keyword) {
    const labels = {
        'home': {
            noResult: `<div style="padding:16px;color:#5f6368;text-align:center;font-style:italic;">
                <i class="fas fa-search fa-2x mb-2 d-block text-muted"></i>
                Không tìm thấy "${keyword}" trên trang chủ
            </div>`,
            header: count => `<div style="padding:12px 16px;background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);
                color:white;border-radius:10px 10px 0 0;font-size:13px;font-weight:500;">
                <i class="fas fa-search me-2"></i>
                Tìm "${keyword}" trên trang chủ
                <span style="float:right;opacity:0.9;">${count} kết quả</span>
            </div>`
        },
        'movies': {
            noResult: `<div style="padding:16px;color:#5f6368;text-align:center;font-style:italic;">
                Không tìm thấy phim nào có "${keyword}"
            </div>`,
            header: count => `<div style="padding:12px 16px;background:#e3f2fd;color:#1976d2;border-radius:10px 10px 0 0;font-size:13px;font-weight:500;">
                <i class="fas fa-film me-2"></i>Tin phim (${count} kết quả)
            </div>`
        },
        'actors': {
            noResult: `<div style="padding:16px;color:#5f6368;text-align:center;font-style:italic;">
                Không tìm thấy diễn viên nào có "${keyword}"
            </div>`,
            header: count => `<div style="padding:12px 16px;background:#f3e5f5;color:#7b1fa2;border-radius:10px 10px 0 0;font-size:13px;font-weight:500;">
                <i class="fas fa-user me-2"></i>Tin diễn viên (${count} kết quả)
            </div>`
        },
        'movie': {
            noResult: `<div style="padding:16px;color:#5f6368;text-align:center;">Không tìm thấy phim</div>`,
            header: count => `<div style="padding:12px 16px;background:#e8f5e8;color:#2e7d32;border-radius:10px 10px 0 0;font-size:13px;">Phim (${count})</div>`
        },
        'actor': {
            noResult: `<div style="padding:16px;color:#5f6368;text-align:center;">Không tìm thấy diễn viên</div>`,
            header: count => `<div style="padding:12px 16px;background:#fff3e0;color:#f57c00;border-radius:10px 10px 0 0;font-size:13px;">Diễn viên (${count})</div>`
        }
    };
   
    return labels[context] || labels['home'];
}

const style = document.createElement('style');
style.textContent = `
#searchBox {
    position: absolute !important; top: calc(100% + 8px); left: 0; right: 0;
    background: white; border-radius: 16px; box-shadow: 0 20px 60px rgba(0,0,0,0.2);
    max-height: 420px; overflow-y: auto; z-index: 10000; border: 1px solid #e8eaed;
    backdrop-filter: blur(10px);
}
.search-item:hover {
    background: linear-gradient(90deg, #f8faff 0%, #f0f7ff 100%) !important;
    border-left: 4px solid #1a73e8 !important;
    transform: translateX(4px) !important;
    box-shadow: inset 0 0 0 1px #e8f0fe !important;
}
#searchBox::-webkit-scrollbar { width: 6px; }
#searchBox::-webkit-scrollbar-track { background: #f1f3f4; border-radius: 10px; }
#searchBox::-webkit-scrollbar-thumb { background: #bdc1c6; border-radius: 10px; }
`;
document.head.appendChild(style);

document.addEventListener('DOMContentLoaded', () => {
    document.getElementById('searchForm').addEventListener('submit', e => {
        e.preventDefault();
        const keyword = input.value.trim();
        if (keyword) window.location.href = `?controller=search&keyword=${encodeURIComponent(keyword)}`;
    });
});
</script>
