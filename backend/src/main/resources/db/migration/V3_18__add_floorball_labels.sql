-- Add display labels for floorball sports
UPDATE SPORTS_TABLE
SET label = CASE name
                WHEN 'FLOORBALL'                THEN 'Unihockey'
                WHEN 'UPL_MEN_QUALIFICATION'    THEN 'UPL Männer Qualifikation'
                WHEN 'UPL_WOMEN_QUALIFICATION'  THEN 'UPL Frauen Qualifikation'
                WHEN 'WM_MEN_GROUPSTAGE'        THEN 'WM Männer Gruppenspiele'
                WHEN 'WM_MEN_FINALS'            THEN 'WM Männer Finalspiele'
                WHEN 'WM_WOMEN_GROUPSTAGE'      THEN 'WM Frauen Gruppenspiele'
                WHEN 'WM_WOMEN_FINALS'          THEN 'WM Frauen Finalspiele'
                ELSE label
    END
WHERE name IN (
               'FLOORBALL',
               'UPL_MEN_QUALIFICATION',
               'UPL_WOMEN_QUALIFICATION',
               'WM_MEN_GROUPSTAGE',
               'WM_MEN_FINALS',
               'WM_WOMEN_GROUPSTAGE',
               'WM_WOMEN_FINALS'
    );