-- For the invoice portal: link the users who log in to tenants.
-- First create two users in Authentication -> Users -> Add user -> Create new user (tick "Auto Confirm User"):
--   demo-acme@example.com / demo-globex@example.com   (choose the passwords yourself; they are not in this repo)
-- If you used other email addresses, change the two places below.
insert into public.memberships (tenant_id, user_id)
select t.id, u.id from public.tenants t
join auth.users u on (t.name = 'Acme Inc.' and u.email = 'demo-acme@example.com')
                  or (t.name = 'Globex Corp.' and u.email = 'demo-globex@example.com')
on conflict do nothing;

-- Check: 2 rows (one person per company)
select t.name as tenant, u.email
from public.memberships m
join public.tenants t on t.id = m.tenant_id
join auth.users u on u.id = m.user_id
where u.email like 'demo-%@example.com' order by t.name;
