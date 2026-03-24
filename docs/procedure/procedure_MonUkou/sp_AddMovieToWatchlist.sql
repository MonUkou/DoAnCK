DELIMITER $$

CREATE PROCEDURE `sp_AddMovieToWatchlist`(
    IN `p_Movie_ID` INT,
    IN `p_Watchlist_ID` INT
)
BEGIN
    INSERT IGNORE INTO `tbl_movie-watchlist` (Movie_ID, Watchlist_ID)
    VALUES (p_Movie_ID, p_Watchlist_ID);
END$$

DELIMITER ;
