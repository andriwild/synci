CREATE TABLE public.users_table
(
    id         UUID PRIMARY KEY,
    auth0_id   TEXT NOT NULL UNIQUE,
    email      TEXT,
    name       TEXT,
    created_at TIMESTAMP DEFAULT now()
);
