-- extension for uuid generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

ALTER TABLE SPORTS_TABLE ADD CONSTRAINT unique_constraint_name UNIQUE (name);
