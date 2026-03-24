DELIMITER $$

CREATE PROCEDURE `sp_GetMoviesInWatchlist`(
    IN `p_Watchlist_ID` INT
)
BEGIN
    SELECT m.* 
    FROM tbl_movie m
    JOIN `tbl_movie-watchlist` mw 
        ON m.Movie_ID = mw.Movie_ID
    WHERE mw.Watchlist_ID = p_Watchlist_ID;
END$$

DELIMITER ;
