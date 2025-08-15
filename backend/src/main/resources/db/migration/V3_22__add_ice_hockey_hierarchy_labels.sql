-- Add display labels for 3-level ice hockey hierarchy
UPDATE SPORTS_TABLE
SET label = CASE name
                -- Level 1
                WHEN 'ICE_HOCKEY'                   THEN 'Eishockey'
                -- Level 2 (leagues)
                WHEN 'NATIONAL_LEAGUE'              THEN 'National League'
                WHEN 'SWISS_LEAGUE'                 THEN 'Swiss League'
                WHEN 'NHL'                          THEN 'NHL'
                -- Level 3 (phases)
                WHEN 'NATIONAL_LEAGUE_QUALIFICATION' THEN 'Qualifikation'
                WHEN 'NATIONAL_LEAGUE_PLAYOFF'      THEN 'Playoff'
                WHEN 'SWISS_LEAGUE_QUALIFICATION'   THEN 'Qualifikation'
                WHEN 'SWISS_LEAGUE_PLAYOFF'         THEN 'Playoff'
                WHEN 'NHL_QUALIFICATION'            THEN 'Qualifikation'
                WHEN 'NHL_PLAYOFF'                  THEN 'Playoff'
                ELSE label
    END
WHERE name IN (
               'ICE_HOCKEY',
               'NATIONAL_LEAGUE', 'SWISS_LEAGUE', 'NHL',
               'NATIONAL_LEAGUE_QUALIFICATION', 'NATIONAL_LEAGUE_PLAYOFF',
               'SWISS_LEAGUE_QUALIFICATION', 'SWISS_LEAGUE_PLAYOFF',
               'NHL_QUALIFICATION', 'NHL_PLAYOFF'
    );