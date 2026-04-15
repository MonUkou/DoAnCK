-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th4 15, 2026 lúc 05:00 PM
-- Phiên bản máy phục vụ: 10.4.32-MariaDB
-- Phiên bản PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Cơ sở dữ liệu: `db_web1`
--

DELIMITER $$
--
-- Thủ tục
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetActorById` (IN `p_actor_id` INT)   BEGIN
    SELECT * 
    FROM tbl_actor 
    WHERE Actor_ID = p_actor_id;
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetActorsPaginated` (IN `p_offset` INT, IN `p_limit` INT)   BEGIN
    SELECT * FROM tbl_actor
    ORDER BY Actor_Name ASC
    LIMIT p_limit OFFSET p_offset;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetActorsWithMovieCount` (IN `p_offset` INT, IN `p_limit` INT)   BEGIN
    SELECT 
        a.*,
        COUNT(c.Movie_ID) AS movie_count
    FROM tbl_actor a
    LEFT JOIN tbl_character c
        ON a.Actor_ID = c.Actor_ID
    GROUP BY a.Actor_ID
    ORDER BY a.Actor_Name ASC
    LIMIT p_limit OFFSET p_offset;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetAllMovies` ()   BEGIN
    SELECT * FROM tbl_movie;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetCommentsByNews` (IN `p_news_id` INT)   BEGIN
    SELECT 
        c.Comment_ID,
        c.Comment_Data,
        c.Comment_Date,
        c.Account_ID,
        c.New_ID,
        a.Username,
        a.Account_img
    FROM tbl_comment c
    JOIN tbl_account a ON c.Account_ID = a.Account_ID
    WHERE c.New_ID = p_news_id
    ORDER BY c.Comment_Date DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetDirectorsByMovie` (IN `p_movie_id` INT)   BEGIN
    SELECT d.Director_ID, d.Director_Name
    FROM tbl_director d
    JOIN tbl_movie_director md ON d.Director_ID = md.Director_ID
    WHERE md.Movie_ID = p_movie_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetGenresByMovie` (IN `p_movie_id` INT)   BEGIN
    SELECT g.Genre_ID, g.Genre_Name
    FROM tbl_genre g
    JOIN tbl_movie_genre mg ON g.Genre_ID = mg.Genre_ID
    WHERE mg.Movie_ID = p_movie_id;
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetLatestNews` (IN `limitNum` INT)   BEGIN
    SELECT *
    FROM tbl_new
    WHERE New_Status = 'Publish'
    ORDER BY New_PublishDate DESC
    LIMIT limitNum;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetMovieCountByActor` (IN `p_actor_id` INT)   BEGIN
    SELECT COUNT(*) AS count
    FROM tbl_character
    WHERE Actor_ID = p_actor_id;
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetMovieFullDetail` (IN `p_movie_id` INT)   BEGIN
    SELECT m.*, 
           a.Username,
           a.Account_img
    FROM tbl_movie m
    LEFT JOIN tbl_account a ON m.Account_ID = a.Account_ID
    WHERE m.Movie_ID = p_movie_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetMoviesByActorWithCount` (IN `actor_id` INT)   BEGIN
    SELECT m.*, 
           (SELECT COUNT(*) FROM tbl_character c2 WHERE c2.Actor_ID = actor_id) as movie_count
    FROM tbl_character c
    JOIN tbl_movie m ON c.Movie_ID = m.Movie_ID
    WHERE c.Actor_ID = actor_id
    ORDER BY m.Movie_ReleaseDate DESC;
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetNewsByCategory` (IN `cat` VARCHAR(50))   BEGIN
    SELECT *
    FROM tbl_new
    WHERE New_Category = cat
      AND New_Status = 'Publish'
    ORDER BY New_PublishDate DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetNewsById` (IN `id` INT)   BEGIN
    SELECT *
    FROM tbl_new
    WHERE New_ID = id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetRelatedNews` (IN `newsId` INT, IN `category` VARCHAR(50), IN `limitNum` INT)   BEGIN
    SELECT *
    FROM tbl_new
    WHERE New_ID != newsId
      AND New_Category = category
      AND New_Status = 'Publish'
    ORDER BY New_PublishDate DESC
    LIMIT limitNum;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetStudiosByMovie` (IN `p_movie_id` INT)   BEGIN
    SELECT s.Studio_ID, s.Studio_Name
    FROM tbl_studio s
    JOIN tbl_movie_studio ms ON s.Studio_ID = ms.Studio_ID
    WHERE ms.Movie_ID = p_movie_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetTotalActors` ()   BEGIN
    SELECT COUNT(*) AS total FROM tbl_actor;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_IncrementNewsView` (IN `id` INT)   BEGIN
    UPDATE tbl_new
    SET New_View = New_View + 1
    WHERE New_ID = id;
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_SearchNews` (IN `keyword` VARCHAR(255))   BEGIN
    SELECT *
    FROM tbl_new
    WHERE New_Title LIKE CONCAT('%', keyword, '%')
       OR New_Content LIKE CONCAT('%', keyword, '%')
    ORDER BY New_PublishDate DESC;
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_UpdateAccount` (IN `p_Account_ID` INT, IN `p_Username` VARCHAR(32), IN `p_Password` VARCHAR(16), IN `p_Mail` VARCHAR(64), IN `p_Tel` INT, IN `p_Account_Img` VARCHAR(225), IN `p_Role` TINYINT)   BEGIN
    UPDATE tbl_account 
    SET
        Username = p_Username,
        Password = p_Password,
        Mail = p_Mail,
        Tel = p_Tel,
        Account_Img = p_Account_Img,
        Role = p_Role
    WHERE Account_ID = p_Account_ID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_UpdateAccountFull` (IN `p_id` INT, IN `p_email` VARCHAR(255), IN `p_tel` VARCHAR(20), IN `p_img` VARCHAR(255))   BEGIN
    UPDATE tbl_account
    SET Mail = p_email,
        Tel = p_tel,
        Account_Img = p_img
    WHERE Account_ID = p_id;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_account`
--

CREATE TABLE `tbl_account` (
  `Account_ID` int(10) NOT NULL,
  `Username` varchar(32) NOT NULL,
  `Password` varchar(32) NOT NULL,
  `Mail` varchar(64) NOT NULL,
  `Tel` int(10) DEFAULT NULL,
  `Account_Img` varchar(225) DEFAULT 'pfp.png',
  `Role` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `tbl_account`
--

INSERT INTO `tbl_account` (`Account_ID`, `Username`, `Password`, `Mail`, `Tel`, `Account_Img`, `Role`) VALUES
(1, 'Mon', 'f385fe3c0b5e58d048de69717f987cc8', 'MonUs@gmail.com', 234567891, 'pfp.png', 1),
(2, 'Hiền', '59d2cd81f877e4b45f3b426faa611e18', 'Hien@gmail.com', NULL, 'pfp.png', 0),
(3, 'Nam', '94ddd8e2d4807e1112d3e95b599d7856', 'Nam@gmail.com', NULL, 'pfp.png', 1),
(4, 'Như', '8ef41977a3cadd0ee7680fc49cf5b5d4', 'Nhu@gmail.com', 1122334457, 'pfp.png', 0),
(5, 'user1', 'c3c2bd601f0ec6a0', 'U1123@gmail.com', 2147483647, 'user1_img.png', 0);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_actor`
--

