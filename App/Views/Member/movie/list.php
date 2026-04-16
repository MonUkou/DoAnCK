<?php
$movies = $GLOBALS['movies'] ?? [];
$totalPages = $GLOBALS['totalPages'] ?? 1;
$currentPage = $GLOBALS['currentPage'] ?? 1;
$totalMovies = $GLOBALS['totalMovies'] ?? 0;
$searchKeyword = $GLOBALS['searchKeyword'] ?? '';
?>

<div class="text-center mb-5 pb-4">
    <h2 class="mb-4 text-white fw-bold fs-1 lh-1">
        <?php if ($searchKeyword !== ''): ?>
            Ket qua phim: "<?= htmlspecialchars($searchKeyword) ?>"
        <?php else: ?>
            <?= $GLOBALS['pageTitle'] ?? 'Danh sach phim' ?>
        <?php endif; ?>
        <span class="badge bg-warning text-dark fs-6 ms-4 px-4 py-2 shadow-sm">
            <?= number_format($totalMovies) ?> phim
        </span>
    </h2>

    <?php if ($totalPages > 1): ?>
    <div class="text-white-50 fs-5">
        Trang <strong><?= $currentPage ?></strong> / <strong><?= $totalPages ?></strong>
        (<?= number_format($totalMovies) ?> phim)
    </div>
    <?php endif; ?>
</div>

<div class="row g-4 mb-5">
    <?php if (empty($movies)): ?>
    <div class="col-12 text-center py-8">
        <i class="fas fa-video fa-5x text-white-50 mb-4"></i>
        <h3 class="text-white-50 mb-4">Chưa có phim nào</h3>
        <a href="index.php" class="btn btn-outline-light btn-lg px-5 shadow-lg">
            <i class="fas fa-home me-2"></i> Về trang chủ
        </a>
    </div>
    <?php else: ?>
        <?php foreach ($movies as $index => $movie): ?>
        <div class="col-sm-6 col-lg-4">
            <div class="card h-100 shadow-xl hover-shadow-lg border-0 overflow-hidden position-relative movie-card"
                 style="border-radius: 24px; background: rgba(255,255,255,0.95); backdrop-filter: blur(20px);">

                <div class="position-relative overflow-hidden" style="height: 280px;">
                    <div class="gradient-overlay"></div>
                    <?php if ($movie['Movie_Img']): ?>
                        <img src="uploads/movies/<?= htmlspecialchars($movie['Movie_Img']) ?>"
                             class="card-img-top h-100 w-100 object-fit-cover" alt="<?= htmlspecialchars($movie['Movie_Title']) ?>">
                    <?php else: ?>
                        <div class="card-img-top h-100 d-flex align-items-center justify-content-center position-relative p-4">
                            <i class="fas fa-film fa-4x text-white opacity-75 position-relative z-2"></i>
                        </div>
                    <?php endif; ?>

                    <?php if ($index < 3): ?>
                    <span class="position-absolute top-3 end-3 badge bg-danger border border-white shadow-lg px-3 py-2">
                        <i class="fas fa-fire me-1"></i>NEW
                    </span>
                    <?php endif; ?>
                </div>

                <div class="card-body p-4 pb-3">
                    <div class="d-flex justify-content-between align-items-start mb-3">
                        <span class="badge bg-primary fs-6 px-3 py-2">
                            <i class="fas fa-calendar-day me-1"></i>
                            <?= $movie['Movie_ReleaseDate'] ? date('d/m/Y', strtotime($movie['Movie_ReleaseDate'])) : 'Chua cong chieu' ?>
                        </span>
                        <?php if (!empty($movie['Username'])): ?>
                        <small class="text-muted">
                            <i class="fas fa-user me-1"></i><?= htmlspecialchars($movie['Username']) ?>
                        </small>
                        <?php endif; ?>
                    </div>

                    <h5 class="card-title mb-3 lh-sm">
                        <a href="index.php?controller=movie&action=showDetail&id=<?= $movie['Movie_ID'] ?>"
                           class="text-decoration-none text-dark fw-bold hover-primary fs-5 line-clamp-2">
                            <?= htmlspecialchars($movie['Movie_Title']) ?>
                        </a>
                    </h5>

                    <p class="card-text text-muted small lh-lg mb-3 flex-grow-1 line-clamp-3">
                        <?= htmlspecialchars($movie['Movie_Description'] ?: 'Khong co mo ta') ?>
                    </p>

                    <div class="d-flex justify-content-between align-items-end">
                        <?php if (!empty($movie['Movie_StreamingDate'])): ?>
                        <span class="badge bg-success">
                            <i class="fas fa-play-circle me-1"></i>
                            <?= date('d/m/Y', strtotime($movie['Movie_StreamingDate'])) ?>
                        </span>
                        <?php endif; ?>

                        <a href="index.php?controller=movie&action=detail&id=<?= $movie['Movie_ID'] ?>"
                           class="btn btn-outline-primary btn-sm px-4">
                            <i class="fas fa-eye me-1"></i>Xem chi tiết
                        </a>
                    </div>
                </div>
            </div>
        </div>
        <?php endforeach; ?>
    <?php endif; ?>
