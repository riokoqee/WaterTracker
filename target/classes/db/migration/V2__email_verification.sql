alter table users
  add column if not exists email_verified boolean default false,
  add column if not exists verification_code varchar(20),
  add column if not exists verification_code_expiry timestamp;

