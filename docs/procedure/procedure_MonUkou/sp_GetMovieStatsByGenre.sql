DELIMITER $$

CREATE PROCEDURE 'sp_GetMovieStatsByGenre'()
BEGIN
    SELECT 
        g.Genre_Name AS Genre,
        COUNT(m.Movie_ID) AS MovieCount
    FROM tbl_genre g
    LEFT JOIN tbl_movie m ON g.Genre_ID = m.Genre_ID
    GROUP BY g.Genre_ID, g.Genre_Name;
END$$

DELIMITER ;
