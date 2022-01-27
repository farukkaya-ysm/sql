CREATE OR REPLACE FUNCTION public.push_to_history_table_func()
 RETURNS event_trigger
 LANGUAGE plpgsql
 STRICT
AS $function$
declare
  r record;
begin
  for r in SELECT * FROM pg_event_trigger_ddl_commands() LOOP
    insert into func_history(tx, objid, object_type, schema_name, object_name, object_identity, in_extension, create_time, content)
      values
       (
          txid_current(),
          r.objid,
          r.object_type,
          r.schema_name,
          (SELECT proname FROM pg_proc WHERE oid = r.objid),
          r.object_identity,
          r.in_extension,
          now(),
          pg_get_functiondef(r.objid)
    );
  end LOOP;
end;
$function$

