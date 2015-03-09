-- Verify sources

BEGIN;

    SELECT id, name, description, category -- Could add more
      FROM wires.sources
     WHERE FALSE;

ROLLBACK;
