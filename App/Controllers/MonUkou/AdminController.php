<?php
namespace App\Controllers\MonUkou;

require_once __DIR__ . '/../../../Config/config.php';
require_once __DIR__ . '/../../../Config/database.php';

class AdminController {
    private $mysqli;
    private $newsUploadDir;

    public function __construct() {
        require_once __DIR__ . '/../../../Config/config.php';
        $this->mysqli = new \mysqli(HOST, USER, PASSWORD, DB);
        if ($this->mysqli->connect_error) {
            die("Connection failed: " . $this->mysqli->connect_error);
        }
        $this->mysqli->set_charset('utf8mb4');
        $this->newsUploadDir = dirname(__DIR__, 3) . DIRECTORY_SEPARATOR . 'uploads' . DIRECTORY_SEPARATOR . 'news';
    }

    public function dashboard() {
        $selectedFilter = $_GET['filter'] ?? 'all';
        $allowedFilters = ['all', 'movie', 'actor', 'draft', 'comments'];

        if (!in_array($selectedFilter, $allowedFilters, true)) {
            $selectedFilter = 'all';
        }

        $stats = [
            'total_news' => 0,
            'movie_news' => 0,
            'actor_news' => 0,
            'total_comments' => 0,
        ];

        $newsList = [];
        $commentList = [];
        $latestPosts = [];
        $dbError = null;

        $page = max(1, intval($_GET['page'] ?? 1));
        $itemsPerPage = 9;

        try {
            $countQueries = [
                'total_news' => "SELECT COUNT(*) AS total FROM tbl_new",
                'movie_news' => "SELECT COUNT(*) AS total FROM tbl_new WHERE New_Category = 'Movie'",
                'actor_news' => "SELECT COUNT(*) AS total FROM tbl_new WHERE New_Category = 'Actor'",
                'total_comments' => "SELECT COUNT(*) AS total FROM tbl_comment",
            ];

            foreach ($countQueries as $key => $sql) {
                $result = $this->mysqli->query($sql);
                if ($result) {
                    $stats[$key] = (int) ($result->fetch_assoc()['total'] ?? 0);
                }
            }

            $whereClause = '';
            if ($selectedFilter === 'movie') {
                $whereClause = "WHERE n.New_Category = 'Movie'";
            } elseif ($selectedFilter === 'actor') {
                $whereClause = "WHERE n.New_Category = 'Actor'";
            } elseif ($selectedFilter === 'draft') {
                $whereClause = "WHERE n.New_Status <> 'Publish'";
            }

            $isCommentView = $selectedFilter === 'comments';
            if ($isCommentView) {
                $countSql = "SELECT COUNT(*) AS total FROM tbl_comment";
            } else {
                $countSql = "SELECT COUNT(*) AS total FROM tbl_new n $whereClause";
            }

            $countResult = $this->mysqli->query($countSql);
            $totalItems = 0;
            if ($countResult) {
                $totalItems = (int) ($countResult->fetch_assoc()['total'] ?? 0);
            }

            $totalPages = max(1, (int) ceil($totalItems / $itemsPerPage));
            if ($page > $totalPages) {
                $page = $totalPages;
            }
            $offset = ($page - 1) * $itemsPerPage;

            if ($isCommentView) {
                $commentSql = "SELECT c.Comment_ID, c.Comment_Data, c.Comment_Date, c.New_ID,
                                      a.Username, n.New_Title
                               FROM tbl_comment c
                               LEFT JOIN tbl_account a ON c.Account_ID = a.Account_ID
                               LEFT JOIN tbl_new n ON c.New_ID = n.New_ID
                               ORDER BY c.Comment_Date DESC
                               LIMIT {$offset}, {$itemsPerPage}";
                $commentResult = $this->mysqli->query($commentSql);
                if ($commentResult) {
                    while ($row = $commentResult->fetch_assoc()) {
                        $commentList[] = $row;
                    }
                }
            } else {
                $newsSql = "SELECT n.New_ID, n.New_Title, n.New_Description, n.New_Content, n.New_Img,
                                   n.New_Category, n.New_Status, n.New_PublishDate, n.New_View,
                                   a.Username
                            FROM tbl_new n
                            LEFT JOIN tbl_account a ON n.Account_ID = a.Account_ID
                            $whereClause
                            ORDER BY n.New_PublishDate DESC, n.New_ID DESC
                            LIMIT {$offset}, {$itemsPerPage}";
                $newsResult = $this->mysqli->query($newsSql);

                if ($newsResult) {
                    while ($row = $newsResult->fetch_assoc()) {
                        $summary = trim(substr(strip_tags($row['New_Description'] ?: $row['New_Content'] ?: ''), 0, 120));
                        $row['short_desc'] = $summary !== '' ? $summary . '...' : 'Chua co mo ta cho bai viet nay.';
                        $newsList[] = $row;
                    }
                }
            }

            $latestSql = "SELECT New_ID, New_Title, New_PublishDate
                          FROM tbl_new
                          ORDER BY New_PublishDate DESC, New_ID DESC
                          LIMIT 5";
            $latestResult = $this->mysqli->query($latestSql);
            if ($latestResult) {
                $latestPosts = $latestResult->fetch_all(MYSQLI_ASSOC);
            }

            $GLOBALS['selectedFilter'] = $selectedFilter;
            $GLOBALS['stats'] = $stats;
            $GLOBALS['newsList'] = $newsList;
            $GLOBALS['commentList'] = $commentList;
            $GLOBALS['latestPosts'] = $latestPosts;
            $GLOBALS['totalPages'] = $totalPages;
            $GLOBALS['page'] = $page;
            $GLOBALS['dbError'] = $dbError;
            $GLOBALS['pageTitle'] = 'Admin Dashboard';
        } catch (\Throwable $e) {
            $GLOBALS['dbError'] = $e->getMessage();
        }

        include __DIR__ . '/../../../App/Views/admin/dashboard.php';
    }

