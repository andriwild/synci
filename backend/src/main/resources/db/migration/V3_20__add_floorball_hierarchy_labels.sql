-- Add display labels for 3-level floorball hierarchy
UPDATE SPORTS_TABLE
SET label = CASE name
                -- Level 1
                WHEN 'FLOORBALL'                THEN 'Unihockey'
                -- Level 2 (leagues)
                WHEN 'UPL_MEN'                  THEN 'UPL Männer'
                WHEN 'UPL_WOMEN'                THEN 'UPL Frauen'
                WHEN 'WM_MEN'                   THEN 'WM Männer'
                WHEN 'WM_WOMEN'                 THEN 'WM Frauen'
                -- Level 3 (phases)
                WHEN 'UPL_MEN_QUALIFICATION'    THEN 'Qualifikation'
                WHEN 'UPL_MEN_PLAYOFF'          THEN 'Playoff'
                WHEN 'UPL_WOMEN_QUALIFICATION'  THEN 'Qualifikation'
                WHEN 'UPL_WOMEN_PLAYOFF'        THEN 'Playoff'
                WHEN 'WM_MEN_GROUPSTAGE'        THEN 'Gruppenspiele'
                WHEN 'WM_MEN_FINALS'            THEN 'Finalspiele'
                WHEN 'WM_WOMEN_GROUPSTAGE'      THEN 'Gruppenspiele'
                WHEN 'WM_WOMEN_FINALS'          THEN 'Finalspiele'
                ELSE label
    END
WHERE name IN (
               'FLOORBALL',
               'UPL_MEN', 'UPL_WOMEN', 'WM_MEN', 'WM_WOMEN',
               'UPL_MEN_QUALIFICATION', 'UPL_MEN_PLAYOFF',
               'UPL_WOMEN_QUALIFICATION', 'UPL_WOMEN_PLAYOFF',
               'WM_MEN_GROUPSTAGE', 'WM_MEN_FINALS',
               'WM_WOMEN_GROUPSTAGE', 'WM_WOMEN_FINALS'
    );