CREATE TYPE gender_type AS ENUM ('MAN', 'WOMAN', 'BOTH', 'UNKNOWN');

ALTER TABLE teams_table
    ADD COLUMN gender gender_type DEFAULT 'UNKNOWN' NOT NULL;