-- RLSをオンにする「前」: ログインしていない人（anon）が、全社の請求書を読めてしまうか確かめる
-- ※ begin; のあと、実行が終わったら `rollback;` を実行してトランザクションを閉じてください
begin;
set local role anon;
select t.name as tenant, i.title, i.amount_jpy
from public.invoices i join public.tenants t on t.id = i.tenant_id
order by i.id;
