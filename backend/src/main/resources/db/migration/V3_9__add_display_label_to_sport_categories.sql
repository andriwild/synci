ALTER TABLE SPORTS_TABLE ADD COLUMN label VARCHAR(255);

UPDATE SPORTS_TABLE
SET label = CASE name
                WHEN 'SOCCER'               THEN 'Fussball'
                WHEN 'SUPER_LEAGUE'         THEN 'Super League'
                WHEN 'PREMIER_LEAGUE'       THEN 'Premier League'
                WHEN 'CHAMPIONS_LEAGUE'     THEN 'Champions League'
                WHEN 'LAlIGA'               THEN 'La Liga'
                WHEN 'BUNDESLIGA'           THEN 'Bundesliga'
                WHEN 'SERIE_A'              THEN 'Serie A'
                WHEN 'EUROPA_LEAGUE'        THEN 'Europa League'
                WHEN 'LIGUE_1'              THEN 'Ligue 1'
                WHEN 'CL_QUALIFICATION_1'   THEN 'Champions League Qualifikation'
                WHEN 'CL_QUALIFICATION_2'   THEN 'Champions League Qualifikation'
                WHEN 'CL_QUALIFICATION_3'   THEN 'Champions League Qualifikation'
                WHEN 'CL_PLAYOFF_ROUND'     THEN 'Champions League Playoff'
                WHEN 'CL_MAIN_ROUND'        THEN 'Champions League Hauptrunde'
                WHEN 'CL_KO_ROUND'          THEN 'Champions League KO Runde'

                ELSE label
    END
WHERE name IN (
               'SOCCER',
               'CL_QUALIFICATION_1',
               'CL_QUALIFICATION_2',
               'CL_QUALIFICATION_3',
               'CL_PLAYOFF_ROUND',
               'CL_MAIN_ROUND',
               'CL_KO_ROUND',
               'SUPER_LEAGUE',
               'PREMIER_LEAGUE',
               'CHAMPIONS_LEAGUE',
               'LAlIGA',
               'BUNDESLIGA',
               'SERIE_A',
               'EUROPA_LEAGUE',
               'LIGUE_1'
    );

UPDATE SPORTS_TABLE
SET label = CASE name
                WHEN 'SKI_ALPINE' THEN 'Ski Alpin'
    -- Für Einträge ohne Disziplin-Kürzel: Cup und Geschlecht enthalten, aber Label soll nur "Ski Alpin" anzeigen
                WHEN 'WC_M'         THEN 'World Cup Männer'
                WHEN 'WC_W'         THEN 'World Cup Frauen'
                WHEN 'FIS_M'        THEN 'FIS Männer'
                WHEN 'FIS_W'        THEN 'FIS Frauen'
                WHEN 'EC_M'         THEN 'Europa Cup Männer'
                WHEN 'EC_W'         THEN 'Europa Cup Frauen'
    -- Riesenslalom (GS)
                WHEN 'WC_GS_M'      THEN 'Riesenslalom'
                WHEN 'WC_GS_W'      THEN 'Riesenslalom'
                WHEN 'FIS_GS_M'     THEN 'Riesenslalom'
                WHEN 'FIS_GS_W'     THEN 'Riesenslalom'
                WHEN 'EC_GS_M'      THEN 'Riesenslalom'
                WHEN 'EC_GS_W'      THEN 'Riesenslalom'
    -- Slalom (SL)
                WHEN 'WC_SL_M'      THEN 'Slalom'
                WHEN 'WC_SL_W'      THEN 'Slalom'
                WHEN 'FIS_SL_M'     THEN 'Slalom'
                WHEN 'FIS_SL_W'     THEN 'Slalom'
                WHEN 'EC_SL_M'      THEN 'Slalom'
                WHEN 'EC_SL_W'      THEN 'Slalom'
    -- Abfahrt (DH)
                WHEN 'WC_DH_M'      THEN 'Abfahrt'
                WHEN 'WC_DH_W'      THEN 'Abfahrt'
                WHEN 'FIS_DH_M'     THEN 'Abfahrt'
                WHEN 'FIS_DH_W'     THEN 'Abfahrt'
                WHEN 'EC_DH_M'      THEN 'Abfahrt'
                WHEN 'EC_DH_W'      THEN 'Abfahrt'
    -- Super G (SG)
                WHEN 'WC_SG_M'      THEN 'Super G'
                WHEN 'WC_SG_W'      THEN 'Super G'
                WHEN 'FIS_SG_M'     THEN 'Super G'
                WHEN 'FIS_SG_W'     THEN 'Super G'
                WHEN 'EC_SG_M'      THEN 'Super G'
                WHEN 'EC_SG_W'      THEN 'Super G'
    -- Alpine Kombination (entspricht AP bzw. in den Kürzeln AC)
                WHEN 'WC_AC_M'      THEN 'Alpine Kombination'
                WHEN 'WC_AC_W'      THEN 'Alpine Kombination'
                WHEN 'FIS_AC_M'     THEN 'Alpine Kombination'
                WHEN 'FIS_AC_W'     THEN 'Alpine Kombination'
                WHEN 'EC_AC_M'      THEN 'Alpine Kombination'
                WHEN 'EC_AC_W'      THEN 'Alpine Kombination'
    -- Team Kombination (TC)
                WHEN 'WC_TC_M'      THEN 'Team Kombination'
                WHEN 'WC_TC_W'      THEN 'Team Kombination'
                WHEN 'FIS_TC_M'     THEN 'Team Kombination'
                WHEN 'FIS_TC_W'     THEN 'Team Kombination'
                WHEN 'EC_TC_M'      THEN 'Team Kombination'
                WHEN 'EC_TC_W'      THEN 'Team Kombination'
                ELSE label
    END
WHERE name IN (
               'SKI_ALPINE',
               'WC_M','WC_W','FIS_M','FIS_W','EC_M','EC_W',
               'WC_GS_M','WC_GS_W','FIS_GS_M','FIS_GS_W','EC_GS_M','EC_GS_W',
               'WC_SL_M','WC_SL_W','FIS_SL_M','FIS_SL_W','EC_SL_M','EC_SL_W',
               'WC_DH_M','WC_DH_W','FIS_DH_M','FIS_DH_W','EC_DH_M','EC_DH_W',
               'WC_SG_M','WC_SG_W','FIS_SG_M','FIS_SG_W','EC_SG_M','EC_SG_W',
               'WC_AC_M','WC_AC_W','FIS_AC_M','FIS_AC_W','EC_AC_M','EC_AC_W',
               'WC_TC_M','WC_TC_W','FIS_TC_M','FIS_TC_W','EC_TC_M','EC_TC_W'
    );