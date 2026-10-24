-- Every sync re-inserted all team/sport links with a fresh random id, so each pair existed once per sync.
-- Keep one row per pair and forbid repeats.
DELETE FROM teams_sports_table t
USING (
    SELECT id, row_number() OVER (PARTITION BY team_id, source_team_id, sport_id ORDER BY id) AS rn
    FROM teams_sports_table
) d
WHERE t.id = d.id
  AND d.rn > 1;

ALTER TABLE teams_sports_table
    ADD CONSTRAINT uq_teams_sports UNIQUE (team_id, source_team_id, sport_id);
