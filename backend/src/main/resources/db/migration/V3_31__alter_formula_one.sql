-- Add WM (Weltmeisterschaft) under existing FORMULA_ONE sport
-- This extends the Formula One structure from V3_14__formula_one.sql

-- Add WM as child of FORMULA_ONE
DO $$
DECLARE
    formula_one_id UUID;
BEGIN
    -- Get existing FORMULA_ONE ID
    SELECT id INTO formula_one_id FROM SPORTS_TABLE WHERE name = 'FORMULA_ONE';

    -- Only insert WM if FORMULA_ONE exists
    IF formula_one_id IS NOT NULL THEN
        INSERT INTO SPORTS_TABLE (id, name, label, parent_id)
        VALUES (gen_random_uuid(), 'WM', 'Weltmeisterschaft', formula_one_id);
    END IF;
END
$$;