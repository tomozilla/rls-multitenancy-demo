-- Turn RLS on. There are no policies yet, so at this point nobody (anon / authenticated) can see anything.
alter table public.tenants enable row level security;
alter table public.memberships enable row level security;
alter table public.invoices enable row level security;
