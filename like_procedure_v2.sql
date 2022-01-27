CREATE OR REPLACE FUNCTION public.like_procedure_v2(s_post_id integer, s_user_id integer)
 RETURNS TABLE(is_success boolean, send_push boolean)
 LANGUAGE plpgsql
AS $function$
DECLARE
    post_user_id bigint;
    post_kafe_id integer;
    send_push boolean = false;
    is_success boolean = false;

BEGIN

    IF not EXISTS(select 1 from likes where post_id = s_post_id and user_id = s_user_id)
    THEN
        select user_id, kafe_id into post_user_id, post_kafe_id from posts where id = s_post_id;
        IF NOT EXISTS(select 1 from posts where id = s_post_id and is_deleted = true)
        THEN
            IF NOT EXISTS(select 1
                          from blocks
                          where (user_id = post_user_id and block_id = s_user_id)
                             OR (user_id = s_user_id and block_id = post_user_id))
            THEN
                IF EXISTS(select 1 from follows where user_id = s_user_id and follow_id = post_user_id and is_pending = false)
                    or EXISTS(select 1 from users where id = post_user_id and is_private = false)
                    or (s_user_id=post_user_id)
                    or (post_kafe_id != 0)
                THEN
                    insert into likes (user_id, post_id, created_at, updated_at)
                    values (s_user_id, s_post_id, now(), now())
                    ON CONFLICT (user_id, post_id) DO NOTHING;
                    UPDATE posts SET like_count = like_count + 1 WHERE id = s_post_id;
                    UPDATE users SET like_count = like_count + 1 WHERE id = s_user_id;
                    select get_push_relation_function(s_user_id, post_user_id, 'post_likes') into send_push;
                    is_success=true;
                    return query (select is_success,send_push) ;

                else
                    return query (select is_success,send_push) ;
                end if;
            else
                  return query (select is_success,send_push) ;
            end if;
        else
             return query (select is_success,send_push) ;
        end if;
    else
        return query (select is_success,send_push) ;
    end if;
END;
$function$

