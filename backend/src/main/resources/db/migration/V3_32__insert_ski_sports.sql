-- Add all ski sports disciplines
INSERT INTO SPORTS_TABLE (id, name, label) values (gen_random_uuid(), 'SKI_ALPINE', 'Ski Alpin');

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
    (gen_random_uuid(), 'WC_W',  ski_alpine_parent_id, 'World Cup Frauen');

SELECT id INTO wc_m_parent_id FROM SPORTS_TABLE WHERE name = 'WC_M';
SELECT id INTO wc_w_parent_id FROM SPORTS_TABLE WHERE name = 'WC_W';

END
$$;
