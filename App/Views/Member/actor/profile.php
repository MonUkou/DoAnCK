<div class="container mt-5">

<div class="card shadow-lg border-0 p-4" style="border-radius: 20px;">

<div class="row">

    <div class="col-md-4 text-center">
        <img src="uploads/actors/<?=$actor->Actor_Img?>"="<?= urlencode($actor->Actor_Name) ?>" 
             class="img-fluid rounded shadow"
             style="max-height: 450px; object-fit: cover;">
    </div>

    <div class="col-md-8">

        <h2 class="fw-bold"><?= htmlspecialchars($actor->Actor_Name) ?></h2>

        <div class="mb-3 mt-3">
            <div><strong>🆔 ID:</strong> <?= $actor->Actor_ID ?></div>

            <?php if ($actor->Actor_Social): ?>
            <div>
                <strong>🔗 Mạng xã hội:</strong><br>
                <a href="<?= htmlspecialchars($actor->Actor_Social) ?>" target="_blank">
                    <?= htmlspecialchars($actor->Actor_Social) ?>
                </a>
            </div>
            <?php endif; ?>

            <div class="mt-2">
                <span class="badge bg-primary">
                    🎬 <?= $movieCount ?? 0 ?> phim
                </span>
            </div>
        </div>

        <!-- BIO -->
        <div class="mb-3">
            <strong>📖 Tiểu sử:</strong>
            <p>
                <?= $actor->Actor_Info 
                    ? nl2br(htmlspecialchars($actor->Actor_Info)) 
                    : 'Chưa có thông tin' ?>
            </p>
        </div>

    </div>

</div>
</div>

<?php if (!empty($movies)): ?>
<div class="card mt-4 p-4 shadow-sm" style="border-radius: 20px;">
    <h4 class="mb-3">🎬 Phim tham gia (<?= count($movies) ?> phim)</h4>

    <div class="row">
        <?php foreach (array_slice($movies, 0, 12) as $movie): ?>
        <div class="col-lg-3 col-md-4 col-sm-6 mb-3">
            <a href="index.php?controller=movie&action=showDetail&id=<?= $movie->Movie_ID ?>" 
               class="text-decoration-none text-dark">

                <div class="card h-100 shadow-sm hover-card">
                    <?php if ($movie->Movie_Img): ?>
                    <img src="uploads/movies/<?= $movie->Movie_Img ?? 'default-poster.png' ?>" 
                         class="card-img-top" style="height: 200px; object-fit: cover;">
                    <?php else: ?>
                    <div class="card-img-top bg-secondary d-flex align-items-center justify-content-center text-white" 
                         style="height: 200px;">
                        <i class="fas fa-film fa-3x"></i>
                    </div>
                    <?php endif; ?>

                    <div class="card-body p-2">
                        <h6 class="mb-1 fw-bold"><?= htmlspecialchars(substr($movie->Movie_Title, 0, 25)) ?>...</h6>
                        <small class="text-muted">
                            <?= $movie->Movie_ReleaseDate ? date('d/m/Y', strtotime($movie->Movie_ReleaseDate)) : 'N/A' ?>
                        </small>
                    </div>
                </div>
            </a>
        </div>
        <?php endforeach; ?>
    </div>
</div>
<?php else: ?>
<div class="card mt-4 p-4 text-center bg-light">
    <i class="fas fa-video-slash fa-3x text-muted mb-3"></i>
    <h5 class="text-muted">Chưa có phim nào</h5>
</div>
<?php endif; ?>

<div class="text-center mt-4">
    <a href="index.php?controller=actor" 
       class="btn btn-primary px-4 py-2 shadow">
        ← Quay lại danh sách diễn viên
    </a>
</div>

</div>

<style>
.hover-card {
    transition: 0.25s;
    border-radius: 15px;
}
.hover-card:hover {
    transform: translateY(-5px);
    box-shadow: 0 10px 20px rgba(0,0,0,0.15);
}
</style>
