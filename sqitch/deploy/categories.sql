-- Deploy categories
-- requires: appschema

BEGIN;

    CREATE TABLE wires.categories (
        id          TEXT UNIQUE PRIMARY KEY,
        name        TEXT NOT NULL,
        description TEXT NULL,
        status      TEXT NULL
    );

COMMIT;