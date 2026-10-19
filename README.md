# rls-multitenancy-demo

English | [日本語](README.ja.md)

A small learning demo of Row Level Security (RLS) that splits "which data you can see" per customer company (tenant). You put two companies' invoices in one project and check what is visible before and after RLS.

> **A personal learning project.** It is not an official sample of any company and not a model of a production design.
>
> Summary: SQL to try Postgres Row Level Security on a Supabase project with a simple multi-tenant invoice model (tenants / memberships / invoices), including checks as `anon`, as one tenant's user (JWT claims impersonation in the SQL Editor), and a cross-tenant write attempt.

This is the code for two Japanese articles on Qiita:
- How-to: *Supabase RLS basics: splitting "visible data" per customer, compared with splitting projects*
- Web app: *I built an "invoice portal" where the visible data changes per customer: log in and only your own company's rows appear* (`app/` and `sql/app/`)

The page/UI texts and comments are English (sample data and queries may stay Japanese in general; here the dummy data is already English-looking). Japanese-commented copies of the code (with the Japanese UI) are in [`ja/`](ja/).

## Contents

| File | Role |
|---|---|
| `sql/00_reset.sql` | (to start over) drop the demo tables |
| `sql/01_schema.sql` | create `tenants` / `memberships` / `invoices` |
| `sql/02_seed.sql` | dummy data: 2 companies, 2 users' memberships, 4 invoices |
| `sql/03_check_without_rls.sql` | BEFORE RLS: check that someone not logged in (anon) can read every company's rows |
| `sql/04_enable_rls.sql` | turn RLS on for the 3 tables |
| `sql/05_policies.sql` | policies: see / add only rows of the tenants you belong to |
| `sql/06_check_anon.sql` | anon sees 0 rows |
| `sql/07_check_as_alice.sql` | read as Alice (Acme) -> only Acme's 2 invoices |
| `sql/08_check_write_other_tenant.sql` | Alice tries to add an invoice for Globex -> error `42501` |
| `sql/app/01_portal_users.sql` | link the portal's login users to tenants |
| `app/` | the invoice portal (one HTML page, `config.example.js`) |
| `ja/` | the same code with Japanese comments / Japanese UI |

## Invoice portal (`app/`)

A small page where, after logging in, you see only your own company's invoices (one HTML file, no build; `supabase-js` is loaded from a CDN). The page code has no condition that filters by tenant. The RLS policies above decide which rows are visible.

```bash
# Prerequisite: sql/01 to 05 above are done. In Authentication -> Users, create two demo users
#   (e.g. demo-acme@example.com / demo-globex@example.com, tick Auto Confirm; choose the passwords yourself)
# Run sql/app/01_portal_users.sql to link the users to tenants
cd app
cp config.example.js config.js     # put in the URL and the publishable key (config.js is in .gitignore)
python3 -m http.server 8765 --bind 127.0.0.1   # -> http://127.0.0.1:8765/index.html
```

- The "Developer tests" on the page let you try: 1. read everything with no filter (only your own company's rows come back), 2. add a row with another tenant's ID (rejected with `42501`).
- Verified (October 2026): I logged in as the two users for real and checked the list, the total, adding a row, and the two tests above. The results matched the earlier "impersonation in the SQL Editor".
- Cost: user authentication and data reads/writes only. The Free plan includes up to 50,000 monthly active users (per the docs).
- Caution: users with several memberships, admins, password reset, and update/delete policies are not covered. Do not put the demo users' passwords into the repository.

## Prerequisites

- A Supabase project (I checked it on a Free-plan demo project)
- Just a browser (you use the SQL Editor)
- Two dummy users: in **Authentication -> Users -> Add user**, create `alice@example.com` and `bob@example.com` (tick **Auto Confirm User**). Choose the passwords yourself; they are not in this repository.

## Steps

1. Create the dummy users above.
2. In the SQL Editor, run `sql/01` onwards in order.
   - Running `01` shows a confirmation like "you are creating a table without RLS". **Choose "Run without RLS"** (so that `03` can show what happens without RLS; do this only in a demo project).
   - `03` / `06` / `07` / `08` start with `begin;`. After running them, run `rollback;` to close the transaction.
3. The expected results are written in the comment at the top of each file.
   - `03`: all 4 rows of both companies are visible (before RLS)
   - `06`: 0 rows
   - `07`: only Acme's 2 rows (change to `bob@example.com` and you get only Globex's 2 rows)
   - `08`: `ERROR: 42501: new row violates row-level security policy for table "invoices"`

I ran everything in this order from scratch and got the results above (October 2026).

## Where I got it wrong

As the comment in `08` says: if you try to add another company's row with `insert ... select`, Alice **cannot see** the other company's rows at all, so the select returns 0 rows and it **"succeeds" by adding 0 rows, with no error**. When you test a policy, insert with the other company's id written out explicitly, otherwise you cannot tell whether the policy works.

## Cost

- This demo ran within the Free plan.
- The article also compares splitting projects per customer. According to the docs, **on a paid-plan organization, each extra project adds Compute charges**. The Free plan allows 2 projects (per the docs, as of October 2026). I only created a second project to look at how it appears; I did not measure the cost or the operational effort.

## Warnings

- **This is a minimal learning setup.** In production you also need to think about write/update/delete policies, roles (such as admins), and performance (indexes on the columns used by policies). I have not tried these.
- The "impersonation" in the SQL Editor (`request.jwt.claims` and `set local role`) is not a test through a real login. The behavior with a real login was checked with the invoice portal in `app/` (same results).
- Right after you create a table, **until you turn RLS on, the table may be readable without logging in, depending on the API settings** (in my project it was, with the default settings). Do not try this order on a publicly exposed project.

## Not verified

- Behavior through a real login from an app (browser/server): only the SQL Editor "impersonation" was checked for the SQL files (the portal in `app/` was checked with real logins, as stated above)
- Update/delete policies, admin roles, and so on
- Speed when the number of policies or rows grows
- Migration and operational effort and cost of the "one project per customer" approach

Note on this English version: after translating comments and UI texts, I only syntax-checked the HTML script (`node --check`). I did not run the translated page or SQL against a live backend again.

## Cleanup

Drop the tables with `sql/00_reset.sql` and delete the dummy users as well.

## License

MIT (see `LICENSE`)
