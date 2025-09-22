DO $$
    DECLARE
        soccer_ch_parent_id UUID;
        soccer_europa_cup_parent_id UUID;
        soccer_euro_league_parent_id UUID;
        soccer_euro_parent_id UUID;
        soccer_conference_parent_id UUID;
        soccer_nati_m_parent_id UUID;
        soccer_nati_w_parent_id UUID;
    BEGIN
        SELECT id INTO soccer_ch_parent_id          FROM SPORTS_TABLE WHERE name = 'SOCCER_CH_LEAGUES';
        SELECT id INTO soccer_euro_parent_id        FROM SPORTS_TABLE WHERE name = 'SOCCER_EURO_LEAGUES';
        SELECT id INTO soccer_europa_cup_parent_id  FROM SPORTS_TABLE WHERE name = 'SOCCER_EUROPA_CUP';
        SELECT id INTO soccer_euro_league_parent_id FROM SPORTS_TABLE WHERE name = 'EUROPA_LEAGUE';
        SELECT id INTO soccer_conference_parent_id  FROM SPORTS_TABLE WHERE name = 'SOCCER_CONFERENCE_LEAGUE';
        SELECT id INTO soccer_nati_m_parent_id      FROM SPORTS_TABLE WHERE name = 'SOCCER_NATI_MEN';
        SELECT id INTO soccer_nati_w_parent_id      FROM SPORTS_TABLE WHERE name = 'SOCCER_NATI_WOMEN';


        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        VALUES
            (gen_random_uuid(), 'SOCCER_CHALLENGE_LEAGUE',      soccer_ch_parent_id, 'Challenge League'),
            (gen_random_uuid(), 'SOCCER_CUP',                   soccer_ch_parent_id, 'Schweizer Cup'),
            (gen_random_uuid(), 'SOCCER_1_LIGA',                soccer_ch_parent_id, '1. Liga'),
            (gen_random_uuid(), 'SOCCER_SUPER_LEAGUE_WOMEN',    soccer_ch_parent_id, 'Super League Frauen'),

            -- euro leagues
            (gen_random_uuid(), 'SOCCER_DFB_POKAL',         soccer_euro_parent_id, 'DFB Pokal'),
            (gen_random_uuid(), 'SOCCER_FA_CUP',            soccer_euro_parent_id, 'FA Cup'),
            (gen_random_uuid(), 'SOCCER_COPA_DEL_REY',      soccer_euro_parent_id, 'Copa del Rey'),
            (gen_random_uuid(), 'SOCCER_COPPA_ITALIA',      soccer_euro_parent_id, 'Coppa Italia'),
            (gen_random_uuid(), 'SOCCER_COUPE_DE_FRANCE',   soccer_euro_parent_id, 'Coupe de France'),

            -- nati men
            (gen_random_uuid(), 'SOCCER_EURO',              soccer_nati_m_parent_id, 'Europameisterschaft'),
            (gen_random_uuid(), 'SOCCER_EURO_QUALI',        soccer_nati_m_parent_id, 'EM Qualifikation'),
            (gen_random_uuid(), 'SOCCER_WM',                soccer_nati_m_parent_id, 'Weltmeisterschaft'),
            (gen_random_uuid(), 'SOCCER_WM_QUALI',          soccer_nati_m_parent_id, 'WM Qualifikation'),
            (gen_random_uuid(), 'SOCCER_NATIONS_LEAGUE',    soccer_nati_m_parent_id, 'Nations League'),
            (gen_random_uuid(), 'SOCCER_TESTGAMES',         soccer_nati_m_parent_id, 'Testspiele'),
            (gen_random_uuid(), 'SOCCER_AFRICA_CUP',        soccer_nati_m_parent_id, 'Afrika Cup'),
            (gen_random_uuid(), 'SOCCER_COPA_AMERICA',      soccer_nati_m_parent_id, 'Copa América'),
            (gen_random_uuid(), 'SOCCER_U21_EURO',          soccer_nati_m_parent_id, 'U21 Europameisterschaft'),
            (gen_random_uuid(), 'SOCCER_U21_EURO_QUALI',    soccer_nati_m_parent_id, 'U21 EM Qualifikation'),

            -- nati women
            (gen_random_uuid(), 'SOCCER_EURO_QUALI_WOMEN',      soccer_nati_w_parent_id, 'Frauen EM Qualifikation'),
            (gen_random_uuid(), 'SOCCER_WM_WOMEN',              soccer_nati_w_parent_id, 'Frauen Weltmeisterschaft'),
            (gen_random_uuid(), 'SOCCER_TESTGAMES_WOMEN',       soccer_nati_w_parent_id, 'Frauen Testspiele'),
            (gen_random_uuid(), 'SOCCER_EURO_WOMEN',            soccer_nati_w_parent_id, 'Frauen Europameisterschaft'),
            (gen_random_uuid(), 'SOCCER_NATIONS_LEAGUE_WOMEN',  soccer_nati_w_parent_id, 'Frauen Nations League'),

            -- europa league
            (gen_random_uuid(), 'SOCCER_EUROPA_LEAGUE_QUALIFICATION_1', soccer_euro_league_parent_id, 'Qualifikation 1'),
            (gen_random_uuid(), 'SOCCER_EUROPA_LEAGUE_QUALIFICATION_2', soccer_euro_league_parent_id, 'Qualifikation 2'),
            (gen_random_uuid(), 'SOCCER_EUROPA_LEAGUE_QUALIFICATION_3', soccer_euro_league_parent_id, 'Qualifikation 3'),
            (gen_random_uuid(), 'SOCCER_EUROPA_LEAGUE_PLAYOFF_ROUND',   soccer_euro_league_parent_id, 'Playoff'),
            (gen_random_uuid(), 'SOCCER_EUROPA_LEAGUE_MAIN_ROUND',      soccer_euro_league_parent_id, 'Hauptrunde'),

            -- conference league
            (gen_random_uuid(), 'SOCCER_CONFERENCE_LEAGUE_QUALIFICATION_1', soccer_conference_parent_id, 'Qualifikation 1'),
            (gen_random_uuid(), 'SOCCER_CONFERENCE_LEAGUE_QUALIFICATION_2', soccer_conference_parent_id, 'Qualifikation 2'),
            (gen_random_uuid(), 'SOCCER_CONFERENCE_LEAGUE_QUALIFICATION_3', soccer_conference_parent_id, 'Qualifikation 3'),
            (gen_random_uuid(), 'SOCCER_CONFERENCE_LEAGUE_PLAYOFF_ROUND',   soccer_conference_parent_id, 'Playoff'),
            (gen_random_uuid(), 'SOCCER_CONFERENCE_LEAGUE_MAIN_ROUND',      soccer_conference_parent_id, 'Hauptrunde');

    END
