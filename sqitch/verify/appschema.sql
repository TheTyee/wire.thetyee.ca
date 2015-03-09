-- Verify appschema

BEGIN;

SELECT pg_catalog.has_schema_privilege('wires', 'usage');

ROLLBACK;

