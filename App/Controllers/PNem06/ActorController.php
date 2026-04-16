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
        $keyword = trim($_GET['keyword'] ?? '');

        if ($keyword !== '') {
            $actors = $this->actorModel->searchActorsWithMovieCount($keyword, $offset, $limit);
            $totalActors = $this->actorModel->countActorsByKeyword($keyword);
            $GLOBALS['searchKeyword'] = $keyword;
        } else {
            $actors = $this->actorModel->getActorsWithMovieCount($offset, $limit);
            $totalActors = $this->actorModel->getTotalActors();
            unset($GLOBALS['searchKeyword']);
        }

        $totalPages = max(1, (int) ceil($totalActors / $limit));

        $GLOBALS['actors'] = $actors;
        $GLOBALS['totalPages'] = $totalPages;
        $GLOBALS['currentPage'] = $page;
        $GLOBALS['totalActors'] = $totalActors;
        $GLOBALS['pageTitle'] = 'Danh sach dien vien';

        include __DIR__ . '/../../Views/Member/actor/list.php';
    }

    public function showProfile($actor_id) {
        $actor = $this->actorModel->getActorById($actor_id);

        if (!$actor) {
            $_SESSION['error'] = 'Dien vien khong ton tai!';
            header('Location: index.php?controller=actor');
            exit;
        }

        $movies = $this->actorModel->getMoviesByActorWithCount($actor_id);
        $movieCount = $this->actorModel->getMovieCount($actor_id);

        $GLOBALS['actor'] = $actor;
        $GLOBALS['movies'] = $movies;
        $GLOBALS['movieCount'] = $movieCount;
        $GLOBALS['pageTitle'] = $actor->Actor_Name;

        include __DIR__ . '/../../Views/Member/actor/profile.php';
    }
}
?>
