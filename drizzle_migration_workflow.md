# Drizzle-powered "Schema-as-Code" & Migration Workflow  
(_Scope: Use Drizzle **only** for schema definitions and SQL-diff generation.  
All runtime data access can stay on Supabase JS / REST / GraphQL as today._)


## Phase 1 – Install & Scaffold _(Complete!)_

**Progress:**
- [x] Install dependencies:
  - [x] `npm install drizzle-orm`
  - [x] `npm install -D drizzle-kit postgres`
- [x] Create `src/db/index.ts` with Drizzle/pg connection
- [x] Create `drizzle.config.ts` in repo root

```bash
pnpm add drizzle-orm
pnpm add -D drizzle-kit postgres
```

`src/db/index.ts`
```ts
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'

const client = postgres(process.env.DATABASE_URL!, { prepare: false }) // pooler = transaction mode
export const db = drizzle(client)
```

`drizzle.config.ts`
```ts
import { config } from 'dotenv'
import { defineConfig } from 'drizzle-kit'

config()

export default defineConfig({
  schema: './src/db/schema.ts',
  out:    './supabase/migrations',   // keep using Supabase-approved folder
  dialect: 'postgresql',
  dbCredentials: { url: process.env.DATABASE_URL! },
})
```

---

## Phase 2 – Create the Baseline Schema File

```bash
npx drizzle-kit introspect --out=src/db/schema.ts   # pulls prod schema ➜ TypeScript
```

Open `schema.ts`; verify tables, enums, indexes & FKs are correct, then commit.  

---

## Phase 3 – Day-to-Day Change Flow

A. Edit `schema.ts` to reflect the desired change.  
B. Generate SQL:
```bash
npx drizzle-kit generate
# ➜ ./supabase/migrations/XXXX_<slug>.sql
```
C. Manually review the file — add RLS, data migration, or extension lines as needed.  
D. Commit **both** the migration file and the updated `schema.ts`.  
E. Before production:  
   1. Snapshot DB.  
   2. Apply migration:
      ```bash
      supabase db push
      ```  
   3. Verify with `supabase migration list`.

---

## Phase 4 – Optional CI Hooks

```jsonc
// package.json scripts
{
  "db:introspect": "drizzle-kit introspect --out=src/db/schema.ts",
  "db:generate":   "drizzle-kit generate",
  "db:check":      "drizzle-kit check",        // fails if schema & SQL diverge
  "db:push":       "supabase db push"
}
```Add `npx drizzle-kit check` to CI to block merges when migrations are missing.

---

## Phase 5 – Usage Tips

• Drizzle types (`typeof features.$inferSelect`) are available for server code but **no runtime path must change**.  
• Keep RLS policies in the same SQL file Drizzle generates (below the `-- statement-breakpoint`).  
• Never run `drizzle-kit push` against production; always pipe through `supabase db push`.

---

