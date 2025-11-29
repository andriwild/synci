-- Add all ski sports disciplines
INSERT INTO SPORTS_TABLE (id, name) values (gen_random_uuid(), 'SKI_ALPINE');

DO $$
DECLARE
    ski_alpine_parent_id UUID;
    wc_m_parent_id UUID;
    wc_w_parent_id UUID;
BEGIN

SELECT id INTO ski_alpine_parent_id FROM SPORTS_TABLE WHERE name = 'SKI_ALPINE';

INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
VALUES
    (gen_random_uuid(), 'WC_M',  ski_alpine_parent_id, 'World Cup Männer'),
    (gen_random_uuid(), 'WC_W',  ski_alpine_parent_id, 'World Cup Frauen'),;

SELECT id INTO wc_m_parent_id FROM SPORTS_TABLE WHERE name = 'WC_M';
SELECT id INTO wc_w_parent_id FROM SPORTS_TABLE WHERE name = 'WC_W';

INSERT INTO SPORTS_TABLE (id, name, parent_id, label)
VALUES
    -- giant slalom
    (gen_random_uuid(),'WC_GS_M', wc_m_parent_id, 'Riesenslalom'),
    (gen_random_uuid(),'WC_GS_W', wc_w_parent_id, 'Riesenslalom'),

    -- slalom
    (gen_random_uuid(),'WC_SL_M', wc_m_parent_id, 'Slalom'),
    (gen_random_uuid(),'WC_SL_W', wc_w_parent_id, 'Slalom'),

    -- downhill
    (gen_random_uuid(),'WC_DH_M', wc_m_parent_id, 'Abfahrt'),
    (gen_random_uuid(),'WC_DH_W', wc_w_parent_id, 'Abfahrt'),

    -- super g
    (gen_random_uuid(),'WC_SG_M', wc_m_parent_id, 'Super G'),
    (gen_random_uuid(),'WC_SG_W', wc_w_parent_id, 'Super G'),

    -- alpine comb
    (gen_random_uuid(),'WC_AC_M', wc_m_parent_id, 'Alpine Kombination'),
    (gen_random_uuid(),'WC_AC_W', wc_w_parent_id, 'Alpine Kombination'),

    -- team comb
    (gen_random_uuid(),'WC_TC_M', wc_m_parent_id, 'Team Kombination'),
    (gen_random_uuid(),'WC_TC_W', wc_w_parent_id, 'Team Kombination');
END
$$;
