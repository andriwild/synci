INSERT INTO SPORTS_TABLE (id, name) values (gen_random_uuid(), 'SOCCER');

-- Add all soccer sports leagues
DO $$
DECLARE
    soccer_parent_id UUID;
BEGIN

    SELECT id INTO soccer_parent_id FROM SPORTS_TABLE WHERE name = 'SOCCER';

    INSERT INTO SPORTS_TABLE (id, name, parent_id)
    VALUES
        (gen_random_uuid(), 'SUPER_LEAGUE', soccer_parent_id),
        (gen_random_uuid(), 'PREMIER_LEAGUE', soccer_parent_id),
        (gen_random_uuid(), 'CHAMPIONS_LEAGUE', soccer_parent_id),
        (gen_random_uuid(), 'LAlIGA', soccer_parent_id),
        (gen_random_uuid(), 'BUNDESLIGA', soccer_parent_id),
        (gen_random_uuid(), 'SERIE_A', soccer_parent_id),
        (gen_random_uuid(), 'EUROPA_LEAGUE', soccer_parent_id),
        (gen_random_uuid(), 'LIGUE_1', soccer_parent_id);
END
$$;
