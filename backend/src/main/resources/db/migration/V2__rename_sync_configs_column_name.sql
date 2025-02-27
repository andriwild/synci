ALTER TABLE sync_configs_teams_table RENAME COLUMN source_team_id TO source_id;

ALTER TABLE sync_configs_table RENAME COLUMN ical_url TO name;
