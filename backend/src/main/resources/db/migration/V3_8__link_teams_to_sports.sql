CREATE TABLE public.TEAMS_SPORTS_TABLE
(
    id             uuid         NOT NULL,
    team_id        varchar(255) NOT NULL,
    source_team_id integer      NOT NULL,
    sport_id       uuid         NOT NULL,
    CONSTRAINT pk_teams_sports
        PRIMARY KEY (id),
    CONSTRAINT fk_team_source FOREIGN KEY (team_id, source_team_id)
        REFERENCES public.TEAMS_TABLE (id, source_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_sports_source FOREIGN KEY (sport_id)
        REFERENCES public.SPORTS_TABLE (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);