create type gender as enum ('MALE','FEMALE','OTHER');
create type user_role as enum ('USER','ADMIN');

create table users (
  id bigserial primary key,
  first_name varchar(60) not null,
  last_name varchar(60) not null,
  email varchar(255) not null unique,
  password_hash varchar(255) not null,
  gender gender,
  age int,
  weight_kg numeric(5,2),
  height_cm numeric(5,2),
  wake_time time,
  sleep_time time,
  roles user_role[] default array['USER']::user_role[],
  reset_token varchar(120),
  reset_token_expiry timestamp,
  created_at timestamp default now(),
  updated_at timestamp default now()
);

create table daily_goal (
  id bigserial primary key,
  user_id bigint not null references users(id) on delete cascade,
  target_ml int not null,
  reminders_enabled boolean default false,
  reminder_every_min int default 60
);

create table water_log (
  id bigserial primary key,
  user_id bigint not null references users(id) on delete cascade,
  amount_ml int not null,
  note varchar(255),
  logged_at timestamp not null default now()
);

create index idx_waterlog_user_time on water_log(user_id, logged_at);
