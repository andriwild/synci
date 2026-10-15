-- Organisations: clubs with admins/members whose structure reuses the sport tree.
-- An organisation is a root row in sports_table (organisation_id set, parent_id NULL, name 'ORG_<uuid>'),
-- its groups are child rows (name 'GRP_<uuid>'); the display name lives in label.
-- Organisation events live in events_table with their own source so the external sync jobs never touch them.
--
-- Version 4.0 is chosen deliberately: the dev branch ends at V3_28 while main already has V3_29..V3_36.
-- When main is merged into dev, enable spring.flyway.out-of-order once so the V3_29..V3_36 migrations
-- can still be applied below this one.

CREATE TYPE org_role AS ENUM ('ADMIN', 'MEMBER');
CREATE TYPE org_member_status AS ENUM ('PENDING', 'ACTIVE');

CREATE TABLE organisations_table (
    id          uuid PRIMARY KEY,
    name        varchar(100) NOT NULL,
    description text,
    created_by  uuid REFERENCES users_table(id) ON DELETE SET NULL,
    created_at  timestamp NOT NULL DEFAULT now()
);

CREATE TABLE organisation_members_table (
    id              uuid PRIMARY KEY,
    organisation_id uuid NOT NULL REFERENCES organisations_table(id) ON DELETE CASCADE,
    user_id         uuid NOT NULL REFERENCES users_table(id) ON DELETE CASCADE,
    role            org_role NOT NULL DEFAULT 'MEMBER',
    status          org_member_status NOT NULL DEFAULT 'PENDING',
    created_at      timestamp NOT NULL DEFAULT now(),
    CONSTRAINT uq_org_member UNIQUE (organisation_id, user_id)
);
CREATE INDEX ix_org_members_user ON organisation_members_table (user_id);

-- organisations and their groups are part of the sport tree
ALTER TABLE sports_table
    ADD COLUMN organisation_id uuid REFERENCES organisations_table(id) ON DELETE CASCADE;
CREATE INDEX ix_sports_organisation ON sports_table (organisation_id);

-- organisation events are regular events with their own source
INSERT INTO sources_table (name) VALUES ('ORGANISATION');
ALTER TABLE events_table ADD COLUMN location varchar(255);
ALTER TABLE events_table ADD COLUMN description text;
