use fifa_ranks;

WITH 
num_matches AS (SELECT r.home_team, r.away_team, r.match_date, r.home_score, r.away_score,
		ROW_NUMBER() OVER (PARTITION BY YEAR(r.match_date) ORDER BY r.match_date DESC) AS rn,
				CASE WHEN (r.home_score > r.away_score) THEN r.home_team
					WHEN (r.away_score > r.home_score) THEN r.away_team
                     WHEN (r.home_score = r.away_score) THEN  COALESCE (s.winner, 'Draw')
				END AS 'winner'
			FROM fifa_ranks.results r LEFT JOIN shootouts s 
					ON r.match_date = s.match_date AND 
                    r.home_team = s.home_team AND 
                    r.away_team = s.away_team
			WHERE (r.tournament = 'FIFA World Cup') 
			AND (r.match_date BETWEEN ' 1993-08-08 00:00:00' AND '2018-12-31 00:00:00') ) ,
furthest_round as (SELECT world_cup, 
			CASE WHEN teams = 'United States' THEN 'USA'
				WHEN teams = 'South Korea' THEN 'Korea Republic'
                ELSE teams END as teams,
                MIN(best_finish) as best_finish
FROM (SELECT year(match_date) as world_cup, home_team as teams, MIN(rn) AS best_finish
		FROM num_matches
		WHERE rn BETWEEN 1 and 8
		GROUP BY teams, year(match_date)
		UNION ALL
		SELECT year(match_date) as world_cup, away_team as teams, MIN(rn) AS best_finish
		FROM num_matches
		WHERE rn BETWEEN 1 AND 8 
		GROUP BY teams, year(match_date)) AS x
GROUP BY teams, world_cup
ORDER BY world_cup, best_finish),
began as (SELECT year(match_date) AS world_cup, MIN(match_date) as start_date FROM results
WHERE (tournament = 'FIFA World Cup') 
		AND (match_date BETWEEN ' 1993-08-08 00:00:00' AND '2018-12-31 00:00:00')
 GROUP BY world_cup),
pre as (SELECT b.world_cup, MAX(d.rank_date) AS rank_date
		FROM began b
		JOIN (SELECT DISTINCT rank_date FROM fifa_ranking) as d
				ON d.rank_date < b.start_date
		GROUP BY b.world_cup),
ranked as (SELECT pre.world_cup, r.country_full, r.rank,
				CASE WHEN best_finish = 1 THEN 'finalist'
				WHEN best_finish = 2 THEN 'semi_finalist (lost semi)'
				WHEN best_finish IN (5,6,7,8) THEN 'quarter_finalist'
                ELSE 'missed top 8'
                END AS finish
FROM fifa_ranking r JOIN pre ON r.rank_date = pre.rank_date
LEFT JOIN furthest_round fr ON r.country_full = fr.teams AND fr.world_cup = pre.world_cup
WHERE `rank` <=20
)

SELECT CASE WHEN `rank` <= 5 THEN 'top 5'
			WHEN `rank` BETWEEN 6 AND 10 THEN '6-10'
			WHEN `rank` BETWEEN 11 AND 20 THEN '11-20'
            END AS rank_bucket,
            COUNT(*) as total,
            ROUND( 100 * SUM(CASE WHEN finish <> 'missed top 8' THEN 1 ELSE 0 END) / COUNT(*), 1 )
					AS pct_top_8
FROM ranked
GROUP BY rank_bucket;
#2006 has a draw at rank 5, so top 5 bucket has 36 teams instead of 35





SELECT COUNT(*) FROM shootouts;



SELECT COUNT(*) FROM shootouts;
SELECT * FROM shootouts
WHERE match_date BETWEEN ' 1993-08-08 00:00:00' AND '2018-12-31 00:00:00';
