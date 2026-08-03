-- Final Project
-- Isaiah Licona
-- NBA Player Performance SQL Data Analysis
-- Schemas: player, team, season, season_stats



-- Data
USE nba_project;



-- Query 1: Top 10 players by Points Per Game
-- The techniques used include JOIN, filtering, ordering, and the calculated field
SELECT p.player_name, t.team_abbrev, ss.gp,
       ROUND(ss.pts * 1.0 / ss.gp, 2) AS points_per_game,
       ss.pts AS total_points
FROM season_stats ss
JOIN player p ON ss.player_id = p.player_id
JOIN team t ON ss.team_id = t.team_id
WHERE ss.gp >= 50
ORDER BY points_per_game DESC
LIMIT 10;



-- Query 2: Team Collective Field-Goal Percentage
-- Techniques used include JOIN, aggregation, and grouping
SELECT t.team_abbrev,
       SUM(ss.fgm) AS team_fgm,
       SUM(ss.fga) AS team_fga,
       ROUND(SUM(ss.fgm) * 1.0 / NULLIF(SUM(ss.fga), 0), 3) AS collective_fg_pct
FROM season_stats ss
JOIN team t ON ss.team_id = t.team_id
GROUP BY t.team_abbrev
ORDER BY collective_fg_pct DESC;



-- Query 3: Assist-to-turnover Leaders
-- The techniques used were JOIN, filtering, and calculated ratio
SELECT p.player_name, t.team_abbrev, ss.gp, ss.ast, ss.tov,
       ROUND(ss.ast * 1.0 / NULLIF(ss.tov, 0), 2) AS ast_to_tov_ratio
FROM season_stats ss
JOIN player p ON ss.player_id = p.player_id
JOIN team t ON ss.team_id = t.team_id
WHERE ss.gp >= 50 AND ss.tov > 0
ORDER BY ast_to_tov_ratio DESC
LIMIT 10;



-- Query 4: Average Efficiency by Team
-- The techniques used JOIN, aggregation, and grouping
SELECT t.team_abbrev,
       COUNT(*) AS players_counted,
       ROUND(AVG(ss.eff), 2) AS avg_efficiency,
       SUM(ss.eff) AS total_efficiency
FROM season_stats ss
JOIN team t ON ss.team_id = t.team_id
GROUP BY t.team_abbrev
ORDER BY avg_efficiency DESC;



-- Query 5: Players with more Steals than Turnovers per Game
-- The techniques used JOIN, filtering, and calculated comparison
SELECT p.player_name, t.team_abbrev, ss.gp,
       ROUND(ss.stl * 1.0 / ss.gp, 2) AS steals_per_game,
       ROUND(ss.tov * 1.0 / ss.gp, 2) AS turnovers_per_game,
       ss.stl_tov
FROM season_stats ss
JOIN player p ON ss.player_id = p.player_id
JOIN team t ON ss.team_id = t.team_id
WHERE ss.gp >= 30 AND (ss.stl * 1.0 / ss.gp) > (ss.tov * 1.0 / ss.gp)
ORDER BY ss.stl_tov DESC
LIMIT 10;



-- Query 6: Teams with the Strongest Free-Throw Shooters
-- Techniques used were JOIN, aggregation, filtering, and grouping
SELECT t.team_abbrev,
       COUNT(*) AS players_above_85_ft_pct,
       ROUND(AVG(ss.ft_pct), 3) AS avg_ft_pct_of_group
FROM season_stats ss
JOIN team t ON ss.team_id = t.team_id
WHERE ss.ft_pct > 0.85 AND ss.fta >= 50
GROUP BY t.team_abbrev
ORDER BY players_above_85_ft_pct DESC, avg_ft_pct_of_group DESC;



-- Query 7: Total Combined Assists by Team
-- The techniques used were JOIN, aggregation, and grouping
SELECT t.team_abbrev,
       SUM(ss.ast) AS total_assists,
       ROUND(SUM(ss.ast) * 1.0 / SUM(ss.gp), 2) AS assists_per_player_game
FROM season_stats ss
JOIN team t ON ss.team_id = t.team_id
GROUP BY t.team_abbrev
ORDER BY total_assists DESC;



-- Query 8: Players who beat Team Scoring Average by more than 10 Points per Game
-- The techniques that was used for this query is JOIN, nested subquery in FROM, aggregation, and filtering
SELECT p.player_name, t.team_abbrev,
       ROUND(ss.pts * 1.0 / ss.gp, 2) AS player_ppg,
       ROUND(team_avg.avg_team_ppg, 2) AS team_avg_ppg,
       ROUND((ss.pts * 1.0 / ss.gp) - team_avg.avg_team_ppg, 2) AS ppg_above_team_avg
FROM season_stats ss
JOIN player p ON ss.player_id = p.player_id
JOIN team t ON ss.team_id = t.team_id
JOIN (
    SELECT team_id, AVG(pts * 1.0 / gp) AS avg_team_ppg
    FROM season_stats
    WHERE gp > 0
    GROUP BY team_id
) AS team_avg ON ss.team_id = team_avg.team_id
WHERE ss.gp >= 50 AND (ss.pts * 1.0 / ss.gp) > team_avg.avg_team_ppg + 10
ORDER BY ppg_above_team_avg DESC;



