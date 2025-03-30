ALTER TABLE public.sync_configs_table
    ALTER COLUMN name SET NOT NULL;

ALTER TABLE public.locations_table
    ALTER COLUMN name SET NOT NULL;

ALTER TABLE public.sports_table
    ALTER COLUMN name SET NOT NULL;

ALTER TABLE public.sync_configs_users_table
    ALTER COLUMN user_id SET NOT NULL,
    ALTER COLUMN sync_config_id SET NOT NULL;

ALTER TABLE public.teams_table
    ALTER COLUMN name SET NOT NULL;

ALTER TABLE public.events_table
    ALTER COLUMN sport_id SET NOT NULL,
    ALTER COLUMN name SET NOT NULL,
    ALTER COLUMN starts_on SET NOT NULL;