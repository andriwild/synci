DO $$
    DECLARE
        hockey_parent_id UUID;
    BEGIN
        SELECT id INTO hockey_parent_id FROM SPORTS_TABLE WHERE name = 'HOCKEY';

        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        VALUES
            (gen_random_uuid(), 'HOCKEY_WM',       hockey_parent_id, 'WM Männer'),
            (gen_random_uuid(), 'HOCKEY_WM_WOMEN', hockey_parent_id, 'WM Frauen');
    END
$$;
