# fanbass-mvp
MVP for FanBass – fan-first music data platform

## Development Setup

### Prerequisites
- Docker Desktop installed and running
- Supabase CLI installed (`scoop install supabase`)

### Environment Setup
1. Make sure Docker Desktop is running
2. Ensure you have the following environment files:
   - `.env` in the root directory with:
     ```
     SUPABASE_PROJECT_ID=vkvhrearjmmwiuvvmcib
     SUPABASE_DB_PASSWORD=your-db-password
     SUPABASE_ACCESS_TOKEN=your-access-token
     ```
   - `frontend/.env` with:
     ```
     REACT_APP_SUPABASE_URL=https://vkvhrearjmmwiuvvmcib.supabase.co
     REACT_APP_SUPABASE_ANON_KEY=your-anon-key
     ```

### Making Database Changes
1. Create a new migration:
   ```bash
   supabase migration new your-migration-name
   ```
2. Edit the migration file in `supabase/migrations/`
3. Push the changes:
   ```bash
   supabase db push
   ```
4. Verify the changes:
   ```bash
   supabase migration list
   ```


To enable browser tools for cursor, run npx @agentdeskai/browser-tools-server@1.2.0
