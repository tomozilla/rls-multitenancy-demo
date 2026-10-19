-- Tenants (customer companies), memberships, invoices
create table public.tenants (
  id uuid primary key default gen_random_uuid(),
  name text not null
);
create table public.memberships (
  tenant_id uuid not null references public.tenants(id),
  user_id uuid not null references auth.users(id),
  primary key (tenant_id, user_id)
);
create table public.invoices (
  id bigint primary key generated always as identity,
  tenant_id uuid not null references public.tenants(id),
  title text not null,
  amount_jpy int not null
);
