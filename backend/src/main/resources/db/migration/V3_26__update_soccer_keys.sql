DO $$
    DECLARE
        soccer_ch_parent_id UUID;
        soccer_europacup_parent_id UUID;
        soccer_euro_parent_id UUID;
        soccer_nati_m_parent_id UUID;
        soccer_nati_w_parent_id UUID;
        champions_id UUID;
        soccer_champions_id UUID;
        bundesliga_id UUID;
        europa_league_id UUID;
        laliga_id UUID;
        ligue_1_id UUID;
        premier_league_id UUID;
        serie_a_id UUID;
        super_league_id UUID;
        cl_quali_1_id UUID;
        cl_quali_2_id UUID;
        cl_quali_3_id UUID;
        cl_playoff_id UUID;
        cl_main_id UUID;
        cl_ko_round UUID;
    BEGIN
        SELECT id INTO soccer_ch_parent_id          FROM SPORTS_TABLE WHERE name = 'SOCCER_CH_LEAGUES';
        SELECT id INTO soccer_europacup_parent_id   FROM SPORTS_TABLE WHERE name = 'SOCCER_EUROPA_CUP';
        SELECT id INTO soccer_euro_parent_id        FROM SPORTS_TABLE WHERE name = 'SOCCER_EURO_LEAGUES';
        SELECT id INTO soccer_nati_m_parent_id      FROM SPORTS_TABLE WHERE name = 'SOCCER_NATI_MEN';
        SELECT id INTO soccer_nati_w_parent_id      FROM SPORTS_TABLE WHERE name = 'SOCCER_NATI_WOMEN';

        SELECT id INTO champions_id         FROM SPORTS_TABLE WHERE name = 'CHAMPIONS_LEAGUE';
        SELECT id INTO bundesliga_id        FROM SPORTS_TABLE WHERE name = 'BUNDESLIGA';
        SELECT id INTO europa_league_id     FROM SPORTS_TABLE WHERE name = 'EUROPA_LEAGUE';
        SELECT id INTO laliga_id            FROM SPORTS_TABLE WHERE name = 'LAlIGA';
        SELECT id INTO ligue_1_id           FROM SPORTS_TABLE WHERE name = 'LIGUE_1';
        SELECT id INTO premier_league_id    FROM SPORTS_TABLE WHERE name = 'PREMIER_LEAGUE';
        SELECT id INTO serie_a_id           FROM SPORTS_TABLE WHERE name = 'SERIE_A';
        SELECT id INTO super_league_id      FROM SPORTS_TABLE WHERE name = 'SUPER_LEAGUE';
        SELECT id INTO cl_quali_1_id        FROM SPORTS_TABLE WHERE name = 'CL_QUALIFICATION_1';
        SELECT id INTO cl_quali_2_id        FROM SPORTS_TABLE WHERE name = 'CL_QUALIFICATION_2';
        SELECT id INTO cl_quali_3_id        FROM SPORTS_TABLE WHERE name = 'CL_QUALIFICATION_3';
        SELECT id INTO cl_playoff_id        FROM SPORTS_TABLE WHERE name = 'CL_PLAYOFF_ROUND';
        SELECT id INTO cl_main_id           FROM SPORTS_TABLE WHERE name = 'CL_MAIN_ROUND';
        SELECT id INTO cl_ko_round          FROM SPORTS_TABLE WHERE name = 'CL_KO_ROUND';

        UPDATE SPORTS_TABLE SET name = 'SOCCER_PRIMERA_DIVISION', parent_id = soccer_euro_parent_id, label='Primera División' WHERE id = laliga_id;

        UPDATE SPORTS_TABLE SET name = 'SOCCER_CHAMPIONS_LEAGUE',       parent_id = soccer_europacup_parent_id  WHERE id = champions_id;
        UPDATE SPORTS_TABLE SET name = 'SOCCER_BUNDESLIGA',             parent_id = soccer_euro_parent_id       WHERE id = bundesliga_id;
        UPDATE SPORTS_TABLE SET name = 'SOCCER_EUROPA_LEAGUE',          parent_id = soccer_europacup_parent_id  WHERE id = europa_league_id;
        UPDATE SPORTS_TABLE SET name = 'SOCCER_LIGUE_1',                parent_id = soccer_euro_parent_id       WHERE id = ligue_1_id;
        UPDATE SPORTS_TABLE SET name = 'SOCCER_PREMIER_LEAGUE',         parent_id = soccer_euro_parent_id       WHERE id = premier_league_id;
        UPDATE SPORTS_TABLE SET name = 'SOCCER_SERIE_A',                parent_id = soccer_euro_parent_id       WHERE id = serie_a_id;
        UPDATE SPORTS_TABLE SET name = 'SOCCER_SUPER_LEAGUE',           parent_id = soccer_ch_parent_id         WHERE id = super_league_id;

        SELECT id INTO soccer_champions_id FROM SPORTS_TABLE WHERE name = 'SOCCER_CHAMPIONS_LEAGUE';

        UPDATE SPORTS_TABLE SET name = 'SOCCER_CL_QUALIFICATION_1',     parent_id = soccer_champions_id, label='Qualifikation 1'    WHERE id = cl_quali_1_id;
        UPDATE SPORTS_TABLE SET name = 'SOCCER_CL_QUALIFICATION_2',     parent_id = soccer_champions_id, label='Qualifikation 2'    WHERE id = cl_quali_2_id;
        UPDATE SPORTS_TABLE SET name = 'SOCCER_CL_QUALIFICATION_3',     parent_id = soccer_champions_id, label='Qualifikation 3'    WHERE id = cl_quali_3_id;
        UPDATE SPORTS_TABLE SET name = 'SOCCER_CL_PLAYOFF_ROUND',       parent_id = soccer_champions_id, label='Playoff'            WHERE id = cl_playoff_id;
        UPDATE SPORTS_TABLE SET name = 'SOCCER_CL_MAIN_ROUND',          parent_id = soccer_champions_id, label='Hauptrunde'         WHERE id = cl_main_id;
    END
$$;