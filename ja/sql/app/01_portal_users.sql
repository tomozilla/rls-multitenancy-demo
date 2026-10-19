-- 請求書ポータル用: ログインするユーザーを、取引先に結びつける
-- 先に、Authentication → Users → Add user → Create new user で、2人作っておきます（Auto Confirm User にチェック）。
--   demo-acme@example.com / demo-globex@example.com   （パスワードは自分で決める。このリポジトリには書きません）
-- 別のメールアドレスにしたときは、下の2か所を書き換えてください。
insert into public.memberships (tenant_id, user_id)
select t.id, u.id from public.tenants t
join auth.users u on (t.name = 'Acme Inc.' and u.email = 'demo-acme@example.com')
                  or (t.name = 'Globex Corp.' and u.email = 'demo-globex@example.com')
on conflict do nothing;

-- 確認: 2行（会社ごとに1人）
select t.name as tenant, u.email
from public.memberships m
join public.tenants t on t.id = m.tenant_id
join auth.users u on u.id = m.user_id
where u.email like 'demo-%@example.com' order by t.name;