    public function addpost() {
        $this->handlePostForm('add');
    }

    public function editpost() {
        $this->handlePostForm('edit');
    }

    public function detailpost() {
        $postId = isset($_GET['id']) ? intval($_GET['id']) : 0;
        $this->showDetail($postId);
    }

    private function handlePostForm($mode = 'add') {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }

        if (!isset($_SESSION['user_obj'])) {
            header("Location: index.php?controller=account&action=login");
            exit;
        }

        $accountId = $_SESSION['user_obj']->getId();
        $error = null;
        $success = null;
        $postId = $mode === 'edit' ? intval($_GET['id'] ?? 0) : 0;

        $availableStatusOptions = [];
        $statusFieldResult = $this->mysqli->query("SHOW COLUMNS FROM tbl_new LIKE 'New_Status'");
        if ($statusFieldResult) {
            $statusField = $statusFieldResult->fetch_assoc();
            if (!empty($statusField['Type'])) {
                $type = trim($statusField['Type']);
                if (preg_match("~^enum\\((.+)\\)$~", $type, $matches)) {
                    foreach (explode(',', $matches[1]) as $statusValue) {
                        $availableStatusOptions[] = trim($statusValue, "'\"");
                    }
                }
            }
        }

        if (empty($availableStatusOptions)) {
            $availableStatusOptions = ['Under Review', 'Publish', 'Banned'];
        }

        $news = [
            'New_Title' => '',
            'New_Description' => '',
            'New_Content' => '',
            'New_Img' => '',
            'New_Category' => 'Movie',
            'New_Status' => !empty($availableStatusOptions) ? $availableStatusOptions[0] : 'Publish',
        ];

        $allowedCategories = ['Movie', 'Actor'];
        $tableColumns = $this->getTableColumns();
        $hasCategoryField = in_array('New_Category', $tableColumns, true);
        $existingPost = null;

        if ($mode === 'edit') {
            if ($postId <= 0) {
                $error = 'ID bai viet khong hop le.';
            } else {
                $existingPost = $this->getPostById($postId);
                if (!$existingPost) {
                    $error = 'Khong tim thay bai viet.';
                } else {
                    $news = array_merge($news, $existingPost);
                }
            }
        }

        if (!$error && $_SERVER['REQUEST_METHOD'] === 'POST') {
            $news['New_Title'] = trim($_POST['New_Title'] ?? '');
            $news['New_Description'] = trim($_POST['New_Description'] ?? '');
            $news['New_Content'] = trim($_POST['New_Content'] ?? '');
            $news['New_Img'] = trim($_POST['existing_New_Img'] ?? ($existingPost['New_Img'] ?? ''));
            if ($hasCategoryField) {
                $news['New_Category'] = in_array($_POST['New_Category'] ?? 'Movie', $allowedCategories, true) ? $_POST['New_Category'] : 'Movie';
            }
            $submittedStatus = trim($_POST['New_Status'] ?? $news['New_Status']);
            $news['New_Status'] = in_array($submittedStatus, $availableStatusOptions, true) ? $submittedStatus : $news['New_Status'];

            if ($news['New_Title'] === '' || $news['New_Content'] === '') {
                $error = 'Tieu de va noi dung la bat buoc.';
            } else {
                $imageResult = $this->handleNewsImageUpload('New_Img', $news['New_Img']);
                if ($imageResult['error'] !== null) {
                    $error = $imageResult['error'];
                } else {
                    $news['New_Img'] = $imageResult['filename'];

                    if ($mode === 'add') {
                        $this->insertPost($news, $accountId, $tableColumns);
                    } else {
                        $this->updatePost($news, $postId, $tableColumns);
                    }
                }
            }
        }

