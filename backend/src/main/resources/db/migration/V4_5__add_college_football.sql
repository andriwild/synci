-- College Football (NCAA FBS) via CollegeFootballData; conference nodes are created by the sync
INSERT INTO SOURCES_TABLE (name) VALUES ('CFBD');

DO $$
    DECLARE
        american_football_id UUID;
        ncaa_id UUID;
    BEGIN
        SELECT id INTO american_football_id FROM SPORTS_TABLE WHERE name = 'AMERICAN_FOOTBALL';

        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        VALUES (gen_random_uuid(), 'NCAA_FOOTBALL', american_football_id, 'College Football');

        SELECT id INTO ncaa_id FROM SPORTS_TABLE WHERE name = 'NCAA_FOOTBALL';

        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        VALUES (gen_random_uuid(), 'NCAA_POSTSEASON', ncaa_id, 'Bowls & Playoff');
    END
$$;
