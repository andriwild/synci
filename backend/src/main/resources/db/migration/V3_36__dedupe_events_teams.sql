-- Every SwissTXT sync re-inserted all event/team links with a fresh random id, so each pair existed once per sync.
-- Keep one row per pair and forbid repeats.
DELETE FROM events_teams_table a
USING events_teams_table b
WHERE a.ctid > b.ctid
  AND a.event_id = b.event_id
  AND a.source_event_id = b.source_event_id
  AND a.team_id = b.team_id
  AND a.source_team_id = b.source_team_id;

ALTER TABLE events_teams_table
    ADD CONSTRAINT uq_events_teams UNIQUE (event_id, source_event_id, team_id, source_team_id);
