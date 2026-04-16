<?php 
$title = isset($GLOBALS['searchKeyword']) ? 
    "Kết quả tìm kiếm: \"{$GLOBALS['searchKeyword']}\"" : 
    ($GLOBALS['pageTitle'] ?? "Tin tức mới nhất");

$categoryFilter = $GLOBALS['categoryFilter'] ?? '';
$newsList = $GLOBALS['newsList'] ?? [];
$totalPages = $GLOBALS['totalPages'] ?? 1;
$pageNum = $GLOBALS['pageNum'] ?? 1;
$totalNews = isset($GLOBALS['totalNews']) ? $GLOBALS['totalNews'] : (count($newsList) * $totalPages);
$searchKeyword = $GLOBALS['searchKeyword'] ?? '';
$GLOBALS['heroCarouselSlides'] = [
    [
        'title' => 'Tin phim mới mỗi ngày',
        'text' => 'Cập nhật nhanh những phim được quan tâm cùng bài viết nổi bật.',
        'image' => 'https://images.unsplash.com/photo-1489599849927-2ee91cede3ba?auto=format&fit=crop&w=1400&q=80',
        'link' => 'index.php?controller=home&action=movies',
        'button' => 'Xem tin phim',
    ],
    [
        'title' => 'Diễn viên và hậu trường',
        'text' => 'Theo dõi câu chuyện nghề nghiệp, sự kiện và nhân vật nổi bật được chú ý',
        'image' => 'https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?auto=format&fit=crop&w=1400&q=80',
        'link' => 'index.php?controller=home&action=actors',
        'button' => 'Khám phá tin sao',
    ],
    [
        'title' => 'Không gian đành cho người yêu điện ảnh',
        'text' => 'Tìm tin tức phim, nhân vật và sự kiện ở một nói giao diện dễ dàng hơn.',
        'image' => 'https://images.unsplash.com/photo-1513106580091-1d82408b8cd6?auto=format&fit=crop&w=1400&q=80',
        'link' => 'index.php?controller=movie',
        'button' => 'Xem danh sách phim',
    ],
];
?>

<div class="text-center mb-5 pb-4" id="homeTitleBlock">
    <h2 class="mb-4 text-white fw-bold fs-1 lh-1 news-title" id="pageTitleHeading">
        <?php if (isset($GLOBALS['searchKeyword'])): ?>
            <?= $title ?>
        <?php elseif ($categoryFilter): ?>
            <?= $title ?> 
            <span class="badge bg-warning text-dark fs-6 ms-4 px-4 py-2 shadow-sm border border-white">
                <i class="fas fa-film me-1"></i><?= $categoryFilter ?>
            </span>
        <?php else: ?>
            <?= $title ?>
        <?php endif; ?>
    </h2>
    
    <?php if ($totalPages > 1): ?>
    <div class="text-white-50 fs-5" id="homeMetaText">
        <i class="fas fa-list me-2"></i>
        Trang <strong><?= $pageNum ?></strong> / <strong><?= $totalPages ?></strong> 
        <?php if (isset($totalNews)): ?>
        (<?= number_format($totalNews) ?> tin tổng)
        <?php endif; ?>
    </div>
    <?php endif; ?>
</div>

<div class="row g-4 mb-5" id="newsGrid">
    <?php if (empty($newsList)): ?>
    <div class="col-12 text-center py-8">
        <i class="fas fa-inbox fa-5x text-white-50 mb-4"></i>
        <h3 class="text-white-50 mb-4">Không có tin nào</h3>
        <?php if (isset($GLOBALS['searchKeyword'])): ?>
        <p class="text-white-50 mb-4">Thử từ khóa khác: <strong>"<?= htmlspecialchars($GLOBALS['searchKeyword']) ?>"</strong></p>
        <?php endif; ?>
        <a href="index.php" class="btn btn-outline-light btn-lg px-5 shadow-lg">
            <i class="fas fa-home me-2"></i> Về trang chủ
        </a>
    </div>
    <?php else: ?>
        <?php foreach ($newsList as $index => $news): ?>
        <div class="col-sm-6 col-lg-4">
            <div class="card h-100 shadow-xl hover-shadow-lg border-0 overflow-hidden position-relative" 
                 style="border-radius: 24px; background: rgba(255,255,255,0.95); backdrop-filter: blur(20px);">
                
                <div class="position-relative overflow-hidden" style="height: 240px;">
                    <div class="gradient-overlay"></div>
                    <div class="card-img-top h-100 d-flex align-items-center justify-content-center position-relative p-4">
                        <?php if (!empty($news['New_Img'])): ?>
                        <img src="uploads/news/<?= htmlspecialchars($news['New_Img']) ?>" 
                        class="w-100 h-100 object-fit-cover position-absolute top-0 start-0"
                        alt="<?= htmlspecialchars($news['New_Title']) ?>">
                        <?php else: ?>
                            <i class="fas fa-film fa-4x text-white opacity-75 position-relative z-2"></i>
                        <?php endif; ?>

                        <?php if ($index < 2): ?>
                        <span class="position-absolute top-3 end-3 badge bg-danger border border-white shadow-lg px-3 py-2">
                            <i class="fas fa-fire me-1"></i>HOT
                        </span>
                        <?php endif; ?>
                    </div>
                </div>

                <div class="card-body p-4 pb-3">
                    <span class="badge bg-<?= $news['New_Category'] === 'Actor' ? 'info' : 'warning' ?> mb-2">
                        <?= $news['category_label'] ?? ($news['New_Category'] === 'Actor' ? '👥 Diễn viên' : '🎬 Phim ảnh') ?>
                    </span>
                    <p class="mb-3"><?= $news['short_desc'] ?? $news['short_content'] ?? '...' ?></p>

                    <h5 class="card-title mb-3 lh-sm">
                        <a href="index.php?controller=news&action=showDetail&id=<?= $news['New_ID'] ?>" 
                        class="text-decoration-none text-dark fw-bold hover-primary fs-5">
                            <?= htmlspecialchars($news['New_Title']) ?>
                        </a>
                    </h5>
                    
                    <p class="card-text text-muted small lh-lg mb-3 flex-grow-1"><?= $news['short_content'] ?? '...' ?></p>
                    <div class="d-flex justify-content-between align-items-end small text-muted">
                        <span><i class="fas fa-clock me-1"></i><?= date('d/m/Y', strtotime($news['New_PublishDate'])) ?></span>
                        <?php if (isset($news['Username'])): ?>
                        <span class="fw-semibold text-primary"><i class="fas fa-user me-1"></i><?= htmlspecialchars($news['Username']) ?></span>
                        <?php endif; ?>
                    </div>
                </div>
            </div>
        </div>
        <?php endforeach; ?>
    <?php endif; ?>
