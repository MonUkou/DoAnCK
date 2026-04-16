<?php
$actors = $GLOBALS['actors'] ?? [];
$currentPage = $GLOBALS['currentPage'] ?? 1;
$totalPages = $GLOBALS['totalPages'] ?? 1;
$pageTitle = $GLOBALS['pageTitle'] ?? 'Danh sách diễn viên';
?>
<?php
require_once __DIR__ . '/../../Models/PNem06/Actor.php';

class ActorController {
    private $actorModel;

    public function __construct() {
        $this->actorModel = new Actor();
    }

    public function index($page = 1) {
        $limit = 6;
        $offset = ($page - 1) * $limit;

        $actors = $this->actorModel->getActorsWithMovieCount($offset, $limit);
        $totalActors = $this->actorModel->getTotalActors();
        $totalPages = ceil($totalActors / $limit);

        $GLOBALS['actors'] = $actors;
        $GLOBALS['totalPages'] = $totalPages;
        $GLOBALS['currentPage'] = $page;
        $GLOBALS['totalActors'] = $totalActors;
        $GLOBALS['pageTitle'] = 'Danh sách diễn viên';

        include __DIR__ . '/../../Views/Member/actor/list.php';
    }

    /** CHI TIẾT DIỄN VIÊN */
    public function showProfile($actor_id) {
    $actor = $this->actorModel->getActorById($actor_id);

    if (!$actor) {
        $_SESSION['error'] = 'Diễn viên không tồn tại!';
        header('Location: index.php?controller=actor');
        exit;
    }

    $movies = $this->actorModel->getMoviesByActorWithCount($actor_id);

    $movieCount = $this->actorModel->getMovieCount($actor_id);

    $GLOBALS['actor'] = $actor;
    $GLOBALS['movies'] = $movies;
    $GLOBALS['movieCount'] = $movieCount; // ✅
    $GLOBALS['pageTitle'] = $actor->Actor_Name;

    include __DIR__ . '/../../Views/Member/actor/profile.php';
}
}
?>
