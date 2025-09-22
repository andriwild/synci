DO $$
    DECLARE
        soccer_parent_id UUID;
    BEGIN
        SELECT id INTO soccer_parent_id FROM SPORTS_TABLE WHERE name = 'SOCCER';

        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        VALUES
            (gen_random_uuid(), 'SOCCER_CH_LEAGUES',    soccer_parent_id, 'Schweiz'),
            (gen_random_uuid(), 'SOCCER_EUROPA_CUP',    soccer_parent_id, 'Europacup'),
            (gen_random_uuid(), 'SOCCER_EURO_LEAGUES',  soccer_parent_id, 'Europ. Ligen'),
            (gen_random_uuid(), 'SOCCER_NATI_MEN',      soccer_parent_id, 'Nationalteams Männer'),
            (gen_random_uuid(), 'SOCCER_NATI_WOMEN',    soccer_parent_id, 'Nationalteams Frauen');
    END
$$;

DO $$
    DECLARE
        soccer_euro_parent_id UUID;
    BEGIN
        SELECT id INTO soccer_euro_parent_id FROM SPORTS_TABLE WHERE name = 'SOCCER_EUROPA_CUP';

        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        VALUES
            (gen_random_uuid(), 'SOCCER_CONFERENCE_LEAGUE', soccer_euro_parent_id, 'Conference League');
    END
$$;