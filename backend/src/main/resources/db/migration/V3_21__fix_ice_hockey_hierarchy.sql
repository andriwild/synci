-- Fix ice hockey hierarchy to 3 levels
-- First, delete events that reference the sports we're going to restructure
DELETE FROM EVENTS_TABLE WHERE sport_id IN (
    SELECT id FROM SPORTS_TABLE WHERE name IN (
        'NATIONAL_LEAGUE_QUALIFICATION',
        'NATIONAL_LEAGUE_PLAYOFF',
        'SWISS_LEAGUE_QUALIFICATION',
        'SWISS_LEAGUE_PLAYOFF',
        'NHL_QUALIFICATION',
        'NHL_PLAYOFF'
    )
);

-- Then remove the current ice hockey entries
DELETE FROM SPORTS_TABLE WHERE name IN (
    'NATIONAL_LEAGUE_QUALIFICATION',
    'NATIONAL_LEAGUE_PLAYOFF',
    'SWISS_LEAGUE_QUALIFICATION',
    'SWISS_LEAGUE_PLAYOFF',
    'NHL_QUALIFICATION',
    'NHL_PLAYOFF'
);

-- Add 3-level hierarchy for ice hockey
DO $$
DECLARE
    ice_hockey_parent_id UUID;
    national_league_id UUID;
    swiss_league_id UUID;
    nhl_id UUID;
BEGIN
    -- Get ice hockey parent ID
    SELECT id INTO ice_hockey_parent_id FROM SPORTS_TABLE WHERE name = 'ICE_HOCKEY';

    -- Insert level 2 (leagues)
    INSERT INTO SPORTS_TABLE (id, name, parent_id)
    VALUES
        (gen_random_uuid(), 'NATIONAL_LEAGUE', ice_hockey_parent_id),
        (gen_random_uuid(), 'SWISS_LEAGUE', ice_hockey_parent_id),
        (gen_random_uuid(), 'NHL', ice_hockey_parent_id);

    -- Get the IDs of level 2
    SELECT id INTO national_league_id FROM SPORTS_TABLE WHERE name = 'NATIONAL_LEAGUE';
    SELECT id INTO swiss_league_id FROM SPORTS_TABLE WHERE name = 'SWISS_LEAGUE';
    SELECT id INTO nhl_id FROM SPORTS_TABLE WHERE name = 'NHL';

    -- Insert level 3 (phases)
    INSERT INTO SPORTS_TABLE (id, name, parent_id)
    VALUES
        -- National League phases
        (gen_random_uuid(), 'NATIONAL_LEAGUE_QUALIFICATION', national_league_id),
        (gen_random_uuid(), 'NATIONAL_LEAGUE_PLAYOFF', national_league_id),
        -- Swiss League phases
        (gen_random_uuid(), 'SWISS_LEAGUE_QUALIFICATION', swiss_league_id),
        (gen_random_uuid(), 'SWISS_LEAGUE_PLAYOFF', swiss_league_id),
        -- NHL phases
        (gen_random_uuid(), 'NHL_QUALIFICATION', nhl_id),
        (gen_random_uuid(), 'NHL_PLAYOFF', nhl_id);
END
$$;