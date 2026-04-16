<?php
$actors = $GLOBALS['actors'] ?? [];
$currentPage = $GLOBALS['currentPage'] ?? 1;
$totalPages = $GLOBALS['totalPages'] ?? 1;
$pageTitle = $GLOBALS['pageTitle'] ?? 'Danh sách diễn viên';
$totalActors = $GLOBALS['totalActors'] ?? count($actors);
$searchKeyword = $GLOBALS['searchKeyword'] ?? '';
?>
<div class="row mb-4">
    <div class="col-12">
        <h2 class="text-white mb-4 text-center">
            <i class="fas fa-users me-2"></i>
            <?php if ($searchKeyword !== ''): ?>
                Kết quả diễn viên: "<?= htmlspecialchars($searchKeyword) ?>"
            <?php else: ?>
                <?= $pageTitle ?>
            <?php endif; ?>
        </h2>
        <p class="text-center text-white-50"><?= number_format($totalActors) ?> diễn viên</p>
    </div>
</div>

<div class="row g-4">
    <?php if (!empty($actors)): ?>
        <?php foreach ($actors as $actor): ?>
        <div class="col-lg-4 col-md-6 col-sm-12">
            <div class="card h-100 hover-shadow">
                <div class="card-img-top position-relative overflow-hidden" style="height: 300px;">
                    <img src="uploads/actors/<?= htmlspecialchars($actor->Actor_Img ?? 'default-avatar.png') ?>"
                         class="card-img-top w-100 h-100 object-fit-cover"
                         alt="<?= htmlspecialchars($actor->Actor_Name ?? 'Dien vien') ?>"
                         onerror="this.src='https://via.placeholder.com/300x300/764ba2/ffffff?text=Dien+vien'">
                    <div class="position-absolute bottom-0 start-0 bg-primary bg-opacity-90 text-white p-2">
                        <i class="fas fa-star me-1"></i><?= $actor->Actor_Rating ?? 'N/A' ?>
                    </div>
                </div>
                <div class="card-body d-flex flex-column">
                    <h5 class="card-title">
                        <a href="index.php?controller=actor&action=detail&id=<?= $actor->Actor_ID ?>"
                           class="text-decoration-none fw-bold text-dark">
                            <?= htmlspecialchars($actor->Actor_Name ?? 'N/A') ?>
                        </a>
                    </h5>
                    <p class="card-text text-muted flex-grow-1">
                        <?= substr(htmlspecialchars($actor->Actor_Info ?? ''), 0, 100) ?>...
                    </p>
                    <p class="text-success fw-bold mb-2">
                        <i class="fas fa-film me-1"></i>
                        <?= $actor->movie_count ?> phim
                    </p>
                    <a href="index.php?controller=actor&action=detail&id=<?= $actor->Actor_ID ?>"
                       class="btn btn-primary w-100 mt-auto">
                        <i class="fas fa-eye me-2"></i>Xem tiểu sử
                    </a>
                </div>
            </div>
        </div>
        <?php endforeach; ?>
    <?php else: ?>
        <div class="col-12">
            <div class="text-center py-5">
                <i class="fas fa-users-slash fa-3x text-muted mb-3"></i>
                <h4 class="text-muted">Chưa có diễn viên nào</h4>
            </div>
        </div>
    <?php endif; ?>
</div>

<?php if ($totalPages > 1): ?>
<div class="row mt-5">
    <div class="col-12">
        <nav aria-label="Danh sách diễn viên">
            <ul class="pagination justify-content-center">
                <?php
                $baseUrl = '?controller=actor';
                if ($searchKeyword !== '') {
                    $baseUrl .= '&keyword=' . urlencode($searchKeyword);
                }
                ?>

                <?php if ($currentPage > 1): ?>
                <li class="page-item">
                    <a class="page-link" href="<?= $baseUrl ?>&page=<?= $currentPage - 1 ?>">
                        <i class="fas fa-chevron-left"></i>
                    </a>
                </li>
                <?php endif; ?>

                <?php
                $startPage = max(1, $currentPage - 2);
                $endPage = min($totalPages, $currentPage + 2);
                ?>
                <?php if ($startPage > 1): ?>
                    <li class="page-item"><a class="page-link" href="<?= $baseUrl ?>&page=1">1</a></li>
                    <?php if ($startPage > 2): ?>
                        <li class="page-item disabled"><span class="page-link">...</span></li>
                    <?php endif; ?>
                <?php endif; ?>

                <?php for ($i = $startPage; $i <= $endPage; $i++): ?>
                    <li class="page-item <?= $i === $currentPage ? 'active' : '' ?>">
                        <a class="page-link" href="<?= $baseUrl ?>&page=<?= $i ?>"><?= $i ?></a>
                    </li>
                <?php endfor; ?>

                <?php if ($endPage < $totalPages): ?>
                    <?php if ($endPage < $totalPages - 1): ?>
                        <li class="page-item disabled"><span class="page-link">...</span></li>
                    <?php endif; ?>
                    <li class="page-item"><a class="page-link" href="<?= $baseUrl ?>&page=<?= $totalPages ?>"><?= $totalPages ?></a></li>
                <?php endif; ?>

                <?php if ($currentPage < $totalPages): ?>
                <li class="page-item">
                    <a class="page-link" href="<?= $baseUrl ?>&page=<?= $currentPage + 1 ?>">
                        <i class="fas fa-chevron-right"></i>
                    </a>
                </li>
                <?php endif; ?>
            </ul>
        </nav>
    </div>
</div>
<?php endif; ?>
