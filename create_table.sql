--------------------------------------------------------------------------------------------------------------------
------------ Create Tables -----------------------------------------------------------------------------------------

CREATE TABLE "auth_user"
(
    "id"          serial PRIMARY KEY,
    "full_name"   varchar                                         not null,
    "bio"         varchar,
    "information" varchar,
    "email"       varchar unique,
    "image_id"    integer,
    "role"        utils.user_role default 'USER'::utils.user_role not null,
    "created_at"  timestamp       default now(),
    "updated_at"  timestamp       default now(),
    "updated_by"  integer
);

drop table auth_user;

drop table followers;
CREATE TABLE "followers"
(
    "id"          serial PRIMARY KEY,
    "owner_id"    integer references auth_user (id),
    "follower_id" integer references auth_user (id)
);

drop table article_category;
CREATE TABLE "article_category"
(
    "id"          serial PRIMARY KEY,
    "name"        varchar not null,
    "description" varchar
);

drop table article;
CREATE TABLE "article"
(
    "id"          serial PRIMARY KEY,
    "title"       varchar not null,
    "body"        text,
    "category_id" integer references article_category (id),
    "created_by"  integer references auth_user (id),
    "created_at"  timestamp,
    "updated_at"  timestamp
);

drop table like_count;
CREATE TABLE "like_count"
(
    "id"              serial PRIMARY KEY,
    "article_id"      integer references article (id),
    "clicked_user_id" integer references auth_user (id)
);

drop table comment;
CREATE TABLE "comment"
(
    "id"         serial PRIMARY KEY,
    "article_id" integer references article (id),
    "message_id" integer references message (id),
    "sent_at"    timestamp
);

drop table message;
CREATE TABLE "message"
(
    "id"        serial PRIMARY KEY,
    "content"   text not null,
    "create_by" integer references auth_user (id),
    "create_at" timestamp,
    "update_at" timestamp
);


drop table saved_article;
CREATE TABLE "saved_article"
(
    "id"         serial PRIMARY KEY,
    "owner_id"   integer references auth_user (id),
    "article_id" integer references article (id)
);

drop table user_interested;
CREATE TABLE "user_interested"
(
    "id"          serial PRIMARY KEY,
    "category_id" integer references article_category (id),
    "user_id"     integer references auth_user (id)
);

create table test
(
    id   integer primary key,
    name varchar
);

drop table test;
------------------------------------------------------------------------------------------------------------------------
----------------- Create schema  ---------------------------------------------------------------------------------------

create schema utils;
create schema mapper;
create schema helper;
create schema crud;


------------------------------------------------------------------------------------------------------------------------
-----------------  Function for utils ----------------------------------------------------------------------------------
create extension if not exists pgcrypto with schema utils;

------------------------------------------------------------------------------------------------------------------------
-----------------  Create DTO ------------------------------------------------------------------------------------------

create type public.auth_user_register_dto as
(
    full_name varchar,
    email     varchar
);

create type public.auth_user_update_dto as
(
    full_name   varchar,
    bio         varchar,
    information varchar,
    image_id    integer
);


create type utils.user_role as ENUM (
    'ADMIN',
    'USER',
    'SUPER_ADMIN'
    );


------------------------------------------------------------------------------------------------------------------------
--------------  Mapper part --------------------------------------------------------------------------------------------

create function mapper.from_user_register_dto(json_data json) returns public.auth_user_register_dto
    language plpgsql
as
$$
DECLARE
    data public.auth_user_register_dto;
BEGIN
    data.email := json_data ->> 'email';
    data.full_name := json_data ->> 'full_name';
    return data;
END
$$;

------------------------------------------------------------------------------------------------------------------------
--------- Helper data --------------------------------------------------------------------------------------------------

create procedure helper.check_data_param(IN data_param text)
    language plpgsql
as
$$
BEGIN
    if data_param is null or data_param = '{}'::text then
        raise exception 'Data param is invalid!';
    end if;
END
$$;


create function helper.check_email(u_email character varying) returns boolean
    language plpgsql
as
$$
DECLARE
    pattern varchar := '^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-]+)(\.[a-zA-Z]{2,5}){1,2}$';
BEGIN
    if u_email is null or trim(u_email) ilike '' then
        raise exception 'Email can not be null or empty' using hint = 'check email';
    end if;
    return u_email ~* pattern;
END
$$;

select helper.check_email('elic@gmail.fu');

------------------------------------------------------------------------------------------------------------------------
----------------- belongs to users -------------------------------------------------------------------------------------

create function crud.auth_user_register(data_param text)
    returns integer
    language plpgsql as
$$
declare
    result int;
    dto    public.auth_user_register_dto;
    info   bool;
begin

    call helper.check_data_param(data_param);

    dto := mapper.from_user_register_dto(data_param::json);

    info = helper.check_email(dto.email);

    if exists(select * from public.auth_user a where a.email ilike dto.email) then
        raise exception 'the email : % already exist!',dto.email;
    end if;

    insert into public.auth_user (full_name, bio, information, email, image_id, role, updated_by)
    values (dto.full_name,
            null,
            null,
            dto.email,
            null,
            'USER'::utils.user_role,
            -1)
    returning id into result;

    return result;
end
$$;

select crud.get_user_id(1);

create function crud.get_user_id(i_user_id bigint default null::bigint) returns text
    language plpgsql
as
$$
BEGIN
    return ((select (json_build_object(
            'id', t.id,
            'full_name', t.full_name,
            'email', t.email,
            'bio', t.bio,
            'information', t.information,
            'role', t.role,
            'image_id', t.image_id,
            'create_at', t.created_at
        ))
             from public.auth_user t
             where t.id = i_user_id)::text);
END
$$;

select crud.get_all_users();

create function crud.get_all_users() returns text
    language plpgsql
as
$$
BEGIN
    return coalesce((select json_agg(crud.get_user_id(t.id)::jsonb)
                     from public.auth_user t)::text, '[]');
END
$$;


create function crud.update_auth_user(data_params text, session_user_id bigint) returns boolean
    language plpgsql
as
$$
DECLARE
    t_user record;
    dto    public.auth_user_update_dto;
BEGIN

END
$$;


------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

select crud.test();



-----------------------------------------------------------------------------------------------------------------
------------ Select part ----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

select crud.auth_user_register('{' ||
                               '"full_name":"Jarvis Elic",' ||
                               '"email":"elic@gmail.com"' ||
                               '}');

select crud.get_all_users();

select crud.get_user_id(1);
