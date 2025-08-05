INSERT INTO SOURCES_TABLE (name) values ('FORMULA_ONE');

-- Motorsport als Oberkategorie
INSERT INTO SPORTS_TABLE (id, name, label)
VALUES (gen_random_uuid(), 'MOTORSPORT', 'Motorsport');

-- Formel 1 unter Motorsport
DO $$
DECLARE
motorsport_id UUID;
BEGIN
SELECT id INTO motorsport_id FROM SPORTS_TABLE WHERE name = 'MOTORSPORT';

INSERT INTO SPORTS_TABLE (id, name, label, parent_id)
VALUES (gen_random_uuid(), 'FORMULA_ONE', 'Formel 1', motorsport_id);
END
$$;