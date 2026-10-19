-- You can see only your own membership rows
create policy "members see their own memberships" on public.memberships
  for select to authenticated
  using (user_id = (select auth.uid()));

-- You can see only the tenants you belong to
create policy "members see their own tenants" on public.tenants
  for select to authenticated
  using (id in (select tenant_id from public.memberships
                where user_id = (select auth.uid())));

-- You can see only the invoices of the tenants you belong to
create policy "members see their tenant's invoices" on public.invoices
  for select to authenticated
  using (tenant_id in (select tenant_id from public.memberships
                       where user_id = (select auth.uid())));

-- You can add invoices only to the tenants you belong to
create policy "members add invoices to their tenant" on public.invoices
  for insert to authenticated
  with check (tenant_id in (select tenant_id from public.memberships
                            where user_id = (select auth.uid())));
