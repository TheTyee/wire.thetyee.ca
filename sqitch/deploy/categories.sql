-- Deploy categories
-- requires: appschema

BEGIN;

    CREATE TABLE wire.categories (
        id          TEXT UNIQUE PRIMARY KEY,
        name        TEXT NOT NULL,
        description TEXT NULL,
        status      TEXT DEFAULT 'active'
    );

COMMIT;
