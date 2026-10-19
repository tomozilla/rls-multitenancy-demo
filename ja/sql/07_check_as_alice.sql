-- Alice（Acmeの人）になりきって読む（期待: Acmeの2件だけ）
-- Bobで試すには、メールアドレスを bob@example.com に変えます（期待: Globexの2件だけ）
-- ※ 実行後に `rollback;` を実行してください
begin;
select set_config('request.jwt.claims',
  json_build_object('sub', (select id from auth.users where email = 'alice@example.com'),
                    'role', 'authenticated')::text, true);
set local role authenticated;
select t.name as tenant, i.title, i.amount_jpy
from public.invoices i join public.tenants t on t.id = i.tenant_id
order by i.id;
