-- NFL (American Football) via nflverse schedules
INSERT INTO SOURCES_TABLE (name) VALUES ('NFLVERSE');

INSERT INTO SPORTS_TABLE (id, name, label) VALUES (gen_random_uuid(), 'AMERICAN_FOOTBALL', 'American Football');

DO $$
    DECLARE
        american_football_id UUID;
        nfl_id UUID;
    BEGIN
        SELECT id INTO american_football_id FROM SPORTS_TABLE WHERE name = 'AMERICAN_FOOTBALL';

        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        VALUES (gen_random_uuid(), 'NFL', american_football_id, 'NFL');

        SELECT id INTO nfl_id FROM SPORTS_TABLE WHERE name = 'NFL';

        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        VALUES
            (gen_random_uuid(), 'NFL_REGULAR_SEASON', nfl_id, 'Regular Season'),
            (gen_random_uuid(), 'NFL_PLAYOFFS',       nfl_id, 'Playoffs');
    END
$$;
