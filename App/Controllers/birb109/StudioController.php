<?php
class StudioController {
    private $db;

    public function __construct($db) {
        $this->db = $db;
    }

    // index(): Danh sách hãng phim
    public function index() {
        try {
            $sql = "SELECT * FROM tbl_studio ORDER BY Studio_Name ASC";
            $stmt = $this->db->query($sql);
            return $stmt->fetchAll(PDO::FETCH_ASSOC);
        } catch (PDOException $e) {
            error_log("Error in StudioController@index: " . $e->getMessage());
            return [];
        }
    }
}
