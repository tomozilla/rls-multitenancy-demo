-- Dummy data. First create these two users in Authentication -> Users (tick "Auto Confirm User"):
--   alice@example.com / bob@example.com   (choose the passwords yourself; they are not in this repo)
insert into public.tenants (name) values ('Acme Inc.'), ('Globex Corp.');

insert into public.memberships (tenant_id, user_id)
select t.id, u.id from public.tenants t
join auth.users u on (t.name = 'Acme Inc.' and u.email = 'alice@example.com')
                  or (t.name = 'Globex Corp.' and u.email = 'bob@example.com');

insert into public.invoices (tenant_id, title, amount_jpy)
select t.id, v.title, v.amount from public.tenants t
join (values
  ('Acme Inc.', 'Website renewal', 120000),
  ('Acme Inc.', 'Support plan', 30000),
  ('Globex Corp.', 'Data migration', 450000),
  ('Globex Corp.', 'Training workshop', 80000)
) as v(tname, title, amount) on v.tname = t.name;
