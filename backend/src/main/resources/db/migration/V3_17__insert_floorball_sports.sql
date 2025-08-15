INSERT INTO SPORTS_TABLE (id, name) values (gen_random_uuid(), 'FLOORBALL');

-- Add all floorball sports leagues
DO $$
DECLARE
    floorball_parent_id UUID;
BEGIN

    SELECT id INTO floorball_parent_id FROM SPORTS_TABLE WHERE name = 'FLOORBALL';

    INSERT INTO SPORTS_TABLE (id, name, parent_id)
    VALUES
        (gen_random_uuid(), 'UPL_MEN_QUALIFICATION', floorball_parent_id),
        (gen_random_uuid(), 'UPL_WOMEN_QUALIFICATION', floorball_parent_id),
        (gen_random_uuid(), 'WM_MEN_GROUPSTAGE', floorball_parent_id),
        (gen_random_uuid(), 'WM_MEN_FINALS', floorball_parent_id),
        (gen_random_uuid(), 'WM_WOMEN_GROUPSTAGE', floorball_parent_id),
        (gen_random_uuid(), 'WM_WOMEN_FINALS', floorball_parent_id);
END
$$;