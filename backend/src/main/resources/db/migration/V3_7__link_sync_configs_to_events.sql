CREATE TABLE public.SYNC_CONFIGS_EVENTS_TABLE
(
    id              uuid         NOT NULL,
    sync_config_id  uuid         NOT NULL,
    event_id        varchar(255) NOT NULL,
    source_event_id integer      NOT NULL,
    CONSTRAINT pk_sync_config_events
        PRIMARY KEY (id),
    CONSTRAINT fk_sync_config FOREIGN KEY (sync_config_id)
        REFERENCES public.SYNC_CONFIGS_TABLE (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_events_source FOREIGN KEY (event_id, source_event_id)
        REFERENCES public.EVENTS_TABLE (id, source_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);