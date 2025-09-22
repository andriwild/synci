DO $$
    DECLARE
        ice_hockey_parent_id UUID;
    BEGIN
        SELECT id INTO ice_hockey_parent_id FROM SPORTS_TABLE WHERE name = 'ICE_HOCKEY';
        UPDATE SPORTS_TABLE SET name = 'HOCKEY' WHERE id = ice_hockey_parent_id;

        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        VALUES
            (gen_random_uuid(), 'HOCKEY_CHL',       ice_hockey_parent_id, 'Champions Hockey League'),
            (gen_random_uuid(), 'HOCKEY_MYSPORTS',  ice_hockey_parent_id, 'MySports Hockey League'),
            (gen_random_uuid(), 'HOCKEY_NLA_WOMEN', ice_hockey_parent_id, 'NLA Frauen');
    END
$$;

DO $$
    DECLARE
        hockey_chl_parent_id UUID;
        hockey_mysports_parent_id UUID;
        hockey_nla_w_parent_id UUID;
    BEGIN
        SELECT id INTO hockey_chl_parent_id         FROM SPORTS_TABLE WHERE name = 'HOCKEY_CHL';
        SELECT id INTO hockey_mysports_parent_id    FROM SPORTS_TABLE WHERE name = 'HOCKEY_MYSPORTS';
        SELECT id INTO hockey_nla_w_parent_id       FROM SPORTS_TABLE WHERE name = 'HOCKEY_NLA_WOMEN';

        INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
        VALUES
            (gen_random_uuid(), 'HOCKEY_CHL_QUALIFICATION', hockey_chl_parent_id, 'Qualifikation'),
            (gen_random_uuid(), 'HOCKEY_CHL_PLAYOFF',       hockey_chl_parent_id, 'Playoff'),

            (gen_random_uuid(), 'HOCKEY_MYSPORTS_QUALIFICATION', hockey_mysports_parent_id, 'Qualifikation'),
            (gen_random_uuid(), 'HOCKEY_MYSPORTS_PLAYOFF',       hockey_mysports_parent_id, 'Playoff'),

            (gen_random_uuid(), 'HOCKEY_NLA_WOMEN_QUALIFICATION', hockey_nla_w_parent_id, 'Qualifikation'),
            (gen_random_uuid(), 'HOCKEY_NLA_WOMEN_PLAYOFF',       hockey_nla_w_parent_id, 'Playoff');
    END
$$;

DO $$
    DECLARE
        hockey_parent_id UUID;
        hockey_nla UUID;
        hockey_nla_qual UUID;
        hockey_nla_playoff UUID;
        hockey_swiss_league UUID;
        hockey_swiss_league_qual UUID;
        hockey_swiss_league_playoff UUID;
        hockey_nhl UUID;
        hockey_nhl_qual UUID;
        hockey_nhl_playoff UUID;
    BEGIN
        SELECT id INTO hockey_parent_id FROM SPORTS_TABLE WHERE name = 'HOCKEY';

        SELECT id INTO hockey_nla                   FROM SPORTS_TABLE WHERE name = 'NATIONAL_LEAGUE';
        SELECT id INTO hockey_nla_qual              FROM SPORTS_TABLE WHERE name = 'NATIONAL_LEAGUE_QUALIFICATION';
        SELECT id INTO hockey_nla_playoff           FROM SPORTS_TABLE WHERE name = 'NATIONAL_LEAGUE_PLAYOFF';
        SELECT id INTO hockey_swiss_league          FROM SPORTS_TABLE WHERE name = 'SWISS_LEAGUE';
        SELECT id INTO hockey_swiss_league_qual     FROM SPORTS_TABLE WHERE name = 'SWISS_LEAGUE_QUALIFICATION';
        SELECT id INTO hockey_swiss_league_playoff  FROM SPORTS_TABLE WHERE name = 'SWISS_LEAGUE_PLAYOFF';
        SELECT id INTO hockey_nhl                   FROM SPORTS_TABLE WHERE name = 'NHL';
        SELECT id INTO hockey_nhl_qual              FROM SPORTS_TABLE WHERE name = 'NHL_QUALIFICATION';
        SELECT id INTO hockey_nhl_playoff           FROM SPORTS_TABLE WHERE name = 'NHL_PLAYOFF';

        UPDATE SPORTS_TABLE SET name = 'HOCKEY_NLA',               parent_id = hockey_parent_id, label = 'NLA Männer' WHERE id = hockey_nla;
        UPDATE SPORTS_TABLE SET name = 'HOCKEY_NLA_QUALIFICATION', parent_id = hockey_nla WHERE id = hockey_nla_qual;
        UPDATE SPORTS_TABLE SET name = 'HOCKEY_NLA_PLAYOFF',       parent_id = hockey_nla WHERE id = hockey_nla_playoff;
        UPDATE SPORTS_TABLE SET name = 'HOCKEY_NLB',               parent_id = hockey_parent_id WHERE id = hockey_swiss_league;
        UPDATE SPORTS_TABLE SET name = 'HOCKEY_NLB_QUALIFICATION', parent_id = hockey_swiss_league WHERE id = hockey_swiss_league_qual;
        UPDATE SPORTS_TABLE SET name = 'HOCKEY_NLB_PLAYOFF',       parent_id = hockey_swiss_league WHERE id = hockey_swiss_league_playoff;
        UPDATE SPORTS_TABLE SET name = 'HOCKEY_NHL',               parent_id = hockey_parent_id WHERE id = hockey_nhl;
        UPDATE SPORTS_TABLE SET name = 'HOCKEY_NHL_QUALIFICATION', parent_id = hockey_nhl WHERE id = hockey_nhl_qual;
        UPDATE SPORTS_TABLE SET name = 'HOCKEY_NHL_PLAYOFF',       parent_id = hockey_nhl WHERE id = hockey_nhl_playoff;
    END
