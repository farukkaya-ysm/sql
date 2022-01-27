CREATE OR REPLACE FUNCTION public.f123(id integer)
 RETURNS integer
 LANGUAGE plpgsql
 STRICT
AS $function$
declare
begin
return id+3;
end;
$function$

