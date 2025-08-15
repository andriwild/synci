-- Fix floorball hierarchy to 3 levels
-- First, delete events that reference the sports we're going to restructure
DELETE FROM EVENTS_TABLE WHERE sport_id IN (
    SELECT id FROM SPORTS_TABLE WHERE name IN (
        'UPL_MEN_QUALIFICATION',
        'UPL_WOMEN_QUALIFICATION', 
        'WM_MEN_GROUPSTAGE',
        'WM_MEN_FINALS',
        'WM_WOMEN_GROUPSTAGE',
        'WM_WOMEN_FINALS'
    )
);

-- Then remove the current floorball entries
DELETE FROM SPORTS_TABLE WHERE name IN (
    'UPL_MEN_QUALIFICATION',
    'UPL_WOMEN_QUALIFICATION', 
    'WM_MEN_GROUPSTAGE',
    'WM_MEN_FINALS',
    'WM_WOMEN_GROUPSTAGE',
    'WM_WOMEN_FINALS'
);

-- Add 3-level hierarchy for floorball
DO $$
DECLARE
    floorball_parent_id UUID;
    upl_men_id UUID;
    upl_women_id UUID;
    wm_men_id UUID;
    wm_women_id UUID;
BEGIN
    -- Get floorball parent ID
    SELECT id INTO floorball_parent_id FROM SPORTS_TABLE WHERE name = 'FLOORBALL';

    -- Insert level 2 (leagues)
    INSERT INTO SPORTS_TABLE (id, name, parent_id)
    VALUES
        (gen_random_uuid(), 'UPL_MEN', floorball_parent_id),
        (gen_random_uuid(), 'UPL_WOMEN', floorball_parent_id),
        (gen_random_uuid(), 'WM_MEN', floorball_parent_id),
        (gen_random_uuid(), 'WM_WOMEN', floorball_parent_id);

    -- Get the IDs of level 2
    SELECT id INTO upl_men_id FROM SPORTS_TABLE WHERE name = 'UPL_MEN';
    SELECT id INTO upl_women_id FROM SPORTS_TABLE WHERE name = 'UPL_WOMEN';
    SELECT id INTO wm_men_id FROM SPORTS_TABLE WHERE name = 'WM_MEN';
    SELECT id INTO wm_women_id FROM SPORTS_TABLE WHERE name = 'WM_WOMEN';

    -- Insert level 3 (phases)
    INSERT INTO SPORTS_TABLE (id, name, parent_id)
    VALUES
        -- UPL Men phases
        (gen_random_uuid(), 'UPL_MEN_QUALIFICATION', upl_men_id),
        (gen_random_uuid(), 'UPL_MEN_PLAYOFF', upl_men_id),
        -- UPL Women phases
        (gen_random_uuid(), 'UPL_WOMEN_QUALIFICATION', upl_women_id),
        (gen_random_uuid(), 'UPL_WOMEN_PLAYOFF', upl_women_id),
        -- WM Men phases
        (gen_random_uuid(), 'WM_MEN_GROUPSTAGE', wm_men_id),
        (gen_random_uuid(), 'WM_MEN_FINALS', wm_men_id),
        -- WM Women phases
        (gen_random_uuid(), 'WM_WOMEN_GROUPSTAGE', wm_women_id),
        (gen_random_uuid(), 'WM_WOMEN_FINALS', wm_women_id);
END
$$;