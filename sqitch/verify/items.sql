-- Verify items

BEGIN;

    SELECT id, url, title, description, content, author, image, pubdate, source_id, count_tw, count_fb, count_su, count_li, count_go
        FROM wire.items
    WHERE FALSE;

ROLLBACK;
