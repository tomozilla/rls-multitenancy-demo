-- 自分の所属（memberships）の行だけ見える
create policy "members see their own memberships" on public.memberships
  for select to authenticated
  using (user_id = (select auth.uid()));

-- 自分が所属する取引先だけ見える
create policy "members see their own tenants" on public.tenants
  for select to authenticated
  using (id in (select tenant_id from public.memberships
                where user_id = (select auth.uid())));

-- 自分が所属する取引先の請求書だけ見える
create policy "members see their tenant's invoices" on public.invoices
  for select to authenticated
  using (tenant_id in (select tenant_id from public.memberships
                       where user_id = (select auth.uid())));

-- 自分が所属する取引先の請求書だけ追加できる
create policy "members add invoices to their tenant" on public.invoices
  for insert to authenticated
  with check (tenant_id in (select tenant_id from public.memberships
                            where user_id = (select auth.uid())));
