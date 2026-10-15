-- More PandaScore games below E-Sport
DO $$
    DECLARE
        esports_id UUID;
    BEGIN
        SELECT id INTO esports_id FROM SPORTS_TABLE WHERE name = 'ESPORTS';

        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        VALUES
            (gen_random_uuid(), 'ESPORTS_R6',        esports_id, 'Rainbow Six Siege'),
            (gen_random_uuid(), 'ESPORTS_OVERWATCH', esports_id, 'Overwatch'),
            (gen_random_uuid(), 'ESPORTS_ROCKET_LEAGUE', esports_id, 'Rocket League');
    END
$$;