$$;


DO $$
    DECLARE
        unihockey_parent_id UUID;
    BEGIN
        SELECT id INTO unihockey_parent_id FROM SPORTS_TABLE WHERE name = 'FLOORBALL';
        UPDATE SPORTS_TABLE SET name = 'UNIHOCKEY' WHERE id = unihockey_parent_id;
    END
$$;


DO $$
    DECLARE
        unihockey_parent_id UUID;
        unihockey_nla_men UUID;
        unihockey_nla_women UUID;
        unihockey_wm_men UUID;
        unihockey_wm_women UUID;
        unihockey_nla_men_qualification UUID;
        unihockey_nla_men_playoff UUID;
        unihockey_nla_women_qualification UUID;
        unihockey_nla_women_playoff UUID;
        unihockey_wm_men_groupstage UUID;
        unihockey_wm_men_finals UUID;
        unihockey_wm_women_groupstage UUID;
        unihockey_wm_women_finals UUID;
    BEGIN
        SELECT id INTO unihockey_parent_id FROM SPORTS_TABLE WHERE name = 'UNIHOCKEY';
        SELECT id INTO unihockey_nla_men                    FROM SPORTS_TABLE WHERE name = 'UPL_MEN';
        SELECT id INTO unihockey_nla_women                  FROM SPORTS_TABLE WHERE name = 'UPL_WOMEN';
        SELECT id INTO unihockey_wm_men                     FROM SPORTS_TABLE WHERE name = 'WM_MEN';
        SELECT id INTO unihockey_wm_women                   FROM SPORTS_TABLE WHERE name = 'WM_WOMEN';
        SELECT id INTO unihockey_nla_men_qualification      FROM SPORTS_TABLE WHERE name = 'UPL_MEN_QUALIFICATION';
        SELECT id INTO unihockey_nla_men_playoff            FROM SPORTS_TABLE WHERE name = 'UPL_MEN_PLAYOFF';
        SELECT id INTO unihockey_nla_women_qualification    FROM SPORTS_TABLE WHERE name = 'UPL_WOMEN_QUALIFICATION';
        SELECT id INTO unihockey_nla_women_playoff          FROM SPORTS_TABLE WHERE name = 'UPL_WOMEN_PLAYOFF';
        SELECT id INTO unihockey_wm_men_groupstage          FROM SPORTS_TABLE WHERE name = 'WM_MEN_GROUPSTAGE';
        SELECT id INTO unihockey_wm_men_finals              FROM SPORTS_TABLE WHERE name = 'WM_MEN_FINALS';
        SELECT id INTO unihockey_wm_women_groupstage        FROM SPORTS_TABLE WHERE name = 'WM_WOMEN_GROUPSTAGE';
        SELECT id INTO unihockey_wm_women_finals            FROM SPORTS_TABLE WHERE name = 'WM_WOMEN_FINALS';

        UPDATE SPORTS_TABLE SET name = 'UNIHOCKEY_NLA',                     parent_id = unihockey_parent_id WHERE id = unihockey_nla_men;
        UPDATE SPORTS_TABLE SET name = 'UNIHOCKEY_NLA_QUALIFICATION',       parent_id = unihockey_nla_men WHERE id = unihockey_nla_men_qualification;
        UPDATE SPORTS_TABLE SET name = 'UNIHOCKEY_NLA_PLAYOFF',             parent_id = unihockey_nla_men WHERE id = unihockey_nla_men_playoff;
        UPDATE SPORTS_TABLE SET name = 'UNIHOCKEY_NLA_WOMEN',               parent_id = unihockey_parent_id WHERE id = unihockey_nla_women;
        UPDATE SPORTS_TABLE SET name = 'UNIHOCKEY_NLA_WOMEN_QUALIFICATION', parent_id = unihockey_nla_women WHERE id = unihockey_nla_women_qualification;
        UPDATE SPORTS_TABLE SET name = 'UNIHOCKEY_NLA_WOMEN_PLAYOFF',       parent_id = unihockey_nla_women WHERE id = unihockey_nla_women_playoff;
        UPDATE SPORTS_TABLE SET name = 'UNIHOCKEY_WM_MEN',                  parent_id = unihockey_parent_id WHERE id = unihockey_wm_men;
        UPDATE SPORTS_TABLE SET name = 'UNIHOCKEY_WM_MEN_GROUPSTAGE',       parent_id = unihockey_wm_men WHERE id = unihockey_wm_men_groupstage;
        UPDATE SPORTS_TABLE SET name = 'UNIHOCKEY_WM_MEN_FINALS',           parent_id = unihockey_wm_men WHERE id = unihockey_wm_men_finals;
        UPDATE SPORTS_TABLE SET name = 'UNIHOCKEY_WM_WOMEN',                parent_id = unihockey_parent_id WHERE id = unihockey_wm_women;
        UPDATE SPORTS_TABLE SET name = 'UNIHOCKEY_WM_WOMEN_GROUPSTAGE',     parent_id = unihockey_wm_women WHERE id = unihockey_wm_women_groupstage;
        UPDATE SPORTS_TABLE SET name = 'UNIHOCKEY_WM_WOMEN_FINALS',         parent_id = unihockey_wm_women WHERE id = unihockey_wm_women_finals;
    END
$$;