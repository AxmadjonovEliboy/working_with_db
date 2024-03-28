CREATE TABLE "auth_user"
(
    "id"          serial PRIMARY KEY,
    "full_name"   varchar not null,
    "bio"         varchar,
    "information" varchar,
    "email"       varchar unique,
    "image_id"    integer,
    "role_id"     integer references role (id),
    "created_at"  timestamp default now(),
    "updated_at"  timestamp default now(),
    "updated_by"  integer
);

drop table role;
CREATE TABLE "role"
(
    "id"   serial PRIMARY KEY,
    "name" varchar,
    "code" varchar
);

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

CREATE TABLE "like_count"
(
    "id"              serial PRIMARY KEY,
    "article_id"      integer references article (id),
    "clicked_user_id" integer references auth_user (id)
);

CREATE TABLE "comment"
(
    "id"         serial PRIMARY KEY,
    "article_id" integer references article (id),
    "message_id" integer references message (id),
    "sent_at"    timestamp
);

CREATE TABLE "message"
(
    "id"        serial PRIMARY KEY,
    "content"   text not null,
    "create_by" integer references auth_user (id),
    "create_at" timestamp,
    "update_at" timestamp
);


CREATE TABLE "saved_article"
(
    "id"         serial PRIMARY KEY,
    "owner_id"   integer references auth_user (id),
    "article_id" integer references article (id)
);

CREATE TABLE "user_interested"
(
    "id"          serial PRIMARY KEY,
    "category_id" integer references article_category (id),
    "user_id"     integer references auth_user (id)
);

create table test (
    id integer primary key ,
    name varchar
)

