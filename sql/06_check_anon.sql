-- How many invoices can someone who is not logged in (anon) see? (expected: 0)
-- Note: run `rollback;` afterwards.
begin;
set local role anon;
select count(*) as visible_invoices from public.invoices;
