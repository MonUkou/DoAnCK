DELIMITER $$

CREATE PROCEDURE 'sp_GetLatestMovies'()
BEGIN
    SELECT 
        m.Movie_Title AS MovieTitle, 
        m.Movie_ReleaseDate AS ReleaseDate,
        g.Genre_Name AS Genre
    FROM tbl_movie m
    INNER JOIN tbl_genre g ON m.Genre_ID = g.Genre_ID
    ORDER BY m.Movie_ReleaseDate DESC;
END$$

DELIMITER ;
