INSERT INTO SPORTS_TABLE (id, name) values (gen_random_uuid(), 'ICE_HOCKEY');

-- Add all ice hockey sports leagues
DO $$
DECLARE
    ice_hockey_parent_id UUID;
BEGIN

    SELECT id INTO ice_hockey_parent_id FROM SPORTS_TABLE WHERE name = 'ICE_HOCKEY';

    INSERT INTO SPORTS_TABLE (id, name, parent_id)
    VALUES
        (gen_random_uuid(), 'NATIONAL_LEAGUE_QUALIFICATION', ice_hockey_parent_id),
        (gen_random_uuid(), 'NATIONAL_LEAGUE_PLAYOFF', ice_hockey_parent_id),
        (gen_random_uuid(), 'SWISS_LEAGUE_QUALIFICATION', ice_hockey_parent_id),
        (gen_random_uuid(), 'SWISS_LEAGUE_PLAYOFF', ice_hockey_parent_id),
        (gen_random_uuid(), 'NHL_QUALIFICATION', ice_hockey_parent_id),
        (gen_random_uuid(), 'NHL_PLAYOFF', ice_hockey_parent_id);
END
$$;