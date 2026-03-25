<?php
class Award {
    private $id;
    private $name;
    private $date;

    private $info;
    private $director_id;
    private $actor_id;
    private $studio_id;

    private $conn;

    public function __construct(mysqli $db){ 
        $this->conn = $db; 
    }

    //Getter, Setter
    public function setId($id)              { $this->id = $id; }
    public function setName($name)          { $this->name = $name; }
    public function setDate($date)          { $this->date = $date; }
    public function setInfo($info)          { $this->info = $info; }
    public function setDirector($director)  { $this->director_id = $director; }
    public function setActor($actor)        { $this->actor_id = $actor; }
    public function setStudio($studio)      { $this->studio_id = $studio; }
    
    public function getId()         { return $this->id; }
    public function getName()       { return $this->name; }
    public function getDate()       { return $this->date; }
    public function getInfo()       { return $this->info; }
    public function getDirector()   { return $this->director_id; }
    public function getActor()      { return $this->actor_id; }
    public function getStudio()     { return $this->studio_id; }

    //createAward()
    public function createAward(){

        $sql = "INSERT INTO tbl_award
                (Award_Name, Award_Info, Award_Date)
                VALUES (?,?,?)";

        $stmt = $this->conn->prepare($sql);

        $stmt->bind_param(
            "sss",
            $this->name,
            $this->info,
            $this->date,
        );

        $stmt->execute();
        $this->id = $this->conn->insert_id;
        return $this->id;
    }

    //assignAwardToActor()
    public function assignAwardToActor(){

        $sql = "INSERT INTO `tbl_award-actor`
                (Award_ID, Actor_ID)
                VALUES (?,?)";

        $stmt = $this->conn->prepare($sql);

        $stmt->bind_param(
            "ii",
            $this->id,
            $this->actor_id
        );

        return $stmt->execute();
    }

    //assignAwardToDirector()
    public function assignAwardToDirector(){

        $sql = "INSERT INTO `tbl_award-director`
                (Award_ID, Director_ID)
                VALUES (?,?)";

        $stmt = $this->conn->prepare($sql);

        $stmt->bind_param(
            "ii",
            $this->id,
            $this->director_id
        );

        return $stmt->execute();
    }

    //getDetails()
    public function getDetails(){

        $sql = "SELECT *
                FROM tbl_award
                WHERE Award_ID=?";

        $stmt = $this->conn->prepare($sql);

        $stmt->bind_param("i",$this->id);

        $stmt->execute();

        return $stmt->get_result()->fetch_assoc();
    }

    //Danh sách Award
    public function getAll(){

        $sql = "SELECT * FROM tbl_award ORDER BY Award_Date DESC";

        return $this->conn->query($sql);
    }

    //Stored Procedure
    public function getTopActors(){

        $sql = "CALL sp_TopActorsByAwards()";

        return $this->conn->query($sql);
    }
}
?>
