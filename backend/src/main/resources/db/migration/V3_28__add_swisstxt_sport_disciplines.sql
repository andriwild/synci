DO $$
    DECLARE
        motorsport_parent_id UUID;
        motorrad_parent_id UUID;
        curling_parent_id UUID;
        handball_parent_id UUID;
        volleyball_parent_id UUID;
        volleyball_nla_parent_id UUID;
        volleyball_nla_w_parent_id UUID;
        basketball_parent_id UUID;
        basketball_nla_parent_id UUID;
        basketball_nba_id UUID;
        basketball_nla_w_parent_id UUID;
        cycling_parent_id UUID;
        tennis_parent_id UUID;
        schwingen_parent_id UUID;
        cross_country_parent_id UUID;
        ski_jumping_parent_id UUID;
        handball_nla_parent_id UUID;
        handball_nla_w_parent_id UUID;
    BEGIN

        SELECT id INTO motorsport_parent_id FROM SPORTS_TABLE WHERE name = 'MOTORSPORT';

        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        VALUES
            (gen_random_uuid(), 'MOTO', motorsport_parent_id, 'Motorrad'),
            (gen_random_uuid(), 'CURLING',          NULL, 'Curling'),
            (gen_random_uuid(), 'HANDBALL',         NULL, 'Handball'),
            (gen_random_uuid(), 'VOLLEYBALL',       NULL, 'Volleyball'),
            (gen_random_uuid(), 'BASKETBALL',       NULL, 'Basketball'),
            (gen_random_uuid(), 'CYCLING',          NULL, 'Radsport'),
            (gen_random_uuid(), 'TENNIS',           NULL, 'Tennis'),
            (gen_random_uuid(), 'SCHWINGEN',        NULL, 'Schwingen'),
            (gen_random_uuid(), 'CROSS-COUNTRY',    NULL, 'Langlauf'),
            (gen_random_uuid(), 'SKI-JUMPING',      NULL, 'Skispringen');

        SELECT id INTO motorrad_parent_id       FROM SPORTS_TABLE WHERE name = 'MOTO';
        SELECT id INTO curling_parent_id        FROM SPORTS_TABLE WHERE name = 'CURLING';
        SELECT id INTO handball_parent_id       FROM SPORTS_TABLE WHERE name = 'HANDBALL';
        SELECT id INTO volleyball_parent_id     FROM SPORTS_TABLE WHERE name = 'VOLLEYBALL';
        SELECT id INTO basketball_parent_id     FROM SPORTS_TABLE WHERE name = 'BASKETBALL';
        SELECT id INTO cycling_parent_id        FROM SPORTS_TABLE WHERE name = 'CYCLING';
        SELECT id INTO tennis_parent_id         FROM SPORTS_TABLE WHERE name = 'TENNIS';
        SELECT id INTO schwingen_parent_id      FROM SPORTS_TABLE WHERE name = 'SCHWINGEN';
        SELECT id INTO cross_country_parent_id  FROM SPORTS_TABLE WHERE name = 'CROSS-COUNTRY';
        SELECT id INTO ski_jumping_parent_id    FROM SPORTS_TABLE WHERE name = 'SKI-JUMPING';

        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        VALUES
            (gen_random_uuid(), 'CURLING_WM',       curling_parent_id, 'WM Männer'),
            (gen_random_uuid(), 'CURLING_EM',       curling_parent_id, 'EM Männer'),
            (gen_random_uuid(), 'CURLING_WM_WOMEN', curling_parent_id, 'WM Frauen'),
            (gen_random_uuid(), 'CURLING_EM_WOMEN', curling_parent_id, 'EM Frauen');

        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        VALUES
            (gen_random_uuid(), 'HANDBALL_NLA',         handball_parent_id, 'NLA Männer'),
            (gen_random_uuid(), 'HANDBALL_WM',          handball_parent_id, 'WM Männer'),
            (gen_random_uuid(), 'HANDBALL_EM',          handball_parent_id, 'EM Männer'),
            (gen_random_uuid(), 'HANDBALL_NLA_WOMEN',   handball_parent_id, 'NLA Frauen'),
            (gen_random_uuid(), 'HANDBALL_WM_WOMEN',    handball_parent_id, 'WM Frauen'),
            (gen_random_uuid(), 'HANDBALL_EM_WOMEN',    handball_parent_id, 'EM Frauen');

        SELECT id INTO handball_nla_parent_id   FROM SPORTS_TABLE WHERE name = 'HANDBALL_NLA';
        SELECT id INTO handball_nla_w_parent_id FROM SPORTS_TABLE WHERE name = 'HANDBALL_NLA_WOMEN';

        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        VALUES
            (gen_random_uuid(), 'HANDBALL_NLA_QUALIFICATION',       handball_nla_parent_id, 'Qualifikation'),
            (gen_random_uuid(), 'HANDBALL_NLA_PLAYOFF',             handball_nla_parent_id, 'Playoff'),
            (gen_random_uuid(), 'HANDBALL_NLA_WOMEN_QUALIFICATION', handball_nla_w_parent_id, 'Qualifikation'),
            (gen_random_uuid(), 'HANDBALL_NLA_WOMEN_PLAYOFF',       handball_nla_w_parent_id, 'Playoff');

        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        VALUES
            (gen_random_uuid(), 'VOLLEYBALL_NLA',       volleyball_parent_id, 'NLA Männer'),
            (gen_random_uuid(), 'VOLLEYBALL_NLA_WOMEN', volleyball_parent_id, 'NLA Frauen'),
            (gen_random_uuid(), 'VOLLEYBALL_EM',        volleyball_parent_id, 'EM Männer'),
            (gen_random_uuid(), 'VOLLEYBALL_EM_WOMEN',  volleyball_parent_id, 'EM Frauen');

        SELECT id INTO volleyball_nla_parent_id     FROM SPORTS_TABLE WHERE name = 'VOLLEYBALL_NLA';
        SELECT id INTO volleyball_nla_w_parent_id   FROM SPORTS_TABLE WHERE name = 'VOLLEYBALL_NLA_WOMEN';

        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        VALUES
            (gen_random_uuid(), 'VOLLEYBALL_NLA_QUALIFICATION',         volleyball_nla_parent_id, 'Qualifikation'),
            (gen_random_uuid(), 'VOLLEYBALL_NLA_PLAYOFF',               volleyball_nla_parent_id, 'Playoff'),
            (gen_random_uuid(), 'VOLLEYBALL_NLA_WOMEN_QUALIFICATION',   volleyball_nla_w_parent_id, 'Qualifikation'),
            (gen_random_uuid(), 'VOLLEYBALL_NLA_WOMEN_PLAYOFF',         volleyball_nla_w_parent_id, 'Playoff');

        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        VALUES
            (gen_random_uuid(), 'BASKETBALL_NLA',       basketball_parent_id, 'NLA Männer'),
            (gen_random_uuid(), 'BASKETBALL_NLA_WOMEN', basketball_parent_id, 'NLA Frauen'),
            (gen_random_uuid(), 'BASKETBALL_NBA',       basketball_parent_id, 'NBA');

        SELECT id INTO basketball_nla_parent_id     FROM SPORTS_TABLE WHERE name = 'BASKETBALL_NLA';
        SELECT id INTO basketball_nla_w_parent_id   FROM SPORTS_TABLE WHERE name = 'BASKETBALL_NLA_WOMEN';
        SELECT id INTO basketball_nba_id            FROM SPORTS_TABLE WHERE name = 'BASKETBALL_NBA';

        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        VALUES
            (gen_random_uuid(), 'BASKETBALL_NBA_QUALIFICATION',         basketball_nba_id, 'Qualifikation'),
            (gen_random_uuid(), 'BASKETBALL_NBA_PLAYOFF',               basketball_nba_id, 'Playoff'),
            (gen_random_uuid(), 'BASKETBALL_NLA_QUALIFICATION',         basketball_nla_parent_id, 'Qualifikation'),
            (gen_random_uuid(), 'BASKETBALL_NLA_PLAYOFF',               basketball_nla_parent_id, 'Playoff'),
            (gen_random_uuid(), 'BASKETBALL_NLA_WOMEN_QUALIFICATION',   basketball_nla_w_parent_id, 'Qualifikation'),
            (gen_random_uuid(), 'BASKETBALL_NLA_WOMEN_PLAYOFF',         basketball_nla_w_parent_id, 'Playoff');

        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        VALUES
            (gen_random_uuid(), 'CYCLING_MTB_WORLDCUP',         cycling_parent_id, 'MTB Worldcup Männer'),
            (gen_random_uuid(), 'CYCLING_MTB_WORLDCUP_WOMEN',   cycling_parent_id, 'MTB Worldcup Frauen');

        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        VALUES
            (gen_random_uuid(), 'TENNIS_ATP_TOUR', tennis_parent_id, 'ATP Tour'),
            (gen_random_uuid(), 'TENNIS_WTA_TOUR', tennis_parent_id, 'WTA Tour');

        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        VALUES
            (gen_random_uuid(), 'SCHWINGEN_KRANZSCHWINGFESTE', schwingen_parent_id, 'Kranzschwingfeste');

        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        VALUES
            (gen_random_uuid(), 'CROSS-COUNTRY_TOUR_DE_SKI',        cross_country_parent_id, 'Tour de Ski Männer'),
            (gen_random_uuid(), 'CROSS-COUNTRY_TOUR_DE_SKI_WOMEN',  cross_country_parent_id, 'Tour de Ski Frauen');

        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        VALUES
            (gen_random_uuid(), 'SKI-JUMPING_VIERSCHANZEN', ski_jumping_parent_id, 'Vierschanzentournee');

        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        VALUES
            (gen_random_uuid(), 'MOTO-GP', motorrad_parent_id, 'Moto GP'),
            (gen_random_uuid(), 'MOTO-2',  motorrad_parent_id, 'Moto 2'),
            (gen_random_uuid(), 'MOTO-3',  motorrad_parent_id, 'Moto 3');
    END
$$;