</div>

<?php if ($totalPages > 1): ?>
<div class="row justify-content-center mb-5">
    <nav aria-label="Phan trang phim">
        <ul class="pagination pagination-lg shadow-xl bg-white rounded-pill p-2 mx-auto" style="max-width: 600px;">
            <?php
            $baseUrl = '?controller=movie';
            if ($searchKeyword !== '') {
                $baseUrl .= '&keyword=' . urlencode($searchKeyword);
            }
            ?>

            <?php if ($currentPage > 1): ?>
            <li class="page-item pe-1">
                <a class="page-link rounded-4 shadow-sm border-0 px-4 py-3 text-primary fw-bold"
                   href="<?= $baseUrl ?>&page=<?= $currentPage - 1 ?>">
                    <i class="fas fa-chevron-left me-2"></i>Trước
                </a>
            </li>
            <?php endif; ?>

            <?php
            $start = max(1, $currentPage - 2);
            $end = min($totalPages, $currentPage + 2);
            ?>

            <?php if ($start > 1): ?>
            <li class="page-item px-1">
                <a class="page-link rounded-3 shadow-sm border-0 px-3 py-3" href="<?= $baseUrl ?>&page=1">1</a>
            </li>
            <?php if ($start > 2): ?>
            <li class="page-item px-1"><span class="page-link px-3 py-3">...</span></li>
            <?php endif; ?>
            <?php endif; ?>

            <?php for ($i = $start; $i <= $end; $i++): ?>
            <li class="page-item px-1 <?= $i == $currentPage ? 'active' : '' ?>">
                <a class="page-link rounded-3 shadow-sm border-0 px-4 py-3 fw-bold <?= $i == $currentPage ? 'bg-gradient-primary text-white shadow-lg' : 'text-primary hover-primary' ?>"
                   href="<?= $baseUrl ?>&page=<?= $i ?>"><?= $i ?></a>
            </li>
            <?php endfor; ?>

            <?php if ($end < $totalPages): ?>
            <?php if ($end < $totalPages - 1): ?>
            <li class="page-item px-1"><span class="page-link px-3 py-3">...</span></li>
            <?php endif; ?>
            <li class="page-item ps-1">
                <a class="page-link rounded-3 shadow-sm border-0 px-3 py-3" href="<?= $baseUrl ?>&page=<?= $totalPages ?>"><?= $totalPages ?></a>
            </li>
            <?php endif; ?>

            <?php if ($currentPage < $totalPages): ?>
            <li class="page-item ps-1">
                <a class="page-link rounded-4 shadow-sm border-0 px-4 py-3 text-primary fw-bold"
                   href="<?= $baseUrl ?>&page=<?= $currentPage + 1 ?>">
                    Sau<i class="fas fa-chevron-right ms-2"></i>
                </a>
            </li>
            <?php endif; ?>
        </ul>
    </nav>
</div>
<?php endif; ?>

<style>
.line-clamp-2 { display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
.line-clamp-3 { display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden; }
.movie-card:hover { transform: translateY(-15px) scale(1.03) !important; }
</style>
