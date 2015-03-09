-- Verify sources

BEGIN;

    SELECT id, name, description, category -- Could add more
      FROM wire.sources
     WHERE FALSE;

ROLLBACK;
