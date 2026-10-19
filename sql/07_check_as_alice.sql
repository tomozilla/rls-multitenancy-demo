-- Read as Alice (a person at Acme) (expected: only Acme's 2 invoices)
-- To try Bob, change the email address to bob@example.com (expected: only Globex's 2 invoices)
-- Note: run `rollback;` afterwards.
begin;
select set_config('request.jwt.claims',
  json_build_object('sub', (select id from auth.users where email = 'alice@example.com'),
                    'role', 'authenticated')::text, true);
set local role authenticated;
select t.name as tenant, i.title, i.amount_jpy
from public.invoices i join public.tenants t on t.id = i.tenant_id
order by i.id;
