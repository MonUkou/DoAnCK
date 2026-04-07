-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th4 07, 2026 lúc 10:12 AM
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
-- Cơ sở dữ liệu: `db_doanck`
--

DELIMITER $$
--
-- Thủ tục
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_AddMovie` (IN `pTitle` VARCHAR(128), IN `pDescription` VARCHAR(512), IN `pImg` VARCHAR(225), IN `pGenreID` INT, IN `pReleaseDate` DATE, IN `pStreamingDate` DATE, IN `pStudioID` INT, IN `pDirectorID` INT, IN `pActorID` INT, IN `pAccountID` INT)   BEGIN
    INSERT INTO tbl_movie(
        Movie_Title,
        Movie_Description,
        Movie_Img,
        Genre_ID,
        Movie_ReleaseDate,
        Movie_StreamingDate,
        Studio_ID,
        Director_ID,
        Actor_ID,
        Account_ID
    )
    VALUES(
        pTitle,
        pDescription,
        pImg,
        pGenreID,
        pReleaseDate,
        pStreamingDate,
        pStudioID,
        pDirectorID,
        pActorID,
        pAccountID
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_AddMovieToWatchlist` (IN `p_Movie_ID` INT, IN `p_Watchlist_ID` INT)   BEGIN
    INSERT IGNORE INTO `tbl_movie-watchlist` (Movie_ID, Watchlist_ID)
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
        g.Genre_Name AS Genre
    FROM tbl_movie m
    INNER JOIN tbl_genre g ON m.Genre_ID = g.Genre_ID
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
    INNER JOIN `tbl_movie-director` md 
        ON m.Movie_ID = md.Movie_ID
    WHERE md.Director_ID = p_DirectorID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetMoviesByGenre` (IN `pGenreID` INT)   BEGIN
   SELECT m.*, g.Genre_Name
   FROM tbl_movie m
   JOIN tbl_genre g
   ON m.Genre_ID = g.Genre_ID
   WHERE m.Genre_ID = pGenreID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetMoviesInWatchlist` (IN `p_Watchlist_ID` INT)   BEGIN
    SELECT m.* 
    FROM tbl_movie m
    JOIN `tbl_movie-watchlist` mw 
        ON m.Movie_ID = mw.Movie_ID
    WHERE mw.Watchlist_ID = p_Watchlist_ID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetMovieStatsByGenre` ()   BEGIN
    SELECT 
        g.Genre_Name AS Genre,
        COUNT(m.Movie_ID) AS MovieCount
    FROM tbl_genre g
    LEFT JOIN tbl_movie m ON g.Genre_ID = m.Genre_ID
    GROUP BY g.Genre_ID, g.Genre_Name;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_InsertAccount` (IN `Account_ID` INT(10) ZEROFILL, IN `Username` VARCHAR(32) CHARSET utf8mb4, IN `Password` VARCHAR(16) CHARSET utf8mb4, IN `Role_ID` ENUM('member','author','member-author') CHARSET utf8mb4, IN `Mail` VARCHAR(64) CHARSET utf8mb4, IN `Tel` INT(10) ZEROFILL, IN `Account_Img` VARCHAR(225))   BEGIN
	INSERT INTO tbl_account(Account_ID, Username, Password, Role_ID, Mail, Tel, Account_Img)
    VALUES (Account_ID, Username, Password, Role_ID, Mail, Tel, Account_Img);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_RemoveMovieFromWatchlist` (IN `p_Movie_ID` INT, IN `p_Watchlist_ID` INT)   BEGIN
    DELETE FROM `tbl_movie-watchlist` 
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
    LEFT JOIN `tbl_award-actor` aa 
        ON a.Actor_ID = aa.Actor_ID
    GROUP BY a.Actor_ID, a.Actor_Name
    ORDER BY Total_Awards DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_TopMoviesByViews` (IN `p_Limit` INT)   BEGIN
    SELECT m.Movie_ID,
           m.Movie_Title,
           COUNT(mw.Movie_ID) AS TotalViews
    FROM tbl_movie m
    INNER JOIN `tbl_movie-watchlist` mw
        ON m.Movie_ID = mw.Movie_ID
    INNER JOIN tbl_watchlist wl
        ON mw.Watchlist_ID = wl.Watchlist_ID
    GROUP BY m.Movie_ID, m.Movie_Title
    ORDER BY TotalViews DESC
    LIMIT p_Limit;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_UpdateAccount` (IN `p_Account_ID` INT(10) ZEROFILL, IN `p_Username` VARCHAR(32) CHARSET utf8mb4, IN `p_Password` VARCHAR(16) CHARSET utf8mb4, IN `p_Role_ID` ENUM('member','author','member-author') CHARSET utf8mb4, IN `p_Mail` VARCHAR(64) CHARSET utf8mb4, IN `p_Tel` INT(10) ZEROFILL, IN `p_Account_Img` VARCHAR(225) CHARSET utf8mb4)   BEGIN
	UPDATE tbl_account 
    SET
    	Username=p_Username,
        Password=p_Password,
        Role_ID=p_Role_ID,
        Mail=p_Mail,
        Tel=p_Tel,
        Account_Img=p_Account_Img
        WHERE Account_ID=p_Account_ID;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_account`
