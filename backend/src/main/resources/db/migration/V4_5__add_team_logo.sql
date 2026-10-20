-- Team logos; SwissTXT logos are addressed by the team id on the SwissTXT CDN
ALTER TABLE TEAMS_TABLE ADD COLUMN logo_url VARCHAR(500);

UPDATE TEAMS_TABLE
SET logo_url = 'https://cdn-csd.swisstxt.ch/images/sport/club/logo/medium/' || id || '.png'
WHERE source_id = (SELECT id FROM SOURCES_TABLE WHERE name = 'SWISSTXT');
