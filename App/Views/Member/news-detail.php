<?php
$news = $GLOBALS['news'] ?? null;
$comments = $GLOBALS['comments'] ?? [];
$relatedNews = $GLOBALS['relatedNews'] ?? [];
$defaultAvatar = 'pfp.png';
$currentUserAvatar = 'uploads/accounts/' . $defaultAvatar;

if (isset($_SESSION['user_obj']) && method_exists($_SESSION['user_obj'], 'getImg')) {
    $avatarFile = basename($_SESSION['user_obj']->getImg() ?: $defaultAvatar);
    $avatarPath = 'uploads/accounts/' . $avatarFile;

    if (is_file(__DIR__ . '/../../../' . $avatarPath)) {
        $currentUserAvatar = $avatarPath;
    }
}

if (!$news) {
    echo "<div class='alert alert-danger text-center mt-5'><h4>Tin tức không tồn tại!</h4><a href='index.php' class='btn btn-primary'>← Trang chủ</a></div>";
    return;
}
?>
<div class="container-fluid py-5">
    <div class="row justify-content-center mb-5">
        <div class="col-lg-10 col-xl-8">
            <article class="bg-white rounded-4 shadow-xl p-5">
                <header class="text-center mb-5 pb-4 border-bottom border-3 border-primary">
                    <h1 class="display-4 fw-bold text-dark mb-4 lh-1"><?= htmlspecialchars($news['New_Title']) ?></h1>
                    <div class="text-muted d-flex justify-content-center align-items-center gap-4 fs-6">
                        <span><i class="fas fa-user text-primary me-1"></i><?= htmlspecialchars($news['Username'] ?? 'Admin') ?></span>
                        <span><i class="fas fa-calendar text-primary me-1"></i><?= date('d/m/Y H:i', strtotime($news['New_PublishDate'])) ?></span>
                        <span><i class="fas fa-eye text-primary me-1"></i><?= number_format($news['New_View'] ?? 0) ?> views</span>
                    </div>
                </header>

                <?php if (!empty($news['New_Img'])): ?>
                    <div class="text-center mb-5">
                        <img src="uploads/news/<?= htmlspecialchars($news['New_Img']) ?>"
                             class="img-fluid rounded-3 shadow-lg"
                             style="max-height: 400px; width:100%; object-fit: cover;"
                             alt="<?= htmlspecialchars($news['New_Title']) ?>">
                    </div>
                <?php endif; ?>

                <div class="news-content fs-5 lh-lg" style="line-height: 1.8; color: #333;">
                    <?= nl2br($news['New_Content']) ?>
                </div>
            </article>
        </div>
    </div>

    <div class="row justify-content-center mb-5">
        <div class="col-lg-10 col-xl-8">
            <div class="card shadow-lg border-0">
                <div class="card-header py-4 px-5" style="background: linear-gradient(135deg, #495057 0%, #6c757d 100%) !important; color: white !important; border-bottom: 3px solid rgba(255,255,255,0.3) !important;">
                    <h3 class="mb-0 fw-bold text-white fs-2" style="text-shadow: 0 2px 4px rgba(0,0,0,0.5) !important;">
                        <i class="fas fa-comments me-3"></i>
                        Bình luận <span class="badge bg-white text-dark ms-2 px-3 py-2 fs-6 fw-bold shadow-sm"><?= count($comments) ?></span>
                    </h3>
                </div>

                <?php if (isset($_SESSION['user_obj'])): ?>
                    <div class="card-body border-bottom p-4">
                        <form id="commentForm" class="row g-3">
                            <div class="col-10">
                                <textarea class="form-control" id="commentContent" rows="3" placeholder="Chia sẻ suy nghĩ của bạn... (Ctrl+Enter để gửi)"></textarea>
                            </div>
                            <div class="col-2">
                                <button type="submit" class="btn btn-primary w-100 h-100">
                                    <i class="fas fa-paper-plane"></i><br><small>Gửi</small>
                                </button>
                            </div>
                            <input type="hidden" id="newsId" value="<?= $news['New_ID'] ?>">
                        </form>
                    </div>
                <?php else: ?>
                    <div class="card-body text-center py-5 bg-light">
                        <i class="fas fa-lock fa-3x text-muted mb-3"></i>
                        <h5 class="text-muted">Đăng nhập để bình luận</h5>
                        <a href="index.php?controller=account&action=login" class="btn btn-primary">Đăng nhập</a>
                    </div>
                <?php endif; ?>

                <div class="card-body p-0" style="max-height: 500px; overflow-y: auto;">
                    <?php if (empty($comments)): ?>
                        <div class="text-center py-5 text-muted">
                            <i class="fas fa-comments fa-4x mb-4 opacity-50"></i>
                            <h5>Chưa có bình luận nào</h5>
                            <p class="lead">Hãy là người đầu tiên!</p>
                        </div>
                    <?php else: ?>
                        <?php foreach (array_slice($comments, 0, 10) as $comment): ?>
                            <?php $commentAvatar = basename($comment['Account_Img'] ?? $comment['Account_img'] ?? $defaultAvatar); ?>
                            <div class="p-4 border-bottom hover-bg-light">
                                <div class="d-flex align-items-start gap-3">
                                    <img src="uploads/accounts/<?= htmlspecialchars($commentAvatar, ENT_QUOTES, 'UTF-8') ?>"
                                         class="rounded-circle shadow-sm"
                                         style="width: 48px; height: 48px; object-fit: cover;"
                                         alt="Avatar">
                                    <div class="flex-grow-1 min-width-0">
                                        <div class="d-flex justify-content-between align-items-start mb-2">
                                            <h6 class="fw-bold mb-1 text-truncate"><?= htmlspecialchars($comment['Username']) ?></h6>
                                            <small class="text-muted"><?= date('H:i d/m', strtotime($comment['Comment_Date'])) ?></small>
                                        </div>
                                        <p class="mb-0 lh-sm"><?= nl2br(htmlspecialchars($comment['Comment_Data'] ?? '')) ?></p>
                                    </div>
                                </div>
                            </div>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </div>
            </div>
        </div>
    </div>

    <?php if (!empty($relatedNews)): ?>
        <div class="row justify-content-center">
            <div class="col-lg-10">
                <h3 class="text-white mb-5 text-center display-6 fw-bold">
                    <i class="fas fa-thumbs-up me-3"></i>Tin liên quan
                </h3>
                <div class="row g-4">
                    <?php foreach ($relatedNews as $rel): ?>
                        <div class="col-md-6 col-lg-3">
                            <a href="index.php?controller=news&action=showDetail&id=<?= $rel['New_ID'] ?>" class="text-decoration-none">
                                <div class="card h-100 shadow-lg hover-shadow border-0 bg-gradient-light">
                                    <div class="card-body p-4 text-center">
                                        <i class="fas fa-newspaper fa-3x text-primary mb-3"></i>
                                        <h6 class="fw-bold text-dark lh-sm"><?= htmlspecialchars(substr($rel['New_Title'], 0, 50)) ?>...</h6>
                                        <small class="text-muted"><?= date('d/m/Y', strtotime($rel['New_PublishDate'])) ?></small>
                                    </div>
                                </div>
                            </a>
                        </div>
                    <?php endforeach; ?>
                </div>
            </div>
        </div>
    <?php endif; ?>
