INSERT INTO SOURCES_TABLE (name) values ('SWISS_SKI');

-- Add all ski sports disciplines
INSERT INTO SPORTS_TABLE (id, name) values (gen_random_uuid(), 'SKI_ALPINE');

DO $$
DECLARE
    ski_alpine_parent_id UUID;
    ec_m_parent_id UUID;
    ec_w_parent_id UUID;
    fis_m_parent_id UUID;
    fis_w_parent_id UUID;
    wc_m_parent_id UUID;
    wc_w_parent_id UUID;
BEGIN

SELECT id INTO ski_alpine_parent_id FROM SPORTS_TABLE WHERE name = 'SKI_ALPINE';

INSERT INTO SPORTS_TABLE (id, name, parent_id)
VALUES
    (gen_random_uuid(), 'WC_M',  ski_alpine_parent_id),
    (gen_random_uuid(), 'WC_W',  ski_alpine_parent_id),
    (gen_random_uuid(), 'FIS_M', ski_alpine_parent_id),
    (gen_random_uuid(), 'FIS_W', ski_alpine_parent_id),
    (gen_random_uuid(), 'EC_M',  ski_alpine_parent_id),
    (gen_random_uuid(), 'EC_W',  ski_alpine_parent_id);

SELECT id INTO wc_m_parent_id FROM SPORTS_TABLE WHERE name = 'WC_M';
SELECT id INTO wc_w_parent_id FROM SPORTS_TABLE WHERE name = 'WC_W';
SELECT id INTO fis_m_parent_id FROM SPORTS_TABLE WHERE name = 'FIS_M';
SELECT id INTO fis_w_parent_id FROM SPORTS_TABLE WHERE name = 'FIS_W';
SELECT id INTO ec_m_parent_id FROM SPORTS_TABLE WHERE name = 'EC_M';
SELECT id INTO ec_w_parent_id FROM SPORTS_TABLE WHERE name = 'EC_W';

INSERT INTO SPORTS_TABLE (id, name, parent_id)
    values
        -- giant slalom
        (gen_random_uuid(),'WC_GS_M', wc_m_parent_id),
        (gen_random_uuid(),'WC_GS_W', wc_w_parent_id),
        (gen_random_uuid(),'FIS_GS_M', fis_m_parent_id),
        (gen_random_uuid(),'FIS_GS_W', fis_w_parent_id),
        (gen_random_uuid(),'EC_GS_M', ec_m_parent_id),
        (gen_random_uuid(),'EC_GS_W', ec_w_parent_id),

        -- slalom
        (gen_random_uuid(),'WC_SL_M', wc_m_parent_id),
        (gen_random_uuid(),'WC_SL_W', wc_w_parent_id),
        (gen_random_uuid(),'FIS_SL_M', fis_m_parent_id),
        (gen_random_uuid(),'FIS_SL_W', fis_w_parent_id),
        (gen_random_uuid(),'EC_SL_M', ec_m_parent_id),
        (gen_random_uuid(),'EC_SL_W', ec_w_parent_id),

        -- downhill
        (gen_random_uuid(),'WC_DH_M', wc_m_parent_id),
        (gen_random_uuid(),'WC_DH_W', wc_w_parent_id),
        (gen_random_uuid(),'FIS_DH_M', fis_m_parent_id),
        (gen_random_uuid(),'FIS_DH_W', fis_w_parent_id),
        (gen_random_uuid(),'EC_DH_M', ec_m_parent_id),
        (gen_random_uuid(),'EC_DH_W', ec_w_parent_id),

        -- super g
        (gen_random_uuid(),'WC_SG_M', wc_m_parent_id),
        (gen_random_uuid(),'WC_SG_W', wc_w_parent_id),
        (gen_random_uuid(),'FIS_SG_M', fis_m_parent_id),
        (gen_random_uuid(),'FIS_SG_W', fis_w_parent_id),
        (gen_random_uuid(),'EC_SG_M', ec_m_parent_id),
        (gen_random_uuid(),'EC_SG_W', ec_w_parent_id),

        -- alpine comb
        (gen_random_uuid(),'WC_AC_M', wc_m_parent_id),
        (gen_random_uuid(),'WC_AC_W', wc_w_parent_id),
        (gen_random_uuid(),'FIS_AC_M', fis_m_parent_id),
        (gen_random_uuid(),'FIS_AC_W', fis_w_parent_id),
        (gen_random_uuid(),'EC_AC_M', ec_m_parent_id),
        (gen_random_uuid(),'EC_AC_W', ec_w_parent_id),

        -- team comb
        (gen_random_uuid(),'WC_TC_M', wc_m_parent_id),
        (gen_random_uuid(),'WC_TC_W', wc_w_parent_id),
        (gen_random_uuid(),'FIS_TC_M', fis_m_parent_id),
        (gen_random_uuid(),'FIS_TC_W', fis_w_parent_id),
        (gen_random_uuid(),'EC_TC_M', ec_m_parent_id),
        (gen_random_uuid(),'EC_TC_W', ec_w_parent_id);
END
$$;
