-- RLSをオン。ポリシーがまだ無いので、この時点では誰にも（anon / authenticated）何も見えなくなる
alter table public.tenants enable row level security;
alter table public.memberships enable row level security;
alter table public.invoices enable row level security;
