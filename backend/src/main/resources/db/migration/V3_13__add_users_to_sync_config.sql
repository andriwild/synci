DROP TABLE public.sync_configs_users_table;

CREATE TABLE public.sync_configs_users_table
(
    id             UUID NOT NULL PRIMARY KEY,
    user_id        UUID NOT NULL,
    sync_config_id UUID NOT NULL,

    CONSTRAINT fk_sync_config
        FOREIGN KEY (sync_config_id)
            REFERENCES public.sync_configs_table (id)
            ON UPDATE CASCADE
            ON DELETE CASCADE,

    CONSTRAINT fk_user
        FOREIGN KEY (user_id)
            REFERENCES public.users_table (id)
            ON UPDATE CASCADE
            ON DELETE CASCADE
);
