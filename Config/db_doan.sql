-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 13, 2026 at 06:33 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_doan`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_AddMovie` (IN `pTitle` VARCHAR(128), IN `pDescription` VARCHAR(512), IN `pImg` VARCHAR(225), IN `pReleaseDate` DATE, IN `pStreamingDate` DATE, IN `pAccountID` INT)   BEGIN
    INSERT INTO tbl_movie(
        Movie_Title,
        Movie_Description,
        Movie_Img,
        Movie_ReleaseDate,
        Movie_StreamingDate,
        Account_ID
    )
    VALUES(
        pTitle,
        pDescription,
        pImg,
        pReleaseDate,
        pStreamingDate,
        pAccountID
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_AddMovieToWatchlist` (IN `p_Movie_ID` INT, IN `p_Watchlist_ID` INT)   BEGIN
    INSERT IGNORE INTO `tbl_movie_watchlist` (Movie_ID, Watchlist_ID)
    VALUES (p_Movie_ID, p_Watchlist_ID);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_DeleteFeedback` (IN `p_Feedback_ID` INT(16))   BEGIN
	DELETE FROM tbl_feedback WHERE Feedback_ID=p_Feedback_ID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetActorsByMovie` (IN `p_MovieID` INT)   BEGIN
    SELECT a.Actor_ID,
           a.Actor_Name,
           a.Actor_Info,
           a.Actor_Social
    FROM tbl_actor a
    INNER JOIN tbl_character c 
        ON a.Actor_ID = c.Actor_ID
    INNER JOIN tbl_movie m 
        ON c.Movie_ID = m.Movie_ID
    WHERE m.Movie_ID = p_MovieID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetAllMovies` ()   BEGIN
    SELECT * FROM tbl_movie;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetLatestMovies` ()   BEGIN
    SELECT 
        m.Movie_Title AS MovieTitle, 
        m.Movie_ReleaseDate AS ReleaseDate,
        GROUP_CONCAT(g.Genre_Name SEPARATOR ', ') AS Genres
    FROM tbl_movie m
    INNER JOIN tbl_movie_genre mg ON m.Movie_ID = mg.Movie_ID
    INNER JOIN tbl_genre g ON mg.Genre_ID = g.Genre_ID
    GROUP BY m.Movie_ID
    ORDER BY m.Movie_ReleaseDate DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getMovieFeedbackList` (IN `Movie_ID` INT(10) ZEROFILL)   BEGIN
    SELECT 
        f.Feedback_ID,
        f.Feedback_Date, 
        f.Feedback_Data, 
        f.Account_ID,
        a.Username
    FROM tbl_feedback f
    JOIN tbl_account a 
        ON f.Account_ID = a.Account_ID
    WHERE f.Movie_ID = Movie_ID
    ORDER BY f.Feedback_Date DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetMoviesByDirector` (IN `p_DirectorID` INT)   BEGIN
    SELECT m.Movie_ID,
           m.Movie_Title,
           m.Movie_ReleaseDate,
           m.Movie_Img
    FROM tbl_movie m
    INNER JOIN `tbl_movie_director` md 
        ON m.Movie_ID = md.Movie_ID
    WHERE md.Director_ID = p_DirectorID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetMoviesByGenre` (IN `pGenreID` INT)   BEGIN
   SELECT m.*, g.Genre_Name
   FROM tbl_movie m
   JOIN tbl_movie_genre mg ON m.Movie_ID = mg.Movie_ID  
   JOIN tbl_genre g ON g.Genre_ID = mg.Genre_ID         
   WHERE mg.Genre_ID = pGenreID                       
   GROUP BY m.Movie_ID
   ORDER BY m.Movie_ReleaseDate DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetMoviesByStudio` (IN `Movie_ID` INT)   BEGIN
    SELECT 
        m.Movie_ID,
        m.Movie_Title,
        m.Movie_Description,
        m.Movie_Img,
        m.Movie_ReleaseDate,
        m.Movie_StreamingDate,
        s.Studio_Name
    FROM tbl_movie m
    INNER JOIN tbl_movie_studio ms ON m.Movie_ID = ms.Movie_ID
    INNER JOIN tbl_studio s ON ms.Studio_ID = s.Studio_ID
    WHERE ms.Studio_ID = @Studio_ID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetMoviesInWatchlist` (IN `p_Watchlist_ID` INT)   BEGIN
    SELECT m.* 
    FROM tbl_movie m
    JOIN `tbl_movie_watchlist` mw 
        ON m.Movie_ID = mw.Movie_ID
    WHERE mw.Watchlist_ID = p_Watchlist_ID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetMovieStatsByGenre` ()   BEGIN
    SELECT 
        g.Genre_Name AS Genre,
        COUNT(m.Movie_ID) AS MovieCount
    FROM tbl_genre g
    LEFT JOIN tbl_movie_genre mg ON g.Genre_ID = mg.Genre_ID
    RIGHT JOIN tbl_movie m ON m.Movie_ID=mg.Movie_ID
    GROUP BY g.Genre_ID, g.Genre_Name
    ORDER BY m.Movie_ReleaseDate DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_InsertAccount` (IN `Username` VARCHAR(32) CHARSET utf8mb4, IN `Password` VARCHAR(16) CHARSET utf8mb4, IN `Mail` VARCHAR(64) CHARSET utf8mb4, IN `Tel` INT(10) ZEROFILL, IN `Account_Img` VARCHAR(225), IN `Role` TINYINT(1))   BEGIN
	INSERT INTO tbl_account(Account_ID, Username, Password, Mail, Tel, Account_Img, Role)
    VALUES (Account_ID, Username, Password, Mail, Tel, Account_Img, Role);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_RemoveMovieFromWatchlist` (IN `p_Movie_ID` INT, IN `p_Watchlist_ID` INT)   BEGIN
    DELETE FROM `tbl_movie_watchlist` 
    WHERE Movie_ID = p_Movie_ID 
      AND Watchlist_ID = p_Watchlist_ID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_SearchMovieByName` (IN `keyword` VARCHAR(128))   BEGIN
    SELECT * 
    FROM tbl_movie
    WHERE Movie_Title LIKE CONCAT('%', keyword, '%');
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_TopActorsByAwards` ()   BEGIN
    SELECT 
        a.Actor_ID,
        a.Actor_Name,
        COUNT(aa.Award_ID) AS Total_Awards
    FROM tbl_actor a
    LEFT JOIN `tbl_award_actor` aa 
        ON a.Actor_ID = aa.Actor_ID
    GROUP BY a.Actor_ID, a.Actor_Name
    ORDER BY Total_Awards DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_TopMoviesByViews` (IN `p_Limit` INT)   BEGIN
    SELECT m.Movie_ID,
           m.Movie_Title,
           COUNT(mw.Movie_ID) AS TotalViews
    FROM tbl_movie m
    INNER JOIN `tbl_movie_watchlist` mw
        ON m.Movie_ID = mw.Movie_ID
    INNER JOIN tbl_watchlist wl
        ON mw.Watchlist_ID = wl.Watchlist_ID
    GROUP BY m.Movie_ID, m.Movie_Title
    ORDER BY TotalViews DESC
    LIMIT p_Limit;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_UpdateAccount` (IN `p_Username` VARCHAR(32) CHARSET utf8mb4, IN `p_Password` VARCHAR(16) CHARSET utf8mb4, IN `p_Mail` VARCHAR(64) CHARSET utf8mb4, IN `p_Tel` INT(10) ZEROFILL, IN `p_Account_Img` VARCHAR(225) CHARSET utf8mb4, IN `p_Role` TINYINT(1))   BEGIN
	UPDATE tbl_account 
    SET
    	Username=p_Username,
        Password=p_Password,
        Mail=p_Mail,
        Tel=p_Tel,
        Account_Img=p_Account_Img,
        Role=p_Role
        WHERE Account_ID=p_Account_ID;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_account`
--

CREATE TABLE `tbl_account` (
  `Account_ID` int(10) NOT NULL,
  `Username` varchar(32) NOT NULL,
  `Password` varchar(32) NOT NULL,
  `Mail` varchar(64) NOT NULL,
  `Tel` int(10) DEFAULT NULL,
  `Account_Img` varchar(225) DEFAULT NULL,
  `Role` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_account`
--

INSERT INTO `tbl_account` (`Account_ID`, `Username`, `Password`, `Mail`, `Tel`, `Account_Img`, `Role`) VALUES
(1, 'Mon', 'f385fe3c0b5e58d048de69717f987cc8', 'MonUs@gmail.com', 234567891, NULL, 1),
(2, 'Hiền', '59d2cd81f877e4b45f3b426faa611e18', 'Hien@gmail.com', NULL, NULL, 0),
(3, 'Nam', '94ddd8e2d4807e1112d3e95b599d7856', 'Nam@gmail.com', NULL, NULL, 1),
(4, 'Như', '8ef41977a3cadd0ee7680fc49cf5b5d4', 'Nhu@gmail.com', NULL, NULL, 0),
(5, 'user1', 'c3c2bd601f0ec6a0', 'U1123@gmail.com', 2147483647, 'user1_img.png', 0);

-- --------------------------------------------------------

--
-- Table structure for table `tbl_actor`
--

CREATE TABLE `tbl_actor` (
  `Actor_ID` int(10) NOT NULL,
  `Actor_Name` varchar(64) NOT NULL,
  `Actor_Info` text DEFAULT NULL,
  `Actor_Social` varchar(225) DEFAULT NULL,
  `Character_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_actor`
--

INSERT INTO `tbl_actor` (`Actor_ID`, `Actor_Name`, `Actor_Info`, `Actor_Social`, `Character_ID`) VALUES
(1, 'Leonardo DiCaprio', 'Nam diễn viên giành giải Oscar, nổi tiếng với các vai diễn trong Inception và Titanic.', 'https://instagram.com/leonardodicaprio', 1),
(2, 'Robert Downey Jr.', 'Nam diễn viên biểu tượng của Marvel với vai diễn Iron Man.', 'https://twitter.com/robertdowneyjr', 2),
(3, 'Scarlett Johansson', 'Nữ diễn viên nổi tiếng với vai Black Widow và nhiều phim nghệ thuật đặc sắc.', 'https://facebook.com/scarlettjohansson', 3),
(4, 'Tom Hardy', 'Diễn viên thực lực người Anh, nổi tiếng với các vai diễn gai góc trong Mad Max và Venom.', 'https://instagram.com/tomhardy', 4),
(5, 'Emma Watson', 'Nổi tiếng từ loạt phim Harry Potter và là nhà hoạt động xã hội tích cực.', 'https://twitter.com/emmawatson', 5),
(6, 'Brad Pitt', 'Nam diễn viên kỳ cựu, nổi tiếng với Fight Club và Once Upon a Time in Hollywood.', 'https://instagram.com/bradpitt', 6),
(7, 'Meryl Streep', 'Được coi là nữ diễn viên xuất sắc nhất thế hệ của mình với kỷ lục đề cử Oscar.', 'https://facebook.com/merylstreep', 7),
(8, 'Denzel Washington', 'Nam diễn viên và đạo diễn lừng danh với các vai diễn đầy quyền lực.', 'https://twitter.com/denzelw', 8),
(9, 'Angelina Jolie', 'Nữ diễn viên, đạo diễn và nhà hoạt động nhân đạo nổi tiếng thế giới.', 'https://instagram.com/angelinajolie', 9),
(10, 'Tom Cruise', 'Ngôi sao hành động hàng đầu với loạt phim Mission Impossible.', 'https://twitter.com/tomcruise', 10),
(11, 'Natalie Portman', 'Nữ diễn viên thực lực, nổi tiếng từ vai diễn trong Leon và Black Swan.', 'https://instagram.com/natalieportman', 11),
(12, 'Joaquin Phoenix', 'Nam diễn viên nổi tiếng với lối diễn xuất nội tâm, đặc biệt là vai Joker.', 'https://facebook.com/joaquinphoenix', 12),
(13, 'Christian Bale', 'Diễn viên phương pháp (method acting) nổi tiếng với sự thay đổi ngoại hình kinh ngạc.', 'https://twitter.com/christianbale', 13),
(14, 'Cate Blanchett', 'Nữ diễn viên người Úc với khả năng hóa thân đa dạng vào nhiều loại vai.', 'https://instagram.com/cateblanchett', 14),
(15, 'Keanu Reeves', 'Nam diễn viên được yêu mến qua loạt phim The Matrix và John Wick.', 'https://twitter.com/keanureeves', 15);

-- --------------------------------------------------------

--
-- Table structure for table `tbl_award`
--

CREATE TABLE `tbl_award` (
  `Award_ID` int(10) NOT NULL,
  `Award_Name` varchar(64) NOT NULL,
  `Award_Info` text DEFAULT NULL,
  `Award_Date` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_award`
--

INSERT INTO `tbl_award` (`Award_ID`, `Award_Name`, `Award_Info`, `Award_Date`) VALUES
(1, 'Best Picture', 'Vinh danh phim Parasite của đạo diễn Bong Joon-ho.', 2020),
(2, 'Best Director', 'Giải đạo diễn xuất sắc nhất dành cho Christopher Nolan.', 2024),
(3, 'Best Actor', 'Leonardo DiCaprio giành giải cho vai diễn trong The Revenant.', 2016),
(4, 'Best Supporting Actor', 'Robert Downey Jr. giành giải Oscar đầu tiên cho Oppenheimer.', 2024),
(5, 'Best Animated Feature', 'Giải phim hoạt hình hay nhất dành cho Spirited Away (Studio Ghibli).', 2003),
(6, 'Best Original Screenplay', 'Quentin Tarantino thắng giải kịch bản cho Pulp Fiction.', 1995),
(7, 'Best Visual Effects', 'Vinh danh kỹ xảo của Avengers: Endgame (Walt Disney Studios).', 2019),
(8, 'Best Production Design', 'Giải thiết kế sản xuất cho bối cảnh lộng lẫy trong The Great Gatsby.', 2014),
(9, 'Best Cinematography', 'Ghi nhận những thước phim không gian tuyệt đẹp của Interstellar.', 2015),
(10, 'Best Independent Film', 'Hãng A24 thắng lớn với Everything Everywhere All at Once.', 2023);

-- --------------------------------------------------------

--
-- Table structure for table `tbl_award_actor`
--

CREATE TABLE `tbl_award_actor` (
  `Award_ID` int(10) NOT NULL,
  `Actor_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_award_actor`
--

INSERT INTO `tbl_award_actor` (`Award_ID`, `Actor_ID`) VALUES
(3, 1),
(4, 2),
(1, 15),
(6, 6);

-- --------------------------------------------------------

--
-- Table structure for table `tbl_award_director`
--

CREATE TABLE `tbl_award_director` (
  `Award_ID` int(10) NOT NULL,
  `Director_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_award_director`
--

INSERT INTO `tbl_award_director` (`Award_ID`, `Director_ID`) VALUES
(1, 2),
(2, 1),
(5, 5),
(6, 3),
(7, 6),
(9, 9);

-- --------------------------------------------------------

--
-- Table structure for table `tbl_award_studio`
--

CREATE TABLE `tbl_award_studio` (
  `Award_ID` int(10) NOT NULL,
  `Studio_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_award_studio`
--

INSERT INTO `tbl_award_studio` (`Award_ID`, `Studio_ID`) VALUES
(5, 6),
(7, 3),
(10, 7),
(2, 2),
(8, 4);

-- --------------------------------------------------------

--
-- Table structure for table `tbl_character`
--

CREATE TABLE `tbl_character` (
  `Character_ID` int(10) NOT NULL,
  `Character_Name` varchar(32) NOT NULL,
  `Movie_ID` int(10) NOT NULL,
  `Actor_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_character`
--

INSERT INTO `tbl_character` (`Character_ID`, `Character_Name`, `Movie_ID`, `Actor_ID`) VALUES
(1, 'Dom Cobb', 1, 1),
(2, 'Jay Gatsby', 4, 1),
(3, 'Tony Stark', 10, 2),
(4, 'Sherlock Holmes', 3, 2),
(5, 'Natasha Romanoff', 10, 3),
(6, 'Lucy', 7, 3),
(7, 'Eddie Brock', 8, 4),
(8, 'Max Rockatansky', 2, 4),
(9, 'Hermione Granger', 5, 5),
(10, 'Belle', 6, 5),
(11, 'Tyler Durden', 7, 6),
(12, 'Miranda Priestly', 4, 7),
(13, 'Alonzo Harris', 9, 8),
(14, 'Lara Croft', 1, 9),
(15, 'Ethan Hunt', 10, 10),
(16, 'Mathilda', 3, 11),
(17, 'Arthur Fleck', 2, 12),
(18, 'Bruce Wayne', 3, 13),
(19, 'Galadriel', 2, 14),
(20, 'Neo', 5, 15),
(21, 'Lewis Strauss', 12, 2),
(22, 'Jack Dawson', 13, 1),
(23, 'Feyd-Rautha Ally', 14, 4),
(24, 'Frank Sheeran Rival', 18, 8),
(25, 'Black Mamba Rival', 19, 9),
(26, 'Commodus', 20, 12);

-- --------------------------------------------------------

--
-- Table structure for table `tbl_comment`
--

CREATE TABLE `tbl_comment` (
  `Comment_ID` int(16) NOT NULL,
  `Comment_Date` date NOT NULL,
  `Comment_Data` text NOT NULL,
  `Account_ID` int(10) NOT NULL,
  `New_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_comment`
--

INSERT INTO `tbl_comment` (`Comment_ID`, `Comment_Date`, `Comment_Data`, `Account_ID`, `New_ID`) VALUES
(1, '2024-01-15', 'Phim này xem hay quá, kỹ xảo đỉnh thực sự!', 1, 1),
(2, '2024-01-16', 'Cốt truyện hơi khó hiểu, chắc phải xem lại lần 2.', 2, 1),
(3, '2024-01-17', 'Diễn xuất của Leonardo DiCaprio chưa bao giờ làm tôi thất vọng.', 3, 2),
(4, '2024-01-18', 'Nhạc phim nghe rất cảm động, phù hợp với không khí phim.', 4, 3),
(5, '2024-01-19', 'Đoạn kết làm mình khóc hết nước mắt luôn...', 3, 4),
(6, '2024-01-20', 'Có ai thấy phim hơi dài quá không? Ngồi mỏi cả lưng.', 1, 5),
(7, '2024-01-21', 'Màu phim đẹp như tranh vẽ, đúng chất Studio Ghibli.', 2, 6),
(8, '2024-01-22', 'Rất thích cách xây dựng nhân vật phản diện trong phần này.', 3, 3),
(9, '2024-01-23', 'Mong chờ phần tiếp theo ra rạp quá đi mất!', 4, 10),
(10, '2024-01-24', 'Một siêu phẩm không thể bỏ qua trong năm nay.', 3, 2),
(11, '2024-01-25', 'Review trên mạng hơi quá đà, thực tế xem cũng bình thường.', 1, 8),
(12, '2024-01-26', 'Thích nhất là triết lý nhân sinh được cài cắm trong phim.', 2, 4),
(13, '2024-01-27', 'Cần thêm nhiều phim có chiều sâu như thế này nữa.', 3, 7),
(14, '2024-01-28', 'Dàn diễn viên phụ diễn còn hay hơn cả diễn viên chính.', 4, 9),
(15, '2024-01-29', 'Đi xem cùng người yêu là hết ý luôn.', 1, 6),
(16, '2024-01-30', 'Kịch bản có vài chỗ hơi vô lý, nhưng tổng thể vẫn ổn.', 1, 2),
(17, '2024-01-31', 'Đạo diễn Christopher Nolan đúng là một thiên tài.', 2, 1),
(18, '2024-02-01', 'Xem xong thấy yêu đời và trân trọng gia đình hơn.', 3, 5),
(19, '2024-02-02', 'Hệ thống rạp chiếu hôm nay hơi tệ, phim thì rất tốt.', 4, 8),
(20, '2024-02-03', 'Chắc chắn sẽ mua bản Blu-ray để sưu tầm.', 2, 3);

-- --------------------------------------------------------

--
-- Table structure for table `tbl_director`
--

CREATE TABLE `tbl_director` (
  `Director_ID` int(10) NOT NULL,
  `Director_Name` varchar(64) NOT NULL,
  `Director_Info` text DEFAULT NULL,
  `Director_Social` varchar(225) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_director`
--

INSERT INTO `tbl_director` (`Director_ID`, `Director_Name`, `Director_Info`, `Director_Social`) VALUES
(1, 'Christopher Nolan', 'Đạo diễn nổi tiếng với phong cách kể chuyện phi tuyến tính và các siêu phẩm như Inception, Interstellar.', 'https://twitter.com/nolanfans'),
(2, 'Bong Joon-ho', 'Đạo diễn người Hàn Quốc đầu tiên đoạt giải Oscar cho Phim xuất sắc nhất với tác phẩm Parasite.', 'https://instagram.com/bongjoonho'),
(3, 'Quentin Tarantino', 'Nổi tiếng với các bộ phim có lời thoại sắc sảo và phong cách bạo lực thẩm mỹ như Pulp Fiction.', 'https://facebook.com/tarantino'),
(4, 'Francis Ford Coppola', 'Một trong những đạo diễn vĩ đại nhất lịch sử điện ảnh, cha đẻ của loạt phim The Godfather.', 'https://instagram.com/ffcoppola'),
(5, 'Hayao Miyazaki', 'Huyền thoại hoạt hình Nhật Bản, người sáng lập Studio Ghibli và đạo diễn Spirited Away.', 'https://twitter.com/ghibli'),
(6, 'Russo Brothers', 'Đạo diễn đứng sau các bom tấn phòng vé toàn cầu của Marvel như Avengers: Endgame.', 'https://twitter.com/russo_brothers'),
(7, 'Makoto Shinkai', 'Nổi tiếng với những bộ phim hoạt hình có hình ảnh lung linh như Your Name, Weathering With You.', 'https://twitter.com/shinkaimakoto'),
(8, 'The Wachowskis', 'Đồng đạo diễn của loạt phim khoa học viễn tưởng kinh điển The Matrix.', 'https://twitter.com/wachowskis'),
(9, 'James Cameron', 'Đạo diễn của những siêu phẩm công nghệ như Avatar và Titanic, người định hình lại kỹ xảo điện ảnh.', 'https://instagram.com/jamescameron'),
(10, 'Martin Scorsese', 'Bậc thầy của dòng phim tội phạm và lịch sử điện ảnh với các tác phẩm như Goodfellas, The Irishman.', 'https://instagram.com/martinscorsese_'),
(11, 'Trấn Thành', 'Đạo diễn, diễn viên sở hữu các kỷ lục phòng vé Việt Nam với Bố Già, Nhà Bà Nữ, Mai.', 'https://facebook.com/tranthanh.official'),
(12, 'Victor Vũ', 'Đạo diễn Việt kiều nổi tiếng với các tác phẩm chỉn chu, hình ảnh đẹp như Mắt Biếc, Tôi Thấy Hoa Vàng Trên Cỏ Xanh.', 'https://facebook.com/victorvu.director'),
(13, 'Lý Hải', 'Đạo diễn đứng sau series phim hành động - hài Lật Mặt cực kỳ thành công tại thị trường Việt.', 'https://facebook.com/lyhai.production'),
(14, 'Vũ Ngọc Đãng', 'Đạo diễn nổi tiếng với phong cách phim đời thường, gần gũi như Bố Già (bản điện ảnh), Chị Chị Em Em 2.', 'https://facebook.com/vungocdang.director'),
(15, 'Aaron Toronto', 'Đạo diễn đứng sau tác phẩm tâm lý xã hội Đêm Tối Rực Rỡ, đoạt nhiều giải thưởng điện ảnh.', 'https://facebook.com/aarontoronto'),
(16, 'Phan Gia Nhật Linh', 'Đạo diễn của các bộ phim đình đám như Em Là Bà Nội Của Anh, Tiệc Trăng Máu.', 'https://facebook.com/phangianhatlinh');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_feedback`
--

CREATE TABLE `tbl_feedback` (
  `Feedback_ID` int(16) NOT NULL,
  `Feedback_Date` date NOT NULL,
  `Feedback_Data` text NOT NULL,
  `Account_ID` int(10) NOT NULL,
  `Movie_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_feedback`
--

INSERT INTO `tbl_feedback` (`Feedback_ID`, `Feedback_Date`, `Feedback_Data`, `Account_ID`, `Movie_ID`) VALUES
(1, '2024-03-01', 'Phim quá tuyệt vời, nội dung hack não đúng chất Nolan.', 1, 1),
(2, '2024-03-02', 'Cảnh quay ngoài không gian trong Interstellar quá thực.', 3, 2),
(3, '2024-03-03', 'Vai Joker của Heath Ledger trong phim này là huyền thoại.', 3, 3),
(4, '2024-03-04', 'Parasite phản ánh thực tế xã hội rất sâu sắc.', 3, 4),
(5, '2024-03-05', 'Kỹ xảo của The Matrix dù lâu rồi vẫn thấy đỉnh.', 1, 5),
(6, '2024-03-06', 'Spirited Away là bộ phim hoạt hình hay nhất tôi từng xem.', 1, 6),
(7, '2024-03-07', 'Lời thoại trong Pulp Fiction cực kỳ thông minh.', 3, 7),
(8, '2024-03-08', 'Your Name có hình ảnh đẹp đến mức có thể dùng làm hình nền.', 3, 8),
(9, '2024-03-09', 'The Godfather đúng là một kiệt tác điện ảnh mọi thời đại.', 1, 9),
(10, '2024-03-10', 'Endgame là cái kết quá mỹ mãn cho một hành trình dài.', 3, 10),
(11, '2024-03-11', 'Ước gì được xem lại Inception trên rạp một lần nữa.', 1, 1),
(12, '2024-03-12', 'Nhạc phim Interstellar của Hans Zimmer nghe quá nổi da gà.', 3, 2),
(13, '2024-03-13', 'The Dark Knight là phim siêu anh hùng hay nhất lịch sử.', 3, 3),
(14, '2024-03-14', 'Cú twist trong Parasite làm mình thực sự sốc.', 1, 4);

-- --------------------------------------------------------

--
-- Table structure for table `tbl_genre`
--

CREATE TABLE `tbl_genre` (
  `Genre_ID` int(10) NOT NULL,
  `Genre_Name` varchar(16) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_genre`
--

INSERT INTO `tbl_genre` (`Genre_ID`, `Genre_Name`) VALUES
(1, 'Action'),
(2, 'Adventure'),
(3, 'Sci-Fi'),
(4, 'Drama'),
(5, 'Thriller'),
(6, 'Crime'),
(7, 'Animation'),
(8, 'Fantasy'),
(9, 'Romance'),
(10, 'Mystery'),
(11, 'Horror'),
(12, 'Family'),
(13, 'Biography'),
(14, 'History'),
(15, 'Comedy');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_movie`
--

CREATE TABLE `tbl_movie` (
  `Movie_ID` int(10) NOT NULL,
  `Movie_Title` varchar(128) NOT NULL,
  `Movie_Description` varchar(512) DEFAULT NULL,
  `Movie_Img` varchar(225) DEFAULT NULL,
  `Movie_ReleaseDate` date DEFAULT NULL,
  `Movie_StreamingDate` date DEFAULT NULL,
  `Account_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_movie`
--

INSERT INTO `tbl_movie` (`Movie_ID`, `Movie_Title`, `Movie_Description`, `Movie_Img`, `Movie_ReleaseDate`, `Movie_StreamingDate`, `Account_ID`) VALUES
(1, 'Inception', 'A thief who steals corporate secrets through the use of dream-sharing technology.', 'inception.jpg', '2010-07-16', '2010-12-01', 1),
(2, 'Interstellar', 'A team of explorers travel through a wormhole in space in an attempt to ensure humanity survival.', 'interstellar.jpg', '2014-11-07', '2015-03-15', 1),
(3, 'The Dark Knight', 'When the menace known as the Joker wreaks havoc and chaos on the people of Gotham.', 'dark_knight.jpg', '2008-07-18', '2008-11-10', 3),
(4, 'Parasite', 'Greed and class discrimination threaten the newly formed symbiotic relationship.', 'parasite.png', '2019-05-30', '2019-10-11', 1),
(5, 'The Matrix', 'A computer hacker learns from mysterious rebels about the true nature of his reality.', 'matrix.jpg', '1999-03-31', '1999-09-21', 3),
(6, 'Spirited Away', 'During her family move to the suburbs, a sullen 10-year-old girl wanders into a world ruled by gods.', 'spirited_away.jpg', '2001-07-20', '2002-03-15', 4),
(7, 'Pulp Fiction', 'The lives of two mob hitmen, a boxer, a gangster and his wife intertwine in four tales.', 'pulp_fiction.jpg', '1994-10-14', '1995-05-20', 1),
(8, 'Your Name', 'Two strangers find themselves linked in a bizarre way. When a connection forms, will distance be the only thing to keep them apart?', 'your_name.jpg', '2016-08-26', '2017-01-10', 3),
(9, 'The Godfather', 'An organized crime dynasty aging patriarch transfers control of his clandestine empire to his reluctant son.', 'godfather.jpg', '1972-03-24', '1972-10-01', 4),
(10, 'Avengers: Endgame', 'After the devastating events of Infinity War, the universe is in ruins.', 'avengers.jpg', '2019-04-26', '2019-08-15', 1),
(11, 'Spider-Man: Into the Spider-Verse', 'Hành trình của Miles Morales qua đa vũ trụ nhện với phong cách đồ họa độc đáo.', 'spiderman_verse.jpg', '2018-12-14', '2019-03-19', 1),
(12, 'Oppenheimer', 'Câu chuyện về J. Robert Oppenheimer và dự án Manhattan chế tạo bom nguyên tử.', 'oppenheimer.jpg', '2023-07-21', '2023-11-21', 1),
(13, 'Titanic', 'Câu chuyện tình yêu định mệnh trên con tàu huyền thoại không may gặp nạn.', 'titanic.jpg', '1997-12-19', '1998-09-01', 4),
(14, 'Dune: Part Two', 'Paul Atreides hợp lực với Chani và người Fremen để trả thù những kẻ hủy diệt gia đình mình.', 'dune_2.jpg', '2024-03-01', '2024-05-14', 1),
(15, 'Avatar: The Way of Water', 'Jake Sully và Neytiri phải bảo vệ gia đình và bộ tộc trước mối đe dọa từ loài người.', 'avatar_2.jpg', '2022-12-16', '2023-03-28', 1),
(16, 'Howl\'s Moving Castle', 'Cô gái trẻ Sophie bị nguyền rủa thành bà lão và bắt đầu hành trình cùng phù thủy Howl.', 'howl_castle.jpg', '2004-11-20', '2005-03-07', 4),
(17, 'Everything Everywhere All at Once', 'Một phụ nữ nhập cư bị cuốn vào cuộc phiêu lưu điên rồ qua các đa vũ trụ để cứu thế giới.', 'eeaaow.jpg', '2022-03-25', '2022-06-07', 3),
(18, 'The Irishmen', 'Câu chuyện về một kẻ sát nhân nhìn lại những bí mật mà anh ta đã giữ cho nghiệp đoàn tội phạm.', 'irishman.jpg', '2019-11-01', '2019-11-27', 1),
(19, 'Kill Bill: Vol. 1', 'Một nữ sát thủ được gọi là Cô dâu thực hiện kế hoạch trả thù những người đã phản bội mình.', 'kill_bill.jpg', '2003-10-10', '2004-04-13', 1),
(20, 'Gladiator', 'Một vị tướng La Mã bị phản bội và tìm cách trả thù hoàng đế tham nhũng trong đấu trường.', 'gladiator.jpg', '2000-05-05', '2000-11-21', 3),
(21, 'Bố Già', 'Phim tâm lý tình cảm gia đình lập kỷ lục doanh thu tại Việt Nam.', 'bo_gia.jpg', '2021-03-12', '2021-06-15', 1),
(22, 'Mai', 'Câu chuyện tình yêu đầy trắc trở của một người phụ nữ làm nghề massage.', 'mai_phim.jpg', '2024-02-10', '2024-05-20', 1),
(23, 'Em Là Bà Nội Của Anh', 'Một bà lão 70 tuổi bất ngờ được trở lại tuổi 20 rực rỡ.', 'em_la_ba_noi.jpg', '2015-12-11', '2016-03-01', 1),
(24, 'Mắt Biếc', 'Chuyện tình đơn phương đẫm nước mắt của Ngạn dành cho Hà Lan.', 'mat_biec.jpg', '2019-12-20', '2020-04-15', 3),
(25, 'Hai Phượng', 'Hành trình nghẹt thở của người mẹ đi tìm đứa con bị bắt cóc.', 'hai_phuong.jpg', '2019-02-22', '2019-05-22', 3),
(26, 'Tôi Thấy Hoa Vàng Trên Cỏ Xanh', 'Bức tranh làng quê Việt Nam yên bình qua ánh mắt của những đứa trẻ.', 'hoa_vang_co_xanh.jpg', '2015-10-02', '2016-01-10', 1),
(27, 'Tiệc Trăng Máu', 'Những bí mật kinh hoàng bị hé lộ trong một bữa tiệc tối của nhóm bạn thân.', 'tiec_trang_mau.jpg', '2020-10-23', '2021-01-30', 1),
(28, 'Lật Mặt 7: Một Điều Ước', 'Phim gia đình lấy nước mắt khán giả về tình mẫu tử thiêng liêng.', 'lat_mat_7.jpg', '2024-04-26', '2024-08-15', 3),
(29, 'Chị Chị Em Em', 'Cuộc đấu trí và những âm mưu đen tối giữa những người phụ nữ.', 'chi_chi_em_em.jpg', '2019-12-20', '2020-03-20', 1),
(30, 'Đêm Tối Rực Rỡ', 'Bi kịch bùng nổ trong một đêm tang lễ tại một gia đình miền Nam.', 'dem_toi_ruc_ro.jpg', '2022-04-08', '2022-07-08', 3),
(31, 'Lật Mặt 6: Tấm Vé Định Mệnh', 'Một nhóm bạn thân cùng lớn lên ở làng chiếu định mệnh thay đổi khi họ trúng số độc đắc.', 'lat_mat_6.jpg', '2023-04-28', '2023-04-28', 1);

-- --------------------------------------------------------

--
-- Table structure for table `tbl_movie_director`
--

CREATE TABLE `tbl_movie_director` (
  `Movie_ID` int(10) NOT NULL,
  `Director_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_movie_director`
--

INSERT INTO `tbl_movie_director` (`Movie_ID`, `Director_ID`) VALUES
(1, 1),
(2, 1),
(3, 1),
(4, 2),
(5, 8),
(6, 5),
(7, 3),
(8, 7),
(9, 4),
(10, 6),
(21, 11),
(22, 11),
(23, 16),
(24, 12),
(26, 12),
(27, 16),
(28, 13),
(30, 15),
(11, 6),
(12, 1),
(13, 9),
(14, 1),
(15, 9),
(16, 5),
(18, 10),
(19, 3);

-- --------------------------------------------------------

--
-- Table structure for table `tbl_movie_genre`
--

CREATE TABLE `tbl_movie_genre` (
  `Movie_ID` int(10) NOT NULL,
  `Genre_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_movie_genre`
--

INSERT INTO `tbl_movie_genre` (`Movie_ID`, `Genre_ID`) VALUES
(1, 1),
(1, 3),
(1, 10),
(2, 2),
(2, 3),
(2, 4),
(3, 1),
(3, 6),
(3, 4),
(4, 4),
(4, 5),
(5, 1),
(5, 3),
(6, 7),
(6, 8),
(6, 2),
(7, 6),
(7, 4),
(8, 7),
(8, 9),
(8, 8),
(9, 6),
(9, 4),
(10, 1),
(10, 2),
(10, 3),
(21, 4),
(21, 9),
(22, 4),
(22, 9),
(23, 15),
(23, 9),
(23, 4),
(24, 4),
(24, 9),
(25, 1),
(25, 5),
(26, 4),
(26, 12),
(27, 4),
(27, 15),
(28, 4),
(28, 9),
(29, 5),
(29, 4),
(30, 4),
(30, 5),
(11, 5),
(11, 1),
(11, 3),
(12, 4),
(13, 4),
(13, 6),
(14, 1),
(14, 2),
(14, 3),
(15, 1),
(15, 2),
(15, 3),
(16, 5),
(16, 2),
(17, 1),
(17, 2),
(17, 3),
(18, 7),
(18, 4),
(19, 1),
(19, 7),
(20, 1),
(20, 4);

-- --------------------------------------------------------

--
-- Table structure for table `tbl_movie_studio`
--

CREATE TABLE `tbl_movie_studio` (
  `Movie_ID` int(10) NOT NULL,
  `Studio_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_movie_studio`
--

INSERT INTO `tbl_movie_studio` (`Movie_ID`, `Studio_ID`) VALUES
(1, 1),
(2, 2),
(3, 1),
(4, 2),
(5, 1),
(6, 6),
(7, 2),
(10, 3),
(21, 11),
(22, 10),
(24, 8),
(26, 8),
(28, 12),
(30, 9),
(11, 5),
(12, 2),
(13, 4),
(14, 1),
(15, 3),
(16, 6),
(17, 7);

-- --------------------------------------------------------

--
-- Table structure for table `tbl_movie_watchlist`
--

CREATE TABLE `tbl_movie_watchlist` (
  `Movie_ID` int(10) NOT NULL,
  `Watchlist_ID` int(16) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_movie_watchlist`
--

INSERT INTO `tbl_movie_watchlist` (`Movie_ID`, `Watchlist_ID`) VALUES
(1, 6),
(2, 6),
(3, 2),
(5, 6),
(6, 3),
(7, 4),
(9, 4),
(10, 7),
(21, 10),
(22, 1),
(23, 10),
(28, 1),
(16, 3),
(11, 2),
(14, 2),
(15, 2),
(19, 2),
(20, 2),
(11, 6),
(14, 6),
(15, 6),
(17, 6),
(12, 4),
(13, 4),
(18, 4),
(20, 4);

-- --------------------------------------------------------

--
-- Table structure for table `tbl_new`
--

CREATE TABLE `tbl_new` (
  `New_ID` int(10) NOT NULL,
  `New_Title` varchar(225) NOT NULL,
  `New_Description` text DEFAULT NULL,
  `New_Content` text NOT NULL,
  `New_Img` varchar(225) DEFAULT NULL,
  `New_PublishDate` date NOT NULL,
  `New_Status` enum('Under Review','Publish','Banned') NOT NULL DEFAULT 'Under Review',
  `Account_ID` int(10) NOT NULL,
  `New_Category` enum('Actor','Movie') NOT NULL DEFAULT 'Movie'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_new`
--

INSERT INTO `tbl_new` (`New_ID`, `New_Title`, `New_Description`, `New_Content`, `New_Img`, `New_PublishDate`, `New_Status`, `Account_ID`, `New_Category`) VALUES
(1, 'Phim \"Bố Già\" vừa ra mắt mang về doanh thu kỷ lục cho Trấn Thành', 'Sự trở lại ngoạn mục của Trấn Thành với vai trò đạo diễn và diễn viên chính.', 'Nội dung chi tiết về thành công của bộ phim Bố Già...', 'bo_gia_news.jpg', '2026-04-01', 'Publish', 1, 'Movie'),
(2, 'Bom tấn \"Inception\" của Leonardo DiCaprio sắp chiếu lại tại Việt Nam', 'Cơ hội hiếm có để thưởng thức siêu phẩm hack não trên màn ảnh rộng.', 'Chi tiết về lịch chiếu và các cụm rạp tại TP.HCM...', 'inception_news.jpg', '2026-04-02', 'Publish', 3, 'Movie'),
(3, 'Brad Pitt xác nhận tham gia dự án phim hành động mới nhất', 'Nam tài tử sẽ thủ vai chính trong một bộ phim lấy bối cảnh tương lai.', 'Thông tin về kịch bản và quá trình đàm phán hợp đồng...', 'brad_pitt_new_movie.jpg', '2026-04-03', 'Publish', 1, 'Movie'),
(4, 'Hậu trường kỹ xảo triệu đô của phim \"Interstellar\"', 'Khám phá cách Anne Hathaway và đoàn phim thực hiện các cảnh quay không trọng lực.', 'Phỏng vấn đội ngũ thiết kế kỹ xảo về lỗ đen Gargantua...', 'interstellar_vfx.jpg', '2026-04-04', 'Publish', 1, 'Movie'),
(5, 'Meryl Streep gây ấn tượng mạnh trong phim tâm lý mới', 'Tác phẩm được dự đoán sẽ mang về cho bà thêm một tượng vàng Oscar.', 'Đánh giá từ giới chuyên môn tại liên hoan phim Cannes...', 'meryl_streep_news.jpg', '2026-04-05', 'Publish', 1, 'Movie'),
(6, 'Ngô Thanh Vân chia sẻ về khó khăn khi làm phim \"Hai Phượng\"', 'Hành trình đưa điện ảnh Việt ra thị trường quốc tế không hề dễ dàng.', 'Những chấn thương trên trường quay và nỗ lực của ekip...', 'hai_phuong_news.jpg', '2026-04-06', 'Publish', 1, 'Movie'),
(7, 'Top 5 phim kinh dị của Christian Bale bạn không thể bỏ lỡ', 'Từ American Psycho đến những vai diễn biến hóa tâm lý phức tạp.', 'Danh sách và tóm tắt nội dung các phim tiêu biểu...', 'christian_bale_horror.jpg', '2026-04-07', 'Publish', 1, 'Movie'),
(8, 'Denzel Washington tái xuất trong siêu phẩm hành động kịch tính', 'Vị đạo diễn lừng danh nhận xét đây là vai diễn xuất sắc nhất của Denzel.', 'Thông tin về ngày ra mắt và trailer chính thức...', 'denzel_news.jpg', '2026-04-08', 'Publish', 1, 'Movie'),
(9, 'Angelina Jolie xuất hiện lộng lẫy tại buổi ra mắt phim mới', 'Nữ minh tinh thu hút mọi ánh nhìn trên thảm đỏ với phong cách quý phái.', 'Hình ảnh Angelina Jolie giao lưu cùng người hâm mộ...', 'jolie_premier.jpg', '2026-04-09', 'Publish', 3, 'Movie'),
(10, 'Tom Cruise tự thực hiện cảnh nhảy dù trong phim mới nhất', 'Sự liều lĩnh của nam tài tử 60 tuổi khiến cả đoàn phim thán phục.', 'Clip hậu trường cảnh quay nguy hiểm tại vách đá...', 'tom_cruise_stunt.jpg', '2026-04-10', 'Publish', 3, 'Movie'),
(11, 'Natalie Portman và hành trình hóa thân vào vai diễn thiên nga', 'Nữ diễn viên chia sẻ về chế độ tập luyện ballet khắc nghiệt.', 'Những bí mật phía sau hậu trường Black Swan...', 'natalie_portman_news.jpg', '2026-04-11', 'Publish', 1, 'Movie'),
(12, 'Joaquin Phoenix tiết lộ lý do nhận vai Joker lần thứ hai', 'Nam diễn viên muốn khám phá sâu hơn những góc khuất của nhân vật.', 'Phỏng vấn độc quyền về quá trình chuẩn bị tâm lý...', 'joaquin_joker_2.jpg', '2026-04-12', 'Publish', 1, 'Movie'),
(13, 'Trấn Thành vừa quay trở lại sân khấu sau 3 năm nghỉ dưỡng', 'Sự xuất hiện bất ngờ của Trấn Thành khiến fan hâm mộ vỡ òa.', 'Nội dung buổi livestream chia sẻ về cuộc sống hiện tại...', 'tran_thanh_back.jpg', '2026-04-01', 'Publish', 3, 'Actor'),
(14, 'Leonardo DiCaprio tiết lộ chế độ tập luyện để vào vai sinh tồn', 'Để đóng phim của Inarritu, anh đã phải chịu đựng cái lạnh âm độ.', 'Chia sẻ về trải nghiệm thực tế trên phim trường...', 'leo_training.jpg', '2026-04-02', 'Publish', 1, 'Actor'),
(15, 'Cate Blanchett nhận giải thưởng cống hiến trọn đời', 'Gương mặt quyền lực của điện ảnh thế giới được vinh danh tại London.', 'Tiểu sử và danh sách các giải thưởng đồ sộ của bà...', 'cate_blanchett_award.jpg', '2026-04-03', 'Publish', 3, 'Actor'),
(16, 'Keanu Reeves hội ngộ cùng dàn sao tại sự kiện từ thiện', 'Nam tài tử John Wick tiếp tục ghi điểm với vẻ ngoài giản dị.', 'Hình ảnh Keanu Reeves đấu giá vật phẩm cá nhân giúp trẻ em...', 'keanu_charity.jpg', '2026-04-04', 'Publish', 1, 'Actor'),
(17, 'Meryl Streep chia sẻ bí quyết giữ lửa nghề diễn cho đàn em', 'Những bài học quý báu sau hơn nửa thế kỷ đứng trên sân khấu.', 'Ghi chép từ buổi lên lớp tại học viện điện ảnh...', 'meryl_teaching.jpg', '2026-04-05', 'Publish', 3, 'Actor'),
(18, 'Ngô Thanh Vân tìm kiếm gương mặt mới cho dự án phim hành động', '\"Đả nữ\" mong muốn tìm ra người kế vị xứng đáng cho điện ảnh Việt.', 'Tiêu chí tuyển chọn diễn viên và lịch casting...', 'ngo_thanh_van_casting.jpg', '2026-04-06', 'Publish', 1, 'Actor'),
(19, 'Brad Pitt tham gia hoạt động bảo vệ môi trường tại Việt Nam', 'Hành động ý nghĩa của nam tài tử nhận được sự ủng hộ lớn từ cộng đồng.', 'Thông tin về chiến dịch mà anh đang tham gia...', 'brad_pitt_green.jpg', '2026-04-07', 'Publish', 3, 'Actor'),
(20, 'Cặp đôi màn ảnh Tom Cruise và Nicole Kidman một thời giờ ra sao?', 'Nhìn lại hành trình tình yêu và sự nghiệp của hai ngôi sao hạng A.', 'Những hình ảnh kỷ niệm đáng nhớ của cặp đôi...', 'tom_nicole_history.jpg', '2026-04-08', 'Publish', 1, 'Actor'),
(21, 'Nghệ sĩ Trấn Thành tổ chức triển lãm kịch bản cá nhân', 'Khám phá tư duy sáng tạo của anh phía sau những trang bản thảo.', 'Không gian trưng bày các dự án chưa từng công bố...', 'tran_thanh_gallery.jpg', '2026-04-09', 'Publish', 1, 'Actor'),
(22, 'Denzel Washington - Giọng nói truyền cảm hứng nhất Hollywood', 'Tìm hiểu tầm ảnh hưởng của ông qua những bài phát biểu bất hủ.', 'Tổng hợp những câu nói hay nhất của Denzel...', 'denzel_speech.jpg', '2026-04-10', 'Publish', 1, 'Actor'),
(23, 'Sự thay đổi ngoại hình của Christian Bale cho vai diễn Người Dơi', 'Khán giả kinh ngạc trước khả năng tăng giảm cân thần tốc của anh.', 'So sánh hình ảnh qua các thời kỳ đóng phim...', 'bale_transformation.jpg', '2026-04-11', 'Publish', 1, 'Actor'),
(24, 'Joaquin Phoenix lấn sân sang vai trò đạo diễn phim tài liệu', 'Một bước đi mới đầy hứa hẹn của nam diễn viên tài năng.', 'Thông tin về chủ đề môi trường mà anh đang thực hiện...', 'joaquin_director.jpg', '2026-04-12', 'Publish', 1, 'Actor'),
(25, 'Hành trình chinh phục Oscar của Angelina Jolie', 'Từ những vai diễn nổi loạn đến vị thế đạo diễn quyền lực.', 'Phỏng vấn độc quyền về những dự định tương lai...', 'jolie_oscar_way.jpg', '2026-04-13', 'Publish', 1, 'Actor');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_studio`
--

CREATE TABLE `tbl_studio` (
  `Studio_ID` int(10) NOT NULL,
  `Studio_Name` varchar(32) NOT NULL,
  `Studio_Info` varchar(225) DEFAULT NULL,
  `Studio_Social` varchar(225) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_studio`
--

INSERT INTO `tbl_studio` (`Studio_ID`, `Studio_Name`, `Studio_Info`, `Studio_Social`) VALUES
(1, 'Warner Bros.', 'Một trong những hãng phim lớn nhất thế giới, sở hữu bản quyền DC Comics và Harry Potter.', 'https://www.warnerbros.com'),
(2, 'Universal Pictures', 'Hãng phim lâu đời nhất Hoa Kỳ, nổi tiếng với loạt phim Fast & Furious và Jurassic Park.', 'https://www.universalpictures.com'),
(3, 'Walt Disney Studios', 'Đế chế giải trí khổng lồ, sở hữu Marvel, Star Wars và Pixar.', 'https://studios.disney.com'),
(4, 'Paramount Pictures', 'Hãng phim biểu tượng với logo đỉnh núi, đứng sau Mission: Impossible và Top Gun.', 'https://www.paramount.com'),
(5, 'Sony Pictures', 'Sở hữu bản quyền điện ảnh của Spider-Man và nhiều thương hiệu công nghệ lớn.', 'https://www.sonypictures.com'),
(6, 'Studio Ghibli', 'Hãng phim hoạt hình huyền thoại của Nhật Bản do Hayao Miyazaki đồng sáng lập.', 'https://www.ghibli.jp'),
(7, 'A24', 'Hãng phim độc lập hiện đại, nổi tiếng với các tác phẩm nghệ thuật đạt giải Oscar như Everything Everywhere All at Once.', 'https://a24films.com'),
(8, 'Galaxy Studio', 'Một trong những nhà phát hành và sản xuất phim hàng đầu Việt Nam (Mắt Biếc, Tôi Thấy Hoa Vàng...).', 'https://galaxy.com.vn'),
(9, 'HKFilm', 'Hãng phim uy tín với các dự án điện ảnh chất lượng cao và quy mô lớn.', 'https://hkfilm.vn'),
(10, 'CJ HK Entertainment', 'Liên doanh giữa CJ ENM (Hàn Quốc) và HKFilm, đứng sau các bom tấn như Nhà Bà Nữ, Mai.', 'https://cj.hk.entertainment'),
(11, 'Trấn Thành Town', 'Công ty sản xuất phim của nghệ sĩ Trấn Thành, chuyên dòng phim tâm lý xã hội (Bố Già, Nhà Bà Nữ).', 'https://facebook.com/tranthanh.town'),
(12, 'Lý Hải Production', 'Hãng phim gia đình của nghệ sĩ Lý Hải, nổi tiếng với thương hiệu Lật Mặt.', 'https://facebook.com/lyhaiproduction');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_watchlist`
--

CREATE TABLE `tbl_watchlist` (
  `Watchlist_ID` int(16) NOT NULL,
  `Watchlist_Name` varchar(64) NOT NULL,
  `Watchlist_Date` date NOT NULL,
  `Account_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_watchlist`
--

INSERT INTO `tbl_watchlist` (`Watchlist_ID`, `Watchlist_Name`, `Watchlist_Date`, `Account_ID`) VALUES
(1, 'Phim Việt Bán Chạy Nhất 2024', '2026-04-09', 4),
(2, 'Top Phim Hành Động Hollywood', '2026-04-09', 4),
(3, 'Phim Hoạt Hình Ghibli Yêu Thích', '2026-04-09', 2),
(4, 'Kinh Điển Mọi Thời Đại', '2026-04-09', 4),
(5, 'Phim Bộ Hàn Quốc Đang Hot', '2026-04-09', 2),
(6, 'Phim Khoa Học Viễn Tưởng (Sci-Fi)', '2026-04-09', 2),
(7, 'Danh Sách Phim Marvel Cinematic Universe', '2026-04-09', 4),
(8, 'Phim Kinh Dị Cảm Giác Mạnh', '2026-04-09', 2),
(9, 'Phim Tài Liệu Lịch Sử Việt Nam', '2026-04-09', 4),
(10, 'Phim Hài Gia Đình Cuối Tuần', '2026-04-09', 2);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `tbl_account`
--
ALTER TABLE `tbl_account`
  ADD PRIMARY KEY (`Account_ID`);

--
-- Indexes for table `tbl_actor`
--
ALTER TABLE `tbl_actor`
  ADD PRIMARY KEY (`Actor_ID`),
  ADD KEY `FK_Character_ID` (`Character_ID`) USING BTREE;

--
-- Indexes for table `tbl_award`
--
ALTER TABLE `tbl_award`
  ADD PRIMARY KEY (`Award_ID`);

--
-- Indexes for table `tbl_award_actor`
--
ALTER TABLE `tbl_award_actor`
  ADD KEY `FK_Actor_ID` (`Actor_ID`) USING BTREE,
  ADD KEY `FK_Award_ID` (`Award_ID`) USING BTREE;

--
-- Indexes for table `tbl_award_director`
--
ALTER TABLE `tbl_award_director`
  ADD KEY `FK_Director_ID` (`Director_ID`) USING BTREE,
  ADD KEY `FK_Award_ID` (`Award_ID`) USING BTREE;

--
-- Indexes for table `tbl_award_studio`
--
ALTER TABLE `tbl_award_studio`
  ADD KEY `FK_Studio_ID` (`Studio_ID`) USING BTREE,
  ADD KEY `FK_Award_ID` (`Award_ID`) USING BTREE;

--
-- Indexes for table `tbl_character`
--
ALTER TABLE `tbl_character`
  ADD PRIMARY KEY (`Character_ID`),
  ADD KEY `FK_Actor_ID` (`Actor_ID`) USING BTREE,
  ADD KEY `FK_Movie_ID` (`Movie_ID`) USING BTREE;

--
-- Indexes for table `tbl_comment`
--
ALTER TABLE `tbl_comment`
  ADD PRIMARY KEY (`Comment_ID`),
  ADD KEY `FK_New_ID` (`New_ID`) USING BTREE,
  ADD KEY `FK_Account_ID` (`Account_ID`) USING BTREE;

--
-- Indexes for table `tbl_director`
--
ALTER TABLE `tbl_director`
  ADD PRIMARY KEY (`Director_ID`);

--
-- Indexes for table `tbl_feedback`
--
ALTER TABLE `tbl_feedback`
  ADD PRIMARY KEY (`Feedback_ID`),
  ADD KEY `FK_Movie_ID` (`Movie_ID`) USING BTREE,
  ADD KEY `FK_Account_ID` (`Account_ID`) USING BTREE;

--
-- Indexes for table `tbl_genre`
--
ALTER TABLE `tbl_genre`
  ADD PRIMARY KEY (`Genre_ID`);

--
-- Indexes for table `tbl_movie`
--
ALTER TABLE `tbl_movie`
  ADD PRIMARY KEY (`Movie_ID`),
  ADD KEY `FK_Account_ID` (`Account_ID`) USING BTREE;

--
-- Indexes for table `tbl_movie_director`
--
ALTER TABLE `tbl_movie_director`
  ADD KEY `FK_Director_ID` (`Director_ID`) USING BTREE,
  ADD KEY `FK_Movie_ID` (`Movie_ID`) USING BTREE;

--
-- Indexes for table `tbl_movie_genre`
--
ALTER TABLE `tbl_movie_genre`
  ADD KEY `FK_Genre_ID` (`Genre_ID`) USING BTREE,
  ADD KEY `FK_Movie_ID` (`Movie_ID`) USING BTREE;

--
-- Indexes for table `tbl_movie_studio`
--
ALTER TABLE `tbl_movie_studio`
  ADD KEY `FK_Studio_ID` (`Studio_ID`) USING BTREE,
  ADD KEY `FK_Movie_ID` (`Movie_ID`) USING BTREE;

--
-- Indexes for table `tbl_movie_watchlist`
--
ALTER TABLE `tbl_movie_watchlist`
  ADD KEY `FK_Watchlist_ID` (`Watchlist_ID`) USING BTREE,
  ADD KEY `FK_Movie_ID` (`Movie_ID`) USING BTREE;

--
-- Indexes for table `tbl_new`
--
ALTER TABLE `tbl_new`
  ADD PRIMARY KEY (`New_ID`),
  ADD KEY `FK_Account_Name` (`Account_ID`) USING BTREE;

--
-- Indexes for table `tbl_studio`
--
ALTER TABLE `tbl_studio`
  ADD PRIMARY KEY (`Studio_ID`);

--
-- Indexes for table `tbl_watchlist`
--
ALTER TABLE `tbl_watchlist`
  ADD PRIMARY KEY (`Watchlist_ID`),
  ADD KEY `FK_Account_ID` (`Account_ID`) USING BTREE;

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `tbl_account`
--
ALTER TABLE `tbl_account`
  MODIFY `Account_ID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `tbl_actor`
--
ALTER TABLE `tbl_actor`
  MODIFY `Actor_ID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `tbl_award`
--
ALTER TABLE `tbl_award`
  MODIFY `Award_ID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `tbl_character`
--
ALTER TABLE `tbl_character`
  MODIFY `Character_ID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT for table `tbl_comment`
--
ALTER TABLE `tbl_comment`
  MODIFY `Comment_ID` int(16) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `tbl_director`
--
ALTER TABLE `tbl_director`
  MODIFY `Director_ID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `tbl_feedback`
--
ALTER TABLE `tbl_feedback`
  MODIFY `Feedback_ID` int(16) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=76;

--
-- AUTO_INCREMENT for table `tbl_genre`
--
ALTER TABLE `tbl_genre`
  MODIFY `Genre_ID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `tbl_movie`
--
ALTER TABLE `tbl_movie`
  MODIFY `Movie_ID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `tbl_new`
--
ALTER TABLE `tbl_new`
  MODIFY `New_ID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=52;

--
-- AUTO_INCREMENT for table `tbl_studio`
--
ALTER TABLE `tbl_studio`
  MODIFY `Studio_ID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `tbl_watchlist`
--
ALTER TABLE `tbl_watchlist`
  MODIFY `Watchlist_ID` int(16) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `tbl_award_actor`
--
ALTER TABLE `tbl_award_actor`
  ADD CONSTRAINT `fk_aa_actor` FOREIGN KEY (`Actor_ID`) REFERENCES `tbl_actor` (`Actor_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_aa_award` FOREIGN KEY (`Award_ID`) REFERENCES `tbl_award` (`Award_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `tbl_award_director`
--
ALTER TABLE `tbl_award_director`
  ADD CONSTRAINT `fk_ad_award` FOREIGN KEY (`Award_ID`) REFERENCES `tbl_award` (`Award_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_ad_director` FOREIGN KEY (`Director_ID`) REFERENCES `tbl_director` (`Director_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `tbl_award_studio`
--
ALTER TABLE `tbl_award_studio`
  ADD CONSTRAINT `fk_as_award` FOREIGN KEY (`Award_ID`) REFERENCES `tbl_award` (`Award_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_as_studio` FOREIGN KEY (`Studio_ID`) REFERENCES `tbl_studio` (`Studio_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `tbl_character`
--
ALTER TABLE `tbl_character`
  ADD CONSTRAINT `fk_character_actor` FOREIGN KEY (`Actor_ID`) REFERENCES `tbl_actor` (`Actor_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_character_movie` FOREIGN KEY (`Movie_ID`) REFERENCES `tbl_movie` (`Movie_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `tbl_comment`
--
ALTER TABLE `tbl_comment`
  ADD CONSTRAINT `fk_comment_account` FOREIGN KEY (`Account_ID`) REFERENCES `tbl_account` (`Account_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `tbl_feedback`
--
ALTER TABLE `tbl_feedback`
  ADD CONSTRAINT `fk_feedback_account` FOREIGN KEY (`Account_ID`) REFERENCES `tbl_account` (`Account_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_feedback_movie` FOREIGN KEY (`Movie_ID`) REFERENCES `tbl_movie` (`Movie_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `tbl_movie`
--
ALTER TABLE `tbl_movie`
  ADD CONSTRAINT `fk_movie_account` FOREIGN KEY (`Account_ID`) REFERENCES `tbl_account` (`Account_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `tbl_movie_director`
--
ALTER TABLE `tbl_movie_director`
  ADD CONSTRAINT `fk_md_director` FOREIGN KEY (`Director_ID`) REFERENCES `tbl_director` (`Director_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_md_movie` FOREIGN KEY (`Movie_ID`) REFERENCES `tbl_movie` (`Movie_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `tbl_movie_genre`
--
ALTER TABLE `tbl_movie_genre`
  ADD CONSTRAINT `fk_mg_genre` FOREIGN KEY (`Genre_ID`) REFERENCES `tbl_genre` (`Genre_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_mg_movie` FOREIGN KEY (`Movie_ID`) REFERENCES `tbl_movie` (`Movie_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `tbl_movie_studio`
--
ALTER TABLE `tbl_movie_studio`
  ADD CONSTRAINT `fk_ms_movie` FOREIGN KEY (`Movie_ID`) REFERENCES `tbl_movie` (`Movie_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_ms_studio` FOREIGN KEY (`Studio_ID`) REFERENCES `tbl_studio` (`Studio_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `tbl_movie_watchlist`
--
ALTER TABLE `tbl_movie_watchlist`
  ADD CONSTRAINT `fk_wlm_movie` FOREIGN KEY (`Movie_ID`) REFERENCES `tbl_movie` (`Movie_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_wlm_watchlist` FOREIGN KEY (`Watchlist_ID`) REFERENCES `tbl_watchlist` (`Watchlist_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `tbl_new`
--
ALTER TABLE `tbl_new`
  ADD CONSTRAINT `fk_new_account` FOREIGN KEY (`Account_ID`) REFERENCES `tbl_account` (`Account_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `tbl_watchlist`
--
ALTER TABLE `tbl_watchlist`
  ADD CONSTRAINT `fk_watchlist_account` FOREIGN KEY (`Account_ID`) REFERENCES `tbl_account` (`Account_ID`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
