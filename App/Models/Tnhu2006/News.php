
 <?php
class News {
    private $conn;

    public function __construct(mysqli $db){
        $this->conn = $db;
    }

    public function getLatest($limit){
        $stmt = $this->conn->prepare("CALL sp_GetLatestNews(?)");
        $stmt->bind_param("i", $limit);
        $stmt->execute();

        $result = $stmt->get_result();

        $stmt->close();
        $this->conn->next_result();

        return $result;
    }

    public function getById($id){
        $stmt = $this->conn->prepare("CALL sp_GetNewsById(?)");
        $stmt->bind_param("i", $id);
        $stmt->execute();

        $result = $stmt->get_result()->fetch_assoc();

        $stmt->close();
        $this->conn->next_result();

        return $result;
    }

    public function increaseView($id){
        $stmt = $this->conn->prepare("CALL sp_IncrementNewsView(?)");
        $stmt->bind_param("i", $id);
        $stmt->execute();

        $stmt->close();
        $this->conn->next_result();

        return true;
    }

    public function getComments($news_id){
        $stmt = $this->conn->prepare("CALL sp_GetCommentsByNews(?)");
        $stmt->bind_param("i", $news_id);
        $stmt->execute();

        $result = $stmt->get_result();

        $stmt->close();
        $this->conn->next_result();

        return $result;
    }

    public function getRelated($newsId, $category, $limitNum){
        $stmt = $this->conn->prepare("CALL sp_GetRelatedNews(?, ?, ?)");
        $stmt->bind_param("isi", $newsId, $category, $limitNum);
        $stmt->execute();

        $result = $stmt->get_result();

        $stmt->close();
        $this->conn->next_result();

        return $result;
    }
}
?>
