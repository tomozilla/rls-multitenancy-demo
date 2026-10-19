-- AliceがGlobex（他社）の請求書を追加しようとすると、どうなる？（期待: エラー 42501）
-- ※ 実行後に `rollback;` を実行してください
--
-- 注意（私が勘違いしたところ）: 次のような「insert ... select」だと、Aliceには他社の行が見えないので、
-- selectが0行になり、エラーにならずに「0行を追加」して成功してしまいます。
--   insert into public.invoices (tenant_id, title, amount_jpy)
--   select id, 'Sneaky invoice', 1 from public.tenants where name = 'Globex Corp.';
-- ポリシーを確かめるときは、他社のidを明示して追加します。
begin;
select set_config('app.globex_id',
  (select id::text from public.tenants where name = 'Globex Corp.'), true);
select set_config('request.jwt.claims',
  json_build_object('sub', (select id from auth.users where email = 'alice@example.com'),
                    'role', 'authenticated')::text, true);
set local role authenticated;
insert into public.invoices (tenant_id, title, amount_jpy)
values (current_setting('app.globex_id')::uuid, 'Sneaky invoice', 1);