</div>

<style>
.bg-gradient { background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%) !important; }
.hover-bg-light:hover { background-color: #f8f9fa !important; }
.hover-shadow { transition: all 0.3s ease; }
.hover-shadow:hover { transform: translateY(-5px); box-shadow: 0 20px 40px rgba(0,0,0,0.15) !important; }
.bg-gradient-light { background: linear-gradient(135deg, #ffffff 0%, #f1f3f4 100%) !important; }
</style>
<script>
document.getElementById("commentForm")?.addEventListener("submit", function(e) {
    e.preventDefault();

    let content = document.getElementById("commentContent").value.trim();
    let newsId = document.getElementById("newsId").value;

    if (!content) {
        alert("Nhập nội dung đi bro");
        return;
    }

    fetch("index.php?controller=comment&action=add", {
        method: "POST",
        headers: {
            "Content-Type": "application/x-www-form-urlencoded"
        },
        body: `news_id=${newsId}&account_id=<?= $_SESSION['user_obj']->getId() ?>&comment_data=${encodeURIComponent(content)}`
    })
    .then(res => res.text())
    .then(text => {
        let data;

        try {
            data = JSON.parse(text);
        } catch (e) {
            alert("Lỗi JSON, mở console để xem chi tiết");
            console.log(text);
            return;
        }

        if (data.success) {
            let html = `
        <div class="p-4 border-bottom">
            <div class="d-flex align-items-start gap-3">
                <img src="<?= htmlspecialchars($currentUserAvatar, ENT_QUOTES, 'UTF-8') ?>"
                    class="rounded-circle"
                    style="width:48px;height:48px;object-fit:cover;"
                    alt="Avatar">
                <div>
                    <b>${data.username}</b>
                    <small class="text-muted ms-2">${data.time}</small>
                    <p class="mb-0">${data.content}</p>
                </div>
            </div>
        </div>`;

            const commentContainer = document.querySelector(".card-body.p-0");
            const emptyState = commentContainer?.querySelector(".text-center.py-5.text-muted");

            if (emptyState) {
                emptyState.remove();
            }

            commentContainer?.insertAdjacentHTML("afterbegin", html);
            document.getElementById("commentContent").value = "";
        } else {
            alert(data.message);
        }
    });
});
</script>
