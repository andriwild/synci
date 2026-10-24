-- Top Events: games between two teams, whatever the competition. Every Abo holds its own list;
-- this node shows it on top of the sports.
INSERT INTO SPORTS_TABLE (id, name, label) VALUES (gen_random_uuid(), 'TOP_EVENTS', 'Top Events');

-- The teams keep the order the user chose; position keeps the order of the list.
CREATE TABLE public.SYNC_CONFIGS_MATCHUPS_TABLE
(
    id             uuid         NOT NULL DEFAULT gen_random_uuid(),
    sync_config_id uuid         NOT NULL,
    source_id      integer      NOT NULL,
    team_a_id      varchar(255) NOT NULL,
    team_b_id      varchar(255) NOT NULL,
    position       integer      NOT NULL,
    CONSTRAINT pk_sync_configs_matchups PRIMARY KEY (id),
    CONSTRAINT ck_sync_configs_matchups_teams CHECK (team_a_id <> team_b_id),
    CONSTRAINT fk_sync_configs_matchups_config FOREIGN KEY (sync_config_id)
        REFERENCES public.SYNC_CONFIGS_TABLE (id)
        ON DELETE CASCADE,
    CONSTRAINT fk_sync_configs_matchups_team_a FOREIGN KEY (team_a_id, source_id)
        REFERENCES public.TEAMS_TABLE (id, source_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_sync_configs_matchups_team_b FOREIGN KEY (team_b_id, source_id)
        REFERENCES public.TEAMS_TABLE (id, source_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- A – B and B – A are the same matchup
CREATE UNIQUE INDEX uq_sync_configs_matchups ON public.SYNC_CONFIGS_MATCHUPS_TABLE
    (sync_config_id, source_id, LEAST(team_a_id, team_b_id), GREATEST(team_a_id, team_b_id));
