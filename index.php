<?php

require_once 'App/Models/MonUkou/Account.php';
session_start();

require_once 'Config/database.php';
require_once 'Config/config.php';

ob_start();

if (isset($_GET['controller']) && $_GET['controller'] === 'search') {
    error_reporting(E_ALL);
    ini_set('display_errors', 1);
    echo "SEARCH DEBUG MODE\n";
}
if (!isset($_SESSION['user_obj'])) {
    $controllerCheck = $_GET['controller'] ?? '';
    if ($controllerCheck !== 'account') {
        header("Location: index.php?controller=account&action=login");
        exit;
    }
}

try {

    $controller = $_GET['controller'] ?? 'home';
    $action = $_GET['action'] ?? 'index';
    $page = $_GET['page'] ?? 1;
    $id = $_GET['id'] ?? 0;

    switch ($controller) {

case 'admin':
    require_once 'App/Controllers/MonUkou/AdminController.php';
    $ctrl = new \App\Controllers\MonUkou\AdminController();

    if (!isset($_SESSION['user_obj']) || $_SESSION['user_obj']->getRole() != 1) {
        header("Location: index.php");
        exit;
    }

    switch($action) {
        case 'dashboard':
            $ctrl->dashboard();
            break;
        case 'addpost':
            $ctrl->addpost();
            break;
        case 'editpost':
            $ctrl->editpost();
            break;
        case 'detailpost':
            $ctrl->detailpost();
            break;
        default:
            $ctrl->dashboard();
            break;
    }
    break;

        case 'account':
            require_once 'App/Controllers/MonUkou/AccountController.php';
            $ctrl = new \App\Controllers\MonUkou\AccountController();

            if ($action === 'login') {
                if ($_SERVER['REQUEST_METHOD'] === 'POST') {
                    $ctrl->login(Database::getInstance()->getConnection());
                } else {
                    $ctrl->showLogin();
                }
            } elseif ($action === 'profile') {
                $ctrl->profile();
            } elseif ($action === 'updateProfile') {
                $ctrl->updateProfile();
            } elseif ($action === 'logout') {
                $ctrl->logout();
            }
            break;

        case 'home':
            require_once 'App/Controllers/PNem06/HomeController.php';
            $ctrl = new HomeController(Database::getInstance()->getConnection());

            if ($action === 'movies') $ctrl->movies($page);
            elseif ($action === 'actors') $ctrl->actors($page);
            else $ctrl->index($page);
            break;

        case 'movie':
            require_once 'App/Controllers/birb109/MovieController.php';
            $ctrl = new MovieController(Database::getInstance()->getConnection());

            if ($action === 'detail' || $action === 'showDetail') {  
                $ctrl->showDetail($id);
            } else {
                $ctrl->index($page);
            }
            break;

        case 'actor':
    require_once 'App/Controllers/PNem06/ActorController.php';
    $ctrl = new ActorController();
    if ($action === 'detail' || $action === 'showProfile') {
        $ctrl->showProfile($id);
    } else {
        $ctrl->index($page);
    }
    break;

    case 'news':
        require_once 'App/Controllers/TNhu2006/NewsController.php';
        $ctrl = new NewsController();

        if ($action === 'showDetail') {
            $ctrl->showDetail($id);
        } else {
            $ctrl->index();
        }
        break;


    case 'comment':
    require_once 'App/Controllers/TNhu2006/CommentController.php';
    $ctrl = new CommentController();

    if ($action === 'add') {
        $ctrl->addComment();
    } elseif ($action === 'delete') {
        $ctrl->deleteComment();
    }
    break;
  
case 'search':
    require_once 'App/Controllers/TNhu2006/SearchController.php';
    $ctrl = new \App\Controllers\TNhu2006\SearchController();

    if ($action === 'ajax') {
        $ctrl->ajax();
        exit; 
    }
    break;
       
        default:
            require_once 'App/Controllers/PNem06/HomeController.php';
            $ctrl = new HomeController(Database::getInstance()->getConnection());
            $ctrl->index(1);
            break;
    }

} catch (Exception $e) {
    echo "<div class='alert alert-danger'>Lỗi: " . $e->getMessage() . "</div>";
}

$content = ob_get_clean();

if (($controller ?? '') === 'comment') {
    echo $content;
    return;
}

if (($controller ?? '') === 'account' && ($action ?? '') === 'login') {
    echo $content;
} else {
    include 'App/Views/Member/layouts/main.php';
}