-- Query 9: Best Team Three-Point Percentage among High-Volume Shooters
-- The techniques used were JOIN, aggregation, filtering, and HAVING
SELECT t.team_abbrev,
       COUNT(*) AS qualifying_players,
       ROUND(AVG(ss.fg3_pct), 3) AS avg_3pt_pct,
       ROUND(SUM(ss.fg3m) * 1.0 / NULLIF(SUM(ss.fg3a), 0), 3) AS weighted_3pt_pct
FROM season_stats ss
JOIN team t ON ss.team_id = t.team_id
WHERE ss.fg3a >= 100
GROUP BY t.team_abbrev
HAVING qualifying_players >= 2
ORDER BY weighted_3pt_pct DESC;



-- Query 10: Combined Assists and Steals Per Game
-- The techniques used for this query is JOIN, filtering, and calculated metric
SELECT p.player_name, t.team_abbrev, ss.gp,
       ROUND(ss.ast * 1.0 / ss.gp, 2) AS assists_per_game,
       ROUND(ss.stl * 1.0 / ss.gp, 2) AS steals_per_game,
       ROUND((ss.ast + ss.stl) * 1.0 / ss.gp, 2) AS ast_stl_per_game
FROM season_stats ss
JOIN player p ON ss.player_id = p.player_id
JOIN team t ON ss.team_id = t.team_id
WHERE ss.gp >= 50
ORDER BY ast_stl_per_game DESC
LIMIT 10;



-- Query 11: Average Turnovers per Game by Team
-- Techniques used are JOIN, aggregation, grouping, and ordering
SELECT t.team_abbrev,
       ROUND(SUM(ss.tov) * 1.0 / SUM(ss.gp), 2) AS team_turnovers_per_player_game,
       SUM(ss.tov) AS total_turnovers
FROM season_stats ss
JOIN team t ON ss.team_id = t.team_id
GROUP BY t.team_abbrev
ORDER BY team_turnovers_per_player_game ASC;



-- Query 12: Players above League-Average Field-Goal Percentage
-- Techniques used for this query include JOIN, nested scalar subquery, and filtering
SELECT p.player_name, t.team_abbrev, ss.gp, ss.fg_pct,
       ROUND((SELECT AVG(fg_pct) FROM season_stats WHERE fga > 0), 3) AS league_avg_fg_pct
FROM season_stats ss
JOIN player p ON ss.player_id = p.player_id
JOIN team t ON ss.team_id = t.team_id
WHERE ss.gp >= 60
  AND ss.fg_pct > (SELECT AVG(fg_pct) FROM season_stats WHERE fga > 0)
ORDER BY ss.fg_pct DESC
LIMIT 15;



-- Query 13: Top Quartile in both Points and Rebounds
-- Techniques used was JOIN, window function, and quartile analysis
WITH ranked_stats AS (
    SELECT p.player_name, t.team_abbrev, ss.pts, ss.reb,
           CUME_DIST() OVER (ORDER BY ss.pts DESC) AS points_quartile_position,
           CUME_DIST() OVER (ORDER BY ss.reb DESC) AS rebounds_quartile_position
    FROM season_stats ss
    JOIN player p ON ss.player_id = p.player_id
    JOIN team t ON ss.team_id = t.team_id
)
SELECT player_name, team_abbrev, pts, reb
FROM ranked_stats
WHERE points_quartile_position <= 0.25
  AND rebounds_quartile_position <= 0.25
ORDER BY pts DESC, reb DESC
LIMIT 20;



-- Query 14: Above Average Scoring and Playmaking
-- The techniques used are JOIN, two nested scalar subqueries, and filtering
SELECT p.player_name, t.team_abbrev,
       ROUND(ss.pts * 1.0 / ss.gp, 2) AS points_per_game,
       ROUND(ss.ast * 1.0 / ss.gp, 2) AS assists_per_game
FROM season_stats ss
JOIN player p ON ss.player_id = p.player_id
JOIN team t ON ss.team_id = t.team_id
WHERE ss.gp >= 50
  AND (ss.pts * 1.0 / ss.gp) > (SELECT AVG(pts * 1.0 / gp) FROM season_stats WHERE gp > 0)
  AND (ss.ast * 1.0 / ss.gp) > (SELECT AVG(ast * 1.0 / gp) FROM season_stats WHERE gp > 0)
ORDER BY points_per_game DESC, assists_per_game DESC
LIMIT 15;



-- Query 15: Players above their Team’s Average Efficiency
-- Techniques used include JOIN, correlated nested subqueries, filtering
SELECT p.player_name, t.team_abbrev, ss.eff,
       ROUND((SELECT AVG(ss2.eff)
              FROM season_stats ss2
              WHERE ss2.team_id = ss.team_id), 2) AS team_avg_eff,
       ROUND(ss.eff - (SELECT AVG(ss3.eff)
                       FROM season_stats ss3
                       WHERE ss3.team_id = ss.team_id), 2) AS eff_above_team_avg
FROM season_stats ss
JOIN player p ON ss.player_id = p.player_id
JOIN team t ON ss.team_id = t.team_id
WHERE ss.gp >= 50
  AND ss.eff > (SELECT AVG(ss4.eff)
                FROM season_stats ss4
                WHERE ss4.team_id = ss.team_id)
ORDER BY eff_above_team_avg DESC
LIMIT 15;
