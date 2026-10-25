-- Organisation events can ask their members to answer yes or no.
-- A member has one answer per event and can change it; it goes when the event or the user is deleted.
-- Answers of former members stay but are only counted while the user is an active member.

ALTER TABLE events_table ADD COLUMN response_requested boolean NOT NULL DEFAULT false;

CREATE TYPE event_answer AS ENUM ('YES', 'NO');

CREATE TABLE organisation_event_responses_table (
    event_id   varchar(255) NOT NULL,
    source_id  integer      NOT NULL,
    user_id    uuid         NOT NULL REFERENCES users_table(id) ON DELETE CASCADE,
    answer     event_answer NOT NULL,
    updated_at timestamp    NOT NULL DEFAULT now(),
    PRIMARY KEY (event_id, source_id, user_id),
    FOREIGN KEY (event_id, source_id) REFERENCES events_table(id, source_id) ON DELETE CASCADE
);
CREATE INDEX ix_event_responses_user ON organisation_event_responses_table (user_id);
