USE cycling;

# changing first all the "Unnamed: 0" from the indexing
ALTER TABLE race_info
CHANGE COLUMN `Unnamed: 0` race_id INTEGER;

ALTER TABLE race_result
CHANGE COLUMN `Unnamed: 0` result_id INTEGER;

ALTER TABLE rider_info
CHANGE COLUMN `Unnamed: 0` rider_id INTEGER;

ALTER TABLE team_historic
CHANGE COLUMN `Unnamed: 0` historic_id INTEGER;

ALTER TABLE team_info
CHANGE COLUMN `Unnamed: 0` team_id INTEGER;

# changing name of foreign keys
ALTER TABLE race_result
CHANGE COLUMN `rider_code` fk_rider_code CHAR(250);
ALTER TABLE race_result
CHANGE COLUMN `race_code` fk_race_code CHAR(250);
ALTER TABLE race_result
CHANGE COLUMN `team_code_2023` fk_team_code_2023 CHAR(250);
ALTER TABLE rider_info
CHANGE COLUMN `team_code` fk_team_code_2023 CHAR(250);
ALTER TABLE team_historic
CHANGE COLUMN `team_code_2023` fk_team_code_2023 CHAR(250);

SELECT rider_info.fullname, race_result.fk_rider_code, COUNT(*) AS nb_wins
FROM race_result
JOIN rider_info ON rider_info.rider_code = race_result.fk_rider_code
WHERE race_result.rnk = 1
GROUP BY rider_info.fullname, race_result.fk_rider_code
ORDER BY nb_wins DESC
LIMIT 10;

SELECT team_info.team_name, race_result.fk_team_code_2023, COUNT(*) AS nb_wins
FROM race_result
JOIN team_info ON team_info.team_code = race_result.fk_team_code_2023
JOIN race_info ON race_info.race_code = race_result.fk_race_code
WHERE (race_result.rnk = 1) AND (race_info.type_race LIKE 'one%')
GROUP BY team_info.team_name, race_result.fk_team_code_2023
ORDER BY nb_wins DESC
LIMIT 10;

SELECT rider_info.fullname, race_result.fk_rider_code, avg(race_result.rnk) AS avg_position, count(*) AS nb_race
FROM race_result
JOIN rider_info ON rider_info.rider_code = race_result.fk_rider_code
JOIN race_info ON race_info.race_code = race_result.fk_race_code
WHERE (race_info.parcours_type = 'hill_uphill_finish' OR race_info.parcours_type = 'mountain_flat_finish' 
OR race_info.parcours_type = 'mountain_uphill_finish') AND (race_result.finished = 1) AND (nb_race > 5)
GROUP BY rider_info.fullname, race_result.fk_rider_code
ORDER BY avg_position ASC
LIMIT 10;

SELECT fullname, fk_rider_code, avg_position, nb_race
FROM (
    SELECT rider_info.fullname, race_result.fk_rider_code, avg(race_result.rnk) AS avg_position, count(*) AS nb_race
    FROM race_result
    JOIN rider_info ON rider_info.rider_code = race_result.fk_rider_code
    JOIN race_info ON race_info.race_code = race_result.fk_race_code
    WHERE (race_info.parcours_type = 'hill_uphill_finish' OR race_info.parcours_type = 'mountain_flat_finish' 
        OR race_info.parcours_type = 'mountain_uphill_finish') 
        AND (race_result.finished = 1) 
    GROUP BY rider_info.fullname, race_result.fk_rider_code
    HAVING nb_race > 5
    ORDER BY avg_position ASC
    LIMIT 10
) subquery_position_climb;

SELECT rider_info.fullname, race_result.fk_rider_code, SUM(race_result.pcs_total_pts) AS pcs_points
FROM race_result
JOIN rider_info ON rider_info.rider_code = race_result.fk_rider_code
GROUP BY rider_info.fullname, race_result.fk_rider_code
ORDER BY pcs_points DESC
LIMIT 20;

SELECT 
    rider_info.fullname, race_result.fk_rider_code, 
    COUNT( CASE WHEN rnk = 'dnf' THEN rider_code END) as dnf_count,
    COUNT( CASE WHEN rnk = 'dns' THEN rider_code END) as dns_count,
    COUNT( CASE WHEN rnk = 'otl' THEN rider_code END) as otl_count,
    COUNT( CASE WHEN rnk = 'dsq' THEN rider_code END) as dsq_count,
    COUNT(*) as nb_race
FROM race_result
JOIN rider_info ON rider_info.rider_code = race_result.fk_rider_code
GROUP BY rider_info.fullname, race_result.fk_rider_code
ORDER BY dnf_count DESC
LIMIT 10;
