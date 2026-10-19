-- ログインしていない人（anon）には、何件見える？（期待: 0件）
-- ※ 実行後に `rollback;` を実行してください
begin;
set local role anon;
select count(*) as visible_invoices from public.invoices;
