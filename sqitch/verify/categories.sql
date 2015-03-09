-- Verify categories

BEGIN;

    SELECT id, name, description, status
        FROM wire.categories
    WHERE FALSE;

ROLLBACK;
