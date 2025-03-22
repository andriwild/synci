DROP TABLE public.USERS_TABLE CASCADE;
DROP TABLE public.SYNC_CONFIGS_USERS_TABLE;
TRUNCATE TABLE public.sync_configs_table CASCADE;

CREATE TABLE public.SYNC_CONFIGS_USERS_TABLE
(
    id uuid NOT NULL PRIMARY KEY,
    user_id uuid,
    sync_config_id uuid,
    CONSTRAINT fk_sync_config FOREIGN KEY (sync_config_id)
        REFERENCES public.SYNC_CONFIGS_TABLE (id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);