</div>

<?php if ($totalPages > 1): ?>
<div class="row justify-content-center mb-5" id="homePagination">
    <nav aria-label="Phân trang tin tức">
        <ul class="pagination pagination-lg shadow-xl bg-white rounded-pill p-2 mx-auto" 
            style="max-width: 600px; box-shadow: 0 20px 40px rgba(0,0,0,0.15) !important;">
            
            <?php 
            $currentAction = $_GET['action'] ?? 'index';
            $baseUrl = "?controller=home&action=$currentAction";
            if ($searchKeyword !== '') {
                $baseUrl .= '&keyword=' . urlencode($searchKeyword);
            }
            ?>
            
            <?php if ($pageNum > 1): ?>
            <li class="page-item pe-1">
                <a class="page-link rounded-4 shadow-sm border-0 px-4 py-3 text-primary fw-bold" 
                   href="<?= $baseUrl ?>&page=<?= max(1, $pageNum-1) ?>"
                   style="min-width: 80px;">
                    <i class="fas fa-chevron-left me-2"></i>Trước
                </a>
            </li>
            <?php endif; ?>

            <?php 
            $start = max(1, $pageNum - 2);
            $end = min($totalPages, $pageNum + 2);
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
            <li class="page-item px-1 <?= $i == $pageNum ? 'active' : '' ?>">
                <a class="page-link rounded-3 shadow-sm border-0 px-4 py-3 fw-bold <?= $i == $pageNum ? 'bg-gradient-primary text-white shadow-lg' : 'text-primary hover-primary' ?>" 
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

            <!-- Next -->
            <?php if ($pageNum < $totalPages): ?>
            <li class="page-item ps-1">
                <a class="page-link rounded-4 shadow-sm border-0 px-4 py-3 text-primary fw-bold" 
                   href="<?= $baseUrl ?>&page=<?= min($totalPages, $pageNum+1) ?>"
                   style="min-width: 80px;">
                    Sau<i class="fas fa-chevron-right ms-2"></i>
                </a>
            </li>
            <?php endif; ?>
        </ul>
    </nav>
</div>
<?php endif; ?>

<style>
:root { --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
.bg-gradient-primary { background: var(--primary-gradient) !important; }
.hover-primary:hover { color: #667eea !important; text-shadow: 0 2px 4px rgba(102,126,234,0.3) !important; }
.hover-shadow-lg { transition: all 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94) !important; }
.hover-shadow-lg:hover { transform: translateY(-15px) scale(1.03) !important; box-shadow: 0 30px 60px rgba(0,0,0,0.25) !important; border-color: rgba(102,126,234,0.2) !important; }
.gradient-overlay { position: absolute; top: 0; left: 0; right: 0; bottom: 0; background: var(--primary-gradient); opacity: 0.5; z-index: 1; }
.card-img-top i { z-index: 2; position: relative; }
.page-link { transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1) !important; }
.page-link:hover:not(.active) { transform: translateY(-3px) scale(1.05) !important; box-shadow: 0 10px 25px rgba(0,0,0,0.2) !important; background: rgba(102,126,234,0.1) !important; border-color: rgba(102,126,234,0.3) !important; }
.page-item.active .page-link { animation: pulse 2s infinite; }
@keyframes pulse { 0% { box-shadow: 0 0 0 0 rgba(102,126,234,0.7); } 70% { box-shadow: 0 0 0 20px rgba(102,126,234,0); } 100% { box-shadow: 0 0 0 0 rgba(102,126,234,0); } }
@media (max-width: 768px) { .pagination { flex-wrap: wrap; justify-content: center; } .page-item { margin: 2px; } }
</style>