CREATE TABLE `tbl_actor` (
  `Actor_ID` int(10) NOT NULL,
  `Actor_Name` varchar(64) NOT NULL,
  `Actor_Info` text DEFAULT NULL,
  `Actor_Social` varchar(225) DEFAULT NULL,
  `Character_ID` int(10) DEFAULT NULL,
  `Actor_Img` varchar(225) NOT NULL DEFAULT 'anon.png'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `tbl_actor`
--

INSERT INTO `tbl_actor` (`Actor_ID`, `Actor_Name`, `Actor_Info`, `Actor_Social`, `Character_ID`, `Actor_Img`) VALUES
(1, 'Leonardo DiCaprio', 'Nam diễn viên giành giải Oscar, nổi tiếng với các vai diễn trong Inception và Titanic.', 'https://instagram.com/leonardodicaprio', 1, 'Leonardo DiCaprio.png'),
(2, 'Robert Downey Jr.', 'Nam diễn viên biểu tượng của Marvel với vai diễn Iron Man.', 'https://twitter.com/robertdowneyjr', 2, 'Robert Downey Jr.png'),
(3, 'Scarlett Johansson', 'Nữ diễn viên nổi tiếng với vai Black Widow và nhiều phim nghệ thuật đặc sắc.', 'https://facebook.com/scarlettjohansson', 3, 'Scarlett Johansson.png'),
(4, 'Tom Hardy', 'Diễn viên thực lực người Anh, nổi tiếng với các vai diễn gai góc trong Mad Max và Venom.', 'https://instagram.com/tomhardy', 4, 'Tom Hardy.png'),
(5, 'Emma Watson', 'Nổi tiếng từ loạt phim Harry Potter và là nhà hoạt động xã hội tích cực.', 'https://twitter.com/emmawatson', 5, 'Emma Watson.png'),
(6, 'Brad Pitt', 'Nam diễn viên kỳ cựu, nổi tiếng với Fight Club và Once Upon a Time in Hollywood.', 'https://instagram.com/bradpitt', 6, 'Brad Pitt.png\r\n'),
(7, 'Meryl Streep', 'Được coi là nữ diễn viên xuất sắc nhất thế hệ của mình với kỷ lục đề cử Oscar.', 'https://facebook.com/merylstreep', 7, 'Meryl Streep.png'),
(8, 'Denzel Washington', 'Nam diễn viên và đạo diễn lừng danh với các vai diễn đầy quyền lực.', 'https://twitter.com/denzelw', 8, 'Denzel Washington.png'),
(9, 'Angelina Jolie', 'Nữ diễn viên, đạo diễn và nhà hoạt động nhân đạo nổi tiếng thế giới.', 'https://instagram.com/angelinajolie', 9, 'Angelina Jolie.png'),
(10, 'Tom Cruise', 'Ngôi sao hành động hàng đầu với loạt phim Mission Impossible.', 'https://twitter.com/tomcruise', 10, 'Tom Cruise.png'),
(11, 'Natalie Portman', 'Nữ diễn viên thực lực, nổi tiếng từ vai diễn trong Leon và Black Swan.', 'https://instagram.com/natalieportman', 11, 'Natalie Portman.png'),
(12, 'Joaquin Phoenix', 'Nam diễn viên nổi tiếng với lối diễn xuất nội tâm, đặc biệt là vai Joker.', 'https://facebook.com/joaquinphoenix', 12, 'Joaquin Phoenix.png'),
(13, 'Christian Bale', 'Diễn viên phương pháp (method acting) nổi tiếng với sự thay đổi ngoại hình kinh ngạc.', 'https://twitter.com/christianbale', 13, 'Christian Bale.png'),
(14, 'Cate Blanchett', 'Nữ diễn viên người Úc với khả năng hóa thân đa dạng vào nhiều loại vai.', 'https://instagram.com/cateblanchett', 14, 'Cate Blanchett.png'),
(15, 'Keanu Reeves', 'Nam diễn viên được yêu mến qua loạt phim The Matrix và John Wick.', 'https://twitter.com/keanureeves', 15, 'Keanu Reeves.png'),
(16, 'Trấn Thành', 'Diễn viên, đạo diễn nổi tiếng', 'fb.com/tranthanh', 27, 'tran_thanh.png'),
(17, 'Tuấn Trần', 'Diễn viên trẻ triển vọng', 'fb.com/tuantran', 28, 'tuan_tran.png'),
(18, 'Phương Anh Đào', 'Nữ diễn viên điện ảnh', 'fb.com/pad', 29, 'pad.png'),
(19, 'Hồng Đào', 'Nghệ sĩ hài, kịch gạo cội', 'fb.com/hongdao', 30, 'hong_dao.png'),
(20, 'Miu Lê', 'Ca sĩ, diễn viên', 'fb.com/miule', 31, 'miu_le.png'),
(21, 'Hứa Vĩ Văn', 'Diễn viên, người mẫu', 'fb.com/huavivan', 32, 'hua_vi_van.png'),
(22, 'Trần Nghĩa', 'Diễn viên trẻ', 'fb.com/trannghia', 33, 'tran_nghia.png'),
(23, 'Trúc Anh', 'Nữ diễn viên trẻ', 'fb.com/trucanh', 34, 'truc_anh.png'),
(24, 'Ngô Thanh Vân', 'Đả nữ màn ảnh Việt', 'fb.com/ntv', 35, 'ngo_thanh_van.png'),
(25, 'Phan Thanh Nhiên', 'VĐV leo núi, diễn viên', 'fb.com/ptn', 36, 'phan_thanh_nhien.png'),
(26, 'Thịnh Vinh', 'Diễn viên nhí (trước đây)', 'fb.com/thinhvinh', 37, 'thinh_vinh.png'),
(27, 'Trọng Khang', 'Diễn viên trẻ', 'fb.com/trongkhang', 38, 'trong_khang.png'),
(28, 'Thái Hòa', 'Ông hoàng phòng vé', 'fb.com/thaihoa', 39, 'thai_hoa.png'),
(29, 'Thu Trang', 'Hoa hậu làng hài', 'fb.com/thutrang', 40, 'thu_trang.png'),
(30, 'Thanh Hiền', 'Nghệ sĩ ưu tú', 'fb.com/thanhhien', 41, 'thanh_hien.png'),
(31, 'Trương Minh Cường', 'Diễn viên kỳ cựu', 'fb.com/tmc', 42, 'truong_minh_cuong.png'),
(32, 'Thanh Hằng', 'Siêu mẫu, diễn viên', 'fb.com/thanhhang', 43, 'thanh_hang.png'),
(33, 'Chi Pu', 'Ca sĩ, diễn viên', 'fb.com/chipu', 44, 'chi_pu.png'),
(34, 'Nhã Uyên', 'Biên kịch, diễn viên', 'fb.com/nhauyen', 45, 'nha_uyen.png'),
(35, 'Kiến An', 'Nghệ sĩ gạo cội', 'fb.com/kienan', 46, 'kien_an.png'),
(36, 'Quốc Cường', 'Diễn viên truyền hình', 'fb.com/quoccuong', 47, 'quoc_cuong.png'),
(37, 'Huy Khánh', 'Diễn viên đào hoa', 'fb.com/huykhanh', 48, 'huy_khanh.png');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_award`
--

CREATE TABLE `tbl_award` (
  `Award_ID` int(10) NOT NULL,
  `Award_Name` varchar(64) NOT NULL,
  `Award_Info` text DEFAULT NULL,
  `Award_Date` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `tbl_award`
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
-- Cấu trúc bảng cho bảng `tbl_award_actor`
--

CREATE TABLE `tbl_award_actor` (
  `Award_ID` int(10) NOT NULL,
  `Actor_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `tbl_award_actor`
--

INSERT INTO `tbl_award_actor` (`Award_ID`, `Actor_ID`) VALUES
(3, 1),
(4, 2),
(1, 15),
(6, 6);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_award_director`
--

CREATE TABLE `tbl_award_director` (
  `Award_ID` int(10) NOT NULL,
  `Director_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `tbl_award_director`
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
-- Cấu trúc bảng cho bảng `tbl_award_studio`
--

CREATE TABLE `tbl_award_studio` (
  `Award_ID` int(10) NOT NULL,
  `Studio_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `tbl_award_studio`
--

INSERT INTO `tbl_award_studio` (`Award_ID`, `Studio_ID`) VALUES
(5, 6),
(7, 3),
(10, 7),
(2, 2),
(8, 4);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_character`
--

CREATE TABLE `tbl_character` (
  `Character_ID` int(10) NOT NULL,
  `Character_Name` varchar(32) NOT NULL,
  `Movie_ID` int(10) NOT NULL,
  `Actor_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `tbl_character`
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
(26, 'Commodus', 20, 12),
(27, 'Ba Sang', 21, 1),
(28, 'Quắn', 21, 2),
(29, 'Mai', 22, 3),
(30, 'Bà Đào', 22, 4),
(31, 'Thanh Nga', 23, 5),
(32, 'Mạnh Đức', 23, 6),
(33, 'Ngạn', 24, 7),
(34, 'Hà Lan', 24, 8),
(35, 'Hai Phượng', 25, 9),
(36, 'Cảnh sát Lương', 25, 10),
(37, 'Thiều', 26, 11),
(38, 'Tường', 26, 12),
(39, 'Phan Bất Bình', 27, 13),
(40, 'Quỳnh', 27, 14),
(41, 'Bà Hai', 28, 15),
(42, 'Hai Khôn', 28, 16),
(43, 'Thiên Kim', 29, 17),
(44, 'Bảo Nhi', 29, 18),
(45, 'Xuân Thanh', 30, 19),
(46, 'Ông Toàn', 30, 20),
(47, 'Phương', 31, 21),
(48, 'Lộc', 31, 22),
(49, 'Ba Sang', 21, 16),
(50, 'Quắn', 21, 17),
(51, 'Mai', 22, 18),
(52, 'Bà Đào', 22, 19),
(53, 'Thanh Nga', 23, 20),
(54, 'Mạnh Đức', 23, 21),
(55, 'Ngạn', 24, 22),
(56, 'Hà Lan', 24, 23),
(57, 'Hai Phượng', 25, 24),
(58, 'Cảnh sát Lương', 25, 25),
(59, 'Thiều', 26, 26),
(60, 'Tường', 26, 27),
(61, 'Phan Bất Bình', 27, 28),
(62, 'Quỳnh', 27, 29),
(63, 'Bà Hai', 28, 30),
(64, 'Hai Khôn', 28, 31),
(65, 'Thiên Kim', 29, 32),
(66, 'Bảo Nhi', 29, 33),
(67, 'Xuân Thanh', 30, 34),
(68, 'Ông Toàn', 30, 35),
(69, 'Phương', 31, 36),
(70, 'Lộc', 31, 37);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_comment`
--

CREATE TABLE `tbl_comment` (
  `Comment_ID` int(16) NOT NULL,
  `Comment_Date` date NOT NULL,
  `Comment_Data` text NOT NULL,
  `Account_ID` int(10) NOT NULL,
  `New_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `tbl_comment`
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
(20, '2024-02-03', 'Chắc chắn sẽ mua bản Blu-ray để sưu tầm.', 2, 3),
(21, '2026-04-15', '1', 4, 53),
(22, '2026-04-15', '1111', 4, 53),
(23, '2026-04-15', '1234', 4, 53),
(24, '2026-04-15', '12345', 4, 53),
(25, '2026-04-15', '111', 4, 53),
(26, '2026-04-15', 'haha', 4, 53),
(27, '2026-04-15', 'woww quá hay luôn', 4, 12),
(28, '2026-04-15', '123', 4, 25);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_director`
--

CREATE TABLE `tbl_director` (
  `Director_ID` int(10) NOT NULL,
  `Director_Name` varchar(64) NOT NULL,
  `Director_Info` text DEFAULT NULL,
  `Director_Social` varchar(225) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `tbl_director`
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
-- Cấu trúc bảng cho bảng `tbl_feedback`
--

CREATE TABLE `tbl_feedback` (
  `Feedback_ID` int(16) NOT NULL,
  `Feedback_Date` date NOT NULL,
  `Feedback_Data` text NOT NULL,
  `Account_ID` int(10) NOT NULL,
  `Movie_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `tbl_feedback`
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
-- Cấu trúc bảng cho bảng `tbl_genre`
--

CREATE TABLE `tbl_genre` (
  `Genre_ID` int(10) NOT NULL,
  `Genre_Name` varchar(16) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `tbl_genre`
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
-- Cấu trúc bảng cho bảng `tbl_movie`
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
-- Đang đổ dữ liệu cho bảng `tbl_movie`
--

INSERT INTO `tbl_movie` (`Movie_ID`, `Movie_Title`, `Movie_Description`, `Movie_Img`, `Movie_ReleaseDate`, `Movie_StreamingDate`, `Account_ID`) VALUES
(1, 'Inception', 'A thief who steals corporate secrets through the use of dream-sharing technology.', 'inception.png', '2010-07-16', '2010-12-01', 1),
(2, 'Interstellar', 'A team of explorers travel through a wormhole in space in an attempt to ensure humanity survival.', 'interstellar.png', '2014-11-07', '2015-03-15', 1),
(3, 'The Dark Knight', 'When the menace known as the Joker wreaks havoc and chaos on the people of Gotham.', 'dark_knight.png', '2008-07-18', '2008-11-10', 3),
(4, 'Parasite', 'Greed and class discrimination threaten the newly formed symbiotic relationship.', 'parasite.png', '2019-05-30', '2019-10-11', 1),
(5, 'The Matrix', 'A computer hacker learns from mysterious rebels about the true nature of his reality.', 'matrix.png', '1999-03-31', '1999-09-21', 3),
(6, 'Spirited Away', 'During her family move to the suburbs, a sullen 10-year-old girl wanders into a world ruled by gods.', 'spirited_away.png', '2001-07-20', '2002-03-15', 4),
(7, 'Pulp Fiction', 'The lives of two mob hitmen, a boxer, a gangster and his wife intertwine in four tales.', 'pulp_fiction.png', '1994-10-14', '1995-05-20', 1),
(8, 'Your Name', 'Two strangers find themselves linked in a bizarre way. When a connection forms, will distance be the only thing to keep them apart?', 'your_name.png', '2016-08-26', '2017-01-10', 3),
(9, 'The Godfather', 'An organized crime dynasty aging patriarch transfers control of his clandestine empire to his reluctant son.', 'godfather.png', '1972-03-24', '1972-10-01', 4),
(10, 'Avengers: Endgame', 'After the devastating events of Infinity War, the universe is in ruins.', 'avengers.png', '2019-04-26', '2019-08-15', 1),
(11, 'Spider-Man: Into the Spider-Verse', 'Hành trình của Miles Morales qua đa vũ trụ nhện với phong cách đồ họa độc đáo.', 'spiderman_verse.png', '2018-12-14', '2019-03-19', 1),
(12, 'Oppenheimer', 'Câu chuyện về J. Robert Oppenheimer và dự án Manhattan chế tạo bom nguyên tử.', 'oppenheimer.png', '2023-07-21', '2023-11-21', 1),
(13, 'Titanic', 'Câu chuyện tình yêu định mệnh trên con tàu huyền thoại không may gặp nạn.', 'titanic.png', '1997-12-19', '1998-09-01', 4),
(14, 'Dune: Part Two', 'Paul Atreides hợp lực với Chani và người Fremen để trả thù những kẻ hủy diệt gia đình mình.', 'dune_2.png', '2024-03-01', '2024-05-14', 1),
(15, 'Avatar: The Way of Water', 'Jake Sully và Neytiri phải bảo vệ gia đình và bộ tộc trước mối đe dọa từ loài người.', 'avatar_2.png', '2022-12-16', '2023-03-28', 1),
(16, 'Howl\'s Moving Castle', 'Cô gái trẻ Sophie bị nguyền rủa thành bà lão và bắt đầu hành trình cùng phù thủy Howl.', 'howl_castle.png', '2004-11-20', '2005-03-07', 4),
(17, 'Everything Everywhere All at Once', 'Một phụ nữ nhập cư bị cuốn vào cuộc phiêu lưu điên rồ qua các đa vũ trụ để cứu thế giới.', 'eeaaow.png', '2022-03-25', '2022-06-07', 3),
(18, 'The Irishmen', 'Câu chuyện về một kẻ sát nhân nhìn lại những bí mật mà anh ta đã giữ cho nghiệp đoàn tội phạm.', 'irishman.png', '2019-11-01', '2019-11-27', 1),
(19, 'Kill Bill: Vol. 1', 'Một nữ sát thủ được gọi là Cô dâu thực hiện kế hoạch trả thù những người đã phản bội mình.', 'kill_bill.png', '2003-10-10', '2004-04-13', 1),
(20, 'Gladiator', 'Một vị tướng La Mã bị phản bội và tìm cách trả thù hoàng đế tham nhũng trong đấu trường.', 'gladiator.png', '2000-05-05', '2000-11-21', 3),
(21, 'Bố Già', 'Phim tâm lý tình cảm gia đình lập kỷ lục doanh thu tại Việt Nam.', 'bo_gia.png', '2021-03-12', '2021-06-15', 1),
(22, 'Mai', 'Câu chuyện tình yêu đầy trắc trở của một người phụ nữ làm nghề massage.', 'mai_phim.png', '2024-02-10', '2024-05-20', 1),
(23, 'Em Là Bà Nội Của Anh', 'Một bà lão 70 tuổi bất ngờ được trở lại tuổi 20 rực rỡ.', 'em_la_ba_noi.png', '2015-12-11', '2016-03-01', 1),
(24, 'Mắt Biếc', 'Chuyện tình đơn phương đẫm nước mắt của Ngạn dành cho Hà Lan.', 'mat_biec.png', '2019-12-20', '2020-04-15', 3),
(25, 'Hai Phượng', 'Hành trình nghẹt thở của người mẹ đi tìm đứa con bị bắt cóc.', 'hai_phuong.png', '2019-02-22', '2019-05-22', 3),
(26, 'Tôi Thấy Hoa Vàng Trên Cỏ Xanh', 'Bức tranh làng quê Việt Nam yên bình qua ánh mắt của những đứa trẻ.', 'hoa_vang_co_xanh.png', '2015-10-02', '2016-01-10', 1),
(27, 'Tiệc Trăng Máu', 'Những bí mật kinh hoàng bị hé lộ trong một bữa tiệc tối của nhóm bạn thân.', 'tiec_trang_mau.png', '2020-10-23', '2021-01-30', 1),
(28, 'Lật Mặt 7: Một Điều Ước', 'Phim gia đình lấy nước mắt khán giả về tình mẫu tử thiêng liêng.', 'lat_mat_7.png', '2024-04-26', '2024-08-15', 3),
(29, 'Chị Chị Em Em', 'Cuộc đấu trí và những âm mưu đen tối giữa những người phụ nữ.', 'chi_chi_em_em.png', '2019-12-20', '2020-03-20', 1),
(30, 'Đêm Tối Rực Rỡ', 'Bi kịch bùng nổ trong một đêm tang lễ tại một gia đình miền Nam.', 'dem_toi_ruc_ro.png', '2022-04-08', '2022-07-08', 3),
(31, 'Lật Mặt 6: Tấm Vé Định Mệnh', 'Một nhóm bạn thân cùng lớn lên ở làng chiếu định mệnh thay đổi khi họ trúng số độc đắc.', 'lat_mat_6.png', '2023-04-28', '2023-04-28', 1);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_movie_director`
--

CREATE TABLE `tbl_movie_director` (
  `Movie_ID` int(10) NOT NULL,
  `Director_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `tbl_movie_director`
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
-- Cấu trúc bảng cho bảng `tbl_movie_genre`
--

CREATE TABLE `tbl_movie_genre` (
  `Movie_ID` int(10) NOT NULL,
  `Genre_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `tbl_movie_genre`
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
-- Cấu trúc bảng cho bảng `tbl_movie_studio`
--

CREATE TABLE `tbl_movie_studio` (
  `Movie_ID` int(10) NOT NULL,
  `Studio_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `tbl_movie_studio`
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
-- Cấu trúc bảng cho bảng `tbl_movie_watchlist`
--

CREATE TABLE `tbl_movie_watchlist` (
  `Movie_ID` int(10) NOT NULL,
  `Watchlist_ID` int(16) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `tbl_movie_watchlist`
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
-- Cấu trúc bảng cho bảng `tbl_new`
--

CREATE TABLE `tbl_new` (
  `New_ID` int(10) NOT NULL,
  `New_Title` varchar(225) NOT NULL,
  `New_Description` text DEFAULT NULL,
  `New_Content` text NOT NULL,
  `New_Img` varchar(225) DEFAULT NULL,
  `New_PublishDate` date NOT NULL,
  `New_Status` enum('Under Review','Publish','Banned') NOT NULL DEFAULT 'Under Review',
  `New_View` int(11) DEFAULT 0,
  `Account_ID` int(10) NOT NULL,
  `New_Category` enum('Actor','Movie') NOT NULL DEFAULT 'Movie'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `tbl_new`
--

INSERT INTO `tbl_new` (`New_ID`, `New_Title`, `New_Description`, `New_Content`, `New_Img`, `New_PublishDate`, `New_Status`, `New_View`, `Account_ID`, `New_Category`) VALUES
(1, 'Phim \"Bố Già\" vừa ra mắt mang về doanh thu kỷ lục cho Trấn Thành', 'Sự trở lại ngoạn mục của Trấn Thành với vai trò đạo diễn và diễn viên chính.', 'Nội dung chi tiết về thành công của bộ phim Bố Già \r\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Ut varius, risus ut condimentum mattis, leo nibh aliquet turpis, eleifend tincidunt quam urna a metus. Proin id velit dui. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Suspendisse finibus eleifend felis, nec mollis dolor ullamcorper sed. Praesent maximus dictum purus vel luctus. Nullam tincidunt tristique sem congue malesuada. Cras quis ultrices tortor, vitae iaculis dolor.\r\n\r\nInteger bibendum maximus odio, eu viverra dui convallis non. Nam vehicula nulla id scelerisque bibendum. Integer scelerisque pharetra tempus. Mauris eget viverra eros, quis porttitor lectus. Phasellus quis nibh quis dui pulvinar cursus. Nullam et mattis enim, sed ornare ipsum. Aliquam at justo at leo bibendum faucibus. Donec lacinia elit vel quam faucibus malesuada. Quisque ut aliquet arcu. Vivamus malesuada semper sollicitudin. Sed ut tempus magna. Donec maximus felis augue, sit amet aliquet mauris ultricies nec.\r\n\r\nMauris vitae erat in tellus sodales pharetra vitae eget tellus. Cras erat mauris, aliquam vulputate mi non, tempor eleifend enim. Nulla vitae sollicitudin elit, ac commodo arcu. Morbi mi est, gravida commodo ornare et, ultricies eget dolor. Nulla facilisi. Donec cursus, risus a viverra interdum, orci lectus fermentum nulla, in mollis erat tellus eget dui. Etiam finibus ut dui sit amet tincidunt. Fusce varius bibendum lectus, sed dictum turpis ultrices iaculis.', 'bo_gia_news.png', '2026-04-01', 'Publish', 0, 1, 'Movie'),
(2, 'Bom tấn \"Inception\" của Leonardo DiCaprio sắp chiếu lại tại Việt Nam', 'Cơ hội hiếm có để thưởng thức siêu phẩm hack não trên màn ảnh rộng.', 'Bom tấn \"Inception\" được chiếu tại các cụm rạp Việt Nam từ 21/8 nhân kỷ niệm 10 năm phát hành.\r\n\r\nTác phẩm thuộc thể loại hành động viễn tưởng của đạo diễn Christopher Nolan từng thu 824 triệu USD toàn cầu, đoạt bốn giải Oscar trên tám đề cử. Các buổi chiếu cũng tiết lộ một đoạn ngắn của Tenet, phim mới nhất của Nolan phát hành ngày 28/8.\r\n\r\nInception xoay quanh Cobb (Leo DiCaprio thủ vai) - chuyên gia trộm thông tin bằng cách đột nhập vào giấc mơ của mục tiêu - bị truy nã và không thể về Mỹ gặp gia đình. Một ông trùm người châu Á đề nghị anh thực hiện phi vụ đặc biệt, đổi lấy sự xóa tội. Thay vì trộm thông tin, Cobb phải gieo ý tưởng mới vào trí óc một doanh nhân, thao túng anh này hủy bỏ cơ nghiệp do người cha mới qua đời để lại.\r\n\r\nTheo Hollywood Reporter, tác phẩm vẫn thu hút khán giả sau 10 năm. Người hâm mộ nhiều năm qua vẫn tranh luận về những câu hỏi được đặt ra suốt bộ phim. Nhất là cảnh kết mang nhiều tính gợi mở khi nhân vật Cobb dùng con quay để phân biệt giữa giấc mơ và thực tại. Người hâm mộ vẫn tranh cãi trên các diễn đàn về điện ảnh suốt thập kỷ qua.\r\n\r\nNgoài Leonardo DiCaprio, phim quy tạo dàn sao: diễn viên gạo cội Michael Caine, \"Venom\" Tom Hardy, Cillian Murphy, Joseph Gordon-Levitt hay minh tinh người Pháp Marion Cotillard.', 'inception_news.png', '2026-04-02', 'Publish', 1, 3, 'Movie'),
(3, 'Brad Pitt xác nhận tham gia dự án phim hành động mới nhất', 'Nam tài tử sẽ thủ vai chính trong một bộ phim lấy bối cảnh tương lai.', 'The Riders is David Kajganich’s adaptation of Tim Winton’s novel of the same name about an Australian man who decides to buy an old farmhouse in Ireland. When his wife and daughter are due to arrive from Australia to meet him, only his daughter turns up, triggering a frantic hunt for his wife across Europe.\r\n\r\nIt is being produced by Scott Free, Berger’s Nine Hours, Pitt’s Plan B and Kajganich. A24 is financing and handling worldwide distribution of the film.\r\n\r\nFurther cast includes Coco Greenstone,  Michael Smiley, Danny Huston, and Ulrich Thomsen.\r\n\r\nScreen has contacted A24 for comment.', 'brad_pitt_new_movie.png', '2026-04-03', 'Publish', 0, 1, 'Movie'),
(4, 'Hậu trường kỹ xảo triệu đô của phim \"Interstellar\"', 'Khám phá cách Anne Hathaway và đoàn phim thực hiện các cảnh quay không trọng lực.', '\"Interstellar\" của C.Nolan gây xúc động nhờ câu chuyện tình cha con lồng yếu tố giả tưởng, thu hút khán giả sau hơn 10 năm.\r\n\r\nPhim ra mắt ở định dạng IMAX tại Hà Nội và TP HCM ngày 28/2, đến nay đạt 30 tỷ đồng sau gần một tháng, theo thống kê của đơn vị quan sát phòng vé độc lập Box Office Vietnam. Suốt ba tuần phát hành, nhiều suất chiếu kín chỗ đặt trước, kể cả những hàng ghế gần màn hình - hiện tượng ít gặp đối với các dự án kinh điển được chiếu lại.\r\n\r\nNhiều khán giả nói háo hức được xem Interstellar lần đầu ở định dạng IMAX. Là sinh viên theo chuyên ngành toán học, khán giả Anh Khoa, 21 tuổi, cho biết các thông tin và nguyên lý khoa học được thể hiện trong phim có sự thuyết phục. \"Christopher Nolan xây dựng thế giới phim bằng lập luận logic, giữ chân người xem nhờ âm nhạc phim và kỹ xảo\", anh nói.\r\n\r\nSau 11 năm, phim vẫn là lựa chọn của nhiều người yêu điện ảnh nhờ cốt truyện mang tính triết lý, cảnh quay hoành tráng và diễn xuất ấn tượng. Phim có nhiều nút thắt, nút mở với những khoảnh khắc gây bất ngờ. Trong đó, mối quan hệ giữa Cooper và con gái Murph là một trong những yếu tố cốt lõi. Sự gắn kết tình cảm giữa họ vượt qua không gian và thời gian, thể hiện qua những tin nhắn nam chính gửi về từ không gian. Còn Murph lớn lên với nỗi nhớ cha, trở thành nhà khoa học tài năng, đóng vai trò quan trọng trong việc giải cứu nhân loại.\r\n\r\nTheo giới chuyên môn, nhân vật Cooper được đánh giá là một trong những vai diễn ấn tượng nhất trong sự nghiệp của tài tử Matthew McConaughey. Cảnh kinh điển trong phim là lúc nhân vật Cooper khóc khi xem đoạn phim của con gái. Theo The Ringer, phân đoạn này thành công sau lần bấm máy đầu tiên.\r\n\r\nTrong nhiều bom tấn của Nolan, Interstellar được đánh giá là tác phẩm dễ cảm nhận nhất. Nhà làm phim nổi tiếng với sự tỉ mỉ trong xây dựng các giả thuyết khoa học. Nhiều chuyên trang nhận định Nolan thể hiện tham vọng với đề tài du hành không gian, đưa ra vô số những giả thuyết về vũ trụ, cùng nhiều thuật ngữ chuyên môn về ngành vật lý, lượng tử. Êkíp được Kip Thorne, chủ nhân Nobel Vật lý 2017, cố vấn khoa học. Tháng 11/2024, ông ra mắt sách The Science of Interstellar, giải thích các khái niệm khoa học đằng sau các ý tưởng vũ trụ học của bộ phim.\r\n\r\nHiệu ứng kỹ xảo tạo cảm giác chân thực, chinh phục người xem bằng những khung hình sống động. Theo Space, giám sát hiệu ứng Paul Franklin tham vọng tái hiện một bức tranh sử thi không gian lên màn ảnh. Mỗi khung hình của chiếc hố đen mất khoảng 100 giờ để kết xuất cho phù hợp với hiệu ứng của \"thấu kính hấp dẫn\" mà nhà vật lý Albert Einstein từng đề cập trong Thuyết tương đối tổng quát.\r\n\r\nTrên IndieWire, Roger Deakins - đạo diễn The Shawshank Redemption - đánh giá đoạn mở đầu của Interstellar là một trong những trường đoạn hay nhất điện ảnh những năm qua. Ông gửi lời khen đến Hoyte van Hoytema, đạo diễn hình ảnh của bộ phim.\"Phân cảnh mở đầu trên cánh đồng ngô được thực hiện xuất sắc\", Deakins nói.\r\n\r\nPhần âm nhạc là điểm sáng khác của bộ phim. Theo Vulture, bản nhạc nền kinh điển do Hans Zimmer thực hiện được tạo ra sau khi Nolan gợi ý. Do từng cộng tác cùng nhau qua nhiều dự án lớn, đạo diễn gửi cho anh một mẩu giấy nhỏ ghi câu chuyện ngắn về dự án, nói Zimmer hãy sáng tác bất cứ điều gì anh nghĩ ra. Từ lần đầu nhạc sĩ gửi bản dựng, Nolan phấn khích vì nhạc phẩm trùng hợp với hình dung của ông.\r\n\r\nPhim công chiếu lần đầu năm 2014, lấy bối cảnh tương lai khi môi trường trái đất trở nên suy thoái. Các nhà khoa học nghiên cứu về việc di cư lên một hành tinh mới thông qua hố đen vũ trụ xuất hiện ngoài không gian. Quá trình tìm nơi ở mới của nhóm phi hành gia do Cooper dẫn đầu, đi xuyên không gian đến dải ngân hà khác. Dự án giành nhiều giải thưởng, trong đó có Hiệu ứng hình ảnh xuất sắc Oscar 2015.\r\n\r\nCuối năm ngoái, dự án ra rạp ở một số quốc gia và vùng lãnh thổ. Tại Bắc Mỹ, dự án đạt năm triệu USD trong tuần đầu tiên, khiến hãng phim quyết định kéo dài thời gian phát hành do nhu cầu cao từ khán giả. Theo Box Office Mojo, tác phẩm thu hơn 37 triệu USD toàn cầu trong năm 2024.\r\n\r\nNam chính McConaughey và đạo diễn Christopher Nolan. Ảnh: MovieWeb/Warner Bros.\r\nNam chính Matthew McConaughey và đạo diễn Christopher Nolan. Ảnh: MovieWeb/Warner Bros.\r\n\r\nChristopher Nolan, 55 tuổi, là đạo diễn Mỹ gốc Anh, làm phim từ năm 1998 và gây tiếng vang với Memento (2000). Trong sự nghiệp, Nolan nhận hàng loạt giải thưởng danh giá, được tạp chí Time xếp vào danh sách 100 người ảnh hưởng nhất thế giới năm 2015, 2019. Hôm 18/12, vợ chồng đạo diễn được Vua Charles III phong tước hiệp sĩ vì có nhiều đóng góp cho điện ảnh. Hiện ông thực hiện dự án The Odyssey - phim sử thi lấy cảm hứng từ trường ca của Homer, có tài tử Matt Damon đóng chính.\r\n\r\n', 'interstellar_vfx.png', '2026-04-04', 'Publish', 0, 1, 'Movie'),
(5, 'Meryl Streep gây ấn tượng mạnh trong phim tâm lý mới', 'Tác phẩm được dự đoán sẽ mang về cho bà thêm một tượng vàng Oscar.', 'Theo People, nữ diễn viên gạo cội vẫn giữ nguyên phong thái và vẻ ngoài quen thuộc của tổng biên tập Miranda Priestly, biểu tượng từng làm mưa làm gió trong phần phim đầu tiên gần 20 năm trước.\r\n\r\nMeryl Streep, nay 76 tuổi và từng 3 lần giành giải Oscar, xuất hiện với mái tóc trắng ngắn đặc trưng của Miranda, kết hợp cùng trang phục thời thượng: áo trench coat màu kaki, chân váy bút chì nâu có đai thắt eo và áo blouse tím cổ chữ V.\r\n\r\nBà hoàn thiện tổng thể bằng đôi giày cao gót đồng điệu, kính râm đen và khuyên tai vàng đơn giản khi bước đi giữa đường phố khu Midtown sầm uất, gần khu vực đặt trailer quay phim.\r\n\r\nMeryl Streep từng thừa nhận không thích quay The Devil Wears Prada\r\nPhần tiếp theo của The Devil Wears Prada - phim ra mắt năm 2006 với sự tham gia của Meryl Streep, Anne Hathaway, Stanley Tucci và Emily Blunt - được xác nhận sản xuất vào tháng 7-2024. \r\n\r\nNhiều gương mặt gạo cội của phần đầu sẽ tái xuất trong phần mới, đưa khán giả trở lại thế giới báo chí thời trang hào nhoáng nhưng đã thay đổi đáng kể theo năm tháng.\r\n\r\nDựa trên tiểu thuyết cùng tên của Lauren Weisberger, phần đầu kể về Andy Sachs (do Anne Hathaway thủ vai), một sinh viên mới ra trường khao khát làm báo.\r\n\r\nCô nhận công việc trợ lý cho Miranda Priestly - tổng biên tập khét tiếng của tạp chí hư cấu Runway. Trong suốt phim, Andy Sachs phải vật lộn để đáp ứng những yêu cầu khắc nghiệt trong công việc, đồng thời duy trì mối quan hệ với bạn trai và đồng nghiệp - Emily (Blunt) và Nigel (Tucci).\r\n\r\nVào năm 2021, Meryl Streep từng thừa nhận rằng bà không hề thích quá trình quay The Devil Wears Prada vì phải “nhập vai quá sâu” vào nhân vật lạnh lùng Miranda Priestly - người được cho là lấy cảm hứng từ tổng biên tập quyền lực của Vogue, Anna Wintour.\r\n\r\nMeryl Streep cũng được bắt gặp cầm theo một chiếc bình nước lấp lánh đính đá \r\n\r\n“Thật kinh khủng! Tôi đã rất khổ sở trong chiếc trailer của mình. Tôi nghe thấy mọi người bên ngoài đang vui vẻ, cười nói rôm rả. Còn tôi thì hoàn toàn chán nản. Tôi đã tự nhủ: ‘Đó là cái giá phải trả khi làm sếp!’ Và đó cũng là lần cuối cùng tôi thử đóng kiểu diễn xuất phương pháp\" - bà chia sẻ với Entertainment Weekly.\r\n\r\nNữ diễn viên kỳ cựu cũng nói thêm rằng bà không hề có ý định thể hiện chân dung Anna Wintour ngoài đời thật, mà quan tâm nhiều hơn đến vai trò và sức nặng vị trí của bà ấy trong công ty: “Tôi muốn thể hiện những gánh nặng mà bà ấy phải gánh vác, bên cạnh việc ngày nào cũng phải xuất hiện thật chỉn chu\".\r\n\r\nMeryl Streep - Ảnh 4.\r\nMeryl Streep trong The Devil Wears Prada và tổng biên tập Vogue Anna Wintour - Ảnh: Shutterstock\r\n\r\nSự xuất hiện của Meryl Streep trên phim trường diễn ra chỉ hai ngày sau khi Anne Hathaway \"nhá hàng\" rằng quá trình quay The Devil Wears Prada 2 chính thức bắt đầu.\r\n\r\nChi tiết nội dung phần 2 vẫn giữ kín, nên khán giả hiện chưa rõ Andy Sachs sẽ làm gì sau gần hai thập kỷ kể từ khi cô rời Runway để chuyển sang làm việc tại một tờ báo lớn ở New York.', 'meryl_streep_news.png', '2026-04-05', 'Publish', 0, 1, 'Movie'),
(6, 'Ngô Thanh Vân chia sẻ về khó khăn khi làm phim \"Hai Phượng\"', 'Hành trình đưa điện ảnh Việt ra thị trường quốc tế không hề dễ dàng.', 'Đả nữ đấu tay đôi Phạm Anh Khoa trong tác phẩm hành động do êkíp Pháp biên đạo võ thuật.\r\n\r\nHai Phượng kể về người mẹ xuất thân giang hồ đi tìm con gái bị bắt cóc. Cô phải đương đầu với băng xã hội đen trong hành trình từ miền Tây lên TP HCM, rồi bám theo đoàn tàu chở con mình. Nữ chính Ngô Thanh Vân có nền tảng thể lực, võ thuật từ khi đóng Bright (2017) cùng Will Smith. Dù vậy, cô phải trải qua chế độ tập luyện nặng cho phim mới. Ngoài ra, cô chia sẻ tuổi tác là trở ngại trong lần nhập vai này. Khoảnh khắc tệ nhất với Ngô Thanh Vân là chấn thương lúc lao mình lên ghe, khiến cả đoàn thiệt hại vài trăm triệu đồng mỗi ngày do ngưng quay.\r\n\r\nHậu trường hành động của Ngô Thanh Vân, Phan Thanh Nhiên, Phạm Anh Khoa trong \"Hai Phượng\"  \r\nHậu trường hành động của \"Hai Phượng\".\r\n\r\nĐạo diễn hành động của Hai Phượng là Yannick Ben - diễn viên đóng thế và chuyên gia võ thuật của nhiều phim Hollywood như Ghost in the Shell, Dunkirk. Biên đạo võ thuật là Kefi Abrikh Samuel, từng là cascadeur trong Dunkirk, Mission: Impossible 6. Để chuẩn bị dự án, Ben và Kefi nghĩ ra các bài đánh rồi dựng trên Previz - một ứng dụng để giả lập cảnh quay, giúp nhà làm phim tính toán về diễn biến và camera trước khi ra hiện trường. Đạo diễn Lê Văn Kiệt phối hợp cùng họ để có những mối chuyển hợp lý từ cảnh tâm lý sang hành động.\r\n\r\nCó bảy màn chiến đấu lớn trong phim. Êkíp muốn trong từng trận đánh đều có một động tác đặc biệt. Ở cao trào - khi Hai Phượng đấu kẻ phản diện chính, điểm nhấn là pha ra đòn liên hoàn của Ngô Thanh Vân. Đòn thế này được quay bổ sung chứ không có trong kịch bản ban đầu. Một cảnh khó khác là trận đánh được quay với chỉ một cú máy - khi Hai Phượng hạ đám giang hồ. Êkíp mất nửa tháng chỉ để tập cảnh này.\r\n\r\nPhan Thanh Nhiên và Phạm Anh Khoa là hai sao nam có nhiều pha chiến đấu trong phim. Phan Thanh Nhiên - người Việt trẻ nhất chinh phục đỉnh Everest - đóng cảnh sát Lương. Dù có thể lực nhờ chơi thể thao mạo hiểm, anh chưa tập võ nhiều. Thanh Nhiên mất hai tháng rèn luyện trước khi quay. Trích đoạn ấn tượng nhất của anh là đấu với nhóm giang hồ trong toa tàu. Còn Phạm Anh Khoa đọ sức Ngô Thanh Vân ở tiệm sửa xe - nơi chứa nhiều vật dụng có khả năng sát thương cao. Địa điểm này khiến trận chiến thêm kịch tính do các nhân vật liên tục thay đổi vũ khí.', 'hai_phuong_news.png', '2026-04-06', 'Publish', 0, 1, 'Movie'),
(7, 'Top 5 phim kinh dị của Christian Bale bạn không thể bỏ lỡ', 'Từ American Psycho đến những vai diễn biến hóa tâm lý phức tạp.', 'Christian Bale là gương mặt trang bìa của tờ GQ trong số tháng 11 sắp ra mắt. Nhân dịp này, tạp chí điểm lại 10 dự án tiêu biểu nhất trong sự nghiệp của anh. Số một là vai siêu anh hùng Batman trong loạt phim của đạo diễn Christopher Nolan.\r\n\r\n\"The Dark Knight\" (2008): Bale hóa thân Bruce Wayne từ công tử trẻ tuổi đến hiệp sĩ giấu mặt chuyên trừng phạt lũ tội phạm tại Gotham. Trong phần đầu, anh toát lên vẻ quyến rũ và quyền quý của người thừa kế nhà Wayne. Phần hai, nhân vật trở nên khéo léo, tinh quái. Đến tập cuối, Batman của Bale lộ những mệt mỏi, tổn thương sau nhiều năm làm siêu anh hùng.\r\n\r\nTrong đó, phần hai \"The Dark Knight\" được đánh giá cao hơn cả. Bale thể hiện nhân vật bên cạnh đồng nghiệp Heath Ledger - người có màn hóa thân phản diện Joker nhận giải Oscar.\r\n\r\n\"American Psycho\" (2000): Vai doanh nhân biến thái Patrick Bateman là dự án định hình sự nghiệp của Christian Bale. Màn thể hiện của ngôi sao sinh năm 1974 được GQ nhận xét vừa quyến rũ vừa điên rồ. Nhân vật có nhiều phân cảnh ấn tượng như cầm cưa máy truy đuổi cô gái bán hoa mới quen hay dùng rìu tấn công đồng nghiệp.\r\n\r\nBộ phim ghi dấu ấn tại Hollywood, truyền cảm hứng cho nhiều bom tấn như \"The Wolf of Wall Street\", \"The Dark Knight\"... Nhân vật Bateman của Bale thường xuyên được xếp vào danh sách các ác nhân, phản anh hùng nổi tiếng nhất lịch sử điện ảnh.\r\n\r\n\"The Fighter\" (2010): Bộ phim của đạo diễn David O Russell lấy cảm hứng từ cuộc đời vận động viên quyền Anh Micky Ward (Mark Wahlberg đóng). Tuy nhiên, màn hóa thân anh trai kiêm huấn luyện viên nghiện ngập Dicky Eklund (phải) của Bale là điểm sáng nhất của dự án. Tài tử tỏa sáng mỗi khi xuất hiện trên màn ảnh và nhận giải Oscar nam phụ nhờ vai diễn.\r\n\r\n\"Vice\" (2018): Bale trải qua quá trình biến đổi ngoại hình khắc nghiệt, tăng 40 kg để vào vai Phó Tổng thống Mỹ Dick Cheney (trái). Vai diễn giúp anh nhận đề cử Oscar và thắng giải nam chính tại Quả Cầu Vàng.\r\n\r\n\"The Machinist\" (2004): Bộ phim mang đến một màn biến đổi ngoại hình của \"tắc kè hoa\" Christian Bale. Anh giảm hơn 28 kg để vào vai Trevor Reznik - một người thường xuyên bị mất ngủ. Bale gợi sự cảm thông từ khán giả với một nhân vật tách biệt khỏi xã hội.\r\n\r\n\"Ford v Ferrari\" (2019): Bale đóng tay đua nổi tiếng Ken Miles. Nhân vật có niềm đam mê bất tận với các loại ôtô và dường như không quan tâm đến những thứ khác. Tài tử thể hiện vai diễn với nhiều sắc thái, từ kẻ lập dị cứng đầu cho đến một con người sống hết mình với tình yêu tốc độ. Vai diễn cũng giúp anh có một đề cử nam chính Quả Cầu Vàng.\r\n\r\n\"Hostiles\" (2017): Bale vào vai quân nhân Joseph Blocker (giữa) từng tham gia cuộc chiến với người da đỏ tại Mỹ. Nhân vật sắp giải ngũ nhưng vẫn giữ nguyên lòng trung thành với các mệnh lệnh. Nhiệm vụ của Blocker lần này là hộ tống một tù trưởng da đỏ mắc ung thư trở về nhà. Hành trình giúp Blocker rút ra nhiều bài học mới về cuộc đời.\r\n\r\n\"I’m Not There\" (2007): Bộ phim lấy cảm hứng từ danh ca Bob Dylan, kể các câu chuyện khác nhau về sáu nhân vật tượng trưng cho một tính cách của danh ca. Bale vào vai Jack Rollins - một ca sĩ nhạc dân gian trong thập niên 1960 nổi tiếng với các ca khúc phản chiến.\r\n\r\n\"Terminator Salvation\" (2009): Khi đang thành công với loạt phim về Batman, Bale nhận lời tham dự một bom tấn hành động, vào vai John Connor chống lại lũ robot đe dọa Trái Đất. Dự án thể hiện một hình rất khác của anh, xả thân trong bùn lầy và thực hiện các phân đoạn hành động thay vì diễn các cảnh tâm lý.\r\n\r\n\"Out of the Furnace\" (2013): Bale vào vai Russell Baze - một công nhân gặp nhiều điều thiếu may mắn và phải ngồi tù. Sau khi lĩnh án, anh trở lại quê nhà và cố gắng làm lại cuộc đời. Tuy nhiên, anh tiếp tục vướng nhiều hoạt động liên quan đến tội phạm.', 'christian_bale_horror.png', '2026-04-07', 'Publish', 0, 1, 'Movie'),
(8, 'Denzel Washington tái xuất trong siêu phẩm hành động kịch tính', 'Vị đạo diễn lừng danh nhận xét đây là vai diễn xuất sắc nhất của Denzel.', 'Đừng bỏ lỡ “Avengers: Doomsday” - Siêu phẩm điện ảnh đánh dấu bước ngoặt vĩ đại của vũ trụ Marvel (MCU) với sự trở lại gây chấn động của nam diễn viên Robert Downey Jr. trong một vai trò hoàn toàn mới.\r\n\r\nCùng VNPAY khám phá thông tin mới nhất về dàn diễn viên, cốt truyện và “Avengers: Doomsday” preview trong bài viết dưới đây.\r\n\r\n1. “Avengers: Doomsday” chuẩn bị khuấy đảo phòng vé toàn cầu cuối năm 2026\r\nSau một thời gian dài chờ đợi và những thay đổi quan trọng trong kế hoạch sản xuất, Marvel Studios đã chính thức đưa thương hiệu Avengers trở lại với phần phim thứ 5 mang tên “Doomsday”. Dưới đây là những điểm nhấn không thể bỏ qua:\r\n\r\nSự trở lại của huyền thoại: Tại sự kiện San Diego Comic-Con 2024, Marvel đã gây bão toàn cầu khi xác nhận Robert Downey Jr. sẽ trở lại MCU. Tuy nhiên, thay vì mặc bộ giáp Iron Man hiện đại, ông sẽ hóa thân thành siêu phản diện nguy hiểm bậc nhất là Victor von Doom (hay Doctor Doom).\r\nNội dung sơ lược: “Avengers: Doomsday” 2026 sẽ tập trung vào sự trỗi dậy của Doctor Doom - một thiên tài với tham vọng thống trị thực tại. Bộ phim được kỳ vọng sẽ kết nối các dòng thời gian trong Đa vũ trụ, tạo tiền đề trực tiếp cho sự kiện khổng lồ “Avengers: Secret Wars” (2027) diễn ra sau đó.\r\nDàn nhân vật quy tụ: Bên cạnh Doctor Doom, phim dự kiến có sự góp mặt của nhóm Fantastic Four (Bộ tứ siêu đẳng), Thunderbolts (Biệt đội sấm sét) và những anh hùng quen thuộc như Spider-Man (Người Nhện) hay Captain America. Sự kết hợp giữa các thế hệ anh hùng hứa hẹn tạo nên những pha hành động mãn nhãn.\r\nĐội ngũ đạo diễn danh tiếng: Phim đánh dấu sự trở lại của anh em nhà Russo (Anthony và Joe Russo) - những người đã nhào nặn nên thành công của “Infinity War” và “Endgame”, đảm bảo chất lượng cho một bom tấn tầm cỡ.\r\nMột số thông tin “bên lề” thú vị dành riêng cho fan cứng của Marvel:\r\n\r\nNăm 2026 đánh dấu một cuộc đối đầu lịch sử tại phòng vé khi hai bom tấn - “Avengers: Doomsday” và “Dune 3” dự kiến ra mắt sát nút nhau, tạo nên một cuộc chiến \"vô tiền khoáng hậu\" giữa hai thương hiệu điện ảnh lớn nhất hiện nay.\r\nDự án này ban đầu có tên là “Avengers: The Kang Dynasty”, nhưng sau những rắc rối pháp lý của nam diễn viên Jonathan Majors, Marvel đã quyết định thay đổi hoàn toàn kịch bản và trọng tâm sang Doctor Doom.\r\nĐể nhận được cái gật đầu từ Robert Downey Jr. và anh em nhà Russo, Marvel Studios được cho là đã chi ra con số lên đến 80 - 100 triệu USD cho mỗi bên. Riêng Robert Downey Jr. còn kèm theo các đặc quyền như di chuyển bằng chuyên cơ riêng và đội ngũ an ninh nghiêm ngặt nhất từ trước đến nay.\r\nChủ tịch Kevin Feige xác nhận phim “Bộ tứ siêu đẳng: Bước đi đầu tiên” (2025) sẽ là bước đệm trực tiếp dẫn dắt khán giả đến với sự kiện trong “Avengers: Doomsday”. Sự xuất hiện của nhóm Fantastic Four được kỳ vọng là chìa khóa để giải mã nguồn gốc của Doctor Doom trong Đa vũ trụ.\r\nPhim được đồn đoán sẽ là màn hội ngộ khổng lồ của các nhân vật từ vũ trụ X-Men của Fox cũng như các phiên bản Người Nhện cũ (Tobey Maguire, Andrew Garfield) để cùng hợp sức chống lại sự xâm lấn Đa vũ trụ.\r\n2. Thông tin về bom tấn “Avengers: Doomsday” - Cập nhật từ A đến Z\r\nThể loại: Hành động, khoa học viễn tưởng, phiêu lưu, siêu anh hùng\r\nThời lượng: Đang cập nhật\r\nĐạo diễn: Anthony Russo và Joe Russo\r\nBiên kịch: Stephen McFeely\r\nNhân vật chính: Robert Downey Jr., Pedro Pascal, Chris Hemsworth…\r\nNgày ra mắt tại Việt Nam: 18/12/2026\r\nCác rạp dự kiến công chiếu: CGV, Lotte Cinema, BHD Star, Beta Cinemas, Rạp chiếu phim Quốc gia\r\nGiá vé: Thường dao động từ 56.000 đồng - 99.000 đồng với phim 2D (tùy thuộc vào vị trí ghế ngồi, suất chiếu và từng rạp chiếu phim cụ thể). Bạn có thể tham khảo chi tiết các ưu đãi mới nhất tại đây\r\n\r\n3. Cốt truyện chính của “Avengers: Doomsday”\r\nVề phần “Avengers: Doomsday” nội dung, phim bắt đầu khi trật tự Đa vũ trụ trở nên hỗn loạn sau những biến cố từ các phần phim trước. Giữa lúc các Avengers đang nỗ lực hàn gắn vết nứt thực tại, một thế lực mới xuất hiện từ Latveria - Victor von Doom (Doctor Doom).\r\n\r\nKhác với những kẻ phản diện trước đây, Doctor Doom sở hữu sự kết hợp hoàn hảo giữa công nghệ tối tân và phép thuật huyền bí. Hắn tin rằng cách duy nhất để cứu lấy Đa vũ trụ là đặt tất cả dưới sự kiểm soát độc tài của mình. Các anh hùng từ khắp các thực tại sẽ phải tạm gạt bỏ mâu thuẫn để đối đầu với một kẻ thù có trí tuệ và quyền năng vượt xa những gì họ từng đối mặt.\r\n\r\n“Avengers: Doomsday” được kỳ vọng là siêu phẩm đánh dấu bước ngoặt vĩ đại nhất của vũ trụ Marvel. (Nguồn ảnh: Internet)\r\n“Avengers: Doomsday” được kỳ vọng là siêu phẩm đánh dấu bước ngoặt vĩ đại nhất của vũ trụ Marvel. (Nguồn ảnh: Internet)\r\n4. Tại sao “Avengers: Doomsday” là bom tấn không nên bỏ lỡ?\r\nĐược đầu tư với kinh phí khổng lồ và mang trọng trách vực dậy kỷ nguyên mới của Marvel, “Avengers: Doomsday” được kỳ vọng sẽ vượt qua cái bóng của “Endgame” (2019) để trở thành tường thành điện ảnh mới của dòng phim siêu anh hùng:\r\n\r\nMàn lột xác gây sốc của Robert Downey Jr.: Sự trở lại của Robert Downey Jr. không phải trong bộ giáp Iron Man mà là dưới chiếc mặt nạ sắt của siêu phản diện Victor von Doom. Chứng kiến biểu tượng của hy vọng trở thành biểu tượng của sự hủy diệt mang lại sự tò mò và kỳ vọng lớn với fan Marvel.\r\nSự tái xuất của \"bộ đôi vàng\" anh em nhà Russo: Sau thành công vang dội của “Infinity War” và “Endgame”, sự trở lại của cặp đạo diễn này là bảo chứng cho những pha hành động quy mô lớn, mạch truyện chặt chẽ và khả năng điều phối dàn nhân vật khổng lồ một cách mượt mà.\r\nMàn chào sân của Fantastic Four: Đây là lần đầu tiên nhóm Bộ tứ siêu đẳng chính thức đứng chung hàng ngũ với các Avengers. Sự kết hợp giữa trí tuệ của Reed Richards và các siêu anh hùng hiện tại sẽ là yếu tố then chốt để đối đầu với trí tuệ thiên tài của Doctor Doom.\r\nCuộc đại chiến Đa vũ trụ quy mô chưa từng có: Phim khai thác sâu khái niệm Incursion (Xâm lấn) - nơi các vũ trụ va chạm và tiêu diệt lẫn nhau. Cảm giác nghẹt thở khi chứng kiến các thế giới dần tan biến mang lại tông màu u tối, kịch tính, hứa hẹn một cái kết gây sốc không kém gì cú búng tay của Thanos.\r\nQuy tụ dàn diễn viên \"khủng\" nhất lịch sử: Không chỉ có các Avengers mới, phim còn được đồn đoán sẽ có sự góp mặt của nhân vật từ vũ trụ X-Men (Fox), Spider-Man (Tobey Maguire và Andrew Garfield), tạo nên sự kiện giao thoa văn hóa đại chúng khổng lồ.\r\nBàn đạp trực tiếp cho “Avengers: Secret Wars”: “Doomsday” không chỉ là một phần phim độc lập mà còn đóng vai trò là chương mở đầu cho trận chiến cuối cùng vĩ đại nhất kỷ nguyên Đa vũ trụ. Mọi sự hy sinh trong phần này đều là mắt xích quan trọng dẫn đến kết cục của toàn bộ MCU.\r\nSự trở lại gây chấn động toàn cầu của Robert Downey Jr. trong vai phản diện nguy hiểm bậc nhất - Victor von Doom. (Nguồn ảnh: Internet)\r\nSự trở lại gây chấn động toàn cầu của Robert Downey Jr. trong vai phản diện nguy hiểm bậc nhất - Victor von Doom. (Nguồn ảnh: Internet)\r\n5. Đặt vé xem “Avengers: Doomsday” dễ dàng, tiện lợi trên ứng dụng ngân hàng và website/ứng dụng VNPAY\r\nĐể ra rạp xem “Avengers: Doomsday” trong khung giờ “vàng” với vị trí ghế ngồi lý tưởng, bạn có thể lựa chọn ngay tính năng “Đặt vé xem phim” trên ứng dụng ngân hàng (VCB Digibank, VietinBank iPay Mobile, BIDV SmartBanking, Agribank Plus…) và website/ứng dụng VNPAY.\r\n\r\n5. Doanh thu phim “Avengers: Doomsday” là bao nhiêu?\r\nHiện tại phim vẫn đang trong quá trình sản xuất nên chưa có số liệu doanh thu chính thức. Tuy nhiên, với sự trở lại của \"ông hoàng phòng vé\" Robert Downey Jr. và anh em nhà Russo (Anthony Russo và Joe Russo), giới chuyên môn dự đoán “Avengers: Doomsday” sẽ dễ dàng cán mốc 1 tỷ USD chỉ sau vài tuần công chiếu.\r\n\r\nMục tiêu xa hơn của Marvel Studios là vượt qua kỷ lục của “Avengers: Endgame” (2.799 tỷ USD) để một lần nữa khẳng định vị thế thống trị của dòng phim siêu anh hùng tại phòng vé toàn cầu.\r\n\r\n6. Nhận định sớm, review của khán giả về phim “Avengers: Doomsday”\r\nDựa trên thông tin từ trailer và các buổi họp báo, khi phân tích kỹ hơn về “Avengers: Doomsday” plot khán giả toàn cầu đang có những phản hồi bùng nổ:\r\n\r\nĐánh giá về sự trở lại của Robert Downey Jr.: Đây là chủ đề gây tranh cãi và phấn khích nhất trên các diễn đàn điện ảnh. Một bộ phận lớn khán giả bày tỏ sự kỳ vọng ông sẽ mang đến một Doctor Doom thâm trầm, nguy hiểm và khác biệt hoàn toàn với hình ảnh Iron Man. Ngược lại, một số fan nguyên tác lo ngại việc sử dụng gương mặt cũ sẽ làm mất đi tính độc lập của nhân vật Doctor Doom.\r\nKỳ vọng vào nội dung và đạo diễn: Sau một giai đoạn MCU bị đánh giá là thiếu gắn kết, sự tái xuất của anh em nhà Russo được xem là \"cứu cánh\" cuối cùng. Người hâm mộ đặt kỳ vọng rất cao vào một kịch bản có chiều sâu, mang tông màu u tối và khốc liệt tương tự như “Infinity War”, nơi các siêu anh hùng phải đối mặt với những lựa chọn đạo đức khó khăn.\r\nĐánh giá về kỹ xảo và quy mô: Qua những đoạn teaser ngắn và hình ảnh hậu trường tại London, giới chuyên gia đánh giá cao việc Marvel quay lại với các bối cảnh thực tế kết hợp CGI tinh xảo. Sự xuất hiện của vương quốc Latveria với kiến trúc pha trộn giữa cổ điển và công nghệ tương lai đang nhận được rất nhiều lời khen ngợi về mặt thị giác.\r\nĐiểm thu hút và lo ngại: Điểm cộng lớn nhất là sự giao thoa giữa nhóm Fantastic Four và Avengers, tạo nên sự tươi mới cho đội hình siêu anh hùng. Tuy nhiên, thách thức lớn nhất của phim chính là việc phải cân bằng đất diễn cho dàn nhân vật quá đồ sộ mà không làm loãng mạch truyện chính.\r\n“Avengers: Doomsday” không chỉ là một bộ phim siêu anh hùng đơn thuần, mà còn là lời khẳng định cho sự trỗi dậy mạnh mẽ của Marvel Studios sau giai đoạn chuyển giao đầy biến động. Với sự tái xuất của bộ đôi đạo diễn lừng danh nhà Russo và màn \"hóa thân\" gây chấn động của Robert Downey Jr., đây chắc chắn là trải nghiệm điện ảnh bùng nổ nhất mà bất kỳ mọt phim nào cũng không thể bỏ lỡ vào cuối năm 2026.', 'denzel_news.png', '2026-04-08', 'Publish', 0, 1, 'Movie'),
(9, 'Angelina Jolie xuất hiện lộng lẫy tại buổi ra mắt phim mới', 'Nữ minh tinh thu hút mọi ánh nhìn trên thảm đỏ với phong cách quý phái.', 'Angelina Jolie nổi tiếng với phong cách thời trang sang trọng. Nữ minh tinh không hề lựa chọn và lên đồ quá cầu kỳ. Thay vào đó, Angelina Jolie ưu tiên những item cơ bản, quen thuộc, chẳng hạn như bộ suit, áo khoác dáng dài, áo blazer và sơ mi trắng… Dù là vào mùa hè hay thu/đông, Angelina Jolie vẫn giữ nguyên tinh thần tối giản trong phong cách.\r\n\r\nĐể nâng tầm thời trang mùa lạnh, phụ nữ trung niên nên tham khảo 10 bộ cánh sau đây của Angelina Jolie:\r\n\r\nDù mang tông màu đen làm chủ đạo, bộ trang phục của Angelina Jolie vẫn rất đẳng cấp. Nữ minh tinh gây ấn tượng với sự sang trọng, thanh lịch. Angelina Jolie còn thể hiện sự tinh tế trong việc chọn trang sức. Cụ thể, cô tô điểm dây chuyền và khuyên tai thiết kế tinh giản để tăng thêm sự long lanh cho outfit.\r\n\r\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Donec blandit id purus sit amet vulputate. Sed massa mauris, tempus quis malesuada ac, tempor eget nisl. Nullam augue nunc, viverra vel augue sit amet, porta accumsan diam. Quisque molestie hendrerit neque, et aliquam nisi ullamcorper eget. Etiam consectetur ipsum eu risus facilisis pellentesque. Suspendisse non efficitur tortor. Quisque id orci ante. Curabitur a eleifend tellus. Phasellus ac odio quis velit ultrices vulputate varius ut metus. Proin ut ex vel libero fringilla porta. Etiam ullamcorper libero id quam ullamcorper, sed tempus dolor volutpat. Proin congue nisi leo, et efficitur mi dapibus nec. Cras ac porttitor dolor. Suspendisse convallis fringilla nibh, eu egestas nisl mattis quis. Nunc condimentum eleifend tempor.\r\n\r\nSuspendisse finibus sit amet velit non vehicula. Etiam malesuada nisl in diam cursus dignissim. Nulla aliquam diam massa, nec fermentum odio porttitor non. Aenean suscipit, lorem id tincidunt facilisis, odio metus faucibus eros, aliquam ultrices eros urna nec mi. Vivamus nunc enim, sollicitudin sit amet cursus vitae, imperdiet vitae erat. Donec purus leo, tempus ac imperdiet a, iaculis sed nibh. Donec at ex a mauris pharetra interdum id in ante.\r\n\r\nNullam accumsan risus risus, a egestas orci suscipit vel. Phasellus vehicula, mi vel bibendum blandit, odio nibh elementum justo, ac efficitur diam dolor id sem. Mauris eu laoreet dolor, quis tristique tellus. Vestibulum sodales metus ac elit vestibulum mollis. Donec mi nisl, vehicula sed venenatis eget, tristique ac arcu. Sed consectetur posuere urna nec luctus. Sed sit amet maximus enim. Nunc mollis ante at sem rutrum, ut faucibus lectus interdum. Etiam sagittis est iaculis arcu interdum, eget lacinia lectus posuere. Duis turpis nulla, maximus id feugiat tristique, varius a justo. Morbi in dui fermentum, scelerisque massa vel, efficitur orci. Vestibulum fringilla rhoncus eleifend. Vivamus mattis, urna vel pretium semper, nisi lectus egestas justo, vel malesuada risus mauris nec mauris.\r\n\r\nNulla sodales luctus convallis. Mauris scelerisque ante ut mauris hendrerit dignissim. Suspendisse blandit finibus tellus, ac volutpat ipsum commodo vel. Nulla sapien libero, viverra egestas molestie non, pharetra quis odio. Etiam ultrices vel leo posuere venenatis. Aliquam consequat nunc sed dui rhoncus scelerisque. Duis quis augue vitae erat euismod volutpat. Donec pellentesque nulla lectus, quis euismod neque varius ac. Morbi laoreet velit volutpat dolor malesuada vehicula.\r\n\r\nMaecenas elit nisl, consectetur id nisl pulvinar, posuere aliquet libero. Mauris quam dui, pretium non lectus in, placerat efficitur magna. Nulla facilisi. Suspendisse sit amet rutrum elit. Proin augue magna, tristique tincidunt tempor at, ultrices vel nibh. Vivamus eget tortor at quam tincidunt dapibus id non erat. Integer varius, erat vitae imperdiet ultrices, urna odio accumsan nunc, at condimentum dui magna at eros. Suspendisse faucibus cursus sapien, et finibus nulla fringilla et. Proin ut accumsan nunc. Maecenas dignissim fringilla consequat. Nam massa arcu, dictum eu interdum nec, venenatis non massa. Maecenas quis sodales nibh. Suspendisse efficitur rutrum consequat. Morbi vitae hendrerit sem, id auctor tellus. Phasellus neque nisl, semper quis placerat consequat, semper et ante.', 'jolie_premier.png', '2026-04-09', 'Publish', 0, 3, 'Movie'),
(10, 'Tom Cruise tự thực hiện cảnh nhảy dù trong phim mới nhất', 'Sự liều lĩnh của nam tài tử 60 tuổi khiến cả đoàn phim thán phục.', 'Ở tuổi 62, Tom Cruise vẫn khiến khán giả ngỡ ngàng khi có thể leo núi mà không cần thiết bị bảo hộ, đu dây giữa các tòa nhà chọc trời, treo mình bên ngoài máy bay đang cất cánh.\r\nGần ba thập kỷ kiên trì chinh phục những điều tưởng chừng “bất khả thi”, Tom Cruise luôn vượt qua chính mình bằng tài năng, ý chí phi thường và niềm đam mê điện ảnh - Ảnh: Animated Times\r\n\r\nTom Cruise chính là linh hồn của Mission: Impossible, góp phần đưa loạt phim trở thành biểu tượng của thể loại hành động hiện đại. Mỗi phần phim mới đều đẩy mức độ nguy hiểm lên một tầm cao mới, mang đến hàng loạt cảnh quay để đời trên màn ảnh rộng.\r\n\r\nTrước thềm công chiếu Mission: Impossible - The Final Reckoning (Nhiệm vụ: Bất khả thi - Nghiệp báo cuối cùng) vào ngày 23-5, cùng điểm lại những pha hành động ngoạn mục và liều lĩnh khó tin làm nên tên tuổi của Tom Cruise.\r\n\r\nLeo núi tay không trên vách đá Utah\r\nMission: Impossible 2 (2000) mở màn bằng cảnh Ethan Hunt (Tom Cruise) leo tay không trên vách đá dựng đứng tại công viên Dead Horse Point, Utah - không dây bảo hiểm, không lưới an toàn. Đây là một dạng free solo climbing, môn thể thao mạo hiểm cực độ, chỉ một sơ suất nhỏ cũng có thể trả giá bằng mạng sống.\r\n\r\nCảnh quay thực hiện trên vách núi cao 600m, Cruise chỉ được giữ bởi một sợi cáp mảnh giấu kín, sau đó xóa bằng kỹ xảo.\r\n\r\nTrong lúc quay, nam diễn viên bị rách vai, gãy chân khi nhảy giữa hai mỏm đá, nhưng vẫn cố gắng làm lại. Đạo diễn John Woo kể lại rằng ông kinh hãi đến nghẹt thở khi chứng kiến cảnh tượng này.\r\n\r\nĐu dây giữa các tòa nhà chọc trời Thượng Hải\r\nTrong Mission: Impossible 3 (2006), Ethan Hunt phải đu dây từ nóc một tòa cao ốc sang tòa nhà kế bên giữa đêm ở Thượng Hải để lấy cắp món đồ bí ẩn mang tên “Rabbit’s Foot”.\r\n\r\nTrên màn ảnh, cảnh quay cho thấy anh lao mình vào khoảng không, đập mạnh vào mặt kính rồi leo lên mái tòa nhà đối diện. Trong thực tế, cảnh này thực hiện trên mô hình mái nhà cao khoảng 24m dựng tại phim trường và Cruise tự mình thực hiện cú nhảy nhiều lần.\r\n\r\nLà phim điện ảnh đầu tay của đạo diễn J.J. Abrams, anh thừa nhận mỗi lần Cruise thực hiện pha mạo hiểm ấy, anh đều toát mồ hôi vì quá nguy hiểm.\r\n\r\nĐu mình bên ngoài tòa tháp Burj Khalifa\r\nỞ phần 4 - Mission: Impossible - Ghost Protocol (2011), Tom Cruise trèo ra bên ngoài Burj Khalifa - tòa nhà cao nhất thế giới tại Dubai (828m). Trong phim, Ethan Hunt đu bám bằng đôi găng tay công nghệ trên mặt kính tòa tháp, trong lúc một trận bão cát đang kéo đến.\r\n\r\nKhông phông xanh, không CGI thay thế: toàn bộ cảnh quay được thực hiện thật ở độ cao hơn 500m, Cruise đích thân treo mình lơ lửng ngoài trời. Dù ê kíp đề xuất dùng kỹ xảo, anh vẫn kiên quyết từ chối và tự thực hiện mọi cảnh quay.\r\n\r\nJeremy Renner - người diễn cùng trong cảnh này - cho biết chỉ cần nửa người ló ra khỏi tòa nhà đã thấy run và hoàn toàn khâm phục sự liều lĩnh cùng tinh thần không ngừng thách thức giới hạn của Cruise.\r\n\r\nBám bên ngoài máy bay cất cánh\r\nPhần mở đầu của Mission: Impossible - Rogue Nation (2015) khiến khán giả nghẹt thở khi Ethan Hunt bám vào cánh cửa một chiếc máy bay vận tải quân sự Airbus đang cất cánh. Không hề có kỹ xảo thay thế, Tom Cruise treo mình bên ngoài máy bay khi nó bay lên tới độ cao 1.500m.\r\n\r\nĐạo diễn Christopher McQuarrie lo ngại chỉ cần một viên đá nhỏ hay chim trời va vào Cruise ở tốc độ đó cũng có thể gây thảm họa. Dù vậy, tài tử vẫn thực hiện cảnh quay tới 8 lần trong 2 ngày vì sự cầu toàn.\r\n\r\nSimon Pegg kể lại cả đoàn phim nín thở mỗi lần máy bay rời mặt đất với Cruise đu bám bên ngoài, cảm giác như nói lời tạm biệt với anh. Tuy nhiên, Pegg khẳng định Cruise không hề liều lĩnh mù quáng mà cực kỳ kỹ lưỡng, luôn ưu tiên an toàn tuyệt đối.\r\n\r\nNhảy HALO từ độ cao 7,6km\r\nKhi khán giả nghĩ Tom Cruise không thể liều hơn sau những màn bám máy bay hay trèo tháp chọc trời, anh lại thực hiện cú nhảy HALO - kỹ thuật nhảy dù từ độ cao cực lớn, chỉ dành cho lính đặc nhiệm.\r\n\r\nTrong Mission: Impossible - Fallout (2018), Ethan Hunt nhảy khỏi máy bay ở độ cao 7,6km, rơi xuyên mây dông rồi mới bung dù. Cruise thực sự thực hiện cú nhảy này, với hơn 100 lần thử để ghi hình hoàn chỉnh.\r\n\r\nVì rủi ro quá lớn, hãng bảo hiểm không cho Henry Cavill nhảy cùng, dù anh rất muốn. Cruise phải huấn luyện hàng trăm giờ để làm chủ kỹ thuật rơi và phối hợp với máy quay trên không.\r\n\r\nNhảy mô tô khỏi vách núi (BASE jump)\r\nỞ tuổi 61, trong Mission: Impossible - Dead Reckoning (2023), Tom Cruise phóng mô tô khỏi mỏm núi dựng đứng rồi lập tức chuyển sang nhảy BASE để thoát thân.\r\n\r\nĐể chuẩn bị cho cảnh này, Cruise đã tập luyện với hơn 13.000 lần nhảy mô tô địa hình và hơn 500 lần nhảy dù để hoàn thiện kỹ thuật điều khiển rơi. Đạo diễn Christopher McQuarrie gọi đây là \"điều nguy hiểm nhất mà chúng tôi từng thử”.\r\n\r\nMọi yếu tố - hướng gió, địa hình, thời gian bung dù - đều được tính toán cặn kẽ, vì chỉ một sai lệch nhỏ cũng có thể gây chết người.\r\n\r\nMay mắn và nhờ sự chuẩn bị cực kỳ nghiêm ngặt, Tom Cruise thực hiện cú nhảy thành công, không chỉ một, mà sáu lần liền trong cùng một ngày để đảm bảo có đủ góc quay phục vụ hậu kỳ.\r\n\r\nNeo mình bên ngoài máy bay hai tầng\r\nTom Cruise tái xuất hoành tráng tại Cannes với Mission: Impossible - The Final Reckoning\r\nTrailer đầu tiên của Mission: Impossible - The Final Reckoning (2025) hé lộ cảnh hành động đầy kịch tính, khi Ethan Hunt đu mình trên cánh của chiếc máy bay Boeing-Stearman - một chiếc máy bay hai tầng cánh từ thời thế chiến, trong khi nó bay nhào lộn và lật ngược trên không trung.\r\n\r\nĐể bám trụ trên cánh máy bay khi nó bay với vận tốc khoảng 200km/h, Cruise phải luyện tập kỹ thuật thở đặc biệt để đối phó với luồng không khí mạnh táp vào mặt.\r\n\r\nTrailer Mission: Impossible - The Final Reckoning\r\n\r\nTrong quá trình luyện tập, có những lần anh bị ngất xỉu vì thiếu oxy và không thể tự trèo lại vào buồng lái. Thêm vào đó là lực G cực lớn tác động lên cơ thể khi máy bay thực hiện các động tác nhào lộn.\r\n\r\nTom Cruise chia sẻ anh xem bộ phim này là đỉnh cao trong sự nghiệp hành động kéo dài suốt 30 năm và hy vọng sẽ mang đến một cái kết thật trọn vẹn cho khán giả.', 'tom_cruise_stunt.png', '2026-04-10', 'Publish', 0, 3, 'Movie'),
(11, 'Natalie Portman và hành trình hóa thân vào vai diễn thiên nga', 'Nữ diễn viên chia sẻ về chế độ tập luyện ballet khắc nghiệt.', 'Những bí mật chưa từng được công bố phía sau hậu trường của bộ phim Black Swan. Nữ diễn viên chia sẻ chi tiết về chế độ tập luyện ballet khắc nghiệt, thực đơn ăn kiêng nghiêm ngặt và những áp lực tâm lý khủng khiếp mà cô phải vượt qua để có thể chạm tay vào tượng vàng Oscar danh giá.\r\n    \r\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Donec blandit id purus sit amet vulputate. Sed massa mauris, tempus quis malesuada ac, tempor eget nisl. Nullam augue nunc, viverra vel augue sit amet, porta accumsan diam. Quisque molestie hendrerit neque, et aliquam nisi ullamcorper eget. Etiam consectetur ipsum eu risus facilisis pellentesque. Suspendisse non efficitur tortor. Quisque id orci ante. Curabitur a eleifend tellus. Phasellus ac odio quis velit ultrices vulputate varius ut metus. Proin ut ex vel libero fringilla porta. Etiam ullamcorper libero id quam ullamcorper, sed tempus dolor volutpat. Proin congue nisi leo, et efficitur mi dapibus nec. Cras ac porttitor dolor. Suspendisse convallis fringilla nibh, eu egestas nisl mattis quis. Nunc condimentum eleifend tempor.\r\n\r\nSuspendisse finibus sit amet velit non vehicula. Etiam malesuada nisl in diam cursus dignissim. Nulla aliquam diam massa, nec fermentum odio porttitor non. Aenean suscipit, lorem id tincidunt facilisis, odio metus faucibus eros, aliquam ultrices eros urna nec mi. Vivamus nunc enim, sollicitudin sit amet cursus vitae, imperdiet vitae erat. Donec purus leo, tempus ac imperdiet a, iaculis sed nibh. Donec at ex a mauris pharetra interdum id in ante.\r\n\r\nNullam accumsan risus risus, a egestas orci suscipit vel. Phasellus vehicula, mi vel bibendum blandit, odio nibh elementum justo, ac efficitur diam dolor id sem. Mauris eu laoreet dolor, quis tristique tellus. Vestibulum sodales metus ac elit vestibulum mollis. Donec mi nisl, vehicula sed venenatis eget, tristique ac arcu. Sed consectetur posuere urna nec luctus. Sed sit amet maximus enim. Nunc mollis ante at sem rutrum, ut faucibus lectus interdum. Etiam sagittis est iaculis arcu interdum, eget lacinia lectus posuere. Duis turpis nulla, maximus id feugiat tristique, varius a justo. Morbi in dui fermentum, scelerisque massa vel, efficitur orci. Vestibulum fringilla rhoncus eleifend. Vivamus mattis, urna vel pretium semper, nisi lectus egestas justo, vel malesuada risus mauris nec mauris.\r\n\r\nNulla sodales luctus convallis. Mauris scelerisque ante ut mauris hendrerit dignissim. Suspendisse blandit finibus tellus, ac volutpat ipsum commodo vel. Nulla sapien libero, viverra egestas molestie non, pharetra quis odio. Etiam ultrices vel leo posuere venenatis. Aliquam consequat nunc sed dui rhoncus scelerisque. Duis quis augue vitae erat euismod volutpat. Donec pellentesque nulla lectus, quis euismod neque varius ac. Morbi laoreet velit volutpat dolor malesuada vehicula.\r\n\r\nMaecenas elit nisl, consectetur id nisl pulvinar, posuere aliquet libero. Mauris quam dui, pretium non lectus in, placerat efficitur magna. Nulla facilisi. Suspendisse sit amet rutrum elit. Proin augue magna, tristique tincidunt tempor at, ultrices vel nibh. Vivamus eget tortor at quam tincidunt dapibus id non erat. Integer varius, erat vitae imperdiet ultrices, urna odio accumsan nunc, at condimentum dui magna at eros. Suspendisse faucibus cursus sapien, et finibus nulla fringilla et. Proin ut accumsan nunc. Maecenas dignissim fringilla consequat. Nam massa arcu, dictum eu interdum nec, venenatis non massa. Maecenas quis sodales nibh. Suspendisse efficitur rutrum consequat. Morbi vitae hendrerit sem, id auctor tellus. Phasellus neque nisl, semper quis placerat consequat, semper et ante.', 'natalie_portman_news.png', '2026-04-11', 'Publish', 0, 1, 'Movie'),
(12, 'Joaquin Phoenix tiết lộ lý do nhận vai Joker lần thứ hai', 'Nam diễn viên muốn khám phá sâu hơn những góc khuất của nhân vật.', 'Cuộc phỏng vấn độc quyền về hành trình tâm lý đầy chông gai của Joaquin Phoenix khi quyết định quay lại với nhân vật Joker. Nam diễn viên chia sẻ về mong muốn khám phá sâu hơn những góc khuất tối tăm, những diễn biến tâm thần phức tạp mà phần đầu tiên chưa kịp lột tả hết.\r\n\r\nJoaquin Phoenix đã trải qua hành trình tâm lý phức tạp khi quay lại với Joker, thúc đẩy bởi mong muốn khám phá sâu hơn những góc khuất tâm thần tối tăm mà phần một chưa lột tả hết. Anh tập trung vào việc thể hiện sự tan vỡ nội tâm và những diễn biến tâm lý dữ dội hơn của nhân vật Arthur Fleck, thay vì chỉ tập trung vào sự điên loạn bên ngoài. \r\n\r\nCác điểm nhấn về hành trình tâm lý của Joaquin Phoenix:\r\nKhám phá sâu hơn: Phoenix chia sẻ mong muốn tìm hiểu những \"góc khuất\" chưa được khai thác, đặc biệt là những diễn biến tâm lý phức tạp mà phần đầu tiên chưa kịp lột tả hết.\r\nChông gai tâm lý: Nam diễn viên thừa nhận việc quay lại nhân vật này đòi hỏi sự chuẩn bị tâm lý kỹ lưỡng và nỗ lực \"xóa bỏ bóng tối\" khỏi đời thực sau khi quay phim.\r\nPhát triển nhân vật: Thay vì lặp lại sự điên loạn, anh tập trung vào việc thể hiện sự tan vỡ nội tâm và những diễn biến tâm lý dữ dội hơn của nhân vật Arthur Fleck.\r\nDiễn xuất \"gây nghiện\": Joaquin Phoenix muốn tiếp tục trường phái diễn xuất \"addiction\" (gây nghiện) – nơi anh hoàn toàn đắm mình vào thế giới tâm lý nhân vật. \r\n\r\nCuộc trở lại này được xem là một thách thức lớn khi nhân vật Joker đã mang lại cho anh tượng vàng Oscar, đồng thời đòi hỏi sự sáng tạo để không lặp lại chính mình. ', 'joaquin_joker_2.png', '2026-04-12', 'Publish', 0, 1, 'Movie'),
(13, 'Trấn Thành vừa quay trở lại sân khấu sau 3 năm nghỉ dưỡng', 'Sự xuất hiện bất ngờ của Trấn Thành khiến fan hâm mộ vỡ òa.', 'Nội dung buổi livestream đầy cảm xúc của Trấn Thành, nơi anh chia sẻ về quãng nghỉ 3 năm vừa qua và những thay đổi trong thế giới quan. Bài viết tóm tắt các dự án nghệ thuật sắp tới, tình cảm của người hâm mộ trong ngày anh tái ngộ ánh đèn sân khấu và những dự định mới trong sự nghiệp. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec blandit id purus sit amet vulputate. Sed massa mauris, tempus quis malesuada ac, tempor eget nisl. Nullam augue nunc, viverra vel augue sit amet, porta accumsan diam. Quisque molestie hendrerit neque, et aliquam nisi ullamcorper eget. Etiam consectetur ipsum eu risus facilisis pellentesque. Suspendisse non efficitur tortor. Quisque id orci ante. Curabitur a eleifend tellus. Phasellus ac odio quis velit ultrices vulputate varius ut metus. Proin ut ex vel libero fringilla porta. Etiam ullamcorper libero id quam ullamcorper, sed tempus dolor volutpat. Proin congue nisi leo, et efficitur mi dapibus nec. Cras ac porttitor dolor. Suspendisse convallis fringilla nibh, eu egestas nisl mattis quis. Nunc condimentum eleifend tempor.\r\n\r\nSuspendisse finibus sit amet velit non vehicula. Etiam malesuada nisl in diam cursus dignissim. Nulla aliquam diam massa, nec fermentum odio porttitor non. Aenean suscipit, lorem id tincidunt facilisis, odio metus faucibus eros, aliquam ultrices eros urna nec mi. Vivamus nunc enim, sollicitudin sit amet cursus vitae, imperdiet vitae erat. Donec purus leo, tempus ac imperdiet a, iaculis sed nibh. Donec at ex a mauris pharetra interdum id in ante.\r\n\r\nNullam accumsan risus risus, a egestas orci suscipit vel. Phasellus vehicula, mi vel bibendum blandit, odio nibh elementum justo, ac efficitur diam dolor id sem. Mauris eu laoreet dolor, quis tristique tellus. Vestibulum sodales metus ac elit vestibulum mollis. Donec mi nisl, vehicula sed venenatis eget, tristique ac arcu. Sed consectetur posuere urna nec luctus. Sed sit amet maximus enim. Nunc mollis ante at sem rutrum, ut faucibus lectus interdum. Etiam sagittis est iaculis arcu interdum, eget lacinia lectus posuere. Duis turpis nulla, maximus id feugiat tristique, varius a justo. Morbi in dui fermentum, scelerisque massa vel, efficitur orci. Vestibulum fringilla rhoncus eleifend. Vivamus mattis, urna vel pretium semper, nisi lectus egestas justo, vel malesuada risus mauris nec mauris.\r\n\r\nNulla sodales luctus convallis. Mauris scelerisque ante ut mauris hendrerit dignissim. Suspendisse blandit finibus tellus, ac volutpat ipsum commodo vel. Nulla sapien libero, viverra egestas molestie non, pharetra quis odio. Etiam ultrices vel leo posuere venenatis. Aliquam consequat nunc sed dui rhoncus scelerisque. Duis quis augue vitae erat euismod volutpat. Donec pellentesque nulla lectus, quis euismod neque varius ac. Morbi laoreet velit volutpat dolor malesuada vehicula.\r\n\r\nMaecenas elit nisl, consectetur id nisl pulvinar, posuere aliquet libero. Mauris quam dui, pretium non lectus in, placerat efficitur magna. Nulla facilisi. Suspendisse sit amet rutrum elit. Proin augue magna, tristique tincidunt tempor at, ultrices vel nibh. Vivamus eget tortor at quam tincidunt dapibus id non erat. Integer varius, erat vitae imperdiet ultrices, urna odio accumsan nunc, at condimentum dui magna at eros. Suspendisse faucibus cursus sapien, et finibus nulla fringilla et. Proin ut accumsan nunc. Maecenas dignissim fringilla consequat. Nam massa arcu, dictum eu interdum nec, venenatis non massa. Maecenas quis sodales nibh. Suspendisse efficitur rutrum consequat. Morbi vitae hendrerit sem, id auctor tellus. Phasellus neque nisl, semper quis placerat consequat, semper et ante.', 'tran_thanh_back.png', '2026-04-01', 'Publish', 0, 3, 'Actor');
INSERT INTO `tbl_new` (`New_ID`, `New_Title`, `New_Description`, `New_Content`, `New_Img`, `New_PublishDate`, `New_Status`, `New_View`, `Account_ID`, `New_Category`) VALUES
(14, 'Leonardo DiCaprio tiết lộ chế độ tập luyện để vào vai sinh tồn', 'Để đóng phim của Inarritu, anh đã phải chịu đựng cái lạnh âm độ.', 'Chia sẻ chân thực về trải nghiệm thực tế khắc nghiệt trên phim trường của đạo diễn Inarritu. Để hóa thân hoàn hảo vào nhân vật, Leonardo đã phải chịu đựng cái lạnh âm độ, ăn gan bò sống và thực hiện những bài tập thể lực cường độ cao để duy trì sức bền trong suốt quá trình quay phim tại vùng hoang dã. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec blandit id purus sit amet vulputate. Sed massa mauris, tempus quis malesuada ac, tempor eget nisl. Nullam augue nunc, viverra vel augue sit amet, porta accumsan diam. Quisque molestie hendrerit neque, et aliquam nisi ullamcorper eget. Etiam consectetur ipsum eu risus facilisis pellentesque. Suspendisse non efficitur tortor. Quisque id orci ante. Curabitur a eleifend tellus. Phasellus ac odio quis velit ultrices vulputate varius ut metus. Proin ut ex vel libero fringilla porta. Etiam ullamcorper libero id quam ullamcorper, sed tempus dolor volutpat. Proin congue nisi leo, et efficitur mi dapibus nec. Cras ac porttitor dolor. Suspendisse convallis fringilla nibh, eu egestas nisl mattis quis. Nunc condimentum eleifend tempor.\r\n\r\nSuspendisse finibus sit amet velit non vehicula. Etiam malesuada nisl in diam cursus dignissim. Nulla aliquam diam massa, nec fermentum odio porttitor non. Aenean suscipit, lorem id tincidunt facilisis, odio metus faucibus eros, aliquam ultrices eros urna nec mi. Vivamus nunc enim, sollicitudin sit amet cursus vitae, imperdiet vitae erat. Donec purus leo, tempus ac imperdiet a, iaculis sed nibh. Donec at ex a mauris pharetra interdum id in ante.\r\n\r\nNullam accumsan risus risus, a egestas orci suscipit vel. Phasellus vehicula, mi vel bibendum blandit, odio nibh elementum justo, ac efficitur diam dolor id sem. Mauris eu laoreet dolor, quis tristique tellus. Vestibulum sodales metus ac elit vestibulum mollis. Donec mi nisl, vehicula sed venenatis eget, tristique ac arcu. Sed consectetur posuere urna nec luctus. Sed sit amet maximus enim. Nunc mollis ante at sem rutrum, ut faucibus lectus interdum. Etiam sagittis est iaculis arcu interdum, eget lacinia lectus posuere. Duis turpis nulla, maximus id feugiat tristique, varius a justo. Morbi in dui fermentum, scelerisque massa vel, efficitur orci. Vestibulum fringilla rhoncus eleifend. Vivamus mattis, urna vel pretium semper, nisi lectus egestas justo, vel malesuada risus mauris nec mauris.\r\n\r\nNulla sodales luctus convallis. Mauris scelerisque ante ut mauris hendrerit dignissim. Suspendisse blandit finibus tellus, ac volutpat ipsum commodo vel. Nulla sapien libero, viverra egestas molestie non, pharetra quis odio. Etiam ultrices vel leo posuere venenatis. Aliquam consequat nunc sed dui rhoncus scelerisque. Duis quis augue vitae erat euismod volutpat. Donec pellentesque nulla lectus, quis euismod neque varius ac. Morbi laoreet velit volutpat dolor malesuada vehicula.\r\n\r\nMaecenas elit nisl, consectetur id nisl pulvinar, posuere aliquet libero. Mauris quam dui, pretium non lectus in, placerat efficitur magna. Nulla facilisi. Suspendisse sit amet rutrum elit. Proin augue magna, tristique tincidunt tempor at, ultrices vel nibh. Vivamus eget tortor at quam tincidunt dapibus id non erat. Integer varius, erat vitae imperdiet ultrices, urna odio accumsan nunc, at condimentum dui magna at eros. Suspendisse faucibus cursus sapien, et finibus nulla fringilla et. Proin ut accumsan nunc. Maecenas dignissim fringilla consequat. Nam massa arcu, dictum eu interdum nec, venenatis non massa. Maecenas quis sodales nibh. Suspendisse efficitur rutrum consequat. Morbi vitae hendrerit sem, id auctor tellus. Phasellus neque nisl, semper quis placerat consequat, semper et ante.', 'leo_training.png', '2026-04-02', 'Publish', 0, 1, 'Actor'),
(15, 'Cate Blanchett nhận giải thưởng cống hiến trọn đời', 'Gương mặt quyền lực của điện ảnh thế giới được vinh danh tại London.', 'Tiểu sử tóm tắt và danh sách các giải thưởng đồ sộ trong sự nghiệp của \"người đàn bà quyền lực\" Cate Blanchett. Bài viết tôn vinh những đóng góp to lớn của bà cho nền điện ảnh thế giới, từ những vai diễn cổ điển đến hiện đại, khẳng định vị thế của một biểu tượng diễn xuất không thể thay thế. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec blandit id purus sit amet vulputate. Sed massa mauris, tempus quis malesuada ac, tempor eget nisl. Nullam augue nunc, viverra vel augue sit amet, porta accumsan diam. Quisque molestie hendrerit neque, et aliquam nisi ullamcorper eget. Etiam consectetur ipsum eu risus facilisis pellentesque. Suspendisse non efficitur tortor. Quisque id orci ante. Curabitur a eleifend tellus. Phasellus ac odio quis velit ultrices vulputate varius ut metus. Proin ut ex vel libero fringilla porta. Etiam ullamcorper libero id quam ullamcorper, sed tempus dolor volutpat. Proin congue nisi leo, et efficitur mi dapibus nec. Cras ac porttitor dolor. Suspendisse convallis fringilla nibh, eu egestas nisl mattis quis. Nunc condimentum eleifend tempor.\r\n\r\nSuspendisse finibus sit amet velit non vehicula. Etiam malesuada nisl in diam cursus dignissim. Nulla aliquam diam massa, nec fermentum odio porttitor non. Aenean suscipit, lorem id tincidunt facilisis, odio metus faucibus eros, aliquam ultrices eros urna nec mi. Vivamus nunc enim, sollicitudin sit amet cursus vitae, imperdiet vitae erat. Donec purus leo, tempus ac imperdiet a, iaculis sed nibh. Donec at ex a mauris pharetra interdum id in ante.\r\n\r\nNullam accumsan risus risus, a egestas orci suscipit vel. Phasellus vehicula, mi vel bibendum blandit, odio nibh elementum justo, ac efficitur diam dolor id sem. Mauris eu laoreet dolor, quis tristique tellus. Vestibulum sodales metus ac elit vestibulum mollis. Donec mi nisl, vehicula sed venenatis eget, tristique ac arcu. Sed consectetur posuere urna nec luctus. Sed sit amet maximus enim. Nunc mollis ante at sem rutrum, ut faucibus lectus interdum. Etiam sagittis est iaculis arcu interdum, eget lacinia lectus posuere. Duis turpis nulla, maximus id feugiat tristique, varius a justo. Morbi in dui fermentum, scelerisque massa vel, efficitur orci. Vestibulum fringilla rhoncus eleifend. Vivamus mattis, urna vel pretium semper, nisi lectus egestas justo, vel malesuada risus mauris nec mauris.\r\n\r\nNulla sodales luctus convallis. Mauris scelerisque ante ut mauris hendrerit dignissim. Suspendisse blandit finibus tellus, ac volutpat ipsum commodo vel. Nulla sapien libero, viverra egestas molestie non, pharetra quis odio. Etiam ultrices vel leo posuere venenatis. Aliquam consequat nunc sed dui rhoncus scelerisque. Duis quis augue vitae erat euismod volutpat. Donec pellentesque nulla lectus, quis euismod neque varius ac. Morbi laoreet velit volutpat dolor malesuada vehicula.\r\n\r\nMaecenas elit nisl, consectetur id nisl pulvinar, posuere aliquet libero. Mauris quam dui, pretium non lectus in, placerat efficitur magna. Nulla facilisi. Suspendisse sit amet rutrum elit. Proin augue magna, tristique tincidunt tempor at, ultrices vel nibh. Vivamus eget tortor at quam tincidunt dapibus id non erat. Integer varius, erat vitae imperdiet ultrices, urna odio accumsan nunc, at condimentum dui magna at eros. Suspendisse faucibus cursus sapien, et finibus nulla fringilla et. Proin ut accumsan nunc. Maecenas dignissim fringilla consequat. Nam massa arcu, dictum eu interdum nec, venenatis non massa. Maecenas quis sodales nibh. Suspendisse efficitur rutrum consequat. Morbi vitae hendrerit sem, id auctor tellus. Phasellus neque nisl, semper quis placerat consequat, semper et ante.', 'cate_blanchett_award.png', '2026-04-03', 'Publish', 0, 3, 'Actor'),
(16, 'Keanu Reeves hội ngộ cùng dàn sao tại sự kiện từ thiện', 'Nam tài tử John Wick tiếp tục ghi điểm với vẻ ngoài giản dị.', 'Hình ảnh Keanu Reeves rạng rỡ tại sự kiện đấu giá vật phẩm cá nhân để gây quỹ từ thiện. Bài viết ghi lại khoảnh khắc nam tài tử John Wick tương tác ấm áp với các đồng nghiệp và người hâm mộ, đồng thời nhấn mạnh vào những hoạt động thiện nguyện thầm lặng mà anh đã theo đuổi suốt nhiều năm qua. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec blandit id purus sit amet vulputate. Sed massa mauris, tempus quis malesuada ac, tempor eget nisl. Nullam augue nunc, viverra vel augue sit amet, porta accumsan diam. Quisque molestie hendrerit neque, et aliquam nisi ullamcorper eget. Etiam consectetur ipsum eu risus facilisis pellentesque. Suspendisse non efficitur tortor. Quisque id orci ante. Curabitur a eleifend tellus. Phasellus ac odio quis velit ultrices vulputate varius ut metus. Proin ut ex vel libero fringilla porta. Etiam ullamcorper libero id quam ullamcorper, sed tempus dolor volutpat. Proin congue nisi leo, et efficitur mi dapibus nec. Cras ac porttitor dolor. Suspendisse convallis fringilla nibh, eu egestas nisl mattis quis. Nunc condimentum eleifend tempor.\r\n\r\nSuspendisse finibus sit amet velit non vehicula. Etiam malesuada nisl in diam cursus dignissim. Nulla aliquam diam massa, nec fermentum odio porttitor non. Aenean suscipit, lorem id tincidunt facilisis, odio metus faucibus eros, aliquam ultrices eros urna nec mi. Vivamus nunc enim, sollicitudin sit amet cursus vitae, imperdiet vitae erat. Donec purus leo, tempus ac imperdiet a, iaculis sed nibh. Donec at ex a mauris pharetra interdum id in ante.\r\n\r\nNullam accumsan risus risus, a egestas orci suscipit vel. Phasellus vehicula, mi vel bibendum blandit, odio nibh elementum justo, ac efficitur diam dolor id sem. Mauris eu laoreet dolor, quis tristique tellus. Vestibulum sodales metus ac elit vestibulum mollis. Donec mi nisl, vehicula sed venenatis eget, tristique ac arcu. Sed consectetur posuere urna nec luctus. Sed sit amet maximus enim. Nunc mollis ante at sem rutrum, ut faucibus lectus interdum. Etiam sagittis est iaculis arcu interdum, eget lacinia lectus posuere. Duis turpis nulla, maximus id feugiat tristique, varius a justo. Morbi in dui fermentum, scelerisque massa vel, efficitur orci. Vestibulum fringilla rhoncus eleifend. Vivamus mattis, urna vel pretium semper, nisi lectus egestas justo, vel malesuada risus mauris nec mauris.\r\n\r\nNulla sodales luctus convallis. Mauris scelerisque ante ut mauris hendrerit dignissim. Suspendisse blandit finibus tellus, ac volutpat ipsum commodo vel. Nulla sapien libero, viverra egestas molestie non, pharetra quis odio. Etiam ultrices vel leo posuere venenatis. Aliquam consequat nunc sed dui rhoncus scelerisque. Duis quis augue vitae erat euismod volutpat. Donec pellentesque nulla lectus, quis euismod neque varius ac. Morbi laoreet velit volutpat dolor malesuada vehicula.\r\n\r\nMaecenas elit nisl, consectetur id nisl pulvinar, posuere aliquet libero. Mauris quam dui, pretium non lectus in, placerat efficitur magna. Nulla facilisi. Suspendisse sit amet rutrum elit. Proin augue magna, tristique tincidunt tempor at, ultrices vel nibh. Vivamus eget tortor at quam tincidunt dapibus id non erat. Integer varius, erat vitae imperdiet ultrices, urna odio accumsan nunc, at condimentum dui magna at eros. Suspendisse faucibus cursus sapien, et finibus nulla fringilla et. Proin ut accumsan nunc. Maecenas dignissim fringilla consequat. Nam massa arcu, dictum eu interdum nec, venenatis non massa. Maecenas quis sodales nibh. Suspendisse efficitur rutrum consequat. Morbi vitae hendrerit sem, id auctor tellus. Phasellus neque nisl, semper quis placerat consequat, semper et ante.', 'keanu_charity.png', '2026-04-04', 'Publish', 0, 1, 'Actor'),
(17, 'Meryl Streep chia sẻ bí quyết giữ lửa nghề diễn cho đàn em', 'Những bài học quý báu sau hơn nửa thế kỷ đứng trên sân khấu.', 'Ghi chép chi tiết từ buổi lên lớp đặc biệt tại Học viện Điện ảnh của huyền thoại Meryl Streep. Bà đã dành hơn nửa thế kỷ đứng trên đỉnh cao và nay chia sẻ lại những bài học quý báu về kỹ thuật biểu đạt cảm ứng, cách nuôi dưỡng đam mê và bí quyết để mỗi vai diễn đều mang một hơi thở riêng biệt. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec blandit id purus sit amet vulputate. Sed massa mauris, tempus quis malesuada ac, tempor eget nisl. Nullam augue nunc, viverra vel augue sit amet, porta accumsan diam. Quisque molestie hendrerit neque, et aliquam nisi ullamcorper eget. Etiam consectetur ipsum eu risus facilisis pellentesque. Suspendisse non efficitur tortor. Quisque id orci ante. Curabitur a eleifend tellus. Phasellus ac odio quis velit ultrices vulputate varius ut metus. Proin ut ex vel libero fringilla porta. Etiam ullamcorper libero id quam ullamcorper, sed tempus dolor volutpat. Proin congue nisi leo, et efficitur mi dapibus nec. Cras ac porttitor dolor. Suspendisse convallis fringilla nibh, eu egestas nisl mattis quis. Nunc condimentum eleifend tempor.\r\n\r\nSuspendisse finibus sit amet velit non vehicula. Etiam malesuada nisl in diam cursus dignissim. Nulla aliquam diam massa, nec fermentum odio porttitor non. Aenean suscipit, lorem id tincidunt facilisis, odio metus faucibus eros, aliquam ultrices eros urna nec mi. Vivamus nunc enim, sollicitudin sit amet cursus vitae, imperdiet vitae erat. Donec purus leo, tempus ac imperdiet a, iaculis sed nibh. Donec at ex a mauris pharetra interdum id in ante.\r\n\r\nNullam accumsan risus risus, a egestas orci suscipit vel. Phasellus vehicula, mi vel bibendum blandit, odio nibh elementum justo, ac efficitur diam dolor id sem. Mauris eu laoreet dolor, quis tristique tellus. Vestibulum sodales metus ac elit vestibulum mollis. Donec mi nisl, vehicula sed venenatis eget, tristique ac arcu. Sed consectetur posuere urna nec luctus. Sed sit amet maximus enim. Nunc mollis ante at sem rutrum, ut faucibus lectus interdum. Etiam sagittis est iaculis arcu interdum, eget lacinia lectus posuere. Duis turpis nulla, maximus id feugiat tristique, varius a justo. Morbi in dui fermentum, scelerisque massa vel, efficitur orci. Vestibulum fringilla rhoncus eleifend. Vivamus mattis, urna vel pretium semper, nisi lectus egestas justo, vel malesuada risus mauris nec mauris.\r\n\r\nNulla sodales luctus convallis. Mauris scelerisque ante ut mauris hendrerit dignissim. Suspendisse blandit finibus tellus, ac volutpat ipsum commodo vel. Nulla sapien libero, viverra egestas molestie non, pharetra quis odio. Etiam ultrices vel leo posuere venenatis. Aliquam consequat nunc sed dui rhoncus scelerisque. Duis quis augue vitae erat euismod volutpat. Donec pellentesque nulla lectus, quis euismod neque varius ac. Morbi laoreet velit volutpat dolor malesuada vehicula.\r\n\r\nMaecenas elit nisl, consectetur id nisl pulvinar, posuere aliquet libero. Mauris quam dui, pretium non lectus in, placerat efficitur magna. Nulla facilisi. Suspendisse sit amet rutrum elit. Proin augue magna, tristique tincidunt tempor at, ultrices vel nibh. Vivamus eget tortor at quam tincidunt dapibus id non erat. Integer varius, erat vitae imperdiet ultrices, urna odio accumsan nunc, at condimentum dui magna at eros. Suspendisse faucibus cursus sapien, et finibus nulla fringilla et. Proin ut accumsan nunc. Maecenas dignissim fringilla consequat. Nam massa arcu, dictum eu interdum nec, venenatis non massa. Maecenas quis sodales nibh. Suspendisse efficitur rutrum consequat. Morbi vitae hendrerit sem, id auctor tellus. Phasellus neque nisl, semper quis placerat consequat, semper et ante.', 'meryl_teaching.png', '2026-04-05', 'Publish', 0, 3, 'Actor'),
(18, 'Ngô Thanh Vân tìm kiếm gương mặt mới cho dự án phim hành động', '\"Đả nữ\" mong muốn tìm ra người kế vị xứng đáng cho điện ảnh Việt.', 'Ngô Thanh Vân tìm diễn viên nữ có thể lực, võ thuật, kiên trì cho vai chính \"Thanh Sói\", đồng thời đóng hành động lâu dài.\r\n\r\nSáng 26/10, công ty của Ngô Thanh Vân tổ chức buổi casting (tuyển diễn viên) cho Thanh Sói. Phim mới khai thác thời trẻ của nữ trùm đường dây bắt cóc trong Hai Phượng. Do lấy bối cảnh quá khứ, diễn viên Thanh Hoa (trong Hai Phượng) không quay lại vai diễn.\r\n\r\nCác giám kháo casting (từ trái sang): Ngô Thanh Vân, người mẫu Xuân Lan, chuyên gia trang điểm Nam Trung. Ảnh: Ân Nguyễn.\r\n\r\nCác giám khảo casting (từ trái sang): Ngô Thanh Vân, người mẫu Xuân Lan, chuyên gia trang điểm Nam Trung. Ảnh: Ân Nguyễn.\r\n\r\nNgoài vai chính phim sắp tới, Ngô Thanh Vân hy vọng người được chọn có thể theo nghề lâu dài, kế thừa cô. \"Đối với tôi, đây là cơ hội để phát hiện một diễn viên thực thụ cho phim hành động. Tôi sẽ rèn luyện, hướng dẫn người này để thành đả nữ tiếp theo của màn ảnh Việt\", cô nói.\r\n\r\nĐúc kết từ kinh nghiệm bản thân, cô cho rằng ngoài thể lực và võ thuật, sao hành động cần đam mê và giàu nghị lực. \"Tôi mất hơn 20 năm để đứng ở vị trí này. Những bước đầu tiên sẽ rất khó, nhưng nếu bạn kiên trì, nỗ lực không ngừng nghỉ thì một ngày sẽ đứng ở vị trí của tôi\", Ngô Thanh Vân nói.\r\n\r\nNgô Thanh Vân chia sẻ về dự án và con đường thành \"đả nữ\".\r\n\r\nThanh Sói là phim Việt hiếm hoi có vai chính là người xấu. Ngô Thanh Vân cho biết kịch bản vẫn sẽ không theo hướng tiêu cực, đồng thời mang góc nhìn cởi mở về động cơ nhân vật. \"Tôi tin tất cả nhân vật xấu đều xuất phát từ lý do nào đó. Tôi nghĩ hướng khai thác này sẽ rất thú vị\", cô nói. Người đẹp nêu dẫn chứng phim Joker ăn khách gần đây, kể về một ác nhân nhưng vẫn được khán giả, giới phê bình khen ngợi.\r\n\r\nMột số sao trẻ đến tham gia casting là Katleen Phan Võ, MLee, Đồng Ánh Quỳnh, Chế Nguyễn Quỳnh Châu, Huỳnh Tuyết Anh. Hiện Thanh Sói đang ở khâu tìm diễn viên, đạo diễn và phát triển kịch bản. Ngô Thanh Vân là một trong các nhà sản xuất, ngoài ra có thể đảm nhận những vai trò khác. Dự án ra đời do độ ăn khách của Hai Phượng đầu năm, thu hơn 200 tỷ và được giới phê bình Âu Mỹ khen ngợi. Tác phẩm cũng đại diện Việt Nam ở hạng mục phim quốc tế tại Oscar 2020. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec blandit id purus sit amet vulputate. Sed massa mauris, tempus quis malesuada ac, tempor eget nisl. Nullam augue nunc, viverra vel augue sit amet, porta accumsan diam. Quisque molestie hendrerit neque, et aliquam nisi ullamcorper eget. Etiam consectetur ipsum eu risus facilisis pellentesque. Suspendisse non efficitur tortor. Quisque id orci ante. Curabitur a eleifend tellus. Phasellus ac odio quis velit ultrices vulputate varius ut metus. Proin ut ex vel libero fringilla porta. Etiam ullamcorper libero id quam ullamcorper, sed tempus dolor volutpat. Proin congue nisi leo, et efficitur mi dapibus nec. Cras ac porttitor dolor. Suspendisse convallis fringilla nibh, eu egestas nisl mattis quis. Nunc condimentum eleifend tempor.\r\n\r\nSuspendisse finibus sit amet velit non vehicula. Etiam malesuada nisl in diam cursus dignissim. Nulla aliquam diam massa, nec fermentum odio porttitor non. Aenean suscipit, lorem id tincidunt facilisis, odio metus faucibus eros, aliquam ultrices eros urna nec mi. Vivamus nunc enim, sollicitudin sit amet cursus vitae, imperdiet vitae erat. Donec purus leo, tempus ac imperdiet a, iaculis sed nibh. Donec at ex a mauris pharetra interdum id in ante.', 'ngo_thanh_van_casting.png', '2026-04-06', 'Publish', 0, 1, 'Actor'),
(19, 'Brad Pitt tham gia hoạt động bảo vệ môi trường tại Việt Nam', 'Hành động ý nghĩa của nam tài tử nhận được sự ủng hộ lớn từ cộng đồng.', 'Brad Pitt tích cực thúc đẩy \"nhuộm xanh\" kiến trúc qua việc hỗ trợ tài chính và tham gia thiết kế các dự án nhà ở bền vững, sử dụng vật liệu thân thiện với môi trường và năng lượng tái tạo. Nổi bật nhất là dự án Make It Right tại New Orleans, cam kết xây dựng nhà ở xã hội đạt chuẩn xanh, bền vững cho cộng đồng. \r\nCác thông tin chính về hoạt động kiến trúc của Brad Pitt:\r\nTầm nhìn chiến lược: Brad Pitt tập trung vào việc tạo ra các không gian sống bền vững, đặc biệt chú trọng vào việc sử dụng năng lượng tái tạo và vật liệu thân thiện với môi trường, đặc biệt tại các quốc gia đang phát triển.\r\nDự án Make It Right: Sau cơn bão Katrina, Pitt đã thành lập tổ chức Make It Right nhằm xây dựng các ngôi nhà xanh, có khả năng chống chịu cao, bền vững và chi phí hợp lý cho người dân tại New Orleans.\r\nThiết kế bền vững: Các dự án thường bao gồm tấm pin năng lượng mặt trời, hệ thống quản lý nước mưa, vật liệu tái chế và thiết kế tối ưu hóa ánh sáng tự nhiên.\r\nSự tham gia trực tiếp: Nam tài tử không chỉ tài trợ mà còn tham gia vào quá trình thiết kế, kết hợp với các kiến trúc sư nổi tiếng để tạo ra những công trình có tính thẩm mỹ và công năng cao. \r\nCác hoạt động này phản ánh cam kết lâu dài của Brad Pitt đối với việc bảo vệ môi trường và cải thiện điều kiện sống của cộng đồng thông qua kiến trúc xanh. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec blandit id purus sit amet vulputate. Sed massa mauris, tempus quis malesuada ac, tempor eget nisl. Nullam augue nunc, viverra vel augue sit amet, porta accumsan diam. Quisque molestie hendrerit neque, et aliquam nisi ullamcorper eget. Etiam consectetur ipsum eu risus facilisis pellentesque. Suspendisse non efficitur tortor. Quisque id orci ante. Curabitur a eleifend tellus. Phasellus ac odio quis velit ultrices vulputate varius ut metus. Proin ut ex vel libero fringilla porta. Etiam ullamcorper libero id quam ullamcorper, sed tempus dolor volutpat. Proin congue nisi leo, et efficitur mi dapibus nec. Cras ac porttitor dolor. Suspendisse convallis fringilla nibh, eu egestas nisl mattis quis. Nunc condimentum eleifend tempor.\r\n\r\nSuspendisse finibus sit amet velit non vehicula. Etiam malesuada nisl in diam cursus dignissim. Nulla aliquam diam massa, nec fermentum odio porttitor non. Aenean suscipit, lorem id tincidunt facilisis, odio metus faucibus eros, aliquam ultrices eros urna nec mi. Vivamus nunc enim, sollicitudin sit amet cursus vitae, imperdiet vitae erat. Donec purus leo, tempus ac imperdiet a, iaculis sed nibh. Donec at ex a mauris pharetra interdum id in ante.', 'brad_pitt_green.png', '2026-04-07', 'Publish', 0, 3, 'Actor'),
(20, 'Cặp đôi màn ảnh Tom Cruise và Nicole Kidman một thời giờ ra sao?', 'Nhìn lại hành trình tình yêu và sự nghiệp của hai ngôi sao hạng A.', ' Mỗi khi nhắc đến Emily Blunt và John Krasinski, bên cạnh sự nghiệp rực rỡ của hai ngôi sao điện ảnh hàng đầu người ta còn nghĩ ngay đến câu chuyện tình đẹp như cổ tích mà họ đã vun đắp sau gần hai thập kỷ.\r\nĐứng ngồi không yên khi ngắm body của nữ rapper quyến rũ nhất Hàn Quốc / Bỏng mắt khi chiêm ngưỡng body của nữ idol sexy nhất xứ Hàn\r\n\r\nCùng với màn ra mắt của Vùng Đất Câm Lặng: Ngày Một (tựa gốc: A Quiet Place: Day One), một lần nữa cùng nhìn lại hành trình của cả hai từ khi còn là những diễn viên triển vọng cho đến bộ đôi quyền lực của Hollywood.\r\nChưa gặp gỡ nhưng đã kịp xem phim của “idol” tới tận 70 lần\r\nt\r\nEmily Blunt và John Krasinski\r\n\r\nMặc dù cặp đôi chưa gặp nhau, ngôi sao của “The Office” đã trở thành người hâm mộ của người vợ tương lai của anh khi “The Devil Wears Prada” ra mắt vào tháng 6 năm 2006. Sau đó, Krasinski thừa nhận với Blunt rằng anh đã xem đi xem lại bộ phim này.\r\nTrong một cuộc phỏng vấn năm 2016 với Glamour, nam diễn viên nhớ lại rằng sau khi cặp đôi hẹn hò được một thời gian, Blunt đã hỏi anh rằng anh đã từng xem bộ phim này chưa.\r\n\"Tôi nói, Có, và cô ấy nói, Bao nhiêu lần? Và tôi nói, Nhiều lắm. Cô ấy nói, Nhiều là bao nhiêu? Và tôi nói, 75 lần\", anh kể lại. \"Tôi thật may mắn khi cô ấy ở lại với tôi và không nhận ra rằng mình thực sự đã kết hôn với một kẻ rình rập ám ảnh!\"\r\nTừ lần gặp gỡ “nhạt nhẽo” đầu tiên\r\n\r\n\r\nThời điểm năm 2008 John Krasinski từng có thời gian hẹn hò với bạn diễn Rashida Jones. Trong khi đó, Emily Blunt vừa trải qua mối tình tan vỡ với ca sĩ Michael Bublé. Họ tình cờ gặp nhau trong một nhà hàng nhờ người bạn chung.\r\nNhớ lại kỷ niệm đó, Emily Blunt chia sẻ: “Lần đầu gặp nhau hạt nhài vậy đó. Anh ấy ăn tối ở nhà hàng, tôi ăn tối ở nhà hàng. Anh bạn Gary tự nhiên kêu lên “Chúa ơi, kia là anh bạn John của tôi”. Chuyện thế đấy. John (Krasinski) đang ngồi với Justin Theroux và rồi bỏ rơi luôn Justin để qua nói chuyện với tôi. Anh ấy cũng không ăn mà chỉ ngồi đó tâm sự và khiến tôi cười mãi”. Chị thì “băng lãnh” nhưng cái sự si mê đã toát ra từ anh lộ lắm rồi!\r\nCảm mến đối phương, cả hai quyết định hẹn hò nhưng tới nay, vẫn không ai chịu thừa nhận ai mới là người mời người kia đi ăn tối trước.\r\nRa mắt thảm đỏ và đính hôn\r\nSau đó một năm, Emily Blunt và John Krasinski có màn ra mắt thảm đỏ đầu tiên tay trong tay tại sự kiện SAG Awards. Sau đó 8 tháng cặp đôi đính hôn, mà sau này Krasinski chia sẻ anh đã “rất hồi hộp. Đó là một khoảnh khắc giản dị nhưng đầy cảm xúc. Và sau đó chúng tôi đều khóc”.\r\nTháng 7/2010: Đám cưới trong mơ\r\n\r\n\r\nVào ngày 10 tháng 7 năm 2010, cặp đôi đã kết hôn trong một buổi lễ yên tĩnh tại điền trang của George Clooney ở Hồ Como, Ý. Trong sự kiện này, Blunt mặc một chiếc váy Marchesa được thiết kế riêng, cùng với một viên kim cương tròn ba carat và chiếc nhẫn bạch kim từ Neil Lane. Một sự cố nhỏ đã xảy ra mà sau này được nữ diễn viên chia sẻ trong chương trình The Late Late Show With James Corden: “Tôi đã xịt da nâu không chuẩn. Trên ảnh trông tôi có một màu cam thật kỳ quặc. Chưa kể hôm đó trời còn nóng, mồ hôi thì túa khắp nơi và tôi mặc đồ trắng nữa. Kết quả mà màu cam cứ chảy ra, thật kinh khủng”.\r\nKrasinski chia sẻ với Elle ngay tại buổi hôn lễ, Clooney đã trao tặng điền trang của mình cho cặp đôi.\r\n“Chỉ đến lần thứ tư được hỏi tôi mới đồng ý. Bởi vì ba lần đầu tiên tôi nghĩ, không đời nào anh ấy nghiêm túc\", anh chia sẻ. \"Nhưng tôi bắt đầu thấy anh ấy tỏ ra đau khổ. Thế đấy, tôi đã làm tổn thương George Clooney”.\r\nTháng 2/2014: Chào đón đứa con đầu lòng\r\nVào ngày 16 tháng 2, Krasinski đã thông báo về sự ra đời của cô con gái đầu lòng của họ, Hazel Grace, thông qua mạng xã hội X (trước đây là Twitter): “Tôi muốn trực tiếp thông báo tin tức này. Emily và tôi vô cùng hạnh phúc khi được chào đón con gái Hazel của chúng tôi đến với thế giới ngày hôm nay! Chúc mừng sinh nhật!”\r\nTiếp tục là những khoảnh khắc “phát cẩu lương” cho cả thế giới phải trầm trồ\r\n\r\n\r\nTại lễ trao giải Critics Choice Awards năm 2015, Blunt đã mang về giải thưởng Nữ diễn viên chính xuất sắc nhất trong phim hành động cho vai diễn trong “The Edge of Tomorrow”. Khi nữ diễn viên bước lên sân khấu để phát biểu nhận giải, cô đã bị chồng mình ngắt lời một cách đáng yêu, anh chạy đến ôm vợ chúc mừng.\r\nTrả lời phỏng vấn với People, John vẫn không giấu được sự “cuồng vợ” khi anh cho biết mình là fan chân chính số 1 của Blunt: “Lấy nhau rồi tôi còn vui hơn ngày tôi gặp cô ấy, thật dữ dội. Tôi không biết công thức cho điều đó, nhưng tôi nghĩ cô ấy rất hài hước, cực kỳ tài năng và tôi chắc chắn là người hâm mộ số 1 của cổ”.\r\nHơn một năm sau khi chào đón con gái Hazel, Krasinski cho biết điều này cũng đã thay đổi cuộc sống của họ. “Tôi nghĩ khi bạn dành cả cuộc đời mình cho bất cứ điều gì như thế, mọi thứ sẽ thay đổi. Tất cả những câu sáo rỗng giờ nghe có lý cả”. Vào tháng 6 năm 2016, cặp đôi này đã ăn mừng sự ra đời của cô con gái thứ hai, Violet. Krasinski một lần nữa lên Twitter để chia sẻ tin vui vào ngày 4 tháng 7.\r\n\r\nDự án đầu tiên đánh dấu màn “song kiếm hợp bích”\r\n\r\n\r\nSau nhiều năm thực hiện các dự án diễn xuất riêng biệt, Blunt và Krasinski đã công bố lần hợp tác đầu tiên của họ vào tháng 3 năm 2017. Cặp đôi này xác nhận họ đang cùng nhau thực hiện một bộ phim kinh dị mới có tên “Vùng Đất Câm Lặng” (tự gốc: A Quiet Place).\r\nKrasinski đăng bức ảnh cả hai chụp chung lên Instagram với caption: “Diễn viên nào bạn muốn đóng cùng? Câu trả lời có ở trên”.\r\nDù bận rộn với những dự án riêng và cuộc sống làm mẹ, chính Emily Blunt là người thuyết phục John Krasinski phát triển dự án Vùng Đất Câm Lặng với ý tưởng độc đáo về những con quái vật săn mồi bằng âm thanh. Bản thân Krasinski rất hy vọng vợ nhận vai chính, nhưng anh đã kiên nhẫn đợi cho đến khi Blunt chủ động ngỏ lời, bởi anh không muốn cô tham gia chỉ vì cả nể. “Tôi không muốn đây là công việc duy nhất mà cô ấy nói rằng, ‘Nghe này, em không biết em có thích công việc này không, nhưng em yêu anh, nên em sẽ làm.”', 'tom_nicole_history.png', '2026-04-08', 'Publish', 0, 1, 'Actor'),
(21, 'Nghệ sĩ Trấn Thành tổ chức triển lãm kịch bản cá nhân', 'Khám phá tư duy sáng tạo của anh phía sau những trang bản thảo.', 'Trong hai ngày 10 và 11/01/2026, UBND Thành phố Hà Nội tổ chức Chương trình “Tụ hội Sáng tạo”, mở đầu cho hành trình hướng tới Lễ hội Thiết kế Sáng tạo Hà Nội diễn ra vào tháng 11/2026, đồng thời khởi động toàn diện các nhiệm vụ trọng tâm, đặt nền móng cho quá trình xây dựng hệ sinh thái sáng tạo đô thị Hà Nội.\r\n\r\nCác nội dung trong Kế hoạch 333 của UBND Thành phố Hà Nội từ tăng cường truyền thông, gia tăng kết nối cộng đồng sáng tạo, khảo sát không gian tiềm năng, thí điểm mô hình Trung tâm Công nghiệp văn hóa đến huy động nguồn lực xã hội và chuẩn bị cho cao điểm Lễ hội đều được kích hoạt đồng bộ ngay từ giai đoạn đầu.\r\n\r\nGần 200 đơn vị sẽ tham gia chuỗi hoạt động trong 2 ngày:\r\n\r\nTập hợp và giới thiệu các sáng kiến tiêu biểu thuộc 8 lĩnh vực công nghiệp văn hoá, tôn vinh tinh thần sáng tạo và các giải pháp đổi mới trong cộng đồng sáng tạo.\r\nGiới thiệu các sản phẩm, dịch vụ công nghiệp văn hoá có tính thiết kế, thủ công mỹ nghệ và nghệ thuật, trong đó tập trung vào các sản phẩm sẵn sàng thương mại của các nhà thiết kế, nghệ nhân và nhà sản xuất địa phương… Từ đó thúc đẩy kết nối, xúc tiến và phát triển thương mại giữa nhà thực hành sáng tạo với các nhà bán lẻ, nhà bán buôn, đơn vị cung cấp giải pháp quà tặng, đơn vị xuất khẩu và các đối tác thị trường, nhằm tìm kiếm và hình thành các giải pháp phân phối sản phẩm công nghiệp văn hoá phù hợp, bền vững và có khả năng mở rộng.\r\nGiới thiệu mô hình phát triển công nghiệp văn hoá của Thủ đô Hà Nội, công bố các không gian, địa điểm có tiềm năng tái thiết và phát triển thành không gian sáng tạo, hướng tới việc xây dựng hệ sinh thái sáng tạo và thúc đẩy nền kinh tế sáng tạo Hà Nội.\r\nHoạt động gặp gỡ, kết nối và ký kết hợp tác giữa các doanh nghiệp, cơ sở đào tạo, cơ quan quản lý văn hóa và các đối tác sáng tạo, qua đó hình thành mạng lưới liên kết đa chiều, hỗ trợ phát triển các sáng kiến, sản phẩm và mô hình công nghiệp văn hóa trong hệ sinh thái sáng tạo của Thủ đô.\r\nVề Hoạt động trong Chương trình “Tụ hội sáng tạo”\r\n\r\nThời gian: Ngày 10, 11/01/2026\r\nĐịa điểm: Quảng trường Đông Kinh Nghĩa Thục, Nhà Bát Giác, các không gian công cộng và tuyến phố đi bộ khu vực hồ Hoàn Kiếm\r\nĐơn vị chỉ đạo: UBND Thành phố Hà Nội và Hội Kiến trúc sư Việt Nam\r\nĐơn vị đồng hành: UN-Habitat; UNESCO & Tập đoàn SOVICO\r\nĐơn vị tổ chức: Sở Văn hóa và Thể thao Hà Nội và Tạp chí Kiến trúc\r\nVà các đối tác, bao gồm nhà tài trợ Honda, Viglacera, Lotte, Lixil, LG, Minh Long, Tasco và đông đảo các cá nhân, tổ chức hoạt động tích cực trong các lĩnh vực.\r\nChương trình “Tụ hội sáng tạo” là hoạt động chào mừng Đại hội Đảng toàn quốc lần thứ XIV nhiệm kỳ 2026 -2031 và thực hiện các nhiệm vụ Nghị quyết 57-NQ/TW của Bộ Chính trị ban hành ngày 22/12/2024 xác định phát triển Khoa học, Công nghệ, Đổi mới Sáng tạo và Chuyển đổi số.\r\n\r\nChương trình “Tụ hội sáng tạo” do Ủy ban nhân dân thành phố Hà Nội và Hội Kiến trúc sư Việt Nam chỉ đạo, Sở Văn hóa và Thể thao Hà Nội và Tạp chí Kiến trúc là đơn vị tổ chức. Chương trình diễn ra với sự đồng hành của UNESCO, tập đoàn SOVICO và tổ chức UN-Habitat và nhận được sự tài trợ của các thương hiệu HONDA, LOTTE, LIXIL, LG và Minh Long…\r\n\r\n-----\r\n\r\nNhóm hoạt động nổi bật\r\n\r\n(1) Lễ Khai mạc Chương trình “Tụ hội Sáng tạo”\r\n\r\nThời gian: 18:30 - 20:00 ngày 10/01/2026\r\nĐịa điểm: Sân khấu Quảng trường Đông Kinh Nghĩa Thục\r\nLễ Khai mạc mở đầu bằng chương trình nghệ thuật chủ đề “Tứ hải giao tình” bởi nền tảng văn hóa & nghệ thuật Lên Ngàn thực hiện, tôn vinh tinh thần sáng tạo gắn với bản sắc văn hóa Thủ đô. Tiếp đó là phát biểu khai mạc của Lãnh đạo Thành phố Hà Nội, phát biểu đồng hành của UNESCO và công bố ký kết các thỏa thuận hợp tác với các đơn vị đồng hành. Nghi lễ Khởi động chính thức đánh dấu hành trình Lễ hội Thiết kế Sáng tạo Hà Nội 2026, mở ra chuỗi hoạt động sáng tạo diễn ra xuyên suốt trong năm. Tiếp nối là chương trình ca nhạc ONWARD “Mở lối tương lai xanh”, lan tỏa thông điệp sáng tạo, phát triển bền vững và hội nhập quốc tế.\r\n\r\n(2) Diễn đàn Sáng tạo\r\n\r\nDiễn đàn Sáng tạo được tổ chức tại Nhà Bát Giác - Vườn hoa Lý Thái Tổ, là không gian đối thoại, chia sẻ và kết nối các sáng kiến, ý tưởng và mô hình phát triển sáng tạo gắn với đô thị, văn hóa và cộng đồng.\r\n\r\nTọa đàm Giới thiệu Đề án: Khảo sát các không gian tiềm năng trở thành không gian sáng tạo và Trung tâm công nghiệp văn hóa trong Thành phố\r\n- Thời gian: 10:30 - 12:00, Thứ Bảy 10/01/2026\r\n- Nội dung: Giới thiệu kết quả khảo sát các không gian tiềm năng chuyển đổi thành không gian sáng tạo tại Hà Nội, đặt nền tảng cho việc hình thành Trung tâm Công nghiệp Văn hóa và phát triển hạ tầng sáng tạo đô thị.\r\n- Đơn vị chỉ đạo: UBND Thành phố Hà Nội và Hội Kiến trúc sư Việt Nam\r\n- Đơn vị tổ chức: Sở Văn hoá & Thể thao Hà Nội, Tạp chí Kiến trúc - Hội Kiến trúc sư Việt Nam\r\nĐơn vị thực hiện: ECUE / Mạng lưới Vì Một Hà Nội Đáng Sống, Trường Đại học Xây dựng Hà Nội - Khoa Kiến trúc và Quy hoạch, Trường Khoa học Liên ngành & Nghệ thuật – Khoa Công nghiệp Văn hoá và Di sản\r\nTọa đàm ra mắt sách: Kiến tạo thay đổi - Hành trình kiến tạo những cộng đồng đáng sống ở Đông Nam Á\r\n- Thời gian: 14:00 - 16:00, Thứ Bảy 10/01/2026\r\n- Nội dung: Chia sẻ các nghiên cứu và thực hành kiến tạo cộng đồng đô thị bền vững tại Đông Nam Á, gợi mở những cách tiếp cận mới trong kiến trúc, quy hoạch và phát triển cộng đồng.\r\n- Đơn vị bảo trợ: Hội Kiến trúc sư Việt Nam\r\n- Đơn vị tổ chức: Tạp chí Kiến Trúc (TCKT), enCity, NXB Omega Plus\r\nTọa đàm: Từ Lễ hội thường niên đến Hệ sinh thái Sáng tạo đô thị\r\n- Thời gian:10:00 - 12:00, Chủ Nhật 11/01/2026\r\n- Nội dung: Thảo luận vai trò mới của Lễ hội Thiết kế Sáng tạo Hà Nội như một nền tảng thúc đẩy hệ sinh thái sáng tạo đô thị, kết nối chính sách, cộng đồng và kinh tế sáng tạo của Thủ đô.\r\n- Đơn vị tổ chức: Ban Tổ chức Lễ hội Thiết kế Sáng tạo Hà Nội\r\nTọa đàm: Giới thiệu Dự án Nghệ thuật Đồng Xuân\r\n- Thời gian: 14:00 - 16:00, Chủ Nhật 11/01/2026\r\n- Nội dung: Giới thiệu các dự án sáng tạo hướng tới tái thiết Chợ Đồng Xuân, làm rõ tiềm năng kết nối di sản, thương mại và sáng tạo trong phát triển công nghiệp văn hóa đô thị.\r\n- Đơn vị tổ chức: Ban Tổ chức Lễ hội Thiết kế Sáng tạo Hà Nội\r\n(3) Trưng bày - Triển lãm\r\n\r\nTrưng bày Khu vực Nhà Bát Giác Pavilion kiến trúc là không gian triển lãm do adrei studio thực hiện và NOTES giám tuyển, bố trí tại khu bãi cỏ trong khuôn viên nhà Bát Giác, phía sau tượng đài vua Lý Thái Tổ. Công trình được thiết kế như một kết cấu nhẹ, lấy cảm hứng từ cảnh quan tự nhiên, sử dụng hệ cây hiện hữu kết hợp mái nhiều lớp bằng vật liệu lưới, tạo hiệu ứng thị giác đa lớp, lọc ánh sáng và làm mềm không gian, góp phần hình thành một điểm nhấn hài hòa trong cảnh quan đô thị. Về công năng, pavilion là nơi trưng bày tổng kết các thành tựu của Lễ hội Thiết kế Sáng tạo Hà Nội qua các mùa từ 2021, đồng thời là nơi tổ chức các hoạt động hội thảo, trao đổi chuyên đề liên quan đến di sản và sáng tạo.\r\n\r\nTrưng bày 90 Sáng kiến Công nghiệp Văn hoá Hà Nội\r\n\r\nGiới thiệu và trưng bày các sáng kiến sáng tạo tiêu biểu đến từ các cá nhân, nhóm và đơn vị hoạt động trong 8 lĩnh vực công nghiệp văn hóa gồm Kiến trúc, Thiết kế, Nghệ thuật liên ngành, Điện ảnh, Thời trang, Xuất bản, Công nghệ và Du lịch, với trụ cột ưu tiên là Kinh tế sáng tạo và Nghệ thuật liên ngành, hướng tới kết nối sáng tạo với đời sống đô thị, thị trường và cộng đồng. Không gian trưng bày được thiết kế như một nền tảng mở, nơi các ý tưởng, dự án và thực hành sáng tạo được giới thiệu dưới nhiều hình thức, từ bản vẽ, mô hình, nghiên cứu mẫu đến trải nghiệm tương tác. Hoạt động nhằm tôn vinh tinh thần sáng tạo, thúc đẩy đối thoại và kết nối giữa cộng đồng sáng tạo với công chúng, đối tác và các nguồn lực phát triển trong hệ sinh thái sáng tạo đô thị Hà Nội.\r\n\r\nTrưng bày Thương hiệu và Dự án sáng tạo từ Cộng đồng\r\n\r\nTrưng bày giới thiệu các thương hiệu và dự án sáng tạo đến từ cộng đồng, với sự tham gia của các đơn vị đào tạo nguồn nhân lực sáng tạo như Cao đẳng Nghệ thuật Hà Nội, Đại học Mở Hà Nội và Trường Khoa học Liên ngành và Nghệ thuật - Đại học Quốc gia Hà Nội; các doanh nghiệp Tập đoàn LOTTE, Trung tâm thương mại TASCO Mall cho tới các studio sáng tạo Ann Fengshui & Art, Đình Collective, Direction Design Studio, Gốm Việt (Canpus), Hai&ikigai, Lamphong Studio, Thời trang Thu Trần.\r\n\r\n(4) Quảng bá và Xúc tiến sản phẩm Công nghiệp văn hóa\r\n\r\nHoạt động Giới thiệu, quảng bá và xúc tiến sản phẩm công nghiệp văn hóa quy tụ gần 50 thương hiệu địa phương (local brands) hoạt động trong các lĩnh vực thiết kế, thủ công mỹ nghệ và nghệ thuật, mang đến không gian trưng bày sống động các sản phẩm sáng tạo gắn với văn hóa bản địa và tư duy đương đại. Tại đây, các đơn vị trực tiếp giới thiệu sản phẩm, thử nghiệm phản hồi thị trường và tìm kiếm cơ hội kết nối với nhà bán lẻ, nhà phân phối và đối tác phát triển giải pháp quà tặng - vật phẩm văn hóa. Nhiều thương hiệu đã được báo chí và công chúng biết đến như Bana Handcraft Studio, Đình Collective, Zó Project, Craftlink, AnCycle, Nón làng Chuông, Sơn mài Đường Lâm hay COMPLEX 01 tiếp tục góp mặt, cùng nhiều gương mặt mới, tạo nên bức tranh đa dạng và giàu tiềm năng của hệ sinh thái công nghiệp văn hóa Hà Nội.\r\n\r\n(5) Trình diễn Nghệ thuật Cộng đồng\r\n\r\nKhông gian sống động, nơi nghệ thuật và đời sống đô thị giao thoa. Các tiết mục được biểu diễn liên tiếp tại sân khấu cộng đồng, quy tụ nhiều loại hình từ di sản văn hóa phi vật thể như xẩm, hát xoan, ca trù, chèo đến các loại hình hiện đại acoustic, múa đương đại, trình diễn đường phố, thời trang trình diễn và rock. Cộng đồng nghệ sĩ tham gia đến từ các câu lạc bộ nghệ thuật như CLB Ngọc Trai Việt, Khôi Minh Band, Dragon Plus, T.Kids Talent, So A Music × Tự Dị Project, CLB Ca trù Hà Nội; các câu lạc bộ nghệ thuật từ các trường đại học, cao đẳng Hà Nội, cùng nguồn cảm hứng từ NSND Thúy Ngần, nghệ sĩ Hát Xoan, Dân ca Phú Thọ và các tiết mục hòa tấu nhạc cụ truyền thống như sáo, trống, đàn bầu, đàn nguyệt do CLB Fan Club gồm các nghệ sĩ khiếm thị trình diễn, lan tỏa giá trị nhân văn.\r\n\r\nCác hoạt động chi tiết xem tại đây.\r\n\r\n------\r\n\r\nVề Lễ hội Thiết kế Sáng tạo Hà Nội 2026\r\n\r\nBước chuyển từ lễ hội thường niên đến hệ sinh thái sáng tạo đô thị\r\n\r\nNăm 2019, Hà Nội gia nhập Mạng lưới các Thành phố Sáng tạo của UNESCO (UCCN) ở lĩnh vực Thiết kế. Từ đó tới nay, Hà Nội đã triển khai nhiều chương trình đổi mới và hội nhập trên nền tảng: “Lấy sự sáng tạo và coi nền kinh tế sáng tạo làm cốt lõi trong tiến trình phát triển thành phố năng động, toàn diện và bền vững”.\r\n\r\nLễ hội Thiết kế sáng tạo Hà Nội là một trong những sáng kiến hành động mà thành phố Hà Nội cam kết thực hiện khi gia nhập Mạng lưới Thành phố sáng tạo của UNESCO. Qua những kỳ tổ chức từ 2021 đến nay, Lễ hội đã thực sự trở thành một điểm sáng, nơi các tài năng, tác phẩm, sản phẩm và mô hình kinh doanh sáng tạo được tụ hội và kết nối với công chúng, thúc đẩy đời sống kinh tế sáng tạo đô thị và gia tăng cơ hội hưởng thụ văn hóa của người dân.\r\n\r\nTừ năm 2021 đến nay, Lễ hội đã mở ra những không gian trải nghiệm sáng tạo mới lạ cho công chúng, giúp \"đánh thức\" các công trình di sản đa dạng, các không gian công cộng và địa điểm mang đậm dấu ấn Hà Nội. Một số địa điểm như: Trung tâm Văn hóa Nghệ thuật 22 Hàng Buồm (2021), Nhà máy Xe lửa Gia Lâm, Tháp nước Hàng Đậu (2023), Nhà khách Chính phủ (trước kia là Bắc Bộ Phủ), Tầng áp mái của khán phòng Ngụy Như Kon Tum thuộc Đại học Khoa học Tự nhiên và Đại học Dược (2024) … lần đầu mở cửa đón công chúng thông qua các triển lãm, trưng bày, sắp đặt và trình diễn nghệ thuật độc đáo.\r\n\r\nQua 4 mùa tổ chức, các hoạt động của Lễ hội đã thu hút sự quan tâm ngày càng mạnh mẽ của công chúng. Năm 2023, Lễ hội ghi nhận hơn 60 hoạt động với trên 200.000 lượt khách tham gia. Năm 2024, số hoạt động đã tăng lên hơn 110 hoạt động, thu hút trên 300.000 lượt khách.\r\n\r\nLễ hội Thiết kế sáng tạo Hà Nội không chỉ làm sống lại những di sản bị lãng quên, chuyển đổi không gian sáng tạo, kết nối giới trẻ và cộng đồng mà quan trọng hơn, đã tụ hội những nguồn lực, khai thác những tiềm năng, thúc đẩy các chính sách phát triển kinh tế sáng tạo của Thủ đô.\r\n\r\nLễ hội Thiết kế sáng tạo Hà Nội 2026, mùa thứ 5, được định hướng tổ chức hoạt động vượt lên một sự kiện văn hóa nghệ thuật thường niên với việc chuyển dịch từ “Tổ chức lễ hội” sang “Xây dựng hệ sinh thái sáng tạo đô thị” và phát triển tư duy liên ngành, kết nối: Nghệ thuật thị giác - Thiết kế - Công nghệ - Kiến trúc - Âm thanh - Dữ liệu - Thủ công - Trình diễn… tạo nên các trải nghiệm đa giác quan, các hình thức nghệ thuật mới và không gian tương tác mang tính quốc tế.\r\n\r\nCác hoạt động chính trong Lễ hội Thiết kế sáng tạo 2026 được tổ chức theo định hướng xây dựng nền kinh tế sáng tạo - trung tâm kết nối, diễn đàn và thử nghiệm mô hình kinh tế sáng tạo. Các nhóm hoạt động được triển khai xuyên suốt năm 2026, bao gồm triển lãm sáng tạo, hội chợ sáng tạo, diễn đàn sáng tạo, cuộc thi sáng tạo, các dự án sáng tạo, giải thưởng thiết kế sáng tạo, quỹ sáng tạo và hệ thống cơ sở hạ tầng sáng tạo.\r\n\r\nCác chặng hành trình đến Lễ hội Thiết kế Sáng tạo 2026\r\n\r\nChặng 1 (Tháng 1 - 2): Chương trình “Tụ hội sáng tạo“\r\nChặng 2 (Tháng 3 - 6): Thí điểm Mô hình hoạt động sáng tạo tại chợ Đồng Xuân; phát động Cuộc thi Thiết kế không gian sáng tạo 2026\r\nChặng 3 (Tháng 6, 8, 10): Chuỗi Tọa đàm “Đánh thức không gian đô thị” và tuyến lễ hội cộng hưởng; phát động chương trình “Mùa hè sáng tạo”\r\nChặng 4 (Tháng 11, 12): Lễ hội Thiết kế Sáng tạo Hà Nội 2026; Trao giải thưởng Thiết kế Sáng tạo.\r\n-----\r\n\r\nMỞ ĐĂNG KÝ DỰ ÁN & Ý TƯỞNG TRONG KHUÔN KHỔ LỄ HỘI THIẾT KẾ SÁNG TẠO HÀ NỘI 2026\r\n\r\nKính gửi: Các cá nhân, nhóm sáng tạo; nhà thiết kế; nghệ sĩ; kiến trúc sư; các doanh nghiệp, startup trong lĩnh vực sáng tạo; các đơn vị nghiên cứu - đào tạo; cùng các tổ chức, cá nhân đang ấp ủ ý tưởng, sáng kiến vì Hà Nội.\r\n\r\nTrong những năm qua, Lễ hội Thiết kế Sáng tạo Hà Nội đã nhận được sự quan tâm, đồng hành của cộng đồng sáng tạo và công chúng Thủ đô. Không chỉ giới thiệu các thành quả đã hoàn thiện, Lễ hội từng bước trở thành nền tảng kết nối, thử nghiệm, chia sẻ, tạo điều kiện để các dự án, đề án và sáng kiến ở nhiều mức độ phát triển được lắng nghe, được nhìn thấy và có cơ hội tiếp cận các nguồn lực phù hợp.\r\n\r\nNhằm tiếp tục phát huy vai trò của Lễ hội trong việc thúc đẩy hệ sinh thái sáng tạo đô thị, Ban Điều phối Lễ hội Thiết kế Sáng tạo Hà Nội 2026 trân trọng thông báo và mời gọi các dự án, ý tưởng sáng tạo (sau đây gọi chung là sáng kiến) đăng ký tham gia các hoạt động sau:\r\n\r\n(1) Trưng bày và kết nối trong Chương trình Khởi động “Tụ hội Sáng tạo”, diễn ra vào ngay đầu năm tháng 01/2026 tại không gian đi bộ hồ Hoàn Kiếm.\r\n\r\n(2) Ghi danh vào danh bạ sáng kiến sáng tạo Hà Nội, có cơ hội được đánh giá và xem xét hỗ trợ phát triển phù hợp.\r\n\r\nBan Điều phối Lễ hội tiếp nhận các sáng kiến tập trung ở 08 lĩnh vực thuộc công nghiệp văn hóa sáng tạo gồm: Kiến trúc, Thiết kế, Nghệ thuật liên ngành, Điện ảnh, Thời trang, Xuất bản, Công nghệ và Du lịch. Các tổ chức, cá nhân đang hoạt động, nghiên cứu hoặc phát triển ý tưởng trong các lĩnh vực nêu trên được khuyến khích tham gia đăng ký.\r\n\r\nCác sáng kiến có thể được tiếp cận và phát triển thông qua nhiều loại hình của hệ sinh thái sáng tạo như: triển lãm, hội chợ sáng tạo, toạ đàm - diễn đàn, dự án thử nghiệm, không gian sáng tạo hay các mô hình kết nối nguồn lực. Dù ý tưởng của bạn đang ở giai đoạn phác thảo hay đã bước đầu triển khai, đều có cơ hội được ghi nhận và trưng bày.\r\n\r\nMức độ hoàn thiện của sáng kiến\r\n\r\nThành phố khuyến khích các sáng kiến có tiềm năng, tư duy sáng tạo và khả năng tạo giá trị cho cộng đồng - đô thị - văn hóa Hà Nội.\r\n\r\nSáng kiến có thể đăng ký nếu thuộc một trong các nhóm sau:\r\n\r\nSáng kiến đã triển khai thành dự án và đang cần nguồn lực để mở rộng, nâng cấp, tái kích hoạt hoặc phát triển giai đoạn tiếp theo;\r\nSáng kiến đang ở giai đoạn ý tưởng: đề án, nghiên cứu mẫu, concept thiết kế, thử nghiệm ban đầu;\r\nSáng kiến chưa từng trưng bày, cần không gian để nhận phản hồi, kết nối đối tác hoặc nhà đầu tư;\r\nÝ tưởng xuất phát từ thực tiễn đô thị - cộng đồng - di sản, hướng tới giải quyết các vấn đề xã hội, môi trường, không gian công cộng, đời sống văn hóa.\r\nĐề xuất đăng ký không bắt buộc phải hoàn thiện, không yêu cầu doanh thu và không giới hạn độ tuổi; Ban Điều phối Lễ hội khuyến khích các sáng kiến ở nhiều giai đoạn tham gia với tinh thần cởi mở và đồng hành. Điều quan trọng nhất là tổ chức/ cá nhân đề xuất nhận diện được một vấn đề từ thực tiễn đô thị - cộng đồng - văn hóa của Hà Nội, có cách tiếp cận sáng tạo thể hiện qua ý tưởng, giải pháp hoặc phương thức triển khai phù hợp bối cảnh, đồng thời sẵn sàng chia sẻ hành trình phát triển sáng kiến với cộng đồng để tạo đối thoại, học hỏi và kết nối nguồn lực, hướng tới gia tăng tác động tích cực cho Thủ đô.\r\n\r\nHình thức trưng bày và giới thiệu sáng kiến\r\n\r\nCác sáng kiến được lựa chọn dự kiến trưng bày, giới thiệu tại Không gian “Con đường Sáng tạo” trong khuôn khổ Chương trình Khởi động “Tụ hội Sáng tạo - Hành trình tới Lễ hội Thiết kế Sáng tạo Hà Nội 2026”, diễn ra ngày 10 - 11/01/2026 tại khu vực tượng đài Lý Thái Tổ, không gian đi bộ hồ Hoàn Kiếm.\r\n\r\nKhông gian trưng bày được thiết kế theo hình thức sắp đặt mở, mang tính biểu trưng về hành trình xây dựng hệ sinh thái sáng tạo đô thị; các sáng kiến sẽ được giới thiệu theo các hình thức phù hợp, gồm:\r\n\r\nBản vẽ, poster, pano;\r\nMô hình, prototype;\r\nPhim dự án, video trình bày;\r\nNghiên cứu mẫu, hình ảnh tư liệu;\r\nTrải nghiệm tương tác (nếu phù hợp).\r\nNgoại trừ một số dự án đặc thù cần diện tích lớn hoặc yêu cầu kỹ thuật riêng, Ban Tổ chức dự kiến hỗ trợ miễn phí không gian trưng bày đối với các sáng kiến có quy mô vừa và nhỏ.\r\n\r\nĐây ngoài là nơi trưng bày mà còn là không gian kết nối nhằm tạo điều kiện để các tổ chức, cá nhân tham gia tiếp cận, trao đổi và thiết lập hợp tác với các đối tác, cộng sự, chuyên gia và các đơn vị liên quan, qua đó hỗ trợ quá trình hoàn thiện, phát triển và triển khai sáng kiến trong giai đoạn tiếp theo.\r\n\r\nHướng dẫn đăng ký\r\n\r\nCó 02 trụ cột xuyên suốt của Lễ hội 2026: Kinh tế sáng tạo - nơi sáng tạo gắn với sinh kế và cộng đồng; và Nghệ thuật liên ngành - nơi các ý tưởng mới, cách tiếp cận mới được thử nghiệm trong dòng chảy sáng tạo đương đại. \r\n\r\nĐường dẫn đăng ký: https://forms.gle/bHRsY1kH96iWsj7b6\r\nHạn gửi thông tin:\r\nĐợt 1: Trước ngày 5/1/2026\r\nĐợt 2: Trước ngày 5/3/2026\r\nĐợt 3: Trước ngày 5/6/2026\r\nBan Điều phối Lễ hội trân trọng đề nghị các cơ quan, tổ chức, đơn vị, cộng đồng sáng tạo và cá nhân quan tâm phối hợp lan tỏa thông tin tới các founder, nhà sáng tạo, tác giả dự án, sinh viên, nhóm khởi nghiệp, studio sáng tạo và doanh nghiệp có sáng kiến phù hợp, nhằm mở rộng mạng lưới kết nối và thúc đẩy các dự án tạo tác động tích cực cho Thủ đô.\r\n\r\nLễ hội Thiết kế Sáng tạo Hà Nội 2026 mong muốn đồng hành cùng cộng đồng sáng tạo từ giai đoạn ý tưởng ban đầu, để các “hạt mầm” hôm nay từng bước phát triển thành những dự án có giá trị và tác động thực tiễn đối với thủ đô Hà Nội.', 'tran_thanh_gallery.png', '2026-04-09', 'Publish', 0, 1, 'Actor'),
(22, 'Denzel Washington - Giọng nói truyền cảm hứng nhất Hollywood', 'Tìm hiểu tầm ảnh hưởng của ông qua những bài phát biểu bất hủ.', 'Tổng hợp những bài diễn thuyết và câu nói hay nhất của Denzel Washington về lòng kiên trì và đạo đức nghề nghiệp. Bài viết phân tích sức mạnh trong giọng nói và tầm ảnh hưởng của ông đối với các thế hệ diễn viên trẻ thông qua những bài phát biểu gây bão tại các lễ tốt nghiệp đại học danh tiếng.', 'denzel_speech.png', '2026-04-10', 'Publish', 0, 1, 'Actor');
INSERT INTO `tbl_new` (`New_ID`, `New_Title`, `New_Description`, `New_Content`, `New_Img`, `New_PublishDate`, `New_Status`, `New_View`, `Account_ID`, `New_Category`) VALUES
(23, 'Sự thay đổi ngoại hình của Christian Bale cho vai diễn Người Dơi', 'Khán giả kinh ngạc trước khả năng tăng giảm cân thần tốc của anh.', 'Bài viết so sánh hình ảnh qua các thời kỳ đóng phim đầy kinh ngạc của Christian Bale, từ gầy gò trong The Machinist đến cơ bắp trong Batman. Khán giả sẽ được tìm hiểu về nỗ lực tăng giảm cân thần tốc và sự hy sinh vì nghệ thuật đến mức cực đoan của nam diễn viên tài năng này.\r\n    \r\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Donec blandit id purus sit amet vulputate. Sed massa mauris, tempus quis malesuada ac, tempor eget nisl. Nullam augue nunc, viverra vel augue sit amet, porta accumsan diam. Quisque molestie hendrerit neque, et aliquam nisi ullamcorper eget. Etiam consectetur ipsum eu risus facilisis pellentesque. Suspendisse non efficitur tortor. Quisque id orci ante. Curabitur a eleifend tellus. Phasellus ac odio quis velit ultrices vulputate varius ut metus. Proin ut ex vel libero fringilla porta. Etiam ullamcorper libero id quam ullamcorper, sed tempus dolor volutpat. Proin congue nisi leo, et efficitur mi dapibus nec. Cras ac porttitor dolor. Suspendisse convallis fringilla nibh, eu egestas nisl mattis quis. Nunc condimentum eleifend tempor.\r\n\r\nSuspendisse finibus sit amet velit non vehicula. Etiam malesuada nisl in diam cursus dignissim. Nulla aliquam diam massa, nec fermentum odio porttitor non. Aenean suscipit, lorem id tincidunt facilisis, odio metus faucibus eros, aliquam ultrices eros urna nec mi. Vivamus nunc enim, sollicitudin sit amet cursus vitae, imperdiet vitae erat. Donec purus leo, tempus ac imperdiet a, iaculis sed nibh. Donec at ex a mauris pharetra interdum id in ante.\r\n\r\nNullam accumsan risus risus, a egestas orci suscipit vel. Phasellus vehicula, mi vel bibendum blandit, odio nibh elementum justo, ac efficitur diam dolor id sem. Mauris eu laoreet dolor, quis tristique tellus. Vestibulum sodales metus ac elit vestibulum mollis. Donec mi nisl, vehicula sed venenatis eget, tristique ac arcu. Sed consectetur posuere urna nec luctus. Sed sit amet maximus enim. Nunc mollis ante at sem rutrum, ut faucibus lectus interdum. Etiam sagittis est iaculis arcu interdum, eget lacinia lectus posuere. Duis turpis nulla, maximus id feugiat tristique, varius a justo. Morbi in dui fermentum, scelerisque massa vel, efficitur orci. Vestibulum fringilla rhoncus eleifend. Vivamus mattis, urna vel pretium semper, nisi lectus egestas justo, vel malesuada risus mauris nec mauris.\r\n\r\nNulla sodales luctus convallis. Mauris scelerisque ante ut mauris hendrerit dignissim. Suspendisse blandit finibus tellus, ac volutpat ipsum commodo vel. Nulla sapien libero, viverra egestas molestie non, pharetra quis odio. Etiam ultrices vel leo posuere venenatis. Aliquam consequat nunc sed dui rhoncus scelerisque. Duis quis augue vitae erat euismod volutpat. Donec pellentesque nulla lectus, quis euismod neque varius ac. Morbi laoreet velit volutpat dolor malesuada vehicula.\r\n\r\nMaecenas elit nisl, consectetur id nisl pulvinar, posuere aliquet libero. Mauris quam dui, pretium non lectus in, placerat efficitur magna. Nulla facilisi. Suspendisse sit amet rutrum elit. Proin augue magna, tristique tincidunt tempor at, ultrices vel nibh. Vivamus eget tortor at quam tincidunt dapibus id non erat. Integer varius, erat vitae imperdiet ultrices, urna odio accumsan nunc, at condimentum dui magna at eros. Suspendisse faucibus cursus sapien, et finibus nulla fringilla et. Proin ut accumsan nunc. Maecenas dignissim fringilla consequat. Nam massa arcu, dictum eu interdum nec, venenatis non massa. Maecenas quis sodales nibh. Suspendisse efficitur rutrum consequat. Morbi vitae hendrerit sem, id auctor tellus. Phasellus neque nisl, semper quis placerat consequat, semper et ante.\r\n\r\nGenerated 5 paragraphs, 487 words, 3321 bytes of Lorem Ipsum', 'bale_transformation.png', '2026-04-11', 'Publish', 0, 1, 'Actor'),
(24, 'Joaquin Phoenix lấn sân sang vai trò đạo diễn phim tài liệu', 'Một bước đi mới đầy hứa hẹn của nam diễn viên tài năng.', 'Một bước đi mới đầy hứa hẹn khi nam diễn viên Joaquin Phoenix thử sức ở vai trò đạo diễn cho một bộ phim tài liệu về biến đổi khí hậu. Bài viết cung cấp thông tin về chủ đề môi trường mà anh đang thực hiện, cùng những chia sẻ về tầm nhìn nghệ thuật khác biệt so với khi anh đứng trước ống kính.\r\n    \r\n    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec blandit id purus sit amet vulputate. Sed massa mauris, tempus quis malesuada ac, tempor eget nisl. Nullam augue nunc, viverra vel augue sit amet, porta accumsan diam. Quisque molestie hendrerit neque, et aliquam nisi ullamcorper eget. Etiam consectetur ipsum eu risus facilisis pellentesque. Suspendisse non efficitur tortor. Quisque id orci ante. Curabitur a eleifend tellus. Phasellus ac odio quis velit ultrices vulputate varius ut metus. Proin ut ex vel libero fringilla porta. Etiam ullamcorper libero id quam ullamcorper, sed tempus dolor volutpat. Proin congue nisi leo, et efficitur mi dapibus nec. Cras ac porttitor dolor. Suspendisse convallis fringilla nibh, eu egestas nisl mattis quis. Nunc condimentum eleifend tempor.\r\n\r\nSuspendisse finibus sit amet velit non vehicula. Etiam malesuada nisl in diam cursus dignissim. Nulla aliquam diam massa, nec fermentum odio porttitor non. Aenean suscipit, lorem id tincidunt facilisis, odio metus faucibus eros, aliquam ultrices eros urna nec mi. Vivamus nunc enim, sollicitudin sit amet cursus vitae, imperdiet vitae erat. Donec purus leo, tempus ac imperdiet a, iaculis sed nibh. Donec at ex a mauris pharetra interdum id in ante.\r\n\r\nNullam accumsan risus risus, a egestas orci suscipit vel. Phasellus vehicula, mi vel bibendum blandit, odio nibh elementum justo, ac efficitur diam dolor id sem. Mauris eu laoreet dolor, quis tristique tellus. Vestibulum sodales metus ac elit vestibulum mollis. Donec mi nisl, vehicula sed venenatis eget, tristique ac arcu. Sed consectetur posuere urna nec luctus. Sed sit amet maximus enim. Nunc mollis ante at sem rutrum, ut faucibus lectus interdum. Etiam sagittis est iaculis arcu interdum, eget lacinia lectus posuere. Duis turpis nulla, maximus id feugiat tristique, varius a justo. Morbi in dui fermentum, scelerisque massa vel, efficitur orci. Vestibulum fringilla rhoncus eleifend. Vivamus mattis, urna vel pretium semper, nisi lectus egestas justo, vel malesuada risus mauris nec mauris.\r\n\r\nNulla sodales luctus convallis. Mauris scelerisque ante ut mauris hendrerit dignissim. Suspendisse blandit finibus tellus, ac volutpat ipsum commodo vel. Nulla sapien libero, viverra egestas molestie non, pharetra quis odio. Etiam ultrices vel leo posuere venenatis. Aliquam consequat nunc sed dui rhoncus scelerisque. Duis quis augue vitae erat euismod volutpat. Donec pellentesque nulla lectus, quis euismod neque varius ac. Morbi laoreet velit volutpat dolor malesuada vehicula.\r\n\r\nMaecenas elit nisl, consectetur id nisl pulvinar, posuere aliquet libero. Mauris quam dui, pretium non lectus in, placerat efficitur magna. Nulla facilisi. Suspendisse sit amet rutrum elit. Proin augue magna, tristique tincidunt tempor at, ultrices vel nibh. Vivamus eget tortor at quam tincidunt dapibus id non erat. Integer varius, erat vitae imperdiet ultrices, urna odio accumsan nunc, at condimentum dui magna at eros. Suspendisse faucibus cursus sapien, et finibus nulla fringilla et. Proin ut accumsan nunc. Maecenas dignissim fringilla consequat. Nam massa arcu, dictum eu interdum nec, venenatis non massa. Maecenas quis sodales nibh. Suspendisse efficitur rutrum consequat. Morbi vitae hendrerit sem, id auctor tellus. Phasellus neque nisl, semper quis placerat consequat, semper et ante.\r\n\r\nGenerated 5 paragraphs, 487 words, 3321 bytes of Lorem Ipsum', 'joaquin_director.png', '2026-04-12', 'Publish', 2, 1, 'Actor'),
(25, 'Hành trình chinh phục Oscar của Angelina Jolie', 'Từ những vai diễn nổi loạn đến vị thế đạo diễn quyền lực.', 'Bài viết nhìn lại chặng đường từ những vai diễn nổi loạn thuở mới vào nghề đến vị thế đạo diễn và nhà hoạt động nhân đạo quyền lực. Cuộc phỏng vấn độc quyền tiết lộ những dự định tương lai và cách Angelina Jolie cân bằng giữa hào quang nghệ thuật với những sứ mệnh cao cả vì cộng đồng.\r\n    \r\n    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec blandit id purus sit amet vulputate. Sed massa mauris, tempus quis malesuada ac, tempor eget nisl. Nullam augue nunc, viverra vel augue sit amet, porta accumsan diam. Quisque molestie hendrerit neque, et aliquam nisi ullamcorper eget. Etiam consectetur ipsum eu risus facilisis pellentesque. Suspendisse non efficitur tortor. Quisque id orci ante. Curabitur a eleifend tellus. Phasellus ac odio quis velit ultrices vulputate varius ut metus. Proin ut ex vel libero fringilla porta. Etiam ullamcorper libero id quam ullamcorper, sed tempus dolor volutpat. Proin congue nisi leo, et efficitur mi dapibus nec. Cras ac porttitor dolor. Suspendisse convallis fringilla nibh, eu egestas nisl mattis quis. Nunc condimentum eleifend tempor.\r\n\r\nSuspendisse finibus sit amet velit non vehicula. Etiam malesuada nisl in diam cursus dignissim. Nulla aliquam diam massa, nec fermentum odio porttitor non. Aenean suscipit, lorem id tincidunt facilisis, odio metus faucibus eros, aliquam ultrices eros urna nec mi. Vivamus nunc enim, sollicitudin sit amet cursus vitae, imperdiet vitae erat. Donec purus leo, tempus ac imperdiet a, iaculis sed nibh. Donec at ex a mauris pharetra interdum id in ante.\r\n\r\nNullam accumsan risus risus, a egestas orci suscipit vel. Phasellus vehicula, mi vel bibendum blandit, odio nibh elementum justo, ac efficitur diam dolor id sem. Mauris eu laoreet dolor, quis tristique tellus. Vestibulum sodales metus ac elit vestibulum mollis. Donec mi nisl, vehicula sed venenatis eget, tristique ac arcu. Sed consectetur posuere urna nec luctus. Sed sit amet maximus enim. Nunc mollis ante at sem rutrum, ut faucibus lectus interdum. Etiam sagittis est iaculis arcu interdum, eget lacinia lectus posuere. Duis turpis nulla, maximus id feugiat tristique, varius a justo. Morbi in dui fermentum, scelerisque massa vel, efficitur orci. Vestibulum fringilla rhoncus eleifend. Vivamus mattis, urna vel pretium semper, nisi lectus egestas justo, vel malesuada risus mauris nec mauris.\r\n\r\nNulla sodales luctus convallis. Mauris scelerisque ante ut mauris hendrerit dignissim. Suspendisse blandit finibus tellus, ac volutpat ipsum commodo vel. Nulla sapien libero, viverra egestas molestie non, pharetra quis odio. Etiam ultrices vel leo posuere venenatis. Aliquam consequat nunc sed dui rhoncus scelerisque. Duis quis augue vitae erat euismod volutpat. Donec pellentesque nulla lectus, quis euismod neque varius ac. Morbi laoreet velit volutpat dolor malesuada vehicula.\r\n\r\nMaecenas elit nisl, consectetur id nisl pulvinar, posuere aliquet libero. Mauris quam dui, pretium non lectus in, placerat efficitur magna. Nulla facilisi. Suspendisse sit amet rutrum elit. Proin augue magna, tristique tincidunt tempor at, ultrices vel nibh. Vivamus eget tortor at quam tincidunt dapibus id non erat. Integer varius, erat vitae imperdiet ultrices, urna odio accumsan nunc, at condimentum dui magna at eros. Suspendisse faucibus cursus sapien, et finibus nulla fringilla et. Proin ut accumsan nunc. Maecenas dignissim fringilla consequat. Nam massa arcu, dictum eu interdum nec, venenatis non massa. Maecenas quis sodales nibh. Suspendisse efficitur rutrum consequat. Morbi vitae hendrerit sem, id auctor tellus. Phasellus neque nisl, semper quis placerat consequat, semper et ante.\r\n\r\nGenerated 5 paragraphs, 487 words, 3321 bytes of Lorem Ipsum', 'jolie_oscar_way.png', '2026-04-13', 'Publish', 9, 1, 'Actor');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_studio`
--

CREATE TABLE `tbl_studio` (
  `Studio_ID` int(10) NOT NULL,
  `Studio_Name` varchar(32) NOT NULL,
  `Studio_Info` varchar(225) DEFAULT NULL,
  `Studio_Social` varchar(225) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `tbl_studio`
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
-- Cấu trúc bảng cho bảng `tbl_watchlist`
--

CREATE TABLE `tbl_watchlist` (
  `Watchlist_ID` int(16) NOT NULL,
  `Watchlist_Name` varchar(64) NOT NULL,
  `Watchlist_Date` date NOT NULL,
  `Account_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `tbl_watchlist`
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
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `tbl_account`
--
ALTER TABLE `tbl_account`
  ADD PRIMARY KEY (`Account_ID`);

--
-- Chỉ mục cho bảng `tbl_actor`
--
ALTER TABLE `tbl_actor`
  ADD PRIMARY KEY (`Actor_ID`),
  ADD UNIQUE KEY `FK_Character_ID` (`Character_ID`);

--
-- Chỉ mục cho bảng `tbl_award`
--
ALTER TABLE `tbl_award`
  ADD PRIMARY KEY (`Award_ID`);

--
-- Chỉ mục cho bảng `tbl_award_actor`
--
ALTER TABLE `tbl_award_actor`
  ADD KEY `FK_Actor_ID` (`Actor_ID`) USING BTREE,
  ADD KEY `FK_Award_ID` (`Award_ID`) USING BTREE;

--
-- Chỉ mục cho bảng `tbl_award_director`
--
ALTER TABLE `tbl_award_director`
  ADD KEY `FK_Director_ID` (`Director_ID`) USING BTREE,
  ADD KEY `FK_Award_ID` (`Award_ID`) USING BTREE;

--
-- Chỉ mục cho bảng `tbl_award_studio`
--
ALTER TABLE `tbl_award_studio`
  ADD KEY `FK_Studio_ID` (`Studio_ID`) USING BTREE,
  ADD KEY `FK_Award_ID` (`Award_ID`) USING BTREE;

--
-- Chỉ mục cho bảng `tbl_character`
--
ALTER TABLE `tbl_character`
  ADD PRIMARY KEY (`Character_ID`),
  ADD KEY `FK_Actor_ID` (`Actor_ID`) USING BTREE,
  ADD KEY `FK_Movie_ID` (`Movie_ID`) USING BTREE;

--
-- Chỉ mục cho bảng `tbl_comment`
--
ALTER TABLE `tbl_comment`
  ADD PRIMARY KEY (`Comment_ID`),
  ADD KEY `FK_New_ID` (`New_ID`) USING BTREE,
  ADD KEY `FK_Account_ID` (`Account_ID`) USING BTREE;

--
-- Chỉ mục cho bảng `tbl_director`
--
ALTER TABLE `tbl_director`
  ADD PRIMARY KEY (`Director_ID`);

--
-- Chỉ mục cho bảng `tbl_feedback`
--
ALTER TABLE `tbl_feedback`
  ADD PRIMARY KEY (`Feedback_ID`),
  ADD KEY `FK_Movie_ID` (`Movie_ID`) USING BTREE,
  ADD KEY `FK_Account_ID` (`Account_ID`) USING BTREE;

--
-- Chỉ mục cho bảng `tbl_genre`
--
ALTER TABLE `tbl_genre`
  ADD PRIMARY KEY (`Genre_ID`);

--
-- Chỉ mục cho bảng `tbl_movie`
--
ALTER TABLE `tbl_movie`
  ADD PRIMARY KEY (`Movie_ID`),
  ADD KEY `FK_Account_ID` (`Account_ID`) USING BTREE;

--
-- Chỉ mục cho bảng `tbl_movie_director`
--
ALTER TABLE `tbl_movie_director`
  ADD KEY `FK_Director_ID` (`Director_ID`) USING BTREE,
  ADD KEY `FK_Movie_ID` (`Movie_ID`) USING BTREE;

--
-- Chỉ mục cho bảng `tbl_movie_genre`
--
ALTER TABLE `tbl_movie_genre`
  ADD KEY `FK_Genre_ID` (`Genre_ID`) USING BTREE,
  ADD KEY `FK_Movie_ID` (`Movie_ID`) USING BTREE;

--
-- Chỉ mục cho bảng `tbl_movie_studio`
--
ALTER TABLE `tbl_movie_studio`
  ADD KEY `FK_Studio_ID` (`Studio_ID`) USING BTREE,
  ADD KEY `FK_Movie_ID` (`Movie_ID`) USING BTREE;

--
-- Chỉ mục cho bảng `tbl_movie_watchlist`
--
ALTER TABLE `tbl_movie_watchlist`
  ADD KEY `FK_Watchlist_ID` (`Watchlist_ID`) USING BTREE,
  ADD KEY `FK_Movie_ID` (`Movie_ID`) USING BTREE;

--
-- Chỉ mục cho bảng `tbl_new`
--
ALTER TABLE `tbl_new`
  ADD PRIMARY KEY (`New_ID`),
  ADD KEY `FK_Account_Name` (`Account_ID`) USING BTREE;

--
-- Chỉ mục cho bảng `tbl_studio`
--
ALTER TABLE `tbl_studio`
  ADD PRIMARY KEY (`Studio_ID`);

--
-- Chỉ mục cho bảng `tbl_watchlist`
--
ALTER TABLE `tbl_watchlist`
  ADD PRIMARY KEY (`Watchlist_ID`),
  ADD KEY `FK_Account_ID` (`Account_ID`) USING BTREE;

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `tbl_account`
--
ALTER TABLE `tbl_account`
  MODIFY `Account_ID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT cho bảng `tbl_actor`
--
ALTER TABLE `tbl_actor`
  MODIFY `Actor_ID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT cho bảng `tbl_award`
--
ALTER TABLE `tbl_award`
  MODIFY `Award_ID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT cho bảng `tbl_character`
--
ALTER TABLE `tbl_character`
  MODIFY `Character_ID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=71;

--
-- AUTO_INCREMENT cho bảng `tbl_comment`
--
ALTER TABLE `tbl_comment`
  MODIFY `Comment_ID` int(16) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT cho bảng `tbl_director`
--
ALTER TABLE `tbl_director`
  MODIFY `Director_ID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT cho bảng `tbl_feedback`
--
ALTER TABLE `tbl_feedback`
  MODIFY `Feedback_ID` int(16) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=76;

--
-- AUTO_INCREMENT cho bảng `tbl_genre`
--
ALTER TABLE `tbl_genre`
  MODIFY `Genre_ID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT cho bảng `tbl_movie`
--
ALTER TABLE `tbl_movie`
  MODIFY `Movie_ID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT cho bảng `tbl_new`
--
ALTER TABLE `tbl_new`
  MODIFY `New_ID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55;

--
-- AUTO_INCREMENT cho bảng `tbl_studio`
--
ALTER TABLE `tbl_studio`
  MODIFY `Studio_ID` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT cho bảng `tbl_watchlist`
--
ALTER TABLE `tbl_watchlist`
  MODIFY `Watchlist_ID` int(16) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `tbl_award_actor`
--
ALTER TABLE `tbl_award_actor`
  ADD CONSTRAINT `fk_aa_actor` FOREIGN KEY (`Actor_ID`) REFERENCES `tbl_actor` (`Actor_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_aa_award` FOREIGN KEY (`Award_ID`) REFERENCES `tbl_award` (`Award_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `tbl_award_director`
--
ALTER TABLE `tbl_award_director`
  ADD CONSTRAINT `fk_ad_award` FOREIGN KEY (`Award_ID`) REFERENCES `tbl_award` (`Award_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_ad_director` FOREIGN KEY (`Director_ID`) REFERENCES `tbl_director` (`Director_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `tbl_award_studio`
--
ALTER TABLE `tbl_award_studio`
  ADD CONSTRAINT `fk_as_award` FOREIGN KEY (`Award_ID`) REFERENCES `tbl_award` (`Award_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_as_studio` FOREIGN KEY (`Studio_ID`) REFERENCES `tbl_studio` (`Studio_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `tbl_character`
--
ALTER TABLE `tbl_character`
  ADD CONSTRAINT `fk_character_actor` FOREIGN KEY (`Actor_ID`) REFERENCES `tbl_actor` (`Actor_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_character_movie` FOREIGN KEY (`Movie_ID`) REFERENCES `tbl_movie` (`Movie_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `tbl_comment`
--
ALTER TABLE `tbl_comment`
  ADD CONSTRAINT `fk_comment_account` FOREIGN KEY (`Account_ID`) REFERENCES `tbl_account` (`Account_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `tbl_feedback`
--
ALTER TABLE `tbl_feedback`
  ADD CONSTRAINT `fk_feedback_account` FOREIGN KEY (`Account_ID`) REFERENCES `tbl_account` (`Account_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_feedback_movie` FOREIGN KEY (`Movie_ID`) REFERENCES `tbl_movie` (`Movie_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `tbl_movie`
--
ALTER TABLE `tbl_movie`
  ADD CONSTRAINT `fk_movie_account` FOREIGN KEY (`Account_ID`) REFERENCES `tbl_account` (`Account_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `tbl_movie_director`
--
ALTER TABLE `tbl_movie_director`
  ADD CONSTRAINT `fk_md_director` FOREIGN KEY (`Director_ID`) REFERENCES `tbl_director` (`Director_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_md_movie` FOREIGN KEY (`Movie_ID`) REFERENCES `tbl_movie` (`Movie_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `tbl_movie_genre`
--
ALTER TABLE `tbl_movie_genre`
  ADD CONSTRAINT `fk_mg_genre` FOREIGN KEY (`Genre_ID`) REFERENCES `tbl_genre` (`Genre_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_mg_movie` FOREIGN KEY (`Movie_ID`) REFERENCES `tbl_movie` (`Movie_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `tbl_movie_studio`
--
ALTER TABLE `tbl_movie_studio`
  ADD CONSTRAINT `fk_ms_movie` FOREIGN KEY (`Movie_ID`) REFERENCES `tbl_movie` (`Movie_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_ms_studio` FOREIGN KEY (`Studio_ID`) REFERENCES `tbl_studio` (`Studio_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `tbl_movie_watchlist`
--
ALTER TABLE `tbl_movie_watchlist`
  ADD CONSTRAINT `fk_wlm_movie` FOREIGN KEY (`Movie_ID`) REFERENCES `tbl_movie` (`Movie_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_wlm_watchlist` FOREIGN KEY (`Watchlist_ID`) REFERENCES `tbl_watchlist` (`Watchlist_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `tbl_new`
--
ALTER TABLE `tbl_new`
  ADD CONSTRAINT `fk_new_account` FOREIGN KEY (`Account_ID`) REFERENCES `tbl_account` (`Account_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `tbl_watchlist`
--
ALTER TABLE `tbl_watchlist`
  ADD CONSTRAINT `fk_watchlist_account` FOREIGN KEY (`Account_ID`) REFERENCES `tbl_account` (`Account_ID`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
