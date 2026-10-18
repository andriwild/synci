-- E-Sport via PandaScore. League nodes below the games are created by the sync.
INSERT INTO SOURCES_TABLE (name) VALUES ('PANDASCORE');

INSERT INTO SPORTS_TABLE (id, name, label) VALUES (gen_random_uuid(), 'ESPORTS', 'E-Sport');

DO $$
    DECLARE
        esports_id UUID;
    BEGIN
        SELECT id INTO esports_id FROM SPORTS_TABLE WHERE name = 'ESPORTS';

        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        VALUES
            (gen_random_uuid(), 'ESPORTS_LOL',      esports_id, 'League of Legends'),
            (gen_random_uuid(), 'ESPORTS_CS2',      esports_id, 'Counter-Strike 2'),
            (gen_random_uuid(), 'ESPORTS_VALORANT', esports_id, 'Valorant'),
            (gen_random_uuid(), 'ESPORTS_DOTA2',    esports_id, 'Dota 2');
    END
$$;
