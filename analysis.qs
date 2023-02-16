let teams = load('data/teams.parquet');
let raw_regular_season = load('data/regular_season.parquet');

SELECT TEAM_ABBREVIATION, SUM(PTS) points FROM regular_season 
    GROUP BY 1 ORDER BY 2 DESC LIMIT 10;

SELECT full_name, SUM(pts) points FROM regular_season JOIN teams 
    ON regular_season.team_abbreviation = teams.abbreviation
    GROUP BY 1 ORDER BY 2 DESC LIMIT 10;

fn get_team(code text) {
    (SELECT full_name FROM teams WHERE abbreviation = code)
}

SELECT get_team(TEAM_ABBREVIATION), SUM(PTS) points FROM regular_season 
    WHERE get_team(TEAM_ABBREVIATION) IS NOT NULL
    GROUP BY 1 ORDER BY 2 DESC;

let regular_season = select * from raw_regular_season WHERE get_team(team_abbreviation) IS NOT NULL;

let matchups = SELECT
    t1.TEAM_ABBREVIATION AS winner,
    t1.PTS AS winner_points,
    t2.TEAM_ABBREVIATION as loser,
    t2.PTS AS loser_points,
    t1.GAME_ID
FROM
    regular_season t1
    JOIN regular_season t2 ON t1.GAME_ID = t2.GAME_ID
WHERE
    t1.WL = 'W' AND t1.TEAM_ABBREVIATION != t2.TEAM_ABBREVIATION
;

let matchups_report = SELECT 
    get_team(winner), get_team(loser),
    COUNT(*) wins,
    AVG(winner_points-loser_points) avg_diff
FROM matchups
GROUP BY 1, 2 ORDER BY 3 DESC;

SELECT * FROM matchups_report ORDER BY wins DESC LIMIT 10;
SELECT * FROM matchups_report ORDER BY avg_diff DESC LIMIT 10;