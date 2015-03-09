-- Verify categories

BEGIN;

    SELECT id, name, description, status
        FROM wires.categories
    WHERE FALSE;

ROLLBACK;
