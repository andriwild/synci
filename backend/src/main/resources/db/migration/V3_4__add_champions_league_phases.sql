DO $$
    DECLARE
        cl_parent_id UUID;
    BEGIN

        SELECT id INTO cl_parent_id FROM SPORTS_TABLE WHERE name = 'CHAMPIONS_LEAGUE';

        INSERT INTO SPORTS_TABLE (id, name, parent_id)
        VALUES
            (gen_random_uuid(), 'CL_QUALIFICATION_1', cl_parent_id),
            (gen_random_uuid(), 'CL_QUALIFICATION_2', cl_parent_id),
            (gen_random_uuid(), 'CL_QUALIFICATION_3', cl_parent_id),
            (gen_random_uuid(), 'CL_PLAYOFF_ROUND', cl_parent_id),
            (gen_random_uuid(), 'CL_MAIN_ROUND', cl_parent_id),
            (gen_random_uuid(), 'CL_KO_ROUND', cl_parent_id);
    END
$$;