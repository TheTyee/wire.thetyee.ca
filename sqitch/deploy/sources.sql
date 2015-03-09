-- Deploy sources
-- requires: appschema
-- requires: categories

BEGIN;

    CREATE TABLE wires.sources (
        id              SERIAL  UNIQUE PRIMARY KEY,
        url             TEXT    NOT NULL UNIQUE,
        name            TEXT    NOT NULL, 
        description     TEXT    NULL,
        image           TEXT    NULL,
        category        TEXT REFERENCES wires.categories (id),
        contact_name    TEXT    NULL,
        contact_email   TEXT    NULL,
        status          TEXT    NULL,
        source_updated  TIMESTAMP without time zone default (now() at time zone 'utc') NOT NULL,
        feed_url        TEXT        NULL,
        feed_updated    TIMESTAMP   NULL
    );

COMMIT;
