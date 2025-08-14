-- Add display labels for ice hockey sports
UPDATE SPORTS_TABLE
SET label = CASE name
                WHEN 'ICE_HOCKEY'                    THEN 'Eishockey'
                WHEN 'NATIONAL_LEAGUE_QUALIFICATION' THEN 'National League Qualifikation'
                WHEN 'NATIONAL_LEAGUE_PLAYOFF'       THEN 'National League Playoff'
                WHEN 'SWISS_LEAGUE_QUALIFICATION'    THEN 'Swiss League Qualifikation'
                WHEN 'SWISS_LEAGUE_PLAYOFF'          THEN 'Swiss League Playoff'
                WHEN 'NHL_QUALIFICATION'             THEN 'NHL Qualifikation'
                WHEN 'NHL_PLAYOFF'                   THEN 'NHL Playoff'
                ELSE label
    END
WHERE name IN (
               'ICE_HOCKEY',
               'NATIONAL_LEAGUE_QUALIFICATION',
               'NATIONAL_LEAGUE_PLAYOFF',
               'SWISS_LEAGUE_QUALIFICATION',
               'SWISS_LEAGUE_PLAYOFF',
               'NHL_QUALIFICATION',
               'NHL_PLAYOFF'
    );