        $GLOBALS['news'] = $news;
        $GLOBALS['error'] = $error;
        $GLOBALS['success'] = $success;
        $GLOBALS['availableStatusOptions'] = $availableStatusOptions;
        $GLOBALS['allowedCategories'] = $allowedCategories;
        $GLOBALS['hasCategoryField'] = $hasCategoryField;
        $GLOBALS['mode'] = $mode;
        $GLOBALS['postId'] = $postId;
        $GLOBALS['pageTitle'] = $mode === 'add' ? 'Them bai viet' : 'Chinh sua bai viet';

        include __DIR__ . '/../../../App/Views/admin/' . $mode . 'post.php';
    }

    private function insertPost($news, $accountId, $tableColumns) {
        $insertFields = ['New_Title', 'New_Description', 'New_Content', 'New_Img', 'New_Status', 'New_PublishDate', 'Account_ID'];
        $insertValues = [
            $news['New_Title'],
            $news['New_Description'],
            $news['New_Content'],
            $news['New_Img'],
            $news['New_Status'],
            date('Y-m-d'),
            $accountId,
        ];

        if (in_array('New_Category', $tableColumns, true)) {
            $insertFields[] = 'New_Category';
            $insertValues[] = $news['New_Category'];
        }
        if (in_array('New_View', $tableColumns, true)) {
            $insertFields[] = 'New_View';
            $insertValues[] = 0;
        }

        $placeholders = implode(', ', array_fill(0, count($insertFields), '?'));
        $fieldList = implode(', ', $insertFields);
        $types = '';
        foreach ($insertFields as $field) {
            if ($field === 'Account_ID' || $field === 'New_View') {
                $types .= 'i';
            } else {
                $types .= 's';
            }
        }

        $sql = "INSERT INTO tbl_new ({$fieldList}) VALUES ({$placeholders})";
        $stmt = $this->mysqli->prepare($sql);
        if ($stmt) {
            $bindParams = array_merge([$types], $insertValues);
            $tmp = [];
            foreach ($bindParams as $key => $value) {
                $tmp[$key] = &$bindParams[$key];
            }
            call_user_func_array([$stmt, 'bind_param'], $tmp);

            if ($stmt->execute()) {
                $insertedId = $stmt->insert_id;
                header('Location: index.php?controller=admin&action=detailpost&id=' . (int) $insertedId);
                exit;
            }
            $stmt->close();
        }
    }

    private function updatePost($news, $postId, $tableColumns) {
        $fieldsToUpdate = ['New_Title = ?', 'New_Description = ?', 'New_Content = ?', 'New_Img = ?', 'New_Status = ?'];
        $values = [
            $news['New_Title'],
            $news['New_Description'],
            $news['New_Content'],
            $news['New_Img'],
            $news['New_Status'],
        ];

        $hasCategoryField = in_array('New_Category', $tableColumns, true);
        if ($hasCategoryField) {
            $fieldsToUpdate[] = 'New_Category = ?';
            $values[] = $news['New_Category'];
        }

        $values[] = $postId;
        $types = 'sssss' . ($hasCategoryField ? 's' : '') . 'i';

        $sql = 'UPDATE tbl_new SET ' . implode(', ', $fieldsToUpdate) . ' WHERE New_ID = ?';
        $stmt = $this->mysqli->prepare($sql);
        if ($stmt) {
            $bindParams = array_merge([$types], $values);
            $tmp = [];
            foreach ($bindParams as $key => $value) {
                $tmp[$key] = &$bindParams[$key];
            }
            call_user_func_array([$stmt, 'bind_param'], $tmp);

            if ($stmt->execute()) {
                header('Location: index.php?controller=admin&action=detailpost&id=' . $postId);
                exit;
            }
            $stmt->close();
        }
    }

    private function getTableColumns() {
        $tableColumns = [];
        $columnsResult = $this->mysqli->query('DESCRIBE tbl_new');
        if ($columnsResult) {
            while ($row = $columnsResult->fetch_assoc()) {
                $tableColumns[] = $row['Field'];
            }
        }

        return $tableColumns;
    }

    private function handleNewsImageUpload($fieldName, $currentFilename = '') {
        if (!isset($_FILES[$fieldName]) || !is_array($_FILES[$fieldName])) {
            return ['filename' => $currentFilename, 'error' => null];
        }

        $file = $_FILES[$fieldName];
        if (($file['error'] ?? UPLOAD_ERR_NO_FILE) === UPLOAD_ERR_NO_FILE) {
            return ['filename' => $currentFilename, 'error' => null];
        }

        if (($file['error'] ?? UPLOAD_ERR_OK) !== UPLOAD_ERR_OK) {
            return ['filename' => $currentFilename, 'error' => 'Tai anh len that bai. Vui long thu lai.'];
        }

        $tmpName = $file['tmp_name'] ?? '';
        if ($tmpName === '' || !is_uploaded_file($tmpName)) {
            return ['filename' => $currentFilename, 'error' => 'Khong nhan duoc tep anh hop le.'];
        }

        $imageInfo = @getimagesize($tmpName);
        if ($imageInfo === false) {
            return ['filename' => $currentFilename, 'error' => 'Chi chap nhan tep anh hop le.'];
        }

        $allowedExtensions = [
            'image/jpeg' => 'jpg',
            'image/png' => 'png',
            'image/gif' => 'gif',
            'image/webp' => 'webp',
        ];

        $mimeType = $imageInfo['mime'] ?? '';
        if (!isset($allowedExtensions[$mimeType])) {
            return ['filename' => $currentFilename, 'error' => 'Anh phai co dinh dang JPG, PNG, GIF hoac WEBP.'];
        }

        if (!is_dir($this->newsUploadDir) && !mkdir($this->newsUploadDir, 0777, true) && !is_dir($this->newsUploadDir)) {
            return ['filename' => $currentFilename, 'error' => 'Khong the tao thu muc luu anh.'];
        }

        $baseName = pathinfo($file['name'] ?? 'news-image', PATHINFO_FILENAME);
        $safeBaseName = preg_replace('/[^A-Za-z0-9_-]+/', '-', $baseName);
        $safeBaseName = trim((string) $safeBaseName, '-');
        if ($safeBaseName === '') {
            $safeBaseName = 'news-image';
        }

        $filename = $safeBaseName . '-' . uniqid('', true) . '.' . $allowedExtensions[$mimeType];
        $targetPath = $this->newsUploadDir . DIRECTORY_SEPARATOR . $filename;

        if (!move_uploaded_file($tmpName, $targetPath)) {
            return ['filename' => $currentFilename, 'error' => 'Khong the luu anh da tai len.'];
        }

        return ['filename' => $filename, 'error' => null];
    }

    private function getPostById($postId) {
        $sql = "SELECT * FROM tbl_new WHERE New_ID = ? LIMIT 1";
        $stmt = $this->mysqli->prepare($sql);
        if ($stmt) {
            $stmt->bind_param('i', $postId);
            $stmt->execute();
            $result = $stmt->get_result();
            $post = $result->fetch_assoc();
            $stmt->close();
            return $post ?: null;
        }
        return null;
    }

    private function showDetail($postId) {
        if ($postId <= 0) {
            header('Location: index.php?controller=admin&action=dashboard');
            exit;
        }

        if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['delete_post'])) {
            $deleteStmt = $this->mysqli->prepare('DELETE FROM tbl_new WHERE New_ID = ?');
            if ($deleteStmt) {
                $deleteStmt->bind_param('i', $postId);
                if ($deleteStmt->execute()) {
                    $deleteStmt->close();
                    header('Location: index.php?controller=admin&action=dashboard&deleted=1');
                    exit;
                }
            }
        }

        $sql = 'SELECT n.New_ID, n.New_Title, n.New_Description, n.New_Content, n.New_Img,
                n.New_Category, n.New_Status, n.New_PublishDate, n.New_View,
                a.Username
         FROM tbl_new n
         LEFT JOIN tbl_account a ON n.Account_ID = a.Account_ID
         WHERE n.New_ID = ?
         LIMIT 1';

        $stmt = $this->mysqli->prepare($sql);
        if ($stmt) {
            $stmt->bind_param('i', $postId);
            $stmt->execute();
            $result = $stmt->get_result();
            $post = $result ? $result->fetch_assoc() : null;
            $stmt->close();

            if (!$post) {
                header('Location: index.php?controller=admin&action=dashboard');
                exit;
            }

            $GLOBALS['post'] = $post;
            $GLOBALS['pageTitle'] = 'Chi tiet bai viet - ' . $post['New_Title'];
            include __DIR__ . '/../../../App/Views/admin/detailpost.php';
        }
    }
}