--

CREATE TABLE `tbl_account` (
  `Account_ID` int(10) NOT NULL,
  `Username` varchar(32) NOT NULL,
  `Password` varchar(16) NOT NULL,
  `Role_ID` enum('member','author','author-member') NOT NULL DEFAULT 'member',
  `Mail` varchar(64) NOT NULL,
  `Tel` int(10) DEFAULT NULL,
  `Account_Img` varchar(225) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_actor`
--

CREATE TABLE `tbl_actor` (
  `Actor_ID` int(10) NOT NULL,
  `Actor_Name` varchar(64) NOT NULL,
  `Actor_Info` text DEFAULT NULL,
  `Actor_Social` varchar(225) DEFAULT NULL,
  `Character_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_award`
--

CREATE TABLE `tbl_award` (
  `Award_ID` int(10) NOT NULL,
  `Award_Name` varchar(64) NOT NULL,
  `Award_Info` text DEFAULT NULL,
  `Award_Date` int(11) DEFAULT NULL,
  `Studio_ID` int(10) DEFAULT NULL,
  `Director_ID` int(10) DEFAULT NULL,
  `Actor_ID` int(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_award-actor`
--

CREATE TABLE `tbl_award-actor` (
  `Award_ID` int(10) NOT NULL,
  `Actor_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_award-studio`
--

CREATE TABLE `tbl_award-studio` (
  `Award_ID` int(10) NOT NULL,
  `Studio_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_award_director`
--

CREATE TABLE `tbl_award_director` (
  `Award_ID` int(10) NOT NULL,
  `Director_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_genre`
--

CREATE TABLE `tbl_genre` (
  `Genre_ID` int(10) NOT NULL,
  `Genre_Name` varchar(16) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_movie`
--

CREATE TABLE `tbl_movie` (
  `Movie_ID` int(10) NOT NULL,
  `Movie_Title` varchar(128) NOT NULL,
  `Movie_Description` varchar(512) DEFAULT NULL,
  `Movie_Img` varchar(225) DEFAULT NULL,
  `Genre_ID` int(10) NOT NULL,
  `Movie_ReleaseDate` date DEFAULT NULL,
  `Movie_StreamingDate` date DEFAULT NULL,
  `Studio_ID` int(10) NOT NULL,
  `Director_ID` int(10) NOT NULL,
  `Actor_ID` int(10) NOT NULL,
  `Account_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_movie-director`
--

CREATE TABLE `tbl_movie-director` (
  `Movie_ID` int(10) NOT NULL,
  `Director_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_movie-genre`
--

CREATE TABLE `tbl_movie-genre` (
  `Movie_ID` int(10) NOT NULL,
  `Genre_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_movie-studio`
--

CREATE TABLE `tbl_movie-studio` (
  `Movie_ID` int(10) NOT NULL,
  `Studio_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `tbl_movie-watchlist`
--

CREATE TABLE `tbl_movie-watchlist` (
  `Movie_ID` int(10) NOT NULL,
  `Watchlist_ID` int(16) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
  `Account_ID` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

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
  ADD KEY `FK_Character_ID` (`Character_ID`) USING BTREE;

--
-- Chỉ mục cho bảng `tbl_award`
--
ALTER TABLE `tbl_award`
  ADD PRIMARY KEY (`Award_ID`),
  ADD KEY `FK_Actor_ID` (`Actor_ID`) USING BTREE,
  ADD KEY `FK_Director_ID` (`Director_ID`) USING BTREE,
  ADD KEY `FK_Studio_ID` (`Studio_ID`) USING BTREE;

--
-- Chỉ mục cho bảng `tbl_award-actor`
--
ALTER TABLE `tbl_award-actor`
  ADD PRIMARY KEY (`Award_ID`,`Actor_ID`),
  ADD KEY `FK_Actor_ID` (`Actor_ID`) USING BTREE,
  ADD KEY `FK_Award_ID` (`Award_ID`) USING BTREE;

--
-- Chỉ mục cho bảng `tbl_award-studio`
--
ALTER TABLE `tbl_award-studio`
  ADD PRIMARY KEY (`Award_ID`,`Studio_ID`),
  ADD KEY `FK_Studio_ID` (`Studio_ID`) USING BTREE,
  ADD KEY `FK_Award_ID` (`Award_ID`) USING BTREE;

--
-- Chỉ mục cho bảng `tbl_award_director`
--
ALTER TABLE `tbl_award_director`
  ADD PRIMARY KEY (`Award_ID`,`Director_ID`),
  ADD KEY `FK_Director_ID` (`Director_ID`) USING BTREE,
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
  ADD UNIQUE KEY `FK_Account_ID` (`Account_ID`),
  ADD KEY `FK_Movie_ID` (`Movie_ID`) USING BTREE;

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
  ADD KEY `FK_Account_ID` (`Account_ID`) USING BTREE,
  ADD KEY `FK_Actor_ID` (`Actor_ID`) USING BTREE,
  ADD KEY `FK_Director_ID` (`Director_ID`) USING BTREE,
  ADD KEY `FK_Studio_ID` (`Studio_ID`) USING BTREE,
  ADD KEY `FK_Genre_ID` (`Genre_ID`) USING BTREE;

--
-- Chỉ mục cho bảng `tbl_movie-director`
--
ALTER TABLE `tbl_movie-director`
  ADD PRIMARY KEY (`Movie_ID`,`Director_ID`),
  ADD KEY `FK_Director_ID` (`Director_ID`) USING BTREE,
  ADD KEY `FK_Movie_ID` (`Movie_ID`) USING BTREE;

--
-- Chỉ mục cho bảng `tbl_movie-genre`
--
ALTER TABLE `tbl_movie-genre`
  ADD PRIMARY KEY (`Movie_ID`,`Genre_ID`),
  ADD KEY `FK_Genre_ID` (`Genre_ID`) USING BTREE,
  ADD KEY `FK_Movie_ID` (`Movie_ID`) USING BTREE;

--
-- Chỉ mục cho bảng `tbl_movie-studio`
--
ALTER TABLE `tbl_movie-studio`
  ADD PRIMARY KEY (`Movie_ID`,`Studio_ID`),
  ADD KEY `FK_Studio_ID` (`Studio_ID`) USING BTREE,
  ADD KEY `FK_Movie_ID` (`Movie_ID`) USING BTREE;

--
-- Chỉ mục cho bảng `tbl_movie-watchlist`
--
ALTER TABLE `tbl_movie-watchlist`
  ADD PRIMARY KEY (`Movie_ID`,`Watchlist_ID`),
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
  MODIFY `Account_ID` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `tbl_actor`
--
ALTER TABLE `tbl_actor`
  MODIFY `Actor_ID` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `tbl_award`
--
ALTER TABLE `tbl_award`
  MODIFY `Award_ID` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `tbl_character`
--
ALTER TABLE `tbl_character`
  MODIFY `Character_ID` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `tbl_comment`
--
ALTER TABLE `tbl_comment`
  MODIFY `Comment_ID` int(16) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `tbl_director`
--
ALTER TABLE `tbl_director`
  MODIFY `Director_ID` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `tbl_feedback`
--
ALTER TABLE `tbl_feedback`
  MODIFY `Feedback_ID` int(16) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `tbl_genre`
--
ALTER TABLE `tbl_genre`
  MODIFY `Genre_ID` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `tbl_movie`
--
ALTER TABLE `tbl_movie`
  MODIFY `Movie_ID` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `tbl_new`
--
ALTER TABLE `tbl_new`
  MODIFY `New_ID` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `tbl_studio`
--
ALTER TABLE `tbl_studio`
  MODIFY `Studio_ID` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT cho bảng `tbl_watchlist`
--
ALTER TABLE `tbl_watchlist`
  MODIFY `Watchlist_ID` int(16) NOT NULL AUTO_INCREMENT;

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `tbl_award-actor`
--
ALTER TABLE `tbl_award-actor`
  ADD CONSTRAINT `fk_aa_actor` FOREIGN KEY (`Actor_ID`) REFERENCES `tbl_actor` (`Actor_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_aa_award` FOREIGN KEY (`Award_ID`) REFERENCES `tbl_award` (`Award_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `tbl_award-studio`
--
ALTER TABLE `tbl_award-studio`
  ADD CONSTRAINT `fk_as_award` FOREIGN KEY (`Award_ID`) REFERENCES `tbl_award` (`Award_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_as_studio` FOREIGN KEY (`Studio_ID`) REFERENCES `tbl_studio` (`Studio_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `tbl_award_director`
--
ALTER TABLE `tbl_award_director`
  ADD CONSTRAINT `fk_ad_award` FOREIGN KEY (`Award_ID`) REFERENCES `tbl_award` (`Award_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_ad_director` FOREIGN KEY (`Director_ID`) REFERENCES `tbl_director` (`Director_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

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
-- Các ràng buộc cho bảng `tbl_movie-director`
--
ALTER TABLE `tbl_movie-director`
  ADD CONSTRAINT `fk_md_director` FOREIGN KEY (`Director_ID`) REFERENCES `tbl_director` (`Director_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_md_movie` FOREIGN KEY (`Movie_ID`) REFERENCES `tbl_movie` (`Movie_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `tbl_movie-genre`
--
ALTER TABLE `tbl_movie-genre`
  ADD CONSTRAINT `fk_mg_genre` FOREIGN KEY (`Genre_ID`) REFERENCES `tbl_genre` (`Genre_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_mg_movie` FOREIGN KEY (`Movie_ID`) REFERENCES `tbl_movie` (`Movie_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `tbl_movie-studio`
--
ALTER TABLE `tbl_movie-studio`
  ADD CONSTRAINT `fk_ms_movie` FOREIGN KEY (`Movie_ID`) REFERENCES `tbl_movie` (`Movie_ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_ms_studio` FOREIGN KEY (`Studio_ID`) REFERENCES `tbl_studio` (`Studio_ID`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `tbl_movie-watchlist`
--
ALTER TABLE `tbl_movie-watchlist`
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
