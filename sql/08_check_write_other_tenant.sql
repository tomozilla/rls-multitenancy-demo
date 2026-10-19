-- What happens when Alice tries to add an invoice for Globex (another company)? (expected: error 42501)
-- Note: run `rollback;` afterwards.
--
-- Careful (where I got it wrong): with an "insert ... select" like the one below, Alice cannot see the
-- other company's rows, so the select returns 0 rows and the insert "succeeds" by adding 0 rows, with no error.
--   insert into public.invoices (tenant_id, title, amount_jpy)
--   select id, 'Sneaky invoice', 1 from public.tenants where name = 'Globex Corp.';
-- To test the policy, insert with the other company's id written out explicitly.
begin;
select set_config('app.globex_id',
  (select id::text from public.tenants where name = 'Globex Corp.'), true);
select set_config('request.jwt.claims',
  json_build_object('sub', (select id from auth.users where email = 'alice@example.com'),
                    'role', 'authenticated')::text, true);
set local role authenticated;
insert into public.invoices (tenant_id, title, amount_jpy)
values (current_setting('app.globex_id')::uuid, 'Sneaky invoice', 1);
