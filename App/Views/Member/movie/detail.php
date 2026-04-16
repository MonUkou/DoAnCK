<?php 
$movie = $GLOBALS['movie'] ?? null;
$genres = $GLOBALS['genres'] ?? [];
$actors = $GLOBALS['actors'] ?? [];
$directors = $GLOBALS['directors'] ?? [];
$studios = $GLOBALS['studios'] ?? [];
?>

<?php if (!$movie): ?>
<div class="text-center py-8">
    <h3>Phim không tồn tại!</h3>
</div>
<?php else: ?>

<div class="container mt-5">

<!-- MAIN CARD -->
<div class="card shadow-lg border-0 p-4" style="border-radius: 20px;">

<div class="row">

    <!-- IMAGE -->
    <div class="col-md-4 text-center">
        <?php if (!empty($movie['Movie_Img'])): ?>
            <img src="uploads/movies/<?= htmlspecialchars($movie['Movie_Img']) ?>" 
                 class="img-fluid rounded shadow"
                 style="max-height: 450px; object-fit: cover;">
        <?php else: ?>
            <div class="bg-secondary text-white d-flex align-items-center justify-content-center rounded"
                 style="height: 450px;">
                No Image
            </div>
        <?php endif; ?>
    </div>

    <!-- INFO -->
    <div class="col-md-8">

        <h2 class="fw-bold"><?= htmlspecialchars($movie['Movie_Title']) ?></h2>

        <!-- WATCHLIST -->
        <a href="index.php?controller=watchlist&action=add&movie_id=<?= $movie['Movie_ID'] ?>" 
           class="btn btn-danger mb-3">
           ❤️ Thêm vào Watchlist
        </a>

        <!-- GENRES -->
        <div class="mb-3">
            <?php foreach ($genres as $g): ?>
                <span class="badge bg-primary"><?= htmlspecialchars($g['Genre_Name']) ?></span>
            <?php endforeach; ?>
        </div>

        <!-- DATE -->
        <div class="mb-3">
            <strong>🎬 Ngày công chiếu:</strong><br>
            <span class="text-primary fs-5">
                <?= $movie['Movie_ReleaseDate'] ? date('d/m/Y', strtotime($movie['Movie_ReleaseDate'])) : 'Chưa có' ?>
            </span>
        </div>

        <div class="mb-3">
            <strong>📱 Ngày Streaming:</strong><br>
            <span class="text-success fs-5">
                <?= $movie['Movie_StreamingDate'] ? date('d/m/Y', strtotime($movie['Movie_StreamingDate'])) : 'Chưa có' ?>
            </span>
        </div>

        <!-- DIRECTOR -->
        <div class="mb-3">
            <strong>🎥 Đạo diễn:</strong><br>
            <?php if (!empty($directors)): ?>
                <?php foreach ($directors as $d): ?>
                    <span><?= htmlspecialchars($d['Director_Name']) ?></span><br>
                <?php endforeach; ?>
            <?php else: ?>
                <span>Chưa có</span>
            <?php endif; ?>
        </div>

        <!-- STUDIO -->
        <div class="mb-3">
            <strong>🏢 Studio:</strong><br>
            <?php if (!empty($studios)): ?>
                <?php foreach ($studios as $s): ?>
                    <span><?= htmlspecialchars($s['Studio_Name']) ?></span><br>
                <?php endforeach; ?>
            <?php else: ?>
                <span>Chưa có</span>
            <?php endif; ?>
        </div>

        <!-- DESCRIPTION -->
        <div class="mb-3">
            <strong>📖 Mô tả:</strong>
            <p><?= nl2br(htmlspecialchars($movie['Movie_Description'] ?? 'Không có')) ?></p>
        </div>

    </div>

</div>
</div>

<!-- ACTORS CARD -->
<div class="card mt-4 p-4 shadow-sm" style="border-radius: 20px;">
    <h4 class="mb-3">👥 Diễn viên</h4>

    <?php if (empty($actors)): ?>
        <p>Chưa có</p>
    <?php else: ?>

    <div class="row">
        <?php foreach ($actors as $actor): ?>
        <div class="col-md-6 mb-3">

            <a href="index.php?controller=actor&action=detail&id=<?= $actor['Actor_ID'] ?>"  
               class="text-decoration-none">

                <!-- TRONG PHẦN ACTORS -->
<div class="card-body p-3 h-100 border-0 shadow-sm">
    <div class="d-flex align-items-center">
        <!-- AVATAR -->
        <div class="avatar me-3">
            <?= strtoupper(substr($actor['Actor_Name'], 0, 1)) ?>
        </div>

        <!-- INFO -->
        <div class="flex-grow-1">
            <div class="fw-bold text-dark">
                <?= htmlspecialchars($actor['Actor_Name']) ?>
            </div>
            <!-- ✅ THÊM SỐ PHIM -->
            <small class="text-success">
                <i class="fas fa-film me-1"></i>
                <?= $actor['movie_count'] ?? 0 ?> phim
            </small>
            <small class="text-muted d-block">
                Nhấn để xem chi tiết
            </small>
        </div>
    </div>
</div>

            </a>

        </div>
        <?php endforeach; ?>
    </div>

    <?php endif; ?>
</div>

<!-- BACK BUTTON -->
<div class="text-center mt-4">
    <a href="index.php?controller=movie" 
       class="btn btn-primary px-4 py-2 shadow">
        ← Quay lại danh sách phim
    </a>
</div>

</div>

<style>
.actor-card {
    border-radius: 15px;
    transition: 0.25s;
    cursor: pointer;
}
.actor-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 10px 20px rgba(0,0,0,0.15);
    background: #f8f9fa;
}
.avatar {
    width: 50px;
    height: 50px;
    background: linear-gradient(135deg, #667eea, #764ba2);
    color: white;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: bold;
}
</style>

<?php endif; ?>
