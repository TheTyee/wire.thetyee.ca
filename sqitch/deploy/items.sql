-- Deploy items
-- requires: appschema
-- requires: feeds

BEGIN;

    CREATE TABLE wires.items (
        id          SERIAL UNIQUE PRIMARY KEY,
        url         TEXT UNIQUE NOT NULL,
        title       TEXT NOT NULL,
        description TEXT NULL,
        content     TEXT NULL,
        author      TEXT NULL,
        image       TEXT NULL,
        pubdate     TIMESTAMP NOT NULL,
        count_tw    INT NOT NULL DEFAULT 0,
        count_su    INT NOT NULL DEFAULT 0,
        count_fb    INT NOT NULL DEFAULT 0,
        count_li    INT NOT NULL DEFAULT 0,
        count_go    INT NOT NULL DEFAULT 0,
        source_id     integer REFERENCES wires.sources (id) ON DELETE CASCADE
    );

COMMIT;
