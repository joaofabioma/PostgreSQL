DO $$
DECLARE
    rec RECORD;
    max_id BIGINT;
    next_val BIGINT;
BEGIN
    FOR rec IN
        SELECT
            n.nspname AS schema_name, c.relname AS table_name, a.attname AS column_name, s.relname AS sequence_name, nseq.nspname AS sequence_schema
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        JOIN pg_attribute a ON a.attrelid = c.oid
        JOIN pg_depend d ON d.refobjid = c.oid AND d.refobjsubid = a.attnum
        JOIN pg_class s ON s.oid = d.objid
        JOIN pg_namespace nseq ON nseq.oid = s.relnamespace
        WHERE d.deptype = 'a' AND c.relkind = 'r' AND a.attnum > 0 AND s.relkind = 'S'
        -- AND n.nspname = 'public' // Todos os schemas
    LOOP
        EXECUTE format('SELECT COALESCE(MAX(%I), 0) FROM %I.%I', rec.column_name, rec.schema_name, rec.table_name) INTO max_id;
        EXECUTE format('SELECT last_value FROM %I.%I',  rec.sequence_schema, rec.sequence_name) INTO next_val;

        IF next_val <= max_id THEN
            EXECUTE format('SELECT setval(%L, %s, true)', rec.sequence_schema || '.' || rec.sequence_name, max_id + 1);
            RAISE NOTICE 'Corrigida sequence: %.% (Tabela: %.%.%) - Novo valor: %',
                        rec.sequence_schema, rec.sequence_name, rec.schema_name, rec.table_name, rec.column_name, max_id + 1;
        END IF;
    END LOOP;
END $$;
