-- Ensure ice hockey sport names match exactly with swisstxt.yml
-- Check and fix any naming mismatches

DO $$
DECLARE
    ice_hockey_parent_id UUID;
    national_league_id UUID;
    swiss_league_id UUID;
    nhl_id UUID;
BEGIN
    -- Get parent IDs
    SELECT id INTO ice_hockey_parent_id FROM SPORTS_TABLE WHERE name = 'ICE_HOCKEY';
    SELECT id INTO national_league_id FROM SPORTS_TABLE WHERE name = 'NATIONAL_LEAGUE';
    SELECT id INTO swiss_league_id FROM SPORTS_TABLE WHERE name = 'SWISS_LEAGUE';
    SELECT id INTO nhl_id FROM SPORTS_TABLE WHERE name = 'NHL';

    -- Ensure all required ice hockey sports exist with correct names
    -- If they don't exist, insert them
    INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
    SELECT gen_random_uuid(), 'NATIONAL_LEAGUE_QUALIFICATION', national_league_id, 'Qualifikation'
    WHERE NOT EXISTS (SELECT 1 FROM SPORTS_TABLE WHERE name = 'NATIONAL_LEAGUE_QUALIFICATION');

    INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
    SELECT gen_random_uuid(), 'SWISS_LEAGUE_QUALIFICATION', swiss_league_id, 'Qualifikation'
    WHERE NOT EXISTS (SELECT 1 FROM SPORTS_TABLE WHERE name = 'SWISS_LEAGUE_QUALIFICATION');

    INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
    SELECT gen_random_uuid(), 'NHL_QUALIFICATION', nhl_id, 'Qualifikation'
    WHERE NOT EXISTS (SELECT 1 FROM SPORTS_TABLE WHERE name = 'NHL_QUALIFICATION');
    
    -- Also ensure floorball sports exist with correct names
    DECLARE
        floorball_parent_id UUID;
        upl_men_id UUID;
        upl_women_id UUID;
        wm_men_id UUID;
        wm_women_id UUID;
    BEGIN
        SELECT id INTO floorball_parent_id FROM SPORTS_TABLE WHERE name = 'FLOORBALL';
        SELECT id INTO upl_men_id FROM SPORTS_TABLE WHERE name = 'UPL_MEN';
        SELECT id INTO upl_women_id FROM SPORTS_TABLE WHERE name = 'UPL_WOMEN';
        SELECT id INTO wm_men_id FROM SPORTS_TABLE WHERE name = 'WM_MEN';
        SELECT id INTO wm_women_id FROM SPORTS_TABLE WHERE name = 'WM_WOMEN';

        -- Ensure floorball sports exist
        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        SELECT gen_random_uuid(), 'UPL_MEN_QUALIFICATION', upl_men_id, 'Qualifikation'
        WHERE NOT EXISTS (SELECT 1 FROM SPORTS_TABLE WHERE name = 'UPL_MEN_QUALIFICATION');

        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        SELECT gen_random_uuid(), 'UPL_WOMEN_QUALIFICATION', upl_women_id, 'Qualifikation'
        WHERE NOT EXISTS (SELECT 1 FROM SPORTS_TABLE WHERE name = 'UPL_WOMEN_QUALIFICATION');

        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        SELECT gen_random_uuid(), 'WM_MEN_GROUPSTAGE', wm_men_id, 'Gruppenspiele'
        WHERE NOT EXISTS (SELECT 1 FROM SPORTS_TABLE WHERE name = 'WM_MEN_GROUPSTAGE');

        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        SELECT gen_random_uuid(), 'WM_MEN_FINALS', wm_men_id, 'Finalspiele'
        WHERE NOT EXISTS (SELECT 1 FROM SPORTS_TABLE WHERE name = 'WM_MEN_FINALS');

        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        SELECT gen_random_uuid(), 'WM_WOMEN_GROUPSTAGE', wm_women_id, 'Gruppenspiele'
        WHERE NOT EXISTS (SELECT 1 FROM SPORTS_TABLE WHERE name = 'WM_WOMEN_GROUPSTAGE');

        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        SELECT gen_random_uuid(), 'WM_WOMEN_FINALS', wm_women_id, 'Finalspiele'
        WHERE NOT EXISTS (SELECT 1 FROM SPORTS_TABLE WHERE name = 'WM_WOMEN_FINALS');
    END;
END
$$;