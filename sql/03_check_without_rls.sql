-- BEFORE enabling RLS: can someone who is not logged in (anon) read every company's invoices?
-- Note: after begin; and running this, run `rollback;` to close the transaction.
begin;
set local role anon;
select t.name as tenant, i.title, i.amount_jpy
from public.invoices i join public.tenants t on t.id = i.tenant_id
order by i.id;
