DELIMITER $$

CREATE PROCEDURE `sp_RemoveMovieFromWatchlist`(
    IN `p_Movie_ID` INT,
    IN `p_Watchlist_ID` INT
)
BEGIN
    DELETE FROM `tbl_movie-watchlist` 
    WHERE Movie_ID = p_Movie_ID 
      AND Watchlist_ID = p_Watchlist_ID;
END$$

DELIMITER ;