$$;

DO $$
    DECLARE
        euro_women_parent_id UUID;
        nations_league_parent_id UUID;
        nations_league_women_parent_id UUID;
    BEGIN
        SELECT id INTO euro_women_parent_id             FROM SPORTS_TABLE WHERE name = 'SOCCER_EURO_WOMEN';
        SELECT id INTO nations_league_parent_id         FROM SPORTS_TABLE WHERE name = 'SOCCER_NATIONS_LEAGUE';
        SELECT id INTO nations_league_women_parent_id   FROM SPORTS_TABLE WHERE name = 'SOCCER_NATIONS_LEAGUE_WOMEN';

    INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
    VALUES
        (gen_random_uuid(), 'SOCCER_EURO_WOMEN_GROUP_PHASE',    euro_women_parent_id, 'Gruppenphase'),
        (gen_random_uuid(), 'SOCCER_EURO_WOMEN_FINALS',         euro_women_parent_id, 'Finalrunde'),

        (gen_random_uuid(), 'SOCCER_NATIONS_LEAGUE_GROUP_PHASE',    nations_league_parent_id, 'Gruppenphase'),
        (gen_random_uuid(), 'SOCCER_NATIONS_LEAGUE_FINALS',         nations_league_parent_id, 'Finalrunde'),

        (gen_random_uuid(), 'SOCCER_NATIONS_LEAGUE_WOMEN_GROUP_PHASE',  nations_league_women_parent_id, 'Gruppenphase'),
        (gen_random_uuid(), 'SOCCER_NATIONS_LEAGUE_WOMEN_FINALS',       nations_league_women_parent_id, 'Finalrunde');
    END
$$;