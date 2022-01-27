CREATE OR REPLACE FUNCTION public.dislike_post_procedure(s_post_id integer, s_user_id integer)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
DECLARE
    post_user_id bigint;
    post_kafe_id integer;
BEGIN
    select user_id, kafe_id into post_user_id, post_kafe_id from posts where id = s_post_id;
    IF NOT EXISTS(Select 1 from dislikes where post_id = s_post_id and user_id = s_user_id)
    THEN
        IF EXISTS(select 1 from follows where user_id = s_user_id and follow_id = post_user_id and is_pending = false)
            or EXISTS(select 1 from users where id = post_user_id and is_private = false)
            or (s_user_id = post_user_id)
            or (post_kafe_id != 0)
        THEN
            IF NOT EXISTS(select 1
                          from blocks
                          where (user_id = post_user_id and block_id = s_user_id)
                             OR (user_id = s_user_id and block_id = post_user_id))
            THEN
                INSERT INTO dislikes (user_id,
                                      post_id)
                VALUES (s_user_id,
                        s_post_id);

                UPDATE posts
                SET dislike_count = dislike_count + 1
                WHERE id = s_post_id;
                RETURN true;
            else
                RETURN false;
            END IF;
        else
            RETURN false;
        END IF;
    else
        RETURN false;
    END IF;
END;
$function$

