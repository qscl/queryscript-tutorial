let teams = load('data/teams.parquet');
let regular_season = load('data/regular_season.parquet');

SELECT COUNT(*) FROM teams;
SELECT COUNT(*) FROM regular_season;

SELECT TEAM_ABBREVIATION, SUM(PTS) points FROM regular_season 
    GROUP BY 1 ORDER BY 2 DESC LIMIT 10;

SELECT full_name, SUM(pts) points FROM regular_season JOIN teams 
    ON regular_season.team_abbreviation = teams.abbreviation
    GROUP BY 1 ORDER BY 2 DESC LIMIT 10;

let regular_season_teams = 
    SELECT full_name, regular_season.* 
    FROM 
        regular_season JOIN teams 
        ON regular_season.team_abbreviation = teams.abbreviation;

SELECT full_name, SUM(PTS) points FROM regular_season_teams
    GROUP BY 1 ORDER BY 2 DESC;


let matchups = SELECT
    t1.FULL_NAME AS WINNER,
    t1.PTS AS WINNER_POINTS,
    T2.FULL_NAME AS LOSER,
    T2.PTS AS LOSER_POINTS,
    T1.SEASON,
    T1.GAME_ID
FROM
    regular_season_teams t1
    JOIN regular_season_teams t2 ON t1.GAME_ID = t2.GAME_ID
WHERE
    t1.WL = 'W' AND t1.FULL_NAME != t2.FULL_NAME;
    

SELECT 
    winner, loser,
    COUNT(*) wins,
    AVG(winner_points-loser_points) avg_diff
FROM matchups
GROUP BY 1, 2 ORDER BY 3 DESC;

fn matchup_report(min_season bigint, max_season bigint) {
    SELECT winner, loser, COUNT(*) wins, AVG(winner_points-loser_points) avg_diff
    FROM matchups
    WHERE
        season >= min_season AND season <= max_season
    GROUP BY 1, 2 ORDER BY 3 DESC
}

matchup_report(1980, 1989);
matchup_report(1990, 1999);

let latest_season = (SELECT MAX(season) FROM regular_season_teams);
matchup_report(latest_season-5, latest_season);
matchup_report(latest_season-1, latest_season);