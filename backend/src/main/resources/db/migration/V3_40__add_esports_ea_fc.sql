-- EA Sports FC (PandaScore videogame "fifa") below E-Sport
DO $$
    DECLARE
        esports_id UUID;
    BEGIN
        SELECT id INTO esports_id FROM SPORTS_TABLE WHERE name = 'ESPORTS';

        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        VALUES (gen_random_uuid(), 'ESPORTS_EA_FC', esports_id, 'EA Sports FC');
    END
$$;
