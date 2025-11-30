-- Rollback of V3_2__insert_ski_sports.sql
-- This migration removes all ski sports and the SWISS_SKI source that were added in V3_2
-- They will be replaced by the simpler structure in V3_32__insert_ski_sports.sql

-- IMPORTANT: Delete events FIRST before deleting sports
-- (sport_id is NOT NULL, so CASCADE SET NULL would fail)
DELETE FROM EVENTS_TABLE
WHERE sport_id IN (
    SELECT id FROM SPORTS_TABLE WHERE name IN (
        -- World Cup disciplines
        'WC_GS_M', 'WC_GS_W',  -- Giant Slalom
        'WC_SL_M', 'WC_SL_W',  -- Slalom
        'WC_DH_M', 'WC_DH_W',  -- Downhill
        'WC_SG_M', 'WC_SG_W',  -- Super G
        'WC_AC_M', 'WC_AC_W',  -- Alpine Combined
        'WC_TC_M', 'WC_TC_W',  -- Team Combined

        -- FIS disciplines
        'FIS_GS_M', 'FIS_GS_W',
        'FIS_SL_M', 'FIS_SL_W',
        'FIS_DH_M', 'FIS_DH_W',
        'FIS_SG_M', 'FIS_SG_W',
        'FIS_AC_M', 'FIS_AC_W',
        'FIS_TC_M', 'FIS_TC_W',

        -- Europa Cup disciplines
        'EC_GS_M', 'EC_GS_W',
        'EC_SL_M', 'EC_SL_W',
        'EC_DH_M', 'EC_DH_W',
        'EC_SG_M', 'EC_SG_W',
        'EC_AC_M', 'EC_AC_W',
        'EC_TC_M', 'EC_TC_W',

        -- Categories
        'WC_M', 'WC_W',
        'FIS_M', 'FIS_W',
        'EC_M', 'EC_W',

        -- Top level
        'SKI_ALPINE'
    )
);

-- Delete all leaf sports (discipline level) - bottom of hierarchy
DELETE FROM SPORTS_TABLE WHERE name IN (
    -- World Cup disciplines
    'WC_GS_M', 'WC_GS_W',  -- Giant Slalom
    'WC_SL_M', 'WC_SL_W',  -- Slalom
    'WC_DH_M', 'WC_DH_W',  -- Downhill
    'WC_SG_M', 'WC_SG_W',  -- Super G
    'WC_AC_M', 'WC_AC_W',  -- Alpine Combined
    'WC_TC_M', 'WC_TC_W',  -- Team Combined

    -- FIS disciplines
    'FIS_GS_M', 'FIS_GS_W',
    'FIS_SL_M', 'FIS_SL_W',
    'FIS_DH_M', 'FIS_DH_W',
    'FIS_SG_M', 'FIS_SG_W',
    'FIS_AC_M', 'FIS_AC_W',
    'FIS_TC_M', 'FIS_TC_W',

    -- Europa Cup disciplines
    'EC_GS_M', 'EC_GS_W',
    'EC_SL_M', 'EC_SL_W',
    'EC_DH_M', 'EC_DH_W',
    'EC_SG_M', 'EC_SG_W',
    'EC_AC_M', 'EC_AC_W',
    'EC_TC_M', 'EC_TC_W'
);

-- Delete middle level sports (categories)
DELETE FROM SPORTS_TABLE WHERE name IN (
    'WC_M', 'WC_W',
    'FIS_M', 'FIS_W',
    'EC_M', 'EC_W'
);

-- Delete top level sport
DELETE FROM SPORTS_TABLE WHERE name = 'SKI_ALPINE';

-- Delete the SWISS_SKI source
DELETE FROM SOURCES_TABLE WHERE name = 'SWISS_SKI';