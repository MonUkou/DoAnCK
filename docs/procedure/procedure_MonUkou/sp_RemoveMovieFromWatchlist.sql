CREATE PROCEDURE `sp_RemoveMovieFromWatchlist`(
    IN `p_Movie_ID` INT(10),
    IN `p_Watchlist_ID` INT(16)
)
BEGIN
    DELETE FROM `tbl_movie-watchlist` 
    WHERE Movie_ID = p_Movie_ID AND Watchlist_ID = p_Watchlist_ID;
END$$
