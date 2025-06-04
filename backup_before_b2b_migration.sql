--
-- PostgreSQL database dump
--

-- Dumped from database version 15.8
-- Dumped by pg_dump version 17.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA auth;


--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA extensions;


--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql;


--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql_public;


--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA pgbouncer;


--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA realtime;


--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA storage;


--
-- Name: supabase_migrations; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA supabase_migrations;


--
-- Name: vault; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA vault;


--
-- Name: pg_graphql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_graphql WITH SCHEMA graphql;


--
-- Name: EXTENSION pg_graphql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_graphql IS 'pg_graphql: GraphQL support';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;


--
-- Name: EXTENSION supabase_vault; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION supabase_vault IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


--
-- Name: action; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in'
);


--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text
);


--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    func_is_graphql_resolve bool;
BEGIN
    func_is_graphql_resolve = (
        SELECT n.proname = 'resolve'
        FROM pg_event_trigger_ddl_commands() AS ev
        LEFT JOIN pg_catalog.pg_proc AS n
        ON ev.objid = n.oid
    );

    IF func_is_graphql_resolve
    THEN
        -- Update public wrapper to pass all arguments through to the pg_graphql resolve func
        DROP FUNCTION IF EXISTS graphql_public.graphql;
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language sql
        as $$
            select graphql.resolve(
                query := query,
                variables := coalesce(variables, '{}'),
                "operationName" := "operationName",
                extensions := extensions
            );
        $$;

        -- This hook executes when `graphql.resolve` is created. That is not necessarily the last
        -- function in the extension so we need to grant permissions on existing entities AND
        -- update default permissions to any others that are created after `graphql.resolve`
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant select on all tables in schema graphql to postgres, anon, authenticated, service_role;
        grant execute on all functions in schema graphql to postgres, anon, authenticated, service_role;
        grant all on all sequences in schema graphql to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;

        -- Allow postgres role to allow granting usage on graphql and graphql_public schemas to custom roles
        grant usage on schema graphql_public to postgres with grant option;
        grant usage on schema graphql to postgres with grant option;
    END IF;

END;
$_$;


--
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    IF EXISTS (
      SELECT FROM pg_extension
      WHERE extname = 'pg_net'
      -- all versions in use on existing projects as of 2025-02-20
      -- version 0.12.0 onwards don't need these applied
      AND extversion IN ('0.2', '0.6', '0.7', '0.7.1', '0.8', '0.10.0', '0.11.0')
    ) THEN
      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

      REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
      REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

      GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
      GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    END IF;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


--
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: -
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $_$
begin
    raise debug 'PgBouncer auth request: %', p_usename;

    return query
    select 
        rolname::text, 
        case when rolvaliduntil < now() 
            then null 
            else rolpassword::text 
        end 
    from pg_authid 
    where rolname=$1 and rolcanlogin;
end;
$_$;


--
-- Name: generate_b2b_fingerprint(uuid[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_b2b_fingerprint(artist_ids uuid[]) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
  RETURN array_to_string(ARRAY(SELECT unnest(artist_ids) ORDER BY 1), ',');
END;
$$;


--
-- Name: get_feature_votes(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_feature_votes(uid uuid) RETURNS TABLE(id uuid, title text, description text, status text, vote_count integer, user_voted boolean, created_at timestamp with time zone)
    LANGUAGE sql
    AS $$
  select
    f.id,
    f.title,
    f.description,
    f.status,
    count(v.id) as vote_count,
    exists (
      select 1 from feature_votes v2
      where v2.feature_id = f.id and v2.user_id = uid
    ) as user_voted,
    f.created_at
  from features f
  left join feature_votes v on v.feature_id = f.id
  group by f.id;
$$;


--
-- Name: handle_new_user_role(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_new_user_role() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
begin
  insert into public.roles (user_id, role)
  values (new.id, 'fan')
  on conflict do nothing;

  return new;
end;
$$;


--
-- Name: has_role(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.has_role(role_name text) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  select exists (
    select 1 from roles
    where user_id = auth.uid()
      and role = role_name
  )
$$;


--
-- Name: set_b2b_fingerprint(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_b2b_fingerprint() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.fingerprint := sorted_artist_fingerprint(NEW.artist_ids);
  RETURN NEW;
END;
$$;


--
-- Name: sorted_artist_fingerprint(text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.sorted_artist_fingerprint(text[]) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
  SELECT array_to_string(ARRAY(
    SELECT unnest($1) ORDER BY 1
  ), ',');
$_$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;


--
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
declare
-- Regclass of the table e.g. public.notes
entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

-- I, U, D, T: insert, update ...
action realtime.action = (
    case wal ->> 'action'
        when 'I' then 'INSERT'
        when 'U' then 'UPDATE'
        when 'D' then 'DELETE'
        else 'ERROR'
    end
);

-- Is row level security enabled for the table
is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

subscriptions realtime.subscription[] = array_agg(subs)
    from
        realtime.subscription subs
    where
        subs.entity = entity_;

-- Subscription vars
roles regrole[] = array_agg(distinct us.claims_role::text)
    from
        unnest(subscriptions) us;

working_role regrole;
claimed_role regrole;
claims jsonb;

subscription_id uuid;
subscription_has_access bool;
visible_to_subscription_ids uuid[] = '{}';

-- structured info for wal's columns
columns realtime.wal_column[];
-- previous identity values for update/delete
old_columns realtime.wal_column[];

error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

-- Primary jsonb output for record
output jsonb;

begin
perform set_config('role', null, true);

columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'columns') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

old_columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'identity') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

for working_role in select * from unnest(roles) loop

    -- Update `is_selectable` for columns and old_columns
    columns =
        array_agg(
            (
                c.name,
                c.type_name,
                c.type_oid,
                c.value,
                c.is_pkey,
                pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
            )::realtime.wal_column
        )
        from
            unnest(columns) c;

    old_columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(old_columns) c;

    if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            -- subscriptions is already filtered by entity
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 400: Bad Request, no primary key']
        )::realtime.wal_rls;

    -- The claims role does not have SELECT permission to the primary key of entity
    elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 401: Unauthorized']
        )::realtime.wal_rls;

    else
        output = jsonb_build_object(
            'schema', wal ->> 'schema',
            'table', wal ->> 'table',
            'type', action,
            'commit_timestamp', to_char(
                ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
            ),
            'columns', (
                select
                    jsonb_agg(
                        jsonb_build_object(
                            'name', pa.attname,
                            'type', pt.typname
                        )
                        order by pa.attnum asc
                    )
                from
                    pg_attribute pa
                    join pg_type pt
                        on pa.atttypid = pt.oid
                where
                    attrelid = entity_
                    and attnum > 0
                    and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
            )
        )
        -- Add "record" key for insert and update
        || case
            when action in ('INSERT', 'UPDATE') then
                jsonb_build_object(
                    'record',
                    (
                        select
                            jsonb_object_agg(
                                -- if unchanged toast, get column name and value from old record
                                coalesce((c).name, (oc).name),
                                case
                                    when (c).name is null then (oc).value
                                    else (c).value
                                end
                            )
                        from
                            unnest(columns) c
                            full outer join unnest(old_columns) oc
                                on (c).name = (oc).name
                        where
                            coalesce((c).is_selectable, (oc).is_selectable)
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                    )
                )
            else '{}'::jsonb
        end
        -- Add "old_record" key for update and delete
        || case
            when action = 'UPDATE' then
                jsonb_build_object(
                        'old_record',
                        (
                            select jsonb_object_agg((c).name, (c).value)
                            from unnest(old_columns) c
                            where
                                (c).is_selectable
                                and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                        )
                    )
            when action = 'DELETE' then
                jsonb_build_object(
                    'old_record',
                    (
                        select jsonb_object_agg((c).name, (c).value)
                        from unnest(old_columns) c
                        where
                            (c).is_selectable
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                    )
                )
            else '{}'::jsonb
        end;

        -- Create the prepared statement
        if is_rls_enabled and action <> 'DELETE' then
            if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                deallocate walrus_rls_stmt;
            end if;
            execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
        end if;

        visible_to_subscription_ids = '{}';

        for subscription_id, claims in (
                select
                    subs.subscription_id,
                    subs.claims
                from
                    unnest(subscriptions) subs
                where
                    subs.entity = entity_
                    and subs.claims_role = working_role
                    and (
                        realtime.is_visible_through_filters(columns, subs.filters)
                        or (
                          action = 'DELETE'
                          and realtime.is_visible_through_filters(old_columns, subs.filters)
                        )
                    )
        ) loop

            if not is_rls_enabled or action = 'DELETE' then
                visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
            else
                -- Check if RLS allows the role to see the record
                perform
                    -- Trim leading and trailing quotes from working_role because set_config
                    -- doesn't recognize the role as valid if they are included
                    set_config('role', trim(both '"' from working_role::text), true),
                    set_config('request.jwt.claims', claims::text, true);

                execute 'execute walrus_rls_stmt' into subscription_has_access;

                if subscription_has_access then
                    visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                end if;
            end if;
        end loop;

        perform set_config('role', null, true);

        return next (
            output,
            is_rls_enabled,
            visible_to_subscription_ids,
            case
                when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                else '{}'
            end
        )::realtime.wal_rls;

    end if;
end loop;

perform set_config('role', null, true);
end;
$$;


--
-- Name: broadcast_changes(text, text, text, text, text, record, record, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


--
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


--
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    declare
      res jsonb;
    begin
      execute format('select to_jsonb(%L::'|| type_::text || ')', val)  into res;
      return res;
    end
    $$;


--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
      /*
      Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
      */
      declare
          op_symbol text = (
              case
                  when op = 'eq' then '='
                  when op = 'neq' then '!='
                  when op = 'lt' then '<'
                  when op = 'lte' then '<='
                  when op = 'gt' then '>'
                  when op = 'gte' then '>='
                  when op = 'in' then '= any'
                  else 'UNKNOWN OP'
              end
          );
          res boolean;
      begin
          execute format(
              'select %L::'|| type_::text || ' ' || op_symbol
              || ' ( %L::'
              || (
                  case
                      when op = 'in' then type_::text || '[]'
                      else type_::text end
              )
              || ')', val_1, val_2) into res;
          return res;
      end;
      $$;


--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen because subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $_$;


--
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS SETOF realtime.wal_rls
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
      with pub as (
        select
          concat_ws(
            ',',
            case when bool_or(pubinsert) then 'insert' else null end,
            case when bool_or(pubupdate) then 'update' else null end,
            case when bool_or(pubdelete) then 'delete' else null end
          ) as w2j_actions,
          coalesce(
            string_agg(
              realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
              ','
            ) filter (where ppt.tablename is not null and ppt.tablename not like '% %'),
            ''
          ) w2j_add_tables
        from
          pg_publication pp
          left join pg_publication_tables ppt
            on pp.pubname = ppt.pubname
        where
          pp.pubname = publication
        group by
          pp.pubname
        limit 1
      ),
      w2j as (
        select
          x.*, pub.w2j_add_tables
        from
          pub,
          pg_logical_slot_get_changes(
            slot_name, null, max_changes,
            'include-pk', 'true',
            'include-transaction', 'false',
            'include-timestamp', 'true',
            'include-type-oids', 'true',
            'format-version', '2',
            'actions', pub.w2j_actions,
            'add-tables', pub.w2j_add_tables
          ) x
      )
      select
        xyz.wal,
        xyz.is_rls_enabled,
        xyz.subscription_ids,
        xyz.errors
      from
        w2j,
        realtime.apply_rls(
          wal := w2j.data::jsonb,
          max_record_bytes := max_record_bytes
        ) xyz(wal, is_rls_enabled, subscription_ids, errors)
      where
        w2j.w2j_add_tables <> ''
        and xyz.subscription_ids[1] is not null
    $$;


--
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
      select
        (
          select string_agg('' || ch,'')
          from unnest(string_to_array(nsp.nspname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
        )
        || '.'
        || (
          select string_agg('' || ch,'')
          from unnest(string_to_array(pc.relname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
          )
      from
        pg_class pc
        join pg_namespace nsp
          on pc.relnamespace = nsp.oid
      where
        pc.oid = entity
    $$;


--
-- Name: send(jsonb, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  BEGIN
    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    -- Attempt to insert the message
    INSERT INTO realtime.messages (payload, event, topic, private, extension)
    VALUES (payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      -- Capture and notify the error
      PERFORM pg_notify(
          'realtime:system',
          jsonb_build_object(
              'error', SQLERRM,
              'function', 'realtime.send',
              'event', event,
              'topic', topic,
              'private', private
          )::text
      );
  END;
END;
$$;


--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    /*
    Validates that the user defined filters for a subscription:
    - refer to valid columns that the claimed role may access
    - values are coercable to the correct column type
    */
    declare
        col_names text[] = coalesce(
                array_agg(c.column_name order by c.ordinal_position),
                '{}'::text[]
            )
            from
                information_schema.columns c
            where
                format('%I.%I', c.table_schema, c.table_name)::regclass = new.entity
                and pg_catalog.has_column_privilege(
                    (new.claims ->> 'role'),
                    format('%I.%I', c.table_schema, c.table_name)::regclass,
                    c.column_name,
                    'SELECT'
                );
        filter realtime.user_defined_filter;
        col_type regtype;

        in_val jsonb;
    begin
        for filter in select * from unnest(new.filters) loop
            -- Filtered column is valid
            if not filter.column_name = any(col_names) then
                raise exception 'invalid column for filter %', filter.column_name;
            end if;

            -- Type is sanitized and safe for string interpolation
            col_type = (
                select atttypid::regtype
                from pg_catalog.pg_attribute
                where attrelid = new.entity
                      and attname = filter.column_name
            );
            if col_type is null then
                raise exception 'failed to lookup type for column %', filter.column_name;
            end if;

            -- Set maximum number of entries for in filter
            if filter.op = 'in'::realtime.equality_op then
                in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
                if coalesce(jsonb_array_length(in_val), 0) > 100 then
                    raise exception 'too many values for `in` filter. Maximum 100';
                end if;
            else
                -- raises an exception if value is not coercable to type
                perform realtime.cast(filter.value, col_type);
            end if;

        end loop;

        -- Apply consistent order to filters so the unique constraint on
        -- (subscription_id, entity, filters) can't be tricked by a different filter order
        new.filters = coalesce(
            array_agg(f order by f.column_name, f.op, f.value),
            '{}'
        ) from unnest(new.filters) f;

        return new;
    end;
    $$;


--
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


--
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
_filename text;
BEGIN
	select string_to_array(name, '/') into _parts;
	select _parts[array_length(_parts,1)] into _filename;
	-- @todo return the last part instead of 2
	return reverse(split_part(reverse(_filename), '.', 1));
END
$$;


--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[1:array_length(_parts,1)-1];
END
$$;


--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::int) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


--
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


--
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(name COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                        substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1)))
                    ELSE
                        name
                END AS name, id, metadata, updated_at
            FROM
                storage.objects
            WHERE
                bucket_id = $5 AND
                name ILIKE $1 || ''%'' AND
                CASE
                    WHEN $6 != '''' THEN
                    name COLLATE "C" > $6
                ELSE true END
                AND CASE
                    WHEN $4 != '''' THEN
                        CASE
                            WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                                substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                name COLLATE "C" > $4
                            END
                    ELSE
                        true
                END
            ORDER BY
                name COLLATE "C" ASC) as e order by name COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_token, bucket_id, start_after;
END;
$_$;


--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


--
-- Name: search(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
  v_order_by text;
  v_sort_order text;
begin
  case
    when sortcolumn = 'name' then
      v_order_by = 'name';
    when sortcolumn = 'updated_at' then
      v_order_by = 'updated_at';
    when sortcolumn = 'created_at' then
      v_order_by = 'created_at';
    when sortcolumn = 'last_accessed_at' then
      v_order_by = 'last_accessed_at';
    else
      v_order_by = 'name';
  end case;

  case
    when sortorder = 'asc' then
      v_sort_order = 'asc';
    when sortorder = 'desc' then
      v_sort_order = 'desc';
    else
      v_sort_order = 'asc';
  end case;

  v_order_by = v_order_by || ' ' || v_sort_order;

  return query execute
    'with folders as (
       select path_tokens[$1] as folder
       from storage.objects
         where objects.name ilike $2 || $3 || ''%''
           and bucket_id = $4
           and array_length(objects.path_tokens, 1) <> $1
       group by folder
       order by folder ' || v_sort_order || '
     )
     (select folder as "name",
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[$1] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where objects.name ilike $2 || $3 || ''%''
       and bucket_id = $4
       and array_length(objects.path_tokens, 1) = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text NOT NULL,
    code_challenge_method auth.code_challenge_method NOT NULL,
    code_challenge text NOT NULL,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone
);


--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.flow_state IS 'stores metadata for pkce logins';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid
);


--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: -
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: -
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text
);


--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: artist_placement_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.artist_placement_history (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    artist_id uuid NOT NULL,
    tier text NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: artist_placements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.artist_placements (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_id uuid,
    artist_id uuid,
    stage text,
    tier text,
    inserted_at timestamp with time zone,
    updated_at timestamp with time zone DEFAULT now(),
    b2b_set_id uuid
);


--
-- Name: artists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.artists (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    name text,
    created_by uuid,
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: artist_placements_with_names; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.artist_placements_with_names AS
 SELECT ap.id,
    ap.user_id,
    ap.artist_id,
    a.name AS artist_name,
    ap.tier,
    ap.updated_at
   FROM (public.artist_placements ap
     JOIN public.artists a ON ((ap.artist_id = a.id)));


--
-- Name: b2b_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.b2b_sets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    artist_ids text[] NOT NULL,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now(),
    fingerprint text NOT NULL
);


--
-- Name: event_set_artists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_set_artists (
    set_id uuid NOT NULL,
    artist_id uuid NOT NULL,
    event_id uuid
);


--
-- Name: event_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_sets (
    event_id uuid NOT NULL,
    tier integer DEFAULT 1 NOT NULL,
    set_note text,
    display_name text,
    created_by uuid,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: event_sets_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.event_sets_view AS
 SELECT s.id AS set_id,
    s.event_id,
    s.tier,
    s.display_name,
    s.set_note,
    a.id AS artist_id,
    a.name AS artist_name
   FROM ((public.event_sets s
     JOIN public.event_set_artists esa ON ((esa.set_id = s.id)))
     JOIN public.artists a ON ((a.id = esa.artist_id)));


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    date date,
    location text,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now(),
    num_tiers integer DEFAULT 3 NOT NULL,
    slug text,
    is_draft boolean DEFAULT true,
    status text DEFAULT 'draft'::text
);


--
-- Name: feature_votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.feature_votes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    feature_id uuid,
    user_id uuid,
    voted_at timestamp with time zone DEFAULT timezone('utc'::text, now())
);


--
-- Name: features; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.features (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    title text NOT NULL,
    description text,
    status text DEFAULT 'Open'::text,
    created_by uuid,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now())
);


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.roles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    role text,
    CONSTRAINT roles_role_check CHECK ((role = ANY (ARRAY['admin'::text, 'fan'::text, 'artist'::text, 'promoter'::text])))
);


--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
)
PARTITION BY RANGE (inserted_at);


--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: -
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text
);


--
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: objects; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb
);


--
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb
);


--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: supabase_migrations; Owner: -
--

CREATE TABLE supabase_migrations.schema_migrations (
    version text NOT NULL,
    statements text[],
    name text
);


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) FROM stdin;
00000000-0000-0000-0000-000000000000	1c41ca94-4dc0-41e9-a915-3ed2123310d8	{"action":"user_signedup","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"team","traits":{"provider":"google"}}	2025-05-24 02:33:25.595911+00	
00000000-0000-0000-0000-000000000000	0c6c7c89-cfc3-44d6-b3c2-0e6d658f74ba	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 02:46:43.453325+00	
00000000-0000-0000-0000-000000000000	60ed2b03-dd5a-4c7f-8f9c-2a35860aa6c9	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 03:53:33.345806+00	
00000000-0000-0000-0000-000000000000	3ba4a44e-5562-4894-888d-e03835ee7b97	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 05:57:52.734369+00	
00000000-0000-0000-0000-000000000000	57260c57-de2a-452a-8d09-d292e9f1a6be	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 06:01:39.087499+00	
00000000-0000-0000-0000-000000000000	d307881e-ef06-4ba1-bb7e-82a4e2629ad1	{"action":"logout","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-05-24 06:05:30.8519+00	
00000000-0000-0000-0000-000000000000	f0ca7ac3-9bac-47b8-9386-9f05dd95a8af	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 06:05:34.259017+00	
00000000-0000-0000-0000-000000000000	60f3fbd4-aa9d-4db6-9ead-8c08c0b4ba9a	{"action":"logout","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-05-24 06:07:10.886435+00	
00000000-0000-0000-0000-000000000000	4d995425-0a86-48f8-ae43-7da187be4863	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 06:10:16.713299+00	
00000000-0000-0000-0000-000000000000	6cb2ca5e-173b-4e7b-8886-f23f7f4eef99	{"action":"logout","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-05-24 06:14:35.222305+00	
00000000-0000-0000-0000-000000000000	e8545b59-c404-425e-8c91-36f204a2b7a3	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 06:14:42.276201+00	
00000000-0000-0000-0000-000000000000	deffcd55-ac08-492b-892a-2617fecdfae2	{"action":"logout","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-05-24 06:15:00.937628+00	
00000000-0000-0000-0000-000000000000	572ecb39-9d47-4e61-af2b-87eda4a82f37	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 06:15:09.595332+00	
00000000-0000-0000-0000-000000000000	6a78610b-534a-4e79-adbb-9d4b0bfa6fe6	{"action":"logout","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-05-24 06:15:12.903396+00	
00000000-0000-0000-0000-000000000000	bd181e84-61a4-436f-9885-060ba9bcc5c4	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 06:15:23.278673+00	
00000000-0000-0000-0000-000000000000	ef54834c-88b1-40e5-8735-a49fafa8ff20	{"action":"logout","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-05-24 06:54:53.041216+00	
00000000-0000-0000-0000-000000000000	9a019fbc-51c8-4409-ad02-a6c91511bf9e	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 06:55:31.237542+00	
00000000-0000-0000-0000-000000000000	673003e2-ffd8-4e7e-b610-4b6f7cb8b6c9	{"action":"logout","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-05-24 07:03:26.091061+00	
00000000-0000-0000-0000-000000000000	5689662a-7be0-4ad3-90ec-88f8a2a070b2	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 07:03:43.459016+00	
00000000-0000-0000-0000-000000000000	9004a9b4-6b46-472e-a709-dd4b382158d6	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-24 08:03:41.633037+00	
00000000-0000-0000-0000-000000000000	fb9c8f75-bde7-44d3-8230-1a77ddd94b59	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-24 08:03:41.633882+00	
00000000-0000-0000-0000-000000000000	f8524be5-0559-43f9-a243-2dda0ef38689	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-24 09:14:54.663481+00	
00000000-0000-0000-0000-000000000000	166cb834-4585-4f16-91eb-dc77458a42b0	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-24 09:14:54.664986+00	
00000000-0000-0000-0000-000000000000	18ffe25c-ed3a-4be4-a940-1560af36f522	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-24 10:13:24.54618+00	
00000000-0000-0000-0000-000000000000	a34ce088-2894-46f3-8563-ec13b71f9e3a	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-24 10:13:24.546983+00	
00000000-0000-0000-0000-000000000000	d45bfc17-84e8-4dbd-b1d3-a033a5780409	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-24 11:11:54.63681+00	
00000000-0000-0000-0000-000000000000	b80d6071-425e-4704-a33a-2d60452f9e11	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-24 11:11:54.637635+00	
00000000-0000-0000-0000-000000000000	c1f3eb3a-0865-4290-b044-99573ffd05e0	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-24 12:10:24.611892+00	
00000000-0000-0000-0000-000000000000	2a41f8da-c418-41e9-9ee6-d9d0b916064f	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-24 12:10:24.613362+00	
00000000-0000-0000-0000-000000000000	0fce9836-ccf6-47d9-ae31-f467c8af9de0	{"action":"user_signedup","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"google"}}	2025-05-24 13:56:41.091929+00	
00000000-0000-0000-0000-000000000000	aab6bdbd-cfe8-4878-a600-9b94177c273a	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-24 14:15:35.000577+00	
00000000-0000-0000-0000-000000000000	82b5bd6d-d0cf-4039-bc3d-56aadfdee2ad	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-24 14:15:35.007091+00	
00000000-0000-0000-0000-000000000000	37f5250f-2bba-4c18-b6f2-7f38d41c6abc	{"action":"logout","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-05-24 14:17:20.103652+00	
00000000-0000-0000-0000-000000000000	af6dde1e-dbb3-461a-84c3-4088e1fd5e35	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 14:17:24.686104+00	
00000000-0000-0000-0000-000000000000	5015c753-925b-47ea-8cb3-2f48ee4493ee	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-24 15:16:53.256905+00	
00000000-0000-0000-0000-000000000000	46e88561-5cf4-4148-adf3-02fb428f69a0	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-24 15:16:53.2577+00	
00000000-0000-0000-0000-000000000000	782f7b69-8125-465f-b0fd-011ebf200d6f	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-24 16:15:13.330771+00	
00000000-0000-0000-0000-000000000000	08cb1daf-a79f-4a02-a839-1f8d5578be2c	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-24 16:15:13.332369+00	
00000000-0000-0000-0000-000000000000	d255f52d-aa6c-4f77-b12f-7f4aa30d637e	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-24 17:13:59.548598+00	
00000000-0000-0000-0000-000000000000	a34e99ca-9477-49d6-aa9f-6a152ba3ece7	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-24 17:13:59.550021+00	
00000000-0000-0000-0000-000000000000	8e0f32fb-3171-456e-a613-1135f8232ed4	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 17:22:43.775881+00	
00000000-0000-0000-0000-000000000000	82da8d26-548f-4292-af23-50040dc796aa	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 17:27:53.701383+00	
00000000-0000-0000-0000-000000000000	36a7d119-94b1-4cb5-bacb-5dd4edb22ad5	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 17:28:44.200487+00	
00000000-0000-0000-0000-000000000000	90577e5a-2a45-432f-b227-390c537854c6	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 17:43:32.544591+00	
00000000-0000-0000-0000-000000000000	e25ef915-ce7d-4b36-9ed0-42e1d8091da3	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 17:53:55.766528+00	
00000000-0000-0000-0000-000000000000	856c96ed-6dd3-497f-8e13-4a3b25f2f968	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 17:56:41.334411+00	
00000000-0000-0000-0000-000000000000	e0493b41-714f-489c-944b-2a017276aaef	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 17:59:00.365362+00	
00000000-0000-0000-0000-000000000000	08a8c0ec-f66c-43f5-a79f-57f5aa21f774	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 18:03:43.029314+00	
00000000-0000-0000-0000-000000000000	0914ca97-7867-42cc-911e-b3b25e6f2e2e	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 18:06:07.100889+00	
00000000-0000-0000-0000-000000000000	958f33d4-8a60-495a-af3b-01b5272fb92f	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 18:14:50.919774+00	
00000000-0000-0000-0000-000000000000	cd2139d3-6efa-4ee2-85ee-787c5a46e0e2	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 18:18:35.171679+00	
00000000-0000-0000-0000-000000000000	f89f7e03-6549-4e75-8700-207da489c963	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 18:30:05.466582+00	
00000000-0000-0000-0000-000000000000	6f846778-c266-4292-b1ce-fb22fc203ffd	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 18:35:42.755704+00	
00000000-0000-0000-0000-000000000000	c7f99173-d667-4679-a4f7-15b048acbd6a	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 18:50:56.149967+00	
00000000-0000-0000-0000-000000000000	ef4a1f8d-6c4c-40ab-bc78-05a5c9079b00	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 19:01:59.975819+00	
00000000-0000-0000-0000-000000000000	e58a180e-d101-43c0-88b7-f93b24c0c705	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 19:19:51.278769+00	
00000000-0000-0000-0000-000000000000	90e93e57-8b12-4981-9f5a-8fa6fbb83d02	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 19:23:57.966873+00	
00000000-0000-0000-0000-000000000000	89d4d79c-bf48-4663-b7d0-0d3ccb856c14	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-24 19:27:23.281445+00	
00000000-0000-0000-0000-000000000000	dc04b56c-87fb-46fd-b1af-c2b0dacc9fb4	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-24 19:27:23.284958+00	
00000000-0000-0000-0000-000000000000	18a49ff6-923c-400a-833d-5633201b9847	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 19:28:04.166316+00	
00000000-0000-0000-0000-000000000000	2aaafb7b-b2e5-43c3-b4a4-6d6e3cc545e4	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 19:32:52.761654+00	
00000000-0000-0000-0000-000000000000	f02b8327-a1c6-4b53-b631-7e9d7c9544fd	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 19:42:46.993715+00	
00000000-0000-0000-0000-000000000000	914b9a05-ee89-43be-88df-14c82c705bd4	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 19:50:41.789597+00	
00000000-0000-0000-0000-000000000000	a343c4d7-2d14-40fd-8d77-db59d88fde55	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-24 19:55:31.054158+00	
00000000-0000-0000-0000-000000000000	1c87da10-0ad8-4288-91d1-98375dea996e	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-25 04:48:28.295981+00	
00000000-0000-0000-0000-000000000000	dd0ab05c-298d-445a-b110-bf07f8e59cd7	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-25 04:48:28.296781+00	
00000000-0000-0000-0000-000000000000	70c99fdc-0a49-4ba0-a510-7888e237dbdc	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-25 10:51:24.668758+00	
00000000-0000-0000-0000-000000000000	8862365a-33d8-471b-b632-e1c0cf28ad21	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-25 10:51:24.674388+00	
00000000-0000-0000-0000-000000000000	823bcd9c-f667-40c0-b840-7ecc53578157	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-25 11:22:30.203823+00	
00000000-0000-0000-0000-000000000000	f82cd2a9-07b2-401f-8596-2887467e1497	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-25 11:29:29.721007+00	
00000000-0000-0000-0000-000000000000	5836c91b-3f65-406a-906d-75132b8eff61	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-25 11:34:08.730556+00	
00000000-0000-0000-0000-000000000000	a571789e-2680-42f1-a07d-2d626dbb6585	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-25 11:38:38.484243+00	
00000000-0000-0000-0000-000000000000	f4d6e9d1-07b9-4761-84c8-31b363538978	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-25 11:42:42.550369+00	
00000000-0000-0000-0000-000000000000	f7f71cb0-b53f-4221-8e27-e1353f2b37ce	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-25 11:47:21.816863+00	
00000000-0000-0000-0000-000000000000	23fe4fdc-4e3a-4067-a29e-3e2a2297902d	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-25 13:12:15.336794+00	
00000000-0000-0000-0000-000000000000	610bc0bc-642c-4ee9-9e68-1926daf13c98	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-25 13:15:04.531496+00	
00000000-0000-0000-0000-000000000000	8cd90a68-8cf4-4e5e-b5b2-7836a999214d	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-25 13:15:04.532292+00	
00000000-0000-0000-0000-000000000000	efe7b553-bed7-4801-abb0-bc8875a7bd57	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-25 13:20:39.771333+00	
00000000-0000-0000-0000-000000000000	8e12977e-9d9d-4154-9509-1031cc9f1060	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-25 15:10:41.501548+00	
00000000-0000-0000-0000-000000000000	2c671786-8798-4b6a-a4d8-f25561718f10	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-25 15:10:41.50409+00	
00000000-0000-0000-0000-000000000000	def5506b-1e5f-4df4-8cd7-440c54089c7f	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-25 15:12:51.723429+00	
00000000-0000-0000-0000-000000000000	73919ee6-2f1c-42e2-bb59-f4c81becbf03	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-25 15:17:59.816267+00	
00000000-0000-0000-0000-000000000000	6310875f-c8db-4b63-870b-bcbbaa6baab9	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-25 15:21:31.978288+00	
00000000-0000-0000-0000-000000000000	d5e41a68-db3e-4ac0-84e9-d193e500326e	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-25 15:37:13.101824+00	
00000000-0000-0000-0000-000000000000	019b1a9e-5ab7-43ce-afe0-db111878d717	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-25 15:38:55.827834+00	
00000000-0000-0000-0000-000000000000	83f53d69-add8-483e-946b-3151c9f067d9	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-25 15:38:55.829875+00	
00000000-0000-0000-0000-000000000000	7a388e14-fcf4-4f63-bbe3-bc4cd32e2020	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-25 15:45:49.651726+00	
00000000-0000-0000-0000-000000000000	dd15ea0c-bdf2-4940-9f9b-d39e009fe1d6	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-25 15:53:21.596926+00	
00000000-0000-0000-0000-000000000000	94d3d108-ca26-43b4-9c72-80510a8eb6ca	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-25 17:15:06.613926+00	
00000000-0000-0000-0000-000000000000	3da99a2a-c4f8-461e-85a1-e144ecb84f1c	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-25 17:15:06.619517+00	
00000000-0000-0000-0000-000000000000	5a4bdf2e-1d42-4dad-984b-9f2d0531fec3	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-25 17:15:37.392938+00	
00000000-0000-0000-0000-000000000000	5270b3d4-5758-4ef8-9ee6-d5d58331351d	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-25 17:20:55.939049+00	
00000000-0000-0000-0000-000000000000	00651b27-17c8-460c-ae6f-7d315d6cad1d	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-25 17:20:55.941305+00	
00000000-0000-0000-0000-000000000000	a2b1770c-4e39-4214-b35c-554918d01057	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-25 17:21:02.69788+00	
00000000-0000-0000-0000-000000000000	ab50b594-f149-42dc-b00a-2d6fb7b3a159	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-25 17:48:22.055985+00	
00000000-0000-0000-0000-000000000000	0b3fbe9a-f21b-472f-8b15-2b5e9f42e2ea	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-25 18:09:35.706384+00	
00000000-0000-0000-0000-000000000000	fd08cd81-1293-4c0a-9d0b-fbe472a66020	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-25 18:50:27.455598+00	
00000000-0000-0000-0000-000000000000	b0b373b1-e254-422a-8218-63d6e224b175	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-25 18:50:27.457076+00	
00000000-0000-0000-0000-000000000000	9418f613-94f9-4b45-8f20-993e05794d28	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-25 18:50:27.646186+00	
00000000-0000-0000-0000-000000000000	bf895d36-59ce-43ef-9787-ac49fc1f9eb5	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-25 18:50:27.646791+00	
00000000-0000-0000-0000-000000000000	d232757e-1209-44fa-bf4c-d10247bfd5f6	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-25 18:50:32.480321+00	
00000000-0000-0000-0000-000000000000	58fd8bd9-fa5b-49fa-a585-bed7dceb9767	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-25 18:55:35.218879+00	
00000000-0000-0000-0000-000000000000	a400543a-ce59-417a-854b-6db0fa5b3412	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-25 19:02:29.851852+00	
00000000-0000-0000-0000-000000000000	f023861b-7986-442b-843a-e9c73687c453	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-26 16:08:13.659677+00	
00000000-0000-0000-0000-000000000000	99d905c4-43bc-4e7e-b55a-f16b975831dc	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-26 16:08:13.667631+00	
00000000-0000-0000-0000-000000000000	ea8db603-8a4f-4e32-a786-a128654ad2f7	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-26 16:08:23.915901+00	
00000000-0000-0000-0000-000000000000	0b249bf5-71fd-410f-a01e-7e6a9f09315a	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-26 16:30:38.072597+00	
00000000-0000-0000-0000-000000000000	68088114-0543-4a71-bc5f-40ec8beb7349	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-26 16:35:17.084137+00	
00000000-0000-0000-0000-000000000000	129c5470-bae4-4a5d-bcf7-1a0ef89f193a	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-26 16:38:55.167648+00	
00000000-0000-0000-0000-000000000000	8312a87d-3673-441e-a180-7230c7d179b6	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-26 16:52:54.071155+00	
00000000-0000-0000-0000-000000000000	04958454-a5d1-4cdc-b66b-6cde402b044c	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-26 16:57:56.473576+00	
00000000-0000-0000-0000-000000000000	115d7695-e59a-4d2a-ae22-5b5fdfdf1c4b	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-26 17:08:34.033325+00	
00000000-0000-0000-0000-000000000000	be517e33-8285-47d1-bbc5-08e9adcb01e0	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-26 17:16:08.379253+00	
00000000-0000-0000-0000-000000000000	74dc2906-ffbb-4d16-bc0b-871c899188e4	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-26 17:18:55.915778+00	
00000000-0000-0000-0000-000000000000	54015f49-7f9e-4747-a936-258860cba5a5	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-26 17:21:44.478722+00	
00000000-0000-0000-0000-000000000000	2d265572-62d2-420a-a058-2e7f64f4247e	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-26 17:37:26.69415+00	
00000000-0000-0000-0000-000000000000	ef16d6fc-bb92-42f3-a07d-48720e470e3c	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-26 17:56:29.683964+00	
00000000-0000-0000-0000-000000000000	ab3f2eb2-4e43-4a6d-bcce-a8f809568ad2	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-26 18:15:48.282569+00	
00000000-0000-0000-0000-000000000000	53eba91a-5ce1-437e-ab2c-74def8f3e058	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-26 18:36:58.958925+00	
00000000-0000-0000-0000-000000000000	eae4d497-3a05-461f-8c73-b232adf225c3	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-26 18:39:56.011176+00	
00000000-0000-0000-0000-000000000000	e69432d1-125b-4763-b801-d44c2a325a70	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-26 18:46:40.033324+00	
00000000-0000-0000-0000-000000000000	411e0e0a-7f54-468c-824d-d4667ba4e81b	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-26 18:50:36.728224+00	
00000000-0000-0000-0000-000000000000	2247b2fd-b5d0-499a-abdd-5a128f499379	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-26 18:53:29.678086+00	
00000000-0000-0000-0000-000000000000	29fc8f12-cf47-476d-94b6-04d58bfd9579	{"action":"logout","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-05-26 18:55:55.554399+00	
00000000-0000-0000-0000-000000000000	f523de65-34ba-4ffc-896b-cadf50a04d6e	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-26 19:03:34.16242+00	
00000000-0000-0000-0000-000000000000	20903cad-7197-4f0e-8fde-40d8ba7c09f6	{"action":"logout","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-05-26 19:03:39.205837+00	
00000000-0000-0000-0000-000000000000	fbfc4bc4-670a-4cd6-8c6e-ddb696091628	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-26 19:05:08.197299+00	
00000000-0000-0000-0000-000000000000	9e6fd554-1796-454f-ad4f-a09ccaa15859	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-26 19:08:10.780663+00	
00000000-0000-0000-0000-000000000000	2316cee1-8b0f-486d-998c-e6805d9e7310	{"action":"logout","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-05-26 19:08:19.458303+00	
00000000-0000-0000-0000-000000000000	ccca0ac8-51a2-4472-91b1-777cb298f205	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-26 19:08:38.279022+00	
00000000-0000-0000-0000-000000000000	be43692a-6ccb-4957-9728-614d43a5e123	{"action":"logout","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-05-26 19:09:52.919257+00	
00000000-0000-0000-0000-000000000000	a7031aa1-dfc9-49de-972c-607d453126cc	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-26 19:09:55.043825+00	
00000000-0000-0000-0000-000000000000	bbabadad-5e65-491b-beca-ddf2a617cce0	{"action":"logout","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-05-26 19:09:56.727402+00	
00000000-0000-0000-0000-000000000000	7885f4ba-2f6d-48ee-999d-144323d28fa2	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-26 19:10:00.78108+00	
00000000-0000-0000-0000-000000000000	3c4d4ee2-bd1c-4a2e-bdb3-bc25866f6987	{"action":"logout","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-05-26 19:12:25.214579+00	
00000000-0000-0000-0000-000000000000	fd4da6bb-1d1a-4a07-b397-f76af109ddba	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-26 19:12:27.985509+00	
00000000-0000-0000-0000-000000000000	fcccb179-479f-4d1e-8256-8ee0af7eddaa	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-26 19:13:17.637118+00	
00000000-0000-0000-0000-000000000000	d30bc8d8-6c5a-4b4a-aa8f-7d928c5fc3eb	{"action":"logout","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-05-26 19:13:30.099231+00	
00000000-0000-0000-0000-000000000000	7e2edb1e-801d-4cbf-9af7-9bc05c47122b	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-26 20:19:21.783481+00	
00000000-0000-0000-0000-000000000000	d4d11626-1845-4bb3-8762-f405220e6de7	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-27 00:37:09.880986+00	
00000000-0000-0000-0000-000000000000	118c77b1-e220-402d-a8da-e1d34add3859	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-27 13:39:13.20148+00	
00000000-0000-0000-0000-000000000000	9d6c065d-383c-4937-8c60-5683f0bcaa22	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-27 13:39:13.215785+00	
00000000-0000-0000-0000-000000000000	10734388-b2ff-4900-ba70-06270cb8cdb2	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-27 21:14:32.856995+00	
00000000-0000-0000-0000-000000000000	0f996d37-3d28-41ba-b8c7-8c9981bb9086	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-27 21:14:32.859772+00	
00000000-0000-0000-0000-000000000000	de3434d1-31f5-41d2-b438-11dcde665385	{"action":"logout","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-05-27 21:14:34.769696+00	
00000000-0000-0000-0000-000000000000	1b0fbcca-bb86-45ff-9dc4-a1dfdb46e5e3	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-28 14:05:28.21902+00	
00000000-0000-0000-0000-000000000000	f17f2e2d-56c2-4e15-bb42-d7906ae3c11c	{"action":"logout","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-05-28 14:05:30.551547+00	
00000000-0000-0000-0000-000000000000	93c2af99-a69d-4e32-9a6c-02503bd7fdc7	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-28 15:35:51.960681+00	
00000000-0000-0000-0000-000000000000	1ec5e1e5-6756-4b09-9bf1-1938ee8a2937	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-28 15:42:10.707031+00	
00000000-0000-0000-0000-000000000000	1859c6c2-4474-477a-affc-b71dd77e0e43	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-28 15:46:28.974705+00	
00000000-0000-0000-0000-000000000000	99df64bc-4659-49c8-ac3e-3ae204be2eee	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-28 16:41:15.531848+00	
00000000-0000-0000-0000-000000000000	7b3b2859-2012-40ef-9697-172b5d4b908d	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-28 16:41:15.534707+00	
00000000-0000-0000-0000-000000000000	9a63a8e5-30fe-45d5-9374-3d7f2f0246aa	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-28 17:32:04.996411+00	
00000000-0000-0000-0000-000000000000	70820092-d3c0-468a-8da5-91736729a7f5	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-28 17:32:04.998478+00	
00000000-0000-0000-0000-000000000000	21bcaabb-7023-4bb0-846c-9a4e83f6dbc7	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-28 17:42:53.521405+00	
00000000-0000-0000-0000-000000000000	fb53b36a-400f-440c-bb26-88481fd9c2a9	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-28 17:42:53.526808+00	
00000000-0000-0000-0000-000000000000	a5a1087b-fc8e-4c94-ac2f-cf29146872de	{"action":"logout","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-05-28 18:17:57.852735+00	
00000000-0000-0000-0000-000000000000	37ed1b67-8567-414b-b595-f7ead6d09aab	{"action":"user_signedup","actor_id":"dfa7ac70-3f2d-47e5-86e4-49bba65a68b5","actor_name":"FanBass Support","actor_username":"support@fanbass.io","actor_via_sso":false,"log_type":"team","traits":{"provider":"google"}}	2025-05-28 18:18:03.752206+00	
00000000-0000-0000-0000-000000000000	034d3caf-3bb7-4f01-906b-20e7f3040d1b	{"action":"logout","actor_id":"dfa7ac70-3f2d-47e5-86e4-49bba65a68b5","actor_name":"FanBass Support","actor_username":"support@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-05-28 18:18:11.203541+00	
00000000-0000-0000-0000-000000000000	ebd14665-c769-4fbc-be10-fb1880e52d06	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-28 18:18:14.796862+00	
00000000-0000-0000-0000-000000000000	22a9dcd2-9b7e-4e4e-8c0b-eb3383923c20	{"action":"logout","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-05-28 18:50:38.507938+00	
00000000-0000-0000-0000-000000000000	df085301-7cd4-4ff4-a4a2-b9aa08405b69	{"action":"login","actor_id":"dfa7ac70-3f2d-47e5-86e4-49bba65a68b5","actor_name":"FanBass Support","actor_username":"support@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-28 18:50:42.378043+00	
00000000-0000-0000-0000-000000000000	2114181e-df66-405f-bcac-72acbb73e175	{"action":"logout","actor_id":"dfa7ac70-3f2d-47e5-86e4-49bba65a68b5","actor_name":"FanBass Support","actor_username":"support@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-05-28 18:50:53.661984+00	
00000000-0000-0000-0000-000000000000	68a57111-3503-498f-8f5e-30d3d14cd21a	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-28 18:52:36.782729+00	
00000000-0000-0000-0000-000000000000	785e3424-f8c7-461d-a812-bb174c76398e	{"action":"logout","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-05-28 18:52:59.787581+00	
00000000-0000-0000-0000-000000000000	6d0beb90-246c-4481-aaab-bcbb186f04af	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-28 18:53:08.82753+00	
00000000-0000-0000-0000-000000000000	92ca1672-e5a9-4442-962f-f8a507dc9de6	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-28 18:53:33.362038+00	
00000000-0000-0000-0000-000000000000	3749481d-eefe-4ec6-ace1-fe9b37cc74c8	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-28 21:00:41.274508+00	
00000000-0000-0000-0000-000000000000	0188665a-6745-4f15-81e4-f598d39b3567	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-28 21:00:41.280364+00	
00000000-0000-0000-0000-000000000000	6139f451-0f83-45ad-a882-872b61d80262	{"action":"logout","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-05-28 21:00:45.749396+00	
00000000-0000-0000-0000-000000000000	daf0dbf3-c029-4fb4-8e7c-950e7c5923c6	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-28 21:42:56.751685+00	
00000000-0000-0000-0000-000000000000	abf5d93a-5962-40ee-b12f-6dbc57498bb3	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-28 21:42:56.75529+00	
00000000-0000-0000-0000-000000000000	532c1739-0e32-4ecf-b1ea-60aa00137a68	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-28 21:43:12.483404+00	
00000000-0000-0000-0000-000000000000	e4fdc169-db0d-4468-89c9-5f739b520189	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-28 21:48:06.704363+00	
00000000-0000-0000-0000-000000000000	60bfce64-95fc-4313-b0fd-470937260279	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-28 22:45:52.658618+00	
00000000-0000-0000-0000-000000000000	7f7c225e-c058-4870-967f-91377d99a4dd	{"action":"logout","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-05-28 22:45:57.699062+00	
00000000-0000-0000-0000-000000000000	0ee9509b-2cf6-4c46-b6a9-ff73b49f5c5f	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-28 22:46:01.398601+00	
00000000-0000-0000-0000-000000000000	78c44ba4-d019-41ce-a258-442ebb4dc6c3	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 00:00:05.122101+00	
00000000-0000-0000-0000-000000000000	c782afb6-323b-4066-a3ac-17b5576939be	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 00:00:05.124099+00	
00000000-0000-0000-0000-000000000000	1864ff67-2022-4f98-b870-2443a12ff2b0	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-29 01:22:04.946744+00	
00000000-0000-0000-0000-000000000000	4b96ee3a-bdf4-4e43-909e-99e61da73baf	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 02:24:13.245233+00	
00000000-0000-0000-0000-000000000000	23d3533d-67de-49a1-ba06-b80ada17e919	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 02:24:13.246687+00	
00000000-0000-0000-0000-000000000000	72719739-32ab-4392-8eca-0253fa55c0c5	{"action":"logout","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-05-29 02:24:24.535036+00	
00000000-0000-0000-0000-000000000000	0b9206a6-e8e5-467e-8d27-e227d600de49	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-29 02:24:49.329567+00	
00000000-0000-0000-0000-000000000000	bcc29469-0880-49e5-b8a2-f5d60d6bc1f5	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-29 02:25:43.969006+00	
00000000-0000-0000-0000-000000000000	b5e7c412-e32f-46de-85c8-0592182ec201	{"action":"user_signedup","actor_id":"7f2169d3-894f-484f-bf65-8be242c8cd24","actor_name":"Aiden St. Clair-Dean","actor_username":"echo2149@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"google"}}	2025-05-29 02:26:02.914172+00	
00000000-0000-0000-0000-000000000000	cf259c03-9f65-4b7b-a8bd-dac6d1a54367	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-29 02:29:15.115472+00	
00000000-0000-0000-0000-000000000000	e885be5c-0426-4546-9dde-f43cbdff2d3f	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-29 02:29:15.121504+00	
00000000-0000-0000-0000-000000000000	e8f789da-a582-4d21-a9ff-988667b2fb62	{"action":"user_signedup","actor_id":"06082977-180b-4170-a3d5-72f7005652a9","actor_name":"Noah Forman","actor_username":"noahjforman@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"google"}}	2025-05-29 02:50:54.968266+00	
00000000-0000-0000-0000-000000000000	61816309-83e5-4a43-9610-d8df1be94943	{"action":"token_refreshed","actor_id":"7f2169d3-894f-484f-bf65-8be242c8cd24","actor_name":"Aiden St. Clair-Dean","actor_username":"echo2149@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 03:52:09.856243+00	
00000000-0000-0000-0000-000000000000	316be1fb-52be-4574-9532-d44591fd75f2	{"action":"token_revoked","actor_id":"7f2169d3-894f-484f-bf65-8be242c8cd24","actor_name":"Aiden St. Clair-Dean","actor_username":"echo2149@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 03:52:09.858775+00	
00000000-0000-0000-0000-000000000000	2d115da0-5252-428b-baba-7cb9c61dc589	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 04:08:31.441834+00	
00000000-0000-0000-0000-000000000000	21824c6d-a707-42c0-86de-69f23823d017	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 04:08:31.443915+00	
00000000-0000-0000-0000-000000000000	676d34cb-411b-442c-af4e-2fc3b43b4e3a	{"action":"token_refreshed","actor_id":"7f2169d3-894f-484f-bf65-8be242c8cd24","actor_name":"Aiden St. Clair-Dean","actor_username":"echo2149@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 05:08:01.95433+00	
00000000-0000-0000-0000-000000000000	1e67e9c1-60dc-4e20-ab1a-dc8512f0c955	{"action":"token_revoked","actor_id":"7f2169d3-894f-484f-bf65-8be242c8cd24","actor_name":"Aiden St. Clair-Dean","actor_username":"echo2149@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 05:08:01.956077+00	
00000000-0000-0000-0000-000000000000	d8442dd0-7122-42fc-8d6d-36a6121ff844	{"action":"token_refreshed","actor_id":"7f2169d3-894f-484f-bf65-8be242c8cd24","actor_name":"Aiden St. Clair-Dean","actor_username":"echo2149@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 06:19:24.229701+00	
00000000-0000-0000-0000-000000000000	58581559-e7a8-455f-aa80-3f50f86c18d6	{"action":"token_revoked","actor_id":"7f2169d3-894f-484f-bf65-8be242c8cd24","actor_name":"Aiden St. Clair-Dean","actor_username":"echo2149@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 06:19:24.246132+00	
00000000-0000-0000-0000-000000000000	5c33bee9-ec19-494a-87a3-2aca63a9890d	{"action":"token_refreshed","actor_id":"7f2169d3-894f-484f-bf65-8be242c8cd24","actor_name":"Aiden St. Clair-Dean","actor_username":"echo2149@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 08:39:25.335453+00	
00000000-0000-0000-0000-000000000000	4b5ee20e-08e7-4b31-81d4-2550273299a4	{"action":"token_revoked","actor_id":"7f2169d3-894f-484f-bf65-8be242c8cd24","actor_name":"Aiden St. Clair-Dean","actor_username":"echo2149@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 08:39:25.338831+00	
00000000-0000-0000-0000-000000000000	d247f85f-be74-417b-beca-26f356ba21dc	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-29 13:08:00.888828+00	
00000000-0000-0000-0000-000000000000	65feffa6-956e-46e0-b8d0-5dc5a2f011cb	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-29 13:08:00.89667+00	
00000000-0000-0000-0000-000000000000	6120e8ea-c2b4-41a0-a481-149a663c9ee6	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-29 13:08:02.618013+00	
00000000-0000-0000-0000-000000000000	78fb225b-b85f-4708-999b-a4f19b27cfc5	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-29 13:08:02.619236+00	
00000000-0000-0000-0000-000000000000	445f62ea-5292-4573-aa0d-14a4173b8893	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 14:02:35.592879+00	
00000000-0000-0000-0000-000000000000	c1a24c01-224a-4fc9-beb5-f12b8a22af2e	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 14:02:35.597762+00	
00000000-0000-0000-0000-000000000000	a2956a09-deb3-47dc-b395-f02101409a5f	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-29 14:11:08.911295+00	
00000000-0000-0000-0000-000000000000	9a8d6938-58f2-4da9-a45a-245af2ec7140	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-29 14:11:08.91406+00	
00000000-0000-0000-0000-000000000000	42a83e2b-2f72-4c87-9964-d95a010a5ec8	{"action":"logout","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-05-29 14:41:57.701929+00	
00000000-0000-0000-0000-000000000000	111e7007-8f70-4e4b-abb9-377db9adfc41	{"action":"login","actor_id":"dfa7ac70-3f2d-47e5-86e4-49bba65a68b5","actor_name":"FanBass Support","actor_username":"support@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-29 14:42:02.510506+00	
00000000-0000-0000-0000-000000000000	a580b48a-b2d6-4540-925f-534201be455d	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 14:51:00.128385+00	
00000000-0000-0000-0000-000000000000	a285a7ef-e779-4ae1-9c26-bedf02972f02	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 14:51:00.130902+00	
00000000-0000-0000-0000-000000000000	55070679-9974-4f6b-b187-e88e870743b2	{"action":"logout","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-05-29 14:51:39.531676+00	
00000000-0000-0000-0000-000000000000	a4531ee4-910c-4754-95cf-5ab9a4cb6855	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-29 14:51:44.454325+00	
00000000-0000-0000-0000-000000000000	a154fd43-7007-4c81-bdf2-0c3a8addbf9b	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-29 14:52:39.771651+00	
00000000-0000-0000-0000-000000000000	b25e2483-110e-4d2c-959a-7093eb247c3b	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-29 15:17:29.598634+00	
00000000-0000-0000-0000-000000000000	59daa2f6-07be-4370-82ae-b56d3650f1e3	{"action":"user_signedup","actor_id":"1988ae88-45c3-4529-929f-24fe6ed0b93b","actor_name":"Alec Hugh","actor_username":"acehugh@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"google"}}	2025-05-29 15:59:38.463557+00	
00000000-0000-0000-0000-000000000000	a0511d23-11f7-458f-beed-c677d9eecc21	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 16:33:45.548157+00	
00000000-0000-0000-0000-000000000000	f14a8431-e5a0-4b4e-adf1-2a239afd8609	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 16:33:45.551865+00	
00000000-0000-0000-0000-000000000000	f2f70a21-49a5-49c5-ac8a-7b8777888221	{"action":"user_signedup","actor_id":"82f7f043-f150-4052-82a7-d98c4c31237c","actor_name":"Eli Verschleiser","actor_username":"eli.v@eliv.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"google"}}	2025-05-29 17:21:27.961633+00	
00000000-0000-0000-0000-000000000000	5f45c735-34f9-4bb1-a6bc-255123f14ca9	{"action":"token_refreshed","actor_id":"82f7f043-f150-4052-82a7-d98c4c31237c","actor_name":"Eli Verschleiser","actor_username":"eli.v@eliv.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 19:40:26.404189+00	
00000000-0000-0000-0000-000000000000	581dec2e-6803-4f11-9f72-222aaf975beb	{"action":"token_revoked","actor_id":"82f7f043-f150-4052-82a7-d98c4c31237c","actor_name":"Eli Verschleiser","actor_username":"eli.v@eliv.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 19:40:26.407594+00	
00000000-0000-0000-0000-000000000000	1afe353b-46ff-4f33-8e58-2875ed44a174	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 19:56:04.838161+00	
00000000-0000-0000-0000-000000000000	5b3770ab-4af9-4f36-a706-94972757d9df	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 19:56:04.842011+00	
00000000-0000-0000-0000-000000000000	9e10bd9f-d1d6-4e1d-8786-f95312b57f30	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 21:23:49.33955+00	
00000000-0000-0000-0000-000000000000	19113ade-730f-41ab-8f98-902200dcc80d	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 21:23:49.342426+00	
00000000-0000-0000-0000-000000000000	5c0b0870-1a44-4c4e-85fc-8f7863f7f47f	{"action":"token_refreshed","actor_id":"7f2169d3-894f-484f-bf65-8be242c8cd24","actor_name":"Aiden St. Clair-Dean","actor_username":"echo2149@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 21:42:55.323632+00	
00000000-0000-0000-0000-000000000000	ad28d103-0dc8-41cd-92b0-9a7b85bebf9f	{"action":"token_revoked","actor_id":"7f2169d3-894f-484f-bf65-8be242c8cd24","actor_name":"Aiden St. Clair-Dean","actor_username":"echo2149@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 21:42:55.326918+00	
00000000-0000-0000-0000-000000000000	6d4e9f40-f492-4e88-8598-eb9c953376a3	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 23:03:43.417987+00	
00000000-0000-0000-0000-000000000000	45a41fe7-a34f-4d5d-9866-50938f5b5b2e	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 23:03:43.421357+00	
00000000-0000-0000-0000-000000000000	126f832c-9434-4423-ab95-a0c6143918c3	{"action":"token_refreshed","actor_id":"7f2169d3-894f-484f-bf65-8be242c8cd24","actor_name":"Aiden St. Clair-Dean","actor_username":"echo2149@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 23:08:36.255079+00	
00000000-0000-0000-0000-000000000000	51befd94-87a5-4f63-9638-c357a7bd95b5	{"action":"token_revoked","actor_id":"7f2169d3-894f-484f-bf65-8be242c8cd24","actor_name":"Aiden St. Clair-Dean","actor_username":"echo2149@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-29 23:08:36.257654+00	
00000000-0000-0000-0000-000000000000	a3009ae4-0f1a-43fc-b2a6-11bc5b1d045f	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 00:40:55.602161+00	
00000000-0000-0000-0000-000000000000	f3f179c7-09b1-4179-9e16-917f52fbcfa3	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 00:40:55.605319+00	
00000000-0000-0000-0000-000000000000	c8988f17-44e9-48d8-b688-689dbe2e1ab2	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 02:44:03.063757+00	
00000000-0000-0000-0000-000000000000	b8c2e4df-62da-4a48-aa68-bd6443aa9521	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 02:44:03.080968+00	
00000000-0000-0000-0000-000000000000	9e3e383f-4652-4e3e-902f-9f502029ae46	{"action":"token_refreshed","actor_id":"7f2169d3-894f-484f-bf65-8be242c8cd24","actor_name":"Aiden St. Clair-Dean","actor_username":"echo2149@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 03:44:08.659945+00	
00000000-0000-0000-0000-000000000000	db7593c1-7e96-492b-ac95-e4d9d723b24f	{"action":"token_revoked","actor_id":"7f2169d3-894f-484f-bf65-8be242c8cd24","actor_name":"Aiden St. Clair-Dean","actor_username":"echo2149@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 03:44:08.662603+00	
00000000-0000-0000-0000-000000000000	26512cf0-dcec-4a92-b4c2-c870f7da74ba	{"action":"token_refreshed","actor_id":"7f2169d3-894f-484f-bf65-8be242c8cd24","actor_name":"Aiden St. Clair-Dean","actor_username":"echo2149@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 04:54:39.261102+00	
00000000-0000-0000-0000-000000000000	f0a12c50-7270-48a2-b1e4-2156276d4eec	{"action":"token_revoked","actor_id":"7f2169d3-894f-484f-bf65-8be242c8cd24","actor_name":"Aiden St. Clair-Dean","actor_username":"echo2149@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 04:54:39.264418+00	
00000000-0000-0000-0000-000000000000	4d85f3eb-d738-4d69-8140-72f5ae90a1c3	{"action":"token_refreshed","actor_id":"7f2169d3-894f-484f-bf65-8be242c8cd24","actor_name":"Aiden St. Clair-Dean","actor_username":"echo2149@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 09:00:58.162055+00	
00000000-0000-0000-0000-000000000000	18d3bd84-a7d3-40f4-a016-dd685bca2ace	{"action":"token_revoked","actor_id":"7f2169d3-894f-484f-bf65-8be242c8cd24","actor_name":"Aiden St. Clair-Dean","actor_username":"echo2149@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 09:00:58.165031+00	
00000000-0000-0000-0000-000000000000	8258d649-6c83-4d99-85b2-99063ebf9c44	{"action":"user_signedup","actor_id":"b0b0ed7d-538a-4b52-bc1c-f5410677612c","actor_name":"Jonathan Privett","actor_username":"jonathanjamesprivett@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"google"}}	2025-05-30 09:05:38.96566+00	
00000000-0000-0000-0000-000000000000	91038236-0a2c-40ce-b7aa-08228608dc4e	{"action":"token_refreshed","actor_id":"06082977-180b-4170-a3d5-72f7005652a9","actor_name":"Noah Forman","actor_username":"noahjforman@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 09:35:08.516009+00	
00000000-0000-0000-0000-000000000000	f68afc93-d7dd-4229-a0b6-0fccdc6cd7b3	{"action":"token_revoked","actor_id":"06082977-180b-4170-a3d5-72f7005652a9","actor_name":"Noah Forman","actor_username":"noahjforman@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 09:35:08.518829+00	
00000000-0000-0000-0000-000000000000	fa8ad148-2cef-49e1-85c0-515fff36a6ce	{"action":"token_refreshed","actor_id":"b0b0ed7d-538a-4b52-bc1c-f5410677612c","actor_name":"Jonathan Privett","actor_username":"jonathanjamesprivett@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 10:21:39.455533+00	
00000000-0000-0000-0000-000000000000	0e07294f-990d-4a0e-ad31-bf209f2d0f2a	{"action":"token_revoked","actor_id":"b0b0ed7d-538a-4b52-bc1c-f5410677612c","actor_name":"Jonathan Privett","actor_username":"jonathanjamesprivett@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 10:21:39.458189+00	
00000000-0000-0000-0000-000000000000	5a27695b-a2d9-4027-b2ff-e0cff5252740	{"action":"token_refreshed","actor_id":"7f2169d3-894f-484f-bf65-8be242c8cd24","actor_name":"Aiden St. Clair-Dean","actor_username":"echo2149@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 10:29:37.828036+00	
00000000-0000-0000-0000-000000000000	1c3794c8-7415-4d67-85d2-8b1fb4a126d6	{"action":"token_revoked","actor_id":"7f2169d3-894f-484f-bf65-8be242c8cd24","actor_name":"Aiden St. Clair-Dean","actor_username":"echo2149@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 10:29:37.830803+00	
00000000-0000-0000-0000-000000000000	d93c3464-a1ee-4744-a776-321569abfbfe	{"action":"token_refreshed","actor_id":"06082977-180b-4170-a3d5-72f7005652a9","actor_name":"Noah Forman","actor_username":"noahjforman@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 10:54:18.727115+00	
00000000-0000-0000-0000-000000000000	8c987cda-5ab2-4c4d-b0a3-91f7eb5e9e07	{"action":"token_revoked","actor_id":"06082977-180b-4170-a3d5-72f7005652a9","actor_name":"Noah Forman","actor_username":"noahjforman@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 10:54:18.730346+00	
00000000-0000-0000-0000-000000000000	fbbecf19-d079-4f4b-a063-5df27bb4cce2	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-30 12:28:07.960687+00	
00000000-0000-0000-0000-000000000000	0181ebfb-0541-4116-be66-ea8c8890c4c3	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-30 12:28:07.9628+00	
00000000-0000-0000-0000-000000000000	e56a3e9b-8b4a-4ea6-bab3-1b110e28ac1f	{"action":"token_refreshed","actor_id":"dfa7ac70-3f2d-47e5-86e4-49bba65a68b5","actor_name":"FanBass Support","actor_username":"support@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-30 12:28:44.737745+00	
00000000-0000-0000-0000-000000000000	5de2452c-6ea2-4e35-97d9-5e26a0b3b6bb	{"action":"token_revoked","actor_id":"dfa7ac70-3f2d-47e5-86e4-49bba65a68b5","actor_name":"FanBass Support","actor_username":"support@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-30 12:28:44.738306+00	
00000000-0000-0000-0000-000000000000	e6fe9e1e-d0ac-4c0d-9fce-184918684133	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 12:39:24.660821+00	
00000000-0000-0000-0000-000000000000	d950a5ae-2ea6-4a8c-a425-dcdbadb90962	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 12:39:24.663345+00	
00000000-0000-0000-0000-000000000000	8e569c1e-3fa9-4a65-862c-34ba64c3123f	{"action":"logout","actor_id":"dfa7ac70-3f2d-47e5-86e4-49bba65a68b5","actor_name":"FanBass Support","actor_username":"support@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-05-30 12:48:54.675705+00	
00000000-0000-0000-0000-000000000000	820e50ee-730f-4748-ae61-9948344d7fd4	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-30 12:48:59.498238+00	
00000000-0000-0000-0000-000000000000	d30509a4-1475-45ac-88f2-30d6f45b8965	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 12:51:12.584623+00	
00000000-0000-0000-0000-000000000000	00af1b6f-7d6e-46b8-839d-3da3e58a4980	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 12:51:12.586644+00	
00000000-0000-0000-0000-000000000000	da79e594-4b7e-4a1b-abd6-eced656e8459	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-30 13:32:55.71706+00	
00000000-0000-0000-0000-000000000000	efb0d680-0907-43d5-a6f4-361d23ee69af	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-30 13:32:55.7276+00	
00000000-0000-0000-0000-000000000000	cd1fabc9-f2be-493e-81fd-7ff9c08cd626	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-30 13:49:10.317138+00	
00000000-0000-0000-0000-000000000000	3b9dc992-9af4-4972-ad7d-1ccea3cfe2f7	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-30 13:49:10.319337+00	
00000000-0000-0000-0000-000000000000	5fb132b5-b248-4b01-b9ce-7908fcd3a7c1	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 14:13:15.704414+00	
00000000-0000-0000-0000-000000000000	d308ae1b-1c61-45a6-93df-e99811c7d072	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 14:13:15.705201+00	
00000000-0000-0000-0000-000000000000	b5ef4823-af22-422b-827f-9be7899459e7	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-30 14:49:36.401827+00	
00000000-0000-0000-0000-000000000000	30b99a2d-66b7-4b29-b66e-b86633d34028	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-30 14:49:36.405133+00	
00000000-0000-0000-0000-000000000000	11f453bb-1dba-4909-973a-8553173ef783	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 15:13:52.029094+00	
00000000-0000-0000-0000-000000000000	d08fd74a-0a65-4095-8d85-30409010c727	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 15:13:52.033328+00	
00000000-0000-0000-0000-000000000000	0ec58d30-7d20-4bee-aa5c-b6617765eb67	{"action":"token_refreshed","actor_id":"7f2169d3-894f-484f-bf65-8be242c8cd24","actor_name":"Aiden St. Clair-Dean","actor_username":"echo2149@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 17:21:05.911188+00	
00000000-0000-0000-0000-000000000000	da36bc5a-e7c6-4ddf-98a1-adcde4a8d7c0	{"action":"token_revoked","actor_id":"7f2169d3-894f-484f-bf65-8be242c8cd24","actor_name":"Aiden St. Clair-Dean","actor_username":"echo2149@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 17:21:05.913217+00	
00000000-0000-0000-0000-000000000000	7df91224-6dc7-4f2a-84f9-55a416cfdf02	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 19:11:08.478383+00	
00000000-0000-0000-0000-000000000000	ef8f6795-6356-48ad-97df-daafce84c528	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 19:11:08.481037+00	
00000000-0000-0000-0000-000000000000	554e9bc9-7f47-46d6-b407-fa2bc821347b	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-30 19:14:49.735959+00	
00000000-0000-0000-0000-000000000000	f0f0bff3-7a82-46f4-b737-466181dab1ed	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-30 19:14:49.73917+00	
00000000-0000-0000-0000-000000000000	6d5be529-523b-497f-96ce-79173e341eb3	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 22:10:54.653803+00	
00000000-0000-0000-0000-000000000000	084cc89e-8c4e-4539-b539-0a13e3192490	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 22:10:54.663856+00	
00000000-0000-0000-0000-000000000000	d01ae96f-d44b-4ef0-babe-b0b76c818c75	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 23:30:39.85751+00	
00000000-0000-0000-0000-000000000000	2413aa6b-98c8-48c8-864e-48173bda4f09	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-30 23:30:39.860365+00	
00000000-0000-0000-0000-000000000000	26a96648-8fd1-46cb-9a2b-4c8512d7a184	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 00:22:22.850873+00	
00000000-0000-0000-0000-000000000000	411ba124-ec47-4706-8193-b8c69065ea65	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 00:22:22.852931+00	
00000000-0000-0000-0000-000000000000	e1855657-fca7-4077-aa7d-dfa4e9b11b68	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 00:22:22.873845+00	
00000000-0000-0000-0000-000000000000	5e7ec95c-032f-4a38-a94b-bf9a778640f0	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 00:22:22.874443+00	
00000000-0000-0000-0000-000000000000	5b16626a-6455-4ad8-b79b-827fb96403a1	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 01:17:28.030237+00	
00000000-0000-0000-0000-000000000000	d59ed83b-7136-4447-b5b7-aa3b2c2ad296	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 01:17:28.033578+00	
00000000-0000-0000-0000-000000000000	b571cd1d-ec45-4d01-bc77-9dfc7490d849	{"action":"token_refreshed","actor_id":"06082977-180b-4170-a3d5-72f7005652a9","actor_name":"Noah Forman","actor_username":"noahjforman@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 01:26:58.36592+00	
00000000-0000-0000-0000-000000000000	50e2b0bb-1438-45c4-9a27-3fef7ef98e82	{"action":"token_revoked","actor_id":"06082977-180b-4170-a3d5-72f7005652a9","actor_name":"Noah Forman","actor_username":"noahjforman@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 01:26:58.3681+00	
00000000-0000-0000-0000-000000000000	59b12913-e1a6-4482-8695-63ed62fa6081	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 01:43:02.218413+00	
00000000-0000-0000-0000-000000000000	713b2d09-cbcd-49af-b2d2-9e19091846ec	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 01:43:02.220645+00	
00000000-0000-0000-0000-000000000000	d0a667c3-e908-4136-8a21-6ee22e307d09	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 02:43:21.449597+00	
00000000-0000-0000-0000-000000000000	98bf3609-44fd-4dca-bc9e-c0fb36411a36	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 02:43:21.451668+00	
00000000-0000-0000-0000-000000000000	b74cf5cd-d7bb-48df-b393-dd3968e9d20a	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 04:44:01.83779+00	
00000000-0000-0000-0000-000000000000	ecbca108-69c5-4cc5-94c1-0f44419eaa53	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 04:44:01.838601+00	
00000000-0000-0000-0000-000000000000	2bd34780-b768-441e-a0ae-7c539a0eda04	{"action":"user_signedup","actor_id":"c3866d1b-210f-490a-b300-bde91941735b","actor_name":"Ariel Lasry","actor_username":"ariel@fanbass.io","actor_via_sso":false,"log_type":"team","traits":{"provider":"google"}}	2025-05-31 04:44:34.277856+00	
00000000-0000-0000-0000-000000000000	581257d0-99d6-4c9b-b19f-fa7e759bd05d	{"action":"token_refreshed","actor_id":"c3866d1b-210f-490a-b300-bde91941735b","actor_name":"Ariel Lasry","actor_username":"ariel@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 05:42:58.961859+00	
00000000-0000-0000-0000-000000000000	7412c7a5-3d81-4b8f-8ce8-3f2e71634231	{"action":"token_revoked","actor_id":"c3866d1b-210f-490a-b300-bde91941735b","actor_name":"Ariel Lasry","actor_username":"ariel@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 05:42:58.96417+00	
00000000-0000-0000-0000-000000000000	79bc6849-24ec-4735-b4a8-8b5e7c7a6908	{"action":"token_refreshed","actor_id":"06082977-180b-4170-a3d5-72f7005652a9","actor_name":"Noah Forman","actor_username":"noahjforman@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 08:26:58.846892+00	
00000000-0000-0000-0000-000000000000	272d8853-51b8-48a5-9fc7-bb847c7a350c	{"action":"token_revoked","actor_id":"06082977-180b-4170-a3d5-72f7005652a9","actor_name":"Noah Forman","actor_username":"noahjforman@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 08:26:58.858777+00	
00000000-0000-0000-0000-000000000000	8c78776c-6b61-43e5-bd3c-8e9b00de312a	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 10:03:51.820484+00	
00000000-0000-0000-0000-000000000000	50d2ca5e-d7d2-48ae-aa80-5cfabedec088	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 10:03:51.822578+00	
00000000-0000-0000-0000-000000000000	4604fbe5-0054-4cd7-b04f-0da28cc7cdaf	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 11:02:15.799311+00	
00000000-0000-0000-0000-000000000000	79adb9e3-4de6-481b-9e8c-90b016d56330	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 11:02:15.801417+00	
00000000-0000-0000-0000-000000000000	82a6a570-9d0b-486c-acb4-161d516a37c2	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-31 11:21:16.765803+00	
00000000-0000-0000-0000-000000000000	07c5304f-13d5-44ac-918f-5de3b4758af3	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 12:00:41.363956+00	
00000000-0000-0000-0000-000000000000	fc16a072-a536-453b-9b33-375f0439e542	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 12:00:41.3669+00	
00000000-0000-0000-0000-000000000000	3fa58449-defc-4dde-8f0c-dc6475e00fec	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 12:25:09.627651+00	
00000000-0000-0000-0000-000000000000	4724ef37-0ef6-484b-aa60-df8727056721	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 12:25:09.630193+00	
00000000-0000-0000-0000-000000000000	a2a02204-5bd7-432d-a77a-9a5bd9b7cae8	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 12:29:34.103488+00	
00000000-0000-0000-0000-000000000000	860b4043-aa59-4b5b-84aa-f6040b5f12f8	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 12:29:34.105629+00	
00000000-0000-0000-0000-000000000000	9d1fa2ea-e48c-4492-a777-326449fe3254	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 12:59:13.482256+00	
00000000-0000-0000-0000-000000000000	2bde893d-39f1-4e49-93fe-168d2c81016c	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 12:59:13.485446+00	
00000000-0000-0000-0000-000000000000	d669f8fb-0232-4fcc-b26d-2ac521777d34	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 13:23:41.485661+00	
00000000-0000-0000-0000-000000000000	8c52adf5-844d-4f62-88b7-0bbe42b53552	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 13:23:41.487842+00	
00000000-0000-0000-0000-000000000000	5bd8cd4d-6b54-44fb-80cc-6627032f6ca3	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 14:00:45.334783+00	
00000000-0000-0000-0000-000000000000	4606dc83-f616-41a3-92f0-e794b5f48eba	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 14:00:45.340541+00	
00000000-0000-0000-0000-000000000000	16af13d3-eb71-4f34-b787-3500a09415f6	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 14:22:13.578344+00	
00000000-0000-0000-0000-000000000000	c42c0d3b-1a81-47a8-9e20-bb6e3a85dc4e	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 14:22:13.582522+00	
00000000-0000-0000-0000-000000000000	644cd0b0-ec6a-4096-a50e-5c03efbfa5a9	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 14:57:27.419047+00	
00000000-0000-0000-0000-000000000000	350722e5-4947-45d6-bc9a-785a9de6aea5	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 14:57:27.421629+00	
00000000-0000-0000-0000-000000000000	7873e50a-6fe3-4cf1-a385-17eee79382de	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 14:58:49.596345+00	
00000000-0000-0000-0000-000000000000	89cd7c54-411f-4548-be84-4bc4a10a2860	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 14:58:49.59689+00	
00000000-0000-0000-0000-000000000000	78e2bc54-c730-44ee-b241-de2b5d924df9	{"action":"logout","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-05-31 14:59:08.91543+00	
00000000-0000-0000-0000-000000000000	94e3372b-447c-4d3a-a4b9-dde905cd835b	{"action":"login","actor_id":"dfa7ac70-3f2d-47e5-86e4-49bba65a68b5","actor_name":"FanBass Support","actor_username":"support@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-31 14:59:38.937832+00	
00000000-0000-0000-0000-000000000000	e784d518-9303-460d-89c6-ff982c7ba1a5	{"action":"logout","actor_id":"dfa7ac70-3f2d-47e5-86e4-49bba65a68b5","actor_name":"FanBass Support","actor_username":"support@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-05-31 15:01:46.491794+00	
00000000-0000-0000-0000-000000000000	50668fd6-9498-4b64-a919-d132eea37675	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-31 15:01:51.118925+00	
00000000-0000-0000-0000-000000000000	1b2e9146-7d03-4f40-937c-7f6c30c55ea4	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 16:21:54.361514+00	
00000000-0000-0000-0000-000000000000	bbc5a5b7-6f79-48c6-b45e-d740d11a7614	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 16:21:54.37778+00	
00000000-0000-0000-0000-000000000000	c7cab6b5-ca32-4f24-958b-493730e0e810	{"action":"logout","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-05-31 16:42:48.316179+00	
00000000-0000-0000-0000-000000000000	b1effa8d-c545-4bbc-91b4-1e9f8242d087	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-31 16:43:10.315039+00	
00000000-0000-0000-0000-000000000000	e4769f00-87e6-460a-b79e-f4bb7e2e54c2	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 17:31:54.297146+00	
00000000-0000-0000-0000-000000000000	b5bfb473-cb1a-4a3a-bd0e-546735192772	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 17:31:54.299589+00	
00000000-0000-0000-0000-000000000000	9b07b907-5bce-4d08-9228-0c4b00bd91d4	{"action":"logout","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-05-31 17:37:31.734867+00	
00000000-0000-0000-0000-000000000000	2eb2a550-c9f0-4561-b30d-a5b8e620fca6	{"action":"login","actor_id":"dfa7ac70-3f2d-47e5-86e4-49bba65a68b5","actor_name":"FanBass Support","actor_username":"support@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-31 17:37:36.779333+00	
00000000-0000-0000-0000-000000000000	83426a64-ab7b-4fe5-b481-9a17dfb92ca2	{"action":"logout","actor_id":"dfa7ac70-3f2d-47e5-86e4-49bba65a68b5","actor_name":"FanBass Support","actor_username":"support@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-05-31 17:50:09.213991+00	
00000000-0000-0000-0000-000000000000	31607e25-d5a8-4249-8681-4c10d3da5979	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-31 17:50:13.783703+00	
00000000-0000-0000-0000-000000000000	974c2a67-b461-4b80-bfc9-a454cf65dd35	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 18:38:43.384914+00	
00000000-0000-0000-0000-000000000000	03f79c56-1084-4e07-b4f5-0d38b0d8e9a8	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 18:38:43.389783+00	
00000000-0000-0000-0000-000000000000	a3012604-e2c8-481d-a349-aa60bb328604	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 18:48:35.457684+00	
00000000-0000-0000-0000-000000000000	a08136dc-0c5b-401f-8b50-cd5c9b8a2dc3	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 18:48:35.459733+00	
00000000-0000-0000-0000-000000000000	e5187912-4f3c-4ee6-b752-aaef65b5a3e9	{"action":"token_refreshed","actor_id":"b0b0ed7d-538a-4b52-bc1c-f5410677612c","actor_name":"Jonathan Privett","actor_username":"jonathanjamesprivett@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 18:52:49.899279+00	
00000000-0000-0000-0000-000000000000	04a7c9b0-79f6-46fc-b603-9f8364790dff	{"action":"token_revoked","actor_id":"b0b0ed7d-538a-4b52-bc1c-f5410677612c","actor_name":"Jonathan Privett","actor_username":"jonathanjamesprivett@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 18:52:49.901492+00	
00000000-0000-0000-0000-000000000000	a7fc29f5-429b-48a9-a75e-8800cc9239cb	{"action":"token_refreshed","actor_id":"06082977-180b-4170-a3d5-72f7005652a9","actor_name":"Noah Forman","actor_username":"noahjforman@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 18:53:38.781606+00	
00000000-0000-0000-0000-000000000000	4c74cb90-b976-408e-b1c8-b7051184815a	{"action":"token_revoked","actor_id":"06082977-180b-4170-a3d5-72f7005652a9","actor_name":"Noah Forman","actor_username":"noahjforman@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 18:53:38.782169+00	
00000000-0000-0000-0000-000000000000	2c3ced38-3819-4fcd-9331-beccae9feb53	{"action":"logout","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-05-31 18:55:49.426218+00	
00000000-0000-0000-0000-000000000000	6e42d135-af71-4cad-b162-62ddf22eb39a	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 19:47:33.775293+00	
00000000-0000-0000-0000-000000000000	00788810-4486-4273-bf92-c9e1b76d5152	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 19:47:33.778386+00	
00000000-0000-0000-0000-000000000000	25774eb8-2f76-4c79-8b87-92a9a172bc0d	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-31 20:10:00.625144+00	
00000000-0000-0000-0000-000000000000	d44aeddf-da0c-4f2c-a819-407c41b13124	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-31 20:10:04.674202+00	
00000000-0000-0000-0000-000000000000	a45f0aea-d671-46c7-ad25-00162a4cfa77	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-31 20:10:18.283275+00	
00000000-0000-0000-0000-000000000000	37240635-8520-4cfe-b7a7-4a048a8b3fbc	{"action":"login","actor_id":"c3866d1b-210f-490a-b300-bde91941735b","actor_name":"Ariel Lasry","actor_username":"ariel@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-31 20:10:23.786913+00	
00000000-0000-0000-0000-000000000000	108d6fad-4125-4b19-92b9-fc522528de11	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-31 20:10:37.593062+00	
00000000-0000-0000-0000-000000000000	927810fa-47e9-4d58-9b8e-61aeda15c9ac	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-31 20:10:53.395959+00	
00000000-0000-0000-0000-000000000000	a379faeb-b977-406c-ad32-486b679e4eda	{"action":"logout","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-05-31 20:11:16.085128+00	
00000000-0000-0000-0000-000000000000	9d9002d5-db6c-4818-b8b8-22765105781c	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-31 20:11:19.627015+00	
00000000-0000-0000-0000-000000000000	255bffc2-09fd-4311-bb94-d3a1ac6260b2	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-31 20:11:26.202907+00	
00000000-0000-0000-0000-000000000000	d2f59a70-f3ef-4a6f-aa4c-e35145d13ba6	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-31 20:11:30.676524+00	
00000000-0000-0000-0000-000000000000	5c93b564-6d1d-4b2a-9127-0ef4f1e90bd3	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-31 20:13:14.155635+00	
00000000-0000-0000-0000-000000000000	322606a9-f8cb-4c0d-91cc-85b9c3111735	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-05-31 20:13:35.162434+00	
00000000-0000-0000-0000-000000000000	8b9e3a13-061a-4780-8a1f-fba95a5d7d76	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 21:35:15.132984+00	
00000000-0000-0000-0000-000000000000	1ef914b0-6180-40c8-942b-2b999d1bf073	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 21:35:15.137929+00	
00000000-0000-0000-0000-000000000000	1af4d1d6-7265-4c0f-a461-b2cc391e045b	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 21:48:00.301819+00	
00000000-0000-0000-0000-000000000000	9eb4e2ba-768c-4b31-afc7-65d55509ba0d	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 21:48:00.30444+00	
00000000-0000-0000-0000-000000000000	359440a7-31a6-407e-8995-322189984083	{"action":"token_refreshed","actor_id":"b0b0ed7d-538a-4b52-bc1c-f5410677612c","actor_name":"Jonathan Privett","actor_username":"jonathanjamesprivett@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 22:23:06.94562+00	
00000000-0000-0000-0000-000000000000	cd4b76aa-3dbe-40d1-be09-5180219f8176	{"action":"token_revoked","actor_id":"b0b0ed7d-538a-4b52-bc1c-f5410677612c","actor_name":"Jonathan Privett","actor_username":"jonathanjamesprivett@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 22:23:06.946462+00	
00000000-0000-0000-0000-000000000000	dcfe58b1-7d38-464e-ab8c-cd927628768c	{"action":"token_refreshed","actor_id":"06082977-180b-4170-a3d5-72f7005652a9","actor_name":"Noah Forman","actor_username":"noahjforman@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 22:26:35.523027+00	
00000000-0000-0000-0000-000000000000	217ed400-81e8-4358-a435-bb4f1ac04651	{"action":"token_revoked","actor_id":"06082977-180b-4170-a3d5-72f7005652a9","actor_name":"Noah Forman","actor_username":"noahjforman@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 22:26:35.525167+00	
00000000-0000-0000-0000-000000000000	f7504640-8883-4640-b17e-105d45915086	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 22:46:13.417763+00	
00000000-0000-0000-0000-000000000000	7eb22172-80e4-4094-b0ea-c1cf31750d93	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 22:46:13.419302+00	
00000000-0000-0000-0000-000000000000	e976b11a-0eae-48c1-933d-10d78ca23aa4	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 23:31:59.851689+00	
00000000-0000-0000-0000-000000000000	313e7f2f-6acc-4bbc-844f-dfbbde0877b9	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 23:31:59.8531+00	
00000000-0000-0000-0000-000000000000	5027b0c2-ca40-4006-8352-cc4248bf6df7	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 23:44:47.018668+00	
00000000-0000-0000-0000-000000000000	fce9e49d-3fad-4b5e-ab05-955ec6c1f1ad	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 23:44:47.02318+00	
00000000-0000-0000-0000-000000000000	0547c825-00d2-416d-ab30-a6650f2c3bd8	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 23:58:39.626114+00	
00000000-0000-0000-0000-000000000000	050c36bc-6dbf-4a7e-849c-b68102534d03	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-05-31 23:58:39.629158+00	
00000000-0000-0000-0000-000000000000	068b037b-142b-416c-a468-cefdde7cd57d	{"action":"token_refreshed","actor_id":"06082977-180b-4170-a3d5-72f7005652a9","actor_name":"Noah Forman","actor_username":"noahjforman@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 23:58:53.88773+00	
00000000-0000-0000-0000-000000000000	55a7d0ed-a258-4404-b29a-658f2eee24b0	{"action":"token_revoked","actor_id":"06082977-180b-4170-a3d5-72f7005652a9","actor_name":"Noah Forman","actor_username":"noahjforman@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-05-31 23:58:53.888266+00	
00000000-0000-0000-0000-000000000000	17a2bc64-f8db-4f7a-ba97-8befdcf2afba	{"action":"user_signedup","actor_id":"419646ee-1d59-4497-9fae-60b0eed36064","actor_name":"Caleb Forman","actor_username":"lightning0379@gmail.com","actor_via_sso":false,"log_type":"team","traits":{"provider":"google"}}	2025-06-01 00:00:41.71368+00	
00000000-0000-0000-0000-000000000000	a8ff3e42-e24f-40f5-a38b-92d12598794b	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-06-01 00:43:06.287742+00	
00000000-0000-0000-0000-000000000000	1ef71504-2a2b-409c-9f61-5bab261a583d	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-06-01 00:43:06.291186+00	
00000000-0000-0000-0000-000000000000	afcdfb82-0778-45d5-8072-04cf4c3056bf	{"action":"token_refreshed","actor_id":"06082977-180b-4170-a3d5-72f7005652a9","actor_name":"Noah Forman","actor_username":"noahjforman@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-01 00:59:11.318191+00	
00000000-0000-0000-0000-000000000000	f55c5ad8-28b7-4858-9ed5-8d486a0cf278	{"action":"token_revoked","actor_id":"06082977-180b-4170-a3d5-72f7005652a9","actor_name":"Noah Forman","actor_username":"noahjforman@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-01 00:59:11.319705+00	
00000000-0000-0000-0000-000000000000	dcd9c558-5900-4488-900d-a161cfc8c70a	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-01 01:21:24.275891+00	
00000000-0000-0000-0000-000000000000	2abe915d-ae66-4df4-a204-1e30a8229c4e	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-01 01:21:24.277964+00	
00000000-0000-0000-0000-000000000000	c91dfc35-0a69-4553-8c1f-8509d9854acc	{"action":"logout","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-06-01 01:33:27.990138+00	
00000000-0000-0000-0000-000000000000	9e38cb15-a4a9-4677-b65d-e63b999dcbda	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-06-01 01:33:32.091301+00	
00000000-0000-0000-0000-000000000000	68dfd541-2542-4c97-8235-592cb1ad54d2	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-06-01 01:33:36.257768+00	
00000000-0000-0000-0000-000000000000	a513578e-c746-496f-9c7d-d163374539b6	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-06-01 01:33:48.600508+00	
00000000-0000-0000-0000-000000000000	b4e38778-eb88-4cbe-b2a7-14ca86f3cf39	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-06-01 01:34:08.483693+00	
00000000-0000-0000-0000-000000000000	daeaa8c8-6007-43b3-b8bf-b940f293e590	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-06-01 01:34:23.958018+00	
00000000-0000-0000-0000-000000000000	ca512b65-7cf7-4d99-9d73-543e8cbf41a0	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-06-01 01:35:01.905109+00	
00000000-0000-0000-0000-000000000000	828813fa-fffd-498c-8947-4767051afff7	{"action":"logout","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account"}	2025-06-01 01:37:41.42637+00	
00000000-0000-0000-0000-000000000000	e8b1300a-592e-4d22-8899-03c7a0b60d0e	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-06-01 01:37:45.563395+00	
00000000-0000-0000-0000-000000000000	3198f361-44fa-463a-8691-4cb9fd40e6f3	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-06-01 01:41:12.318151+00	
00000000-0000-0000-0000-000000000000	513f25a2-0b02-4806-86f2-d11d3b263123	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-06-01 01:41:12.320586+00	
00000000-0000-0000-0000-000000000000	355583b6-9729-4a8b-96ba-1f68eccde40d	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-01 02:36:01.212815+00	
00000000-0000-0000-0000-000000000000	6e332d86-48d1-4dfa-abc1-d403075f3306	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-01 02:36:01.215739+00	
00000000-0000-0000-0000-000000000000	07d7c5c7-aaa2-4e4a-a66f-2ee0bc521d0d	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-06-01 02:45:21.371578+00	
00000000-0000-0000-0000-000000000000	21843e4d-0365-4aec-b940-df65c0fc9955	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-06-01 02:45:21.375837+00	
00000000-0000-0000-0000-000000000000	61fda4d1-a5a7-4425-947c-7267353ff4cb	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-01 03:34:31.244977+00	
00000000-0000-0000-0000-000000000000	58f73881-2f83-4d52-9645-f20fd9ea0242	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-01 03:34:31.247837+00	
00000000-0000-0000-0000-000000000000	f37a7d8b-8e75-4fa2-9ae5-fbb77aa4ffd5	{"action":"logout","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-06-01 03:39:23.445097+00	
00000000-0000-0000-0000-000000000000	9821ee99-dd95-4f6b-9d00-c415d3875a69	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-06-01 03:58:14.679549+00	
00000000-0000-0000-0000-000000000000	e7b9de00-3b9b-4561-a755-cd865e3fd758	{"action":"token_refreshed","actor_id":"06082977-180b-4170-a3d5-72f7005652a9","actor_name":"Noah Forman","actor_username":"noahjforman@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-01 03:58:24.812058+00	
00000000-0000-0000-0000-000000000000	9f9fc6fa-c386-4981-8b07-2ba795d28683	{"action":"token_revoked","actor_id":"06082977-180b-4170-a3d5-72f7005652a9","actor_name":"Noah Forman","actor_username":"noahjforman@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-01 03:58:24.812613+00	
00000000-0000-0000-0000-000000000000	9f767d65-6db2-47e3-8043-2a7e8b72aae8	{"action":"logout","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-06-01 03:58:26.619071+00	
00000000-0000-0000-0000-000000000000	464c9fdf-8bd9-4ded-b161-b43bdf6fc16a	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-06-01 04:06:47.398833+00	
00000000-0000-0000-0000-000000000000	ea0ad931-d118-4f37-ab12-246182a184b9	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-01 04:32:52.636613+00	
00000000-0000-0000-0000-000000000000	dfc606c8-7088-45ea-b47e-59a0f018a39f	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-01 04:32:52.639497+00	
00000000-0000-0000-0000-000000000000	84077d79-2361-4ec2-81eb-d9e3a46f490a	{"action":"logout","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-06-01 04:45:31.190509+00	
00000000-0000-0000-0000-000000000000	4942ca15-d8fa-47b1-b590-32e332cd5683	{"action":"login","actor_id":"dfa7ac70-3f2d-47e5-86e4-49bba65a68b5","actor_name":"FanBass Support","actor_username":"support@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-06-01 04:45:35.986414+00	
00000000-0000-0000-0000-000000000000	8fa4584a-e1fe-4811-b4b9-8647260896fc	{"action":"logout","actor_id":"dfa7ac70-3f2d-47e5-86e4-49bba65a68b5","actor_name":"FanBass Support","actor_username":"support@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-06-01 04:45:47.833405+00	
00000000-0000-0000-0000-000000000000	545ebea9-13f4-4973-a485-21956030ed1c	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-06-01 04:45:51.621477+00	
00000000-0000-0000-0000-000000000000	116d6c93-7d37-4101-9c34-7d3e976a506c	{"action":"logout","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-06-01 04:45:54.818629+00	
00000000-0000-0000-0000-000000000000	3eac0ce5-b358-4eb2-a6e0-04add6f6b765	{"action":"token_refreshed","actor_id":"06082977-180b-4170-a3d5-72f7005652a9","actor_name":"Noah Forman","actor_username":"noahjforman@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-01 05:15:49.024604+00	
00000000-0000-0000-0000-000000000000	16a0ad4c-4b82-40e9-9db9-41a1ac69e210	{"action":"token_revoked","actor_id":"06082977-180b-4170-a3d5-72f7005652a9","actor_name":"Noah Forman","actor_username":"noahjforman@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-01 05:15:49.025408+00	
00000000-0000-0000-0000-000000000000	0cc0da5e-a81c-4438-be76-e5ca54c8185e	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-01 05:31:46.335247+00	
00000000-0000-0000-0000-000000000000	1c1e8f43-dc0b-49c9-a80d-7182d100ac97	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-01 05:31:46.338477+00	
00000000-0000-0000-0000-000000000000	f2f5eb00-b23b-4474-9f18-c80f978521a8	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-01 06:53:42.391951+00	
00000000-0000-0000-0000-000000000000	052eaaeb-1e87-489c-9d74-fa6b74944d08	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-01 06:53:42.399585+00	
00000000-0000-0000-0000-000000000000	77fe9b57-e757-4aac-b3e2-fd10f06cf544	{"action":"token_refreshed","actor_id":"06082977-180b-4170-a3d5-72f7005652a9","actor_name":"Noah Forman","actor_username":"noahjforman@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-01 07:36:50.071177+00	
00000000-0000-0000-0000-000000000000	d48f75d1-b872-4ec3-84fe-f0d80ec1b274	{"action":"token_revoked","actor_id":"06082977-180b-4170-a3d5-72f7005652a9","actor_name":"Noah Forman","actor_username":"noahjforman@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-01 07:36:50.074002+00	
00000000-0000-0000-0000-000000000000	6dd28b81-5219-4c05-a534-ebcc9a8c52bb	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-01 22:46:58.775322+00	
00000000-0000-0000-0000-000000000000	10da8410-2e7b-4da8-b695-9a2bb31b7e17	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-01 22:46:58.790056+00	
00000000-0000-0000-0000-000000000000	df7ca7ec-181d-4127-aafa-0478272cf240	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-02 02:47:39.024537+00	
00000000-0000-0000-0000-000000000000	880c991a-6a8e-4c04-b807-86a954e4e8c8	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-02 02:47:39.031248+00	
00000000-0000-0000-0000-000000000000	547bd7af-848c-444a-94c6-0ae16e65b11f	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-03 02:30:05.575553+00	
00000000-0000-0000-0000-000000000000	79fa7341-a573-429c-8c55-a9d485081b50	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-03 02:30:05.592636+00	
00000000-0000-0000-0000-000000000000	393cc561-95ac-4e84-8308-e1acf67fc5e4	{"action":"login","actor_id":"7f2169d3-894f-484f-bf65-8be242c8cd24","actor_name":"Aiden St. Clair-Dean","actor_username":"echo2149@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-06-03 05:06:50.049398+00	
00000000-0000-0000-0000-000000000000	8a0750df-e4dd-42fc-9bef-08ea080a43e7	{"action":"token_refreshed","actor_id":"7f2169d3-894f-484f-bf65-8be242c8cd24","actor_name":"Aiden St. Clair-Dean","actor_username":"echo2149@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-03 06:18:32.14612+00	
00000000-0000-0000-0000-000000000000	5f9263bd-f5db-4475-8283-06ae7f3b0eed	{"action":"token_revoked","actor_id":"7f2169d3-894f-484f-bf65-8be242c8cd24","actor_name":"Aiden St. Clair-Dean","actor_username":"echo2149@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-03 06:18:32.162539+00	
00000000-0000-0000-0000-000000000000	56ab484a-d713-43f0-85b5-b94c8e1c64b2	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-06-03 06:29:26.786439+00	
00000000-0000-0000-0000-000000000000	ccd9384e-fc7e-4924-9c72-652e88b35e17	{"action":"logout","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-06-03 06:31:21.861218+00	
00000000-0000-0000-0000-000000000000	63487904-3c3c-4f4b-a3f5-3eef348d62fd	{"action":"login","actor_id":"dfa7ac70-3f2d-47e5-86e4-49bba65a68b5","actor_name":"FanBass Support","actor_username":"support@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-06-03 06:31:26.500944+00	
00000000-0000-0000-0000-000000000000	20e6c5e6-e6dd-406f-b8fb-356178083d7f	{"action":"logout","actor_id":"dfa7ac70-3f2d-47e5-86e4-49bba65a68b5","actor_name":"FanBass Support","actor_username":"support@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-06-03 06:31:31.240827+00	
00000000-0000-0000-0000-000000000000	7c6863d5-0105-4698-afdd-e0fe92ea7710	{"action":"token_refreshed","actor_id":"06082977-180b-4170-a3d5-72f7005652a9","actor_name":"Noah Forman","actor_username":"noahjforman@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-03 06:33:51.587786+00	
00000000-0000-0000-0000-000000000000	b05b2364-4069-48a2-8956-326c4cc067e8	{"action":"token_revoked","actor_id":"06082977-180b-4170-a3d5-72f7005652a9","actor_name":"Noah Forman","actor_username":"noahjforman@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-03 06:33:51.589201+00	
00000000-0000-0000-0000-000000000000	74b19d28-a1ad-40ab-90bf-6c08fb48d01a	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-03 06:34:13.570525+00	
00000000-0000-0000-0000-000000000000	cea8d69b-2830-44d7-b9f8-fbd5f73e7512	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-03 06:34:13.571078+00	
00000000-0000-0000-0000-000000000000	7a6eb6c0-5a94-4a54-bfd7-b605683739ad	{"action":"login","actor_id":"dfa7ac70-3f2d-47e5-86e4-49bba65a68b5","actor_name":"FanBass Support","actor_username":"support@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-06-03 06:34:46.792073+00	
00000000-0000-0000-0000-000000000000	9edb9f55-e6ec-42fa-ac7f-6aa9cd3066e6	{"action":"logout","actor_id":"dfa7ac70-3f2d-47e5-86e4-49bba65a68b5","actor_name":"FanBass Support","actor_username":"support@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-06-03 06:34:56.689313+00	
00000000-0000-0000-0000-000000000000	2f9ab11d-4247-43ac-b331-9340ab44ce1c	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-06-03 06:35:00.393824+00	
00000000-0000-0000-0000-000000000000	6765833e-0094-47d3-af36-5f0f1e2d9292	{"action":"logout","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-06-03 06:39:20.496774+00	
00000000-0000-0000-0000-000000000000	1646d6ec-c634-4a91-80e6-b3adaac22598	{"action":"login","actor_id":"dfa7ac70-3f2d-47e5-86e4-49bba65a68b5","actor_name":"FanBass Support","actor_username":"support@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-06-03 06:39:24.872839+00	
00000000-0000-0000-0000-000000000000	96c33c2a-a794-401e-8333-eb75e0a363c3	{"action":"logout","actor_id":"dfa7ac70-3f2d-47e5-86e4-49bba65a68b5","actor_name":"FanBass Support","actor_username":"support@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-06-03 06:40:54.025122+00	
00000000-0000-0000-0000-000000000000	c6a5dd1e-6a2d-4a67-8014-c4fd65c7359a	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-06-03 06:40:57.986409+00	
00000000-0000-0000-0000-000000000000	f7effdec-d811-44b7-bdef-55ad9da3aa63	{"action":"logout","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-06-03 06:42:02.274652+00	
00000000-0000-0000-0000-000000000000	3be2cad3-dd89-4703-a8e4-1439f43094cd	{"action":"login","actor_id":"dfa7ac70-3f2d-47e5-86e4-49bba65a68b5","actor_name":"FanBass Support","actor_username":"support@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-06-03 06:42:05.666212+00	
00000000-0000-0000-0000-000000000000	025cd27f-d622-4505-9fdf-f2630a82c500	{"action":"logout","actor_id":"dfa7ac70-3f2d-47e5-86e4-49bba65a68b5","actor_name":"FanBass Support","actor_username":"support@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-06-03 07:07:19.267373+00	
00000000-0000-0000-0000-000000000000	efc526c1-22ea-4275-b7ec-4fff0c42c1e0	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-06-03 07:07:22.72622+00	
00000000-0000-0000-0000-000000000000	2c680651-b2f7-4027-ad83-b5170bbab957	{"action":"logout","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-06-03 07:08:55.565237+00	
00000000-0000-0000-0000-000000000000	2986336a-17f7-433d-9a41-2472d5622dc7	{"action":"login","actor_id":"dfa7ac70-3f2d-47e5-86e4-49bba65a68b5","actor_name":"FanBass Support","actor_username":"support@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-06-03 07:09:00.11492+00	
00000000-0000-0000-0000-000000000000	7fbc5ba0-0747-4275-b88d-240e9f6d08f2	{"action":"logout","actor_id":"dfa7ac70-3f2d-47e5-86e4-49bba65a68b5","actor_name":"FanBass Support","actor_username":"support@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-06-03 07:09:13.013383+00	
00000000-0000-0000-0000-000000000000	59865c41-f063-46b0-9401-9fb688001bef	{"action":"login","actor_id":"dfa7ac70-3f2d-47e5-86e4-49bba65a68b5","actor_name":"FanBass Support","actor_username":"support@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-06-03 07:09:17.169803+00	
00000000-0000-0000-0000-000000000000	6ba54973-4a48-4e39-9ef8-25ca3ec23a90	{"action":"logout","actor_id":"dfa7ac70-3f2d-47e5-86e4-49bba65a68b5","actor_name":"FanBass Support","actor_username":"support@fanbass.io","actor_via_sso":false,"log_type":"account"}	2025-06-03 07:09:18.610589+00	
00000000-0000-0000-0000-000000000000	a788ec25-3571-4b11-aa49-f8e4aa4b719a	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-06-03 07:09:21.862248+00	
00000000-0000-0000-0000-000000000000	61b6b608-b9bd-447a-90e5-3cd202a87737	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-06-03 07:14:08.848538+00	
00000000-0000-0000-0000-000000000000	fe894b5d-e97f-4958-a06b-283002fd1793	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-06-03 08:07:51.534394+00	
00000000-0000-0000-0000-000000000000	44bd9933-70bd-4c09-a454-5fdceb1ad134	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-06-03 08:07:51.540687+00	
00000000-0000-0000-0000-000000000000	1d08a16a-125d-4787-a62c-d9b191561ced	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-06-03 08:12:38.520338+00	
00000000-0000-0000-0000-000000000000	2612e084-777a-4491-a405-49bbc631f2e7	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-06-03 08:12:38.52261+00	
00000000-0000-0000-0000-000000000000	b1ff4d63-f035-4351-900b-76440bf7830e	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-06-03 09:08:02.458953+00	
00000000-0000-0000-0000-000000000000	9bbbf2e6-f340-4df4-9aaa-e31300fd6a0c	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-06-03 09:08:02.470444+00	
00000000-0000-0000-0000-000000000000	6a06c831-c8f9-4c11-a0e0-448123247269	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-06-03 09:11:08.576143+00	
00000000-0000-0000-0000-000000000000	8c131aa1-940d-477b-b1d9-873224a7d382	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-06-03 09:11:08.580096+00	
00000000-0000-0000-0000-000000000000	5f9b8dfd-3ec5-469d-b6a2-a1e1b7b2ea17	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-03 09:12:45.036138+00	
00000000-0000-0000-0000-000000000000	6565a95b-8f0e-4fa8-afbd-269391d85eca	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-03 09:12:45.036935+00	
00000000-0000-0000-0000-000000000000	24c17030-ac00-494a-a041-7787e545d375	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-03 10:29:21.428348+00	
00000000-0000-0000-0000-000000000000	e6dd0fb4-b562-4470-9bd7-20b3d7807508	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-03 10:29:21.432753+00	
00000000-0000-0000-0000-000000000000	a6507677-a7ed-4872-b872-409c742f1f3e	{"action":"token_refreshed","actor_id":"7f2169d3-894f-484f-bf65-8be242c8cd24","actor_name":"Aiden St. Clair-Dean","actor_username":"echo2149@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-03 20:14:08.815868+00	
00000000-0000-0000-0000-000000000000	f9aefd0b-f0b6-481a-a91c-08732faf59a2	{"action":"token_revoked","actor_id":"7f2169d3-894f-484f-bf65-8be242c8cd24","actor_name":"Aiden St. Clair-Dean","actor_username":"echo2149@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-03 20:14:08.828173+00	
00000000-0000-0000-0000-000000000000	22509744-b816-423f-b851-7910ab5fd0cc	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-06-03 20:35:53.942684+00	
00000000-0000-0000-0000-000000000000	2d33b036-9f34-471f-9907-6a9413292dca	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-06-03 20:35:53.948327+00	
00000000-0000-0000-0000-000000000000	ca670d8f-b077-4a81-9903-cc3f4457e973	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-03 20:37:53.346038+00	
00000000-0000-0000-0000-000000000000	91a8e1b5-0de6-4838-b1d8-2766b89b43c0	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-03 20:37:53.347478+00	
00000000-0000-0000-0000-000000000000	6f3175f0-4ad8-4ba9-8648-30729877c81c	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-06-03 20:44:47.274753+00	
00000000-0000-0000-0000-000000000000	394ae756-85e1-41ae-86eb-1df595bdc8f8	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-06-03 20:44:47.278677+00	
00000000-0000-0000-0000-000000000000	4ee06f17-2669-4ebf-9ae7-45a644f673ba	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-06-03 21:13:01.057922+00	
00000000-0000-0000-0000-000000000000	567dc5bd-c4d1-4a37-99aa-331269186d4a	{"action":"login","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-06-03 21:13:01.45199+00	
00000000-0000-0000-0000-000000000000	f711ba34-a8c1-4da7-ba6f-f29d43f00495	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-06-03 21:42:50.259098+00	
00000000-0000-0000-0000-000000000000	6a0c3a03-277b-4e19-8bd2-f5cda00b3725	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-06-03 21:47:07.233248+00	
00000000-0000-0000-0000-000000000000	08a3cb9b-d806-4a29-b3ad-217bcf0194dc	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-06-03 21:52:18.411109+00	
00000000-0000-0000-0000-000000000000	572ea891-b1a3-47a5-9dbe-679898899250	{"action":"login","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"account","traits":{"provider":"google"}}	2025-06-03 21:55:23.253993+00	
00000000-0000-0000-0000-000000000000	6dc024d9-e442-4058-be39-19987a8a6852	{"action":"token_refreshed","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-03 22:23:27.15226+00	
00000000-0000-0000-0000-000000000000	13601235-2c92-40f8-90a5-d0ed3a29cf07	{"action":"token_revoked","actor_id":"9547e1f9-306e-4dd2-96fb-89fc33ce7512","actor_name":"Ariel Lasry","actor_username":"lasryariel@gmail.com","actor_via_sso":false,"log_type":"token"}	2025-06-03 22:23:27.156817+00	
00000000-0000-0000-0000-000000000000	379ddd5e-24ca-4681-b9a7-3e0ce92972b7	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-06-03 22:53:23.772056+00	
00000000-0000-0000-0000-000000000000	19f42cc3-8cba-4a75-84c8-caf87b6620a8	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-06-03 22:53:23.7752+00	
00000000-0000-0000-0000-000000000000	b11cbaec-b630-4dac-b5ec-35dc79cfc609	{"action":"token_refreshed","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-06-04 00:00:59.42766+00	
00000000-0000-0000-0000-000000000000	ef1f326c-e1b8-48ae-b6a3-e1ef51f13412	{"action":"token_revoked","actor_id":"eda854e4-0358-4ae6-b5e2-8bb490e5782a","actor_name":"FanBass Admin","actor_username":"admin@fanbass.io","actor_via_sso":false,"log_type":"token"}	2025-06-04 00:00:59.432954+00	
\.


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.flow_state (id, user_id, auth_code, code_challenge_method, code_challenge, provider_type, provider_access_token, provider_refresh_token, created_at, updated_at, authentication_method, auth_code_issued_at) FROM stdin;
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) FROM stdin;
111669120252205994531	06082977-180b-4170-a3d5-72f7005652a9	{"iss": "https://accounts.google.com", "sub": "111669120252205994531", "name": "Noah Forman", "email": "noahjforman@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocL6OQ9T5PbQPTU9hCdzWrKkOc9wrA9IT_f4VL66lca1YsVYhF2c0A=s96-c", "full_name": "Noah Forman", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocL6OQ9T5PbQPTU9hCdzWrKkOc9wrA9IT_f4VL66lca1YsVYhF2c0A=s96-c", "provider_id": "111669120252205994531", "email_verified": true, "phone_verified": false}	google	2025-05-29 02:50:54.963682+00	2025-05-29 02:50:54.963732+00	2025-05-29 02:50:54.963732+00	4f8a223d-1a2c-4c39-a5fd-f3ca9b5ec4ea
113290904484040490635	7f2169d3-894f-484f-bf65-8be242c8cd24	{"iss": "https://accounts.google.com", "sub": "113290904484040490635", "name": "Aiden St. Clair-Dean", "email": "echo2149@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocLXkOwokZgYT3kZSPt8M5RhOzsgNyJjWEnJuFxvQ-gtAOvQrBO8LQ=s96-c", "full_name": "Aiden St. Clair-Dean", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocLXkOwokZgYT3kZSPt8M5RhOzsgNyJjWEnJuFxvQ-gtAOvQrBO8LQ=s96-c", "provider_id": "113290904484040490635", "email_verified": true, "phone_verified": false}	google	2025-05-29 02:26:02.908414+00	2025-05-29 02:26:02.908466+00	2025-06-03 05:06:50.038556+00	85b53cc4-261f-42db-903b-a5ec9bb9ba18
114901621736922906550	b0b0ed7d-538a-4b52-bc1c-f5410677612c	{"iss": "https://accounts.google.com", "sub": "114901621736922906550", "name": "Jonathan Privett", "email": "jonathanjamesprivett@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocK4c4ORRwHhkb3MGD_PTrbuuEgiv-EvGBYZUfijFuEWYdBwQw=s96-c", "full_name": "Jonathan Privett", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocK4c4ORRwHhkb3MGD_PTrbuuEgiv-EvGBYZUfijFuEWYdBwQw=s96-c", "provider_id": "114901621736922906550", "email_verified": true, "phone_verified": false}	google	2025-05-30 09:05:38.955837+00	2025-05-30 09:05:38.95589+00	2025-05-30 09:05:38.95589+00	92d78080-3a15-4c5f-b9ba-4092ca46020d
103440462013485736657	eda854e4-0358-4ae6-b5e2-8bb490e5782a	{"iss": "https://accounts.google.com", "sub": "103440462013485736657", "name": "FanBass Admin", "email": "admin@fanbass.io", "picture": "https://lh3.googleusercontent.com/a/ACg8ocJr9jXnrp4S09r6prpw1_taMYR-YTLrayZENrtEfaPKnU2hvg=s96-c", "full_name": "FanBass Admin", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocJr9jXnrp4S09r6prpw1_taMYR-YTLrayZENrtEfaPKnU2hvg=s96-c", "provider_id": "103440462013485736657", "custom_claims": {"hd": "fanbass.io"}, "email_verified": true, "phone_verified": false}	google	2025-05-24 02:33:25.590717+00	2025-05-24 02:33:25.590773+00	2025-06-03 21:55:23.249628+00	cc2162d3-a6e3-4233-a118-66713d76cbb4
109179280511826067208	c3866d1b-210f-490a-b300-bde91941735b	{"iss": "https://accounts.google.com", "sub": "109179280511826067208", "name": "Ariel Lasry", "email": "ariel@fanbass.io", "picture": "https://lh3.googleusercontent.com/a/ACg8ocKa70Z8bUKJFnsac83T-yaI35qD9dZ0I3LMrapkYtiAfwJg4g=s96-c", "full_name": "Ariel Lasry", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocKa70Z8bUKJFnsac83T-yaI35qD9dZ0I3LMrapkYtiAfwJg4g=s96-c", "provider_id": "109179280511826067208", "custom_claims": {"hd": "fanbass.io"}, "email_verified": true, "phone_verified": false}	google	2025-05-31 04:44:34.270328+00	2025-05-31 04:44:34.270379+00	2025-05-31 20:10:23.785266+00	5b2ba7cb-5a47-40b4-8acd-d597a50115d2
114618827989739603275	1988ae88-45c3-4529-929f-24fe6ed0b93b	{"iss": "https://accounts.google.com", "sub": "114618827989739603275", "name": "Alec Hugh", "email": "acehugh@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocI6-hrm8xkYFFEpAPY9ttPUgqYa3yIMKtwzmHBasc5cU4fIdUxb=s96-c", "full_name": "Alec Hugh", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocI6-hrm8xkYFFEpAPY9ttPUgqYa3yIMKtwzmHBasc5cU4fIdUxb=s96-c", "provider_id": "114618827989739603275", "email_verified": true, "phone_verified": false}	google	2025-05-29 15:59:38.456979+00	2025-05-29 15:59:38.457037+00	2025-05-29 15:59:38.457037+00	efa007b1-914e-44cb-bd3a-f7af7d654396
106842646774411158557	82f7f043-f150-4052-82a7-d98c4c31237c	{"iss": "https://accounts.google.com", "sub": "106842646774411158557", "name": "Eli Verschleiser", "email": "eli.v@eliv.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocLUvy-3540gGVb-ZDvs7gzl2fd6QKduu9PP1wK8ffBrY7LDpQ=s96-c", "full_name": "Eli Verschleiser", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocLUvy-3540gGVb-ZDvs7gzl2fd6QKduu9PP1wK8ffBrY7LDpQ=s96-c", "provider_id": "106842646774411158557", "custom_claims": {"hd": "eliv.com"}, "email_verified": true, "phone_verified": false}	google	2025-05-29 17:21:27.957305+00	2025-05-29 17:21:27.957364+00	2025-05-29 17:21:27.957364+00	e2b7bfa5-a014-4ac7-9e7b-14974edb8039
116251500687178227262	9547e1f9-306e-4dd2-96fb-89fc33ce7512	{"iss": "https://accounts.google.com", "sub": "116251500687178227262", "name": "Ariel Lasry", "email": "lasryariel@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocJpdyn5QhuOg-4pLiYi7uwmTgFbw_jsEIwxTvpwJCoZw0X0Aw=s96-c", "full_name": "Ariel Lasry", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocJpdyn5QhuOg-4pLiYi7uwmTgFbw_jsEIwxTvpwJCoZw0X0Aw=s96-c", "provider_id": "116251500687178227262", "email_verified": true, "phone_verified": false}	google	2025-05-24 13:56:41.087981+00	2025-05-24 13:56:41.088038+00	2025-06-03 21:13:01.450408+00	e9e443c4-bfc8-4182-b808-8e7a17215991
107808641427011897080	dfa7ac70-3f2d-47e5-86e4-49bba65a68b5	{"iss": "https://accounts.google.com", "sub": "107808641427011897080", "name": "FanBass Support", "email": "support@fanbass.io", "picture": "https://lh3.googleusercontent.com/a/ACg8ocKvDjO-AlcdYkEQp2DS7GJPh_Kbgwk55aUzmYHl5Luuva5nPg=s96-c", "full_name": "FanBass Support", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocKvDjO-AlcdYkEQp2DS7GJPh_Kbgwk55aUzmYHl5Luuva5nPg=s96-c", "provider_id": "107808641427011897080", "custom_claims": {"hd": "fanbass.io"}, "email_verified": true, "phone_verified": false}	google	2025-05-28 18:18:03.743894+00	2025-05-28 18:18:03.743941+00	2025-06-03 07:09:17.168058+00	a201dbbf-bb7e-44bf-8bb6-6cbee11f4b35
101599941440498930649	419646ee-1d59-4497-9fae-60b0eed36064	{"iss": "https://accounts.google.com", "sub": "101599941440498930649", "name": "Caleb Forman", "email": "lightning0379@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocKn3BELy0vGG4dsmWuUG8icK82eu0xegMdMl88CoXaTZ4rhHw=s96-c", "full_name": "Caleb Forman", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocKn3BELy0vGG4dsmWuUG8icK82eu0xegMdMl88CoXaTZ4rhHw=s96-c", "provider_id": "101599941440498930649", "email_verified": true, "phone_verified": false}	google	2025-06-01 00:00:41.707557+00	2025-06-01 00:00:41.707609+00	2025-06-01 00:00:41.707609+00	502bdfdd-8f41-423c-8039-267d090a1edc
\.


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.instances (id, uuid, raw_base_config, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) FROM stdin;
c33b28bd-3d67-4a71-ab95-614ee99fc214	2025-06-03 05:06:50.071818+00	2025-06-03 05:06:50.071818+00	oauth	ffcd62f5-96d6-4fb2-9905-97035f9cc057
f3a4c0a6-5d30-417a-91f9-9127b981e48c	2025-06-03 07:09:21.865396+00	2025-06-03 07:09:21.865396+00	oauth	96734ecf-62c9-4ab6-a05b-3b88f8a55389
060b1d37-458b-4073-88e4-547a6de07fce	2025-06-03 07:14:08.854605+00	2025-06-03 07:14:08.854605+00	oauth	185e78a2-f2a6-484d-b347-c145c225a027
21fbec2e-ba85-4d47-8e37-e0d52ca35775	2025-06-03 21:13:01.076509+00	2025-06-03 21:13:01.076509+00	oauth	a4986271-23a0-4347-88ac-e88497846811
9a633493-46af-4296-a046-6946c7c3c70d	2025-06-03 21:13:01.455222+00	2025-06-03 21:13:01.455222+00	oauth	0f3e821a-e9a2-4b3b-b6e8-89d3261dae6f
ee997cba-9a7b-40da-92a1-01eaa71e353b	2025-06-03 21:42:50.268685+00	2025-06-03 21:42:50.268685+00	oauth	b8a7e669-6d0c-49ec-b6c9-ed37508438fd
54262d46-c10e-4bc0-b5b7-5fa3cb594295	2025-06-03 21:47:07.244471+00	2025-06-03 21:47:07.244471+00	oauth	8a665ba5-5479-4d4f-ab68-62d34e24195b
331dfbd4-9b84-4b3a-9010-4f56bbab69d8	2025-06-03 21:52:18.419986+00	2025-06-03 21:52:18.419986+00	oauth	b449e277-2000-4cb8-b288-7aee139bac35
2a38c4a2-7844-4614-b339-d697ba9069d8	2025-06-03 21:55:23.260664+00	2025-06-03 21:55:23.260664+00	oauth	89840980-d3dc-4992-b5a8-e87dbcc7e833
7de8b4bf-0d21-4fd6-b8fb-d6320ae28a94	2025-05-29 02:26:02.921636+00	2025-05-29 02:26:02.921636+00	oauth	5dafdca9-4bff-4ac0-b09d-b5c7e6e2631b
8d2e7c28-aa71-4ad1-b5cb-ea2e08bb9b86	2025-05-29 02:50:54.985949+00	2025-05-29 02:50:54.985949+00	oauth	fee0fb1c-671d-4aee-b638-d34201361379
3ae75e5c-f124-4066-9417-90802f117089	2025-05-29 15:59:38.476011+00	2025-05-29 15:59:38.476011+00	oauth	2898a50b-5440-4fd1-81fd-7a60942a86b2
92c0b2d4-9588-4173-a726-1d4f89cb3d1b	2025-05-29 17:21:27.970035+00	2025-05-29 17:21:27.970035+00	oauth	7aa0c5f0-9bf8-45ca-92e2-784a97a672c7
45816520-f650-4f52-a890-bd6f0b72a3d4	2025-05-30 09:05:38.98454+00	2025-05-30 09:05:38.98454+00	oauth	55d81cac-de30-48ce-bd75-85664668bf0d
2b4fe8e7-c593-4e1e-8223-cd053205850a	2025-05-31 04:44:34.299558+00	2025-05-31 04:44:34.299558+00	oauth	eab2d992-2377-4d03-91ba-e086556aa2c4
4d95d2d2-2aed-4307-9670-aa7d1c9dc3c0	2025-05-31 20:10:23.789326+00	2025-05-31 20:10:23.789326+00	oauth	6c3b57c0-8d81-4151-9af1-8ba22d71322f
b62cfbd0-8a10-4455-970b-425f227e830c	2025-06-01 00:00:41.723392+00	2025-06-01 00:00:41.723392+00	oauth	2183897a-f3f3-4b93-b68e-d3d1e18b8d97
dd93a70d-562d-4f0e-8453-0aee7ed46cc2	2025-06-01 01:37:45.570763+00	2025-06-01 01:37:45.570763+00	oauth	a0ab07c2-4d2f-4da3-90a4-7a0cc5f2d6d0
\.


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_challenges (id, factor_id, created_at, verified_at, ip_address, otp_code, web_authn_session_data) FROM stdin;
\.


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_factors (id, user_id, friendly_name, factor_type, status, created_at, updated_at, secret, phone, last_challenged_at, web_authn_credential, web_authn_aaguid) FROM stdin;
\.


--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.one_time_tokens (id, user_id, token_type, token_hash, relates_to, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) FROM stdin;
00000000-0000-0000-0000-000000000000	263	aiagih2ln5lw	9547e1f9-306e-4dd2-96fb-89fc33ce7512	t	2025-06-02 02:47:39.037077+00	2025-06-03 02:30:05.597561+00	dcq22lboqwqr	dd93a70d-562d-4f0e-8453-0aee7ed46cc2
00000000-0000-0000-0000-000000000000	190	silfa64p72gq	c3866d1b-210f-490a-b300-bde91941735b	t	2025-05-31 04:44:34.292789+00	2025-05-31 05:42:58.96467+00	\N	2b4fe8e7-c593-4e1e-8223-cd053205850a
00000000-0000-0000-0000-000000000000	186	mo5r4veix72u	06082977-180b-4170-a3d5-72f7005652a9	t	2025-05-31 01:26:58.372769+00	2025-05-31 08:26:58.860253+00	e5arcxohkuje	8d2e7c28-aa71-4ad1-b5cb-ea2e08bb9b86
00000000-0000-0000-0000-000000000000	152	46gekf3bysxs	82f7f043-f150-4052-82a7-d98c4c31237c	f	2025-05-29 19:40:26.410605+00	2025-05-29 19:40:26.410605+00	4ngkky3hxnzo	92c0b2d4-9588-4173-a726-1d4f89cb3d1b
00000000-0000-0000-0000-000000000000	261	onknntmqxtmf	06082977-180b-4170-a3d5-72f7005652a9	t	2025-06-01 07:36:50.078598+00	2025-06-03 06:33:51.589696+00	sx2nwmeilfyp	8d2e7c28-aa71-4ad1-b5cb-ea2e08bb9b86
00000000-0000-0000-0000-000000000000	264	uehfiuzd55e2	9547e1f9-306e-4dd2-96fb-89fc33ce7512	t	2025-06-03 02:30:05.610898+00	2025-06-03 06:34:13.571527+00	aiagih2ln5lw	dd93a70d-562d-4f0e-8453-0aee7ed46cc2
00000000-0000-0000-0000-000000000000	139	vzl4lqqvs5qp	7f2169d3-894f-484f-bf65-8be242c8cd24	t	2025-05-29 08:39:25.339976+00	2025-05-29 21:42:55.327426+00	5pv54kh672ae	7de8b4bf-0d21-4fd6-b8fb-d6320ae28a94
00000000-0000-0000-0000-000000000000	214	prgvpw6az3yc	b0b0ed7d-538a-4b52-bc1c-f5410677612c	t	2025-05-31 18:52:49.905827+00	2025-05-31 22:23:06.947045+00	e5q6quzp7cyt	45816520-f650-4f52-a890-bd6f0b72a3d4
00000000-0000-0000-0000-000000000000	231	psw6fngquysm	06082977-180b-4170-a3d5-72f7005652a9	t	2025-05-31 22:26:35.526317+00	2025-05-31 23:58:53.890838+00	utqxi4jcxjdi	8d2e7c28-aa71-4ad1-b5cb-ea2e08bb9b86
00000000-0000-0000-0000-000000000000	160	x6y4fqvccwim	7f2169d3-894f-484f-bf65-8be242c8cd24	t	2025-05-30 03:44:08.667859+00	2025-05-30 04:54:39.264945+00	qyyby3bjrfcb	7de8b4bf-0d21-4fd6-b8fb-d6320ae28a94
00000000-0000-0000-0000-000000000000	236	ogtpylldxyez	06082977-180b-4170-a3d5-72f7005652a9	t	2025-05-31 23:58:53.891179+00	2025-06-01 00:59:11.320837+00	psw6fngquysm	8d2e7c28-aa71-4ad1-b5cb-ea2e08bb9b86
00000000-0000-0000-0000-000000000000	162	3rgnremp7upc	7f2169d3-894f-484f-bf65-8be242c8cd24	t	2025-05-30 09:00:58.172544+00	2025-05-30 10:29:37.831302+00	j6ugehgn4pyz	7de8b4bf-0d21-4fd6-b8fb-d6320ae28a94
00000000-0000-0000-0000-000000000000	279	rp3ig4frupvv	eda854e4-0358-4ae6-b5e2-8bb490e5782a	t	2025-06-03 07:09:21.863491+00	2025-06-03 08:07:51.541941+00	\N	f3a4c0a6-5d30-417a-91f9-9127b981e48c
00000000-0000-0000-0000-000000000000	164	sge7uctdonyo	06082977-180b-4170-a3d5-72f7005652a9	t	2025-05-30 09:35:08.521348+00	2025-05-30 10:54:18.730837+00	377lu2ws22oy	8d2e7c28-aa71-4ad1-b5cb-ea2e08bb9b86
00000000-0000-0000-0000-000000000000	281	btk4lnlpcmg4	eda854e4-0358-4ae6-b5e2-8bb490e5782a	t	2025-06-03 08:07:51.545943+00	2025-06-03 09:08:02.471032+00	rp3ig4frupvv	f3a4c0a6-5d30-417a-91f9-9127b981e48c
00000000-0000-0000-0000-000000000000	247	4nhdujlgfbh4	9547e1f9-306e-4dd2-96fb-89fc33ce7512	t	2025-06-01 01:37:45.56801+00	2025-06-01 02:36:01.216269+00	\N	dd93a70d-562d-4f0e-8453-0aee7ed46cc2
00000000-0000-0000-0000-000000000000	135	75ovo7lf4tc6	7f2169d3-894f-484f-bf65-8be242c8cd24	t	2025-05-29 03:52:09.861059+00	2025-05-29 05:08:01.956663+00	bv7tczfxocyq	7de8b4bf-0d21-4fd6-b8fb-d6320ae28a94
00000000-0000-0000-0000-000000000000	249	uhcegur5ueiu	9547e1f9-306e-4dd2-96fb-89fc33ce7512	t	2025-06-01 02:36:01.21889+00	2025-06-01 03:34:31.248414+00	4nhdujlgfbh4	dd93a70d-562d-4f0e-8453-0aee7ed46cc2
00000000-0000-0000-0000-000000000000	137	gj6hfmlf25ga	7f2169d3-894f-484f-bf65-8be242c8cd24	t	2025-05-29 05:08:01.957375+00	2025-05-29 06:19:24.246797+00	75ovo7lf4tc6	7de8b4bf-0d21-4fd6-b8fb-d6320ae28a94
00000000-0000-0000-0000-000000000000	285	6q6lm55udnry	9547e1f9-306e-4dd2-96fb-89fc33ce7512	t	2025-06-03 09:12:45.03805+00	2025-06-03 10:29:21.43388+00	jhmqi56vbdwa	dd93a70d-562d-4f0e-8453-0aee7ed46cc2
00000000-0000-0000-0000-000000000000	266	zgakefqypzkf	7f2169d3-894f-484f-bf65-8be242c8cd24	t	2025-06-03 06:18:32.178363+00	2025-06-03 20:14:08.829912+00	xcvg2ev74yrb	7de8b4bf-0d21-4fd6-b8fb-d6320ae28a94
00000000-0000-0000-0000-000000000000	251	t3nypzkhsfsz	9547e1f9-306e-4dd2-96fb-89fc33ce7512	t	2025-06-01 03:34:31.251089+00	2025-06-01 04:32:52.640045+00	uhcegur5ueiu	dd93a70d-562d-4f0e-8453-0aee7ed46cc2
00000000-0000-0000-0000-000000000000	287	lp7y3iqsrzfa	7f2169d3-894f-484f-bf65-8be242c8cd24	f	2025-06-03 20:14:08.839786+00	2025-06-03 20:14:08.839786+00	zgakefqypzkf	7de8b4bf-0d21-4fd6-b8fb-d6320ae28a94
00000000-0000-0000-0000-000000000000	283	3yimylayh2xx	eda854e4-0358-4ae6-b5e2-8bb490e5782a	t	2025-06-03 09:08:02.479361+00	2025-06-03 20:35:53.948863+00	btk4lnlpcmg4	f3a4c0a6-5d30-417a-91f9-9127b981e48c
00000000-0000-0000-0000-000000000000	289	pzwvbaxqr2yi	9547e1f9-306e-4dd2-96fb-89fc33ce7512	f	2025-06-03 20:37:53.348539+00	2025-06-03 20:37:53.348539+00	fizzwrdoatat	dd93a70d-562d-4f0e-8453-0aee7ed46cc2
00000000-0000-0000-0000-000000000000	259	7uskta4hrm5o	9547e1f9-306e-4dd2-96fb-89fc33ce7512	t	2025-06-01 05:31:46.342247+00	2025-06-01 06:53:42.400801+00	5rigeldcgz23	dd93a70d-562d-4f0e-8453-0aee7ed46cc2
00000000-0000-0000-0000-000000000000	166	xcsxpkl5367z	7f2169d3-894f-484f-bf65-8be242c8cd24	t	2025-05-30 10:29:37.834362+00	2025-05-30 17:21:05.913729+00	3rgnremp7upc	7de8b4bf-0d21-4fd6-b8fb-d6320ae28a94
00000000-0000-0000-0000-000000000000	291	dnpaqeoylwjc	9547e1f9-306e-4dd2-96fb-89fc33ce7512	f	2025-06-03 21:13:01.071159+00	2025-06-03 21:13:01.071159+00	\N	21fbec2e-ba85-4d47-8e37-e0d52ca35775
00000000-0000-0000-0000-000000000000	192	2xbw5aakwfmi	06082977-180b-4170-a3d5-72f7005652a9	t	2025-05-31 08:26:58.8674+00	2025-05-31 18:53:38.782727+00	mo5r4veix72u	8d2e7c28-aa71-4ad1-b5cb-ea2e08bb9b86
00000000-0000-0000-0000-000000000000	294	3xsheqqx4zjm	eda854e4-0358-4ae6-b5e2-8bb490e5782a	f	2025-06-03 21:47:07.240181+00	2025-06-03 21:47:07.240181+00	\N	54262d46-c10e-4bc0-b5b7-5fa3cb594295
00000000-0000-0000-0000-000000000000	296	dcuhjwxnea7c	eda854e4-0358-4ae6-b5e2-8bb490e5782a	f	2025-06-03 21:55:23.255907+00	2025-06-03 21:55:23.255907+00	\N	2a38c4a2-7844-4614-b339-d697ba9069d8
00000000-0000-0000-0000-000000000000	292	rc3wb4tycvkx	9547e1f9-306e-4dd2-96fb-89fc33ce7512	t	2025-06-03 21:13:01.453277+00	2025-06-03 22:23:27.1574+00	\N	9a633493-46af-4296-a046-6946c7c3c70d
00000000-0000-0000-0000-000000000000	298	cscsz6wj3dsm	eda854e4-0358-4ae6-b5e2-8bb490e5782a	t	2025-06-03 22:53:23.779721+00	2025-06-04 00:00:59.43422+00	ltadkkd6ubo6	331dfbd4-9b84-4b3a-9010-4f56bbab69d8
00000000-0000-0000-0000-000000000000	138	5pv54kh672ae	7f2169d3-894f-484f-bf65-8be242c8cd24	t	2025-05-29 06:19:24.254919+00	2025-05-29 08:39:25.33937+00	gj6hfmlf25ga	7de8b4bf-0d21-4fd6-b8fb-d6320ae28a94
00000000-0000-0000-0000-000000000000	191	m3nfozdoa4ql	c3866d1b-210f-490a-b300-bde91941735b	f	2025-05-31 05:42:58.965324+00	2025-05-31 05:42:58.965324+00	silfa64p72gq	2b4fe8e7-c593-4e1e-8223-cd053205850a
00000000-0000-0000-0000-000000000000	265	quvofemryah6	7f2169d3-894f-484f-bf65-8be242c8cd24	f	2025-06-03 05:06:50.06332+00	2025-06-03 05:06:50.06332+00	\N	c33b28bd-3d67-4a71-ab95-614ee99fc214
00000000-0000-0000-0000-000000000000	178	xcvg2ev74yrb	7f2169d3-894f-484f-bf65-8be242c8cd24	t	2025-05-30 17:21:05.917416+00	2025-06-03 06:18:32.164733+00	xcsxpkl5367z	7de8b4bf-0d21-4fd6-b8fb-d6320ae28a94
00000000-0000-0000-0000-000000000000	269	m3xbufd3jzot	06082977-180b-4170-a3d5-72f7005652a9	f	2025-06-03 06:33:51.590366+00	2025-06-03 06:33:51.590366+00	onknntmqxtmf	8d2e7c28-aa71-4ad1-b5cb-ea2e08bb9b86
00000000-0000-0000-0000-000000000000	220	xnfzxgc5w3xx	c3866d1b-210f-490a-b300-bde91941735b	f	2025-05-31 20:10:23.788161+00	2025-05-31 20:10:23.788161+00	\N	4d95d2d2-2aed-4307-9670-aa7d1c9dc3c0
00000000-0000-0000-0000-000000000000	149	w3ww6z7dk5is	1988ae88-45c3-4529-929f-24fe6ed0b93b	f	2025-05-29 15:59:38.471+00	2025-05-29 15:59:38.471+00	\N	3ae75e5c-f124-4066-9417-90802f117089
00000000-0000-0000-0000-000000000000	280	wgn7hlsoqz3j	eda854e4-0358-4ae6-b5e2-8bb490e5782a	t	2025-06-03 07:14:08.852415+00	2025-06-03 08:12:38.52311+00	\N	060b1d37-458b-4073-88e4-547a6de07fce
00000000-0000-0000-0000-000000000000	151	4ngkky3hxnzo	82f7f043-f150-4052-82a7-d98c4c31237c	t	2025-05-29 17:21:27.967704+00	2025-05-29 19:40:26.408172+00	\N	92c0b2d4-9588-4173-a726-1d4f89cb3d1b
00000000-0000-0000-0000-000000000000	230	uqrjmu3yoduz	b0b0ed7d-538a-4b52-bc1c-f5410677612c	f	2025-05-31 22:23:06.949249+00	2025-05-31 22:23:06.949249+00	prgvpw6az3yc	45816520-f650-4f52-a890-bd6f0b72a3d4
00000000-0000-0000-0000-000000000000	215	utqxi4jcxjdi	06082977-180b-4170-a3d5-72f7005652a9	t	2025-05-31 18:53:38.783065+00	2025-05-31 22:26:35.525686+00	2xbw5aakwfmi	8d2e7c28-aa71-4ad1-b5cb-ea2e08bb9b86
00000000-0000-0000-0000-000000000000	282	jgcgmft6o26p	eda854e4-0358-4ae6-b5e2-8bb490e5782a	t	2025-06-03 08:12:38.524507+00	2025-06-03 09:11:08.581836+00	wgn7hlsoqz3j	060b1d37-458b-4073-88e4-547a6de07fce
00000000-0000-0000-0000-000000000000	155	63bjostzwrvl	7f2169d3-894f-484f-bf65-8be242c8cd24	t	2025-05-29 21:42:55.329693+00	2025-05-29 23:08:36.258157+00	vzl4lqqvs5qp	7de8b4bf-0d21-4fd6-b8fb-d6320ae28a94
00000000-0000-0000-0000-000000000000	270	jhmqi56vbdwa	9547e1f9-306e-4dd2-96fb-89fc33ce7512	t	2025-06-03 06:34:13.571836+00	2025-06-03 09:12:45.03748+00	uehfiuzd55e2	dd93a70d-562d-4f0e-8453-0aee7ed46cc2
00000000-0000-0000-0000-000000000000	132	bv7tczfxocyq	7f2169d3-894f-484f-bf65-8be242c8cd24	t	2025-05-29 02:26:02.919777+00	2025-05-29 03:52:09.859321+00	\N	7de8b4bf-0d21-4fd6-b8fb-d6320ae28a94
00000000-0000-0000-0000-000000000000	237	3obyh3y7foxg	419646ee-1d59-4497-9fae-60b0eed36064	f	2025-06-01 00:00:41.721701+00	2025-06-01 00:00:41.721701+00	\N	b62cfbd0-8a10-4455-970b-425f227e830c
00000000-0000-0000-0000-000000000000	288	fo66ocvtmqnh	eda854e4-0358-4ae6-b5e2-8bb490e5782a	f	2025-06-03 20:35:53.951564+00	2025-06-03 20:35:53.951564+00	3yimylayh2xx	f3a4c0a6-5d30-417a-91f9-9127b981e48c
00000000-0000-0000-0000-000000000000	286	fizzwrdoatat	9547e1f9-306e-4dd2-96fb-89fc33ce7512	t	2025-06-03 10:29:21.438501+00	2025-06-03 20:37:53.347946+00	6q6lm55udnry	dd93a70d-562d-4f0e-8453-0aee7ed46cc2
00000000-0000-0000-0000-000000000000	284	q4olxqsekkgv	eda854e4-0358-4ae6-b5e2-8bb490e5782a	t	2025-06-03 09:11:08.58491+00	2025-06-03 20:44:47.279191+00	jgcgmft6o26p	060b1d37-458b-4073-88e4-547a6de07fce
00000000-0000-0000-0000-000000000000	157	qyyby3bjrfcb	7f2169d3-894f-484f-bf65-8be242c8cd24	t	2025-05-29 23:08:36.259503+00	2025-05-30 03:44:08.663208+00	63bjostzwrvl	7de8b4bf-0d21-4fd6-b8fb-d6320ae28a94
00000000-0000-0000-0000-000000000000	165	e5q6quzp7cyt	b0b0ed7d-538a-4b52-bc1c-f5410677612c	t	2025-05-30 10:21:39.460629+00	2025-05-31 18:52:49.90208+00	otiodfsxfwhl	45816520-f650-4f52-a890-bd6f0b72a3d4
00000000-0000-0000-0000-000000000000	161	j6ugehgn4pyz	7f2169d3-894f-484f-bf65-8be242c8cd24	t	2025-05-30 04:54:39.267342+00	2025-05-30 09:00:58.166884+00	x6y4fqvccwim	7de8b4bf-0d21-4fd6-b8fb-d6320ae28a94
00000000-0000-0000-0000-000000000000	290	nicafgjc7gdu	eda854e4-0358-4ae6-b5e2-8bb490e5782a	f	2025-06-03 20:44:47.28223+00	2025-06-03 20:44:47.28223+00	q4olxqsekkgv	060b1d37-458b-4073-88e4-547a6de07fce
00000000-0000-0000-0000-000000000000	134	377lu2ws22oy	06082977-180b-4170-a3d5-72f7005652a9	t	2025-05-29 02:50:54.978592+00	2025-05-30 09:35:08.519423+00	\N	8d2e7c28-aa71-4ad1-b5cb-ea2e08bb9b86
00000000-0000-0000-0000-000000000000	163	otiodfsxfwhl	b0b0ed7d-538a-4b52-bc1c-f5410677612c	t	2025-05-30 09:05:38.979515+00	2025-05-30 10:21:39.458716+00	\N	45816520-f650-4f52-a890-bd6f0b72a3d4
00000000-0000-0000-0000-000000000000	293	23ecjvg5aamq	eda854e4-0358-4ae6-b5e2-8bb490e5782a	f	2025-06-03 21:42:50.263714+00	2025-06-03 21:42:50.263714+00	\N	ee997cba-9a7b-40da-92a1-01eaa71e353b
00000000-0000-0000-0000-000000000000	297	hsl2cimhzv25	9547e1f9-306e-4dd2-96fb-89fc33ce7512	f	2025-06-03 22:23:27.162601+00	2025-06-03 22:23:27.162601+00	rc3wb4tycvkx	9a633493-46af-4296-a046-6946c7c3c70d
00000000-0000-0000-0000-000000000000	295	ltadkkd6ubo6	eda854e4-0358-4ae6-b5e2-8bb490e5782a	t	2025-06-03 21:52:18.413748+00	2025-06-03 22:53:23.775736+00	\N	331dfbd4-9b84-4b3a-9010-4f56bbab69d8
00000000-0000-0000-0000-000000000000	299	jndmxo2qcfsg	eda854e4-0358-4ae6-b5e2-8bb490e5782a	f	2025-06-04 00:00:59.436937+00	2025-06-04 00:00:59.436937+00	cscsz6wj3dsm	331dfbd4-9b84-4b3a-9010-4f56bbab69d8
00000000-0000-0000-0000-000000000000	239	elvnq26dwpa2	06082977-180b-4170-a3d5-72f7005652a9	t	2025-06-01 00:59:11.322149+00	2025-06-01 03:58:24.81376+00	ogtpylldxyez	8d2e7c28-aa71-4ad1-b5cb-ea2e08bb9b86
00000000-0000-0000-0000-000000000000	253	eacuw6tpj5kc	06082977-180b-4170-a3d5-72f7005652a9	t	2025-06-01 03:58:24.814326+00	2025-06-01 05:15:49.025898+00	elvnq26dwpa2	8d2e7c28-aa71-4ad1-b5cb-ea2e08bb9b86
00000000-0000-0000-0000-000000000000	255	5rigeldcgz23	9547e1f9-306e-4dd2-96fb-89fc33ce7512	t	2025-06-01 04:32:52.642611+00	2025-06-01 05:31:46.338956+00	t3nypzkhsfsz	dd93a70d-562d-4f0e-8453-0aee7ed46cc2
00000000-0000-0000-0000-000000000000	167	e5arcxohkuje	06082977-180b-4170-a3d5-72f7005652a9	t	2025-05-30 10:54:18.732773+00	2025-05-31 01:26:58.370722+00	sge7uctdonyo	8d2e7c28-aa71-4ad1-b5cb-ea2e08bb9b86
00000000-0000-0000-0000-000000000000	258	sx2nwmeilfyp	06082977-180b-4170-a3d5-72f7005652a9	t	2025-06-01 05:15:49.030104+00	2025-06-01 07:36:50.075178+00	eacuw6tpj5kc	8d2e7c28-aa71-4ad1-b5cb-ea2e08bb9b86
00000000-0000-0000-0000-000000000000	260	qbz67oce55re	9547e1f9-306e-4dd2-96fb-89fc33ce7512	t	2025-06-01 06:53:42.406024+00	2025-06-01 22:46:58.791325+00	7uskta4hrm5o	dd93a70d-562d-4f0e-8453-0aee7ed46cc2
00000000-0000-0000-0000-000000000000	262	dcq22lboqwqr	9547e1f9-306e-4dd2-96fb-89fc33ce7512	t	2025-06-01 22:46:58.803875+00	2025-06-02 02:47:39.031845+00	qbz67oce55re	dd93a70d-562d-4f0e-8453-0aee7ed46cc2
\.


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_providers (id, sso_provider_id, entity_id, metadata_xml, metadata_url, attribute_mapping, created_at, updated_at, name_id_format) FROM stdin;
\.


--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_relay_states (id, sso_provider_id, request_id, for_email, redirect_to, created_at, updated_at, flow_state_id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.schema_migrations (version) FROM stdin;
20171026211738
20171026211808
20171026211834
20180103212743
20180108183307
20180119214651
20180125194653
00
20210710035447
20210722035447
20210730183235
20210909172000
20210927181326
20211122151130
20211124214934
20211202183645
20220114185221
20220114185340
20220224000811
20220323170000
20220429102000
20220531120530
20220614074223
20220811173540
20221003041349
20221003041400
20221011041400
20221020193600
20221021073300
20221021082433
20221027105023
20221114143122
20221114143410
20221125140132
20221208132122
20221215195500
20221215195800
20221215195900
20230116124310
20230116124412
20230131181311
20230322519590
20230402418590
20230411005111
20230508135423
20230523124323
20230818113222
20230914180801
20231027141322
20231114161723
20231117164230
20240115144230
20240214120130
20240306115329
20240314092811
20240427152123
20240612123726
20240729123726
20240802193726
20240806073726
20241009103726
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip, tag) FROM stdin;
7de8b4bf-0d21-4fd6-b8fb-d6320ae28a94	7f2169d3-894f-484f-bf65-8be242c8cd24	2025-05-29 02:26:02.918442+00	2025-06-03 20:14:08.852641+00	\N	aal1	\N	2025-06-03 20:14:08.852554	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Mobile Safari/537.36	76.131.24.187	\N
f3a4c0a6-5d30-417a-91f9-9127b981e48c	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-06-03 07:09:21.862848+00	2025-06-03 20:35:53.956594+00	\N	aal1	\N	2025-06-03 20:35:53.956523	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36	76.131.24.187	\N
21fbec2e-ba85-4d47-8e37-e0d52ca35775	9547e1f9-306e-4dd2-96fb-89fc33ce7512	2025-06-03 21:13:01.062204+00	2025-06-03 21:13:01.062204+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36	76.131.24.187	\N
54262d46-c10e-4bc0-b5b7-5fa3cb594295	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-06-03 21:47:07.236418+00	2025-06-03 21:47:07.236418+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36	76.131.24.187	\N
2a38c4a2-7844-4614-b339-d697ba9069d8	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-06-03 21:55:23.254786+00	2025-06-03 21:55:23.254786+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36	76.131.24.187	\N
2b4fe8e7-c593-4e1e-8223-cd053205850a	c3866d1b-210f-490a-b300-bde91941735b	2025-05-31 04:44:34.284757+00	2025-05-31 05:42:58.96827+00	\N	aal1	\N	2025-05-31 05:42:58.968202	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36	71.211.155.68	\N
9a633493-46af-4296-a046-6946c7c3c70d	9547e1f9-306e-4dd2-96fb-89fc33ce7512	2025-06-03 21:13:01.452588+00	2025-06-03 22:23:27.17001+00	\N	aal1	\N	2025-06-03 22:23:27.169929	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36	76.131.24.187	\N
92c0b2d4-9588-4173-a726-1d4f89cb3d1b	82f7f043-f150-4052-82a7-d98c4c31237c	2025-05-29 17:21:27.965499+00	2025-05-29 19:40:26.416374+00	\N	aal1	\N	2025-05-29 19:40:26.416302	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/136.0.7103.91 Mobile/15E148 Safari/604.1	174.229.56.30	\N
45816520-f650-4f52-a890-bd6f0b72a3d4	b0b0ed7d-538a-4b52-bc1c-f5410677612c	2025-05-30 09:05:38.972128+00	2025-05-31 22:23:06.953035+00	\N	aal1	\N	2025-05-31 22:23:06.952965	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Mobile Safari/537.36	172.59.226.98	\N
dd93a70d-562d-4f0e-8453-0aee7ed46cc2	9547e1f9-306e-4dd2-96fb-89fc33ce7512	2025-06-01 01:37:45.56398+00	2025-06-03 20:37:53.35141+00	\N	aal1	\N	2025-06-03 20:37:53.35134	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Mobile Safari/537.36	76.131.24.187	\N
060b1d37-458b-4073-88e4-547a6de07fce	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-06-03 07:14:08.850774+00	2025-06-03 20:44:47.285675+00	\N	aal1	\N	2025-06-03 20:44:47.285603	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36	76.131.24.187	\N
ee997cba-9a7b-40da-92a1-01eaa71e353b	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-06-03 21:42:50.262661+00	2025-06-03 21:42:50.262661+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36	76.131.24.187	\N
331dfbd4-9b84-4b3a-9010-4f56bbab69d8	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-06-03 21:52:18.412669+00	2025-06-04 00:00:59.445669+00	\N	aal1	\N	2025-06-04 00:00:59.445597	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36	76.131.24.187	\N
4d95d2d2-2aed-4307-9670-aa7d1c9dc3c0	c3866d1b-210f-490a-b300-bde91941735b	2025-05-31 20:10:23.787503+00	2025-05-31 20:10:23.787503+00	\N	aal1	\N	\N	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Mobile Safari/537.36	76.131.24.187	\N
3ae75e5c-f124-4066-9417-90802f117089	1988ae88-45c3-4529-929f-24fe6ed0b93b	2025-05-29 15:59:38.468103+00	2025-05-29 15:59:38.468103+00	\N	aal1	\N	\N	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Mobile Safari/537.36	98.214.160.82	\N
c33b28bd-3d67-4a71-ab95-614ee99fc214	7f2169d3-894f-484f-bf65-8be242c8cd24	2025-06-03 05:06:50.050874+00	2025-06-03 05:06:50.050874+00	\N	aal1	\N	\N	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36	73.153.255.68	\N
8d2e7c28-aa71-4ad1-b5cb-ea2e08bb9b86	06082977-180b-4170-a3d5-72f7005652a9	2025-05-29 02:50:54.975569+00	2025-06-03 06:33:51.594418+00	\N	aal1	\N	2025-06-03 06:33:51.594344	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Mobile Safari/537.36	76.131.24.187	\N
b62cfbd0-8a10-4455-970b-425f227e830c	419646ee-1d59-4497-9fae-60b0eed36064	2025-06-01 00:00:41.718052+00	2025-06-01 00:00:41.718052+00	\N	aal1	\N	\N	Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1	104.28.39.67	\N
\.


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_domains (id, sso_provider_id, domain, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_providers (id, resource_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) FROM stdin;
00000000-0000-0000-0000-000000000000	9547e1f9-306e-4dd2-96fb-89fc33ce7512	authenticated	authenticated	lasryariel@gmail.com	\N	2025-05-24 13:56:41.093896+00	\N		\N		\N			\N	2025-06-03 21:13:01.452511+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "116251500687178227262", "name": "Ariel Lasry", "email": "lasryariel@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocJpdyn5QhuOg-4pLiYi7uwmTgFbw_jsEIwxTvpwJCoZw0X0Aw=s96-c", "full_name": "Ariel Lasry", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocJpdyn5QhuOg-4pLiYi7uwmTgFbw_jsEIwxTvpwJCoZw0X0Aw=s96-c", "provider_id": "116251500687178227262", "email_verified": true, "phone_verified": false}	\N	2025-05-24 13:56:41.080197+00	2025-06-03 22:23:27.165133+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	dfa7ac70-3f2d-47e5-86e4-49bba65a68b5	authenticated	authenticated	support@fanbass.io	\N	2025-05-28 18:18:03.752726+00	\N		\N		\N			\N	2025-06-03 07:09:17.171009+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "107808641427011897080", "name": "FanBass Support", "email": "support@fanbass.io", "picture": "https://lh3.googleusercontent.com/a/ACg8ocKvDjO-AlcdYkEQp2DS7GJPh_Kbgwk55aUzmYHl5Luuva5nPg=s96-c", "full_name": "FanBass Support", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocKvDjO-AlcdYkEQp2DS7GJPh_Kbgwk55aUzmYHl5Luuva5nPg=s96-c", "provider_id": "107808641427011897080", "custom_claims": {"hd": "fanbass.io"}, "email_verified": true, "phone_verified": false}	\N	2025-05-28 18:18:03.735748+00	2025-06-03 07:09:17.173928+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	7f2169d3-894f-484f-bf65-8be242c8cd24	authenticated	authenticated	echo2149@gmail.com	\N	2025-05-29 02:26:02.914637+00	\N		\N		\N			\N	2025-06-03 05:06:50.050804+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "113290904484040490635", "name": "Aiden St. Clair-Dean", "email": "echo2149@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocLXkOwokZgYT3kZSPt8M5RhOzsgNyJjWEnJuFxvQ-gtAOvQrBO8LQ=s96-c", "full_name": "Aiden St. Clair-Dean", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocLXkOwokZgYT3kZSPt8M5RhOzsgNyJjWEnJuFxvQ-gtAOvQrBO8LQ=s96-c", "provider_id": "113290904484040490635", "email_verified": true, "phone_verified": false}	\N	2025-05-29 02:26:02.898095+00	2025-06-03 20:14:08.845542+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	eda854e4-0358-4ae6-b5e2-8bb490e5782a	authenticated	authenticated	admin@fanbass.io	\N	2025-05-24 02:33:25.597996+00	\N		\N		\N			\N	2025-06-03 21:55:23.254714+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "103440462013485736657", "name": "FanBass Admin", "email": "admin@fanbass.io", "picture": "https://lh3.googleusercontent.com/a/ACg8ocJr9jXnrp4S09r6prpw1_taMYR-YTLrayZENrtEfaPKnU2hvg=s96-c", "full_name": "FanBass Admin", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocJr9jXnrp4S09r6prpw1_taMYR-YTLrayZENrtEfaPKnU2hvg=s96-c", "provider_id": "103440462013485736657", "custom_claims": {"hd": "fanbass.io"}, "email_verified": true, "phone_verified": false}	\N	2025-05-24 02:33:25.577272+00	2025-06-04 00:00:59.444226+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	82f7f043-f150-4052-82a7-d98c4c31237c	authenticated	authenticated	eli.v@eliv.com	\N	2025-05-29 17:21:27.963675+00	\N		\N		\N			\N	2025-05-29 17:21:27.965431+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "106842646774411158557", "name": "Eli Verschleiser", "email": "eli.v@eliv.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocLUvy-3540gGVb-ZDvs7gzl2fd6QKduu9PP1wK8ffBrY7LDpQ=s96-c", "full_name": "Eli Verschleiser", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocLUvy-3540gGVb-ZDvs7gzl2fd6QKduu9PP1wK8ffBrY7LDpQ=s96-c", "provider_id": "106842646774411158557", "custom_claims": {"hd": "eliv.com"}, "email_verified": true, "phone_verified": false}	\N	2025-05-29 17:21:27.950606+00	2025-05-29 19:40:26.41448+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	1988ae88-45c3-4529-929f-24fe6ed0b93b	authenticated	authenticated	acehugh@gmail.com	\N	2025-05-29 15:59:38.465538+00	\N		\N		\N			\N	2025-05-29 15:59:38.468036+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "114618827989739603275", "name": "Alec Hugh", "email": "acehugh@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocI6-hrm8xkYFFEpAPY9ttPUgqYa3yIMKtwzmHBasc5cU4fIdUxb=s96-c", "full_name": "Alec Hugh", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocI6-hrm8xkYFFEpAPY9ttPUgqYa3yIMKtwzmHBasc5cU4fIdUxb=s96-c", "provider_id": "114618827989739603275", "email_verified": true, "phone_verified": false}	\N	2025-05-29 15:59:38.446144+00	2025-05-29 15:59:38.474889+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	06082977-180b-4170-a3d5-72f7005652a9	authenticated	authenticated	noahjforman@gmail.com	\N	2025-05-29 02:50:54.970188+00	\N		\N		\N			\N	2025-05-29 02:50:54.975493+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "111669120252205994531", "name": "Noah Forman", "email": "noahjforman@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocL6OQ9T5PbQPTU9hCdzWrKkOc9wrA9IT_f4VL66lca1YsVYhF2c0A=s96-c", "full_name": "Noah Forman", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocL6OQ9T5PbQPTU9hCdzWrKkOc9wrA9IT_f4VL66lca1YsVYhF2c0A=s96-c", "provider_id": "111669120252205994531", "email_verified": true, "phone_verified": false}	\N	2025-05-29 02:50:54.95881+00	2025-06-03 06:33:51.591422+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	b0b0ed7d-538a-4b52-bc1c-f5410677612c	authenticated	authenticated	jonathanjamesprivett@gmail.com	\N	2025-05-30 09:05:38.967589+00	\N		\N		\N			\N	2025-05-30 09:05:38.97205+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "114901621736922906550", "name": "Jonathan Privett", "email": "jonathanjamesprivett@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocK4c4ORRwHhkb3MGD_PTrbuuEgiv-EvGBYZUfijFuEWYdBwQw=s96-c", "full_name": "Jonathan Privett", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocK4c4ORRwHhkb3MGD_PTrbuuEgiv-EvGBYZUfijFuEWYdBwQw=s96-c", "provider_id": "114901621736922906550", "email_verified": true, "phone_verified": false}	\N	2025-05-30 09:05:38.936843+00	2025-05-31 22:23:06.951042+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	419646ee-1d59-4497-9fae-60b0eed36064	authenticated	authenticated	lightning0379@gmail.com	\N	2025-06-01 00:00:41.714403+00	\N		\N		\N			\N	2025-06-01 00:00:41.717973+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "101599941440498930649", "name": "Caleb Forman", "email": "lightning0379@gmail.com", "picture": "https://lh3.googleusercontent.com/a/ACg8ocKn3BELy0vGG4dsmWuUG8icK82eu0xegMdMl88CoXaTZ4rhHw=s96-c", "full_name": "Caleb Forman", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocKn3BELy0vGG4dsmWuUG8icK82eu0xegMdMl88CoXaTZ4rhHw=s96-c", "provider_id": "101599941440498930649", "email_verified": true, "phone_verified": false}	\N	2025-06-01 00:00:41.685724+00	2025-06-01 00:00:41.722926+00	\N	\N			\N		0	\N		\N	f	\N	f
00000000-0000-0000-0000-000000000000	c3866d1b-210f-490a-b300-bde91941735b	authenticated	authenticated	ariel@fanbass.io	\N	2025-05-31 04:44:34.280933+00	\N		\N		\N			\N	2025-05-31 20:10:23.787429+00	{"provider": "google", "providers": ["google"]}	{"iss": "https://accounts.google.com", "sub": "109179280511826067208", "name": "Ariel Lasry", "email": "ariel@fanbass.io", "picture": "https://lh3.googleusercontent.com/a/ACg8ocKa70Z8bUKJFnsac83T-yaI35qD9dZ0I3LMrapkYtiAfwJg4g=s96-c", "full_name": "Ariel Lasry", "avatar_url": "https://lh3.googleusercontent.com/a/ACg8ocKa70Z8bUKJFnsac83T-yaI35qD9dZ0I3LMrapkYtiAfwJg4g=s96-c", "provider_id": "109179280511826067208", "custom_claims": {"hd": "fanbass.io"}, "email_verified": true, "phone_verified": false}	\N	2025-05-31 04:44:34.254055+00	2025-05-31 20:10:23.789041+00	\N	\N			\N		0	\N		\N	f	\N	f
\.


--
-- Data for Name: artist_placement_history; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.artist_placement_history (id, user_id, artist_id, tier, created_at) FROM stdin;
18090c7b-ee4e-4407-bfc1-10779ce9c10c	eda854e4-0358-4ae6-b5e2-8bb490e5782a	e55d78f1-9783-40ea-a802-4fcd58024a44	must_see	2025-05-28 16:33:23.300251+00
fa0c3206-3c92-4273-8654-e3264b61af77	eda854e4-0358-4ae6-b5e2-8bb490e5782a	00bb3ab7-03ae-451d-9c37-44ad2f8e892d	worth_the_effort	2025-05-28 16:33:23.300251+00
8cb40717-a9ae-4001-8640-4d7a6db7faff	eda854e4-0358-4ae6-b5e2-8bb490e5782a	e55d78f1-9783-40ea-a802-4fcd58024a44	must_see	2025-05-28 16:37:23.590207+00
2079ca44-d703-4c3e-91da-ef0dc534e52a	eda854e4-0358-4ae6-b5e2-8bb490e5782a	e55d78f1-9783-40ea-a802-4fcd58024a44	must_see	2025-05-28 16:38:30.116994+00
89ffcee9-5c92-48fa-86fe-f71a0fb1ecc2	eda854e4-0358-4ae6-b5e2-8bb490e5782a	00bb3ab7-03ae-451d-9c37-44ad2f8e892d	depends_on_context	2025-05-28 16:39:08.932064+00
005be4b3-008c-4c13-bc7c-82a77ec75bd8	eda854e4-0358-4ae6-b5e2-8bb490e5782a	e55d78f1-9783-40ea-a802-4fcd58024a44	must_see	2025-05-28 17:24:56.97366+00
61038b32-6d38-4414-b79c-1fbb515b0b61	eda854e4-0358-4ae6-b5e2-8bb490e5782a	00bb3ab7-03ae-451d-9c37-44ad2f8e892d	depends_on_context	2025-05-28 17:24:56.97366+00
3f211759-226f-4465-9476-ed72bc082893	eda854e4-0358-4ae6-b5e2-8bb490e5782a	bda40a00-6f80-4934-8687-2e2946e207c9	worth_the_effort	2025-05-28 17:24:56.97366+00
08817244-dd82-4e4d-aec0-a9d8bd50bd5f	eda854e4-0358-4ae6-b5e2-8bb490e5782a	e55d78f1-9783-40ea-a802-4fcd58024a44	must_see	2025-05-28 17:28:24.191762+00
2675b06f-21b6-4cd3-84a7-4bddc8b33292	eda854e4-0358-4ae6-b5e2-8bb490e5782a	00bb3ab7-03ae-451d-9c37-44ad2f8e892d	depends_on_context	2025-05-28 17:28:24.191762+00
9b10ec14-20b4-44d5-aed4-106fd8a9738f	eda854e4-0358-4ae6-b5e2-8bb490e5782a	bda40a00-6f80-4934-8687-2e2946e207c9	worth_the_effort	2025-05-28 17:28:24.191762+00
8737f15d-45fc-4253-ae58-06e0aeb38956	eda854e4-0358-4ae6-b5e2-8bb490e5782a	201159a2-9103-438a-aed4-f52efd8a0155	nice_to_catch	2025-05-28 17:28:24.191762+00
bfeda695-5d1d-493c-9378-5c86308c17aa	eda854e4-0358-4ae6-b5e2-8bb490e5782a	e55d78f1-9783-40ea-a802-4fcd58024a44	must_see	2025-05-28 17:28:37.923786+00
155da651-3b2d-477a-818c-99c9fdc998cc	eda854e4-0358-4ae6-b5e2-8bb490e5782a	00bb3ab7-03ae-451d-9c37-44ad2f8e892d	depends_on_context	2025-05-28 17:28:37.923786+00
f93cb89c-d10c-49ac-8a5a-8c05cfd3c1a1	eda854e4-0358-4ae6-b5e2-8bb490e5782a	bda40a00-6f80-4934-8687-2e2946e207c9	worth_the_effort	2025-05-28 17:28:37.923786+00
abded586-9f7e-48f2-9e67-a4a3a7a563f8	eda854e4-0358-4ae6-b5e2-8bb490e5782a	201159a2-9103-438a-aed4-f52efd8a0155	nice_to_catch	2025-05-28 17:28:37.923786+00
2e4497aa-f920-4d23-a797-362a717fca52	eda854e4-0358-4ae6-b5e2-8bb490e5782a	925ea8da-12d9-4554-8968-9505e4c09104	worth_the_effort	2025-05-28 17:28:37.923786+00
482a2335-004e-4ae8-8c1c-3954c9eaebaf	eda854e4-0358-4ae6-b5e2-8bb490e5782a	e55d78f1-9783-40ea-a802-4fcd58024a44	must_see	2025-05-28 17:29:38.024198+00
09d437b9-595b-4a33-90ed-a5ed9108b78f	eda854e4-0358-4ae6-b5e2-8bb490e5782a	00bb3ab7-03ae-451d-9c37-44ad2f8e892d	depends_on_context	2025-05-28 17:29:38.024198+00
9df8df80-dad1-4f39-9142-3ddf8798b753	eda854e4-0358-4ae6-b5e2-8bb490e5782a	bda40a00-6f80-4934-8687-2e2946e207c9	worth_the_effort	2025-05-28 17:29:38.024198+00
75e53b25-500a-4cb5-9b99-b76fbcb26f78	eda854e4-0358-4ae6-b5e2-8bb490e5782a	201159a2-9103-438a-aed4-f52efd8a0155	nice_to_catch	2025-05-28 17:29:38.024198+00
9b5a2f3b-1002-4f56-aa9a-746717d10569	eda854e4-0358-4ae6-b5e2-8bb490e5782a	925ea8da-12d9-4554-8968-9505e4c09104	worth_the_effort	2025-05-28 17:29:38.024198+00
b016e50c-3d47-4382-bbe2-35c5448b2de2	eda854e4-0358-4ae6-b5e2-8bb490e5782a	b7d4d8bb-da8e-438f-b781-9d37fd74e4b4	must_see	2025-05-28 17:29:38.024198+00
8e22406d-f294-4a9d-ae61-71420b7bc82f	eda854e4-0358-4ae6-b5e2-8bb490e5782a	e55d78f1-9783-40ea-a802-4fcd58024a44	must_see	2025-05-28 17:29:52.506026+00
00d31ff2-6489-4b2b-997b-426b6a810ad0	eda854e4-0358-4ae6-b5e2-8bb490e5782a	00bb3ab7-03ae-451d-9c37-44ad2f8e892d	depends_on_context	2025-05-28 17:29:52.506026+00
62dfdc1e-d2ed-4891-8462-2a671588bd65	eda854e4-0358-4ae6-b5e2-8bb490e5782a	bda40a00-6f80-4934-8687-2e2946e207c9	worth_the_effort	2025-05-28 17:29:52.506026+00
cd050521-ac77-4145-b188-56de7a1bc23b	eda854e4-0358-4ae6-b5e2-8bb490e5782a	201159a2-9103-438a-aed4-f52efd8a0155	nice_to_catch	2025-05-28 17:29:52.506026+00
628b0413-8108-4d3a-a3bf-9f9095378b94	eda854e4-0358-4ae6-b5e2-8bb490e5782a	925ea8da-12d9-4554-8968-9505e4c09104	worth_the_effort	2025-05-28 17:29:52.506026+00
91bda64d-5753-44f8-ab2b-cc644192312e	eda854e4-0358-4ae6-b5e2-8bb490e5782a	b7d4d8bb-da8e-438f-b781-9d37fd74e4b4	must_see	2025-05-28 17:29:52.506026+00
83933c92-d04b-4d9e-968e-ac2627d9433b	eda854e4-0358-4ae6-b5e2-8bb490e5782a	b6582170-250f-4c8f-940b-f8422b2dc3a1	must_see	2025-05-28 17:29:52.506026+00
7afdb902-3651-4a1f-80e6-73aade6a082d	eda854e4-0358-4ae6-b5e2-8bb490e5782a	e55d78f1-9783-40ea-a802-4fcd58024a44	must_see	2025-05-28 17:30:28.67381+00
5ff24855-a99c-45f6-b24e-2c1a14ecf5f7	eda854e4-0358-4ae6-b5e2-8bb490e5782a	00bb3ab7-03ae-451d-9c37-44ad2f8e892d	depends_on_context	2025-05-28 17:30:28.67381+00
e5f24cc5-0bcb-4215-ae9a-838386a1758c	eda854e4-0358-4ae6-b5e2-8bb490e5782a	bda40a00-6f80-4934-8687-2e2946e207c9	worth_the_effort	2025-05-28 17:30:28.67381+00
0bd86c0a-839b-49da-852a-abe4736a87e4	eda854e4-0358-4ae6-b5e2-8bb490e5782a	201159a2-9103-438a-aed4-f52efd8a0155	nice_to_catch	2025-05-28 17:30:28.67381+00
212154b1-874b-4cce-af0d-fef0223678a3	eda854e4-0358-4ae6-b5e2-8bb490e5782a	925ea8da-12d9-4554-8968-9505e4c09104	worth_the_effort	2025-05-28 17:30:28.67381+00
c6dbb37c-3360-4050-86e6-ff297c11d473	eda854e4-0358-4ae6-b5e2-8bb490e5782a	b7d4d8bb-da8e-438f-b781-9d37fd74e4b4	must_see	2025-05-28 17:30:28.67381+00
1ab330fe-8a17-4fa6-b796-d8eec43eeeab	eda854e4-0358-4ae6-b5e2-8bb490e5782a	b6582170-250f-4c8f-940b-f8422b2dc3a1	must_see	2025-05-28 17:30:28.67381+00
4e512c01-d333-4416-9d2e-be0c06b091b2	eda854e4-0358-4ae6-b5e2-8bb490e5782a	e55d78f1-9783-40ea-a802-4fcd58024a44	must_see	2025-05-28 17:31:43.18641+00
42d7b495-9356-4608-9c18-0528c2c6673c	eda854e4-0358-4ae6-b5e2-8bb490e5782a	00bb3ab7-03ae-451d-9c37-44ad2f8e892d	depends_on_context	2025-05-28 17:31:43.18641+00
abbf215f-a4dd-49d2-aa64-9de85a27d16c	eda854e4-0358-4ae6-b5e2-8bb490e5782a	bda40a00-6f80-4934-8687-2e2946e207c9	worth_the_effort	2025-05-28 17:31:43.18641+00
b1d0c88c-1cc8-4641-ab3d-ce5e0e351663	eda854e4-0358-4ae6-b5e2-8bb490e5782a	201159a2-9103-438a-aed4-f52efd8a0155	nice_to_catch	2025-05-28 17:31:43.18641+00
0bc2df86-6c39-4dab-9e41-c260bbf85180	eda854e4-0358-4ae6-b5e2-8bb490e5782a	925ea8da-12d9-4554-8968-9505e4c09104	worth_the_effort	2025-05-28 17:31:43.18641+00
d9b801b6-28e1-482f-9234-384a7f8986cc	eda854e4-0358-4ae6-b5e2-8bb490e5782a	b7d4d8bb-da8e-438f-b781-9d37fd74e4b4	must_see	2025-05-28 17:31:43.18641+00
d6515793-1388-401e-a92d-856c36dce4aa	eda854e4-0358-4ae6-b5e2-8bb490e5782a	b6582170-250f-4c8f-940b-f8422b2dc3a1	must_see	2025-05-28 17:31:43.18641+00
27efdced-c825-4efc-a1f5-7c1248d10c13	eda854e4-0358-4ae6-b5e2-8bb490e5782a	8d672b69-4006-4ed0-bb5e-8de6c504223d	nice_to_catch	2025-05-28 17:31:43.18641+00
2c93ba09-be34-4e9b-a0b1-1a60d8bd6d79	eda854e4-0358-4ae6-b5e2-8bb490e5782a	e55d78f1-9783-40ea-a802-4fcd58024a44	must_see	2025-05-28 17:31:55.261903+00
e7e74cbb-6afe-48fd-bc1c-3b283f0709e9	eda854e4-0358-4ae6-b5e2-8bb490e5782a	00bb3ab7-03ae-451d-9c37-44ad2f8e892d	depends_on_context	2025-05-28 17:31:55.261903+00
eda4b171-c2c5-43bc-8475-e51df653e79e	eda854e4-0358-4ae6-b5e2-8bb490e5782a	bda40a00-6f80-4934-8687-2e2946e207c9	worth_the_effort	2025-05-28 17:31:55.261903+00
64200416-0424-484c-91b3-e3777589f179	eda854e4-0358-4ae6-b5e2-8bb490e5782a	201159a2-9103-438a-aed4-f52efd8a0155	nice_to_catch	2025-05-28 17:31:55.261903+00
5a700100-fac3-456c-bc48-2352573e61e1	eda854e4-0358-4ae6-b5e2-8bb490e5782a	925ea8da-12d9-4554-8968-9505e4c09104	worth_the_effort	2025-05-28 17:31:55.261903+00
91839f17-0c63-4d15-8262-985aa9d3fb3e	eda854e4-0358-4ae6-b5e2-8bb490e5782a	b7d4d8bb-da8e-438f-b781-9d37fd74e4b4	must_see	2025-05-28 17:31:55.261903+00
2ab233d5-99dd-434d-888d-81825bc721b7	eda854e4-0358-4ae6-b5e2-8bb490e5782a	b6582170-250f-4c8f-940b-f8422b2dc3a1	must_see	2025-05-28 17:31:55.261903+00
5b2d1e89-14bf-4409-902b-52c9900e10c8	eda854e4-0358-4ae6-b5e2-8bb490e5782a	8d672b69-4006-4ed0-bb5e-8de6c504223d	nice_to_catch	2025-05-28 17:31:55.261903+00
a4b09d65-cf2c-49c1-81d7-2ae9526b27ae	eda854e4-0358-4ae6-b5e2-8bb490e5782a	e55d78f1-9783-40ea-a802-4fcd58024a44	must_see	2025-05-28 17:33:11.325796+00
e948a296-c8da-4400-a472-36a12010490d	eda854e4-0358-4ae6-b5e2-8bb490e5782a	00bb3ab7-03ae-451d-9c37-44ad2f8e892d	depends_on_context	2025-05-28 17:33:11.325796+00
87fb1d31-f004-425a-bb22-e322d501d4dd	eda854e4-0358-4ae6-b5e2-8bb490e5782a	bda40a00-6f80-4934-8687-2e2946e207c9	worth_the_effort	2025-05-28 17:33:11.325796+00
166f08ad-5795-410f-a221-ccb413964e40	eda854e4-0358-4ae6-b5e2-8bb490e5782a	201159a2-9103-438a-aed4-f52efd8a0155	nice_to_catch	2025-05-28 17:33:11.325796+00
2173a770-7b43-4f63-bc02-685c6ae843be	eda854e4-0358-4ae6-b5e2-8bb490e5782a	925ea8da-12d9-4554-8968-9505e4c09104	worth_the_effort	2025-05-28 17:33:11.325796+00
5e7b6e5e-e6fe-4535-a088-e6d23463a2cd	eda854e4-0358-4ae6-b5e2-8bb490e5782a	b7d4d8bb-da8e-438f-b781-9d37fd74e4b4	must_see	2025-05-28 17:33:11.325796+00
a901b0ae-3cc6-48f7-ab3b-9246d0edd2b9	eda854e4-0358-4ae6-b5e2-8bb490e5782a	b6582170-250f-4c8f-940b-f8422b2dc3a1	worth_the_effort	2025-05-28 17:33:11.325796+00
0b382f64-06b9-44fa-873f-738979297364	eda854e4-0358-4ae6-b5e2-8bb490e5782a	8d672b69-4006-4ed0-bb5e-8de6c504223d	nice_to_catch	2025-05-28 17:33:11.325796+00
d3374006-6b37-4830-9670-bafe23a7b69c	eda854e4-0358-4ae6-b5e2-8bb490e5782a	e55d78f1-9783-40ea-a802-4fcd58024a44	must_see	2025-05-28 17:33:24.182615+00
0475ba28-cbcb-4b5b-92ad-7d190618f7ce	eda854e4-0358-4ae6-b5e2-8bb490e5782a	00bb3ab7-03ae-451d-9c37-44ad2f8e892d	depends_on_context	2025-05-28 17:33:24.182615+00
9b2903d9-c17d-45ed-895f-0fe5be06dde9	eda854e4-0358-4ae6-b5e2-8bb490e5782a	bda40a00-6f80-4934-8687-2e2946e207c9	worth_the_effort	2025-05-28 17:33:24.182615+00
3bf659ca-c086-47be-8fc9-cf6c6c2dda59	eda854e4-0358-4ae6-b5e2-8bb490e5782a	201159a2-9103-438a-aed4-f52efd8a0155	nice_to_catch	2025-05-28 17:33:24.182615+00
6f23d8b9-5f51-4131-986c-c22e3f02a326	eda854e4-0358-4ae6-b5e2-8bb490e5782a	925ea8da-12d9-4554-8968-9505e4c09104	worth_the_effort	2025-05-28 17:33:24.182615+00
b6766c89-7526-4092-95cb-6b497d498eb8	eda854e4-0358-4ae6-b5e2-8bb490e5782a	b7d4d8bb-da8e-438f-b781-9d37fd74e4b4	must_see	2025-05-28 17:33:24.182615+00
f1b9ae1d-a94d-4176-876a-ee8392397553	eda854e4-0358-4ae6-b5e2-8bb490e5782a	b6582170-250f-4c8f-940b-f8422b2dc3a1	must_see	2025-05-28 17:33:24.182615+00
520a506b-6d07-41df-a97f-c85b752a3c16	eda854e4-0358-4ae6-b5e2-8bb490e5782a	8d672b69-4006-4ed0-bb5e-8de6c504223d	nice_to_catch	2025-05-28 17:33:24.182615+00
8ab13d25-273b-42e3-a6f2-d9b2eebe8573	eda854e4-0358-4ae6-b5e2-8bb490e5782a	b6582170-250f-4c8f-940b-f8422b2dc3a1	must_see	2025-05-28 17:43:01.644742+00
30fd6130-70ca-451a-bc8d-b7980f78023c	eda854e4-0358-4ae6-b5e2-8bb490e5782a	201159a2-9103-438a-aed4-f52efd8a0155	worth_the_effort	2025-05-28 17:55:55.423088+00
7974680d-d469-4921-8412-ae4a00606d4d	eda854e4-0358-4ae6-b5e2-8bb490e5782a	b7d4d8bb-da8e-438f-b781-9d37fd74e4b4	depends_on_context	2025-05-28 17:56:03.77041+00
0a5458f7-eacb-4690-894a-0c293c9fb59d	eda854e4-0358-4ae6-b5e2-8bb490e5782a	feace927-62d7-4aff-9628-ae72bbb3d35b	depends_on_context	2025-05-28 18:11:54.818657+00
aa4a1f18-8fea-4dcc-ab2a-e415ee17786b	eda854e4-0358-4ae6-b5e2-8bb490e5782a	201159a2-9103-438a-aed4-f52efd8a0155	depends_on_context	2025-05-28 18:17:50.881215+00
c99e58e9-23a8-40f4-b5c4-8bea5668819d	eda854e4-0358-4ae6-b5e2-8bb490e5782a	419ab7b0-624f-4d9c-8b0f-bc8402121f3b	unranked	2025-05-28 18:36:40.843603+00
bab42d79-67d0-45bf-a324-d8dad87120f4	eda854e4-0358-4ae6-b5e2-8bb490e5782a	a15aa35b-fb50-493b-8acd-a7df2ecb855a	unranked	2025-05-28 18:43:22.424418+00
236a109b-0314-46da-95a4-c29e611d084b	eda854e4-0358-4ae6-b5e2-8bb490e5782a	ca558feb-ad2a-4fc6-9f6a-a3ae28dde382	unranked	2025-05-28 18:46:27.349821+00
23f02a26-1878-4d46-bba7-4a64a9258e9c	eda854e4-0358-4ae6-b5e2-8bb490e5782a	8a9874dd-8991-4067-a155-48677c1c5a2e	unranked	2025-05-28 18:49:11.115948+00
b2c98566-6c33-45b3-b573-b01dcbcb74f1	eda854e4-0358-4ae6-b5e2-8bb490e5782a	8a9874dd-8991-4067-a155-48677c1c5a2e	depends_on_context	2025-05-28 18:49:13.554848+00
eea70e7c-5cfe-40f2-8f85-dd04422613f9	dfa7ac70-3f2d-47e5-86e4-49bba65a68b5	e55d78f1-9783-40ea-a802-4fcd58024a44	unranked	2025-05-28 18:50:46.924523+00
6ab2eddd-b44f-4254-9f9e-8a2fc7219cc0	9547e1f9-306e-4dd2-96fb-89fc33ce7512	b6582170-250f-4c8f-940b-f8422b2dc3a1	unranked	2025-05-28 21:43:19.064335+00
d3e6602f-defe-4c4c-b820-c8226bae8b16	9547e1f9-306e-4dd2-96fb-89fc33ce7512	b6582170-250f-4c8f-940b-f8422b2dc3a1	must_see	2025-05-28 21:43:21.578713+00
af785d71-6f19-4511-ae9a-71f617a32ff5	eda854e4-0358-4ae6-b5e2-8bb490e5782a	0abcd924-b5fa-4da6-ac81-8d09c7fa74ad	unranked	2025-05-28 22:18:13.41766+00
eb67905f-830f-4d33-bff1-c610e762ed6b	eda854e4-0358-4ae6-b5e2-8bb490e5782a	1ef315d8-9eef-48be-bbc8-b9728991ac10	unranked	2025-05-28 22:18:17.8023+00
bd0585bc-5a96-4393-9d10-6ca4b7e6c14f	9547e1f9-306e-4dd2-96fb-89fc33ce7512	0abcd924-b5fa-4da6-ac81-8d09c7fa74ad	unranked	2025-05-28 22:46:09.08647+00
e2a48c59-d05d-442e-ae13-e5b9bdf8a0e0	9547e1f9-306e-4dd2-96fb-89fc33ce7512	0abcd924-b5fa-4da6-ac81-8d09c7fa74ad	nice_to_catch	2025-05-28 22:46:12.484066+00
8f36f3d1-1690-48c1-a926-3875108fe0b3	9547e1f9-306e-4dd2-96fb-89fc33ce7512	0abcd924-b5fa-4da6-ac81-8d09c7fa74ad	worth_the_effort	2025-05-28 22:46:14.681013+00
c2f3979d-e041-4d52-8d4c-a38ce9cc2ff9	9547e1f9-306e-4dd2-96fb-89fc33ce7512	91f2f3b2-7222-4f54-a961-71152e5fb8b9	unranked	2025-05-29 01:26:11.593782+00
9cf7d787-cd34-4c47-9c06-dc6d16189958	9547e1f9-306e-4dd2-96fb-89fc33ce7512	91f2f3b2-7222-4f54-a961-71152e5fb8b9	must_see	2025-05-29 01:26:15.369102+00
6c36f5df-e8ed-4c17-aa62-cfa34686771a	9547e1f9-306e-4dd2-96fb-89fc33ce7512	03198e4d-0bd0-40bb-8a15-d07c3ace24e2	unranked	2025-05-29 01:26:29.692991+00
2846ae13-a832-4b24-a6e0-18554e9dedcb	9547e1f9-306e-4dd2-96fb-89fc33ce7512	03198e4d-0bd0-40bb-8a15-d07c3ace24e2	must_see	2025-05-29 01:26:34.790917+00
b6b91c48-d964-4dfe-9d54-e4054e646741	9547e1f9-306e-4dd2-96fb-89fc33ce7512	5deaa96a-b9e9-42c6-93b3-54fed8a6fa66	unranked	2025-05-29 02:25:00.059394+00
6b11918b-d987-48f7-b893-56f951f717b0	9547e1f9-306e-4dd2-96fb-89fc33ce7512	5deaa96a-b9e9-42c6-93b3-54fed8a6fa66	must_see	2025-05-29 02:25:05.077338+00
331b0a5f-5687-4a4b-86fb-4fa498611765	9547e1f9-306e-4dd2-96fb-89fc33ce7512	af19c3d0-4797-46bb-8ad5-cf818a693ac3	unranked	2025-05-29 02:25:53.533482+00
e72a4858-4884-4224-8896-a60ab7baecb5	9547e1f9-306e-4dd2-96fb-89fc33ce7512	af19c3d0-4797-46bb-8ad5-cf818a693ac3	nice_to_catch	2025-05-29 02:26:04.003303+00
795a1fd9-309e-469f-a8e5-689878d73328	7f2169d3-894f-484f-bf65-8be242c8cd24	f1475be9-7380-4d9c-941b-bee134b996e8	unranked	2025-05-29 02:26:11.900923+00
8088fccf-85d4-44cf-8f4a-6af7b8e10e4f	7f2169d3-894f-484f-bf65-8be242c8cd24	f1475be9-7380-4d9c-941b-bee134b996e8	must_see	2025-05-29 02:26:17.281793+00
641dc10c-3977-4ec5-83b7-71c6d4095b48	7f2169d3-894f-484f-bf65-8be242c8cd24	8447d406-ca7a-4e33-a432-db89fd5619ac	unranked	2025-05-29 02:26:26.474816+00
1f3852f7-8770-47e3-b540-4c0ab8bc5ed4	7f2169d3-894f-484f-bf65-8be242c8cd24	a086100e-92d9-4f7a-a69d-82ea9e2661d3	unranked	2025-05-29 02:26:51.689923+00
5c64548c-3148-4629-96fb-e5c9773bf0e5	7f2169d3-894f-484f-bf65-8be242c8cd24	9d16e7fb-13dc-4fe4-aefc-198cf833ae25	unranked	2025-05-29 02:29:19.728772+00
6b6b453a-185c-4b62-8ee0-596bcf51b240	7f2169d3-894f-484f-bf65-8be242c8cd24	a086100e-92d9-4f7a-a69d-82ea9e2661d3	must_see	2025-05-29 02:29:26.192821+00
92a71e97-f858-48e4-b84f-a96457171f20	7f2169d3-894f-484f-bf65-8be242c8cd24	8447d406-ca7a-4e33-a432-db89fd5619ac	nice_to_catch	2025-05-29 02:29:30.59246+00
fa2d4ccf-1c74-4a3e-a876-a231d502f59b	7f2169d3-894f-484f-bf65-8be242c8cd24	9d16e7fb-13dc-4fe4-aefc-198cf833ae25	depends_on_context	2025-05-29 02:29:37.022873+00
00d3425a-1e58-44d8-b3a9-cad1b9f22ced	06082977-180b-4170-a3d5-72f7005652a9	af19c3d0-4797-46bb-8ad5-cf818a693ac3	unranked	2025-05-29 02:51:10.162792+00
13c45827-2fbd-4ff5-9195-84eb1a840a1e	06082977-180b-4170-a3d5-72f7005652a9	2ff236d1-79c7-4024-82e2-36ab8448b544	unranked	2025-05-29 02:51:20.216575+00
447e9cd1-d6d8-4d73-bda3-7e667d1697fa	06082977-180b-4170-a3d5-72f7005652a9	2ff236d1-79c7-4024-82e2-36ab8448b544	must_see	2025-05-29 02:51:25.423498+00
f18106f6-121f-4ec1-9967-f413dcbb381f	06082977-180b-4170-a3d5-72f7005652a9	af19c3d0-4797-46bb-8ad5-cf818a693ac3	worth_the_effort	2025-05-29 02:51:30.128916+00
b7b151a6-676d-47d9-bbf8-1983b189711d	7f2169d3-894f-484f-bf65-8be242c8cd24	b0201b37-2235-4f7d-8003-1a997ce45ec7	unranked	2025-05-29 03:52:21.381331+00
83c76a7b-4e3b-4f74-b6a1-6772636beb68	7f2169d3-894f-484f-bf65-8be242c8cd24	2738faf7-37f0-4185-949a-89cfd3886c0a	unranked	2025-05-29 03:52:51.596732+00
212ac107-8b73-4b4a-a8f0-7d5b2e14563f	7f2169d3-894f-484f-bf65-8be242c8cd24	cbe86f61-e078-4e41-a080-e3cb34655b1a	unranked	2025-05-29 03:53:00.151998+00
76945770-5753-408e-903c-4a107e095bbe	7f2169d3-894f-484f-bf65-8be242c8cd24	cbe86f61-e078-4e41-a080-e3cb34655b1a	unranked	2025-05-29 03:53:00.201779+00
32e41ccc-17d8-4f81-8ef4-5bf400c374f1	7f2169d3-894f-484f-bf65-8be242c8cd24	251010cf-e3e4-464b-b9bb-a5d004a87436	unranked	2025-05-29 03:53:10.058892+00
2f639214-ea53-4435-b3d6-f4ef44bfc90c	7f2169d3-894f-484f-bf65-8be242c8cd24	529e0560-6c77-4f9a-ba42-d33a2a5be212	unranked	2025-05-29 03:53:17.101493+00
0192c54e-096b-4f16-8096-06f46ad1ae64	7f2169d3-894f-484f-bf65-8be242c8cd24	6b4f0e47-8d36-4f0c-8de3-e4d2f0bdaf4f	unranked	2025-05-29 03:53:36.860516+00
c2b5b7fc-39e0-4d6f-a867-efddb82917b3	7f2169d3-894f-484f-bf65-8be242c8cd24	896d1939-d580-4c04-86d5-55fc7b4eae9b	unranked	2025-05-29 03:53:40.758079+00
56374bd3-22c4-4c73-b99f-9327fa8c9fe0	7f2169d3-894f-484f-bf65-8be242c8cd24	0e8d2c15-ccdd-4943-9944-15fcc2088c8d	unranked	2025-05-29 03:53:44.691757+00
91052bab-1230-4b2d-9ede-917ad055b4ad	7f2169d3-894f-484f-bf65-8be242c8cd24	3c93268e-2cb9-4178-aa98-de903cee400e	unranked	2025-05-29 03:53:58.494882+00
6856774b-9380-45a2-9ed7-add2a89483f0	7f2169d3-894f-484f-bf65-8be242c8cd24	a0b3fdde-922b-4ad8-97c9-1680acde14c6	unranked	2025-05-29 03:54:02.155243+00
f0b40fb4-b767-470a-8945-383410913428	7f2169d3-894f-484f-bf65-8be242c8cd24	5433d511-91ae-47d4-9300-b60debf25374	unranked	2025-05-29 03:54:25.191095+00
c41954d5-177c-450b-929b-9a77df37d9b8	7f2169d3-894f-484f-bf65-8be242c8cd24	04a6c2ff-926a-4e3e-8998-607f87cc44a4	unranked	2025-05-29 03:54:31.799534+00
88a1fec4-e2e8-41e5-bb79-d92fe6f18082	7f2169d3-894f-484f-bf65-8be242c8cd24	6a2d3037-1e9d-4716-a7e4-9876a2d654d9	unranked	2025-05-29 03:54:43.978347+00
d2978b4c-0725-4313-bc5a-7f46301f7607	7f2169d3-894f-484f-bf65-8be242c8cd24	0dfda089-c25b-4616-859f-fb3e0f6887df	unranked	2025-05-29 03:54:49.381769+00
c65d1246-8f9c-48d5-9f8e-0dcecd47e38a	7f2169d3-894f-484f-bf65-8be242c8cd24	c328eee0-e7a7-4898-92fc-03986af2315b	unranked	2025-05-29 03:55:00.570976+00
0abca9d7-8428-43cf-a497-b399abdbc467	7f2169d3-894f-484f-bf65-8be242c8cd24	c12473f3-6818-43ec-b547-22773a403e5e	unranked	2025-05-29 03:55:02.956026+00
a000c5d0-ff33-434d-89fd-42179accb3c1	7f2169d3-894f-484f-bf65-8be242c8cd24	cfb93b76-9df9-4359-8757-384063e62ef2	unranked	2025-05-29 03:55:06.612657+00
a10d2275-8b1c-4495-9485-c4b6d622c304	7f2169d3-894f-484f-bf65-8be242c8cd24	9e5899d6-ad8b-4a43-9fc6-ec062ad6fbe5	unranked	2025-05-29 03:55:09.259845+00
9fa712cb-d5b1-41ea-926a-0565cc0d3164	7f2169d3-894f-484f-bf65-8be242c8cd24	d4bc2ec6-4a61-4fa3-837d-4a1021397a48	unranked	2025-05-29 03:55:10.052498+00
446dcb35-e756-4615-af46-0f274723fe6e	7f2169d3-894f-484f-bf65-8be242c8cd24	312b7a85-2a3c-4c22-ab67-c6b164c34c76	unranked	2025-05-29 03:55:13.65391+00
d6699883-e47e-4d46-b5ae-e1288b3752b6	7f2169d3-894f-484f-bf65-8be242c8cd24	9c4c2751-2f32-468e-a11f-8b1c93af25d6	unranked	2025-05-29 04:10:34.807917+00
a62933d6-d1c8-49ed-bea7-8656fe9847a3	7f2169d3-894f-484f-bf65-8be242c8cd24	d4078249-02ee-4c40-9dfc-281dc176f165	unranked	2025-05-29 04:11:03.051873+00
790ec707-1141-4d3f-bbf2-ea98ffaf5d2a	7f2169d3-894f-484f-bf65-8be242c8cd24	b14f3f69-f29e-4695-9c0e-1b933c30f02d	unranked	2025-05-29 04:11:05.417884+00
c34fd1ef-b0ac-40d7-824b-bce43328e999	7f2169d3-894f-484f-bf65-8be242c8cd24	af19c3d0-4797-46bb-8ad5-cf818a693ac3	unranked	2025-05-29 04:11:10.604136+00
40ef7556-6a98-434b-82e0-7ae283e01b12	7f2169d3-894f-484f-bf65-8be242c8cd24	f0efedf2-57e4-4680-8f61-758b5eb44d25	unranked	2025-05-29 04:11:18.782946+00
0bc02c03-5ecc-462c-9d29-2159c08515bd	7f2169d3-894f-484f-bf65-8be242c8cd24	baa43c55-7964-4641-a10c-3d48b4687e61	unranked	2025-05-29 04:11:58.582089+00
74b9aaf5-e6e7-4e91-8fe2-fe4a7408076d	7f2169d3-894f-484f-bf65-8be242c8cd24	09bcd870-e9c0-4e32-af0b-645558f64e44	unranked	2025-05-29 04:12:00.366871+00
4502f161-2d13-4d4f-90a0-6612d1aa8a96	7f2169d3-894f-484f-bf65-8be242c8cd24	6d97d81b-01c0-4c37-a28f-d2067f3e9509	unranked	2025-05-29 04:12:12.055473+00
c8e73940-862e-4b36-8cb5-fe22ef6bb4d5	7f2169d3-894f-484f-bf65-8be242c8cd24	c88ed6f7-bf92-4615-aa57-4e350b785df0	unranked	2025-05-29 04:12:13.709186+00
0cd9e2ae-a7b4-4a67-8c72-b34b7f934fd0	7f2169d3-894f-484f-bf65-8be242c8cd24	efcf0d8c-13e5-4254-94b5-4c58ca7ae811	unranked	2025-05-29 04:12:26.421344+00
ba80fb21-0df8-4fc1-94f8-788c99c2dcea	7f2169d3-894f-484f-bf65-8be242c8cd24	effeab64-1222-4afb-91c4-9eaf8b89efe5	unranked	2025-05-29 04:12:29.834447+00
52dd3c5b-a20b-4448-8c7d-7494aeec6700	7f2169d3-894f-484f-bf65-8be242c8cd24	ba136da2-7e08-4b99-989f-997cc7da5a4c	unranked	2025-05-29 04:12:33.416848+00
667cb372-f952-4460-823b-62c931f3fd31	7f2169d3-894f-484f-bf65-8be242c8cd24	14de17b4-ad41-4c59-af07-7c15f73d2df2	unranked	2025-05-29 04:12:39.558334+00
e06c0a8e-62d2-4f2b-8c87-f8737bc187c0	7f2169d3-894f-484f-bf65-8be242c8cd24	d9aacecd-4e49-4504-99a7-7865352caed3	unranked	2025-05-29 04:12:47.321114+00
1595e54c-1ae0-4572-99c9-cb273c95eb29	7f2169d3-894f-484f-bf65-8be242c8cd24	d9dc1b8a-4e9d-4284-a5bf-0cf24cc75e50	unranked	2025-05-29 04:12:49.965248+00
7a130001-3cf5-4a30-a677-69b7e35ad9bd	7f2169d3-894f-484f-bf65-8be242c8cd24	03198e4d-0bd0-40bb-8a15-d07c3ace24e2	unranked	2025-05-29 04:12:56.566929+00
f5fec209-cd60-4455-a437-6ec1db329d1f	7f2169d3-894f-484f-bf65-8be242c8cd24	f033c53c-fca2-4fff-bc3c-1e49e2163515	unranked	2025-05-29 04:13:01.645084+00
cfb6dba5-6185-49e4-8f4b-2822169c5eb6	7f2169d3-894f-484f-bf65-8be242c8cd24	8787935e-a836-41f7-bcb0-e239701eedad	unranked	2025-05-29 04:13:09.456662+00
a079a69f-2b5f-4761-b6df-05e74e1bd764	7f2169d3-894f-484f-bf65-8be242c8cd24	e9e87d59-3ebe-4bd2-9a13-9787d02610de	unranked	2025-05-29 04:13:10.600154+00
1c93ce40-442b-4f84-981f-bfdbe4df7b35	7f2169d3-894f-484f-bf65-8be242c8cd24	91b4afa4-e104-473b-8cc6-7a31688e8e1c	unranked	2025-05-29 04:13:14.819667+00
a93f0dcb-597c-47ed-867f-42c83cf4ebbe	7f2169d3-894f-484f-bf65-8be242c8cd24	91b4afa4-e104-473b-8cc6-7a31688e8e1c	nice_to_catch	2025-05-29 04:13:28.007396+00
ded3cb11-3161-4b65-8e76-efd2032c7762	7f2169d3-894f-484f-bf65-8be242c8cd24	e9e87d59-3ebe-4bd2-9a13-9787d02610de	worth_the_effort	2025-05-29 04:13:33.225186+00
d45bd4d0-4271-4219-981f-eeaecd3600bf	7f2169d3-894f-484f-bf65-8be242c8cd24	8787935e-a836-41f7-bcb0-e239701eedad	worth_the_effort	2025-05-29 04:13:35.587932+00
ba4994ae-64db-42f5-ace0-3a74240a1e6d	7f2169d3-894f-484f-bf65-8be242c8cd24	03198e4d-0bd0-40bb-8a15-d07c3ace24e2	must_see	2025-05-29 04:13:40.386909+00
6afc0f9a-7f3d-4f78-a20c-faffa1827f0a	7f2169d3-894f-484f-bf65-8be242c8cd24	d9dc1b8a-4e9d-4284-a5bf-0cf24cc75e50	worth_the_effort	2025-05-29 04:13:42.442081+00
33fdbcc7-697c-403a-8c9b-57b7ead672fb	7f2169d3-894f-484f-bf65-8be242c8cd24	d9aacecd-4e49-4504-99a7-7865352caed3	worth_the_effort	2025-05-29 04:13:44.151378+00
fe1da627-d2c8-48f8-88bb-bf84ed492014	7f2169d3-894f-484f-bf65-8be242c8cd24	91f2f3b2-7222-4f54-a961-71152e5fb8b9	unranked	2025-05-29 04:13:53.186517+00
34e20e69-0ec2-4c1b-bc44-ac69b2fea3cc	7f2169d3-894f-484f-bf65-8be242c8cd24	91f2f3b2-7222-4f54-a961-71152e5fb8b9	must_see	2025-05-29 04:13:58.028044+00
3762828c-c4d3-420b-9308-687419eeaf40	7f2169d3-894f-484f-bf65-8be242c8cd24	6d97d81b-01c0-4c37-a28f-d2067f3e9509	worth_the_effort	2025-05-29 04:14:09.791501+00
69d7be1d-c126-44f3-80c4-19cba8f750cf	7f2169d3-894f-484f-bf65-8be242c8cd24	c88ed6f7-bf92-4615-aa57-4e350b785df0	nice_to_catch	2025-05-29 04:14:13.139076+00
816c4506-7ddd-4d96-94b4-1130acb003e2	7f2169d3-894f-484f-bf65-8be242c8cd24	09bcd870-e9c0-4e32-af0b-645558f64e44	nice_to_catch	2025-05-29 04:14:16.415241+00
acd504cd-5294-43ec-8c03-e7b69d06ae4b	7f2169d3-894f-484f-bf65-8be242c8cd24	af19c3d0-4797-46bb-8ad5-cf818a693ac3	worth_the_effort	2025-05-29 04:14:19.051667+00
d6c861ff-54af-4d01-9f7c-b39670a3f565	7f2169d3-894f-484f-bf65-8be242c8cd24	d4078249-02ee-4c40-9dfc-281dc176f165	must_see	2025-05-29 04:14:22.494784+00
b2fcbb5a-67b8-497b-9d6a-ff5a70b12aef	7f2169d3-894f-484f-bf65-8be242c8cd24	c328eee0-e7a7-4898-92fc-03986af2315b	worth_the_effort	2025-05-29 04:14:24.555887+00
c139ed55-cffd-4c5c-858d-ab4d2c515874	7f2169d3-894f-484f-bf65-8be242c8cd24	6a2d3037-1e9d-4716-a7e4-9876a2d654d9	must_see	2025-05-29 04:14:35.285961+00
ceaec1b2-cc27-4e26-a71f-d5c76cdc357a	7f2169d3-894f-484f-bf65-8be242c8cd24	0e8d2c15-ccdd-4943-9944-15fcc2088c8d	nice_to_catch	2025-05-29 04:14:38.964425+00
14b9c2c5-7bec-465a-af6f-ff4628ed5fcd	7f2169d3-894f-484f-bf65-8be242c8cd24	3c93268e-2cb9-4178-aa98-de903cee400e	must_see	2025-05-29 04:14:42.368213+00
5e4b9346-b989-41cb-88e3-793b478a31b4	7f2169d3-894f-484f-bf65-8be242c8cd24	04a6c2ff-926a-4e3e-8998-607f87cc44a4	worth_the_effort	2025-05-29 04:14:49.608721+00
c1dd326d-af09-40a9-ad6c-610057b85d19	7f2169d3-894f-484f-bf65-8be242c8cd24	b14f3f69-f29e-4695-9c0e-1b933c30f02d	must_see	2025-05-29 04:14:51.56923+00
579e8f10-38a4-4824-b435-71fd7d52c932	7f2169d3-894f-484f-bf65-8be242c8cd24	a0b3fdde-922b-4ad8-97c9-1680acde14c6	nice_to_catch	2025-05-29 04:14:54.786059+00
48cd09cb-8fb0-47f6-9658-51052f6f0844	7f2169d3-894f-484f-bf65-8be242c8cd24	cbe86f61-e078-4e41-a080-e3cb34655b1a	worth_the_effort	2025-05-29 04:14:58.755853+00
5af38599-8104-4fd2-a4c3-e2657f2fbcf1	7f2169d3-894f-484f-bf65-8be242c8cd24	ba136da2-7e08-4b99-989f-997cc7da5a4c	depends_on_context	2025-05-29 04:15:05.783957+00
13f58dc0-f2c6-4bbd-94e3-040d111c574c	7f2169d3-894f-484f-bf65-8be242c8cd24	effeab64-1222-4afb-91c4-9eaf8b89efe5	worth_the_effort	2025-05-29 04:15:08.363793+00
7de460e0-c3bd-4f58-a481-70d5d1daa9cb	7f2169d3-894f-484f-bf65-8be242c8cd24	896d1939-d580-4c04-86d5-55fc7b4eae9b	must_see	2025-05-29 04:15:19.104111+00
066cb5f3-ea01-4fcb-849f-7d94bad02958	7f2169d3-894f-484f-bf65-8be242c8cd24	6b4f0e47-8d36-4f0c-8de3-e4d2f0bdaf4f	nice_to_catch	2025-05-29 04:15:24.751839+00
001e4024-0ce5-4bb5-ab5b-e0c647b7ccd4	7f2169d3-894f-484f-bf65-8be242c8cd24	c12473f3-6818-43ec-b547-22773a403e5e	worth_the_effort	2025-05-29 04:15:27.004032+00
fea5241a-d3d1-4e58-ad5f-e228b8d8325f	7f2169d3-894f-484f-bf65-8be242c8cd24	251010cf-e3e4-464b-b9bb-a5d004a87436	depends_on_context	2025-05-29 04:15:33.076292+00
f2e39865-4e96-4967-9441-6b7dd571e110	7f2169d3-894f-484f-bf65-8be242c8cd24	2738faf7-37f0-4185-949a-89cfd3886c0a	depends_on_context	2025-05-29 04:15:35.906625+00
9ba1247c-fdaf-4d8e-b59a-07353884ccd3	7f2169d3-894f-484f-bf65-8be242c8cd24	529e0560-6c77-4f9a-ba42-d33a2a5be212	depends_on_context	2025-05-29 04:15:37.865091+00
03d9c813-8e42-4d64-996e-a0a8abac5631	7f2169d3-894f-484f-bf65-8be242c8cd24	5433d511-91ae-47d4-9300-b60debf25374	worth_the_effort	2025-05-29 04:15:42.255522+00
a48067c7-e5a4-4149-aa35-019434d5507a	7f2169d3-894f-484f-bf65-8be242c8cd24	0dfda089-c25b-4616-859f-fb3e0f6887df	nice_to_catch	2025-05-29 04:15:46.231824+00
4110e90c-9d4e-40a7-a27d-4349fdddf14c	7f2169d3-894f-484f-bf65-8be242c8cd24	9e5899d6-ad8b-4a43-9fc6-ec062ad6fbe5	nice_to_catch	2025-05-29 04:15:48.913931+00
693d409b-04f9-4b0e-97ff-26f01f70fc20	7f2169d3-894f-484f-bf65-8be242c8cd24	312b7a85-2a3c-4c22-ab67-c6b164c34c76	worth_the_effort	2025-05-29 04:15:51.882943+00
4d449965-92cb-4ab8-91df-83337c12b6e0	7f2169d3-894f-484f-bf65-8be242c8cd24	d4bc2ec6-4a61-4fa3-837d-4a1021397a48	nice_to_catch	2025-05-29 04:15:56.378769+00
3e49122b-3aa4-449a-8c42-70feaaddc654	7f2169d3-894f-484f-bf65-8be242c8cd24	f0efedf2-57e4-4680-8f61-758b5eb44d25	worth_the_effort	2025-05-29 04:15:58.863939+00
36c48d33-e123-4e2c-b18c-b587e60c9ddb	7f2169d3-894f-484f-bf65-8be242c8cd24	14de17b4-ad41-4c59-af07-7c15f73d2df2	depends_on_context	2025-05-29 04:16:05.507241+00
322af9ec-27df-4fa7-8798-4db35caaff94	7f2169d3-894f-484f-bf65-8be242c8cd24	efcf0d8c-13e5-4254-94b5-4c58ca7ae811	must_see	2025-05-29 04:16:10.309486+00
c300c1c7-55e6-486c-bd1b-8cb1c8435724	7f2169d3-894f-484f-bf65-8be242c8cd24	deec7ef9-3016-4cea-8a72-cdc20bd84de9	unranked	2025-05-29 04:16:32.536938+00
3073b0bb-248a-4b5b-a7df-1e85379df7ea	7f2169d3-894f-484f-bf65-8be242c8cd24	b998a6b5-407b-408c-8332-36d631792dd1	unranked	2025-05-29 04:16:34.464679+00
097f6bda-5efc-47fc-b094-89ba1244bd96	7f2169d3-894f-484f-bf65-8be242c8cd24	1c32cf44-79e3-4c2a-b52a-8f7d33454d97	unranked	2025-05-29 04:16:47.159693+00
8c76a066-7701-4a7a-a633-5dba1106bca3	7f2169d3-894f-484f-bf65-8be242c8cd24	2ff236d1-79c7-4024-82e2-36ab8448b544	unranked	2025-05-29 04:16:52.484416+00
6010be1f-31ad-4fe6-b672-2aea12f7cf36	7f2169d3-894f-484f-bf65-8be242c8cd24	ed77a0a0-b6f7-40da-9c65-c1da43a57b18	unranked	2025-05-29 04:17:32.634119+00
7ba8a8d7-633a-4e19-aeb1-b198f93e5a56	7f2169d3-894f-484f-bf65-8be242c8cd24	dcb49616-3db2-439e-8e94-c4eba88edfbd	unranked	2025-05-29 04:17:35.84248+00
c5af3630-5d2c-458d-ba02-33a1c5e570ce	7f2169d3-894f-484f-bf65-8be242c8cd24	9ae66327-d7e1-4e94-9e2e-9e167522bb27	unranked	2025-05-29 04:17:52.300995+00
ebc1f5b4-ee9f-421e-8192-3617625091c2	7f2169d3-894f-484f-bf65-8be242c8cd24	5deaa96a-b9e9-42c6-93b3-54fed8a6fa66	unranked	2025-05-29 04:19:00.290133+00
3045e6e2-8f24-4e21-8cab-fd648799d2d8	7f2169d3-894f-484f-bf65-8be242c8cd24	399dfe29-7032-4c75-b9eb-cc57059c4979	unranked	2025-05-29 04:19:03.475695+00
fcf915a8-b15d-41d9-887c-b0b532d83bd9	7f2169d3-894f-484f-bf65-8be242c8cd24	87b41ea5-c560-4722-9176-9a2b14d8cce5	unranked	2025-05-29 04:19:22.510195+00
b946ed74-d474-44f3-861b-3079f0432773	7f2169d3-894f-484f-bf65-8be242c8cd24	40e5cff6-cfd9-4e03-b9d8-6e1c4ddfc2eb	unranked	2025-05-29 04:19:33.786231+00
8bcf421b-f4a0-46e8-94be-1246f3540c7a	7f2169d3-894f-484f-bf65-8be242c8cd24	39218df5-8857-4e8e-a69a-36214b8e9d96	unranked	2025-05-29 04:19:45.685429+00
c693a8f3-95b0-4ea8-9814-90d100f5e495	7f2169d3-894f-484f-bf65-8be242c8cd24	d3046501-1cc4-4f36-bea6-fdcba9ceac7c	unranked	2025-05-29 04:20:21.015092+00
b7ad273f-790b-49b9-8626-9a6880394dc9	7f2169d3-894f-484f-bf65-8be242c8cd24	fb8ef487-ed6f-49f5-8350-99a2b1c87da2	unranked	2025-05-29 04:20:23.867962+00
b01462b3-ff75-4dc0-b19f-dd440e50ea40	7f2169d3-894f-484f-bf65-8be242c8cd24	0d253ebe-6120-431c-9654-acb9b41480b0	unranked	2025-05-29 04:20:38.511299+00
de18a061-997e-4dcb-b0bb-9d710d4098f3	7f2169d3-894f-484f-bf65-8be242c8cd24	6ce195f4-9bd9-43a6-8c5d-297e5259228c	unranked	2025-05-29 04:20:48.311891+00
26aaf239-ce5b-46c5-8a9a-9cbee5dddcbd	7f2169d3-894f-484f-bf65-8be242c8cd24	82b3a6d3-7751-4fa9-810d-c8f65bdd4735	unranked	2025-05-29 04:21:22.370922+00
c9d023f4-0ca3-4b83-bcfd-15bf27f60f9f	7f2169d3-894f-484f-bf65-8be242c8cd24	74156f52-825c-4176-a1db-52f2ce49e322	unranked	2025-05-29 04:21:52.439599+00
7fc008b1-fb52-4c0a-81ed-06ba25a502ff	7f2169d3-894f-484f-bf65-8be242c8cd24	2b03801f-952a-4956-bf78-e055da97d490	unranked	2025-05-29 04:21:58.973635+00
ecb8d9d3-dd94-4741-849c-197cb4dffdf5	7f2169d3-894f-484f-bf65-8be242c8cd24	df085140-4e96-46ed-b256-38eb250455ee	unranked	2025-05-29 04:22:34.410084+00
d377c2ea-efc5-4e0b-b189-7bf0d9ec5636	7f2169d3-894f-484f-bf65-8be242c8cd24	74156f52-825c-4176-a1db-52f2ce49e322	must_see	2025-05-29 04:22:58.892728+00
ebcd245c-8d92-4f8d-af95-0a9838e561ac	7f2169d3-894f-484f-bf65-8be242c8cd24	df085140-4e96-46ed-b256-38eb250455ee	must_see	2025-05-29 04:23:01.073641+00
fc4b9f2a-5a87-4276-80e2-e5c460ebd618	7f2169d3-894f-484f-bf65-8be242c8cd24	ed77a0a0-b6f7-40da-9c65-c1da43a57b18	must_see	2025-05-29 04:23:03.299807+00
93e3f6da-b20a-456b-904e-0f7a9521fc9c	7f2169d3-894f-484f-bf65-8be242c8cd24	2ff236d1-79c7-4024-82e2-36ab8448b544	must_see	2025-05-29 04:23:09.000021+00
03a27175-f37e-4f8a-8e29-618401276d7a	7f2169d3-894f-484f-bf65-8be242c8cd24	1c32cf44-79e3-4c2a-b52a-8f7d33454d97	nice_to_catch	2025-05-29 04:23:11.160903+00
2f8a40a8-c395-42aa-b533-a267cace52fc	7f2169d3-894f-484f-bf65-8be242c8cd24	dcb49616-3db2-439e-8e94-c4eba88edfbd	depends_on_context	2025-05-29 04:23:14.461863+00
6c32d1ad-2336-4df9-a97b-e513f1de8aed	7f2169d3-894f-484f-bf65-8be242c8cd24	9ae66327-d7e1-4e94-9e2e-9e167522bb27	nice_to_catch	2025-05-29 04:23:17.219226+00
b68f5be6-93a9-4068-aa85-50775bb96a2c	7f2169d3-894f-484f-bf65-8be242c8cd24	5deaa96a-b9e9-42c6-93b3-54fed8a6fa66	depends_on_context	2025-05-29 04:23:20.499767+00
97601637-e51c-43b4-bcdc-54bf9df0e723	7f2169d3-894f-484f-bf65-8be242c8cd24	deec7ef9-3016-4cea-8a72-cdc20bd84de9	must_see	2025-05-29 04:23:22.952954+00
14c67d1f-5101-4822-8bc3-5eb29edbf609	7f2169d3-894f-484f-bf65-8be242c8cd24	39218df5-8857-4e8e-a69a-36214b8e9d96	must_see	2025-05-29 04:23:28.066488+00
f0721500-3c69-42f6-af52-d9ee4463ab0b	7f2169d3-894f-484f-bf65-8be242c8cd24	0d253ebe-6120-431c-9654-acb9b41480b0	nice_to_catch	2025-05-29 04:23:34.000136+00
216b9c0e-823d-4c4a-aa9c-cb9db1b5b197	7f2169d3-894f-484f-bf65-8be242c8cd24	6ce195f4-9bd9-43a6-8c5d-297e5259228c	nice_to_catch	2025-05-29 04:23:37.595547+00
7524d420-e205-4e6a-bd55-6039968b2a18	7f2169d3-894f-484f-bf65-8be242c8cd24	82b3a6d3-7751-4fa9-810d-c8f65bdd4735	depends_on_context	2025-05-29 04:23:40.468253+00
7e85a7ac-cb2b-4eee-a5a8-269a21d86539	7f2169d3-894f-484f-bf65-8be242c8cd24	baa43c55-7964-4641-a10c-3d48b4687e61	depends_on_context	2025-05-29 04:23:46.601611+00
5f33bb9f-35b7-4566-8a28-0277ea4df25d	7f2169d3-894f-484f-bf65-8be242c8cd24	87b41ea5-c560-4722-9176-9a2b14d8cce5	depends_on_context	2025-05-29 04:23:55.13792+00
1316fdb7-0b4e-4764-96e4-df87f3b52b78	7f2169d3-894f-484f-bf65-8be242c8cd24	7e37c869-3c43-44e1-a933-5530e4db2d5d	unranked	2025-05-29 05:08:08.208522+00
e92d5a0d-c824-45a9-b1fe-2832004ce1c6	7f2169d3-894f-484f-bf65-8be242c8cd24	53cf4ee2-936b-4c34-af4d-332fb75fc5cc	unranked	2025-05-29 05:09:57.674037+00
e7b79878-29d6-45ee-be17-0f37f8c2c370	7f2169d3-894f-484f-bf65-8be242c8cd24	b3c2b328-2c0b-41ea-89a3-6f242884eecd	unranked	2025-05-29 05:10:07.625434+00
d0ba757c-9086-45af-9231-45e1f6e7ba07	7f2169d3-894f-484f-bf65-8be242c8cd24	5793846d-0815-4ef9-afb1-0add3b8fbb30	unranked	2025-05-29 05:10:09.250698+00
60636e53-3df3-44f8-89ff-4554a4031f5c	7f2169d3-894f-484f-bf65-8be242c8cd24	1ab79c35-2148-494d-89a4-a854969c8869	unranked	2025-05-29 05:10:21.941045+00
57f5ba2a-bf6a-41de-a2fb-dfac11735cac	7f2169d3-894f-484f-bf65-8be242c8cd24	11ab2bff-caf6-4824-b632-1c3fde9886c1	unranked	2025-05-29 05:13:36.894499+00
e22d23cf-06f5-4c92-9130-1b5489658c30	7f2169d3-894f-484f-bf65-8be242c8cd24	987b37ad-8b72-459b-bbab-488495f64110	unranked	2025-05-29 05:14:08.673173+00
907c5d34-b202-4104-a50c-c3235d852c95	7f2169d3-894f-484f-bf65-8be242c8cd24	35e7c4f0-e39b-4d60-8b67-931a2280b494	unranked	2025-05-29 05:14:30.277198+00
98f414fc-32e0-4773-bbf4-a8259daebffa	7f2169d3-894f-484f-bf65-8be242c8cd24	408068ff-c8a4-43a5-93da-95d02e59fca7	unranked	2025-05-29 05:15:01.404202+00
192cd1c3-7b3c-4a40-bf5c-a7da32c4393c	7f2169d3-894f-484f-bf65-8be242c8cd24	4675fb22-1159-4183-b3fa-4561f7df57e4	unranked	2025-05-29 05:15:45.83274+00
bee63ed7-267f-4cfb-bcc6-17a93c3dd516	7f2169d3-894f-484f-bf65-8be242c8cd24	1935575c-6b2b-4f41-b8fc-edd258397c2e	unranked	2025-05-29 05:18:26.302372+00
3a8bb704-669e-4d6d-b439-82905f1941c4	7f2169d3-894f-484f-bf65-8be242c8cd24	b2bac8b5-7e3c-45f5-a9b2-ee98cce286c1	unranked	2025-05-29 05:18:30.021977+00
87b6e7ec-a37c-485d-a63b-e9fcc42e258e	7f2169d3-894f-484f-bf65-8be242c8cd24	84779002-0010-473f-853c-58f1feb3f962	unranked	2025-05-29 05:22:24.544051+00
637e8230-e09c-426a-8a1a-541b8c93994e	7f2169d3-894f-484f-bf65-8be242c8cd24	f9ea4624-18e0-46c5-93b1-512cbf7cbc7c	unranked	2025-05-29 05:22:36.194478+00
56e3cbdc-dfb1-4e6c-abc8-7560309d1c63	7f2169d3-894f-484f-bf65-8be242c8cd24	100edba3-2443-40a3-bd9e-935e9a7770aa	unranked	2025-05-29 05:22:41.284149+00
1ffbbe7e-df86-44e1-907e-573d6180b84e	7f2169d3-894f-484f-bf65-8be242c8cd24	4c5325ac-f7b1-47ab-b3d1-7d5ce3535c55	unranked	2025-05-29 05:25:14.929736+00
0e7e7fd8-c741-40dc-93ee-499e6683658b	7f2169d3-894f-484f-bf65-8be242c8cd24	8d70afd4-c541-4a0e-9fa4-40b0271f4d69	unranked	2025-05-29 05:25:25.382132+00
e871ce7d-ec58-4177-961a-4e7fc3cdc96a	7f2169d3-894f-484f-bf65-8be242c8cd24	1ab79c35-2148-494d-89a4-a854969c8869	worth_the_effort	2025-05-29 06:32:56.408342+00
b77a74c4-966c-4ab9-89c8-cafd87ef0f33	7f2169d3-894f-484f-bf65-8be242c8cd24	11ab2bff-caf6-4824-b632-1c3fde9886c1	nice_to_catch	2025-05-29 06:33:04.7238+00
9b33f90c-ff68-48fe-9ab0-12559cdff971	7f2169d3-894f-484f-bf65-8be242c8cd24	b3c2b328-2c0b-41ea-89a3-6f242884eecd	must_see	2025-05-29 06:33:17.203112+00
d2d89fe1-ea31-44af-9d89-307e048538fe	7f2169d3-894f-484f-bf65-8be242c8cd24	53cf4ee2-936b-4c34-af4d-332fb75fc5cc	worth_the_effort	2025-05-29 06:33:26.805841+00
d4e0ba09-e82b-4d86-9692-25607b1420e8	7f2169d3-894f-484f-bf65-8be242c8cd24	7e37c869-3c43-44e1-a933-5530e4db2d5d	must_see	2025-05-29 06:33:39.108601+00
1a3131a2-b90b-42f1-b39f-5293486613d3	7f2169d3-894f-484f-bf65-8be242c8cd24	d2dc9307-0a0b-45a7-94ff-d22fff4e6121	unranked	2025-05-29 21:46:50.583741+00
f7645c93-209d-4e50-a2e5-e04bd1584376	7f2169d3-894f-484f-bf65-8be242c8cd24	b93cf86d-6480-4418-aa5f-f8413c204711	unranked	2025-05-29 21:47:28.641838+00
80cc3fc9-91c8-45e5-b559-25751042f3d9	7f2169d3-894f-484f-bf65-8be242c8cd24	c1c24e02-6163-4ec1-9e01-7be09048b365	unranked	2025-05-29 21:48:02.942342+00
479fb458-0de8-481f-ba3e-72e9b845c826	7f2169d3-894f-484f-bf65-8be242c8cd24	cef58682-aa2a-4be6-85d5-c563eaeafe05	unranked	2025-05-29 21:49:03.10669+00
04b9fbf0-7d82-4b0a-a560-6ba5033b2c18	7f2169d3-894f-484f-bf65-8be242c8cd24	e36ef47e-9501-49e6-9486-bf15d790eb1c	unranked	2025-05-29 21:54:22.197414+00
30e22486-bb82-458a-a560-b4dd9ab46301	7f2169d3-894f-484f-bf65-8be242c8cd24	ccc0cac3-9fd6-4884-beb7-3fdbd04b533a	unranked	2025-05-29 21:57:37.822518+00
f8188e5b-877a-4c5c-888b-e319851c2bd3	7f2169d3-894f-484f-bf65-8be242c8cd24	ccc0cac3-9fd6-4884-beb7-3fdbd04b533a	must_see	2025-05-29 21:57:43.043839+00
3c87819c-3214-44d4-978b-d4653fedbf08	7f2169d3-894f-484f-bf65-8be242c8cd24	e36ef47e-9501-49e6-9486-bf15d790eb1c	must_see	2025-05-29 21:57:52.368493+00
e156e667-e8c7-4193-94e6-4932f2d2634d	7f2169d3-894f-484f-bf65-8be242c8cd24	d2dc9307-0a0b-45a7-94ff-d22fff4e6121	must_see	2025-05-29 21:57:55.545306+00
ddcb5e76-2564-48bc-b5e6-46b7fceaf791	7f2169d3-894f-484f-bf65-8be242c8cd24	1935575c-6b2b-4f41-b8fc-edd258397c2e	worth_the_effort	2025-05-29 21:58:01.051012+00
a3ad4646-93c5-4e6e-bb8c-7dda96a2118d	7f2169d3-894f-484f-bf65-8be242c8cd24	408068ff-c8a4-43a5-93da-95d02e59fca7	nice_to_catch	2025-05-29 21:58:06.305402+00
d5967267-7d63-4fd2-b195-7071930f73dd	7f2169d3-894f-484f-bf65-8be242c8cd24	b5df5cf8-999a-413e-a3f5-8d12c5998be3	unranked	2025-05-29 22:00:32.941704+00
1916c478-ff6e-4968-85f7-a4308c179776	7f2169d3-894f-484f-bf65-8be242c8cd24	cc4ec826-fec6-43a5-bd2a-df79453908d7	unranked	2025-05-29 22:01:53.624844+00
ffe43956-724b-4a70-9f87-c7f860e989d4	7f2169d3-894f-484f-bf65-8be242c8cd24	4eaaa400-d5ad-4d08-aeb2-63e77e27391e	unranked	2025-05-29 22:05:11.664371+00
f44ae22d-8c4c-41bc-9378-1cf4d8eef9e5	7f2169d3-894f-484f-bf65-8be242c8cd24	0c88940f-d78b-406c-9f17-ecdc1b1842cb	unranked	2025-05-29 22:06:02.77485+00
654d2722-116a-4a41-81ca-b1b7cea5d7e2	7f2169d3-894f-484f-bf65-8be242c8cd24	e387fe82-de95-4b51-bb07-a8906557e2aa	unranked	2025-05-29 22:06:36.769026+00
decd4c1e-0bf3-4825-b715-6af6515a2a5a	7f2169d3-894f-484f-bf65-8be242c8cd24	bbc928b2-37c2-484e-a098-cba93cec0c02	unranked	2025-05-29 22:08:13.430061+00
e83b2646-a6fe-468e-9a3e-16b7b3ac703e	7f2169d3-894f-484f-bf65-8be242c8cd24	20819972-5859-4db6-a4bb-dba1d0f4debe	unranked	2025-05-29 22:08:19.67141+00
1a535d94-bb87-4aae-baee-31db6585596f	7f2169d3-894f-484f-bf65-8be242c8cd24	998ca517-d793-4e53-8859-fadd418da2b2	unranked	2025-05-29 22:09:24.852487+00
a9a71b3f-bffe-4968-8b20-60fb7896dab7	7f2169d3-894f-484f-bf65-8be242c8cd24	1175a04b-450f-4618-b7f0-f9777600bf78	unranked	2025-05-29 22:23:33.156403+00
481d8539-1068-4f03-8411-16b026924c2b	7f2169d3-894f-484f-bf65-8be242c8cd24	94f2f589-b501-4a61-98ff-98b802394b0d	unranked	2025-05-29 22:23:50.593033+00
ac8802f2-ca9c-4663-b676-afc16af5d167	7f2169d3-894f-484f-bf65-8be242c8cd24	b5df5cf8-999a-413e-a3f5-8d12c5998be3	nice_to_catch	2025-05-29 22:27:24.869317+00
13a72fbc-26a0-4c90-bafa-9b59b8ac2383	7f2169d3-894f-484f-bf65-8be242c8cd24	cef58682-aa2a-4be6-85d5-c563eaeafe05	depends_on_context	2025-05-29 22:27:29.305801+00
2311d290-08f2-422a-82a5-1471874c9329	7f2169d3-894f-484f-bf65-8be242c8cd24	e387fe82-de95-4b51-bb07-a8906557e2aa	depends_on_context	2025-05-29 22:27:32.735809+00
5eee42d2-2ce5-4c43-97d2-9adca97edcba	7f2169d3-894f-484f-bf65-8be242c8cd24	b2bac8b5-7e3c-45f5-a9b2-ee98cce286c1	depends_on_context	2025-05-29 22:27:37.738868+00
dc692b4f-d591-47bc-a9f4-45894bf223c0	7f2169d3-894f-484f-bf65-8be242c8cd24	d3046501-1cc4-4f36-bea6-fdcba9ceac7c	depends_on_context	2025-05-29 22:27:44.933399+00
2d143e0d-381e-4564-acef-07b4b7154328	7f2169d3-894f-484f-bf65-8be242c8cd24	b93cf86d-6480-4418-aa5f-f8413c204711	nice_to_catch	2025-05-29 22:27:53.804435+00
e0424289-80ce-4028-b15f-dc98241ef05b	7f2169d3-894f-484f-bf65-8be242c8cd24	4eaaa400-d5ad-4d08-aeb2-63e77e27391e	worth_the_effort	2025-05-29 22:28:00.972678+00
182fce83-6340-4525-a4d1-09452de766ff	7f2169d3-894f-484f-bf65-8be242c8cd24	0c88940f-d78b-406c-9f17-ecdc1b1842cb	must_see	2025-05-29 22:28:05.386069+00
c51f2971-7ef1-4d16-a522-502d4eacfaff	7f2169d3-894f-484f-bf65-8be242c8cd24	998ca517-d793-4e53-8859-fadd418da2b2	must_see	2025-05-29 22:28:08.685219+00
d36c5655-af6a-455a-acc4-a8de9838af0e	7f2169d3-894f-484f-bf65-8be242c8cd24	cc4ec826-fec6-43a5-bd2a-df79453908d7	depends_on_context	2025-05-29 22:28:13.722514+00
cb55ffd5-a35c-42f1-bbe0-71c00a05cddf	7f2169d3-894f-484f-bf65-8be242c8cd24	1175a04b-450f-4618-b7f0-f9777600bf78	worth_the_effort	2025-05-29 22:28:17.459891+00
a35e3d0b-b653-4d90-854b-acfc6bd356a5	7f2169d3-894f-484f-bf65-8be242c8cd24	94f2f589-b501-4a61-98ff-98b802394b0d	must_see	2025-05-29 22:28:19.517895+00
0bffef9c-8d8b-42e3-9b41-c3fb2b325d93	7f2169d3-894f-484f-bf65-8be242c8cd24	c1c24e02-6163-4ec1-9e01-7be09048b365	nice_to_catch	2025-05-29 22:28:28.130507+00
16521127-ea0f-42c7-96b2-b1995e608346	7f2169d3-894f-484f-bf65-8be242c8cd24	86759873-08dc-42b4-8426-35ba0be89d3c	unranked	2025-05-29 22:31:44.315103+00
b7bc7dd2-4dc2-4b60-8ad3-b854ce53d558	7f2169d3-894f-484f-bf65-8be242c8cd24	c0bfac75-1573-4d1f-bf91-ab6689e12bfa	unranked	2025-05-29 22:33:57.753834+00
f8816409-78e5-458a-a9a0-12d58f082de9	7f2169d3-894f-484f-bf65-8be242c8cd24	c0bfac75-1573-4d1f-bf91-ab6689e12bfa	must_see	2025-05-29 22:34:03.799474+00
08ca0227-4afa-4e08-97a6-f7144b97cf9b	7f2169d3-894f-484f-bf65-8be242c8cd24	4b5837f1-f7fe-423f-a027-ce6e9699f200	unranked	2025-05-30 04:54:49.89928+00
586d7e1c-1516-4442-b6af-6f96469f6597	7f2169d3-894f-484f-bf65-8be242c8cd24	20ebf32e-65ef-4085-b352-02fecc95c06a	unranked	2025-05-30 04:55:28.658004+00
bcfdfa89-b840-4074-8109-9f8a7bb02c63	b0b0ed7d-538a-4b52-bc1c-f5410677612c	2ff236d1-79c7-4024-82e2-36ab8448b544	unranked	2025-05-30 09:06:18.158967+00
fdd38a9d-572e-4891-95ff-7745455d6d9c	b0b0ed7d-538a-4b52-bc1c-f5410677612c	2ff236d1-79c7-4024-82e2-36ab8448b544	must_see	2025-05-30 09:06:27.352832+00
7b768c8a-c5ad-4855-a31b-56e93825a648	b0b0ed7d-538a-4b52-bc1c-f5410677612c	2ff236d1-79c7-4024-82e2-36ab8448b544	worth_the_effort	2025-05-30 09:07:02.357311+00
f77ffcf4-9c9c-40ef-8877-124052c5f562	b0b0ed7d-538a-4b52-bc1c-f5410677612c	cbe86f61-e078-4e41-a080-e3cb34655b1a	unranked	2025-05-30 09:07:40.834149+00
ed24338e-61b1-4308-901a-22c1cf43b339	b0b0ed7d-538a-4b52-bc1c-f5410677612c	e35d21f2-94ee-4a50-b626-1b983b125327	unranked	2025-05-30 09:09:16.962341+00
17172ba0-cf23-481c-9476-7ea74b101085	b0b0ed7d-538a-4b52-bc1c-f5410677612c	312b7a85-2a3c-4c22-ab67-c6b164c34c76	unranked	2025-05-30 09:10:01.042194+00
bbe91a20-cbe0-4732-b89c-54c82d794165	b0b0ed7d-538a-4b52-bc1c-f5410677612c	5f1be115-c6f5-4fdb-8f4a-b865d3780b54	unranked	2025-05-30 09:10:02.81146+00
fbc0f971-080d-4dda-8ebc-9c5591e5be65	b0b0ed7d-538a-4b52-bc1c-f5410677612c	deec7ef9-3016-4cea-8a72-cdc20bd84de9	unranked	2025-05-30 09:10:44.620445+00
72c90626-a890-4a3b-bf25-cfdd8f2af3a6	b0b0ed7d-538a-4b52-bc1c-f5410677612c	4eaaa400-d5ad-4d08-aeb2-63e77e27391e	unranked	2025-05-30 09:10:54.642857+00
50645540-5428-4f5c-aa83-c900aabd819c	b0b0ed7d-538a-4b52-bc1c-f5410677612c	91f2f3b2-7222-4f54-a961-71152e5fb8b9	unranked	2025-05-30 09:11:01.221235+00
c83db65a-6a4c-44f1-927e-be925b3cf5ce	b0b0ed7d-538a-4b52-bc1c-f5410677612c	03198e4d-0bd0-40bb-8a15-d07c3ace24e2	unranked	2025-05-30 09:11:08.787277+00
d2ced057-fbd5-4655-9392-924328e6d80a	b0b0ed7d-538a-4b52-bc1c-f5410677612c	df085140-4e96-46ed-b256-38eb250455ee	unranked	2025-05-30 09:11:22.206727+00
aebcd9ed-eaf7-4fe7-bd39-75576c8ee791	b0b0ed7d-538a-4b52-bc1c-f5410677612c	53cf4ee2-936b-4c34-af4d-332fb75fc5cc	unranked	2025-05-30 09:11:46.37741+00
27d50040-9440-4827-bc9e-d898eca259ea	b0b0ed7d-538a-4b52-bc1c-f5410677612c	c88ed6f7-bf92-4615-aa57-4e350b785df0	unranked	2025-05-30 09:11:55.123316+00
37a84d37-22e9-4e9a-b540-ad402319caa8	b0b0ed7d-538a-4b52-bc1c-f5410677612c	6d97d81b-01c0-4c37-a28f-d2067f3e9509	unranked	2025-05-30 09:12:00.436885+00
01f417c2-2de2-40b8-84a5-0a413f3bd6c2	b0b0ed7d-538a-4b52-bc1c-f5410677612c	8de421d5-8326-4eb8-9841-73482086066a	unranked	2025-05-30 09:12:09.512482+00
e9e1af9d-2363-4e93-9986-5f9573416a0c	b0b0ed7d-538a-4b52-bc1c-f5410677612c	52b8d7cd-d509-4bac-8583-cb4ea065fdaa	unranked	2025-05-30 09:12:15.665075+00
47792ac4-8f1b-441b-b24c-1994bacda891	b0b0ed7d-538a-4b52-bc1c-f5410677612c	5793846d-0815-4ef9-afb1-0add3b8fbb30	unranked	2025-05-30 09:12:16.658808+00
9f107659-2f90-4d5d-9e1f-4f52c4e50f3d	b0b0ed7d-538a-4b52-bc1c-f5410677612c	477e2eff-f202-4617-8b4c-8c134eca5317	unranked	2025-05-30 09:12:21.996548+00
d3182709-d4f8-49f6-b99d-27c889416973	b0b0ed7d-538a-4b52-bc1c-f5410677612c	5eb26bf5-f16d-4c2f-8ee1-4597d693f6c2	unranked	2025-05-30 09:12:32.854337+00
c21bbbc6-50d1-442d-be8f-f42c7cefc3f8	b0b0ed7d-538a-4b52-bc1c-f5410677612c	11ab2bff-caf6-4824-b632-1c3fde9886c1	unranked	2025-05-30 09:13:12.046923+00
2d9a1ee2-5a01-4e74-b436-ae77288d7738	b0b0ed7d-538a-4b52-bc1c-f5410677612c	b998a6b5-407b-408c-8332-36d631792dd1	unranked	2025-05-30 09:13:15.46422+00
f64ae84d-a58c-4738-9db2-0fba4a7abf3f	b0b0ed7d-538a-4b52-bc1c-f5410677612c	f0efedf2-57e4-4680-8f61-758b5eb44d25	unranked	2025-05-30 09:13:17.47338+00
1118733e-0046-47f6-8797-f66642cf70f3	b0b0ed7d-538a-4b52-bc1c-f5410677612c	39218df5-8857-4e8e-a69a-36214b8e9d96	unranked	2025-05-30 09:13:18.275857+00
df7b5d9d-9d56-41ac-9c8f-1aa190f33c2e	b0b0ed7d-538a-4b52-bc1c-f5410677612c	2eb51647-373d-4a11-9a30-dbe1a4ba0789	unranked	2025-05-30 09:13:21.586427+00
df2cf8dd-59cd-4c13-8fe2-cb81f918f959	b0b0ed7d-538a-4b52-bc1c-f5410677612c	d4078249-02ee-4c40-9dfc-281dc176f165	unranked	2025-05-30 09:13:36.497325+00
d197f6bf-b074-488e-8da7-29127265e95d	b0b0ed7d-538a-4b52-bc1c-f5410677612c	b14f3f69-f29e-4695-9c0e-1b933c30f02d	unranked	2025-05-30 09:13:40.668313+00
c9cdf826-dd3c-4fea-9023-8525da0a9077	b0b0ed7d-538a-4b52-bc1c-f5410677612c	d4bc2ec6-4a61-4fa3-837d-4a1021397a48	unranked	2025-05-30 09:13:59.783156+00
0bde55b3-78b0-4c00-82a1-0175e110ed02	b0b0ed7d-538a-4b52-bc1c-f5410677612c	05409c9f-6b94-4f2b-ac42-f15e4f4f84ba	unranked	2025-05-30 09:14:02.554766+00
b0cbf098-d6e7-4c1d-8719-8affbd3af4ec	b0b0ed7d-538a-4b52-bc1c-f5410677612c	b3c2b328-2c0b-41ea-89a3-6f242884eecd	unranked	2025-05-30 09:14:13.520074+00
8e232255-dc1d-4938-aea8-42896dab2a09	b0b0ed7d-538a-4b52-bc1c-f5410677612c	6a2d3037-1e9d-4716-a7e4-9876a2d654d9	unranked	2025-05-30 09:14:21.60576+00
1356a078-a759-4358-9912-7cd75e1fbd15	b0b0ed7d-538a-4b52-bc1c-f5410677612c	35e7c4f0-e39b-4d60-8b67-931a2280b494	unranked	2025-05-30 09:14:38.306333+00
3c4677e9-0106-40d0-b411-63b747ffbf65	b0b0ed7d-538a-4b52-bc1c-f5410677612c	987b37ad-8b72-459b-bbab-488495f64110	unranked	2025-05-30 09:14:43.225552+00
d51e838b-8967-4f01-9e3e-30606dd50ebd	b0b0ed7d-538a-4b52-bc1c-f5410677612c	6b4f0e47-8d36-4f0c-8de3-e4d2f0bdaf4f	unranked	2025-05-30 09:15:00.942931+00
08f5f426-5627-4a63-8ce9-9d16937d5a3a	b0b0ed7d-538a-4b52-bc1c-f5410677612c	6ce195f4-9bd9-43a6-8c5d-297e5259228c	unranked	2025-05-30 09:15:36.636102+00
3836b89f-3589-4117-9547-f35dc3f5a1f7	06082977-180b-4170-a3d5-72f7005652a9	d1dd8e3e-f4cf-497a-ac82-f746b1f77ad1	unranked	2025-05-30 09:44:26.329522+00
34716779-66f8-4dfa-bcfe-44812c5dba59	06082977-180b-4170-a3d5-72f7005652a9	04a6c2ff-926a-4e3e-8998-607f87cc44a4	unranked	2025-05-30 09:44:29.745765+00
0821dc9d-69fb-4ed1-9767-22a4f3ddeea3	06082977-180b-4170-a3d5-72f7005652a9	6a2d3037-1e9d-4716-a7e4-9876a2d654d9	unranked	2025-05-30 09:45:08.758972+00
4019e7eb-1827-43b3-a7bb-7131fb724da3	06082977-180b-4170-a3d5-72f7005652a9	04a6c2ff-926a-4e3e-8998-607f87cc44a4	worth_the_effort	2025-05-30 09:45:29.501984+00
4cb4d16d-9b1a-4414-9302-5a809bfdcefa	06082977-180b-4170-a3d5-72f7005652a9	6a2d3037-1e9d-4716-a7e4-9876a2d654d9	must_see	2025-05-30 09:45:31.769619+00
3fb4098b-e1a9-4212-a4dd-d7659a08846b	06082977-180b-4170-a3d5-72f7005652a9	03198e4d-0bd0-40bb-8a15-d07c3ace24e2	unranked	2025-05-30 09:46:38.332986+00
794d96ec-11c4-4bc3-87c1-3ac606038be0	06082977-180b-4170-a3d5-72f7005652a9	03198e4d-0bd0-40bb-8a15-d07c3ace24e2	worth_the_effort	2025-05-30 09:46:48.273904+00
1b075527-e9f5-4aa5-9ef9-18d28d3879bb	06082977-180b-4170-a3d5-72f7005652a9	5433d511-91ae-47d4-9300-b60debf25374	unranked	2025-05-30 09:46:58.764601+00
9c3b1cdf-110a-4c1b-bb4d-9d2034df31b2	06082977-180b-4170-a3d5-72f7005652a9	5433d511-91ae-47d4-9300-b60debf25374	worth_the_effort	2025-05-30 09:47:02.766333+00
3fdd69a6-194b-46c2-b8d1-4c7f79cad67a	06082977-180b-4170-a3d5-72f7005652a9	0c88940f-d78b-406c-9f17-ecdc1b1842cb	unranked	2025-05-30 09:49:34.24307+00
693d3d9c-4ac1-491a-8552-56636e027985	06082977-180b-4170-a3d5-72f7005652a9	0c88940f-d78b-406c-9f17-ecdc1b1842cb	must_see	2025-05-30 09:49:38.040226+00
d074722d-ddb1-4c2f-a423-ff3cdcf15d8b	eda854e4-0358-4ae6-b5e2-8bb490e5782a	fe56b223-e30e-4a75-9256-1a1edc43a910	unranked	2025-05-30 19:26:19.502348+00
90691d04-5733-4754-b846-4e3db17b4573	eda854e4-0358-4ae6-b5e2-8bb490e5782a	fe56b223-e30e-4a75-9256-1a1edc43a910	worth_the_effort	2025-05-30 19:26:30.283885+00
c65fa8c5-6039-45e0-8dd2-47694d21bb13	c3866d1b-210f-490a-b300-bde91941735b	ea413c86-587c-44ca-b209-c5cdd1e40c36	unranked	2025-05-31 04:44:53.027827+00
fa9521ad-a31f-447e-95b9-ba01044cbb90	c3866d1b-210f-490a-b300-bde91941735b	df5e983f-965c-43ef-be0c-3784d9030ece	unranked	2025-05-31 04:46:07.023327+00
db1b28cc-a532-433b-beac-f1f046267753	c3866d1b-210f-490a-b300-bde91941735b	ea413c86-587c-44ca-b209-c5cdd1e40c36	must_see	2025-05-31 04:46:21.043101+00
a0e4a6d0-94d0-49f8-a57d-a29c3c5d98b9	c3866d1b-210f-490a-b300-bde91941735b	df5e983f-965c-43ef-be0c-3784d9030ece	worth_the_effort	2025-05-31 04:46:24.914069+00
6e7bf010-9eeb-42ed-89b5-952ef5d35cd1	eda854e4-0358-4ae6-b5e2-8bb490e5782a	925ea8da-12d9-4554-8968-9505e4c09104	unranked	2025-05-31 12:17:53.155983+00
4d481b2d-158b-4879-a10b-dcbebdf55c9d	eda854e4-0358-4ae6-b5e2-8bb490e5782a	bda40a00-6f80-4934-8687-2e2946e207c9	nice_to_catch	2025-05-31 12:18:06.91452+00
ef5de795-2b25-45e0-a439-b19c7568e897	eda854e4-0358-4ae6-b5e2-8bb490e5782a	1ef315d8-9eef-48be-bbc8-b9728991ac10	not_for_me	2025-05-31 13:05:25.79615+00
95989eb1-c911-423d-acca-5d5c5ae9999f	eda854e4-0358-4ae6-b5e2-8bb490e5782a	05d2c5fc-23ba-4376-8983-c4d18af1c4dc	nice_to_catch	2025-05-31 13:40:03.515995+00
6185ed86-74d7-49bc-9689-7e42c8367035	eda854e4-0358-4ae6-b5e2-8bb490e5782a	00bb3ab7-03ae-451d-9c37-44ad2f8e892d	nice_to_catch	2025-05-31 15:25:22.381406+00
9e4e7a32-6128-4af4-97e5-224cfbf1fddf	eda854e4-0358-4ae6-b5e2-8bb490e5782a	e55d78f1-9783-40ea-a802-4fcd58024a44	nice_to_catch	2025-05-31 20:06:44.657717+00
1813d77c-492f-4e22-8754-601d1a1ee203	eda854e4-0358-4ae6-b5e2-8bb490e5782a	df8f9260-9a19-435f-a309-c2ef93f58337	unranked	2025-06-01 00:41:39.110744+00
\.


--
-- Data for Name: artist_placements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.artist_placements (id, created_at, user_id, artist_id, stage, tier, inserted_at, updated_at, b2b_set_id) FROM stdin;
71f6c5c1-467e-4746-93e5-8c23eeda788a	2025-05-28 17:29:52.418252+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	b6582170-250f-4c8f-940b-f8422b2dc3a1	\N	must_see	\N	2025-05-28 17:43:01.571475+00	\N
e78631b7-fd59-473a-b308-b891849651ae	2025-05-29 04:10:34.501814+00	7f2169d3-894f-484f-bf65-8be242c8cd24	9c4c2751-2f32-468e-a11f-8b1c93af25d6	\N	unranked	\N	2025-05-29 04:10:34.501814+00	\N
774616a6-2802-4bf4-85d2-0c4a26b9d374	2025-05-28 16:38:30.19403+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	e55d78f1-9783-40ea-a802-4fcd58024a44	\N	nice_to_catch	\N	2025-06-03 07:58:32.14863+00	\N
88a56cad-af32-4b6c-84fd-958e089f542f	2025-05-28 18:49:11.040636+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	8a9874dd-8991-4067-a155-48677c1c5a2e	\N	depends_on_context	\N	2025-05-28 18:49:13.483789+00	\N
1bb1257f-20b2-4e08-9a53-f1b92a1ad1d0	2025-05-28 21:43:18.962014+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	b6582170-250f-4c8f-940b-f8422b2dc3a1	\N	must_see	\N	2025-05-28 21:43:21.504093+00	\N
65e61872-066b-4e30-85e5-049f2f96defb	2025-05-29 03:52:21.251508+00	7f2169d3-894f-484f-bf65-8be242c8cd24	b0201b37-2235-4f7d-8003-1a997ce45ec7	\N	not_for_me	\N	2025-06-03 05:08:23.452813+00	\N
2ed1e90b-f1d1-419b-a87d-9ca53f713b7e	2025-05-29 01:26:11.489215+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	91f2f3b2-7222-4f54-a961-71152e5fb8b9	\N	must_see	\N	2025-05-29 01:26:15.287256+00	\N
1fd0f44f-460c-4edb-8e2d-9c71fe105650	2025-05-29 01:26:29.616927+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	03198e4d-0bd0-40bb-8a15-d07c3ace24e2	\N	must_see	\N	2025-05-29 01:26:34.704399+00	\N
109b81ec-03b2-4527-a76a-e9e1fd678bcb	2025-05-29 02:24:59.981239+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	5deaa96a-b9e9-42c6-93b3-54fed8a6fa66	\N	must_see	\N	2025-05-29 02:25:04.995048+00	\N
4fd4075f-9da4-41e6-a527-003960b8c399	2025-05-29 02:25:53.376697+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	af19c3d0-4797-46bb-8ad5-cf818a693ac3	\N	nice_to_catch	\N	2025-05-29 02:26:03.906863+00	\N
844a4f21-d855-4f31-97c9-0c314393543e	2025-05-29 02:26:11.789911+00	7f2169d3-894f-484f-bf65-8be242c8cd24	f1475be9-7380-4d9c-941b-bee134b996e8	\N	must_see	\N	2025-05-29 02:26:17.192414+00	\N
c1b1fadf-a500-4d51-89cc-0d8856e08764	2025-05-29 02:26:51.591189+00	7f2169d3-894f-484f-bf65-8be242c8cd24	a086100e-92d9-4f7a-a69d-82ea9e2661d3	\N	must_see	\N	2025-05-29 02:29:25.983808+00	\N
4d1e3233-932c-470c-9702-c463dfde6f13	2025-05-29 02:26:26.324209+00	7f2169d3-894f-484f-bf65-8be242c8cd24	8447d406-ca7a-4e33-a432-db89fd5619ac	\N	nice_to_catch	\N	2025-05-29 02:29:30.383402+00	\N
ea0e81cc-de99-4983-9747-312e970b65f8	2025-05-29 02:29:19.620108+00	7f2169d3-894f-484f-bf65-8be242c8cd24	9d16e7fb-13dc-4fe4-aefc-198cf833ae25	\N	depends_on_context	\N	2025-05-29 02:29:36.902398+00	\N
de040110-5d96-4167-8782-52b1ba60c317	2025-05-29 02:51:20.123634+00	06082977-180b-4170-a3d5-72f7005652a9	2ff236d1-79c7-4024-82e2-36ab8448b544	\N	must_see	\N	2025-05-29 02:51:25.314912+00	\N
ec12c5c4-e40b-4917-83af-07f84383ae77	2025-05-29 02:51:10.030648+00	06082977-180b-4170-a3d5-72f7005652a9	af19c3d0-4797-46bb-8ad5-cf818a693ac3	\N	worth_the_effort	\N	2025-05-29 02:51:30.037461+00	\N
dcfacd8a-ba59-45d6-8254-b2f23477a35a	2025-05-29 04:12:33.216502+00	7f2169d3-894f-484f-bf65-8be242c8cd24	ba136da2-7e08-4b99-989f-997cc7da5a4c	\N	depends_on_context	\N	2025-05-29 04:15:05.603113+00	\N
ad19f4c9-e31a-4cf8-85a6-8565da534a0f	2025-05-28 22:18:17.716602+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	1ef315d8-9eef-48be-bbc8-b9728991ac10	\N	not_for_me	\N	2025-05-31 13:05:25.703542+00	\N
7a9cd92e-89ad-4fc5-a0ea-3fac13b3ac75	2025-05-28 17:24:56.882966+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	bda40a00-6f80-4934-8687-2e2946e207c9	\N	nice_to_catch	\N	2025-05-31 12:18:06.833849+00	\N
c8b820e7-0339-4fa5-8a28-49e101135d6f	2025-05-28 17:31:43.0868+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	8d672b69-4006-4ed0-bb5e-8de6c504223d	\N	nice_to_catch	\N	2025-05-28 17:33:24.076794+00	\N
1f1c9525-9bd9-460c-b52c-5d06f78c89ee	2025-05-29 03:55:06.474012+00	7f2169d3-894f-484f-bf65-8be242c8cd24	cfb93b76-9df9-4359-8757-384063e62ef2	\N	unranked	\N	2025-05-29 03:55:06.474012+00	\N
64a0f236-485d-49cb-9b1d-dc3ad39a3ab8	2025-05-29 04:13:01.516062+00	7f2169d3-894f-484f-bf65-8be242c8cd24	f033c53c-fca2-4fff-bc3c-1e49e2163515	\N	unranked	\N	2025-05-29 04:13:01.516062+00	\N
2ff8d968-5d06-4111-a000-07bbe28826c9	2025-05-29 04:13:14.61926+00	7f2169d3-894f-484f-bf65-8be242c8cd24	91b4afa4-e104-473b-8cc6-7a31688e8e1c	\N	nice_to_catch	\N	2025-05-29 04:13:27.816553+00	\N
534462d0-0bad-4be5-90b1-1473a83f21a2	2025-05-29 04:13:10.407254+00	7f2169d3-894f-484f-bf65-8be242c8cd24	e9e87d59-3ebe-4bd2-9a13-9787d02610de	\N	worth_the_effort	\N	2025-05-29 04:13:33.121556+00	\N
873414cd-dc82-41f3-bed8-521bda661529	2025-05-29 04:13:09.336287+00	7f2169d3-894f-484f-bf65-8be242c8cd24	8787935e-a836-41f7-bcb0-e239701eedad	\N	worth_the_effort	\N	2025-05-29 04:13:35.386256+00	\N
e24606fc-8200-43ea-bf4c-b946c0cd3fcd	2025-05-29 04:12:56.425825+00	7f2169d3-894f-484f-bf65-8be242c8cd24	03198e4d-0bd0-40bb-8a15-d07c3ace24e2	\N	must_see	\N	2025-05-29 04:13:40.180525+00	\N
6397eb30-3c3e-4f0d-85a0-88bd51bc44c1	2025-05-29 04:12:49.829264+00	7f2169d3-894f-484f-bf65-8be242c8cd24	d9dc1b8a-4e9d-4284-a5bf-0cf24cc75e50	\N	worth_the_effort	\N	2025-05-29 04:13:42.327958+00	\N
33271ebb-2a62-441b-9b31-7fede1f8e412	2025-05-29 04:12:47.156351+00	7f2169d3-894f-484f-bf65-8be242c8cd24	d9aacecd-4e49-4504-99a7-7865352caed3	\N	worth_the_effort	\N	2025-05-29 04:13:44.03906+00	\N
c45cee85-48a9-43fa-a70d-2794589b0f72	2025-05-29 04:13:53.041854+00	7f2169d3-894f-484f-bf65-8be242c8cd24	91f2f3b2-7222-4f54-a961-71152e5fb8b9	\N	must_see	\N	2025-05-29 04:13:57.806158+00	\N
a77aa3c1-43dd-4a0e-ab70-da1a3cf8c9fc	2025-05-29 04:12:11.955053+00	7f2169d3-894f-484f-bf65-8be242c8cd24	6d97d81b-01c0-4c37-a28f-d2067f3e9509	\N	worth_the_effort	\N	2025-05-29 04:14:09.651449+00	\N
6140739f-0d62-4436-a14f-b10bbdd8c93a	2025-05-29 04:12:13.611964+00	7f2169d3-894f-484f-bf65-8be242c8cd24	c88ed6f7-bf92-4615-aa57-4e350b785df0	\N	nice_to_catch	\N	2025-05-29 04:14:13.027268+00	\N
c7cf08e1-c9b7-427d-a3f3-0d7aca113508	2025-05-29 04:12:00.191618+00	7f2169d3-894f-484f-bf65-8be242c8cd24	09bcd870-e9c0-4e32-af0b-645558f64e44	\N	nice_to_catch	\N	2025-05-29 04:14:16.318118+00	\N
5e14bac7-68ce-484e-9334-91944b0b912f	2025-05-29 04:11:10.469059+00	7f2169d3-894f-484f-bf65-8be242c8cd24	af19c3d0-4797-46bb-8ad5-cf818a693ac3	\N	worth_the_effort	\N	2025-05-29 04:14:18.961259+00	\N
f765b92e-7252-4b5d-96cb-661578f23cc4	2025-05-29 04:11:02.827355+00	7f2169d3-894f-484f-bf65-8be242c8cd24	d4078249-02ee-4c40-9dfc-281dc176f165	\N	must_see	\N	2025-05-29 04:14:22.287394+00	\N
acaf04ba-4676-4523-906d-112420112f1d	2025-05-29 03:55:00.472611+00	7f2169d3-894f-484f-bf65-8be242c8cd24	c328eee0-e7a7-4898-92fc-03986af2315b	\N	worth_the_effort	\N	2025-05-29 04:14:24.34735+00	\N
4cac2768-2237-4b30-8ab4-ec4f927de4ca	2025-05-29 03:54:43.840785+00	7f2169d3-894f-484f-bf65-8be242c8cd24	6a2d3037-1e9d-4716-a7e4-9876a2d654d9	\N	must_see	\N	2025-05-29 04:14:35.187173+00	\N
76cd5b51-647f-4661-a5b7-cd70d5f8d71b	2025-05-29 03:53:44.593686+00	7f2169d3-894f-484f-bf65-8be242c8cd24	0e8d2c15-ccdd-4943-9944-15fcc2088c8d	\N	nice_to_catch	\N	2025-05-29 04:14:38.822304+00	\N
ba83f25e-6b2b-45f8-9c47-e5a3160c33c0	2025-05-29 03:53:58.399969+00	7f2169d3-894f-484f-bf65-8be242c8cd24	3c93268e-2cb9-4178-aa98-de903cee400e	\N	must_see	\N	2025-05-29 04:14:42.143481+00	\N
b32b016e-7b08-4764-af2e-d1233d2da9e8	2025-05-29 03:54:31.653036+00	7f2169d3-894f-484f-bf65-8be242c8cd24	04a6c2ff-926a-4e3e-8998-607f87cc44a4	\N	worth_the_effort	\N	2025-05-29 04:14:49.436218+00	\N
f54f601e-51dd-4fb5-9707-43708f1d187c	2025-05-29 04:11:05.301124+00	7f2169d3-894f-484f-bf65-8be242c8cd24	b14f3f69-f29e-4695-9c0e-1b933c30f02d	\N	must_see	\N	2025-05-29 04:14:51.33993+00	\N
c0d66438-9274-44a0-b4d5-aa72ccc33911	2025-05-29 03:54:01.958573+00	7f2169d3-894f-484f-bf65-8be242c8cd24	a0b3fdde-922b-4ad8-97c9-1680acde14c6	\N	nice_to_catch	\N	2025-05-29 04:14:54.529856+00	\N
06df7c1b-659e-466b-ba64-a97065ab88c6	2025-05-29 03:53:00.045091+00	7f2169d3-894f-484f-bf65-8be242c8cd24	cbe86f61-e078-4e41-a080-e3cb34655b1a	\N	worth_the_effort	\N	2025-05-29 04:14:58.522961+00	\N
0000e0cd-640b-485d-a4cc-30c4d3d4ebb9	2025-05-29 04:12:29.713167+00	7f2169d3-894f-484f-bf65-8be242c8cd24	effeab64-1222-4afb-91c4-9eaf8b89efe5	\N	worth_the_effort	\N	2025-05-29 04:15:08.20117+00	\N
b5021537-165b-425d-a3a1-e6b12abc50c9	2025-05-29 03:53:40.631997+00	7f2169d3-894f-484f-bf65-8be242c8cd24	896d1939-d580-4c04-86d5-55fc7b4eae9b	\N	must_see	\N	2025-05-29 04:15:18.983614+00	\N
12263d47-94a5-4306-880e-bb219ce87cae	2025-05-29 03:53:36.671029+00	7f2169d3-894f-484f-bf65-8be242c8cd24	6b4f0e47-8d36-4f0c-8de3-e4d2f0bdaf4f	\N	nice_to_catch	\N	2025-05-29 04:15:24.546792+00	\N
5d8fc982-44ea-4ff8-8bc1-ee3a0af5769e	2025-05-29 03:55:02.847377+00	7f2169d3-894f-484f-bf65-8be242c8cd24	c12473f3-6818-43ec-b547-22773a403e5e	\N	worth_the_effort	\N	2025-05-29 04:15:26.824527+00	\N
a6dd2310-4667-4743-b9b8-861dbc1da276	2025-05-29 03:53:09.874885+00	7f2169d3-894f-484f-bf65-8be242c8cd24	251010cf-e3e4-464b-b9bb-a5d004a87436	\N	depends_on_context	\N	2025-05-29 04:15:32.96611+00	\N
0f96bf9d-382c-4399-82fb-d3dc9cfe5a6b	2025-05-29 03:52:51.497592+00	7f2169d3-894f-484f-bf65-8be242c8cd24	2738faf7-37f0-4185-949a-89cfd3886c0a	\N	depends_on_context	\N	2025-05-29 04:15:35.802013+00	\N
2853b5e4-5063-4e3e-b154-c12b7283c472	2025-05-29 03:53:16.981789+00	7f2169d3-894f-484f-bf65-8be242c8cd24	529e0560-6c77-4f9a-ba42-d33a2a5be212	\N	depends_on_context	\N	2025-05-29 04:15:37.650428+00	\N
c42b9d52-b7c1-4826-b4ce-21806055286f	2025-05-29 03:54:49.220963+00	7f2169d3-894f-484f-bf65-8be242c8cd24	0dfda089-c25b-4616-859f-fb3e0f6887df	\N	nice_to_catch	\N	2025-05-29 04:15:46.096402+00	\N
f99709c2-c1ad-4032-b338-5678a848a863	2025-05-29 03:55:09.146758+00	7f2169d3-894f-484f-bf65-8be242c8cd24	9e5899d6-ad8b-4a43-9fc6-ec062ad6fbe5	\N	nice_to_catch	\N	2025-05-29 04:15:48.774446+00	\N
b5f20c32-63e0-4e8e-a439-9c7aad904b10	2025-05-29 03:55:13.56662+00	7f2169d3-894f-484f-bf65-8be242c8cd24	312b7a85-2a3c-4c22-ab67-c6b164c34c76	\N	worth_the_effort	\N	2025-05-29 04:15:51.741431+00	\N
cd60b0c3-ddd2-49bc-a960-ec51c592f085	2025-05-29 03:55:09.952773+00	7f2169d3-894f-484f-bf65-8be242c8cd24	d4bc2ec6-4a61-4fa3-837d-4a1021397a48	\N	nice_to_catch	\N	2025-05-29 04:15:56.256677+00	\N
ea78bbdf-78be-4d5c-aacb-5feee3403f82	2025-05-29 04:11:18.657916+00	7f2169d3-894f-484f-bf65-8be242c8cd24	f0efedf2-57e4-4680-8f61-758b5eb44d25	\N	worth_the_effort	\N	2025-05-29 04:15:58.7644+00	\N
9daef23c-9aa1-4baf-8772-aee1ac16847d	2025-05-29 04:12:39.414054+00	7f2169d3-894f-484f-bf65-8be242c8cd24	14de17b4-ad41-4c59-af07-7c15f73d2df2	\N	depends_on_context	\N	2025-05-29 04:16:05.363355+00	\N
8c556eb3-1914-49ca-8d54-8d90e797eb41	2025-05-29 04:12:26.32725+00	7f2169d3-894f-484f-bf65-8be242c8cd24	efcf0d8c-13e5-4254-94b5-4c58ca7ae811	\N	must_see	\N	2025-05-29 04:16:10.102553+00	\N
06f24f27-10e3-4bf9-9daf-5ddf6da33bb4	2025-05-29 04:11:58.454505+00	7f2169d3-894f-484f-bf65-8be242c8cd24	baa43c55-7964-4641-a10c-3d48b4687e61	\N	depends_on_context	\N	2025-05-29 04:23:46.40791+00	\N
12fda984-23fa-4ce7-994d-4bde181672b9	2025-05-28 18:41:51.45831+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	05d2c5fc-23ba-4376-8983-c4d18af1c4dc	\N	nice_to_catch	\N	2025-05-31 13:40:03.415453+00	\N
030d19c0-bcdb-4682-b057-2f886c7ace07	2025-05-28 16:39:09.125791+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	00bb3ab7-03ae-451d-9c37-44ad2f8e892d	\N	nice_to_catch	\N	2025-05-31 15:25:22.270085+00	\N
8a5979e7-a8e3-41aa-afae-57b7f2bea1c9	2025-05-29 03:54:25.084221+00	7f2169d3-894f-484f-bf65-8be242c8cd24	5433d511-91ae-47d4-9300-b60debf25374	\N	worth_the_effort	\N	2025-05-29 04:15:42.12147+00	\N
e83d678e-4862-4089-b63f-7eb34f61d25f	2025-05-29 04:16:34.305905+00	7f2169d3-894f-484f-bf65-8be242c8cd24	b998a6b5-407b-408c-8332-36d631792dd1	\N	unranked	\N	2025-05-29 04:16:34.305905+00	\N
c73b82b0-37a9-4aa7-8caa-a95c82521280	2025-05-29 04:19:03.301758+00	7f2169d3-894f-484f-bf65-8be242c8cd24	399dfe29-7032-4c75-b9eb-cc57059c4979	\N	unranked	\N	2025-05-29 04:19:03.301758+00	\N
33f512f2-4a58-4789-83df-45d32ec7ac58	2025-05-29 04:19:33.577321+00	7f2169d3-894f-484f-bf65-8be242c8cd24	40e5cff6-cfd9-4e03-b9d8-6e1c4ddfc2eb	\N	unranked	\N	2025-05-29 04:19:33.577321+00	\N
c4a05990-9fce-4bd6-afcb-6f81ea18eceb	2025-05-29 04:20:23.65837+00	7f2169d3-894f-484f-bf65-8be242c8cd24	fb8ef487-ed6f-49f5-8350-99a2b1c87da2	\N	unranked	\N	2025-05-29 04:20:23.65837+00	\N
daee5288-c365-49fd-8d02-74379e95e3d2	2025-05-29 04:21:58.84237+00	7f2169d3-894f-484f-bf65-8be242c8cd24	2b03801f-952a-4956-bf78-e055da97d490	\N	unranked	\N	2025-05-29 04:21:58.84237+00	\N
28f85912-6087-4ab0-9a2f-a8809b275ec8	2025-05-29 04:21:52.322952+00	7f2169d3-894f-484f-bf65-8be242c8cd24	74156f52-825c-4176-a1db-52f2ce49e322	\N	must_see	\N	2025-05-29 04:22:58.731671+00	\N
340931bf-f512-4e96-9366-ea4bad0db1b8	2025-05-29 04:22:34.262802+00	7f2169d3-894f-484f-bf65-8be242c8cd24	df085140-4e96-46ed-b256-38eb250455ee	\N	must_see	\N	2025-05-29 04:23:00.864662+00	\N
835c143a-8fb5-4af7-a52b-acaffa476bfb	2025-05-29 04:17:32.503029+00	7f2169d3-894f-484f-bf65-8be242c8cd24	ed77a0a0-b6f7-40da-9c65-c1da43a57b18	\N	must_see	\N	2025-05-29 04:23:03.161756+00	\N
9219f01a-2145-43cf-adef-b487464bfc35	2025-05-29 04:16:52.32903+00	7f2169d3-894f-484f-bf65-8be242c8cd24	2ff236d1-79c7-4024-82e2-36ab8448b544	\N	must_see	\N	2025-05-29 04:23:08.698359+00	\N
782d317d-86df-4957-b88b-9505aff88b20	2025-05-29 04:16:46.985362+00	7f2169d3-894f-484f-bf65-8be242c8cd24	1c32cf44-79e3-4c2a-b52a-8f7d33454d97	\N	nice_to_catch	\N	2025-05-29 04:23:11.050039+00	\N
2bf35230-17ae-4e30-9235-94f519031705	2025-05-29 04:17:35.620123+00	7f2169d3-894f-484f-bf65-8be242c8cd24	dcb49616-3db2-439e-8e94-c4eba88edfbd	\N	depends_on_context	\N	2025-05-29 04:23:14.282498+00	\N
3fd933ba-ee19-4708-8f09-c457b6ed5073	2025-05-29 04:17:52.142603+00	7f2169d3-894f-484f-bf65-8be242c8cd24	9ae66327-d7e1-4e94-9e2e-9e167522bb27	\N	nice_to_catch	\N	2025-05-29 04:23:17.112047+00	\N
6120a2f4-1f1f-4518-804a-d8a349065cb5	2025-05-29 04:19:00.13166+00	7f2169d3-894f-484f-bf65-8be242c8cd24	5deaa96a-b9e9-42c6-93b3-54fed8a6fa66	\N	depends_on_context	\N	2025-05-29 04:23:20.309759+00	\N
2650fbef-611b-4589-aa7d-1abb7ca7c9e1	2025-05-29 04:16:32.322844+00	7f2169d3-894f-484f-bf65-8be242c8cd24	deec7ef9-3016-4cea-8a72-cdc20bd84de9	\N	must_see	\N	2025-05-29 04:23:22.78462+00	\N
3e9ad992-9164-42f9-a83d-8d8ecc292439	2025-05-29 04:19:45.59366+00	7f2169d3-894f-484f-bf65-8be242c8cd24	39218df5-8857-4e8e-a69a-36214b8e9d96	\N	must_see	\N	2025-05-29 04:23:27.959628+00	\N
a0f05877-5993-4993-bb84-2f68ac2a1a2a	2025-05-29 04:20:38.312315+00	7f2169d3-894f-484f-bf65-8be242c8cd24	0d253ebe-6120-431c-9654-acb9b41480b0	\N	nice_to_catch	\N	2025-05-29 04:23:33.861991+00	\N
a4561d51-a528-4af9-b1b6-76e89057381f	2025-05-29 04:20:48.176229+00	7f2169d3-894f-484f-bf65-8be242c8cd24	6ce195f4-9bd9-43a6-8c5d-297e5259228c	\N	nice_to_catch	\N	2025-05-29 04:23:37.413371+00	\N
4b6a11bb-3383-44cd-9ffd-ebb7f19152d7	2025-05-29 04:21:22.131018+00	7f2169d3-894f-484f-bf65-8be242c8cd24	82b3a6d3-7751-4fa9-810d-c8f65bdd4735	\N	depends_on_context	\N	2025-05-29 04:23:40.26245+00	\N
2da485dc-6163-4f94-aa4e-6f6fcbc0161f	2025-05-29 04:19:22.360049+00	7f2169d3-894f-484f-bf65-8be242c8cd24	87b41ea5-c560-4722-9176-9a2b14d8cce5	\N	depends_on_context	\N	2025-05-29 04:23:55.028223+00	\N
d7a09535-fca4-4707-9eb8-2d205434f5a2	2025-05-29 05:10:09.086296+00	7f2169d3-894f-484f-bf65-8be242c8cd24	5793846d-0815-4ef9-afb1-0add3b8fbb30	\N	unranked	\N	2025-05-29 05:10:09.086296+00	\N
d2dafb4a-1a06-462b-b825-e7e54573101f	2025-05-29 05:14:30.166591+00	7f2169d3-894f-484f-bf65-8be242c8cd24	35e7c4f0-e39b-4d60-8b67-931a2280b494	\N	unranked	\N	2025-05-29 05:14:30.166591+00	\N
1035cdda-ff3c-405d-8256-fb69250a187d	2025-05-29 05:15:45.72545+00	7f2169d3-894f-484f-bf65-8be242c8cd24	4675fb22-1159-4183-b3fa-4561f7df57e4	\N	unranked	\N	2025-05-29 05:15:45.72545+00	\N
83e77e5d-3562-4f84-b82f-a5570a55e7af	2025-05-29 05:22:36.093559+00	7f2169d3-894f-484f-bf65-8be242c8cd24	f9ea4624-18e0-46c5-93b1-512cbf7cbc7c	\N	unranked	\N	2025-05-29 05:22:36.093559+00	\N
ea66e0b1-324f-404b-af70-74fdde0545e0	2025-05-29 05:22:41.106391+00	7f2169d3-894f-484f-bf65-8be242c8cd24	100edba3-2443-40a3-bd9e-935e9a7770aa	\N	unranked	\N	2025-05-29 05:22:41.106391+00	\N
9787d140-79ca-4046-8283-93c2bccc5fd5	2025-05-29 05:25:14.805776+00	7f2169d3-894f-484f-bf65-8be242c8cd24	4c5325ac-f7b1-47ab-b3d1-7d5ce3535c55	\N	unranked	\N	2025-05-29 05:25:14.805776+00	\N
0bf12b82-994d-464b-b538-ba3b5688e2ba	2025-05-29 05:25:25.238209+00	7f2169d3-894f-484f-bf65-8be242c8cd24	8d70afd4-c541-4a0e-9fa4-40b0271f4d69	\N	unranked	\N	2025-05-29 05:25:25.238209+00	\N
316a58c5-7220-4261-9409-8473f8ae9b43	2025-05-29 05:10:21.721937+00	7f2169d3-894f-484f-bf65-8be242c8cd24	1ab79c35-2148-494d-89a4-a854969c8869	\N	worth_the_effort	\N	2025-05-29 06:32:56.129804+00	\N
1e63025f-89e0-4bfe-9382-9f08095a2ad8	2025-05-29 05:13:36.808319+00	7f2169d3-894f-484f-bf65-8be242c8cd24	11ab2bff-caf6-4824-b632-1c3fde9886c1	\N	nice_to_catch	\N	2025-05-29 06:33:04.536155+00	\N
2338da02-492c-43a7-bcca-1de61e7a9c51	2025-05-29 05:10:07.539801+00	7f2169d3-894f-484f-bf65-8be242c8cd24	b3c2b328-2c0b-41ea-89a3-6f242884eecd	\N	must_see	\N	2025-05-29 06:33:17.108209+00	\N
4b27f0e5-804a-48ed-a880-add4d71cf3f5	2025-05-29 05:09:57.511594+00	7f2169d3-894f-484f-bf65-8be242c8cd24	53cf4ee2-936b-4c34-af4d-332fb75fc5cc	\N	worth_the_effort	\N	2025-05-29 06:33:26.725656+00	\N
8d09d1a7-b175-44fb-9e4c-9ceeb2315846	2025-05-29 05:08:08.107245+00	7f2169d3-894f-484f-bf65-8be242c8cd24	7e37c869-3c43-44e1-a933-5530e4db2d5d	\N	must_see	\N	2025-05-29 06:33:39.023554+00	\N
fd934425-181b-4122-b98d-f1041f0e3dde	2025-05-29 21:57:37.725443+00	7f2169d3-894f-484f-bf65-8be242c8cd24	ccc0cac3-9fd6-4884-beb7-3fdbd04b533a	\N	must_see	\N	2025-05-29 21:57:42.908916+00	\N
a5a603f7-5012-4694-85e2-9a367bb4f16e	2025-05-29 21:54:22.101173+00	7f2169d3-894f-484f-bf65-8be242c8cd24	e36ef47e-9501-49e6-9486-bf15d790eb1c	\N	must_see	\N	2025-05-29 21:57:52.2561+00	\N
dcc59dbe-36ea-4e48-98e1-9cb04bc94986	2025-05-29 21:46:50.412998+00	7f2169d3-894f-484f-bf65-8be242c8cd24	d2dc9307-0a0b-45a7-94ff-d22fff4e6121	\N	must_see	\N	2025-05-29 21:57:55.455919+00	\N
155caf26-6b16-4322-bcc9-f364d7a713b9	2025-05-29 05:18:26.169003+00	7f2169d3-894f-484f-bf65-8be242c8cd24	1935575c-6b2b-4f41-b8fc-edd258397c2e	\N	worth_the_effort	\N	2025-05-29 21:58:00.951599+00	\N
57f3fa53-4e68-4d92-8965-1214e1b39a40	2025-05-29 05:15:01.210661+00	7f2169d3-894f-484f-bf65-8be242c8cd24	408068ff-c8a4-43a5-93da-95d02e59fca7	\N	nice_to_catch	\N	2025-05-29 21:58:06.162228+00	\N
7fb9cccf-41e9-4d5a-9748-ac2adaaf5263	2025-05-29 22:08:13.323192+00	7f2169d3-894f-484f-bf65-8be242c8cd24	bbc928b2-37c2-484e-a098-cba93cec0c02	\N	unranked	\N	2025-05-29 22:08:13.323192+00	\N
ab6af593-b10f-4a41-8742-6be1abdf4461	2025-05-29 22:08:19.568055+00	7f2169d3-894f-484f-bf65-8be242c8cd24	20819972-5859-4db6-a4bb-dba1d0f4debe	\N	unranked	\N	2025-05-29 22:08:19.568055+00	\N
7201563b-f555-4317-a066-8336eccfa53a	2025-05-29 22:00:32.744595+00	7f2169d3-894f-484f-bf65-8be242c8cd24	b5df5cf8-999a-413e-a3f5-8d12c5998be3	\N	nice_to_catch	\N	2025-05-29 22:27:24.649233+00	\N
5adb1e30-6a38-4042-afde-8cf1c080a660	2025-05-29 21:49:03.020597+00	7f2169d3-894f-484f-bf65-8be242c8cd24	cef58682-aa2a-4be6-85d5-c563eaeafe05	\N	depends_on_context	\N	2025-05-29 22:27:29.145653+00	\N
2b5fb987-78fd-4686-8533-8fc8f8517da8	2025-05-29 22:06:36.638512+00	7f2169d3-894f-484f-bf65-8be242c8cd24	e387fe82-de95-4b51-bb07-a8906557e2aa	\N	depends_on_context	\N	2025-05-29 22:27:32.554956+00	\N
c42960f9-1146-4494-9c1e-0c9afc556489	2025-05-29 05:18:29.930137+00	7f2169d3-894f-484f-bf65-8be242c8cd24	b2bac8b5-7e3c-45f5-a9b2-ee98cce286c1	\N	depends_on_context	\N	2025-05-29 22:27:37.63948+00	\N
eb4b414f-d303-4c3b-89f6-74b938429b65	2025-05-29 04:20:20.870291+00	7f2169d3-894f-484f-bf65-8be242c8cd24	d3046501-1cc4-4f36-bea6-fdcba9ceac7c	\N	depends_on_context	\N	2025-05-29 22:27:44.847906+00	\N
f0b77772-eec5-478b-af48-93c600511067	2025-05-29 21:47:28.475922+00	7f2169d3-894f-484f-bf65-8be242c8cd24	b93cf86d-6480-4418-aa5f-f8413c204711	\N	nice_to_catch	\N	2025-05-29 22:27:53.639557+00	\N
4781e6c5-f279-4115-9b17-2e7ea6c96ede	2025-05-29 22:05:11.564447+00	7f2169d3-894f-484f-bf65-8be242c8cd24	4eaaa400-d5ad-4d08-aeb2-63e77e27391e	\N	worth_the_effort	\N	2025-05-29 22:28:00.845416+00	\N
1efbc698-1d0a-4f42-8083-83d0be4a80b7	2025-05-29 22:06:02.691115+00	7f2169d3-894f-484f-bf65-8be242c8cd24	0c88940f-d78b-406c-9f17-ecdc1b1842cb	\N	must_see	\N	2025-05-29 22:28:05.303677+00	\N
4250a78b-a0e5-419e-b03b-faceac003f96	2025-05-29 22:09:24.75118+00	7f2169d3-894f-484f-bf65-8be242c8cd24	998ca517-d793-4e53-8859-fadd418da2b2	\N	must_see	\N	2025-05-29 22:28:08.59194+00	\N
76629fac-bbc0-4883-817e-ce22ed249464	2025-05-29 22:01:53.495227+00	7f2169d3-894f-484f-bf65-8be242c8cd24	cc4ec826-fec6-43a5-bd2a-df79453908d7	\N	depends_on_context	\N	2025-05-29 22:28:13.639879+00	\N
9f5b2f2a-b3a9-450a-9433-c5b6dc1b2e03	2025-05-29 22:23:33.070234+00	7f2169d3-894f-484f-bf65-8be242c8cd24	1175a04b-450f-4618-b7f0-f9777600bf78	\N	worth_the_effort	\N	2025-05-29 22:28:17.345931+00	\N
c68f61c5-8df0-4f7c-8c24-9f807c6dc301	2025-05-29 22:23:50.500879+00	7f2169d3-894f-484f-bf65-8be242c8cd24	94f2f589-b501-4a61-98ff-98b802394b0d	\N	must_see	\N	2025-05-29 22:28:19.437736+00	\N
43c4d8c9-5bce-432a-b975-e94c300d7dcd	2025-05-29 21:48:02.825371+00	7f2169d3-894f-484f-bf65-8be242c8cd24	c1c24e02-6163-4ec1-9e01-7be09048b365	\N	nice_to_catch	\N	2025-05-29 22:28:27.995435+00	\N
f70ee7ac-6377-48e0-b36d-a89aff5ae5a6	2025-05-29 22:33:57.611713+00	7f2169d3-894f-484f-bf65-8be242c8cd24	c0bfac75-1573-4d1f-bf91-ab6689e12bfa	\N	must_see	\N	2025-05-29 22:34:03.62731+00	\N
6c309128-7e0a-4a39-828c-932e6f2c3247	2025-05-30 04:55:28.573354+00	7f2169d3-894f-484f-bf65-8be242c8cd24	20ebf32e-65ef-4085-b352-02fecc95c06a	\N	unranked	\N	2025-05-30 04:55:28.573354+00	\N
67c51a87-4d95-4937-acaa-85781550a643	2025-05-30 04:54:49.684561+00	7f2169d3-894f-484f-bf65-8be242c8cd24	4b5837f1-f7fe-423f-a027-ce6e9699f200	\N	worth_the_effort	\N	2025-06-03 05:08:32.877395+00	\N
135d66df-4cef-419d-9a2b-7f47c9ddc97c	2025-05-30 09:06:18.041837+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	2ff236d1-79c7-4024-82e2-36ab8448b544	\N	worth_the_effort	\N	2025-05-30 09:07:02.08274+00	\N
ad0ffcf9-bc00-4865-9d2a-a664e3ae4907	2025-05-30 09:07:40.657131+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	cbe86f61-e078-4e41-a080-e3cb34655b1a	\N	unranked	\N	2025-05-30 09:07:40.657131+00	\N
cced25d8-3750-49b5-a16d-7a6c6b1f2a81	2025-05-30 09:09:16.800384+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	e35d21f2-94ee-4a50-b626-1b983b125327	\N	unranked	\N	2025-05-30 09:09:16.800384+00	\N
980f1504-6b3e-4515-aea0-0b8a47115ea2	2025-05-30 09:10:00.806315+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	312b7a85-2a3c-4c22-ab67-c6b164c34c76	\N	unranked	\N	2025-05-30 09:10:00.806315+00	\N
b747dab3-a377-4803-a4a5-39a96af4c432	2025-05-30 09:10:02.71465+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	5f1be115-c6f5-4fdb-8f4a-b865d3780b54	\N	unranked	\N	2025-05-30 09:10:02.71465+00	\N
5ddc193b-1bc2-4a32-b6ee-0c46bd3795ee	2025-05-30 09:10:44.485765+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	deec7ef9-3016-4cea-8a72-cdc20bd84de9	\N	unranked	\N	2025-05-30 09:10:44.485765+00	\N
76d35d0a-7084-435c-94be-e3e39b317286	2025-05-30 09:10:54.385445+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	4eaaa400-d5ad-4d08-aeb2-63e77e27391e	\N	unranked	\N	2025-05-30 09:10:54.385445+00	\N
5bf79c8e-9636-4248-82cc-0ebc0b0b6a55	2025-05-30 09:11:01.068764+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	91f2f3b2-7222-4f54-a961-71152e5fb8b9	\N	unranked	\N	2025-05-30 09:11:01.068764+00	\N
1b454e51-a78e-475b-8e8e-3aff13855635	2025-05-30 09:11:08.678465+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	03198e4d-0bd0-40bb-8a15-d07c3ace24e2	\N	unranked	\N	2025-05-30 09:11:08.678465+00	\N
98becdb9-f0e6-4665-a178-d67137ad796c	2025-05-30 09:11:22.091799+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	df085140-4e96-46ed-b256-38eb250455ee	\N	unranked	\N	2025-05-30 09:11:22.091799+00	\N
d765d1c5-11d1-40ac-b03c-69981da9c038	2025-05-30 09:11:46.270904+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	53cf4ee2-936b-4c34-af4d-332fb75fc5cc	\N	unranked	\N	2025-05-30 09:11:46.270904+00	\N
ff54c4b9-e046-4de7-8937-8a9cdff91295	2025-05-30 09:11:55.023742+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	c88ed6f7-bf92-4615-aa57-4e350b785df0	\N	unranked	\N	2025-05-30 09:11:55.023742+00	\N
ad621bca-6f0b-4b16-ae5f-84c932fd9363	2025-05-29 22:31:44.198773+00	7f2169d3-894f-484f-bf65-8be242c8cd24	86759873-08dc-42b4-8426-35ba0be89d3c	\N	nice_to_catch	\N	2025-06-03 06:19:12.977217+00	\N
178e65be-f085-4b4a-be06-f297f6067d08	2025-05-29 05:22:24.442473+00	7f2169d3-894f-484f-bf65-8be242c8cd24	84779002-0010-473f-853c-58f1feb3f962	\N	depends_on_context	\N	2025-06-03 06:19:25.714872+00	\N
7b59a991-22da-489b-9d14-de82db559a1a	2025-05-29 05:14:08.547264+00	7f2169d3-894f-484f-bf65-8be242c8cd24	987b37ad-8b72-459b-bbab-488495f64110	\N	worth_the_effort	\N	2025-06-03 06:19:30.274152+00	\N
f4b4b134-74f9-4ee9-8787-fdd87cd16ef4	2025-05-30 09:12:00.273799+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	6d97d81b-01c0-4c37-a28f-d2067f3e9509	\N	unranked	\N	2025-05-30 09:12:00.273799+00	\N
3762149a-ce5c-46e0-9eaa-6ddc6f924548	2025-05-30 09:12:09.430751+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	8de421d5-8326-4eb8-9841-73482086066a	\N	unranked	\N	2025-05-30 09:12:09.430751+00	\N
583d94f7-2ab6-4088-b646-72df508150c3	2025-05-30 09:12:15.571764+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	52b8d7cd-d509-4bac-8583-cb4ea065fdaa	\N	unranked	\N	2025-05-30 09:12:15.571764+00	\N
71af07b5-d87c-4534-bd8b-392f99823666	2025-05-30 09:12:16.583274+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	5793846d-0815-4ef9-afb1-0add3b8fbb30	\N	unranked	\N	2025-05-30 09:12:16.583274+00	\N
dbaba10b-1b32-4f3f-ba4d-5bcb3437eaa4	2025-05-30 09:12:21.867636+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	477e2eff-f202-4617-8b4c-8c134eca5317	\N	unranked	\N	2025-05-30 09:12:21.867636+00	\N
3d433f90-4fcf-44de-92a6-01ab38430550	2025-05-30 09:12:32.777237+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	5eb26bf5-f16d-4c2f-8ee1-4597d693f6c2	\N	unranked	\N	2025-05-30 09:12:32.777237+00	\N
cb32e316-6a6d-4b75-96fb-a9225f43f379	2025-05-30 09:13:11.944695+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	11ab2bff-caf6-4824-b632-1c3fde9886c1	\N	unranked	\N	2025-05-30 09:13:11.944695+00	\N
5c72b550-fe18-4339-ba84-4f8fabbcf03c	2025-05-30 09:13:15.362218+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	b998a6b5-407b-408c-8332-36d631792dd1	\N	unranked	\N	2025-05-30 09:13:15.362218+00	\N
6207626e-b8de-4617-9bf1-ab065845b098	2025-05-30 09:13:17.279802+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	f0efedf2-57e4-4680-8f61-758b5eb44d25	\N	unranked	\N	2025-05-30 09:13:17.279802+00	\N
3ff1574e-cc03-496b-b744-ba446b275c7d	2025-05-30 09:13:18.194686+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	39218df5-8857-4e8e-a69a-36214b8e9d96	\N	unranked	\N	2025-05-30 09:13:18.194686+00	\N
aa2697e1-3d70-4e66-aa4b-bbbf04d15a41	2025-05-30 09:13:21.502308+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	2eb51647-373d-4a11-9a30-dbe1a4ba0789	\N	unranked	\N	2025-05-30 09:13:21.502308+00	\N
e69ce29a-532e-43b8-bbb4-073dac54aa5e	2025-05-30 09:13:36.400392+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	d4078249-02ee-4c40-9dfc-281dc176f165	\N	unranked	\N	2025-05-30 09:13:36.400392+00	\N
5f377b99-40ee-4420-999f-3f3f9044aeee	2025-05-30 09:13:40.588175+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	b14f3f69-f29e-4695-9c0e-1b933c30f02d	\N	unranked	\N	2025-05-30 09:13:40.588175+00	\N
63c8eb67-8d64-44ff-acb2-46f9f44b96e9	2025-05-30 09:13:59.689688+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	d4bc2ec6-4a61-4fa3-837d-4a1021397a48	\N	unranked	\N	2025-05-30 09:13:59.689688+00	\N
9d813751-9f49-4c84-966b-10bf29cb307a	2025-05-30 09:14:02.474199+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	05409c9f-6b94-4f2b-ac42-f15e4f4f84ba	\N	unranked	\N	2025-05-30 09:14:02.474199+00	\N
43150830-3125-48ab-baf6-b3883868ac29	2025-05-30 09:14:13.353885+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	b3c2b328-2c0b-41ea-89a3-6f242884eecd	\N	unranked	\N	2025-05-30 09:14:13.353885+00	\N
38861f33-fac5-4b6d-87e7-590697ca2b93	2025-05-30 09:14:21.487075+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	6a2d3037-1e9d-4716-a7e4-9876a2d654d9	\N	unranked	\N	2025-05-30 09:14:21.487075+00	\N
6c513189-93a6-4118-a68b-8d61d5a2e397	2025-05-30 09:14:38.146907+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	35e7c4f0-e39b-4d60-8b67-931a2280b494	\N	unranked	\N	2025-05-30 09:14:38.146907+00	\N
705cfde7-c8a7-43fd-8559-1dfe21372109	2025-05-30 09:14:43.068387+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	987b37ad-8b72-459b-bbab-488495f64110	\N	unranked	\N	2025-05-30 09:14:43.068387+00	\N
eb8faee0-b180-4636-93c2-da21c7bb2887	2025-05-30 09:15:00.760253+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	6b4f0e47-8d36-4f0c-8de3-e4d2f0bdaf4f	\N	unranked	\N	2025-05-30 09:15:00.760253+00	\N
14e9d469-bb6e-43d2-975d-ba6a653963ed	2025-05-30 09:15:36.545196+00	b0b0ed7d-538a-4b52-bc1c-f5410677612c	6ce195f4-9bd9-43a6-8c5d-297e5259228c	\N	unranked	\N	2025-05-30 09:15:36.545196+00	\N
fbbdd4ce-e6ef-4d3b-8e14-cb3364cf2dfa	2025-05-30 09:44:26.176864+00	06082977-180b-4170-a3d5-72f7005652a9	d1dd8e3e-f4cf-497a-ac82-f746b1f77ad1	\N	unranked	\N	2025-05-30 09:44:26.176864+00	\N
a5fb3d68-d03b-40fc-8bf2-ebbf62a96e93	2025-05-30 09:44:29.604153+00	06082977-180b-4170-a3d5-72f7005652a9	04a6c2ff-926a-4e3e-8998-607f87cc44a4	\N	worth_the_effort	\N	2025-05-30 09:45:29.366891+00	\N
e7631c50-ce7b-4b83-aa8c-2cb03e012f5b	2025-05-30 09:45:08.660665+00	06082977-180b-4170-a3d5-72f7005652a9	6a2d3037-1e9d-4716-a7e4-9876a2d654d9	\N	must_see	\N	2025-05-30 09:45:31.664072+00	\N
539734b4-29f2-4b9f-a99f-2cc531ff089b	2025-05-30 09:46:38.230295+00	06082977-180b-4170-a3d5-72f7005652a9	03198e4d-0bd0-40bb-8a15-d07c3ace24e2	\N	worth_the_effort	\N	2025-05-30 09:46:48.146865+00	\N
75169369-f808-47eb-bc6f-2260fc8c2367	2025-05-30 09:46:58.663679+00	06082977-180b-4170-a3d5-72f7005652a9	5433d511-91ae-47d4-9300-b60debf25374	\N	worth_the_effort	\N	2025-05-30 09:47:02.545612+00	\N
576cfde6-6aaa-4b69-823f-82cb61f8b279	2025-05-30 09:49:34.145072+00	06082977-180b-4170-a3d5-72f7005652a9	0c88940f-d78b-406c-9f17-ecdc1b1842cb	\N	must_see	\N	2025-05-30 09:49:37.943253+00	\N
ae233754-0ebd-486b-bcec-44cfba8a52e1	2025-05-30 19:26:19.397562+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	fe56b223-e30e-4a75-9256-1a1edc43a910	\N	worth_the_effort	\N	2025-05-30 19:26:30.204577+00	\N
15c837e0-d376-4f6f-886a-72b46402c2c5	2025-05-31 04:44:52.927842+00	c3866d1b-210f-490a-b300-bde91941735b	ea413c86-587c-44ca-b209-c5cdd1e40c36	\N	must_see	\N	2025-05-31 04:46:20.95014+00	\N
b38648a8-d1c8-452e-b701-e3dcd0c0f19b	2025-05-31 04:46:06.954298+00	c3866d1b-210f-490a-b300-bde91941735b	df5e983f-965c-43ef-be0c-3784d9030ece	\N	worth_the_effort	\N	2025-05-31 04:46:24.778629+00	\N
47c5910b-65c5-45f4-8067-7450b9f1bc59	2025-05-31 12:15:56.04284+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	312d780b-61dc-4eff-9855-43474fcc67c9	\N	nice_to_catch	\N	2025-05-31 12:16:06.109851+00	\N
cd7cec7f-9a1e-45f1-9ecc-3ed29b22935f	2025-05-31 12:16:17.668351+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	85204815-53a8-4b46-8efd-00b5d0485478	\N	nice_to_catch	\N	2025-05-31 12:16:17.668351+00	\N
dae7b557-acff-42f0-99da-970dc0db4bfb	2025-05-31 12:16:30.332739+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	cf3a4113-c8fe-4f84-a5cf-63854917c954	\N	depends_on_context	\N	2025-05-31 12:16:30.332739+00	\N
56001af1-9d63-4973-be9e-aea58c2a0981	2025-05-31 12:16:42.917193+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	ae46228d-9a1e-433a-9586-aaf97db54b3f	\N	worth_the_effort	\N	2025-05-31 12:16:42.917193+00	\N
90f1d40f-ce6f-4b86-b00f-e296cfb27953	2025-05-31 12:16:59.097591+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	727fcb31-cb8f-48ce-a0d4-60b4511d9bea	\N	nice_to_catch	\N	2025-05-31 12:16:59.097591+00	\N
bbadbbe3-9310-41aa-82ed-a29227cfd169	2025-05-31 12:16:37.479331+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	f73e31b8-b650-491a-94c5-5a0dfe4e265d	\N	worth_the_effort	\N	2025-05-31 12:17:08.881897+00	\N
b74acd80-b344-42b1-8e39-ce5d9a4e9230	2025-06-01 04:10:51.327044+00	06082977-180b-4170-a3d5-72f7005652a9	cfb93b76-9df9-4359-8757-384063e62ef2	\N	depends_on_context	\N	2025-06-01 04:10:51.327044+00	\N
fbfd2ccf-ef3f-406c-a837-db80c0231a55	2025-06-01 04:10:58.480687+00	06082977-180b-4170-a3d5-72f7005652a9	1c32cf44-79e3-4c2a-b52a-8f7d33454d97	\N	worth_the_effort	\N	2025-06-01 04:10:58.480687+00	\N
9ed2546f-3b4e-4395-ab77-2c63621f1453	2025-06-01 04:11:03.807766+00	06082977-180b-4170-a3d5-72f7005652a9	11ab2bff-caf6-4824-b632-1c3fde9886c1	\N	nice_to_catch	\N	2025-06-01 04:11:03.807766+00	\N
16061c6c-4df1-4d6c-91b2-1fb5c24dc2b8	2025-06-01 04:11:12.729672+00	06082977-180b-4170-a3d5-72f7005652a9	dcb49616-3db2-439e-8e94-c4eba88edfbd	\N	nice_to_catch	\N	2025-06-01 04:11:12.729672+00	\N
ea8b44d5-4025-4a74-9bd3-6e57d78c5934	2025-06-01 04:02:02.179779+00	06082977-180b-4170-a3d5-72f7005652a9	cd51ef2d-109b-4319-abc8-b3a6fefe3973	\N	nice_to_catch	\N	2025-06-01 04:02:02.179779+00	\N
a3575ee7-097e-4dc9-b27c-162ccb9e7a6f	2025-06-01 04:02:30.282592+00	06082977-180b-4170-a3d5-72f7005652a9	93e26fc8-8621-4a91-b748-bda1a4d30b3f	\N	worth_the_effort	\N	2025-06-01 04:02:30.282592+00	\N
75373c1c-d8a7-4167-8107-f9121a605efd	2025-06-01 04:05:53.53485+00	06082977-180b-4170-a3d5-72f7005652a9	87c114d4-b366-4ed0-a238-6d6c06df12a8	\N	worth_the_effort	\N	2025-06-01 04:05:53.53485+00	\N
ad2fa704-38c1-4782-b660-3065adc1429f	2025-06-01 04:08:02.316906+00	06082977-180b-4170-a3d5-72f7005652a9	bda40a00-6f80-4934-8687-2e2946e207c9	\N	depends_on_context	\N	2025-06-01 04:08:02.316906+00	\N
3c3234a5-479a-4ea8-a562-7060bab4e1dc	2025-06-01 04:08:06.78172+00	06082977-180b-4170-a3d5-72f7005652a9	a0b3fdde-922b-4ad8-97c9-1680acde14c6	\N	depends_on_context	\N	2025-06-01 04:08:06.78172+00	\N
376449c8-f16a-4856-818d-05192ad1e21c	2025-06-01 04:08:11.233327+00	06082977-180b-4170-a3d5-72f7005652a9	35e7c4f0-e39b-4d60-8b67-931a2280b494	\N	nice_to_catch	\N	2025-06-01 04:08:11.233327+00	\N
0bab0dda-3821-4209-a388-a2a994a13d53	2025-06-01 04:09:19.308793+00	06082977-180b-4170-a3d5-72f7005652a9	c12473f3-6818-43ec-b547-22773a403e5e	\N	must_see	\N	2025-06-01 04:09:19.308793+00	\N
47321315-3360-4015-99e5-41eca7c3f362	2025-06-01 04:09:25.992334+00	06082977-180b-4170-a3d5-72f7005652a9	520a5fe5-3c1f-452e-80f0-122260e49497	\N	nice_to_catch	\N	2025-06-01 04:09:25.992334+00	\N
2931fe51-ae3d-4fb2-b508-98f8d563486f	2025-06-01 04:10:44.588626+00	06082977-180b-4170-a3d5-72f7005652a9	3d1b7778-c1e7-441c-8b7d-a960905a60f4	\N	worth_the_effort	\N	2025-06-01 04:10:44.588626+00	\N
1f575d2e-72bd-41bc-81e5-664c60702029	2025-06-01 04:10:47.359097+00	06082977-180b-4170-a3d5-72f7005652a9	312b7a85-2a3c-4c22-ab67-c6b164c34c76	\N	must_see	\N	2025-06-01 04:10:47.359097+00	\N
58ac0496-eecd-40f4-aba9-36b60a93f5b2	2025-06-01 04:11:17.235265+00	06082977-180b-4170-a3d5-72f7005652a9	baa43c55-7964-4641-a10c-3d48b4687e61	\N	nice_to_catch	\N	2025-06-01 04:11:17.235265+00	\N
9360cbaa-a843-4acb-9b7a-131c326c695a	2025-06-01 04:11:20.852293+00	06082977-180b-4170-a3d5-72f7005652a9	09bcd870-e9c0-4e32-af0b-645558f64e44	\N	worth_the_effort	\N	2025-06-01 04:11:20.852293+00	\N
650aaa76-34b0-42b7-a680-b79693cf6486	2025-06-01 04:11:24.871815+00	06082977-180b-4170-a3d5-72f7005652a9	6d97d81b-01c0-4c37-a28f-d2067f3e9509	\N	nice_to_catch	\N	2025-06-01 04:11:24.871815+00	\N
ac225ffd-02c9-4e1f-9496-fb87aaca5fa6	2025-06-01 04:11:38.481924+00	06082977-180b-4170-a3d5-72f7005652a9	b6582170-250f-4c8f-940b-f8422b2dc3a1	\N	nice_to_catch	\N	2025-06-01 04:11:38.481924+00	\N
02faff26-90a9-47d3-a228-2ba04afad481	2025-06-01 04:11:41.427044+00	06082977-180b-4170-a3d5-72f7005652a9	7e37c869-3c43-44e1-a933-5530e4db2d5d	\N	nice_to_catch	\N	2025-06-01 04:11:41.427044+00	\N
075995b6-d00b-4cd3-af5f-ac9ca6488d90	2025-06-01 04:12:00.574932+00	06082977-180b-4170-a3d5-72f7005652a9	d3046501-1cc4-4f36-bea6-fdcba9ceac7c	\N	not_for_me	\N	2025-06-01 04:12:00.574932+00	\N
22d89615-b1c6-4177-a8eb-67119797402d	2025-06-01 04:14:33.568249+00	06082977-180b-4170-a3d5-72f7005652a9	90733164-4d01-4262-844c-48c3ad58811a	\N	depends_on_context	\N	2025-06-01 04:14:33.568249+00	\N
95bb0265-4ca0-464f-b9fc-2653291f1e62	2025-06-01 04:15:02.281437+00	06082977-180b-4170-a3d5-72f7005652a9	b5df5cf8-999a-413e-a3f5-8d12c5998be3	\N	nice_to_catch	\N	2025-06-01 04:15:02.281437+00	\N
299f45c6-87a5-4bb5-b586-9eeffd028843	2025-06-01 04:15:06.540249+00	06082977-180b-4170-a3d5-72f7005652a9	59524fc3-ab6c-46dd-bc3d-1206cd8add3d	\N	worth_the_effort	\N	2025-06-01 04:15:06.540249+00	\N
b9b0b623-8e0f-482e-bd14-46ff9067dbe0	2025-06-01 04:15:12.790109+00	06082977-180b-4170-a3d5-72f7005652a9	1935575c-6b2b-4f41-b8fc-edd258397c2e	\N	worth_the_effort	\N	2025-06-01 04:15:12.790109+00	\N
67a4b6fb-5b6d-494c-96b4-815536c4fa8e	2025-06-01 04:15:18.184842+00	06082977-180b-4170-a3d5-72f7005652a9	576eb744-cdb3-4b16-a31d-6ab49e7a3e89	\N	depends_on_context	\N	2025-06-01 04:15:18.184842+00	\N
87ac72c9-050c-4f85-8107-ded36cbfea4f	2025-06-01 04:22:41.950315+00	06082977-180b-4170-a3d5-72f7005652a9	d4078249-02ee-4c40-9dfc-281dc176f165	\N	must_see	\N	2025-06-01 04:22:41.950315+00	\N
ba3691c7-a93f-47d3-983d-3ae2cb6f1ecd	2025-06-01 05:19:05.500689+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	b56b2920-37bf-46ed-8ede-c810e7bf8f07	\N	must_see	\N	2025-06-01 05:19:05.500689+00	\N
b0342de9-dc3f-4007-8475-d44a1d60641e	2025-06-01 05:19:13.601749+00	06082977-180b-4170-a3d5-72f7005652a9	f139e000-eae6-497f-9d85-75f4711ab4f9	\N	not_for_me	\N	2025-06-01 05:19:13.601749+00	\N
c3310a15-dbf7-4480-8d2d-80d376ef143c	2025-06-01 05:19:36.155963+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	e7e95fb5-597c-41f5-bfbc-a130c340f68a	\N	must_see	\N	2025-06-01 05:19:36.155963+00	\N
dd341f8f-1b63-44f1-9e72-f5b941e87b82	2025-06-01 05:19:56.351336+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	3d70d102-ff6c-4720-ade3-0b1e25a30336	\N	must_see	\N	2025-06-01 05:19:56.351336+00	\N
eb756fd4-e7f4-440b-a3ea-8a06b6d0da7c	2025-06-01 05:24:40.342527+00	06082977-180b-4170-a3d5-72f7005652a9	\N	\N	unranked	\N	2025-06-01 05:24:40.342527+00	617523cf-4675-4064-b4bc-c0a06e8b6d53
af29de40-4f59-42da-a71f-af0d40edb971	2025-06-01 05:27:50.453839+00	06082977-180b-4170-a3d5-72f7005652a9	a086100e-92d9-4f7a-a69d-82ea9e2661d3	\N	must_see	\N	2025-06-01 05:27:50.453839+00	\N
b184749a-1328-44fa-8d8e-420267666742	2025-06-01 06:57:52.178566+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	a21aa284-cf62-4345-aabf-2195094d6c63	\N	nice_to_catch	\N	2025-06-01 06:57:52.178566+00	\N
d606223e-84c9-48b4-8ef4-83648f992d22	2025-06-01 06:57:55.829769+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	a0b3fdde-922b-4ad8-97c9-1680acde14c6	\N	nice_to_catch	\N	2025-06-01 06:57:55.829769+00	\N
d209b4c4-4b52-446a-aa03-58d46dac502c	2025-06-01 06:57:58.906401+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	bda40a00-6f80-4934-8687-2e2946e207c9	\N	nice_to_catch	\N	2025-06-01 06:57:58.906401+00	\N
c4344f7f-5f2d-4431-9ab6-ecd7b1f6eb97	2025-06-01 06:58:04.782542+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	4b5837f1-f7fe-423f-a027-ce6e9699f200	\N	worth_the_effort	\N	2025-06-01 06:58:04.782542+00	\N
dca353df-c1a9-47ff-9658-e4c64ac49c32	2025-06-01 06:58:13.12212+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	35e7c4f0-e39b-4d60-8b67-931a2280b494	\N	nice_to_catch	\N	2025-06-01 06:58:13.12212+00	\N
7539184b-934a-4235-8550-e4fdfbe65461	2025-06-01 06:58:33.210975+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	82b3a6d3-7751-4fa9-810d-c8f65bdd4735	\N	nice_to_catch	\N	2025-06-01 06:58:33.210975+00	\N
a0990a98-372c-4df0-8f67-98da698dd9b3	2025-06-01 06:58:48.984069+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	69f9dfec-af6a-4db1-b864-bd7bf83fd4e1	\N	nice_to_catch	\N	2025-06-01 06:58:48.984069+00	\N
44ed682f-9445-4f80-87f9-6706208ef2ef	2025-06-01 06:58:51.915921+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	33391ef7-8678-445a-b96e-74e868f15393	\N	depends_on_context	\N	2025-06-01 06:58:51.915921+00	\N
98dbdcef-1781-4414-859e-8e15a12f9e2e	2025-06-01 06:58:55.8278+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	5433d511-91ae-47d4-9300-b60debf25374	\N	worth_the_effort	\N	2025-06-01 06:58:55.8278+00	\N
cc833cd3-9a67-4960-b57e-5cd23dec3b1c	2025-06-01 06:59:42.469821+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	2ff236d1-79c7-4024-82e2-36ab8448b544	\N	nice_to_catch	\N	2025-06-01 06:59:42.469821+00	\N
33f1c786-c997-40b3-bb7b-0bcefd4e44d5	2025-06-01 07:00:39.357289+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	520a5fe5-3c1f-452e-80f0-122260e49497	\N	nice_to_catch	\N	2025-06-01 07:00:39.357289+00	\N
63ff8633-184b-4b1c-b9af-bc6bb3a00d40	2025-06-01 07:01:14.326208+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	c41316c0-b177-4c9d-b8b7-097988b9534f	\N	nice_to_catch	\N	2025-06-01 07:01:14.326208+00	\N
45a8cebd-9db4-4929-af84-8ee542a24ddb	2025-06-01 07:01:19.684062+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	c7b9a5f6-2c6d-4304-b8a6-4624d8bca27c	\N	nice_to_catch	\N	2025-06-01 07:01:19.684062+00	\N
275d473e-af4e-49c3-a788-a1cb3c274089	2025-06-01 07:01:30.067533+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	47be4daf-5aa2-4064-9885-c142ce1f2e70	\N	depends_on_context	\N	2025-06-01 07:01:30.067533+00	\N
3295c033-cda7-427c-9588-dd29e0366f3f	2025-06-01 07:01:36.184856+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	c12473f3-6818-43ec-b547-22773a403e5e	\N	worth_the_effort	\N	2025-06-01 07:01:36.184856+00	\N
6da62dd7-2f13-4585-8d71-2d4c0aac8bff	2025-06-01 07:01:40.84492+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	3d1b7778-c1e7-441c-8b7d-a960905a60f4	\N	worth_the_effort	\N	2025-06-01 07:01:40.84492+00	\N
bbf96f9e-7875-4f74-8c70-9007f425a78f	2025-06-01 07:02:02.330203+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	312b7a85-2a3c-4c22-ab67-c6b164c34c76	\N	nice_to_catch	\N	2025-06-01 07:02:02.330203+00	\N
b2d57993-6ae3-4269-b604-66e303464b87	2025-06-01 07:02:10.66359+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	cfb93b76-9df9-4359-8757-384063e62ef2	\N	nice_to_catch	\N	2025-06-01 07:02:10.66359+00	\N
5632704d-d8d3-4c8d-a8a4-d43d78ac03ad	2025-06-01 07:02:55.197186+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	11ab2bff-caf6-4824-b632-1c3fde9886c1	\N	nice_to_catch	\N	2025-06-01 07:02:55.197186+00	\N
7565991c-8292-428e-a391-ac443daa5373	2025-06-01 07:03:24.695765+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	70ecbbb3-d239-4e8d-8d8c-f17f4d46a17f	\N	nice_to_catch	\N	2025-06-01 07:03:24.695765+00	\N
b8e46d93-c7be-4e3e-ac19-f9ae5bc6e4de	2025-06-01 07:03:34.259255+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	dcb49616-3db2-439e-8e94-c4eba88edfbd	\N	worth_the_effort	\N	2025-06-01 07:03:34.259255+00	\N
d86f809c-c125-4961-8bbc-3e000802dc8e	2025-06-01 07:04:13.21137+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	baa43c55-7964-4641-a10c-3d48b4687e61	\N	nice_to_catch	\N	2025-06-01 07:04:13.21137+00	\N
dec153b0-3b3c-4584-bb08-fd556899d1ae	2025-06-01 07:04:25.693426+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	a5df90d4-c578-4d14-a1ea-4ef52413ac1b	\N	worth_the_effort	\N	2025-06-01 07:04:25.693426+00	\N
2baf1ba4-5ccd-496b-95ac-ec77e32ec7c9	2025-06-01 07:04:29.668394+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	6d97d81b-01c0-4c37-a28f-d2067f3e9509	\N	worth_the_effort	\N	2025-06-01 07:04:29.668394+00	\N
bca18c2c-7c5b-4a5b-bad2-787f347b124d	2025-06-01 07:05:06.875938+00	9547e1f9-306e-4dd2-96fb-89fc33ce7512	d3046501-1cc4-4f36-bea6-fdcba9ceac7c	\N	nice_to_catch	\N	2025-06-01 07:05:06.875938+00	\N
d6f4a46b-3a22-4faa-9ff7-681c95fe6117	2025-06-03 05:09:13.995834+00	7f2169d3-894f-484f-bf65-8be242c8cd24	8de421d5-8326-4eb8-9841-73482086066a	\N	not_for_me	\N	2025-06-03 05:09:13.995834+00	\N
1667c8e8-7d45-4ac3-987b-0af3e83f575a	2025-06-03 06:36:56.401926+00	7f2169d3-894f-484f-bf65-8be242c8cd24	4b441a88-0f24-4023-9166-7caeee61c9db	\N	depends_on_context	\N	2025-06-03 06:36:56.401926+00	\N
b9f10002-b875-4832-8f8b-f1b3142a8313	2025-06-03 06:41:16.491717+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	b7dff97a-bf8c-466b-b6a4-8d4520be4557	\N	worth_the_effort	\N	2025-06-03 06:41:16.491717+00	\N
9f39ab44-3e2d-48fd-987a-60d9bc650b6f	2025-06-03 06:44:31.134869+00	dfa7ac70-3f2d-47e5-86e4-49bba65a68b5	b6582170-250f-4c8f-940b-f8422b2dc3a1	\N	nice_to_catch	\N	2025-06-03 06:44:39.59571+00	\N
217bda53-f855-4d84-a8b5-0c6334887487	2025-06-03 07:16:11.678393+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	b4dc2171-a97a-48c7-bc28-f720a079690f	\N	not_for_me	\N	2025-06-03 07:16:11.678393+00	\N
5986c414-3275-4c74-9c9c-661354eb2fed	2025-06-03 07:40:29.823938+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	375774d6-4803-428a-a838-104f0646a1ea	\N	not_for_me	\N	2025-06-03 07:40:29.823938+00	\N
0729531d-236d-4fb7-a346-b78fc7ec1871	2025-06-03 07:41:05.024538+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	a518e470-7921-4baf-baff-a76e14858ac8	\N	worth_the_effort	\N	2025-06-03 07:41:05.024538+00	\N
215893fd-0e82-4a24-90b1-b7ae4804b22a	2025-06-03 07:41:16.928702+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	be5ebc3b-dcd4-4f06-b02d-a3d36fd36081	\N	not_for_me	\N	2025-06-03 07:41:16.928702+00	\N
17044a2d-1316-4f61-b806-1bef93af48ee	2025-06-03 07:44:32.059779+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	e10642bc-41a4-4508-a333-2ecb6c9d3f17	\N	depends_on_context	\N	2025-06-03 07:44:32.059779+00	\N
686b2ba3-7663-48e9-8a02-af87dd11fa8d	2025-06-03 21:55:41.427555+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	1dfae29e-a0e2-48b0-b3ef-77b217e61715	\N	nice_to_catch	\N	2025-06-03 21:55:55.346369+00	\N
eac639e9-0076-44d9-a026-7833730b55e1	2025-06-03 07:50:55.954638+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	ed95cba1-893a-4d90-b88f-3b732fc775a8	\N	depends_on_context	\N	2025-06-03 07:50:55.954638+00	\N
fe7768fc-9502-4220-b5b7-0a8acc952436	2025-06-03 07:44:21.85804+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	db20f866-7a4c-4332-bf46-3fad46432c32	\N	depends_on_context	\N	2025-06-03 23:36:10.776822+00	\N
8cbaeca7-95dd-4e82-b5c3-590df78dd160	2025-06-04 00:42:13.639511+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	a8f0cdf1-0dc0-4f5d-8443-8e1802f799bc	\N	depends_on_context	\N	2025-06-04 00:42:13.639511+00	\N
494c233a-3c1a-4a1d-8ee3-a8ab645e6a16	2025-06-03 07:48:18.868193+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	c64a7496-30b4-47d8-8182-9a98a8fed3ee	\N	depends_on_context	\N	2025-06-03 07:51:11.284951+00	\N
55d21b7e-5a85-498e-818a-16ce267e3413	2025-06-03 07:55:06.401798+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	b49b8a41-618d-4f17-a07a-bca2538439f3	\N	depends_on_context	\N	2025-06-03 07:55:06.401798+00	\N
9957cd8b-9e2f-4655-a7e9-3978be68c355	2025-06-03 07:48:24.278218+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2738faf7-37f0-4185-949a-89cfd3886c0a	\N	depends_on_context	\N	2025-06-03 07:58:15.392088+00	\N
6a7064ac-e724-405d-8b81-05a115db63ea	2025-06-03 07:44:25.844878+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	87c114d4-b366-4ed0-a238-6d6c06df12a8	\N	nice_to_catch	\N	2025-06-03 08:30:28.480688+00	\N
8ae6f66f-a1da-4ccb-93f4-3d252d7c0cb6	2025-06-03 08:30:52.239821+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	c13a2416-037d-4923-97f7-fd7642373ec8	\N	depends_on_context	\N	2025-06-03 08:30:52.239821+00	\N
5a33fa21-50eb-44ba-b07a-62e0b7e0c452	2025-06-03 08:35:49.370523+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	\N	\N	nice_to_catch	\N	2025-06-03 08:35:54.1002+00	9008c542-036b-42b9-b503-8820f01b5935
304eaedc-0e3a-4bd5-af0a-62207f536889	2025-06-03 21:43:17.878759+00	eda854e4-0358-4ae6-b5e2-8bb490e5782a	10889bf3-e3b6-483c-8db1-d3c56b2116a1	\N	depends_on_context	\N	2025-06-03 21:54:46.257214+00	\N
\.


--
-- Data for Name: artists; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.artists (id, created_at, name, created_by, updated_at) FROM stdin;
da902580-dbf1-4b9d-87cd-309e6648eb1c	2025-05-24 16:35:45.699806+00	$UICIDEBOY$	\N	2025-05-29 13:24:10.622809+00
c225abe4-6747-44a4-b89b-98389549d504	2025-05-24 16:35:45.699806+00	100 GECS	\N	2025-05-29 13:24:10.622809+00
e70b0cc4-446f-4e46-8236-0a5f5cb934c1	2025-05-24 16:35:45.699806+00	12TH PLANET	\N	2025-05-29 13:24:10.622809+00
6a5bcac3-7cfd-438c-9327-25673127acef	2025-05-24 16:35:45.699806+00	1788-L	\N	2025-05-29 13:24:10.622809+00
1441b842-428f-4f72-aa0c-394f3c565028	2025-05-24 16:35:45.699806+00	21 SAVAGE	\N	2025-05-29 13:24:10.622809+00
91237f1b-de52-4e4e-a1c4-0a258df82bb4	2025-05-24 16:35:45.699806+00	2CRI$PY	\N	2025-05-29 13:24:10.622809+00
a15aa35b-fb50-493b-8acd-a7df2ecb855a	2025-05-24 16:35:45.699806+00	3 BLOKES	\N	2025-05-29 13:24:10.622809+00
a6d6f888-5b4e-456b-8f66-4e5b814942ee	2025-05-24 16:35:45.699806+00	3LAU	\N	2025-05-29 13:24:10.622809+00
b0201b37-2235-4f7d-8003-1a997ce45ec7	2025-05-24 16:35:45.699806+00	A HUNDRED DRUMS	\N	2025-05-29 13:24:10.622809+00
9d50e77d-b0fc-4255-b637-83f4a50e47a4	2025-05-24 16:35:45.699806+00	A SKILLZ	\N	2025-05-29 13:24:10.622809+00
651a43f7-31d1-477a-8b38-1362f7944d73	2025-05-24 16:35:45.699806+00	A-TRAK	\N	2025-05-29 13:24:10.622809+00
4a98a28b-4306-4761-b02a-7a82962443eb	2025-05-24 16:35:45.699806+00	A.M.C.	\N	2025-05-29 13:24:10.622809+00
df8f9260-9a19-435f-a309-c2ef93f58337	2025-05-24 16:35:45.699806+00	AARON KAMM AND THE ONE DROPS	\N	2025-05-29 13:24:10.622809+00
e55d78f1-9783-40ea-a802-4fcd58024a44	2025-05-24 16:35:45.699806+00	ABELATION	\N	2025-05-29 13:24:10.622809+00
00bb3ab7-03ae-451d-9c37-44ad2f8e892d	2025-05-24 16:35:45.699806+00	ABOVE & BEYOND	\N	2025-05-29 13:24:10.622809+00
0abcd924-b5fa-4da6-ac81-8d09c7fa74ad	2025-05-24 16:35:45.699806+00	ABRAXIS	\N	2025-05-29 13:24:10.622809+00
55c4e3e3-1c32-40ea-b580-bcca97270738	2025-05-24 16:35:45.699806+00	AC SLATER	\N	2025-05-29 13:24:10.622809+00
53922d8c-edc2-4998-8606-06ae3b3ed240	2025-05-24 16:35:45.699806+00	ACE AURA	\N	2025-05-29 13:24:10.622809+00
db20f866-7a4c-4332-bf46-3fad46432c32	2025-05-24 16:35:45.699806+00	ACRAZE	\N	2025-05-29 13:24:10.622809+00
81508419-3dcd-4892-ad9d-69b5374068d0	2025-05-24 16:35:45.699806+00	ADAM BEYER	\N	2025-05-29 13:24:10.622809+00
75d37cb7-a713-4912-942d-ab8f8cac2f48	2025-05-24 16:35:45.699806+00	ADAM MELCHOR	\N	2025-05-29 13:24:10.622809+00
ac384e87-d5cc-42f0-ad61-25b7c6a20b79	2025-05-24 16:35:45.699806+00	ADRENALIZE	\N	2025-05-29 13:24:10.622809+00
d2e63248-deae-4c80-ae65-46ac06f15e24	2025-05-24 16:35:45.699806+00	ADVENTURE CLUB	\N	2025-05-29 13:24:10.622809+00
feace927-62d7-4aff-9628-ae72bbb3d35b	2025-05-24 16:35:45.699806+00	AFROJACK	\N	2025-05-29 13:24:10.622809+00
45d6f9c1-b8f8-4e92-bb30-65bd972c4076	2025-05-24 16:35:45.699806+00	AGENT O	\N	2025-05-29 13:24:10.622809+00
87c114d4-b366-4ed0-a238-6d6c06df12a8	2025-05-24 16:35:45.699806+00	AHEE	\N	2025-05-29 13:24:10.622809+00
201159a2-9103-438a-aed4-f52efd8a0155	2025-05-24 16:35:45.699806+00	AIR2EARTH	\N	2025-05-29 13:24:10.622809+00
c1513dea-b728-40e1-9f01-bbe58c974059	2025-05-24 16:35:45.699806+00	AL.YA TOFFLER	\N	2025-05-29 13:24:10.622809+00
d1b98ce5-130b-4dbf-9293-99a9e33c3faa	2025-05-24 16:35:45.699806+00	ALAN WALKER	\N	2025-05-29 13:24:10.622809+00
5b44041f-dcff-4220-adfb-cb513b445543	2025-05-24 16:35:45.699806+00	ALBER-K	\N	2025-05-29 13:24:10.622809+00
c46e4f3f-7627-4a32-abce-1ba7b064056d	2025-05-24 16:35:45.699806+00	ALECTRIC	\N	2025-05-29 13:24:10.622809+00
7849d3dc-8269-47f3-94b4-e649f45b51d4	2025-05-24 16:35:45.699806+00	ALESSO	\N	2025-05-29 13:24:10.622809+00
8c704a79-ca27-452a-a931-7b48913b0fd1	2025-05-24 16:35:45.699806+00	ALEXANDER PANOS	\N	2025-05-29 13:24:10.622809+00
b8176e84-6b82-4900-acaa-cfa208de6468	2025-05-24 16:35:45.699806+00	ALICE IVY	\N	2025-05-29 13:24:10.622809+00
177a5b95-e372-4ef8-8bfe-270a60352b9c	2025-05-24 16:35:45.699806+00	ALISON KRAUSS	\N	2025-05-29 13:24:10.622809+00
b365b541-7d21-433d-b92d-2fea6a06818c	2025-05-24 16:35:45.699806+00	ALIX PEREZ	\N	2025-05-29 13:24:10.622809+00
4b87f60d-9dfb-41a3-9c14-121174b26672	2025-05-24 16:35:45.699806+00	ALL THEM WITCHES	\N	2025-05-29 13:24:10.622809+00
ca558feb-ad2a-4fc6-9f6a-a3ae28dde382	2025-05-24 16:35:45.699806+00	ALL TIME LOW	\N	2025-05-29 13:24:10.622809+00
6a1bc7f2-1c0d-4a0c-b3a9-5cc8a58a9e9b	2025-05-24 16:35:45.699806+00	ALOK	\N	2025-05-29 13:24:10.622809+00
b7d4d8bb-da8e-438f-b781-9d37fd74e4b4	2025-05-24 16:35:45.699806+00	ALPHA 9	\N	2025-05-29 13:24:10.622809+00
d7f55b98-c502-4e59-ac25-705af600d8a7	2025-05-24 16:35:45.699806+00	ALRT	\N	2025-05-29 13:24:10.622809+00
0a8f7c7a-f585-46c6-88b1-e66a1783f17f	2025-05-24 16:35:45.699806+00	ALY & FILA	\N	2025-05-29 13:24:10.622809+00
d46e5fe4-d4f7-4a70-8d9c-f3aa478a926f	2025-05-24 16:35:45.699806+00	ALYX ANDER	\N	2025-05-29 13:24:10.622809+00
31e77e5e-d705-4618-bbe9-da9f87d07f04	2025-05-24 16:35:45.699806+00	AMERICAN GRIME	\N	2025-05-29 13:24:10.622809+00
8a9874dd-8991-4067-a155-48677c1c5a2e	2025-05-24 16:35:45.699806+00	AMON TOBIN	\N	2025-05-29 13:24:10.622809+00
f31f8507-5d9e-4518-bb9f-a82b689a3c33	2025-05-24 16:35:45.699806+00	AMTRAC	\N	2025-05-29 13:24:10.622809+00
05d2c5fc-23ba-4376-8983-c4d18af1c4dc	2025-05-24 16:35:45.699806+00	AN-TEN-NAE	\N	2025-05-29 13:24:10.622809+00
738baafe-da03-41dd-95dc-b66fb8e2f4f3	2025-05-24 16:35:45.699806+00	ANAKIM	\N	2025-05-29 13:24:10.622809+00
396f410e-7ba1-4eaa-b69b-e790789b9d5b	2025-05-24 16:35:45.699806+00	ANAMANAGUCHI	\N	2025-05-29 13:24:10.622809+00
3cf6a6e2-c2c2-4e12-b08b-8c696dfb293c	2025-05-24 16:35:45.699806+00	ANDREA OLIVA	\N	2025-05-29 13:24:10.622809+00
7fe3a3f6-4114-4640-879f-6a7f2d1f3662	2025-05-24 16:35:45.699806+00	ANDREW BAYER	\N	2025-05-29 13:24:10.622809+00
71ed647a-3aba-4178-bda5-e47766341ddc	2025-05-24 16:35:45.699806+00	ANDREW RAYEL	\N	2025-05-29 13:24:10.622809+00
c64a7496-30b4-47d8-8182-9a98a8fed3ee	2025-05-24 16:35:45.699806+00	ANDY C	\N	2025-05-29 13:24:10.622809+00
6cd1105c-bb4e-4a3b-acd7-e7d35c01b216	2025-05-24 16:35:45.699806+00	ANDY COE BAND	\N	2025-05-29 13:24:10.622809+00
96526682-9433-4682-80b6-6474287343d2	2025-05-24 16:35:45.699806+00	ANDY FRASCO AND THE U.N.	\N	2025-05-29 13:24:10.622809+00
134babd2-b2c6-4fea-92bf-0ff3d6f5801f	2025-05-24 16:35:45.699806+00	ANFISA	\N	2025-05-29 13:24:10.622809+00
98f07399-f73c-49a5-9c82-f733af61e5d5	2025-05-24 16:35:45.699806+00	ANGELIC ROOT	\N	2025-05-29 13:24:10.622809+00
9da514ce-af81-401a-9313-f76bc599da4b	2025-05-24 16:35:45.699806+00	ANKOU	\N	2025-05-29 13:24:10.622809+00
016b2c63-437d-4f8b-8f45-54e35c539d2c	2025-05-24 16:35:45.699806+00	ANN CLUE	\N	2025-05-29 13:24:10.622809+00
a4f6dc8b-481a-4309-ad3d-a378e2657820	2025-05-24 16:35:45.699806+00	ANOMALIE	\N	2025-05-29 13:24:10.622809+00
8463ab8b-ecf0-4f1f-b4b4-596caa5289ef	2025-05-24 16:35:45.699806+00	ANTENNAE	\N	2025-05-29 13:24:10.622809+00
22426d89-3cc7-4067-87ee-fd3f70f75874	2025-05-24 16:35:45.699806+00	ANTHILL CINEMA	\N	2025-05-29 13:24:10.622809+00
925ea8da-12d9-4554-8968-9505e4c09104	2025-05-24 16:35:45.699806+00	APASHAE	\N	2025-05-29 13:24:10.622809+00
e589c5d5-d615-4014-a4ea-b81c4f165ee1	2025-05-24 16:35:45.699806+00	APASHE	\N	2025-05-29 13:24:10.622809+00
8f1f4a3f-5c9a-40ea-9425-c20074cc7c64	2025-05-24 16:35:45.699806+00	APO10	\N	2025-05-29 13:24:10.622809+00
bca60ed5-3282-422a-9e8e-183b1d54f77d	2025-05-24 16:35:45.699806+00	AQUEOUS	\N	2025-05-29 13:24:10.622809+00
e577a8a6-cedf-4ddc-a476-480d9afd9686	2025-05-24 16:35:45.699806+00	ARLO PARKS	\N	2025-05-29 13:24:10.622809+00
c29cf9ee-cb4e-40af-bb0f-81c873b16166	2025-05-24 16:35:45.699806+00	ARMIN VAN BUUREN	\N	2025-05-29 13:24:10.622809+00
e10642bc-41a4-4508-a333-2ecb6c9d3f17	2025-05-24 16:35:45.699806+00	ARMNHMR	\N	2025-05-29 13:24:10.622809+00
b242e50d-dd6d-4a77-94c0-cc89830d77c5	2025-05-24 16:35:45.699806+00	ARTBAT	\N	2025-05-29 13:24:10.622809+00
295c2f5e-a9b7-4457-b4ad-3c6e1ffb369c	2025-05-24 16:35:45.699806+00	ASHE	\N	2025-05-29 13:24:10.622809+00
92597c16-0d40-40ab-877c-8f39815af088	2025-05-24 16:35:45.699806+00	ASTRIX	\N	2025-05-29 13:24:10.622809+00
e90cd21c-6483-487e-b1c8-f2fd3e834657	2025-05-24 16:35:45.699806+00	ASTRO	\N	2025-05-29 13:24:10.622809+00
65bf9d23-9637-4209-9d3e-79b633f84169	2025-05-24 16:35:45.699806+00	ATB	\N	2025-05-29 13:24:10.622809+00
9880c680-f43c-47e4-b834-15cef0da1e60	2025-05-24 16:35:45.699806+00	ATDUSK	\N	2025-05-29 13:24:10.622809+00
2738faf7-37f0-4185-949a-89cfd3886c0a	2025-05-24 16:35:45.699806+00	ATLIENS	\N	2025-05-29 13:24:10.622809+00
f51e1fa4-9790-4501-8168-0da9172cbbff	2025-05-24 16:35:45.699806+00	ATTLAS	\N	2025-05-29 13:24:10.622809+00
dd5e4519-e810-4037-8250-a04e0185abde	2025-05-24 16:35:45.699806+00	ATYYA	\N	2025-05-29 13:24:10.622809+00
a7a34136-7787-4771-b164-ee91be29698e	2025-05-24 16:35:45.699806+00	AU5	\N	2025-05-29 13:24:10.622809+00
0c4ece48-c2b9-49da-b3da-c0197a08784c	2025-05-24 16:35:45.699806+00	AU5 X CHIME	\N	2025-05-29 13:24:10.622809+00
3cf5adc9-0bcd-42c2-b278-b569e5d7e725	2025-05-24 16:35:45.699806+00	AUDIEN	\N	2025-05-29 13:24:10.622809+00
10889bf3-e3b6-483c-8db1-d3c56b2116a1	2025-05-24 16:35:45.699806+00	AUDIOFREQ	\N	2025-05-29 13:24:10.622809+00
6ebf5841-4370-409b-8fa2-a5d9b211cc74	2025-05-24 16:35:45.699806+00	AUSTIN MILLZ	\N	2025-05-29 13:24:10.622809+00
3d8f229b-be0e-48bc-b871-c7e4d9b36e24	2025-05-24 16:35:45.699806+00	AUTOGRAF	\N	2025-05-29 13:24:10.622809+00
3fca0eec-fa2c-4b77-b307-f671bcb3a360	2025-05-24 16:35:45.699806+00	AVERAGE CITIZENS	\N	2025-05-29 13:24:10.622809+00
c6cbc2c2-029e-4081-8c56-926a3108e955	2025-05-24 16:35:45.699806+00	AVISION	\N	2025-05-29 13:24:10.622809+00
b11ad569-2383-44d5-9ddf-f424d46643ab	2025-05-24 16:35:45.699806+00	AWEMINUS	\N	2025-05-29 13:24:10.622809+00
6a6497b9-5453-4546-ad6b-4e743ea7e3c8	2025-05-24 16:35:45.699806+00	AWOOD	\N	2025-05-29 13:24:10.622809+00
12198f94-21a2-4b0c-89b5-c10b70605928	2025-05-24 16:35:45.699806+00	AZZELA	\N	2025-05-29 13:24:10.622809+00
806f0ca8-afc6-4660-8bd7-1922178cbceb	2025-05-24 16:35:45.699806+00	B. TRAITS	\N	2025-05-29 13:24:10.622809+00
6b2a3555-9874-4fef-bc96-092b7bc95670	2025-05-24 16:35:45.699806+00	BACKPACT	\N	2025-05-29 13:24:10.622809+00
25b13644-2cdc-4902-9ab6-7f190f94bfd4	2025-05-24 16:35:45.699806+00	BADMAN	\N	2025-05-29 13:24:10.622809+00
2b226699-3e00-40de-a619-cb197a3b5123	2025-05-24 16:35:45.699806+00	BAKERMAT	\N	2025-05-29 13:24:10.622809+00
b6343879-e110-4080-ba03-ffa991132620	2025-05-24 16:35:45.699806+00	BALKAN BUMP	\N	2025-05-29 13:24:10.622809+00
419ab7b0-624f-4d9c-8b0f-bc8402121f3b	2025-05-24 16:35:45.699806+00	BANKAJI	\N	2025-05-29 13:24:10.622809+00
0d8c726c-bb11-4234-81b4-70b541f9d96d	2025-05-24 16:35:45.699806+00	BANSHEE TREE	\N	2025-05-29 13:24:10.622809+00
cbe86f61-e078-4e41-a080-e3cb34655b1a	2025-05-24 16:35:45.699806+00	BARCLAY CRENSHAW	\N	2025-05-29 13:24:10.622809+00
ed95cba1-893a-4d90-b88f-3b732fc775a8	2025-05-24 16:35:45.699806+00	BARELY ALIVE	\N	2025-05-29 13:24:10.622809+00
3c22025c-f701-4b68-a1c6-e2dfc40ee85d	2025-05-24 16:35:45.699806+00	BARILAN	\N	2025-05-29 13:24:10.622809+00
fbcbcfb0-7e43-4f09-89d8-08d356ada729	2025-05-24 16:35:45.699806+00	BARISONE	\N	2025-05-29 13:24:10.622809+00
5d595784-3911-41e0-9d04-7633253b4e3e	2025-05-24 16:35:45.699806+00	BARNACLE BOI	\N	2025-05-29 13:24:10.622809+00
0c538152-a67f-4f72-b0a1-d659103cce31	2025-05-24 16:35:45.699806+00	BAS	\N	2025-05-29 13:24:10.622809+00
db854d3f-3602-4d80-9a22-e9e3cf170cd5	2025-05-24 16:35:45.699806+00	BASE2	\N	2025-05-29 13:24:10.622809+00
2ed248eb-0958-4598-bd76-5cbb00a05c59	2025-05-24 16:35:45.699806+00	BASSNECTAR	\N	2025-05-29 13:24:10.622809+00
66229fd4-ee57-4acd-bb39-c0ac85d5c64d	2025-05-24 16:35:45.699806+00	BASSRUSH EXPERIENCE	\N	2025-05-29 13:24:10.622809+00
ec2f3aed-a6ec-46b7-ac0c-2e1a17672f4d	2025-05-24 16:35:45.699806+00	BAWLDY	\N	2025-05-29 13:24:10.622809+00
6b7bdd1e-1071-42a2-bf93-c2d84a30a6f5	2025-05-24 16:35:45.699806+00	BÀWLDY	\N	2025-05-29 13:24:10.622809+00
04550e52-3444-4059-81ef-413604d357b2	2025-05-24 16:35:45.699806+00	BAYNK	\N	2025-05-29 13:24:10.622809+00
ec57922e-cd59-46ac-afb0-91df23422ac4	2025-05-24 16:35:45.699806+00	BEA MILLER	\N	2025-05-29 13:24:10.622809+00
f4092bf8-0980-40c0-b033-457a47dccea8	2025-05-24 16:35:45.699806+00	BEAK NASTY	\N	2025-05-29 13:24:10.622809+00
596ccf5b-67ba-4276-a0c3-12560a682bf5	2025-05-24 16:35:45.699806+00	BEARDTHUG	\N	2025-05-29 13:24:10.622809+00
76dddbac-7400-4ab5-9943-7e0979fcc009	2025-05-24 16:35:45.699806+00	BEAT KITTY	\N	2025-05-29 13:24:10.622809+00
57a495c3-0e91-41ab-8044-9eeb863fd89a	2025-05-24 16:35:45.699806+00	BEN BOHMER	\N	2025-05-29 13:24:10.622809+00
51ca0ca4-4028-4119-8317-ddccc9d8e420	2025-05-24 16:35:45.699806+00	BEN BÖHMER	\N	2025-05-29 13:24:10.622809+00
1674b38c-d717-4d02-a600-d60ff13c2d4b	2025-05-24 16:35:45.699806+00	BEN NICKY	\N	2025-05-29 13:24:10.622809+00
b49b8a41-618d-4f17-a07a-bca2538439f3	2025-05-24 16:35:45.699806+00	BENDA	\N	2025-05-29 13:24:10.622809+00
30741fe7-3bec-4575-b877-3f3158586f20	2025-05-24 16:35:45.699806+00	BENEE	\N	2025-05-29 13:24:10.622809+00
86005f19-714f-4e4b-b432-a5c81af2e163	2025-05-24 16:35:45.699806+00	BENGA	\N	2025-05-29 13:24:10.622809+00
de525250-4269-48ad-85f7-4cea687e6f73	2025-05-24 16:35:45.699806+00	BENJI ROBOT	\N	2025-05-29 13:24:10.622809+00
50748049-162e-4950-9a78-7e880b9df205	2025-05-24 16:35:45.699806+00	BENSLEY	\N	2025-05-29 13:24:10.622809+00
74a4861c-0899-4817-927a-41f9c413f04f	2025-05-24 16:35:45.699806+00	BENTLEY DEAN	\N	2025-05-29 13:24:10.622809+00
7b445433-abc0-4b95-9ea1-8e509a11cafd	2025-05-24 16:35:45.699806+00	BEXXIE	\N	2025-05-29 13:24:10.622809+00
d98c013b-cc10-4f8f-b4b9-64b05858a73b	2025-05-24 16:35:45.699806+00	BIG FREEDIA	\N	2025-05-29 13:24:10.622809+00
251010cf-e3e4-464b-b9bb-a5d004a87436	2025-05-24 16:35:45.699806+00	BIG GIGANTIC	\N	2025-05-29 13:24:10.622809+00
7b3eded1-fdf6-4d7e-adc1-61a604d7ec69	2025-05-24 16:35:45.699806+00	BIG JOE DADDY	\N	2025-05-29 13:24:10.622809+00
76b93696-17d7-4608-824b-1ef5debd80fd	2025-05-24 16:35:45.699806+00	BIG SOMETHING	\N	2025-05-29 13:24:10.622809+00
7b09a31a-4bb9-4ded-9084-1aebd0323b38	2025-05-24 16:35:45.699806+00	BIG WILD	\N	2025-05-29 13:24:10.622809+00
920f48f8-fab5-495c-8e4a-2fd233ff6835	2025-05-24 16:35:45.699806+00	BIICLA	\N	2025-05-29 13:24:10.622809+00
c13a2416-037d-4923-97f7-fd7642373ec8	2025-05-24 16:35:45.699806+00	BIJOU	\N	2025-05-29 13:24:10.622809+00
e006cf46-387a-4282-8926-bbb3bd33872a	2025-05-24 16:35:45.699806+00	BILLY STRINGS	\N	2025-05-29 13:24:10.622809+00
f748899c-4523-4d7e-bd5b-526e5a2fbb1f	2025-05-24 16:35:45.699806+00	BIOLUMIGEN	\N	2025-05-29 13:24:10.622809+00
41664747-f3cb-4e42-843e-2cc25b07e538	2025-05-24 16:35:45.699806+00	BIOMASSIVE	\N	2025-05-29 13:24:10.622809+00
04f8ae3f-7c5d-4f29-89e7-ed57ee9b24b2	2025-05-24 16:35:45.699806+00	BISCITS	\N	2025-05-29 13:24:10.622809+00
0453719d-1c52-424c-ad0a-e7b0507d7fcf	2025-05-24 16:35:45.699806+00	BLACK CARL	\N	2025-05-29 13:24:10.622809+00
06c6326a-65f9-4ee2-a67a-77da47528d7f	2025-05-24 16:35:45.699806+00	BLACK CARL B2B SAKA	\N	2025-05-29 13:24:10.622809+00
baab00e4-ed68-4a5b-8d28-befffa8f4115	2025-05-24 16:35:45.699806+00	BLACK CARL!	\N	2025-05-29 13:24:10.622809+00
7c9f972d-27d7-4529-9e98-a50c184583c9	2025-05-24 16:35:45.699806+00	BLACK COFFEE	\N	2025-05-29 13:24:10.622809+00
63ced827-a3ba-462e-9a80-a1cc654fc882	2025-05-24 16:35:45.699806+00	BLACK GUMMY	\N	2025-05-29 13:24:10.622809+00
55099f84-8d5d-44a3-b688-52223afbf9dd	2025-05-24 16:35:45.699806+00	BLACK SUN EMPIRE	\N	2025-05-29 13:24:10.622809+00
529e0560-6c77-4f9a-ba42-d33a2a5be212	2025-05-24 16:35:45.699806+00	BLACK TIGER SEX MACHINE	\N	2025-05-29 13:24:10.622809+00
0ec7dfa5-c12b-4f13-8450-13e17f8b834a	2025-05-24 16:35:45.699806+00	BLACK V NECK	\N	2025-05-29 13:24:10.622809+00
840c74c8-2375-4f22-81b4-217a4ed96755	2025-05-24 16:35:45.699806+00	BLACKGUMMY	\N	2025-05-29 13:24:10.622809+00
ed5a12b3-70ce-4647-9592-3e21248986fb	2025-05-24 16:35:45.699806+00	BLANKE	\N	2025-05-29 13:24:10.622809+00
756e6b5d-4e9f-4585-b020-b9ef2d789fb0	2025-05-24 16:35:45.699806+00	BLEACHERS	\N	2025-05-29 13:24:10.622809+00
194ddbfb-4cae-463c-98b8-326193cff38a	2025-05-24 16:35:45.699806+00	BLEEP BLOOP	\N	2025-05-29 13:24:10.622809+00
99fa2da7-39c7-45a1-a626-5acb745c2763	2025-05-24 16:35:45.699806+00	BLOCKHEAD	\N	2025-05-29 13:24:10.622809+00
4c2ab9c5-8f89-4bdc-bbf3-74adb6704661	2025-05-24 16:35:45.699806+00	BLOODCREST	\N	2025-05-29 13:24:10.622809+00
1dfae29e-a0e2-48b0-b3ef-77b217e61715	2025-05-24 16:35:45.699806+00	BLOSSOM	\N	2025-05-29 13:24:10.622809+00
42c80090-481e-43bf-ad8e-43bf3fb38d25	2025-05-24 16:35:45.699806+00	BLU DETIGER	\N	2025-05-29 13:24:10.622809+00
97be217c-c8f5-433c-830f-94ca3bd61d66	2025-05-24 16:35:45.699806+00	BLUE DETIGER	\N	2025-05-29 13:24:10.622809+00
31a2d68c-a133-4d15-83e5-9db45f0dfce1	2025-05-24 16:35:45.699806+00	BLUNTS & BLONDES	\N	2025-05-29 13:24:10.622809+00
b976681d-a6c0-4c28-8986-8fd6c5be89ce	2025-05-24 16:35:45.699806+00	BLVK JVCK	\N	2025-05-29 13:24:10.622809+00
2acb0605-5c30-4554-beb3-039154c5cf7a	2025-05-24 16:35:45.699806+00	BOBI STEVKOVSKI	\N	2025-05-29 13:24:10.622809+00
605a4b0d-e549-4d76-956b-1573ea7511a7	2025-05-24 16:35:45.699806+00	BOGTROTTER	\N	2025-05-29 13:24:10.622809+00
a8f0cdf1-0dc0-4f5d-8443-8e1802f799bc	2025-05-24 16:35:45.699806+00	BOMMER	\N	2025-05-29 13:24:10.622809+00
e4d7c2de-5937-4048-98dd-cbe9043983e3	2025-05-24 16:35:45.699806+00	BONE THUGS-N-HARMONY	\N	2025-05-29 13:24:10.622809+00
e2d0d5ee-d53b-4d61-9230-7c0f21a7843b	2025-05-24 16:35:45.699806+00	BONNIE X CLYDE	\N	2025-05-29 13:24:10.622809+00
50e787c4-18d3-4267-9cd7-5ccf084a98fe	2025-05-24 16:35:45.699806+00	BONOBO	\N	2025-05-29 13:24:10.622809+00
0c49e938-5b5f-4fb9-9609-9239f57bd862	2025-05-24 16:35:45.699806+00	BONTAN	\N	2025-05-29 13:24:10.622809+00
8281ab74-b358-435a-8d67-2626847be7de	2025-05-24 16:35:45.699806+00	BOOGIE T	\N	2025-05-29 13:24:10.622809+00
90f4155b-aad4-46a9-b762-cd230f4d9e61	2025-05-24 16:35:45.699806+00	BOOTY BOO B2B VLAD THE INHALER	\N	2025-05-29 13:24:10.622809+00
dc61f9e0-f5b7-4c53-bae3-8080c5ede9c8	2025-05-24 16:35:45.699806+00	BORA UZER	\N	2025-05-29 13:24:10.622809+00
d6063130-752c-48ff-8bc5-890863b51f23	2025-05-24 16:35:45.699806+00	BORGORE	\N	2025-05-29 13:24:10.622809+00
0c531e36-db32-459e-afda-345ee6a2c242	2025-05-24 16:35:45.699806+00	BORGORE B2B RIOT TEN	\N	2025-05-29 13:24:10.622809+00
4665e6c6-a03d-40ea-aa67-591d354f6922	2025-05-24 16:35:45.699806+00	BORIS BREJCHA	\N	2025-05-29 13:24:10.622809+00
94a91a1f-59e0-4098-8b5a-7ec19094c62f	2025-05-24 16:35:45.699806+00	BRAD GOLDMAN	\N	2025-05-29 13:24:10.622809+00
5c6d4642-f403-45c9-a28c-393ed669b137	2025-05-24 16:35:45.699806+00	BRAINCHILD	\N	2025-05-29 13:24:10.622809+00
b3fd997f-8154-47d6-9e7d-4315409a6001	2025-05-24 16:35:45.699806+00	BRANDON “TAZ” NIEDERAUER	\N	2025-05-29 13:24:10.622809+00
6ce6c88e-614d-45f6-9a67-73c13935fab2	2025-05-24 16:35:45.699806+00	BRASS AGAINST	\N	2025-05-29 13:24:10.622809+00
20fceb69-c6ba-4884-9be1-e78cdc23be3c	2025-05-24 16:35:45.699806+00	BREAD WINNER	\N	2025-05-29 13:24:10.622809+00
f23feffb-170c-44a2-b323-101697c8c457	2025-05-24 16:35:45.699806+00	BREAK SCIENCE	\N	2025-05-29 13:24:10.622809+00
85cdeb80-d5e0-44fd-a494-6014d63cbef0	2025-05-24 16:35:45.699806+00	BREAKA	\N	2025-05-29 13:24:10.622809+00
52472979-5724-4af4-81d2-b505f7817db4	2025-05-24 16:35:45.699806+00	BRENNAN HEART	\N	2025-05-29 13:24:10.622809+00
e273d8da-d30b-475e-a4c1-f151255bb7ee	2025-05-24 16:35:45.699806+00	BRICKSQUASH	\N	2025-05-29 13:24:10.622809+00
2f0b15d9-4cbf-49e3-be31-66dc98fcba17	2025-05-24 16:35:45.699806+00	BRIJEAN	\N	2025-05-29 13:24:10.622809+00
9d9aba8f-9678-4b87-b31b-ec7937b72598	2025-05-24 16:35:45.699806+00	BRISTON MARONEY	\N	2025-05-29 13:24:10.622809+00
215e96b7-319f-4639-b421-52ed7d90b113	2025-05-24 16:35:45.699806+00	BROMOSAPIEN	\N	2025-05-29 13:24:10.622809+00
0d253ebe-6120-431c-9654-acb9b41480b0	2025-05-24 16:35:45.699806+00	BRONDO	\N	2025-05-29 13:24:10.622809+00
922abd1c-dcca-4d5f-b2d9-be314cbb575e	2025-05-24 16:35:45.699806+00	BRONDO B2B LICK	\N	2025-05-29 13:24:10.622809+00
88691775-1de0-40ad-b878-d5706bf2e8e0	2025-05-24 16:35:45.699806+00	BROTHER BEAR	\N	2025-05-29 13:24:10.622809+00
a299f8a6-b679-4455-8049-d6924b4967c6	2025-05-24 16:35:45.699806+00	BRUNO FURLAN	\N	2025-05-29 13:24:10.622809+00
9315a32e-dd86-4a5c-8bf5-fc5ab1d20ed4	2025-05-24 16:35:45.699806+00	BRUNO MARTINI	\N	2025-05-29 13:24:10.622809+00
3bdb5824-8287-48d9-8034-47767fb69c84	2025-05-24 16:35:45.699806+00	BRYCE MENCHACA	\N	2025-05-29 13:24:10.622809+00
39e4c0e7-750f-46e8-9882-1c41eb438cb3	2025-05-24 16:35:45.699806+00	BUKKHA	\N	2025-05-29 13:24:10.622809+00
20819972-5859-4db6-a4bb-dba1d0f4debe	2025-05-24 16:35:45.699806+00	BUKU	\N	2025-05-29 13:24:10.622809+00
7104d0d6-4217-4d78-a0e9-bf165ad208da	2025-05-24 16:35:45.699806+00	BUTTA’	\N	2025-05-29 13:24:10.622809+00
1e0cfaae-340c-4c2e-8740-65903d7eaf04	2025-05-24 16:35:45.699806+00	BUXAPLENTY	\N	2025-05-29 13:24:10.622809+00
ed3c8b75-0869-4cda-a471-1cf9ccae4f77	2025-05-24 16:35:45.699806+00	BVNISHED	\N	2025-05-29 13:24:10.622809+00
ea8fa0e5-508f-48a1-8f7f-e1a92ba7eada	2025-05-24 16:35:45.699806+00	CALCIUM	\N	2025-05-29 13:24:10.622809+00
1fd5e9eb-d7f6-49b9-86ee-74830a81454b	2025-05-24 16:35:45.699806+00	CALCIUM B2B KOMPANY	\N	2025-05-29 13:24:10.622809+00
9025137a-58e5-49e6-a0cb-e0471dfbb516	2025-05-24 16:35:45.699806+00	CALDER ALLEN	\N	2025-05-29 13:24:10.622809+00
c41c02f3-1fb8-4548-8eea-1a1eb7f09e6e	2025-05-24 16:35:45.699806+00	CALEB JOHNSON	\N	2025-05-29 13:24:10.622809+00
623cbf06-094d-4353-9348-35ae977fcca6	2025-05-24 16:35:45.699806+00	CALEESI & SARAH KREIS	\N	2025-05-29 13:24:10.622809+00
b46a8ab4-b969-4b8d-a423-0b8259f848d0	2025-05-24 16:35:45.699806+00	CALYX & TEEBEE	\N	2025-05-29 13:24:10.622809+00
e341edc6-9357-4aff-bb06-c7b3628f4982	2025-05-24 16:35:45.699806+00	CAMELPHAT	\N	2025-05-29 13:24:10.622809+00
bda40a00-6f80-4934-8687-2e2946e207c9	2025-05-24 16:35:45.699806+00	CANABLISS	\N	2025-05-29 13:24:10.622809+00
070c9c88-7d08-4a70-a6c6-200af1f0cf47	2025-05-24 16:35:45.699806+00	CANNONS	\N	2025-05-29 13:24:10.622809+00
c27800a6-3567-44aa-845d-823a669c056c	2025-05-24 16:35:45.699806+00	CANVAS	\N	2025-05-29 13:24:10.622809+00
a97a94ce-c3a7-4f99-9307-777315015365	2025-05-24 16:35:45.699806+00	CAPOZZI	\N	2025-05-29 13:24:10.622809+00
b2df1b0c-d412-47e0-9d8c-a0f3545446bf	2025-05-24 16:35:45.699806+00	CARL COX	\N	2025-05-29 13:24:10.622809+00
ac65a05f-75c1-44c2-8fa1-050cf1a382e1	2025-05-24 16:35:45.699806+00	CARLITA	\N	2025-05-29 13:24:10.622809+00
86157538-6606-488d-a707-d505cb3a1464	2025-05-24 16:35:45.699806+00	CARNAGE	\N	2025-05-29 13:24:10.622809+00
c45aed64-9a58-4c16-bb00-9e3bc4959807	2025-05-24 16:35:45.699806+00	CASE OF THE MONDAYS	\N	2025-05-29 13:24:10.622809+00
a0fc15f1-8e79-41e8-b19f-c2ad8fd9f6e8	2025-05-24 16:35:45.699806+00	CASMALIA	\N	2025-05-29 13:24:10.622809+00
07095aca-1693-4179-a7e9-866f59a4e2df	2025-05-24 16:35:45.699806+00	CASSIAN	\N	2025-05-29 13:24:10.622809+00
14ddadb9-31fd-4659-a868-8ce3eb0e2331	2025-05-24 16:35:45.699806+00	CAT DEALERS	\N	2025-05-29 13:24:10.622809+00
c77648fd-460a-485c-ab9c-889cd515078d	2025-05-24 16:35:45.699806+00	CATCH & RELEASE TAKEOVER	\N	2025-05-29 13:24:10.622809+00
e1596281-a03b-4e63-b262-861fdce1862a	2025-05-24 16:35:45.699806+00	CAUTIOUS CLAY	\N	2025-05-29 13:24:10.622809+00
b1a59217-73ab-4b3c-b6e2-bdd565acbc68	2025-05-24 16:35:45.699806+00	CAZZTEK	\N	2025-05-29 13:24:10.622809+00
bbb70cfc-bf43-4fbd-86f6-5c28f964b80a	2025-05-24 16:35:45.699806+00	CEDAR TEETH	\N	2025-05-29 13:24:10.622809+00
e2cabdc6-162a-4c42-8fbc-a1958dae354e	2025-05-24 16:35:45.699806+00	CELISSE	\N	2025-05-29 13:24:10.622809+00
e5b0abd5-6bc7-4a0b-b4d9-39fc72f5a747	2025-05-24 16:35:45.699806+00	CH!LDS PLAY	\N	2025-05-29 13:24:10.622809+00
933ee147-1e38-422e-9d89-c54a6c11711b	2025-05-24 16:35:45.699806+00	CHALI 2NA & CUT CHEMIST	\N	2025-05-29 13:24:10.622809+00
8333437d-419b-4e4d-a06f-f991a8227085	2025-05-24 16:35:45.699806+00	CHALI2NA&CUT CHEMIST	\N	2025-05-29 13:24:10.622809+00
6b4f0e47-8d36-4f0c-8de3-e4d2f0bdaf4f	2025-05-24 16:35:45.699806+00	CHAMPAGNE DRIP	\N	2025-05-29 13:24:10.622809+00
d65a9276-3c56-4ca7-bb39-a57bf4498c12	2025-05-24 16:35:45.699806+00	CHAMPAGNE DRIP B2B LUZCID	\N	2025-05-29 13:24:10.622809+00
8c2431b2-45b4-4146-9606-c7ada6180107	2025-05-24 16:35:45.699806+00	CHANNEL TRES	\N	2025-05-29 13:24:10.622809+00
6e1ddedb-8ba0-4bc2-99e9-49bc78e87603	2025-05-24 16:35:45.699806+00	CHAPTER & VERSE	\N	2025-05-29 13:24:10.622809+00
254d7f69-84c2-4cc1-90b2-aece4c5761e3	2025-05-24 16:35:45.699806+00	CHARK	\N	2025-05-29 13:24:10.622809+00
71a7a7e4-7025-4028-8276-a6ba2ca208ea	2025-05-24 16:35:45.699806+00	CHARLES MEYER	\N	2025-05-29 13:24:10.622809+00
896d1939-d580-4c04-86d5-55fc7b4eae9b	2025-05-24 16:35:45.699806+00	CHARLESTHEFIRST	\N	2025-05-29 13:24:10.622809+00
7158ff72-a376-4f5e-ad54-52ec239f424e	2025-05-24 16:35:45.699806+00	CHARLOTTE DE WITTE	\N	2025-05-29 13:24:10.622809+00
d6e4f7d6-01f0-4b00-80ae-9deb7d7fcb95	2025-05-24 16:35:45.699806+00	CHEAT CODES	\N	2025-05-29 13:24:10.622809+00
90a88224-a982-4c2c-b842-6b02f079bf61	2025-05-24 16:35:45.699806+00	CHEE	\N	2025-05-29 13:24:10.622809+00
6f6071e3-776e-4aad-9d1e-38f267971ce6	2025-05-24 16:35:45.699806+00	CHEE B2B TSURUDA	\N	2025-05-29 13:24:10.622809+00
0e8d2c15-ccdd-4943-9944-15fcc2088c8d	2025-05-24 16:35:45.699806+00	CHEF BOYARBEATZ	\N	2025-05-29 13:24:10.622809+00
fa33ee21-273e-4483-9c16-139a8671cf4c	2025-05-24 16:35:45.699806+00	CHEF BOYARBEETS	\N	2025-05-29 13:24:10.622809+00
894e2371-3aa8-4b2d-b00e-03f96d28c049	2025-05-24 16:35:45.699806+00	CHELINA MANUHUTU	\N	2025-05-29 13:24:10.622809+00
84c78988-6ad1-43bd-a743-98d9a59d911e	2025-05-24 16:35:45.699806+00	CHELSEA CUTLER	\N	2025-05-29 13:24:10.622809+00
97d64ecf-be8c-4bc4-b359-526f23d4afde	2025-05-24 16:35:45.699806+00	CHERUB	\N	2025-05-29 13:24:10.622809+00
b673b0ba-4218-47b9-835a-11383d42ab39	2025-05-24 16:35:45.699806+00	CHET FAKER	\N	2025-05-29 13:24:10.622809+00
616a9eb9-0014-4a8e-944d-1f104ce93f96	2025-05-24 16:35:45.699806+00	CHICAGO FARMER & THE FIELD NOTES	\N	2025-05-29 13:24:10.622809+00
129d03a3-2e97-4350-a577-fd2c07d98e33	2025-05-24 16:35:45.699806+00	CHIDI	\N	2025-05-29 13:24:10.622809+00
1ae6ecea-716f-48c6-854d-f79340a430f6	2025-05-24 16:35:45.699806+00	CHIEF KAYA	\N	2025-05-29 13:24:10.622809+00
a16a4209-67f6-45b7-9cac-c316b66972ce	2025-05-24 16:35:45.699806+00	CHIKA	\N	2025-05-29 13:24:10.622809+00
4b5837f1-f7fe-423f-a027-ce6e9699f200	2025-05-24 16:35:45.699806+00	CHMURA	\N	2025-05-29 13:24:10.622809+00
53ffba9f-4928-4cab-aebe-2830daba97c4	2025-05-24 16:35:45.699806+00	CHOMPPA	\N	2025-05-29 13:24:10.622809+00
c0c67ce1-a3e3-4e13-b4bd-6314b6a9db24	2025-05-24 16:35:45.699806+00	CHOZEN	\N	2025-05-29 13:24:10.622809+00
173bc02c-d405-47e4-b50c-ce01f83680e8	2025-05-24 16:35:45.699806+00	CHRIS KARNS	\N	2025-05-29 13:24:10.622809+00
630a361b-486e-4491-94ec-d1aabe6abb99	2025-05-24 16:35:45.699806+00	CHRIS LAKE	\N	2025-05-29 13:24:10.622809+00
917fb3a2-6ee4-447f-9d0a-ef1fb4bba225	2025-05-24 16:35:45.699806+00	CHRIS LORENZO	\N	2025-05-29 13:24:10.622809+00
4c873b34-b2eb-4de7-8446-4f9668d1ab9d	2025-05-24 16:35:45.699806+00	CHRISTIAN MCFALL	\N	2025-05-29 13:24:10.622809+00
1d766419-18b4-445a-a4ef-93c356284101	2025-05-24 16:35:45.699806+00	CHROMONICCI	\N	2025-05-29 13:24:10.622809+00
dc7d3006-9ba9-467e-a5ba-29cca24b1055	2025-05-24 16:35:45.699806+00	CHVRCHES	\N	2025-05-29 13:24:10.622809+00
9ee577f7-bc4a-4f32-b38d-dc11b115f2da	2025-05-24 16:35:45.699806+00	CID	\N	2025-05-29 13:24:10.622809+00
c8f359f0-bdc3-4bfa-b6a9-24259808f22e	2025-05-24 16:35:45.699806+00	CIRCADIANRIFF	\N	2025-05-29 13:24:10.622809+00
b31f3979-abae-4559-9c3b-5adf42abc794	2025-05-24 16:35:45.699806+00	CLAPTONE	\N	2025-05-29 13:24:10.622809+00
a50ba3bc-d69e-4607-94e9-35425d0a4e4a	2025-05-24 16:35:45.699806+00	CLAUD	\N	2025-05-29 13:24:10.622809+00
04874b48-adb6-453d-9ae9-c7d79e3810ad	2025-05-24 16:35:45.699806+00	CLAUDE VONSTROKE	\N	2025-05-29 13:24:10.622809+00
24bc4870-7b5d-4665-9464-a88a5105fc98	2025-05-24 16:35:45.699806+00	CLINT SAMPLES	\N	2025-05-29 13:24:10.622809+00
5c8c9ee3-5d57-4cd9-bbf2-f4e49784dd3c	2025-05-24 16:35:45.699806+00	CLOONEE	\N	2025-05-29 13:24:10.622809+00
f7154093-f005-4b8b-8fce-1648b2ab4cdc	2025-05-24 16:35:45.699806+00	CLOUDNONE	\N	2025-05-29 13:24:10.622809+00
5deaa96a-b9e9-42c6-93b3-54fed8a6fa66	2025-05-24 16:35:45.699806+00	CLOZEE	\N	2025-05-29 13:24:10.622809+00
96e2e8cd-7ae4-43a6-a0fa-7d758f7945dc	2025-05-24 16:35:45.699806+00	CLOZEE X ANDROID JONES	\N	2025-05-29 13:24:10.622809+00
01b2fbc4-fefe-490f-bcc5-bf2d079c8937	2025-05-24 16:35:45.699806+00	CNTRLLA	\N	2025-05-29 13:24:10.622809+00
7667748b-05c4-41a5-a993-d31fbac1cb15	2025-05-24 16:35:45.699806+00	COCO & BREEZY	\N	2025-05-29 13:24:10.622809+00
ba9f9517-4eb6-4106-b95b-aa2a0e30af82	2025-05-24 16:35:45.699806+00	COFRESI	\N	2025-05-29 13:24:10.622809+00
49d8da10-a80c-43d2-bc10-fd3cc7baba6b	2025-05-24 16:35:45.699806+00	COIN	\N	2025-05-29 13:24:10.622809+00
5f40be7f-9432-424c-8cdb-e70b40c5c366	2025-05-24 16:35:45.699806+00	COKI	\N	2025-05-29 13:24:10.622809+00
dc52519f-ad81-4faf-9cfe-88f3714ec6d0	2025-05-24 16:35:45.699806+00	COLTCUTS	\N	2025-05-29 13:24:10.622809+00
399dfe29-7032-4c75-b9eb-cc57059c4979	2025-05-24 16:35:45.699806+00	COM3T	\N	2025-05-29 13:24:10.622809+00
c0d6b672-03d0-45ff-8a91-e91439a49881	2025-05-24 16:35:45.699806+00	COMISAR	\N	2025-05-29 13:24:10.622809+00
dc0c01a1-c0fd-45a4-bf89-0b10cfc6311d	2025-05-24 16:35:45.699806+00	COMISTAR	\N	2025-05-29 13:24:10.622809+00
3c93268e-2cb9-4178-aa98-de903cee400e	2025-05-24 16:35:45.699806+00	COMMON CREATION	\N	2025-05-29 13:24:10.622809+00
dab8424d-b149-4353-a8f4-a10c280c4304	2025-05-24 16:35:45.699806+00	COMPUTA	\N	2025-05-29 13:24:10.622809+00
eb2e800b-f5a6-4103-b387-04afd9d7fe5c	2025-05-24 16:35:45.699806+00	CON BRIO	\N	2025-05-29 13:24:10.622809+00
09d0d219-2627-479e-b21d-b94209b8c666	2025-05-24 16:35:45.699806+00	CONDUIT	\N	2025-05-29 13:24:10.622809+00
eddf28f5-d116-42b0-98cc-7e878988da04	2025-05-24 16:35:45.699806+00	CONRANK	\N	2025-05-29 13:24:10.622809+00
543363c8-be52-468e-9f12-923a503498d4	2025-05-24 16:35:45.699806+00	CORDAE	\N	2025-05-29 13:24:10.622809+00
855da62f-db4f-42ef-8488-8de303108bb9	2025-05-24 16:35:45.699806+00	CORRUPT	\N	2025-05-29 13:24:10.622809+00
38c4e089-5d66-4339-b86e-f6e769f5a6d2	2025-05-24 16:35:45.699806+00	CORRUPT UK	\N	2025-05-29 13:24:10.622809+00
397c27ca-b57a-49bb-88f9-48e9bec8e7f0	2025-05-24 16:35:45.699806+00	CORY HENRY	\N	2025-05-29 13:24:10.622809+00
b5a9a6a6-29bb-42a2-ae4e-8392609669ad	2025-05-24 16:35:45.699806+00	CORY HENRY AND THE FUNK APOSTLES	\N	2025-05-29 13:24:10.622809+00
817fc087-f102-426b-9649-7b358a4ab7b1	2025-05-24 16:35:45.699806+00	CORY WONG	\N	2025-05-29 13:24:10.622809+00
8d672b69-4006-4ed0-bb5e-8de6c504223d	2025-05-24 16:35:45.699806+00	COSMIC GATE	\N	2025-05-29 13:24:10.622809+00
4bb9f666-980e-4656-bfa1-952f85ec3f76	2025-05-24 16:35:45.699806+00	COUCH	\N	2025-05-29 13:24:10.622809+00
b20879dc-1a1f-4aaa-aea0-20f92c57e153	2025-05-24 16:35:45.699806+00	CRAIG CONNELLY	\N	2025-05-29 13:24:10.622809+00
a0b3fdde-922b-4ad8-97c9-1680acde14c6	2025-05-24 16:35:45.699806+00	CRANKDAT	\N	2025-05-29 13:24:10.622809+00
2541316a-e595-40ff-9f08-cf70baab9bad	2025-05-24 16:35:45.699806+00	CRIME FAMILY	\N	2025-05-29 13:24:10.622809+00
a0c37d28-d8a1-4c9c-8537-0799642855f9	2025-05-24 16:35:45.699806+00	CRISTOPH	\N	2025-05-29 13:24:10.622809+00
ad12a0c0-a781-4da9-83c2-891913e47811	2025-05-24 16:35:45.699806+00	CRUEL MISTRESS	\N	2025-05-29 13:24:10.622809+00
ae79e033-31dc-4d71-ab55-b0494eb7faa7	2025-05-24 16:35:45.699806+00	CRYSTAL SKIES	\N	2025-05-29 13:24:10.622809+00
6fe725cc-1b48-4038-aaac-f0a1c5946337	2025-05-24 16:35:45.699806+00	CULTURE SHOCK	\N	2025-05-29 13:24:10.622809+00
762dfdd5-f4dd-41f5-bbcc-28d8ab388365	2025-05-24 16:35:45.699806+00	CURRA	\N	2025-05-29 13:24:10.622809+00
421c385b-212b-4988-8e3e-68f46a3fc7c7	2025-05-24 16:35:45.699806+00	CUT RUGS	\N	2025-05-29 13:24:10.622809+00
ccbbaa8d-2410-4079-ace2-84184a3b80c6	2025-05-24 16:35:45.699806+00	CYTRUS	\N	2025-05-29 13:24:10.622809+00
70feec80-83c5-4900-b338-59446d07d356	2025-05-24 16:35:45.699806+00	D-STURB	\N	2025-05-29 13:24:10.622809+00
030f42ec-ac20-45b4-866b-76e912d87804	2025-05-24 16:35:45.699806+00	DA TWEEKAZ	\N	2025-05-29 13:24:10.622809+00
cb0bb59e-8614-4342-999e-1a19d7ef6dcf	2025-05-24 16:35:45.699806+00	DABIN	\N	2025-05-29 13:24:10.622809+00
6ce195f4-9bd9-43a6-8c5d-297e5259228c	2025-05-24 16:35:45.699806+00	DAILY BREAD	\N	2025-05-29 13:24:10.622809+00
47fb94c5-10bf-4c61-a0a0-e03244fa6487	2025-05-24 16:35:45.699806+00	DALEK ONE	\N	2025-05-29 13:24:10.622809+00
0814803c-9a38-44d0-b6d3-6121af1d2686	2025-05-24 16:35:45.699806+00	DALEK ONE X MYTHM	\N	2025-05-29 13:24:10.622809+00
9d394f14-5369-43c3-9ce5-35cafdaed03b	2025-05-24 16:35:45.699806+00	DANE	\N	2025-05-29 13:24:10.622809+00
348a3852-95ad-4ecc-872d-93cb43d5dd91	2025-05-24 16:35:45.699806+00	DANNY CORN	\N	2025-05-29 13:24:10.622809+00
f7e36633-19a9-473d-882b-115b69decd8f	2025-05-24 16:35:45.699806+00	DARKSIDERZ	\N	2025-05-29 13:24:10.622809+00
0b71ed81-7b1f-468c-9552-fce5b0071dc1	2025-05-24 16:35:45.699806+00	DARREN STYLES	\N	2025-05-29 13:24:10.622809+00
64765344-b15f-4d23-957a-41ddc6fff604	2025-05-24 16:35:45.699806+00	DASTARDLY	\N	2025-05-29 13:24:10.622809+00
a0cbfecd-1031-4dc3-bcd6-20d64a51225d	2025-05-24 16:35:45.699806+00	DAVID GUETTA	\N	2025-05-29 13:24:10.622809+00
f966a8a7-7f86-43ff-9a28-ac1e703b40d8	2025-05-24 16:35:45.699806+00	DAVID STARFIRE	\N	2025-05-29 13:24:10.622809+00
d9780d4f-c9e8-465b-a8a9-9c4547b55ce8	2025-05-24 16:35:45.699806+00	DAVIN TITUS	\N	2025-05-29 13:24:10.622809+00
a88ee616-023c-44e0-9108-d735780295a6	2025-05-24 16:35:45.699806+00	DAYGLOW	\N	2025-05-29 13:24:10.622809+00
667e8437-bfd3-4f06-b344-1a13f2ba35f4	2025-05-24 16:35:45.699806+00	DDT	\N	2025-05-29 13:24:10.622809+00
adc87b85-b8eb-40d8-8db5-ca29fc7456e6	2025-05-24 16:35:45.699806+00	DE-TU	\N	2025-05-29 13:24:10.622809+00
ae25bfb6-1def-48a9-9aed-21c59e108f6a	2025-05-24 16:35:45.699806+00	DEADCROW	\N	2025-05-29 13:24:10.622809+00
1f3ee1d9-4b1c-4090-a7c7-f4f46bdb9bf3	2025-05-24 16:35:45.699806+00	DEADLY GUNS	\N	2025-05-29 13:24:10.622809+00
4b0e08c4-cbc8-4262-ace3-957f0b6a0a98	2025-05-24 16:35:45.699806+00	DEADMAN	\N	2025-05-29 13:24:10.622809+00
b377dc5c-d202-4a39-87f5-13403ddd4095	2025-05-24 16:35:45.699806+00	DEADMAU5	\N	2025-05-29 13:24:10.622809+00
3a7c3b29-14d2-4755-8ed6-e7c1b2825cde	2025-05-24 16:35:45.699806+00	DEAFAOIL	\N	2025-05-29 13:24:10.622809+00
a2034ca0-bee9-4b8f-a492-37c03421dfca	2025-05-24 16:35:45.699806+00	DEATH KINGS	\N	2025-05-29 13:24:10.622809+00
0575d6a7-cf57-484b-8365-894a35d693d2	2025-05-24 16:35:45.699806+00	DEATHPACT	\N	2025-05-29 13:24:10.622809+00
81f24be4-e04f-4a8a-86ca-c9443af00453	2025-05-24 16:35:45.699806+00	DEBORAH DE LUCA	\N	2025-05-29 13:24:10.622809+00
2b2aa341-bf1c-4a83-9468-8d7886978717	2025-05-24 16:35:45.699806+00	DECADON	\N	2025-05-29 13:24:10.622809+00
2915b28d-7b5b-445a-924b-60a4131daa0f	2025-05-24 16:35:45.699806+00	DEEMZOO	\N	2025-05-29 13:24:10.622809+00
419b1bf8-8c66-40b0-b186-2765309a3a98	2025-05-24 16:35:45.699806+00	DEEPER PURPOSE	\N	2025-05-29 13:24:10.622809+00
5a251bfa-df1e-454b-825b-c0cd52688285	2025-05-24 16:35:45.699806+00	DEERSKIN	\N	2025-05-29 13:24:10.622809+00
0a991887-2aa6-422a-ac19-a07d15554fbf	2025-05-24 16:35:45.699806+00	DEEZ	\N	2025-05-29 13:24:10.622809+00
e1aa8f61-5e5c-4408-bb07-98a6b408afef	2025-05-24 16:35:45.699806+00	DEEZNAUTS	\N	2025-05-29 13:24:10.622809+00
d54575cf-993d-4e0b-8878-3be72f91ff28	2025-05-24 16:35:45.699806+00	DEFUNK	\N	2025-05-29 13:24:10.622809+00
6d51c76d-64b3-4cca-bcab-583a54ed4de7	2025-05-24 16:35:45.699806+00	DELA MOON	\N	2025-05-29 13:24:10.622809+00
1a50f0ae-18c8-40d2-8370-15440bc27d17	2025-05-24 16:35:45.699806+00	DELAMOON	\N	2025-05-29 13:24:10.622809+00
c2780ca5-c4ce-46cb-8de2-21af5fd05b60	2025-05-24 16:35:45.699806+00	DELTA HEAVY	\N	2025-05-29 13:24:10.622809+00
8e26f531-349c-44fc-a8d0-3607a89fc5c6	2025-05-24 16:35:45.699806+00	DENNIX CRUZ	\N	2025-05-29 13:24:10.622809+00
1bd61616-26db-4878-b2a6-637b3a472257	2025-05-24 16:35:45.699806+00	DENZEL CURRY	\N	2025-05-29 13:24:10.622809+00
8dff5ae7-6be1-4079-b578-69bfd48b839d	2025-05-24 16:35:45.699806+00	DEORRO	\N	2025-05-29 13:24:10.622809+00
f8509e4d-4ba7-439c-96e9-f5e8fd2a9f14	2025-05-24 16:35:45.699806+00	DERNIS	\N	2025-05-29 13:24:10.622809+00
67c62f3d-072b-4fdf-a83e-e94d932eb424	2025-05-24 16:35:45.699806+00	DESERT DWELLERS	\N	2025-05-29 13:24:10.622809+00
c776f1d4-bd48-408e-ac07-b8ebd887f623	2025-05-24 16:35:45.699806+00	DESTRUCTO	\N	2025-05-29 13:24:10.622809+00
6bafe2f6-f22a-4f65-828d-3b5157ea4b97	2025-05-24 16:35:45.699806+00	DETOX UNIT	\N	2025-05-29 13:24:10.622809+00
4a0c8e77-2a38-4e55-b013-8b38f3f1f805	2025-05-24 16:35:45.699806+00	DEVAULT	\N	2025-05-29 13:24:10.622809+00
ad4950a4-2287-4eb2-971e-afed84a07ad9	2025-05-24 16:35:45.699806+00	DEVIN KROES	\N	2025-05-29 13:24:10.622809+00
23f5387c-5f49-489f-888d-f9a0021abe6f	2025-05-24 16:35:45.699806+00	DEVIOUS	\N	2025-05-29 13:24:10.622809+00
7ec6169d-5f8c-45df-9085-dd2b24a5e0f1	2025-05-24 16:35:45.699806+00	DEVON JAMES	\N	2025-05-29 13:24:10.622809+00
f75b92a1-2476-4106-b56b-e3e1775f1966	2025-05-24 16:35:45.699806+00	DICE MAN	\N	2025-05-29 13:24:10.622809+00
dd2650fd-978c-45f8-9525-f9e2c78f096e	2025-05-24 16:35:45.699806+00	DICKEY DOO	\N	2025-05-29 13:24:10.622809+00
43435fd8-e95b-4b7f-9f69-6b3378d85374	2025-05-24 16:35:45.699806+00	DIELAHN	\N	2025-05-29 13:24:10.622809+00
93046a67-4480-4183-963e-8c65f5589b2a	2025-05-24 16:35:45.699806+00	DIESEL	\N	2025-05-29 13:24:10.622809+00
646ec18b-fee7-4b20-aa8c-c274d6c7a440	2025-05-24 16:35:45.699806+00	DIESELBOY	\N	2025-05-29 13:24:10.622809+00
8385dc6c-7721-428d-9ef9-a3659bf4e4eb	2025-05-24 16:35:45.699806+00	DIG SISTA	\N	2025-05-29 13:24:10.622809+00
09205bb8-522f-4f1c-9999-e751173fecfa	2025-05-24 16:35:45.699806+00	DIGITAL ETHOS	\N	2025-05-29 13:24:10.622809+00
3646a015-3bbb-4c65-9ff5-93d4807737ec	2025-05-24 16:35:45.699806+00	DILLARD	\N	2025-05-29 13:24:10.622809+00
3ff8913f-ebba-418d-bdb7-c1133415e3d6	2025-05-24 16:35:45.699806+00	DILLON FRANCIS	\N	2025-05-29 13:24:10.622809+00
768b5e18-a0a4-489a-ba14-a9e44744c226	2025-05-24 16:35:45.699806+00	DILLON NATHANIEL	\N	2025-05-29 13:24:10.622809+00
a946b224-b0b0-45a1-9e2b-f99583e5bbf0	2025-05-24 16:35:45.699806+00	DIMENSION	\N	2025-05-29 13:24:10.622809+00
f5a92096-eee1-4ba3-b242-b0cb1a0828b9	2025-05-24 16:35:45.699806+00	DIMIBO	\N	2025-05-29 13:24:10.622809+00
a21aa284-cf62-4345-aabf-2195094d6c63	2025-05-24 16:35:45.699806+00	DION TIMMER	\N	2025-05-29 13:24:10.622809+00
051da336-12e4-4cf9-9595-6f01dc21aa4f	2025-05-24 16:35:45.699806+00	DIPLO	\N	2025-05-29 13:24:10.622809+00
987b37ad-8b72-459b-bbab-488495f64110	2025-05-24 16:35:45.699806+00	DIRT MONKEY	\N	2025-05-29 13:24:10.622809+00
bf334a68-40f5-412c-9728-34ea13b96810	2025-05-24 16:35:45.699806+00	DIRTWIRE	\N	2025-05-29 13:24:10.622809+00
b331da02-4b0d-41e2-8947-e2dc5895a497	2025-05-24 16:35:45.699806+00	DISCLOSURE	\N	2025-05-29 13:24:10.622809+00
c38d3588-52e9-4a44-9d58-06083a625ada	2025-05-24 16:35:45.699806+00	DISKULL	\N	2025-05-29 13:24:10.622809+00
33391ef7-8678-445a-b96e-74e868f15393	2025-05-24 16:35:45.699806+00	DISTINCT MOTIVE	\N	2025-05-29 13:24:10.622809+00
5c84f9b0-1fed-4edd-bb43-c61cfa42ad02	2025-05-24 16:35:45.699806+00	DIXON’S VIOLIN	\N	2025-05-29 13:24:10.622809+00
11571121-fad4-4572-916c-3b058ac03ad3	2025-05-24 16:35:45.699806+00	DIZGO	\N	2025-05-29 13:24:10.622809+00
0b34cdb5-f29d-442c-bee4-9322592d0560	2025-05-24 16:35:45.699806+00	DJ ANIME	\N	2025-05-29 13:24:10.622809+00
35f47e8e-304f-4c28-a973-08eed60fdbe9	2025-05-24 16:35:45.699806+00	DJ DAVE	\N	2025-05-29 13:24:10.622809+00
cdb0db49-6904-4ba8-a6ea-c9e1a071a061	2025-05-24 16:35:45.699806+00	DJ FRACTAL THEORY	\N	2025-05-29 13:24:10.622809+00
c5a74657-8c26-4708-b421-85008c8a2e52	2025-05-24 16:35:45.699806+00	DJ HOLOGRAPHIC	\N	2025-05-29 13:24:10.622809+00
cfef6c67-b8ca-47fe-b801-4681d626cf52	2025-05-24 16:35:45.699806+00	DJ ISAAC	\N	2025-05-29 13:24:10.622809+00
19bb8ed0-f015-4002-a9a0-2afac9ffeb6d	2025-05-24 16:35:45.699806+00	DJ JAZZY JEFF	\N	2025-05-29 13:24:10.622809+00
040541ef-4be0-4dc2-ac86-c45b0528f183	2025-05-24 16:35:45.699806+00	DJ MINX	\N	2025-05-29 13:24:10.622809+00
05f6dd3d-79aa-4cf2-9640-b4f83433b5c5	2025-05-24 16:35:45.699806+00	DJ PREMIER	\N	2025-05-29 13:24:10.622809+00
060c9bde-8801-429c-98d6-b59153cf9f49	2025-05-24 16:35:45.699806+00	DJ SNAKE	\N	2025-05-29 13:24:10.622809+00
1db3f488-6bcb-44ce-80ac-280166dbeb87	2025-05-24 16:35:45.699806+00	DMVU	\N	2025-05-29 13:24:10.622809+00
ddb7d4ba-f44e-44a0-86dc-6f0c7b14190a	2025-05-24 16:35:45.699806+00	DNMO	\N	2025-05-29 13:24:10.622809+00
b663c38c-9f7f-4541-98b1-b5bf11d699de	2025-05-24 16:35:45.699806+00	DOCTOR JEEP	\N	2025-05-29 13:24:10.622809+00
114bbc40-f21a-40d3-a6ed-d77af154581a	2025-05-24 16:35:45.699806+00	DOGMA	\N	2025-05-29 13:24:10.622809+00
678f35f4-84cf-4ad2-ad22-94d17fb9a75d	2025-05-24 16:35:45.699806+00	DOGS IN A PILE	\N	2025-05-29 13:24:10.622809+00
491e448c-d912-49e2-a184-b26974af1799	2025-05-24 16:35:45.699806+00	DOM BRWN	\N	2025-05-29 13:24:10.622809+00
35427135-54ab-4997-b6c7-29caa7f43f59	2025-05-24 16:35:45.699806+00	DOM DOLLA	\N	2025-05-29 13:24:10.622809+00
eb171735-77e6-4ab5-ac06-97a80c1e1062	2025-05-24 16:35:45.699806+00	DOMBRESKY	\N	2025-05-29 13:24:10.622809+00
7e71b960-e098-4b1e-bab7-97ccca0cc2f1	2025-05-24 16:35:45.699806+00	DOMII	\N	2025-05-29 13:24:10.622809+00
22182c70-1a20-4aa8-94f4-77025159662c	2025-05-24 16:35:45.699806+00	DON DIABLO	\N	2025-05-29 13:24:10.622809+00
235d3e65-1f8b-4d56-9676-613ba58f50b4	2025-05-24 16:35:45.699806+00	DOOM FLAMINGO	\N	2025-05-29 13:24:10.622809+00
9479a478-4358-4945-943f-440042b20962	2025-05-24 16:35:45.699806+00	DÖP	\N	2025-05-29 13:24:10.622809+00
200be4f8-85b7-4383-8b0a-d527235fe1e6	2025-05-24 16:35:45.699806+00	DOPAPOD	\N	2025-05-29 13:24:10.622809+00
c371b2f1-16fb-4dec-a639-58f4e200a583	2025-05-24 16:35:45.699806+00	DOPEL	\N	2025-05-29 13:24:10.622809+00
b85faaed-35ac-4cae-8704-90edfa56e9ba	2025-05-24 16:35:45.699806+00	DOSS	\N	2025-05-29 13:24:10.622809+00
196ddfe9-ef71-4c7d-a629-a23faf73d719	2025-05-24 16:35:45.699806+00	DOT	\N	2025-05-29 13:24:10.622809+00
d23966bc-a819-416e-974b-4bd990254294	2025-05-24 16:35:45.699806+00	DOWNLINK	\N	2025-05-29 13:24:10.622809+00
584c8cbe-757e-4cc7-9a9b-68f8d4254065	2025-05-24 16:35:45.699806+00	DOWNLO	\N	2025-05-29 13:24:10.622809+00
182591a5-6e49-48a5-bb3e-ea92f9389ad4	2025-05-24 16:35:45.699806+00	DR FRESCH	\N	2025-05-29 13:24:10.622809+00
93098214-f7bd-45dc-b22f-cb145de92e02	2025-05-24 16:35:45.699806+00	DR PHUNK	\N	2025-05-29 13:24:10.622809+00
1dbff2fc-8688-42d5-876c-abc1bca4f07c	2025-05-24 16:35:45.699806+00	DR. BACON	\N	2025-05-29 13:24:10.622809+00
e35d21f2-94ee-4a50-b626-1b983b125327	2025-05-24 16:35:45.699806+00	DR. FRESCH	\N	2025-05-29 13:24:10.622809+00
586f0449-edbb-44e0-96f9-f53ad3d279ac	2025-05-24 16:35:45.699806+00	DRAMA	\N	2025-05-29 13:24:10.622809+00
8babb078-fe2d-45b1-ae71-9df65d048ac2	2025-05-24 16:35:45.699806+00	DREAM PUSHA	\N	2025-05-29 13:24:10.622809+00
9fdadc26-1dd3-48c4-9852-0681605123f7	2025-05-24 16:35:45.699806+00	DREZO	\N	2025-05-29 13:24:10.622809+00
35e7c4f0-e39b-4d60-8b67-931a2280b494	2025-05-24 16:35:45.699806+00	DRINKURWATER	\N	2025-05-29 13:24:10.622809+00
e61ce413-c324-4fc8-a41e-0102b363a6bf	2025-05-24 16:35:45.699806+00	DROELOE	\N	2025-05-29 13:24:10.622809+00
d9c9d1e5-427b-41ce-a3a4-9fa0b6c16d5f	2025-05-24 16:35:45.699806+00	DROPLITZ	\N	2025-05-29 13:24:10.622809+00
457958db-0db9-42f6-b882-f0980efa0350	2025-05-24 16:35:45.699806+00	DUCK SAUCE	\N	2025-05-29 13:24:10.622809+00
dce1eba8-3017-48a2-b60a-87d419d60845	2025-05-24 16:35:45.699806+00	DUCKWRTH	\N	2025-05-29 13:24:10.622809+00
ea7522a4-295f-405c-9ef8-b5942d1afc76	2025-05-24 16:35:45.699806+00	DUFFREY	\N	2025-05-29 13:24:10.622809+00
f4563977-0830-4265-9701-ac066959c705	2025-05-24 16:35:45.699806+00	DUKE DUMONT	\N	2025-05-29 13:24:10.622809+00
d0411f7e-8e2a-48ab-9613-f73520ae0145	2025-05-24 16:35:45.699806+00	DUMPLING	\N	2025-05-29 13:24:10.622809+00
8a7d5011-c311-4d6c-946f-92a0afb110f1	2025-05-24 16:35:45.699806+00	DUMPSTAPHUNK	\N	2025-05-29 13:24:10.622809+00
4d8055c2-1d2d-4695-bc65-1157b24b1cdd	2025-05-24 16:35:45.699806+00	DURAND JONES & THE INDICATORS	\N	2025-05-29 13:24:10.622809+00
bd7dffd8-011e-42dc-b59b-d157e94c4256	2025-05-24 16:35:45.699806+00	DURANDAL	\N	2025-05-29 13:24:10.622809+00
1e64c4e8-f127-402c-9dbf-5d1894d04bf1	2025-05-24 16:35:45.699806+00	DURANTE	\N	2025-05-29 13:24:10.622809+00
f313ae6e-cd77-48f2-a43f-992fb9959a90	2025-05-24 16:35:45.699806+00	EARTHGANG	\N	2025-05-29 13:24:10.622809+00
82b3a6d3-7751-4fa9-810d-c8f65bdd4735	2025-05-24 16:35:45.699806+00	EAZYBAKED	\N	2025-05-29 13:24:10.622809+00
6b3fec95-5413-4bef-beac-b3863431f121	2025-05-24 16:35:45.699806+00	ECHO BROWN	\N	2025-05-29 13:24:10.622809+00
2b6eadfc-9a19-4829-9a76-f9d70ad35612	2025-05-24 16:35:45.699806+00	ECOTEK	\N	2025-05-29 13:24:10.622809+00
5f43e56a-43b2-4b9c-8685-36832dc795e6	2025-05-24 16:35:45.699806+00	EDDIE ESSEKS	\N	2025-05-29 13:24:10.622809+00
c3bb4ff5-d8f5-4a81-acaf-29443b165a6f	2025-05-24 16:35:45.699806+00	EDDIE GOLD	\N	2025-05-29 13:24:10.622809+00
ead27b98-aa0a-48b9-95d5-246f14ea0558	2025-05-24 16:35:45.699806+00	EDEN PRINCE	\N	2025-05-29 13:24:10.622809+00
8b6082dd-dc34-467f-9ba3-eb873ab92cf2	2025-05-24 16:35:45.699806+00	EDIT	\N	2025-05-29 13:24:10.622809+00
69f9dfec-af6a-4db1-b864-bd7bf83fd4e1	2025-05-24 16:35:45.699806+00	EFFIN	\N	2025-05-29 13:24:10.622809+00
ffb99929-a4ae-4595-8535-3a8fdc2b5e32	2025-05-24 16:35:45.699806+00	EGGY	\N	2025-05-29 13:24:10.622809+00
6af730ba-91ee-42c0-b625-db6d27d5df86	2025-05-24 16:35:45.699806+00	EKALI	\N	2025-05-29 13:24:10.622809+00
11b0aaf7-99bf-4b28-a4b0-aec7f349121c	2025-05-24 16:35:45.699806+00	ELAH	\N	2025-05-29 13:24:10.622809+00
1286c72b-53fb-4391-8920-3c2582c5ca10	2025-05-24 16:35:45.699806+00	ELDER ISLAND	\N	2025-05-29 13:24:10.622809+00
ea413c86-587c-44ca-b209-c5cdd1e40c36	2025-05-24 16:35:45.699806+00	ELDERBROOK	\N	2025-05-29 13:24:10.622809+00
17915f13-3707-4662-b881-d2602ce7e42c	2025-05-24 16:35:45.699806+00	ELEPHANT HEART	\N	2025-05-29 13:24:10.622809+00
00395ea9-d974-48d9-a18c-ed7465c8fbff	2025-05-24 16:35:45.699806+00	ELI & FUR	\N	2025-05-29 13:24:10.622809+00
5433d511-91ae-47d4-9300-b60debf25374	2025-05-24 16:35:45.699806+00	ELIMINATE	\N	2025-05-29 13:24:10.622809+00
38a9ffad-6291-450c-9980-7f20de211a67	2025-05-24 16:35:45.699806+00	ELOHIM	\N	2025-05-29 13:24:10.622809+00
9e2551f9-c6c3-4f83-9326-3cb5ad1f1c09	2025-05-24 16:35:45.699806+00	EMANCIPATOR	\N	2025-05-29 13:24:10.622809+00
84bc7167-5cb0-4164-aee5-146e8cdf2105	2025-05-24 16:35:45.699806+00	EMINENCE ENSEMBLE	\N	2025-05-29 13:24:10.622809+00
a85d9945-440f-4b4a-bc39-48457d6d0cd4	2025-05-24 16:35:45.699806+00	EMOGEE	\N	2025-05-29 13:24:10.622809+00
672dcc24-31f3-459e-959a-6e9fef555407	2025-05-24 16:35:45.699806+00	EMPRESS OF	\N	2025-05-29 13:24:10.622809+00
6e0106db-2d0c-4862-977d-fe6526a57aa4	2025-05-24 16:35:45.699806+00	ENCOUNTERS	\N	2025-05-29 13:24:10.622809+00
e50c69c5-9e11-48d1-abcf-30e908239d87	2025-05-24 16:35:45.699806+00	ENGIX	\N	2025-05-29 13:24:10.622809+00
85e07965-e5f5-443d-bdc2-0ea81c0821d5	2025-05-24 16:35:45.699806+00	ENIGMA DUBZ	\N	2025-05-29 13:24:10.622809+00
c078f0d1-c079-4a8e-99d0-18d7cef02399	2025-05-24 16:35:45.699806+00	ENRICO SANGIULIANO	\N	2025-05-29 13:24:10.622809+00
1f76fe5b-1366-4ea3-b6c5-e36770143d5a	2025-05-24 16:35:45.699806+00	ENTANGLED MIND	\N	2025-05-29 13:24:10.622809+00
051e2d72-bc47-4d66-80a2-25c24fc1c5c3	2025-05-24 16:35:45.699806+00	ENTHEOGENIC	\N	2025-05-29 13:24:10.622809+00
c44512d2-1162-4ea1-863d-f076dc906409	2025-05-24 16:35:45.699806+00	EPISCOOL	\N	2025-05-29 13:24:10.622809+00
100edba3-2443-40a3-bd9e-935e9a7770aa	2025-05-24 16:35:45.699806+00	EPROM	\N	2025-05-29 13:24:10.622809+00
cd7a8718-db44-4ef9-b39d-a33828286d63	2025-05-24 16:35:45.699806+00	EPTIC	\N	2025-05-29 13:24:10.622809+00
68683e97-e512-4e99-8db0-d3bfb7f8a5a0	2025-05-24 16:35:45.699806+00	ERIC KRASNO & THE ASSEMBLY	\N	2025-05-29 13:24:10.622809+00
48cee1e4-c481-4ee4-aa3d-9bad2f825003	2025-05-24 16:35:45.699806+00	EROTHYME	\N	2025-05-29 13:24:10.622809+00
9ae66327-d7e1-4e94-9e2e-9e167522bb27	2025-05-24 16:35:45.699806+00	ESSEKS	\N	2025-05-29 13:24:10.622809+00
dd0035c3-c3d9-40fe-98f8-d3ca81f888cb	2025-05-24 16:35:45.699806+00	ETHNO	\N	2025-05-29 13:24:10.622809+00
6156bec8-f13d-4625-9d5f-ddc1434e4f82	2025-05-24 16:35:45.699806+00	EUGENE UGORSKI	\N	2025-05-29 13:24:10.622809+00
d1dd8e3e-f4cf-497a-ac82-f746b1f77ad1	2025-05-24 16:35:45.699806+00	EVALUATION	\N	2025-05-29 13:24:10.622809+00
04a6c2ff-926a-4e3e-8998-607f87cc44a4	2025-05-24 16:35:45.699806+00	EVALUTION	\N	2025-05-29 13:24:10.622809+00
9f587d66-2cc4-43fd-8cc7-029cf7a1b010	2025-05-24 16:35:45.699806+00	EVAN GIIA	\N	2025-05-29 13:24:10.622809+00
28fc6f9c-b2fa-4bf0-9fe2-f9c773eb252e	2025-05-24 16:35:45.699806+00	EVANOFF	\N	2025-05-29 13:24:10.622809+00
3f1d9214-64a9-41b5-b948-990ab109d98c	2025-05-24 16:35:45.699806+00	EVERYONE ORCHESTRA	\N	2025-05-29 13:24:10.622809+00
fd13b213-4618-48dc-b9bb-53e959fc857b	2025-05-24 16:35:45.699806+00	EVOLUSHAWN	\N	2025-05-29 13:24:10.622809+00
87b41ea5-c560-4722-9176-9a2b14d8cce5	2025-05-24 16:35:45.699806+00	EXCISION	\N	2025-05-29 13:24:10.622809+00
e58f57b5-a7c5-4aba-ae59-e8acf5ea9a7c	2025-05-24 16:35:45.699806+00	EXCISION (DETOX SET)	\N	2025-05-29 13:24:10.622809+00
da698866-79a0-4798-8845-8197512418ad	2025-05-24 16:35:45.699806+00	EXCISION B2B ILLENIUM	\N	2025-05-29 13:24:10.622809+00
9556fe31-caaa-48bb-9f50-0fc6823485c1	2025-05-24 16:35:45.699806+00	EXES	\N	2025-05-29 13:24:10.622809+00
9abac572-12ca-4dbb-8b79-52fde84bf6c7	2025-05-24 16:35:45.699806+00	EXIT 9	\N	2025-05-29 13:24:10.622809+00
e3d01ec0-0487-4443-9ab9-cfd9d3366440	2025-05-24 16:35:45.699806+00	EYLXR	\N	2025-05-29 13:24:10.622809+00
ef375860-a8fb-4d5d-8320-d8ddca6896c9	2025-05-24 16:35:45.699806+00	FACEPLANT	\N	2025-05-29 13:24:10.622809+00
c40e6d86-edcd-4b0d-833a-939f9ec4c997	2025-05-24 16:35:45.699806+00	FALLEN	\N	2025-05-29 13:24:10.622809+00
91d6a91b-c662-40e0-9a9c-63bffd7197e2	2025-05-24 16:35:45.699806+00	FAMILY GROOVE COMPANY	\N	2025-05-29 13:24:10.622809+00
479c2a6c-3a54-4314-8ce9-f4480cb7132e	2025-05-24 16:35:45.699806+00	FANCY MONSTER	\N	2025-05-29 13:24:10.622809+00
e8b387f0-6619-4dd7-a395-323ab9fde4bd	2025-05-24 16:35:45.699806+00	FANTASTIC NEGRITO	\N	2025-05-29 13:24:10.622809+00
5b0585ed-0e45-4caa-9593-ace104f85d14	2025-05-24 16:35:45.699806+00	FAR OUT	\N	2025-05-29 13:24:10.622809+00
036c5246-a215-4242-8b0a-8a5d6085dbbf	2025-05-24 16:35:45.699806+00	FARSIDE	\N	2025-05-29 13:24:10.622809+00
71b553c5-03eb-4193-9200-6abf5eaec51f	2025-05-24 16:35:45.699806+00	FATUM	\N	2025-05-29 13:24:10.622809+00
b644f970-6721-4979-9c55-d37404ee15d3	2025-05-24 16:35:45.699806+00	FAUVELY	\N	2025-05-29 13:24:10.622809+00
6771e506-41f3-47fe-9029-585231888b24	2025-05-24 16:35:45.699806+00	FAYBL	\N	2025-05-29 13:24:10.622809+00
103bad39-0e29-4494-a9ab-580f030d989f	2025-05-24 16:35:45.699806+00	FEELMONGER	\N	2025-05-29 13:24:10.622809+00
a861ba27-fe94-4cbb-bb7f-cc14b4bf533e	2025-05-24 16:35:45.699806+00	FELIX CARTAL	\N	2025-05-29 13:24:10.622809+00
29e84d89-26ec-4dc6-87a2-26481dde29f4	2025-05-24 16:35:45.699806+00	FELLY	\N	2025-05-29 13:24:10.622809+00
35d0f12a-8b41-491b-a60a-58d619ae4723	2025-05-24 16:35:45.699806+00	FEMI KUTI	\N	2025-05-29 13:24:10.622809+00
352f3700-f7d8-41cb-aa39-8d4401945bc6	2025-05-24 16:35:45.699806+00	FEMI KUTI & THE POSITIVE FORCE	\N	2025-05-29 13:24:10.622809+00
0ab06db4-36d4-4d98-8cb0-3e7e5175802a	2025-05-24 16:35:45.699806+00	FERRY CORSTEN	\N	2025-05-29 13:24:10.622809+00
aafc4eef-981d-47e9-8019-0fc23f82e83f	2025-05-24 16:35:45.699806+00	FIFTHDENSITY	\N	2025-05-29 13:24:10.622809+00
6bb72406-9305-4f13-aafa-11e50598bd93	2025-05-24 16:35:45.699806+00	FINDERZ KEEPERZ	\N	2025-05-29 13:24:10.622809+00
446b680b-71fa-4b07-8ad1-a8dc92a74345	2025-05-24 16:35:45.699806+00	FISHER	\N	2025-05-29 13:24:10.622809+00
75ad64f4-7d84-4864-a359-b2929d06f83a	2025-05-24 16:35:45.699806+00	FISHER (SUNSET SET)	\N	2025-05-29 13:24:10.622809+00
0d5d0a19-8200-426f-a2c2-bf9ffeb7b520	2025-05-24 16:35:45.699806+00	FIVE LETTER WORD	\N	2025-05-29 13:24:10.622809+00
8e31f36c-e2ee-48e4-943f-13d2e365d80c	2025-05-24 16:35:45.699806+00	FJAAK	\N	2025-05-29 13:24:10.622809+00
75e6db79-5bc2-4618-a5a3-9cab059b02f6	2025-05-24 16:35:45.699806+00	FLAMINGOSIS	\N	2025-05-29 13:24:10.622809+00
620396af-f21b-48d5-a0c5-96212607ce2b	2025-05-24 16:35:45.699806+00	FLETCHER	\N	2025-05-29 13:24:10.622809+00
5a9808fb-7671-4f42-823d-7a7093658260	2025-05-24 16:35:45.699806+00	FLINTWICK	\N	2025-05-29 13:24:10.622809+00
3b176318-ecfd-4e09-9b2e-e94b51a6b95a	2025-05-24 16:35:45.699806+00	FLIPTURN	\N	2025-05-29 13:24:10.622809+00
455a6da5-b593-4752-be9c-a2ed90f61711	2025-05-24 16:35:45.699806+00	FLORET LORET	\N	2025-05-29 13:24:10.622809+00
ff969eaf-8c21-4ecf-9400-ccd294288032	2025-05-24 16:35:45.699806+00	FLOWMOTION	\N	2025-05-29 13:24:10.622809+00
c4f974a0-eef9-4fa7-afd0-2283f3368b74	2025-05-24 16:35:45.699806+00	FLUME	\N	2025-05-29 13:24:10.622809+00
9c4173f9-5459-4888-858f-f51bbb954b43	2025-05-24 16:35:45.699806+00	FLUX PAVILION	\N	2025-05-29 13:24:10.622809+00
5581d58f-3064-4a7a-a5d1-9b0dceb12a2b	2025-05-24 16:35:45.699806+00	FLY	\N	2025-05-29 13:24:10.622809+00
0d4ba422-511b-4a0d-8743-4d38929e8dd1	2025-05-24 16:35:45.699806+00	FORD.	\N	2025-05-29 13:24:10.622809+00
4c03a71a-31a5-439f-bea8-cff31926e528	2025-05-24 16:35:45.699806+00	FOREIGN SUSPECTS	\N	2025-05-29 13:24:10.622809+00
d0e10744-e210-4b4e-8f7f-fd3cdc37348c	2025-05-24 16:35:45.699806+00	FOREST FATHERS	\N	2025-05-29 13:24:10.622809+00
db9e0670-8dea-4b22-bb02-35a73996742c	2025-05-24 16:35:45.699806+00	FORMERLY THE FOX	\N	2025-05-29 13:24:10.622809+00
e9efaa5b-3ef7-4a01-93c0-9a38f5e97e42	2025-05-24 16:35:45.699806+00	FORT KNOX FIVE & QDUP	\N	2025-05-29 13:24:10.622809+00
5c3ef805-a785-4caa-b320-b7fa6b5b0b8c	2025-05-24 16:35:45.699806+00	FOUR TET	\N	2025-05-29 13:24:10.622809+00
e80c617d-5f4c-4d9d-aa7a-71834a439f9f	2025-05-24 16:35:45.699806+00	FOXY MORON	\N	2025-05-29 13:24:10.622809+00
1f6f441b-dd18-4bad-8cf0-dae5a57b0f5f	2025-05-24 16:35:45.699806+00	FRAMEWORKS	\N	2025-05-29 13:24:10.622809+00
bbdb0049-7a19-4864-bc21-69ed1f378b10	2025-05-24 16:35:45.699806+00	FRANC MOODY	\N	2025-05-29 13:24:10.622809+00
27621df5-38c6-4a22-a646-4c0642a10126	2025-05-24 16:35:45.699806+00	FRANCIS MERCIER	\N	2025-05-29 13:24:10.622809+00
2041b5e9-e570-4ea5-990f-9fc3c1a83f36	2025-05-24 16:35:45.699806+00	FRANSIS DERELLE	\N	2025-05-29 13:24:10.622809+00
a4617c6a-e39f-45c1-9cfc-e01d759f9286	2025-05-24 16:35:45.699806+00	FREAKON	\N	2025-05-29 13:24:10.622809+00
f91106ff-53df-4ebb-a44a-9715115ac2a0	2025-05-24 16:35:45.699806+00	FREAKY	\N	2025-05-29 13:24:10.622809+00
b895f41b-8d32-4226-ad3b-18f850e61b5c	2025-05-24 16:35:45.699806+00	FREDDY TODD	\N	2025-05-29 13:24:10.622809+00
bc95222c-4254-4b94-8c6b-0611a7046949	2025-05-24 16:35:45.699806+00	FREQ	\N	2025-05-29 13:24:10.622809+00
85204815-53a8-4b46-8efd-00b5d0485478	2025-05-24 16:35:45.699806+00	FREQUENT	\N	2025-05-29 13:24:10.622809+00
7517a33d-94c4-4ef6-9cb4-8c14eaf3e5c2	2025-05-24 16:35:45.699806+00	FREQUENT & HUDSON LEE	\N	2025-05-29 13:24:10.622809+00
7537f8ed-5139-4a40-9743-21bf8403a376	2025-05-24 16:35:45.699806+00	FRIDA K	\N	2025-05-29 13:24:10.622809+00
6b5ad5a3-4536-4ea5-9303-8fd84533f52d	2025-05-24 16:35:45.699806+00	FRISBAE	\N	2025-05-29 13:24:10.622809+00
0103e9de-0590-45fc-9e79-654263988580	2025-05-24 16:35:45.699806+00	FUNDIDO	\N	2025-05-29 13:24:10.622809+00
b4b8f2fd-93db-4dac-b4c2-97ab6584d06b	2025-05-24 16:35:45.699806+00	FUNK YOU	\N	2025-05-29 13:24:10.622809+00
42761211-3c0b-4d0b-813d-f4e1c8fb6a96	2025-05-24 16:35:45.699806+00	FUNKSHWAY	\N	2025-05-29 13:24:10.622809+00
6ae1d526-a1eb-48cd-97f5-245bd793a8e9	2025-05-24 16:35:45.699806+00	FURY	\N	2025-05-29 13:24:10.622809+00
f9ea4624-18e0-46c5-93b1-512cbf7cbc7c	2025-05-24 16:35:45.699806+00	G JONES	\N	2025-05-29 13:24:10.622809+00
2c1919c2-5ae2-4555-be16-c2f7cc610aff	2025-05-24 16:35:45.699806+00	G JONES B2B EPROM	\N	2025-05-29 13:24:10.622809+00
fb0b14ca-9d24-49d7-bd12-7b14ea093db7	2025-05-24 16:35:45.699806+00	G SENSE	\N	2025-05-29 13:24:10.622809+00
520a5fe5-3c1f-452e-80f0-122260e49497	2025-05-24 16:35:45.699806+00	G-REX	\N	2025-05-29 13:24:10.622809+00
6c7d4958-fc09-4674-a886-af91c5e64f90	2025-05-24 16:35:45.699806+00	G-SPACE	\N	2025-05-29 13:24:10.622809+00
deedd8c0-f228-4289-8a16-c7806fc7280d	2025-05-24 16:35:45.699806+00	GABRIEL & DRESDEN	\N	2025-05-29 13:24:10.622809+00
4d383be8-a9dd-4079-885b-11a2f2c31e08	2025-05-24 16:35:45.699806+00	GALANTIS	\N	2025-05-29 13:24:10.622809+00
40f331b4-caa2-46b1-8dab-2c0871bc4450	2025-05-24 16:35:45.699806+00	GAMMER	\N	2025-05-29 13:24:10.622809+00
6a2d3037-1e9d-4716-a7e4-9876a2d654d9	2025-05-24 16:35:45.699806+00	GANJA WHITE NIGHT	\N	2025-05-29 13:24:10.622809+00
24ab379e-a8fb-4a1c-9baa-9dcb21f390f1	2025-05-24 16:35:45.699806+00	GARDELLA	\N	2025-05-29 13:24:10.622809+00
ce98b89f-3a36-41c0-adc0-706547f1e6ca	2025-05-24 16:35:45.699806+00	GATTUSO	\N	2025-05-29 13:24:10.622809+00
978d69ba-71ce-4d1d-9419-e75522e83b49	2025-05-24 16:35:45.699806+00	GAUDI	\N	2025-05-29 13:24:10.622809+00
c4d2ae5f-811c-4ea2-ad2f-e9e1950c00df	2025-05-24 16:35:45.699806+00	GEM & TAURI	\N	2025-05-29 13:24:10.622809+00
7bea3ece-1907-4275-a988-b4247ea8b86e	2025-05-24 16:35:45.699806+00	GENE FARRIS	\N	2025-05-29 13:24:10.622809+00
b0ea3abc-da76-4810-8647-b942a54e987e	2025-05-24 16:35:45.699806+00	GEO	\N	2025-05-29 13:24:10.622809+00
940764b9-d756-4460-b982-1dd7507947b0	2025-05-24 16:35:45.699806+00	GETTER	\N	2025-05-29 13:24:10.622809+00
9624771a-70d6-40e4-9595-033bc6e76506	2025-05-24 16:35:45.699806+00	GETTOBLASTER	\N	2025-05-29 13:24:10.622809+00
7d2d5ce3-996b-4ce8-855b-77c331fa9a39	2025-05-24 16:35:45.699806+00	GETTOBLASTER B2B FRANKLIN WATTS	\N	2025-05-29 13:24:10.622809+00
a96be806-8ac8-4d5c-8ee9-cd5286eea9f7	2025-05-24 16:35:45.699806+00	GG MAGREE	\N	2025-05-29 13:24:10.622809+00
0dfda089-c25b-4616-859f-fb3e0f6887df	2025-05-24 16:35:45.699806+00	GHASTLY	\N	2025-05-29 13:24:10.622809+00
96140536-e221-4451-9b5a-f24bb5f59fd0	2025-05-24 16:35:45.699806+00	GHASTLY B2B EPTIC	\N	2025-05-29 13:24:10.622809+00
ecd2ad7a-1c9c-4b6a-9421-9267ac95bfe6	2025-05-24 16:35:45.699806+00	GHOST LIGHT	\N	2025-05-29 13:24:10.622809+00
3060702b-864d-4bcf-8674-bd582e8fdf22	2025-05-24 16:35:45.699806+00	GHOST RYDR	\N	2025-05-29 13:24:10.622809+00
1f86787c-0a62-4d7c-a694-390e82dd8d26	2025-05-24 16:35:45.699806+00	GHOST RYDR (GHASTLY B2B JOYRIDE)	\N	2025-05-29 13:24:10.622809+00
37e37bed-deae-4ad1-a5e2-768d7bf10161	2025-05-24 16:35:45.699806+00	GHOST-NOTE	\N	2025-05-29 13:24:10.622809+00
dabdcbcf-b3ef-47a0-a829-89768a1953c3	2025-05-24 16:35:45.699806+00	GHOSTRYDER	\N	2025-05-29 13:24:10.622809+00
7a5745bb-4b59-42ce-951f-b620c6aa52c1	2025-05-24 16:35:45.699806+00	GIANT WALKING ROBOTS	\N	2025-05-29 13:24:10.622809+00
62ad76f7-fc10-4c8a-a66a-ef258a83f27b	2025-05-24 16:35:45.699806+00	GIOLI & ASSIA	\N	2025-05-29 13:24:10.622809+00
e03f8509-390e-4260-a615-b3a19ce8e356	2025-05-24 16:35:45.699806+00	GIORGIA ANGIULI – LIVE	\N	2025-05-29 13:24:10.622809+00
a4bdb009-ad5a-491c-9ee9-66ad3eb96af0	2025-05-24 16:35:45.699806+00	GIUSEPPE OTTAVIANI	\N	2025-05-29 13:24:10.622809+00
35f68fa5-60ec-4bf4-9c4e-1671aa7fce0f	2025-05-24 16:35:45.699806+00	GLASS ANIMALS	\N	2025-05-29 13:24:10.622809+00
27bfbe6c-7559-4d58-8ecf-0d9a9431699b	2025-05-24 16:35:45.699806+00	GLOOM TRENCH	\N	2025-05-29 13:24:10.622809+00
c5b05dea-2e20-44dd-9407-0ae0a64706b8	2025-05-24 16:35:45.699806+00	GNVALY	\N	2025-05-29 13:24:10.622809+00
ee670140-c1e2-4d26-9728-5addc0c4379d	2025-05-24 16:35:45.699806+00	GOLDEN PONY	\N	2025-05-29 13:24:10.622809+00
9a1795b4-cc3b-436c-8035-140c1070c7d5	2025-05-24 16:35:45.699806+00	GOLDENCHILD	\N	2025-05-29 13:24:10.622809+00
e7807c7d-2a0f-46fb-9be5-51370b1e0dcf	2025-05-24 16:35:45.699806+00	GOLDLINK	\N	2025-05-29 13:24:10.622809+00
9160c44d-c00c-488e-9cca-878221922bd1	2025-05-24 16:35:45.699806+00	GONE GONE BEYOND	\N	2025-05-29 13:24:10.622809+00
eb558179-dba1-4ddf-b392-0d9af9d40e3e	2025-05-24 16:35:45.699806+00	GOOD TIMES AHEAD	\N	2025-05-29 13:24:10.622809+00
e6fb6334-ed27-474e-8204-b8b6538fed9a	2025-05-24 16:35:45.699806+00	GOODNIGHT, TEXAS	\N	2025-05-29 13:24:10.622809+00
805a080c-7a3d-494a-a73b-dc416a744a44	2025-05-24 16:35:45.699806+00	GOOSE	\N	2025-05-29 13:24:10.622809+00
ce757039-d115-4e11-9b6f-132bb03e6547	2025-05-24 16:35:45.699806+00	GORDO	\N	2025-05-29 13:24:10.622809+00
571c23fc-5a96-4247-bd74-8a0531111847	2025-05-24 16:35:45.699806+00	GORGON CITY	\N	2025-05-29 13:24:10.622809+00
1ef315d8-9eef-48be-bbc8-b9728991ac10	2025-05-24 16:35:45.699806+00	GOTH BABE	\N	2025-05-29 13:24:10.622809+00
5fcc05e8-3f9a-47ef-8209-1062b6c32ac3	2025-05-24 16:35:45.699806+00	GRABBITS	\N	2025-05-29 13:24:10.622809+00
5210b90e-1c67-45bc-b092-b4da8e9711a3	2025-05-24 16:35:45.699806+00	GRABBITZ	\N	2025-05-29 13:24:10.622809+00
da730cfd-0bf5-4662-ad69-34225b542f5d	2025-05-24 16:35:45.699806+00	GRAFIX	\N	2025-05-29 13:24:10.622809+00
ae13b20c-4de4-4ba3-be87-105eb06a6ee0	2025-05-24 16:35:45.699806+00	GRANDPA DA GAMBLER	\N	2025-05-29 13:24:10.622809+00
f1e67673-ea18-4acc-ba4f-ef8e949e1ba4	2025-05-24 16:35:45.699806+00	GRANDTHEFT	\N	2025-05-29 13:24:10.622809+00
806979e5-7398-44e9-907a-e5329be2cc2c	2025-05-24 16:35:45.699806+00	GREEN VELVET	\N	2025-05-29 13:24:10.622809+00
56e90481-3d8a-4e98-a3bb-b5ce51226215	2025-05-24 16:35:45.699806+00	GREENHOUSE LOUNGE	\N	2025-05-29 13:24:10.622809+00
d7b3a994-bb1e-46e6-9f94-16f2198376d5	2025-05-24 16:35:45.699806+00	GREENSKY BLUEGRASS	\N	2025-05-29 13:24:10.622809+00
9762aa60-2c5c-44e4-96b2-641b63435f0b	2025-05-24 16:35:45.699806+00	GREG WILSON	\N	2025-05-29 13:24:10.622809+00
7991ae35-3137-4e2b-bccb-a27e35184eb9	2025-05-24 16:35:45.699806+00	GRGLY	\N	2025-05-29 13:24:10.622809+00
5e156832-df00-4f89-8286-6d643ee417b8	2025-05-24 16:35:45.699806+00	GRIMBLEE	\N	2025-05-29 13:24:10.622809+00
3c5505a1-3932-452f-8b0b-0a6848a0a73f	2025-05-24 16:35:45.699806+00	GRIMES	\N	2025-05-29 13:24:10.622809+00
b3c2b328-2c0b-41ea-89a3-6f242884eecd	2025-05-24 16:35:45.699806+00	GRIZ	\N	2025-05-29 13:24:10.622809+00
45953ffd-e802-4ab6-a867-6bd370391bbe	2025-05-24 16:35:45.699806+00	GRYFFIN	\N	2025-05-29 13:24:10.622809+00
7c419e02-36da-4197-a302-611b24656a95	2025-05-24 16:35:45.699806+00	GRYMETYME	\N	2025-05-29 13:24:10.622809+00
05d4db7b-5795-4ebe-ab4f-0ce04bb585db	2025-05-24 16:35:45.699806+00	GUILLAME & THE COUTU DUMONTS	\N	2025-05-29 13:24:10.622809+00
420ad337-c7af-4025-adbc-ad5321b63acc	2025-05-24 16:35:45.699806+00	HABSTRAKT	\N	2025-05-29 13:24:10.622809+00
c41316c0-b177-4c9d-b8b7-097988b9534f	2025-05-24 16:35:45.699806+00	HAIRITAGE	\N	2025-05-29 13:24:10.622809+00
030f7fd3-20fb-4823-90a1-e3f9f5e736b4	2025-05-24 16:35:45.699806+00	HANA	\N	2025-05-29 13:24:10.622809+00
12c7648b-27e3-4c2e-8777-9471a9dafd8f	2025-05-24 16:35:45.699806+00	HANDSOME TIGER	\N	2025-05-29 13:24:10.622809+00
703c2cf7-f6df-4dc5-9ee7-5bdbd339200f	2025-05-24 16:35:45.699806+00	HANDZ	\N	2025-05-29 13:24:10.622809+00
d6e281d0-1fd8-46eb-8339-f82552d74712	2025-05-24 16:35:45.699806+00	HAPPY CAMPER	\N	2025-05-29 13:24:10.622809+00
28c010c4-4af3-433e-87df-b038c0475c50	2025-05-24 16:35:45.699806+00	HAUMS	\N	2025-05-29 13:24:10.622809+00
5dd8b5a5-8387-4021-988f-6e4c6f8eea69	2025-05-24 16:35:45.699806+00	HE$H	\N	2025-05-29 13:24:10.622809+00
6115ef8f-6dde-453e-9116-d64edb91caeb	2025-05-24 16:35:45.699806+00	HEADHUNTERZ	\N	2025-05-29 13:24:10.622809+00
f6c2e6c3-0abd-4ad3-82d0-fb772a45ba3c	2025-05-24 16:35:45.699806+00	HECKADECIMAL	\N	2025-05-29 13:24:10.622809+00
c7b9a5f6-2c6d-4304-b8a6-4624d8bca27c	2025-05-24 16:35:45.699806+00	HEKLER	\N	2025-05-29 13:24:10.622809+00
687c1a10-3f74-40cd-9922-96e33ed86b0f	2025-05-24 16:35:45.699806+00	HEKTIK	\N	2025-05-29 13:24:10.622809+00
4b2c9426-7671-4127-8989-f22e56341b7f	2025-05-24 16:35:45.699806+00	HERBIE HANCOCK	\N	2025-05-29 13:24:10.622809+00
d44440f5-7854-4cde-b6a6-4d4c01449ceb	2025-05-24 16:35:45.699806+00	HERE COME THE MUMMIES	\N	2025-05-29 13:24:10.622809+00
77fe1711-8dae-4430-9774-a507429027d0	2025-05-24 16:35:45.699806+00	HERMANOS GUTIERREZ	\N	2025-05-29 13:24:10.622809+00
d2fb195e-a3b8-4791-9750-5744ac70d2b5	2025-05-24 16:35:45.699806+00	HERNAN CATTANEO	\N	2025-05-29 13:24:10.622809+00
68ca40ab-1ec5-405a-8d02-ad51ec227241	2025-05-24 16:35:45.699806+00	HEROBUST	\N	2025-05-29 13:24:10.622809+00
47be4daf-5aa2-4064-9885-c142ce1f2e70	2025-05-24 16:35:45.699806+00	HESH	\N	2025-05-29 13:24:10.622809+00
c328eee0-e7a7-4898-92fc-03986af2315b	2025-05-24 16:35:45.699806+00	HEX COUGAR	\N	2025-05-29 13:24:10.622809+00
ff0890bd-97e9-43b0-be9f-6a38aed71d3e	2025-05-24 16:35:45.699806+00	HEYZ	\N	2025-05-29 13:24:10.622809+00
9fc96741-626c-46b1-93ab-2a5b0fabce20	2025-05-24 16:35:45.699806+00	HIGH STEP SOCIETY	\N	2025-05-29 13:24:10.622809+00
ba609f83-724c-44a1-8a01-980cf3097c7f	2025-05-24 16:35:45.699806+00	HIPPY CHRIS	\N	2025-05-29 13:24:10.622809+00
1d2a4d2e-b78f-47cd-9903-b4556fca7881	2025-05-24 16:35:45.699806+00	HOBDAY	\N	2025-05-29 13:24:10.622809+00
0ba285c9-a81f-4f13-956c-5ef3cbd06654	2025-05-24 16:35:45.699806+00	HOL!	\N	2025-05-29 13:24:10.622809+00
c29f584d-d748-48d9-9af2-97767d797211	2025-05-24 16:35:45.699806+00	HOLY SMOKES	\N	2025-05-29 13:24:10.622809+00
4ab060f1-157c-4437-87dd-34c74577571c	2025-05-24 16:35:45.699806+00	HONEY DJON	\N	2025-05-29 13:24:10.622809+00
86011a9f-899c-43c9-a693-9ec80784dbd0	2025-05-24 16:35:45.699806+00	HONEY HOUNDS	\N	2025-05-29 13:24:10.622809+00
08169351-e7f0-4c01-bab2-966af86981ab	2025-05-24 16:35:45.699806+00	HONEY ISLAND SWAMP BAND	\N	2025-05-29 13:24:10.622809+00
712f336f-e2de-4bce-a68d-bf2a3a50adbb	2025-05-24 16:35:45.699806+00	HONEYBEE	\N	2025-05-29 13:24:10.622809+00
40e5cff6-cfd9-4e03-b9d8-6e1c4ddfc2eb	2025-05-24 16:35:45.699806+00	HONEYCOMB	\N	2025-05-29 13:24:10.622809+00
82415f5a-89ea-4a99-911a-61304e197e5d	2025-05-24 16:35:45.699806+00	HONEYLUV	\N	2025-05-29 13:24:10.622809+00
16030b89-a859-4a5c-88c7-6f9d50113f4e	2025-05-24 16:35:45.699806+00	HPNOTIC	\N	2025-05-29 13:24:10.622809+00
f73e31b8-b650-491a-94c5-5a0dfe4e265d	2025-05-24 16:35:45.699806+00	HUDSON LEE	\N	2025-05-29 13:24:10.622809+00
3543cb45-c872-4abc-ba85-487a2860c72d	2025-05-24 16:35:45.699806+00	HUGEL	\N	2025-05-29 13:24:10.622809+00
0e6858d0-5d38-4a60-af76-5df4daa025e3	2025-05-24 16:35:45.699806+00	HULK GANG	\N	2025-05-29 13:24:10.622809+00
b6dc9d4d-7f92-4662-a965-56b69967ab00	2025-05-24 16:35:45.699806+00	HUXLEY ANNE	\N	2025-05-29 13:24:10.622809+00
5e4c41bb-f708-4c8b-ba0a-b849f66645f0	2025-05-24 16:35:45.699806+00	HVDES	\N	2025-05-29 13:24:10.622809+00
f13e5d85-2d04-461f-9470-ed66b210d862	2025-05-24 16:35:45.699806+00	HYBRID MINDS	\N	2025-05-29 13:24:10.622809+00
c12473f3-6818-43ec-b547-22773a403e5e	2025-05-24 16:35:45.699806+00	HYDRAULIX	\N	2025-05-29 13:24:10.622809+00
f9caa512-e73d-4b8e-abb6-e56b126bd68b	2025-05-24 16:35:45.699806+00	HYPHO	\N	2025-05-29 13:24:10.622809+00
232ef934-1431-44e9-ae22-1eeaae7ed74e	2025-05-24 16:35:45.699806+00	HYPNOZ	\N	2025-05-29 13:24:10.622809+00
8e72afbc-01d2-4df7-bbad-d5f938f5d09c	2025-05-24 16:35:45.699806+00	HYROGLIFICS	\N	2025-05-29 13:24:10.622809+00
9959c0cd-551e-450c-aded-69699d6244ee	2025-05-24 16:35:45.699806+00	I HATE MODELS	\N	2025-05-29 13:24:10.622809+00
a90ff97b-599d-402b-b0ce-911a936ea1bb	2025-05-24 16:35:45.699806+00	IAN RIVERS	\N	2025-05-29 13:24:10.622809+00
228afa16-0ff3-4e1d-87c7-3b372f2c2cab	2025-05-24 16:35:45.699806+00	IGGY	\N	2025-05-29 13:24:10.622809+00
eba0d98c-438b-417d-950e-6dd8904e0ac2	2025-05-24 16:35:45.699806+00	ILAN BLUESTONE	\N	2025-05-29 13:24:10.622809+00
08858b0a-8c9c-45e0-8965-54a4f90146cc	2025-05-24 16:35:45.699806+00	ILARIO ALICANTE	\N	2025-05-29 13:24:10.622809+00
29934d50-6d00-4f48-9000-9ceae85cf8bd	2025-05-24 16:35:45.699806+00	ILLANTHROPY	\N	2025-05-29 13:24:10.622809+00
3d1b7778-c1e7-441c-8b7d-a960905a60f4	2025-05-24 16:35:45.699806+00	ILLENIUM	\N	2025-05-29 13:24:10.622809+00
3fdcac8b-2588-49ce-886c-72bbbc28451c	2025-05-24 16:35:45.699806+00	ILLOH	\N	2025-05-29 13:24:10.622809+00
97bf79fe-873b-4005-8364-d574a08f4c85	2025-05-24 16:35:45.699806+00	ILLUSTRIUS BLACKS	\N	2025-05-29 13:24:10.622809+00
ddf46fa6-804a-4c37-a03c-08c022d65aa0	2025-05-24 16:35:45.699806+00	IMANBEK	\N	2025-05-29 13:24:10.622809+00
08d31650-2e18-4f13-8a9c-44dbfca857e4	2025-05-24 16:35:45.699806+00	IMANU	\N	2025-05-29 13:24:10.622809+00
6d2e0fde-274e-4623-9225-ba4695be19fe	2025-05-24 16:35:45.699806+00	INDIGO DE SOUZA	\N	2025-05-29 13:24:10.622809+00
78a69844-c181-4f55-827d-2c6ca105e44b	2025-05-24 16:35:45.699806+00	INDIRA PAGANOTTO	\N	2025-05-29 13:24:10.622809+00
53e0f622-d7e5-4630-b272-ac7e2273253b	2025-05-24 16:35:45.699806+00	INFEKT	\N	2025-05-29 13:24:10.622809+00
9fcbc682-609c-4a78-8310-683c5d84d63c	2025-05-24 16:35:45.699806+00	INNELER	\N	2025-05-29 13:24:10.622809+00
a07f5ed9-b0a1-4750-bc38-dffcb7366885	2025-05-24 16:35:45.699806+00	INSOMNIAC RECORDS	\N	2025-05-29 13:24:10.622809+00
c963a7b8-51bd-4ac8-a02c-ceb24f9bc21e	2025-05-24 16:35:45.699806+00	INTEGRATE	\N	2025-05-29 13:24:10.622809+00
deec7ef9-3016-4cea-8a72-cdc20bd84de9	2025-05-24 16:35:45.699806+00	INZO	\N	2025-05-29 13:24:10.622809+00
8fec8e05-6881-427b-9807-c85c2650c5e9	2025-05-24 16:35:45.699806+00	ION	\N	2025-05-29 13:24:10.622809+00
9fe0fb88-f3a1-41a3-8995-aa01785e1314	2025-05-24 16:35:45.699806+00	IRONHEART	\N	2025-05-29 13:24:10.622809+00
05409c9f-6b94-4f2b-ac42-f15e4f4f84ba	2025-05-24 16:35:45.699806+00	ISAIAH RASHAD	\N	2025-05-29 13:24:10.622809+00
49320755-137b-4140-81a4-7dd73d049f5e	2025-05-24 16:35:45.699806+00	ISDED	\N	2025-05-29 13:24:10.622809+00
a62c2114-96ff-46a6-bb1e-35dff083fc8a	2025-05-24 16:35:45.699806+00	IT HZ	\N	2025-05-29 13:24:10.622809+00
cfb93b76-9df9-4359-8757-384063e62ef2	2025-05-24 16:35:45.699806+00	IVY LAB	\N	2025-05-29 13:24:10.622809+00
6b388aa7-d187-4a49-a9bb-c86667fe2630	2025-05-24 16:35:45.699806+00	IYA TERRA	\N	2025-05-29 13:24:10.622809+00
09bb0c45-d2fe-4be7-a96a-142ec93757bb	2025-05-24 16:35:45.699806+00	J ADJODHA	\N	2025-05-29 13:24:10.622809+00
c0be858d-0940-414c-bf29-559b7d2d063e	2025-05-24 16:35:45.699806+00	J. COLE	\N	2025-05-29 13:24:10.622809+00
7bfdaf37-0fe8-4413-b5ae-d46d3e52cc03	2025-05-24 16:35:45.699806+00	J. WORRA	\N	2025-05-29 13:24:10.622809+00
4345c75c-3308-4bb4-8ccb-94bbe08e82f2	2025-05-24 16:35:45.699806+00	J.GILL	\N	2025-05-29 13:24:10.622809+00
2ca8fdc4-7275-4670-b097-e91f0302c877	2025-05-24 16:35:45.699806+00	JACK ANTONOFF	\N	2025-05-29 13:24:10.622809+00
ca45f92d-53ea-437d-94fa-91d4b77886e6	2025-05-24 16:35:45.699806+00	JACK HARLOW	\N	2025-05-29 13:24:10.622809+00
585cd700-d5cc-46fd-a480-fcc5e7872192	2025-05-24 16:35:45.699806+00	JACKIICHAN	\N	2025-05-29 13:24:10.622809+00
d4bc2ec6-4a61-4fa3-837d-4a1021397a48	2025-05-24 16:35:45.699806+00	JADE CICADA	\N	2025-05-29 13:24:10.622809+00
9e5899d6-ad8b-4a43-9fc6-ec062ad6fbe5	2025-05-24 16:35:45.699806+00	JAENGA	\N	2025-05-29 13:24:10.622809+00
0f77ca7c-2a7e-4087-b831-619552b7faae	2025-05-24 16:35:45.699806+00	JAI WOLF	\N	2025-05-29 13:24:10.622809+00
2db02ed0-8caa-4c8a-8358-8a8f19bc2324	2025-05-24 16:35:45.699806+00	JAKE WESLEY ROGERS	\N	2025-05-29 13:24:10.622809+00
2962e59d-97cb-4201-bc14-d2ed1d23f197	2025-05-24 16:35:45.699806+00	JAMES HYPE	\N	2025-05-29 13:24:10.622809+00
82a03310-ea2a-4ab2-a27a-a571d1ef2d61	2025-05-24 16:35:45.699806+00	JAMES MASLOW	\N	2025-05-29 13:24:10.622809+00
7080bf03-2e49-47e2-beee-0e1c0b5e7514	2025-05-24 16:35:45.699806+00	JAMES PATRICK	\N	2025-05-29 13:24:10.622809+00
3bb26417-d1ca-4038-8722-24ee6bd5f9cb	2025-05-24 16:35:45.699806+00	JAML	\N	2025-05-29 13:24:10.622809+00
312b7a85-2a3c-4c22-ab67-c6b164c34c76	2025-05-24 16:35:45.699806+00	JANTSEN	\N	2025-05-29 13:24:10.622809+00
5f1be115-c6f5-4fdb-8f4a-b865d3780b54	2025-05-24 16:35:45.699806+00	JANTSEN B2B SUBDOCTA	\N	2025-05-29 13:24:10.622809+00
db9a0d67-d6b2-4af7-95a1-7912f98179bb	2025-05-24 16:35:45.699806+00	JAPANESE BREAKFAST	\N	2025-05-29 13:24:10.622809+00
4007c31b-3e4e-401e-8f1e-5e8642bd60f3	2025-05-24 16:35:45.699806+00	JARREAU VANDAL	\N	2025-05-29 13:24:10.622809+00
61990013-5f7d-4c0c-b793-8d760010a3b9	2025-05-24 16:35:45.699806+00	JASON ROSS	\N	2025-05-29 13:24:10.622809+00
2efa59a7-80de-414c-9510-1a5ddf5a2024	2025-05-24 16:35:45.699806+00	JAUZ	\N	2025-05-29 13:24:10.622809+00
fa1f583b-6172-4b69-afdf-29337f8916a5	2025-05-24 16:35:45.699806+00	JAYDA G	\N	2025-05-29 13:24:10.622809+00
032f8fe8-3b19-4c7e-a3fb-dd00b3ec0bfe	2025-05-24 16:35:45.699806+00	JEANIE	\N	2025-05-29 13:24:10.622809+00
e6c30b71-20ab-4bdd-81c8-51f79b261ee5	2025-05-24 16:35:45.699806+00	JENNY VOSS	\N	2025-05-29 13:24:10.622809+00
8bfce10a-6950-4bfa-8b68-0ca1b4dca892	2025-05-24 16:35:45.699806+00	JEREMY SOLE	\N	2025-05-29 13:24:10.622809+00
7084b55a-e480-4acd-8d09-36c84650cc4a	2025-05-24 16:35:45.699806+00	JEREMY SOLE & NICKODEMUS	\N	2025-05-29 13:24:10.622809+00
18a8a37e-2d00-42eb-97f5-a873cc7aac51	2025-05-24 16:35:45.699806+00	JERRO	\N	2025-05-29 13:24:10.622809+00
d27e480f-cc25-41ed-9735-f567ab491884	2025-05-24 16:35:45.699806+00	JESSICA AUDIFFRED	\N	2025-05-29 13:24:10.622809+00
ac0ff6c3-1374-4230-8ee6-a0f81c547c1d	2025-05-24 16:35:45.699806+00	JESSIE MURPH	\N	2025-05-29 13:24:10.622809+00
ceab264d-8e08-4e84-99ae-f248a09cdda6	2025-05-24 16:35:45.699806+00	JGBCB	\N	2025-05-29 13:24:10.622809+00
563fdd7c-2832-4829-86b0-c56fae9fdc56	2025-05-24 16:35:45.699806+00	JIV	\N	2025-05-29 13:24:10.622809+00
11d3a85d-5437-4933-bed0-0a17a3cab3a0	2025-05-24 16:35:45.699806+00	JOANNA MAGIK	\N	2025-05-29 13:24:10.622809+00
2a6a4ace-f706-46f2-8507-6ecd7cbfc5af	2025-05-24 16:35:45.699806+00	JOE BIG	\N	2025-05-29 13:24:10.622809+00
c88a0380-cd4f-46b3-b5ea-190be70f0547	2025-05-24 16:35:45.699806+00	JOE HERTLER & THE RAINBOW SEEKERS	\N	2025-05-29 13:24:10.622809+00
a8d19105-61df-45d1-bcbb-4e4e27f2af1d	2025-05-24 16:35:45.699806+00	JOE MARCINEK BAND	\N	2025-05-29 13:24:10.622809+00
9e9428a9-f35b-481b-a723-d43bba972e47	2025-05-24 16:35:45.699806+00	JOE RUSSO’S ALMOST DEAD	\N	2025-05-29 13:24:10.622809+00
689ea791-d860-42e3-81bb-fe9297e4b50c	2025-05-24 16:35:45.699806+00	JOEL CORRY	\N	2025-05-29 13:24:10.622809+00
9cbfe670-90d1-4a7c-92ce-4c3041366b5f	2025-05-24 16:35:45.699806+00	JOHN O’CALLAGHAN	\N	2025-05-29 13:24:10.622809+00
d742e29c-5255-48e3-be0c-fdea57ab4cd2	2025-05-24 16:35:45.699806+00	JOHN SUMMIT	\N	2025-05-29 13:24:10.622809+00
545bdf2e-900c-4b6f-a6c8-eaa75b490138	2025-05-24 16:35:45.699806+00	JOLUCA	\N	2025-05-29 13:24:10.622809+00
f05a3773-5847-4f8d-b0d2-706f0004e5cd	2025-05-24 16:35:45.699806+00	JON CASEY	\N	2025-05-29 13:24:10.622809+00
1b1eda98-5517-4ba7-8ed8-1034a602b541	2025-05-24 16:35:45.699806+00	JON HOPKINS	\N	2025-05-29 13:24:10.622809+00
12ace4a0-0f2a-4f26-a263-aacec1ef562e	2025-05-24 16:35:45.699806+00	JON STICKLEY TRIO	\N	2025-05-29 13:24:10.622809+00
c6fb811a-bb22-4f67-8251-521723a4a0a4	2025-05-24 16:35:45.699806+00	JORDNMOODY	\N	2025-05-29 13:24:10.622809+00
8fdd9459-2070-4728-baf0-8198a0ad22ce	2025-05-24 16:35:45.699806+00	JORZA	\N	2025-05-29 13:24:10.622809+00
b801b40b-6ddc-4c7e-96cc-6e4802043bba	2025-05-24 16:35:45.699806+00	JOSH TEED	\N	2025-05-29 13:24:10.622809+00
64147f74-e2e7-48cf-9587-6a5e1f64debb	2025-05-24 16:35:45.699806+00	JOSHWA	\N	2025-05-29 13:24:10.622809+00
d4c079e4-13a8-4990-8926-198c51d66f07	2025-05-24 16:35:45.699806+00	JOY OLADOKUN	\N	2025-05-29 13:24:10.622809+00
d82d122d-eb93-42d2-b07c-a95378d2eb20	2025-05-24 16:35:45.699806+00	JOYCE MUNIZ	\N	2025-05-29 13:24:10.622809+00
84779002-0010-473f-853c-58f1feb3f962	2025-05-24 16:35:45.699806+00	JOYRYDE	\N	2025-05-29 13:24:10.622809+00
59d65faa-0699-4f00-ac4c-e6bbe2c41405	2025-05-24 16:35:45.699806+00	JPOD	\N	2025-05-29 13:24:10.622809+00
e114cf87-7ded-4b01-8fcb-2e3be7ae874e	2025-05-24 16:35:45.699806+00	JSTJR	\N	2025-05-29 13:24:10.622809+00
26b0ffdd-b40d-4777-aab2-296ae7821604	2025-05-24 16:35:45.699806+00	JUDAH & THE LION	\N	2025-05-29 13:24:10.622809+00
2468a1e8-204a-4932-9774-c23b53268ca9	2025-05-24 16:35:45.699806+00	JUELZ	\N	2025-05-29 13:24:10.622809+00
c5ba753c-51f9-452b-ac02-02b30ead8af2	2025-05-24 16:35:45.699806+00	JUJU BEATS	\N	2025-05-29 13:24:10.622809+00
6f51a206-c4d9-44f7-8203-da80dc1c5cdd	2025-05-24 16:35:45.699806+00	JUNGLE	\N	2025-05-29 13:24:10.622809+00
9c4c2751-2f32-468e-a11f-8b1c93af25d6	2025-05-24 16:35:45.699806+00	JUST A GENT	\N	2025-05-29 13:24:10.622809+00
e4764c64-576d-4ed1-98cc-cb863403b29e	2025-05-24 16:35:45.699806+00	JUST JOHN	\N	2025-05-29 13:24:10.622809+00
f22ff238-23f1-4d27-b0bd-2dfffac2afc0	2025-05-24 16:35:45.699806+00	JUSTIN MARTIN	\N	2025-05-29 13:24:10.622809+00
b00e49df-b748-4374-a29e-c11657070268	2025-05-24 16:35:45.699806+00	JUSTTJOKAY	\N	2025-05-29 13:24:10.622809+00
2baf9e72-2c8c-400a-b9a1-4fd4b8433ef5	2025-05-24 16:35:45.699806+00	JVNA	\N	2025-05-29 13:24:10.622809+00
785994a2-7134-483b-877f-19f90bdd946b	2025-05-24 16:35:45.699806+00	K?D	\N	2025-05-29 13:24:10.622809+00
e9e631cb-585c-457d-96dd-883e90e66ecb	2025-05-24 16:35:45.699806+00	K.L.O	\N	2025-05-29 13:24:10.622809+00
07cf30fc-f00e-45b3-9113-f9723205aa3e	2025-05-24 16:35:45.699806+00	KAGE KOSTER	\N	2025-05-29 13:24:10.622809+00
8ffde8e3-db31-4c05-8241-3dbf70bde4fe	2025-05-24 16:35:45.699806+00	KAHN	\N	2025-05-29 13:24:10.622809+00
ba008b4f-e338-4871-b5f4-51172f4b7288	2025-05-24 16:35:45.699806+00	KAHN & NEEK	\N	2025-05-29 13:24:10.622809+00
252c760a-14e8-4ce3-986f-9ca5f840f0b5	2025-05-24 16:35:45.699806+00	KAI WACHI	\N	2025-05-29 13:24:10.622809+00
a6185993-82dc-446a-85e8-296b02b639df	2025-05-24 16:35:45.699806+00	KAIVON	\N	2025-05-29 13:24:10.622809+00
71b7c5ce-1cb5-4b3b-85a0-26ca4932ba18	2025-05-24 16:35:45.699806+00	KALYA SCINTILLA & EVE OLUTION	\N	2025-05-29 13:24:10.622809+00
860efe2b-d39a-41f8-b859-7fa3229e5162	2025-05-24 16:35:45.699806+00	KAMANI	\N	2025-05-29 13:24:10.622809+00
365af052-2178-4fb3-8c21-66eb5813697e	2025-05-24 16:35:45.699806+00	KAMI	\N	2025-05-29 13:24:10.622809+00
d9fd453f-6f79-451c-8875-b8d32d215772	2025-05-24 16:35:45.699806+00	KANDOR	\N	2025-05-29 13:24:10.622809+00
aa8bedfb-d5f1-417b-946b-6256cd45b121	2025-05-24 16:35:45.699806+00	KAREEM ALI	\N	2025-05-29 13:24:10.622809+00
2a748092-8078-4c29-96fa-70be8884cbc8	2025-05-24 16:35:45.699806+00	KAREEM MARTIN	\N	2025-05-29 13:24:10.622809+00
335e1345-af28-4a13-ae15-31d36a0ba707	2025-05-24 16:35:45.699806+00	KARL BLAU	\N	2025-05-29 13:24:10.622809+00
c356c876-6d53-4b3b-a805-19b345efbe7d	2025-05-24 16:35:45.699806+00	KASABLANCA	\N	2025-05-29 13:24:10.622809+00
be1b8197-cc45-43c9-bcf8-43c6f63d9809	2025-05-24 16:35:45.699806+00	KASBO	\N	2025-05-29 13:24:10.622809+00
e9fe9f0f-a2b6-40af-95bd-d441202aaa36	2025-05-24 16:35:45.699806+00	KASKADE	\N	2025-05-29 13:24:10.622809+00
e9ffaa45-7c8f-4474-9222-6f474736ffa6	2025-05-24 16:35:45.699806+00	KATALYST	\N	2025-05-29 13:24:10.622809+00
b3b43ac6-092f-4d74-82e5-3534cd3ec4d4	2025-05-24 16:35:45.699806+00	KAYA PROJECT	\N	2025-05-29 13:24:10.622809+00
4193e0ca-35f5-4756-a95b-61ac20254098	2025-05-24 16:35:45.699806+00	KAYTRANADA	\N	2025-05-29 13:24:10.622809+00
c894d221-9e53-492d-b01b-0b461cb34976	2025-05-24 16:35:45.699806+00	KAYZO	\N	2025-05-29 13:24:10.622809+00
f4022914-83f4-4a13-8eb7-9f039d700f3e	2025-05-24 16:35:45.699806+00	KEERO	\N	2025-05-29 13:24:10.622809+00
29e600de-ecdf-4016-9ccf-4b7955499d1e	2025-05-24 16:35:45.699806+00	KELLER WILLIAMS’ GRATEFUL GRASS	\N	2025-05-29 13:24:10.622809+00
f4b40c84-0311-421a-b0ab-0bafb1dfbb9d	2025-05-24 16:35:45.699806+00	KELSEY RAY	\N	2025-05-29 13:24:10.622809+00
c3802d39-05af-4912-b496-518bc4ba5659	2025-05-24 16:35:45.699806+00	KENDOLL	\N	2025-05-29 13:24:10.622809+00
9e42e837-1aa4-44c0-94dd-6c9efcf1841a	2025-05-24 16:35:45.699806+00	KENNY MASON	\N	2025-05-29 13:24:10.622809+00
cf3a4113-c8fe-4f84-a5cf-63854917c954	2025-05-24 16:35:45.699806+00	KEOTA	\N	2025-05-29 13:24:10.622809+00
2725c727-3ef6-4da4-869b-1a41cfdc254c	2025-05-24 16:35:45.699806+00	KERALA DUST	\N	2025-05-29 13:24:10.622809+00
861cb7bb-1399-482f-bd06-50343bcf56c5	2025-05-24 16:35:45.699806+00	KHIVA	\N	2025-05-29 13:24:10.622809+00
bf445b8e-1f74-42a6-add2-e7d1955bcb06	2025-05-24 16:35:45.699806+00	KHROMATA	\N	2025-05-29 13:24:10.622809+00
8ca681d6-9b0a-4b31-be98-35d6082407cf	2025-05-24 16:35:45.699806+00	KHRUANGBIN	\N	2025-05-29 13:24:10.622809+00
b85fa711-5e5b-4c9d-81d8-3fa9cd4bb112	2025-05-24 16:35:45.699806+00	KICK THE CAT	\N	2025-05-29 13:24:10.622809+00
0ca86403-f8df-41dc-a445-e8456de1031a	2025-05-24 16:35:45.699806+00	KILAMANZEGO	\N	2025-05-29 13:24:10.622809+00
384422a0-a8bc-4100-9ff1-fc34c2a8489a	2025-05-24 16:35:45.699806+00	KIMONTHY LEARY	\N	2025-05-29 13:24:10.622809+00
1463ddc1-59c7-498c-bf1d-b681dc4d0238	2025-05-24 16:35:45.699806+00	KING GIZZARD & THE LIZARD WIZARD	\N	2025-05-29 13:24:10.622809+00
2475c58e-f952-4ab9-95bf-d73096fc20cd	2025-05-24 16:35:45.699806+00	KIRBY BRIGHT	\N	2025-05-29 13:24:10.622809+00
026a01a0-8f2c-45af-917a-803f518e5371	2025-05-24 16:35:45.699806+00	KIRBYBRIGHT	\N	2025-05-29 13:24:10.622809+00
5cc2673c-878f-403e-badd-e9024df28377	2025-05-24 16:35:45.699806+00	KITCHEN DWELLERS	\N	2025-05-29 13:24:10.622809+00
e63da2ab-5f65-4970-b327-dadcd6522226	2025-05-24 16:35:45.699806+00	KITO	\N	2025-05-29 13:24:10.622809+00
28319684-b252-49d5-b696-e54127c1d5a2	2025-05-24 16:35:45.699806+00	KJ SAWKA	\N	2025-05-29 13:24:10.622809+00
45697f00-24c5-4955-8bba-35edc3c7972e	2025-05-24 16:35:45.699806+00	KLIPEE	\N	2025-05-29 13:24:10.622809+00
727fcb31-cb8f-48ce-a0d4-60b4511d9bea	2025-05-24 16:35:45.699806+00	KLL SMTH	\N	2025-05-29 13:24:10.622809+00
ba198c41-1eea-46c2-bf48-e0ec92076f57	2025-05-24 16:35:45.699806+00	KLO	\N	2025-05-29 13:24:10.622809+00
8d70afd4-c541-4a0e-9fa4-40b0271f4d69	2025-05-24 16:35:45.699806+00	KOAN SOUND	\N	2025-05-29 13:24:10.622809+00
1857ee4b-5a03-43a6-b723-a4092e926c51	2025-05-24 16:35:45.699806+00	KOFFEE	\N	2025-05-29 13:24:10.622809+00
5a2466e7-012d-4a17-820d-4d6c45099bd4	2025-05-24 16:35:45.699806+00	KOGNITIVE	\N	2025-05-29 13:24:10.622809+00
47e0528e-a7f5-4d6f-a6cc-167b5891efde	2025-05-24 16:35:45.699806+00	KOMPANY	\N	2025-05-29 13:24:10.622809+00
96c57b71-4898-42c3-aa13-c691586fcb06	2025-05-24 16:35:45.699806+00	KOMUZ	\N	2025-05-29 13:24:10.622809+00
538dc872-8a4f-4674-a51d-784c0f5cb470	2025-05-24 16:35:45.699806+00	KORRA THE KID	\N	2025-05-29 13:24:10.622809+00
69ea956a-deb2-4ea1-b622-2fd6fbe17349	2025-05-24 16:35:45.699806+00	KOVEN	\N	2025-05-29 13:24:10.622809+00
4062de1e-4ab7-494b-843f-1a37a7095bcc	2025-05-24 16:35:45.699806+00	KRAFTY KUTS	\N	2025-05-29 13:24:10.622809+00
a47f5e4d-62d4-4d9f-821c-323acd2643bf	2025-05-24 16:35:45.699806+00	KRAKINOV	\N	2025-05-29 13:24:10.622809+00
b2a56112-cf8b-479b-9987-77673f58c9e7	2025-05-24 16:35:45.699806+00	KRAKYN	\N	2025-05-29 13:24:10.622809+00
bb1168c4-8a4f-4948-9365-8a1b5af351ad	2025-05-24 16:35:45.699806+00	KREAM	\N	2025-05-29 13:24:10.622809+00
20b52df8-806e-4a4c-8a81-fff0f0922397	2025-05-24 16:35:45.699806+00	KREATION	\N	2025-05-29 13:24:10.622809+00
4650aadf-afc4-45fe-869a-b9bf3fd93a47	2025-05-24 16:35:45.699806+00	KREWX	\N	2025-05-29 13:24:10.622809+00
16aff4a1-23b3-4b7c-a0e5-43d392c07b07	2025-05-24 16:35:45.699806+00	KSHMR	\N	2025-05-29 13:24:10.622809+00
33b58bf3-4619-45f5-b5ae-5a906beb04f0	2025-05-24 16:35:45.699806+00	KTREK	\N	2025-05-29 13:24:10.622809+00
ec853c01-eb7a-489c-ac88-0ecda0a1c99b	2025-05-24 16:35:45.699806+00	KUDA	\N	2025-05-29 13:24:10.622809+00
1fcb7094-4a68-4f92-a3df-34307b185f7d	2025-05-24 16:35:45.699806+00	KUH NIVES	\N	2025-05-29 13:24:10.622809+00
9716d4d4-ff97-44d0-a504-aca329702972	2025-05-24 16:35:45.699806+00	KUMARION	\N	2025-05-29 13:24:10.622809+00
facbb095-7bc7-4250-ac23-646e4786d0aa	2025-05-24 16:35:45.699806+00	KUMARION B2B REAPER	\N	2025-05-29 13:24:10.622809+00
c3cf192b-5ad3-420f-83df-e765e0db65d5	2025-05-24 16:35:45.699806+00	KURSA	\N	2025-05-29 13:24:10.622809+00
b40db790-8301-4933-9da0-ebfaacaa9c44	2025-05-24 16:35:45.699806+00	KURSK	\N	2025-05-29 13:24:10.622809+00
7f6dda01-4515-493e-977d-1023be8402d7	2025-05-24 16:35:45.699806+00	KYLE HOLLINGSWORTH BAND	\N	2025-05-29 13:24:10.622809+00
103a5e25-5df9-41bc-9757-25042c553246	2025-05-24 16:35:45.699806+00	KYLE KINCH	\N	2025-05-29 13:24:10.622809+00
a7b0a3ad-c1c4-43be-87a3-8b39145b02a7	2025-05-24 16:35:45.699806+00	KYLE WALKER	\N	2025-05-29 13:24:10.622809+00
cec80172-3ba6-402c-857f-b7785d1d12b0	2025-05-24 16:35:45.699806+00	KYLE WATSON	\N	2025-05-29 13:24:10.622809+00
f370d0f4-355d-4f66-ac70-a8d51318ef78	2025-05-24 16:35:45.699806+00	KYMERA	\N	2025-05-29 13:24:10.622809+00
cc198201-9a63-4f2c-8593-c1aa96489649	2025-05-24 16:35:45.699806+00	KYRAL BANKO	\N	2025-05-29 13:24:10.622809+00
4b682315-4f77-41fd-8d10-38a8bd17f44e	2025-05-24 16:35:45.699806+00	KYRAL X BANKO	\N	2025-05-29 13:24:10.622809+00
4f26d6fc-3081-4b24-9e82-b9e694110272	2025-05-24 16:35:45.699806+00	KYTAMI & PHONIK OPS	\N	2025-05-29 13:24:10.622809+00
1d6f2e6e-2f34-4821-af8f-599c899c7682	2025-05-24 16:35:45.699806+00	L’ESPECIAL	\N	2025-05-29 13:24:10.622809+00
5ece337d-5bdb-4503-aba0-406d2633b4a1	2025-05-24 16:35:45.699806+00	LAB GROUP	\N	2025-05-29 13:24:10.622809+00
c0cc791c-ee5e-4ac5-b6de-634853bb8d28	2025-05-24 16:35:45.699806+00	LABRAT	\N	2025-05-29 13:24:10.622809+00
93a1e5ec-6896-454f-88e9-12968f14a468	2025-05-24 16:35:45.699806+00	LADY FAITH B2B DARKSIDERZ B2B ROB GEE	\N	2025-05-29 13:24:10.622809+00
53aeb7c2-67b7-471e-841b-c5c75ae600c6	2025-05-24 16:35:45.699806+00	LAMORN	\N	2025-05-29 13:24:10.622809+00
338f949b-74fb-4612-b9c0-c4becf4abad3	2025-05-24 16:35:45.699806+00	LANE 8	\N	2025-05-29 13:24:10.622809+00
bc5fe307-a044-4975-97e9-d57a592b5e47	2025-05-24 16:35:45.699806+00	LANY	\N	2025-05-29 13:24:10.622809+00
781c08ce-0e1f-432e-bea5-c85b68ee0ffb	2025-05-24 16:35:45.699806+00	LASER ASSASSINS	\N	2025-05-29 13:24:10.622809+00
25ed8042-d9b1-4ba7-bea1-f762af0880d6	2025-05-24 16:35:45.699806+00	LAST HEROES	\N	2025-05-29 13:24:10.622809+00
cf210b0c-208f-4bbc-837e-f60d6788974e	2025-05-24 16:35:45.699806+00	LASTLINGS	\N	2025-05-29 13:24:10.622809+00
d8a3b2d2-50ee-4a10-b1a6-0115ba66faaa	2025-05-24 16:35:45.699806+00	LASZEWO	\N	2025-05-29 13:24:10.622809+00
bacd4dec-3419-4f7f-ae17-60125260935a	2025-05-24 16:35:45.699806+00	LAUREN FLAX	\N	2025-05-29 13:24:10.622809+00
08b5d3e4-5720-443e-ab15-d79d4cbab070	2025-05-24 16:35:45.699806+00	LAYZ	\N	2025-05-29 13:24:10.622809+00
51362c49-c616-44f4-a741-683e2652bb1f	2025-05-24 16:35:45.699806+00	LAZY SYRUP ORCHESTRA	\N	2025-05-29 13:24:10.622809+00
4c6a0509-9fc3-4c56-a5e3-f1af77feeb06	2025-05-24 16:35:45.699806+00	LB & KONFUSION	\N	2025-05-29 13:24:10.622809+00
4b9f272b-052a-47a0-89ac-45aef5a3e71a	2025-05-24 16:35:45.699806+00	LE YOUTH	\N	2025-05-29 13:24:10.622809+00
ec37d954-6cb2-4c64-a687-dbf2db42b7c6	2025-05-24 16:35:45.699806+00	LEAH CULVER	\N	2025-05-29 13:24:10.622809+00
ef7a2090-fa22-4fff-9852-2af7ebec0542	2025-05-24 16:35:45.699806+00	LEE FOSS	\N	2025-05-29 13:24:10.622809+00
fe1360e4-f7a3-4346-af7d-fc4e14a8c46d	2025-05-24 16:35:45.699806+00	LEET	\N	2025-05-29 13:24:10.622809+00
26f66005-e5a6-4d3f-9879-bb4b4b987d2a	2025-05-24 16:35:45.699806+00	LEFTOVER SALMON	\N	2025-05-29 13:24:10.622809+00
8284d338-97b0-40ba-9e4a-be91edebf254	2025-05-24 16:35:45.699806+00	LEON BRIDGES	\N	2025-05-29 13:24:10.622809+00
f7e847ff-fb32-42f9-a545-e906f6b9ed0e	2025-05-24 16:35:45.699806+00	LEOTRIX	\N	2025-05-29 13:24:10.622809+00
004fe51b-516c-491d-bb91-769e48290d99	2025-05-24 16:35:45.699806+00	LESPECIAL	\N	2025-05-29 13:24:10.622809+00
4e053804-3dd0-47b7-a556-77713429260b	2025-05-24 16:35:45.699806+00	LETTUCE	\N	2025-05-29 13:24:10.622809+00
27426ded-0f5b-4cf4-9441-b5544617e8df	2025-05-24 16:35:45.699806+00	LETYAGO	\N	2025-05-29 13:24:10.622809+00
1c32cf44-79e3-4c2a-b52a-8f7d33454d97	2025-05-24 16:35:45.699806+00	LEVEL UP	\N	2025-05-29 13:24:10.622809+00
d14f9cd6-e156-4ad3-ac8c-4f599b5c575c	2025-05-24 16:35:45.699806+00	LEVITATION JONES	\N	2025-05-29 13:24:10.622809+00
f66973c8-dec0-4239-b117-dd7d1fa518c0	2025-05-24 16:35:45.699806+00	LIA LOTUS	\N	2025-05-29 13:24:10.622809+00
9951d4a2-9ac8-4c33-803d-41ec9d5bf811	2025-05-24 16:35:45.699806+00	LIAM FITZGERALD	\N	2025-05-29 13:24:10.622809+00
ba5d5e51-51e7-426f-ad72-51690652cbf2	2025-05-24 16:35:45.699806+00	LICK	\N	2025-05-29 13:24:10.622809+00
55e617a2-4393-4646-8f1c-328d29f6f2cb	2025-05-24 16:35:45.699806+00	LIGHTCODE (BY LSDREAM)	\N	2025-05-29 13:24:10.622809+00
a706fd80-f609-44ca-8011-7b8615b47836	2025-05-24 16:35:45.699806+00	LIL TEXAS	\N	2025-05-29 13:24:10.622809+00
d560460c-f263-4036-9824-311aea377c0e	2025-05-24 16:35:45.699806+00	LINK	\N	2025-05-29 13:24:10.622809+00
35db87bb-3b21-4698-9eec-2c9f1e1f67c0	2025-05-24 16:35:45.699806+00	LIONE	\N	2025-05-29 13:24:10.622809+00
bfb14608-98bb-4fe1-ab02-dae187113328	2025-05-24 16:35:45.699806+00	LIQUID SNAILS	\N	2025-05-29 13:24:10.622809+00
d4078249-02ee-4c40-9dfc-281dc176f165	2025-05-24 16:35:45.699806+00	LIQUID STRANGER	\N	2025-05-29 13:24:10.622809+00
74156f52-825c-4176-a1db-52f2ce49e322	2025-05-24 16:35:45.699806+00	LIQUID STRANGER (2 SETS)	\N	2025-05-29 13:24:10.622809+00
b14f3f69-f29e-4695-9c0e-1b933c30f02d	2025-05-24 16:35:45.699806+00	LIQUID STRANGER B2B LSDREAM	\N	2025-05-29 13:24:10.622809+00
fcae8ac1-1774-4dc5-bba8-7c78cbadbde3	2025-05-24 16:35:45.699806+00	LITA LOTUS	\N	2025-05-29 13:24:10.622809+00
aaf4e353-7d28-4ddf-9bed-11ce34818a8e	2025-05-24 16:35:45.699806+00	LITLEBIRD	\N	2025-05-29 13:24:10.622809+00
941d2bc4-b083-448f-b3f3-3728c041a188	2025-05-24 16:35:45.699806+00	LITTLE FEAT	\N	2025-05-29 13:24:10.622809+00
68a73dd0-2cc0-4cfe-9b46-7ef82423429f	2025-05-24 16:35:45.699806+00	LITTLE SIMZ	\N	2025-05-29 13:24:10.622809+00
69dd65ee-6cc0-4afd-9f8c-7b04537e1e60	2025-05-24 16:35:45.699806+00	LITTLE SNAKE.	\N	2025-05-29 13:24:10.622809+00
a6378d39-1dae-48ad-b7a5-436645587b7b	2025-05-24 16:35:45.699806+00	LITTLE STRANGER	\N	2025-05-29 13:24:10.622809+00
e37998ad-c42f-44aa-b715-3bf49ce210f9	2025-05-24 16:35:45.699806+00	LIZZY JANE	\N	2025-05-29 13:24:10.622809+00
7443dde3-67e7-4f8a-826e-6b833af2868f	2025-05-24 16:35:45.699806+00	LLLLNNNN	\N	2025-05-29 13:24:10.622809+00
290cb0fe-dee2-44b2-b512-3276622c457c	2025-05-24 16:35:45.699806+00	LNY TNZ	\N	2025-05-29 13:24:10.622809+00
addcc7ee-9487-4f7a-8f61-bcfec37e55b8	2025-05-24 16:35:45.699806+00	LOADED GUNN	\N	2025-05-29 13:24:10.622809+00
a56f50e7-807f-4be3-af0e-bf0d3753fac6	2025-05-24 16:35:45.699806+00	LOCO DICE	\N	2025-05-29 13:24:10.622809+00
0d914036-6aee-4e81-be7c-bb2283efaa16	2025-05-24 16:35:45.699806+00	LONE DRUM	\N	2025-05-29 13:24:10.622809+00
9be56472-74ab-4bee-8e46-b4e5e66f6d46	2025-05-24 16:35:45.699806+00	LONGWALKSHORTDOCK	\N	2025-05-29 13:24:10.622809+00
773467e2-b967-4126-846c-8aef879ff049	2025-05-24 16:35:45.699806+00	LORD HURON	\N	2025-05-29 13:24:10.622809+00
dd3e0fb6-41e0-46d0-9fbd-a87af308090f	2025-05-24 16:35:45.699806+00	LOST KINGS	\N	2025-05-29 13:24:10.622809+00
8c6af885-8f1d-4501-a17d-0acff06a948f	2025-05-24 16:35:45.699806+00	LOST WANDERING	\N	2025-05-29 13:24:10.622809+00
4a31decb-552f-4303-b5d4-819da9d50e5e	2025-05-24 16:35:45.699806+00	LOTEMP	\N	2025-05-29 13:24:10.622809+00
ab348720-f5d5-415a-84b2-0aaf2159089f	2025-05-24 16:35:45.699806+00	LOTUS	\N	2025-05-29 13:24:10.622809+00
68b2e3f4-4219-4936-b441-283715e9a69e	2025-05-24 16:35:45.699806+00	LOU PHELPS	\N	2025-05-29 13:24:10.622809+00
1b75fa3c-8c48-47ad-9152-fc137abaf03f	2025-05-24 16:35:45.699806+00	LOUD LUXURY	\N	2025-05-29 13:24:10.622809+00
202a8795-ae75-4844-8dd6-0afb871136d9	2025-05-24 16:35:45.699806+00	LOUIS FUTON	\N	2025-05-29 13:24:10.622809+00
79c846d0-e8cc-40e0-b143-de03487536fb	2025-05-24 16:35:45.699806+00	LOUIS THE CHILD	\N	2025-05-29 13:24:10.622809+00
9e0e63b4-2690-45c4-b56f-f776f1be5f8f	2025-05-24 16:35:45.699806+00	LP GIOBBI	\N	2025-05-29 13:24:10.622809+00
af19c3d0-4797-46bb-8ad5-cf818a693ac3	2025-05-24 16:35:45.699806+00	LSDREAM	\N	2025-05-29 13:24:10.622809+00
5886feec-d58b-42e5-8f56-642adccbb467	2025-05-24 16:35:45.699806+00	LUBELSKI	\N	2025-05-29 13:24:10.622809+00
9a788bc4-4c55-4de0-b154-07ca5fcc80a0	2025-05-24 16:35:45.699806+00	LUCATI	\N	2025-05-29 13:24:10.622809+00
71ef17d9-09c1-4de4-826e-48509f72c954	2025-05-24 16:35:45.699806+00	LUCID VISION	\N	2025-05-29 13:24:10.622809+00
23f708f1-18ea-4a25-be24-feba206f52e2	2025-05-24 16:35:45.699806+00	LUCII	\N	2025-05-29 13:24:10.622809+00
64bba2c7-71ef-41e7-bc0d-820d33cd018c	2025-05-24 16:35:45.699806+00	LUCILLE CROFT	\N	2025-05-29 13:24:10.622809+00
5ceb08e9-1ff3-4d30-bc50-b136cbe9b565	2025-05-24 16:35:45.699806+00	LUCKY RABBIT	\N	2025-05-29 13:24:10.622809+00
edfc7ecc-0184-4f02-92ab-e72ac260b503	2025-05-24 16:35:45.699806+00	LUDACRIS	\N	2025-05-29 13:24:10.622809+00
bc4eab0b-7f6c-4bd6-8f47-5da0181ef19f	2025-05-24 16:35:45.699806+00	LUKE ANDY	\N	2025-05-29 13:24:10.622809+00
0fa38312-7209-41c9-ad86-562e816ec5f9	2025-05-24 16:35:45.699806+00	LUMINYST	\N	2025-05-29 13:24:10.622809+00
2bd83f26-4603-473e-93e3-9dae841dfcc7	2025-05-24 16:35:45.699806+00	LUNA MAR	\N	2025-05-29 13:24:10.622809+00
8fea9501-c029-449d-93ae-6452c83f2693	2025-05-24 16:35:45.699806+00	LUNAR FIRE	\N	2025-05-29 13:24:10.622809+00
ac230f73-56a2-4a7f-ae5a-fbdbe9a6dc9b	2025-05-24 16:35:45.699806+00	LUPA	\N	2025-05-29 13:24:10.622809+00
607102bb-bfde-424a-a4c3-1dd3b79f04a8	2025-05-24 16:35:45.699806+00	LUTTRELL	\N	2025-05-29 13:24:10.622809+00
d5b919d9-5c22-4260-9677-bec0458ca527	2025-05-24 16:35:45.699806+00	LUX VELOUR	\N	2025-05-29 13:24:10.622809+00
2eb51647-373d-4a11-9a30-dbe1a4ba0789	2025-05-24 16:35:45.699806+00	LUZCID	\N	2025-05-29 13:24:10.622809+00
8fb7a51d-7211-4caa-b7ba-5e15d7e84d13	2025-05-24 16:35:45.699806+00	MACHETE	\N	2025-05-29 13:24:10.622809+00
1adb9f6d-bed5-4a9a-8d84-904d29af3c51	2025-05-24 16:35:45.699806+00	MACHINE GUN KELLY	\N	2025-05-29 13:24:10.622809+00
96cac18b-f93c-454c-ba01-b4ba605774c8	2025-05-24 16:35:45.699806+00	MACKY GEE	\N	2025-05-29 13:24:10.622809+00
6312489f-ceef-4e77-ade2-79058bba4f55	2025-05-24 16:35:45.699806+00	MAD DOG	\N	2025-05-29 13:24:10.622809+00
67ef2fb2-4272-46ba-a197-68b62cb6ff5b	2025-05-24 16:35:45.699806+00	MADAM X	\N	2025-05-29 13:24:10.622809+00
2b03801f-952a-4956-bf78-e055da97d490	2025-05-24 16:35:45.699806+00	MADDY O’NEAL	\N	2025-05-29 13:24:10.622809+00
c8c63d49-5965-4585-aacb-5ed9f3f02ba5	2025-05-24 16:35:45.699806+00	MADEON	\N	2025-05-29 13:24:10.622809+00
d2a08ccd-e68b-48e0-bb57-320021495945	2025-05-24 16:35:45.699806+00	MAGELLAN	\N	2025-05-29 13:24:10.622809+00
76116345-e564-40c7-a0ee-3a2516b33a36	2025-05-24 16:35:45.699806+00	MAGGIE ROSE	\N	2025-05-29 13:24:10.622809+00
e2e4224b-4758-438c-8e0e-b12be2c5b9cf	2025-05-24 16:35:45.699806+00	MAGIC BEANS	\N	2025-05-29 13:24:10.622809+00
6f74b288-2b07-4933-9100-1a25ba1a35bd	2025-05-24 16:35:45.699806+00	MAGIC CITY HIPPIES	\N	2025-05-29 13:24:10.622809+00
bc95cfb8-9a22-4c60-bcbb-50c12e9cf398	2025-05-24 16:35:45.699806+00	MAGNOLIA BOULEVARD	\N	2025-05-29 13:24:10.622809+00
9b4d19d7-8423-49eb-9a4a-526cfe29a3fd	2025-05-24 16:35:45.699806+00	MAJESTIC	\N	2025-05-29 13:24:10.622809+00
c6da0e6a-63c7-49ec-874b-3074c9221031	2025-05-24 16:35:45.699806+00	MALAA	\N	2025-05-29 13:24:10.622809+00
39218df5-8857-4e8e-a69a-36214b8e9d96	2025-05-24 16:35:45.699806+00	MANIC FOCUS	\N	2025-05-29 13:24:10.622809+00
a5e98200-c2e1-4267-baed-7431346dbde9	2025-05-24 16:35:45.699806+00	MANOLO	\N	2025-05-29 13:24:10.622809+00
d3c064cc-6ffd-4dbd-8980-7d3d827a25ba	2025-05-24 16:35:45.699806+00	MANTHOM PHENACE	\N	2025-05-29 13:24:10.622809+00
376e2cef-c010-43b4-bdbc-79df539f9d1c	2025-05-24 16:35:45.699806+00	MARAUDA	\N	2025-05-29 13:24:10.622809+00
9881646b-0c18-4c93-a988-1ea00372dc47	2025-05-24 16:35:45.699806+00	MARC E. BASSY	\N	2025-05-29 13:24:10.622809+00
f0efedf2-57e4-4680-8f61-758b5eb44d25	2025-05-24 16:35:45.699806+00	MARC REBILLET	\N	2025-05-29 13:24:10.622809+00
ebb3d528-5ac9-403f-b7e8-5d9dd72c5a2c	2025-05-24 16:35:45.699806+00	MARCO BENEVENTO	\N	2025-05-29 13:24:10.622809+00
7e93e16e-79ae-4fed-9661-f560f3255a4e	2025-05-24 16:35:45.699806+00	MARK FARINA	\N	2025-05-29 13:24:10.622809+00
c800fb7d-596a-4c1e-bdc0-180a8815c332	2025-05-24 16:35:45.699806+00	MARK WOODYARD	\N	2025-05-29 13:24:10.622809+00
505e56c8-8220-46df-80b0-edb7a0675adc	2025-05-24 16:35:45.699806+00	MARKUS SCHULZ	\N	2025-05-29 13:24:10.622809+00
3d15be01-bf72-40d7-9e09-8989697615b3	2025-05-24 16:35:45.699806+00	MARLO	\N	2025-05-29 13:24:10.622809+00
68ec9882-5939-41f0-b04a-c1a1f9a284b6	2025-05-24 16:35:45.699806+00	MAROC	\N	2025-05-29 13:24:10.622809+00
ad3c77ee-74b2-45c8-a252-d9220d3bd31d	2025-05-24 16:35:45.699806+00	MARQUES WYATT	\N	2025-05-29 13:24:10.622809+00
c1637557-15d4-4312-b5f2-bc9d44d1093f	2025-05-24 16:35:45.699806+00	MARSH	\N	2025-05-29 13:24:10.622809+00
b0ab419e-0746-4241-bb61-46d6bee43664	2025-05-24 16:35:45.699806+00	MARTIN GARRIX	\N	2025-05-29 13:24:10.622809+00
c74aaf86-cc19-4665-ba73-f93cf7f8219e	2025-05-24 16:35:45.699806+00	MARTIN IKIN	\N	2025-05-29 13:24:10.622809+00
eafd4e50-c68b-4c42-b5e3-885ede0c690c	2025-05-24 16:35:45.699806+00	MARUDA	\N	2025-05-29 13:24:10.622809+00
b998a6b5-407b-408c-8332-36d631792dd1	2025-05-24 16:35:45.699806+00	MARY DROPPINZ	\N	2025-05-29 13:24:10.622809+00
9def33c2-b8ea-4a0a-8a1f-b8dca2bbffbf	2025-05-24 16:35:45.699806+00	MASEGO	\N	2025-05-29 13:24:10.622809+00
09d30b64-ecdc-4d8b-b8cf-ed0f7e10fd79	2025-05-24 16:35:45.699806+00	MASON MAYNARD	\N	2025-05-29 13:24:10.622809+00
9f6f6dd1-02ba-474e-b1cf-814eefec2373	2025-05-24 16:35:45.699806+00	MAT ZO	\N	2025-05-29 13:24:10.622809+00
fbb9c5ed-7689-4799-9459-952bf500ff45	2025-05-24 16:35:45.699806+00	MATHENY	\N	2025-05-29 13:24:10.622809+00
9808a89a-46b0-47d0-8571-1a183ae03d0e	2025-05-24 16:35:45.699806+00	MATHEW JOHNSON	\N	2025-05-29 13:24:10.622809+00
7a8c8faf-3448-44b7-b0cc-2d1d5d341a4e	2025-05-24 16:35:45.699806+00	MATRODA	\N	2025-05-29 13:24:10.622809+00
cf500e9d-2ca3-4e79-8dc2-153f5ef687d5	2025-05-24 16:35:45.699806+00	MATT FAX	\N	2025-05-29 13:24:10.622809+00
17ec4e7f-4351-44db-ad83-6be1eb2136a3	2025-05-24 16:35:45.699806+00	MAX	\N	2025-05-29 13:24:10.622809+00
a16cb691-ac9f-4192-9071-bbb34c3b2ed4	2025-05-24 16:35:45.699806+00	MAX COOPER	\N	2025-05-29 13:24:10.622809+00
8f8f347d-f1b1-4208-8ca9-923b1eb2fef8	2025-05-24 16:35:45.699806+00	MAXFIELD	\N	2025-05-29 13:24:10.622809+00
6d097565-f179-48ef-9504-be0764a70728	2025-05-24 16:35:45.699806+00	MAXXUS	\N	2025-05-29 13:24:10.622809+00
6589f0a4-ae28-4837-9109-e176dac13fb0	2025-05-24 16:35:45.699806+00	MAYA JANE COLES	\N	2025-05-29 13:24:10.622809+00
787257fb-c889-4874-b204-1bdb9b8cf5d1	2025-05-24 16:35:45.699806+00	MC WORD	\N	2025-05-29 13:24:10.622809+00
e1aeebae-5de3-4b93-bb0c-8d014928af69	2025-05-24 16:35:45.699806+00	MEDICINE PLACE	\N	2025-05-29 13:24:10.622809+00
befad7e5-c1cb-4ea2-8375-b9edec307930	2025-05-24 16:35:45.699806+00	MEDISIN	\N	2025-05-29 13:24:10.622809+00
a05fbd50-d696-4ccb-b5bc-14c72f65e01d	2025-05-24 16:35:45.699806+00	MEDUSO	\N	2025-05-29 13:24:10.622809+00
cb185428-1fc7-4662-acd1-0ab78c1c6f1b	2025-05-24 16:35:45.699806+00	MEGAN HAMILTON	\N	2025-05-29 13:24:10.622809+00
f87856f2-e8b0-4287-b44d-01ac84e2e191	2025-05-24 16:35:45.699806+00	MELI RODRIGUEZ	\N	2025-05-29 13:24:10.622809+00
00237ca6-0247-451d-9eac-d72534b3d5ef	2025-05-24 16:35:45.699806+00	MELODY LINES	\N	2025-05-29 13:24:10.622809+00
c257b902-b559-4250-91fd-c1629fde825f	2025-05-24 16:35:45.699806+00	MEMBA	\N	2025-05-29 13:24:10.622809+00
887985a8-52e1-4dd2-aeba-40e827071380	2025-05-24 16:35:45.699806+00	MEMOREX	\N	2025-05-29 13:24:10.622809+00
11ab2bff-caf6-4824-b632-1c3fde9886c1	2025-05-24 16:35:45.699806+00	MERSIV	\N	2025-05-29 13:24:10.622809+00
1ab79c35-2148-494d-89a4-a854969c8869	2025-05-24 16:35:45.699806+00	MESO	\N	2025-05-29 13:24:10.622809+00
25119b3b-0c23-4f6c-adec-845e424b05a3	2025-05-24 16:35:45.699806+00	METAFLOOR	\N	2025-05-29 13:24:10.622809+00
fe82093d-cdf6-4b65-b01d-8539f0c72b12	2025-05-24 16:35:45.699806+00	MIANE	\N	2025-05-29 13:24:10.622809+00
1e7dfc6e-7c9b-4718-8de4-05a53016a804	2025-05-24 16:35:45.699806+00	MICHAEL RED	\N	2025-05-29 13:24:10.622809+00
712e373a-9371-4a67-be0d-1c45ff8ea0ae	2025-05-24 16:35:45.699806+00	MICHIGANDER	\N	2025-05-29 13:24:10.622809+00
6b01ad12-4c59-42ae-9eef-43c90ff75d39	2025-05-24 16:35:45.699806+00	MICKMAN	\N	2025-05-29 13:24:10.622809+00
1e7a1c37-1bd2-44bb-9b1a-95c7690a47f2	2025-05-24 16:35:45.699806+00	MIDNIGHT PANDA	\N	2025-05-29 13:24:10.622809+00
6bc7399d-6f9c-4811-9359-c52323a556bf	2025-05-24 16:35:45.699806+00	MIDNIGHT TYRANNOSAURUS	\N	2025-05-29 13:24:10.622809+00
bb2250f6-5cbc-453b-9c2e-f225a9bce57b	2025-05-24 16:35:45.699806+00	MIGUEL MIGS	\N	2025-05-29 13:24:10.622809+00
46671519-7eb1-4451-876c-a0ff539febfe	2025-05-24 16:35:45.699806+00	MIJA	\N	2025-05-29 13:24:10.622809+00
7dfaeed2-6362-4ddd-a5d0-ecc45efbf455	2025-05-24 16:35:45.699806+00	MIKE’S REVENGE	\N	2025-05-29 13:24:10.622809+00
0f191d2c-b5ca-42e0-83a3-8b472235c0fd	2025-05-24 16:35:45.699806+00	MIKERAT	\N	2025-05-29 13:24:10.622809+00
80e67008-c787-4e3d-8f3f-c92f180c544d	2025-05-24 16:35:45.699806+00	MIKEY LION B2B LEE REYNOLDS	\N	2025-05-29 13:24:10.622809+00
86f3d9c1-f06c-4a72-a9e2-8c69332d79eb	2025-05-24 16:35:45.699806+00	MIKEY THUNDER	\N	2025-05-29 13:24:10.622809+00
19926942-7796-4b2f-99ce-fdfbe7513017	2025-05-24 16:35:45.699806+00	MIKRODOT	\N	2025-05-29 13:24:10.622809+00
c0e9819a-162e-431d-8601-3b1a5021dd3d	2025-05-24 16:35:45.699806+00	MILAND	\N	2025-05-29 13:24:10.622809+00
fa4c7ce9-a8c7-4054-92f1-25d1b51d9791	2025-05-24 16:35:45.699806+00	MILES HARRIS & THE DEEP CUTS	\N	2025-05-29 13:24:10.622809+00
f32ff7aa-aa69-42bd-ad47-10348303ef12	2025-05-24 16:35:45.699806+00	MILES OVER MOUNTAINS	\N	2025-05-29 13:24:10.622809+00
fee01170-9124-4e3f-bf9e-1ed9fa2f822c	2025-05-24 16:35:45.699806+00	MILK + HONEY	\N	2025-05-29 13:24:10.622809+00
170f359d-af16-4ab8-a8e0-53c7e7320de0	2025-05-24 16:35:45.699806+00	MIME	\N	2025-05-29 13:24:10.622809+00
59f687c2-f08a-4425-8089-935d9b415048	2025-05-24 16:35:45.699806+00	MINDBLUR	\N	2025-05-29 13:24:10.622809+00
365fbca8-b972-4a01-8858-78db774f88b7	2025-05-24 16:35:45.699806+00	MINDCHATTER	\N	2025-05-29 13:24:10.622809+00
603f3a87-ec98-4c33-b56c-3cb1a85b1fa4	2025-05-24 16:35:45.699806+00	MINDEX	\N	2025-05-29 13:24:10.622809+00
4675fb22-1159-4183-b3fa-4561f7df57e4	2025-05-24 16:35:45.699806+00	MINNESOTA	\N	2025-05-29 13:24:10.622809+00
4b7af9ec-1412-4bc6-9139-09293dc15c1a	2025-05-24 16:35:45.699806+00	MINNESOTA B2B BUKU	\N	2025-05-29 13:24:10.622809+00
f575cb1f-11e1-4b55-b4c4-20869d9fd2e3	2025-05-24 16:35:45.699806+00	MIRA	\N	2025-05-29 13:24:10.622809+00
99e98f9a-5270-476b-a83f-9f21be48b42f	2025-05-24 16:35:45.699806+00	MIRAJA	\N	2025-05-29 13:24:10.622809+00
18207c7d-7daa-430b-b9de-4d6123609e2e	2025-05-24 16:35:45.699806+00	MIRANDUBZ	\N	2025-05-29 13:24:10.622809+00
cb5ec085-20c4-4136-bb8e-cda801290b0d	2025-05-24 16:35:45.699806+00	MISTAH	\N	2025-05-29 13:24:10.622809+00
2d78726b-3549-4675-9433-ca233ec3a528	2025-05-24 16:35:45.699806+00	MISTAH DILL	\N	2025-05-29 13:24:10.622809+00
b711ae04-9a20-4349-b06a-ee3c94a2765b	2025-05-24 16:35:45.699806+00	MITIS	\N	2025-05-29 13:24:10.622809+00
d3222acd-5ae6-4361-be33-cc0e4d4bc401	2025-05-24 16:35:45.699806+00	MIXEDMIND	\N	2025-05-29 13:24:10.622809+00
ec544433-ec77-451d-bd94-1a3c9fa54c3c	2025-05-24 16:35:45.699806+00	MIZE	\N	2025-05-29 13:24:10.622809+00
919d834b-ef20-4ec2-9268-196518ca1cc7	2025-05-24 16:35:45.699806+00	MJ LEE	\N	2025-05-29 13:24:10.622809+00
598a7536-6fae-4ce8-96b5-5b242d9b149b	2025-05-24 16:35:45.699806+00	MK	\N	2025-05-29 13:24:10.622809+00
e9557bd4-c39c-4b36-a8cc-84b0cc316c55	2025-05-24 16:35:45.699806+00	MLOTIK	\N	2025-05-29 13:24:10.622809+00
d3c74a65-6390-4abe-8f66-d4a01ee0130a	2025-05-24 16:35:45.699806+00	MO LOWDA & THE HUMBLE	\N	2025-05-29 13:24:10.622809+00
cfb7ddec-30f2-4dba-a1e9-c26bc35030d1	2025-05-24 16:35:45.699806+00	MOB TACTICS	\N	2025-05-29 13:24:10.622809+00
56adb76e-6c7f-4146-8688-2f40a9b92a08	2025-05-24 16:35:45.699806+00	MOE.	\N	2025-05-29 13:24:10.622809+00
bfa47f62-1041-49f5-ad6a-e7e103ece001	2025-05-24 16:35:45.699806+00	MOKSI	\N	2025-05-29 13:24:10.622809+00
1e1b003d-dfe2-4e17-b85a-e03e6766582b	2025-05-24 16:35:45.699806+00	MOLOKAI	\N	2025-05-29 13:24:10.622809+00
11186770-e165-4686-9e71-e609bc58be78	2025-05-24 16:35:45.699806+00	MONKEY TWERK	\N	2025-05-29 13:24:10.622809+00
c81bc7ba-58ea-4158-ac1e-2f09a8058c2e	2025-05-24 16:35:45.699806+00	MONOLINK	\N	2025-05-29 13:24:10.622809+00
ac0cb213-59a3-4f57-934d-aae53f1041a8	2025-05-24 16:35:45.699806+00	MONOPHONICS	\N	2025-05-29 13:24:10.622809+00
f9b7904a-27fc-48c8-96ee-763ffdead972	2025-05-24 16:35:45.699806+00	MONXX	\N	2025-05-29 13:24:10.622809+00
3b3e95b8-ee27-48a9-8ed5-d119722404aa	2025-05-24 16:35:45.699806+00	MOON TAXI	\N	2025-05-29 13:24:10.622809+00
e51a3034-7c6d-4e3f-8a46-15c07077adb9	2025-05-24 16:35:45.699806+00	MOONTRICKS	\N	2025-05-29 13:24:10.622809+00
b6cb2cd5-3843-4440-a9df-d667da5c9b97	2025-05-24 16:35:45.699806+00	MOORE KISMET	\N	2025-05-29 13:24:10.622809+00
5aaf8bc4-3c2f-4055-89de-8903b685d480	2025-05-24 16:35:45.699806+00	MOOREA MASA AND THE MOOD	\N	2025-05-29 13:24:10.622809+00
e852d461-1e60-4e5d-ab46-7a7b72c197ce	2025-05-24 16:35:45.699806+00	MORGIN MADISON	\N	2025-05-29 13:24:10.622809+00
1b087d21-adf0-4127-bd02-007abdafe0fb	2025-05-24 16:35:45.699806+00	MOSCOMAN	\N	2025-05-29 13:24:10.622809+00
220b733f-3fe5-4e0d-a4cc-5f11d013be08	2025-05-24 16:35:45.699806+00	MOSKI	\N	2025-05-29 13:24:10.622809+00
2cf0aaa0-c6b2-49d2-bf6a-8bae489b393c	2025-05-24 16:35:45.699806+00	MOUSAI	\N	2025-05-29 13:24:10.622809+00
a086100e-92d9-4f7a-a69d-82ea9e2661d3	2025-05-24 16:35:45.699806+00	MPORT	\N	2025-05-29 13:24:10.622809+00
ca7f3548-366d-4f15-9a78-69ea1815b877	2025-05-24 16:35:45.699806+00	MR. BILL	\N	2025-05-29 13:24:10.622809+00
56de60d8-4fca-4198-906b-590fa5653a3a	2025-05-24 16:35:45.699806+00	MR. CARMACK	\N	2025-05-29 13:24:10.622809+00
54820f61-0322-496d-a9c6-464584596e2f	2025-05-24 16:35:45.699806+00	MR. CARMACK (SUNSET SET)	\N	2025-05-29 13:24:10.622809+00
bc1a8b9f-6551-426e-819e-87039e51b001	2025-05-24 16:35:45.699806+00	MROTEK	\N	2025-05-29 13:24:10.622809+00
35a47437-1830-44d8-ac07-d9591aad419d	2025-05-24 16:35:45.699806+00	MS. MADA	\N	2025-05-29 13:24:10.622809+00
5c9d705b-4cf9-4fb6-9127-facbdcba1071	2025-05-24 16:35:45.699806+00	MT. JOY	\N	2025-05-29 13:24:10.622809+00
807ea831-23f5-407b-90e1-275907d092fd	2025-05-24 16:35:45.699806+00	MUMUKSHU	\N	2025-05-29 13:24:10.622809+00
f2ce7df6-52e5-4075-8639-525491b73c01	2025-05-24 16:35:45.699806+00	MUNCH	\N	2025-05-29 13:24:10.622809+00
6e56f751-5fac-4ca8-a6c2-3c480aa03ee5	2025-05-24 16:35:45.699806+00	MUNGION	\N	2025-05-29 13:24:10.622809+00
24d58d1a-2940-4ad6-ad0b-9d18fafab12a	2025-05-24 16:35:45.699806+00	MUNGO’S HIFI	\N	2025-05-29 13:24:10.622809+00
6e7b4451-e000-4ecd-8458-512fdd826e50	2025-05-24 16:35:45.699806+00	MURGE	\N	2025-05-29 13:24:10.622809+00
815e580a-a10e-422b-b826-aa4f992f04ee	2025-05-24 16:35:45.699806+00	MURKIRY	\N	2025-05-29 13:24:10.622809+00
dcafa973-5672-44a4-9724-3fc5f1da4759	2025-05-24 16:35:45.699806+00	MURKURY	\N	2025-05-29 13:24:10.622809+00
2b62d188-c0f0-4333-bb44-2e1a70fab6ae	2025-05-24 16:35:45.699806+00	MUST DIE!	\N	2025-05-29 13:24:10.622809+00
446bc4cc-da13-4b95-80f9-c134614d76e5	2025-05-24 16:35:45.699806+00	MUUS	\N	2025-05-29 13:24:10.622809+00
debd2e10-aafc-4320-afb5-dda6b27dc1dd	2025-05-24 16:35:45.699806+00	MUZI	\N	2025-05-29 13:24:10.622809+00
e721ae2c-791e-407f-9395-abab493ceb76	2025-05-24 16:35:45.699806+00	MY MORNING JACKET	\N	2025-05-29 13:24:10.622809+00
1150c144-3f69-46c2-99ad-716e1745fab0	2025-05-24 16:35:45.699806+00	MYSTERY HEADLINER	\N	2025-05-29 13:24:10.622809+00
61c44ee6-9276-420d-8ebf-5156e6716087	2025-05-24 16:35:45.699806+00	MYSTIC GRIZZLY	\N	2025-05-29 13:24:10.622809+00
32db9068-bdff-4ce4-8947-6207734fe4c7	2025-05-24 16:35:45.699806+00	MYSTIC STATE	\N	2025-05-29 13:24:10.622809+00
e1524bfa-4479-45a1-9504-9f90764112f5	2025-05-24 16:35:45.699806+00	MYTHM	\N	2025-05-29 13:24:10.622809+00
99b693ed-ebb6-42dd-972d-451063697279	2025-05-24 16:35:45.699806+00	MZG	\N	2025-05-29 13:24:10.622809+00
0ae63825-d3ea-4532-9acf-24dd8a727358	2025-05-24 16:35:45.699806+00	N-TYPE	\N	2025-05-29 13:24:10.622809+00
09545a12-4b06-43a8-99f7-0b431d7c0521	2025-05-24 16:35:45.699806+00	NALA	\N	2025-05-29 13:24:10.622809+00
c0340340-3f4e-4f8f-b75b-453be302fe2e	2025-05-24 16:35:45.699806+00	NATHANIEL RATELIFF & THE NIGHT SWEATS	\N	2025-05-29 13:24:10.622809+00
bc34db9a-95bc-44c4-87d2-f83f8332bd7e	2025-05-24 16:35:45.699806+00	NAUDIBLE	\N	2025-05-29 13:24:10.622809+00
24ea03fc-b584-44cf-ac39-89bcf16d7f66	2025-05-24 16:35:45.699806+00	NEAL FRANCIS	\N	2025-05-29 13:24:10.622809+00
9fac3230-e587-476a-bcf2-2b4197b43507	2025-05-24 16:35:45.699806+00	NECROMANCER	\N	2025-05-29 13:24:10.622809+00
e9e6ae51-5e98-4d41-aae1-c31ad170a73e	2025-05-24 16:35:45.699806+00	NECROMANGER	\N	2025-05-29 13:24:10.622809+00
1dcbf4a7-2d60-4611-b91e-11177b9b30df	2025-05-24 16:35:45.699806+00	NEIGHBOR	\N	2025-05-29 13:24:10.622809+00
05083e7c-073f-479b-b939-a998c7c026f9	2025-05-24 16:35:45.699806+00	NEIGHBOUR	\N	2025-05-29 13:24:10.622809+00
11da862e-b6fd-43cf-b4b7-75865a6115d6	2025-05-24 16:35:45.699806+00	NEIL FRANCES	\N	2025-05-29 13:24:10.622809+00
50cce836-6ad3-41f4-992b-bc002ef99fba	2025-05-24 16:35:45.699806+00	NEON STEVE	\N	2025-05-29 13:24:10.622809+00
f99618e3-fbb4-45a4-b59e-3ca3b37ec4ba	2025-05-24 16:35:45.699806+00	NERF THE WORLD	\N	2025-05-29 13:24:10.622809+00
358e6b08-ea14-4160-bc70-144f2be5df1c	2025-05-24 16:35:45.699806+00	NETSKY	\N	2025-05-29 13:24:10.622809+00
ff717242-bb7b-46af-9cfc-f5275a39a2c1	2025-05-24 16:35:45.699806+00	NEZ	\N	2025-05-29 13:24:10.622809+00
e8d7b591-d188-4845-a17b-06817b8ca577	2025-05-24 16:35:45.699806+00	NGHTMRE	\N	2025-05-29 13:24:10.622809+00
357c1fc6-1a87-445c-8f7b-e1270f6924ed	2025-05-24 16:35:45.699806+00	NICKY GENESIS	\N	2025-05-29 13:24:10.622809+00
25d77efe-0b32-4b6b-b4b5-14dd59e9fdf2	2025-05-24 16:35:45.699806+00	NICKY RAGE	\N	2025-05-29 13:24:10.622809+00
cff6c5e2-8d46-4dbb-a803-48b749fd2b23	2025-05-24 16:35:45.699806+00	NICOLE MOUDABER	\N	2025-05-29 13:24:10.622809+00
a86dafef-9ad5-4e19-8152-49a6d1a9fddb	2025-05-24 16:35:45.699806+00	NIGHT HERON	\N	2025-05-29 13:24:10.622809+00
6d6315b3-b36c-4a69-8f8c-7c43e0a8638d	2025-05-24 16:35:45.699806+00	NIKKI NAIR	\N	2025-05-29 13:24:10.622809+00
3b919f59-68a1-4105-8759-82480a3e3ce3	2025-05-24 16:35:45.699806+00	NIKO THE KID	\N	2025-05-29 13:24:10.622809+00
4fb66c1c-f795-4adf-b281-170def661514	2025-05-24 16:35:45.699806+00	NINA LAS VEGAS	\N	2025-05-29 13:24:10.622809+00
bfbbcf4c-1a4d-445d-a17a-2ef5e14f3c18	2025-05-24 16:35:45.699806+00	NITEBLOOM	\N	2025-05-29 13:24:10.622809+00
5b1cdd62-06a7-4c30-8912-6627e62c613d	2025-05-24 16:35:45.699806+00	NO MANA	\N	2025-05-29 13:24:10.622809+00
bf127b94-c967-4631-9c66-963e8c429618	2025-05-24 16:35:45.699806+00	NO MANA B2B EDDIE	\N	2025-05-29 13:24:10.622809+00
0b2e19ed-6d8f-4d8b-96a9-a3f65132b87d	2025-05-24 16:35:45.699806+00	NO THANKS	\N	2025-05-29 13:24:10.622809+00
87e3c41b-6f83-46f6-be60-8e2fc583d1a7	2025-05-24 16:35:45.699806+00	NOER THE BOY	\N	2025-05-29 13:24:10.622809+00
9dff0b80-ff0b-48b4-987e-130fd2224012	2025-05-24 16:35:45.699806+00	NOGA EREZ	\N	2025-05-29 13:24:10.622809+00
34826bfa-e788-4979-8e98-d29c784444a8	2025-05-24 16:35:45.699806+00	NOIZU	\N	2025-05-29 13:24:10.622809+00
3926d66f-7dd1-44e9-af1b-dc9462207861	2025-05-24 16:35:45.699806+00	NOLL	\N	2025-05-29 13:24:10.622809+00
3d24a7d7-6edb-4588-a67b-235d2224df4f	2025-05-24 16:35:45.699806+00	NORA EN PURE	\N	2025-05-29 13:24:10.622809+00
73629646-a622-4f56-9ae7-eb0bd6914c20	2025-05-24 16:35:45.699806+00	NOSTALGIX	\N	2025-05-29 13:24:10.622809+00
6a1f7214-91f2-4d90-8825-bffc0896ef48	2025-05-24 16:35:45.699806+00	NOTHING	\N	2025-05-29 13:24:10.622809+00
764420b0-c026-4cce-831f-3774a63030b2	2025-05-24 16:35:45.699806+00	NOTIXX	\N	2025-05-29 13:24:10.622809+00
fd8f48da-8a6c-4a15-9f52-a673a8b9fc0b	2025-05-24 16:35:45.699806+00	NOTLO	\N	2025-05-29 13:24:10.622809+00
d5bcb16f-ace7-48c4-9125-bb7b126282a3	2025-05-24 16:35:45.699806+00	NOTLÖ	\N	2025-05-29 13:24:10.622809+00
467195cf-cf1b-4994-8324-d6083edb4dc0	2025-05-24 16:35:45.699806+00	NTXC	\N	2025-05-29 13:24:10.622809+00
d9527b17-afbf-4972-8dd7-0f97c256bab2	2025-05-24 16:35:45.699806+00	NUMBER NIN6	\N	2025-05-29 13:24:10.622809+00
9904d470-5969-4ac2-be33-b2eaa1ab1061	2025-05-24 16:35:45.699806+00	NURKO	\N	2025-05-29 13:24:10.622809+00
b95e06f2-6341-4ada-8d88-ce0c760e8df0	2025-05-24 16:35:45.699806+00	NXSTY	\N	2025-05-29 13:24:10.622809+00
007cd0f4-a3eb-4601-8b60-da0a426d9c76	2025-05-24 16:35:45.699806+00	O-PRIME DELTA	\N	2025-05-29 13:24:10.622809+00
dc1b8d5c-d6b1-43f1-ab79-b9b8ba938c1f	2025-05-24 16:35:45.699806+00	OAKK	\N	2025-05-29 13:24:10.622809+00
71c1f4d2-6d67-44e8-801e-9a156b7de7e2	2025-05-24 16:35:45.699806+00	OBEYGREY	\N	2025-05-29 13:24:10.622809+00
1c307a80-ffed-4ff9-aed0-8e1cac6a7f28	2025-05-24 16:35:45.699806+00	OCTAVE CAT	\N	2025-05-29 13:24:10.622809+00
c157569a-5f9f-4641-9eb1-054e0965d84a	2025-05-24 16:35:45.699806+00	ODESZA	\N	2025-05-29 13:24:10.622809+00
f1475be9-7380-4d9c-941b-bee134b996e8	2025-05-24 16:35:45.699806+00	OF THE TREES	\N	2025-05-29 13:24:10.622809+00
5239c609-9152-4bac-893d-ae505a7ba315	2025-05-24 16:35:45.699806+00	OFFAIAH	\N	2025-05-29 13:24:10.622809+00
bce2618e-72da-4610-a72a-1d36f2047373	2025-05-24 16:35:45.699806+00	OG NIXIN	\N	2025-05-29 13:24:10.622809+00
f834bd0d-7a2a-4626-8390-f0be7fa523d4	2025-05-24 16:35:45.699806+00	OLAN	\N	2025-05-29 13:24:10.622809+00
97e9a419-b07a-44e5-b431-939dbc0de24e	2025-05-24 16:35:45.699806+00	OLD SHOE	\N	2025-05-29 13:24:10.622809+00
ffabd599-abc2-427c-b880-6648593c67b5	2025-05-24 16:35:45.699806+00	OLIVER HELDENS	\N	2025-05-29 13:24:10.622809+00
70ecbbb3-d239-4e8d-8d8c-f17f4d46a17f	2025-05-24 16:35:45.699806+00	OLIVERSE	\N	2025-05-29 13:24:10.622809+00
e8e7b6e8-8153-4363-a5e8-5eaf4219b1ff	2025-05-24 16:35:45.699806+00	ONE TRUE GOD	\N	2025-05-29 13:24:10.622809+00
b931e829-404a-4db8-a5bd-3f53e1c5465e	2025-05-24 16:35:45.699806+00	ONHELL	\N	2025-05-29 13:24:10.622809+00
316869b8-160d-47fd-8914-17fc8829e576	2025-05-24 16:35:45.699806+00	ONYVAA	\N	2025-05-29 13:24:10.622809+00
5eb26bf5-f16d-4c2f-8ee1-4597d693f6c2	2025-05-24 16:35:45.699806+00	OPIUO	\N	2025-05-29 13:24:10.622809+00
3f5c2b39-c712-465c-8d90-3e29a593cc57	2025-05-24 16:35:45.699806+00	OPIUO (SUNSET SET)	\N	2025-05-29 13:24:10.622809+00
9c8de23f-121c-468c-85d1-858b8e488262	2025-05-24 16:35:45.699806+00	OPTION4	\N	2025-05-29 13:24:10.622809+00
2f8f9e74-ccf4-4f4f-a741-809332f79845	2025-05-24 16:35:45.699806+00	ORENDA	\N	2025-05-29 13:24:10.622809+00
2d31c1a4-ba42-4c60-9dbb-5737a0ce81e8	2025-05-24 16:35:45.699806+00	OSMETIC	\N	2025-05-29 13:24:10.622809+00
3ecf5ac8-7337-463f-bba1-abd1ad6af605	2025-05-24 16:35:45.699806+00	OTICA	\N	2025-05-29 13:24:10.622809+00
aeddecfa-a3fd-4df4-9b55-683c9701a937	2025-05-24 16:35:45.699806+00	OTT.	\N	2025-05-29 13:24:10.622809+00
061ad762-e259-4ef8-86ec-3f339ea287ac	2025-05-24 16:35:45.699806+00	OUZA	\N	2025-05-29 13:24:10.622809+00
666f68ed-481d-46f5-a0d4-4bf96cdb3771	2025-05-24 16:35:45.699806+00	OVER EASY	\N	2025-05-29 13:24:10.622809+00
da5f8e20-0483-44cb-8d0f-77896f40eb27	2025-05-24 16:35:45.699806+00	OXFORD NOLAND	\N	2025-05-29 13:24:10.622809+00
2f1152a3-8107-40b3-a3dc-6edc6d9ab637	2025-05-24 16:35:45.699806+00	PANDAMONIUM	\N	2025-05-29 13:24:10.622809+00
354146be-0f98-481c-8fe8-625cfa087f62	2025-05-24 16:35:45.699806+00	PARALEVEN	\N	2025-05-29 13:24:10.622809+00
1f3eab58-c8f0-4de6-9705-75c1b22be936	2025-05-24 16:35:45.699806+00	PARTY PUPILS	\N	2025-05-29 13:24:10.622809+00
85c61c1c-b3c8-42f3-a76c-becb7d3c74d1	2025-05-24 16:35:45.699806+00	PASTRY	\N	2025-05-29 13:24:10.622809+00
b01c8762-3afd-47b5-8fd5-9fe213224be7	2025-05-24 16:35:45.699806+00	PATCHES	\N	2025-05-29 13:24:10.622809+00
bf2d1427-1ed4-4c5f-8160-b6ed4dfcdcd7	2025-05-24 16:35:45.699806+00	PATRICK DRONEY	\N	2025-05-29 13:24:10.622809+00
57c4ecc3-1024-4772-80f3-63e7f51a93c7	2025-05-24 16:35:45.699806+00	PAUL VAN DYK	\N	2025-05-29 13:24:10.622809+00
7d9b8637-f730-4a32-af68-42b5641902e8	2025-05-24 16:35:45.699806+00	PAULINE HERR	\N	2025-05-29 13:24:10.622809+00
8181707d-1ffd-4c8a-8e71-572d7bdfade1	2025-05-24 16:35:45.699806+00	PAULO VENTURA	\N	2025-05-29 13:24:10.622809+00
8be7c729-dba8-4a31-9cab-c2044988251b	2025-05-24 16:35:45.699806+00	PAV4N	\N	2025-05-29 13:24:10.622809+00
9dfa8f12-59ef-4ff7-81ad-476f98020cd5	2025-05-24 16:35:45.699806+00	PAWS	\N	2025-05-29 13:24:10.622809+00
9dbe2b64-32ab-401f-b586-ce04fa07bba3	2025-05-24 16:35:45.699806+00	PAX	\N	2025-05-29 13:24:10.622809+00
dcb49616-3db2-439e-8e94-c4eba88edfbd	2025-05-24 16:35:45.699806+00	PEEKABOO	\N	2025-05-29 13:24:10.622809+00
2c29f886-03ef-45f7-8ca1-aa1662b94bb8	2025-05-24 16:35:45.699806+00	PEEWHEE	\N	2025-05-29 13:24:10.622809+00
ad159239-b2e7-4ba5-abb6-27470e1abe64	2025-05-24 16:35:45.699806+00	PHANTOMS	\N	2025-05-29 13:24:10.622809+00
4c5325ac-f7b1-47ab-b3d1-7d5ce3535c55	2025-05-24 16:35:45.699806+00	PHASEONE	\N	2025-05-29 13:24:10.622809+00
14793f65-14f2-4380-b5ca-d7edf1be732f	2025-05-24 16:35:45.699806+00	PHEEL	\N	2025-05-29 13:24:10.622809+00
65f67e0c-79dd-4c6a-823a-297a3c2cf3d4	2025-05-24 16:35:45.699806+00	PHIBES	\N	2025-05-29 13:24:10.622809+00
f270d48e-6028-44e7-996d-a7d898ef4ac5	2025-05-24 16:35:45.699806+00	PHLO	\N	2025-05-29 13:24:10.622809+00
4269273d-5921-450a-97fe-db5449336756	2025-05-24 16:35:45.699806+00	PHONON	\N	2025-05-29 13:24:10.622809+00
9abf3f75-def2-4d27-9071-e4b30c481326	2025-05-24 16:35:45.699806+00	PHYDRA	\N	2025-05-29 13:24:10.622809+00
37073752-20ee-4368-a7b4-89f385216085	2025-05-24 16:35:45.699806+00	PHYPHR	\N	2025-05-29 13:24:10.622809+00
c362f168-4a5f-42e7-afa6-815b6f58a4ca	2025-05-24 16:35:45.699806+00	PIERCE	\N	2025-05-29 13:24:10.622809+00
eedfbc8f-8d95-4f39-b89d-2b26863680cd	2025-05-24 16:35:45.699806+00	PIGEONS PLAYING PING PONG	\N	2025-05-29 13:24:10.622809+00
f90a9c34-eacb-41a6-be56-0fbf1fd8a1a8	2025-05-24 16:35:45.699806+00	PINED & LOEB	\N	2025-05-29 13:24:10.622809+00
45e10ca9-c817-4415-ba77-ae203478bb64	2025-05-24 16:35:45.699806+00	PLANET OF THE DRUMS	\N	2025-05-29 13:24:10.622809+00
dd18342a-cf13-40e6-ad37-051d2f51d6cc	2025-05-24 16:35:45.699806+00	PLAYER DAVE	\N	2025-05-29 13:24:10.622809+00
29e8b120-6bbd-466d-8a91-7e5e31ea25f5	2025-05-24 16:35:45.699806+00	PLEASURE BASTARD	\N	2025-05-29 13:24:10.622809+00
8ad7f9f0-b3c9-4051-b1f0-140d38d01648	2025-05-24 16:35:45.699806+00	PLOYD	\N	2025-05-29 13:24:10.622809+00
7909764a-97a8-4912-b676-58f12cc9c052	2025-05-24 16:35:45.699806+00	PLSMA	\N	2025-05-29 13:24:10.622809+00
53c7a8c0-42ef-4cbe-a1f2-d6c748b45d7b	2025-05-24 16:35:45.699806+00	PNUMA	\N	2025-05-29 13:24:10.622809+00
e3bfb5ff-9b2f-4d2f-b5d4-738eecb395ea	2025-05-24 16:35:45.699806+00	PORTER ROBINSON	\N	2025-05-29 13:24:10.622809+00
8ba0aaf3-c67c-4fb0-88fc-9d180709821d	2025-05-24 16:35:45.699806+00	POSTAL	\N	2025-05-29 13:24:10.622809+00
423c61eb-61bc-463a-a560-3f80c95c4e0d	2025-05-24 16:35:45.699806+00	POTIONS	\N	2025-05-29 13:24:10.622809+00
22859431-df49-489a-a9df-1fde8be87f55	2025-05-24 16:35:45.699806+00	PRETTY PINK	\N	2025-05-29 13:24:10.622809+00
9b1276a3-3b23-4bbe-99c7-c8e63c2244e4	2025-05-24 16:35:45.699806+00	PRISMATIC	\N	2025-05-29 13:24:10.622809+00
1ca408d4-d22d-4497-aae7-c71110945471	2025-05-24 16:35:45.699806+00	PROJECT ASPECT	\N	2025-05-29 13:24:10.622809+00
fb1b4f4f-f46a-478d-8f17-3f133e4d2cc8	2025-05-24 16:35:45.699806+00	PROTIAL	\N	2025-05-29 13:24:10.622809+00
0ef7cb14-ac91-43a4-b0fc-9fb85a1073ce	2025-05-24 16:35:45.699806+00	PROTOJE	\N	2025-05-29 13:24:10.622809+00
1f125abf-8321-4048-a164-c92fbbb38567	2025-05-24 16:35:45.699806+00	PURITY RING	\N	2025-05-29 13:24:10.622809+00
477e2eff-f202-4617-8b4c-8c134eca5317	2025-05-24 16:35:45.699806+00	PUSCIFER	\N	2025-05-29 13:24:10.622809+00
0433b72e-5826-4ca1-a7a7-a12714c33c0b	2025-05-24 16:35:45.699806+00	PUSHLOOP	\N	2025-05-29 13:24:10.622809+00
be6143e5-73fa-4fdf-8643-948e798fc9a4	2025-05-24 16:35:45.699806+00	QRION	\N	2025-05-29 13:24:10.622809+00
049ee22b-3bd7-41be-bd2c-43bec9a51d9b	2025-05-24 16:35:45.699806+00	QRTR	\N	2025-05-29 13:24:10.622809+00
22ea35ff-f7b9-4925-a245-73b535ee8b62	2025-05-24 16:35:45.699806+00	QUINCHO	\N	2025-05-29 13:24:10.622809+00
848292c5-d0f3-4545-a89a-0be2b877cf16	2025-05-24 16:35:45.699806+00	QUINOA	\N	2025-05-29 13:24:10.622809+00
ccf84ad1-d7de-4393-a798-97f4da94f4b2	2025-05-24 16:35:45.699806+00	RAAKET	\N	2025-05-29 13:24:10.622809+00
1fc8224e-dcfc-4419-bfad-aec53fddba5d	2025-05-24 16:35:45.699806+00	RACHEL MONAE	\N	2025-05-29 13:24:10.622809+00
4e4b5162-35f2-4704-97da-00864a5660e6	2025-05-24 16:35:45.699806+00	RADER	\N	2025-05-29 13:24:10.622809+00
5e28fd14-fb4f-4d8d-b252-9522552ef793	2025-05-24 16:35:45.699806+00	RADICAL REDEMPTION	\N	2025-05-29 13:24:10.622809+00
5610d240-e6ac-4009-90f6-6ad5b464182e	2025-05-24 16:35:45.699806+00	RANGER TRUCCO	\N	2025-05-29 13:24:10.622809+00
71a7ac04-21b8-4c43-8c84-1a8087edb806	2025-05-24 16:35:45.699806+00	RAQUEL RODRIGUEZ	\N	2025-05-29 13:24:10.622809+00
f3a06d38-66fe-4693-9574-49622eb9493c	2025-05-24 16:35:45.699806+00	RATED R	\N	2025-05-29 13:24:10.622809+00
baa43c55-7964-4641-a10c-3d48b4687e61	2025-05-24 16:35:45.699806+00	RAVENSCOON	\N	2025-05-29 13:24:10.622809+00
09bcd870-e9c0-4e32-af0b-645558f64e44	2025-05-24 16:35:45.699806+00	RAY VOLPE	\N	2025-05-29 13:24:10.622809+00
aa842970-ec6d-42a0-bc4a-807050a097d5	2025-05-24 16:35:45.699806+00	REAPER	\N	2025-05-29 13:24:10.622809+00
e3e9f2a1-6e1a-45ca-98ba-c53344b617f5	2025-05-24 16:35:45.699806+00	REAPER B2B KUMARION	\N	2025-05-29 13:24:10.622809+00
aa0ef0e9-eac0-4873-a858-84ac5a35f57a	2025-05-24 16:35:45.699806+00	REDLIGHT	\N	2025-05-29 13:24:10.622809+00
5bee8471-d5b5-4d24-8f7a-9c27d8db0bb7	2025-05-24 16:35:45.699806+00	REDRUM	\N	2025-05-29 13:24:10.622809+00
8d99e846-c7be-4412-a04a-1cbdc5711210	2025-05-24 16:35:45.699806+00	REGARD	\N	2025-05-29 13:24:10.622809+00
a7b80a73-0813-4550-b6e3-78ad462880bf	2025-05-24 16:35:45.699806+00	RELATIVITY LOUNGE	\N	2025-05-29 13:24:10.622809+00
87d32ca9-9f88-4753-ba84-d933f574d60c	2025-05-24 16:35:45.699806+00	RELIQUARY	\N	2025-05-29 13:24:10.622809+00
2ff18040-9e55-4c78-b1da-2a7bb150dcf7	2025-05-24 16:35:45.699806+00	RESONANT LANGUAGE	\N	2025-05-29 13:24:10.622809+00
9f043d7f-99b4-4218-ada6-ffdd85a7b9dd	2025-05-24 16:35:45.699806+00	REST IN PIERCE	\N	2025-05-29 13:24:10.622809+00
59bfc74e-b955-493a-833e-709af8027a10	2025-05-24 16:35:45.699806+00	REVIVAL	\N	2025-05-29 13:24:10.622809+00
0d8c5611-e8e5-4a54-bb63-769fac4c7e87	2025-05-24 16:35:45.699806+00	REXX LIFE RAJ	\N	2025-05-29 13:24:10.622809+00
f139e000-eae6-497f-9d85-75f4711ab4f9	2025-05-24 16:35:45.699806+00	REZZ	\N	2025-05-29 13:24:10.622809+00
0a8748b6-9bfe-4755-a67a-d3cc38fc279f	2025-05-24 16:35:45.699806+00	RINZEN ·	\N	2025-05-29 13:24:10.622809+00
ffd5d1c9-76fd-4617-8528-a37c486f4321	2025-05-24 16:35:45.699806+00	RIOT TEN	\N	2025-05-29 13:24:10.622809+00
5793846d-0815-4ef9-afb1-0add3b8fbb30	2025-05-24 16:35:45.699806+00	RL GRIME	\N	2025-05-29 13:24:10.622809+00
479036a5-3e3f-4aca-97fd-5b35f9c725b0	2025-05-24 16:35:45.699806+00	RNÉ	\N	2025-05-29 13:24:10.622809+00
1e341c2f-83c2-4ffd-9bde-cb4b2dcae0f2	2025-05-24 16:35:45.699806+00	ROB GEE	\N	2025-05-29 13:24:10.622809+00
5d0619a5-2bc4-4652-831e-51a3146f315a	2025-05-24 16:35:45.699806+00	ROBERT PLANT	\N	2025-05-29 13:24:10.622809+00
e5e1b4e4-85ed-4296-8ba4-3db822fc3d5a	2025-05-24 16:35:45.699806+00	ROBIN TRISKELE	\N	2025-05-29 13:24:10.622809+00
52b8d7cd-d509-4bac-8583-cb4ea065fdaa	2025-05-24 16:35:45.699806+00	RODDY RICCH	\N	2025-05-29 13:24:10.622809+00
fd600eb3-5c72-453c-bb3e-ae7ccfcedd8b	2025-05-24 16:35:45.699806+00	ROHAAN	\N	2025-05-29 13:24:10.622809+00
93834a9b-64b4-45a8-a7a2-fa84b9de670b	2025-05-24 16:35:45.699806+00	ROHAN SOLO	\N	2025-05-29 13:24:10.622809+00
8add6e87-231c-4362-9fd6-02cda1ca4a6a	2025-05-24 16:35:45.699806+00	ROLE MODEL	\N	2025-05-29 13:24:10.622809+00
76a1a778-84d8-4e9c-a543-1730bda5071d	2025-05-24 16:35:45.699806+00	ROME IN SILVER	\N	2025-05-29 13:24:10.622809+00
a0584ddd-d534-477d-8041-80ae29eea0b3	2025-05-24 16:35:45.699806+00	ROOSEVELT COLLIER BAND	\N	2025-05-29 13:24:10.622809+00
be5c529b-1887-497f-ba30-b5feba5bf9e1	2025-05-24 16:35:45.699806+00	ROSSY	\N	2025-05-29 13:24:10.622809+00
c2d86a4e-5674-4df8-a27e-63bd23490591	2025-05-24 16:35:45.699806+00	RUBEN DE RONDE	\N	2025-05-29 13:24:10.622809+00
a30fb588-3c78-42a3-a618-dd9ed3620e26	2025-05-24 16:35:45.699806+00	RUDASHI	\N	2025-05-29 13:24:10.622809+00
aa6869e9-4a4c-436a-bbd7-031f811f964e	2025-05-24 16:35:45.699806+00	RUDIMENTAL	\N	2025-05-29 13:24:10.622809+00
a525a7d4-22e6-4224-86c5-9349d93073fc	2025-05-24 16:35:45.699806+00	RUMPUS	\N	2025-05-29 13:24:10.622809+00
2bafe727-92bb-4ced-baf5-2cf038228ea1	2025-05-24 16:35:45.699806+00	RUSKO	\N	2025-05-29 13:24:10.622809+00
f5bfec39-e447-4f18-a9c4-d52c25f4655e	2025-05-24 16:35:45.699806+00	RUSS LIQUID	\N	2025-05-29 13:24:10.622809+00
bc7c5d04-11e3-4775-8934-8b2be03ea053	2025-05-24 16:35:45.699806+00	S.P.O.R.E.	\N	2025-05-29 13:24:10.622809+00
0e00d521-5c01-4727-a383-36ff69a7c15e	2025-05-24 16:35:45.699806+00	SACRED CREAM	\N	2025-05-29 13:24:10.622809+00
39f74efb-dbb3-400f-86dd-ee6d941a7dd8	2025-05-24 16:35:45.699806+00	SACRED SNOW	\N	2025-05-29 13:24:10.622809+00
adfc4748-e24f-4717-9871-614c621b8abf	2025-05-24 16:35:45.699806+00	SAID THE SKY	\N	2025-05-29 13:24:10.622809+00
a5df90d4-c578-4d14-a1ea-4ef52413ac1b	2025-05-24 16:35:45.699806+00	SAKA	\N	2025-05-29 13:24:10.622809+00
ee38397a-e521-412c-9ec4-38dae46e3b9e	2025-05-24 16:35:45.699806+00	SAKA B2B FLORET LORET	\N	2025-05-29 13:24:10.622809+00
a0a92f5d-1126-4230-be66-483fb5b0e409	2025-05-24 16:35:45.699806+00	SALOME LE CHAT	\N	2025-05-29 13:24:10.622809+00
def8ef52-8aad-4dec-bc51-44256f24f1bb	2025-05-24 16:35:45.699806+00	SALTY	\N	2025-05-29 13:24:10.622809+00
2dcc1153-c761-4f90-a36f-6f5b39a14e13	2025-05-24 16:35:45.699806+00	SAM DIVINE	\N	2025-05-29 13:24:10.622809+00
9fd444b6-f9d6-4db4-ac26-b0ef06698559	2025-05-24 16:35:45.699806+00	SAM FELDT	\N	2025-05-29 13:24:10.622809+00
2a9c0fd9-e649-449d-94ab-bdab2a3e6fac	2025-05-24 16:35:45.699806+00	SAM WOLFE	\N	2025-05-29 13:24:10.622809+00
332f17bd-93f6-4a60-b95f-ec57f0fc957b	2025-05-24 16:35:45.699806+00	SAMA’ ABDULHADI	\N	2025-05-29 13:24:10.622809+00
af5bd8e9-2871-45e3-953b-b28f707f2da4	2025-05-24 16:35:45.699806+00	SAMI KNOX	\N	2025-05-29 13:24:10.622809+00
4340610a-0b92-4e17-8bba-cbab3991474b	2025-05-24 16:35:45.699806+00	SAMMY RAE & THE FRIENDS	\N	2025-05-29 13:24:10.622809+00
23bd7f0c-8400-41da-9460-e42af48f5cfe	2025-05-24 16:35:45.699806+00	SAN HOLO	\N	2025-05-29 13:24:10.622809+00
665eda89-520d-4096-9e17-4ebab3253999	2025-05-24 16:35:45.699806+00	SANGO	\N	2025-05-29 13:24:10.622809+00
6794bf28-6832-49ad-8bcd-93230e27faf8	2025-05-24 16:35:45.699806+00	SAQI	\N	2025-05-29 13:24:10.622809+00
51b7eddb-4765-4d71-80ab-616c58f0232c	2025-05-24 16:35:45.699806+00	SATSANG	\N	2025-05-29 13:24:10.622809+00
c8347d37-a45d-489d-8bcf-0010db6cd2cb	2025-05-24 16:35:45.699806+00	SATURNA	\N	2025-05-29 13:24:10.622809+00
6bcddc51-5906-4e89-a7a3-658ad8109b87	2025-05-24 16:35:45.699806+00	SAULE	\N	2025-05-29 13:24:10.622809+00
d2f232ab-6362-4ff4-af5a-d475a6de48f2	2025-05-24 16:35:45.699806+00	SAXSQUATCH	\N	2025-05-29 13:24:10.622809+00
d369f7bb-9b4c-4f55-a299-aa7ab1cc968d	2025-05-24 16:35:45.699806+00	SAYER	\N	2025-05-29 13:24:10.622809+00
0516f50f-11e4-42c8-9e4d-e825d139de7f	2025-05-24 16:35:45.699806+00	SCALES	\N	2025-05-29 13:24:10.622809+00
57968873-b939-48d9-938a-3dcdb0f0efa4	2025-05-24 16:35:45.699806+00	SCHALA	\N	2025-05-29 13:24:10.622809+00
6d659c72-9737-4704-989b-69ce33fa4211	2025-05-24 16:35:45.699806+00	SCHLOMO	\N	2025-05-29 13:24:10.622809+00
9f2e0762-0532-4f84-81ca-16b2874de4d1	2025-05-24 16:35:45.699806+00	SCHMOOP	\N	2025-05-29 13:24:10.622809+00
b3ba20a0-8ca5-4b1d-9ec3-ac39d79f231d	2025-05-24 16:35:45.699806+00	SCIENTIST	\N	2025-05-29 13:24:10.622809+00
671f1746-3950-4868-9397-760f3d2f4ba6	2025-05-24 16:35:45.699806+00	SCUBA	\N	2025-05-29 13:24:10.622809+00
5d526a46-566a-4072-a233-7960b8496ab6	2025-05-24 16:35:45.699806+00	SEAN MAJORS	\N	2025-05-29 13:24:10.622809+00
95ddd3ab-e850-49d2-b485-a0223393e583	2025-05-24 16:35:45.699806+00	SEBASTIAN PAUL	\N	2025-05-29 13:24:10.622809+00
6534de0c-bf84-48a5-a655-265098f844f8	2025-05-24 16:35:45.699806+00	SEBASTIAN VYDRA	\N	2025-05-29 13:24:10.622809+00
cd8741fb-0017-43e1-a9ed-1a59ed50011d	2025-05-24 16:35:45.699806+00	SÉBASTIEN LÉGER	\N	2025-05-29 13:24:10.622809+00
7e7c8140-e237-4717-9c12-e6c24eea8994	2025-05-24 16:35:45.699806+00	SECRET GUEST	\N	2025-05-29 13:24:10.622809+00
fe6b9fca-5e38-4ef3-86d5-c7519b8252be	2025-05-24 16:35:45.699806+00	SECRET RECIPE	\N	2025-05-29 13:24:10.622809+00
bb63b08a-91f8-4e78-8146-6af8d9b23590	2025-05-24 16:35:45.699806+00	SELASE & THE FAFA FAMILY	\N	2025-05-29 13:24:10.622809+00
6e7b50b0-c9f9-4dbd-8f77-53db12b0de6a	2025-05-24 16:35:45.699806+00	SEPPA	\N	2025-05-29 13:24:10.622809+00
368df9e1-c945-4de0-a71a-24279120bccf	2025-05-24 16:35:45.699806+00	SERGE DEVANT	\N	2025-05-29 13:24:10.622809+00
aa7672d5-d848-4351-b7b2-b363f4457c84	2025-05-24 16:35:45.699806+00	SETH TROXLER	\N	2025-05-29 13:24:10.622809+00
8de421d5-8326-4eb8-9841-73482086066a	2025-05-24 16:35:45.699806+00	SEVEN LIONS	\N	2025-05-29 13:24:10.622809+00
bbc928b2-37c2-484e-a098-cba93cec0c02	2025-05-24 16:35:45.699806+00	SFAM	\N	2025-05-29 13:24:10.622809+00
0a9549ed-7b6a-4bea-9155-93ba30f242d9	2025-05-24 16:35:45.699806+00	SG LEWIS	\N	2025-05-29 13:24:10.622809+00
6182adf1-683a-4d35-baa5-306f4cd169e5	2025-05-24 16:35:45.699806+00	SHADES	\N	2025-05-29 13:24:10.622809+00
9d818baa-ba35-4a09-a239-d641960d4b64	2025-05-24 16:35:45.699806+00	SHADOW SPIRIT	\N	2025-05-29 13:24:10.622809+00
6d97d81b-01c0-4c37-a28f-d2067f3e9509	2025-05-24 16:35:45.699806+00	SHANGHAI DOOM	\N	2025-05-29 13:24:10.622809+00
c88ed6f7-bf92-4615-aa57-4e350b785df0	2025-05-24 16:35:45.699806+00	SHARLITZ WEB	\N	2025-05-29 13:24:10.622809+00
f26d574e-cac9-473f-adbe-fcd33e846987	2025-05-24 16:35:45.699806+00	SHARPS	\N	2025-05-29 13:24:10.622809+00
4b04d34b-e3ac-4465-b913-737c66f96fb5	2025-05-24 16:35:45.699806+00	SHAWNA	\N	2025-05-29 13:24:10.622809+00
8036ff07-e607-4f16-823e-5c2c3b55dad2	2025-05-24 16:35:45.699806+00	SHEDBOIZ	\N	2025-05-29 13:24:10.622809+00
f8a0450e-b092-4453-a57c-5d3398fe07ab	2025-05-24 16:35:45.699806+00	SHERM	\N	2025-05-29 13:24:10.622809+00
617e2dcb-165a-4d69-a4ae-2c9431e2c669	2025-05-24 16:35:45.699806+00	SHERMANOLOGY	\N	2025-05-29 13:24:10.622809+00
9fbe6f94-7c3d-4087-ac17-a1d46d72fa67	2025-05-24 16:35:45.699806+00	SHIBA SAN	\N	2025-05-29 13:24:10.622809+00
08e80948-179f-4cd9-8405-e841ff1698af	2025-05-24 16:35:45.699806+00	SHINE AND THE SHAKERS	\N	2025-05-29 13:24:10.622809+00
8e756bcd-401f-4e93-9554-6445ed2be515	2025-05-24 16:35:45.699806+00	SHINY THINGS	\N	2025-05-29 13:24:10.622809+00
51986c8d-1a18-4371-b2bf-c8bff01e1140	2025-05-24 16:35:45.699806+00	SHIP WREK	\N	2025-05-29 13:24:10.622809+00
cfbe20f2-09df-4e32-a466-e96c4335a85a	2025-05-24 16:35:45.699806+00	SHIVERZ	\N	2025-05-29 13:24:10.622809+00
408068ff-c8a4-43a5-93da-95d02e59fca7	2025-05-24 16:35:45.699806+00	SHLUMP	\N	2025-05-29 13:24:10.622809+00
ef634484-e7a8-45d1-9f0a-9be6c2dfcc55	2025-05-24 16:35:45.699806+00	SHMOOP	\N	2025-05-29 13:24:10.622809+00
4f031ee2-2f9d-4a73-87da-a06ac2a72a9b	2025-05-24 16:35:45.699806+00	SHOCKONE	\N	2025-05-29 13:24:10.622809+00
e21d92dd-e45a-446b-b855-de64c389d507	2025-05-24 16:35:45.699806+00	SHPONGLE	\N	2025-05-29 13:24:10.622809+00
bc32c6c8-735c-4ddc-9763-71e0de726e92	2025-05-24 16:35:45.699806+00	SHPONGLE DROID(SIMON POSFORD LIVE FEAT. ANDROID JONES)	\N	2025-05-29 13:24:10.622809+00
fce4dbc3-5240-4ca8-bd56-d4547ee68d37	2025-05-24 16:35:45.699806+00	SHY MELON	\N	2025-05-29 13:24:10.622809+00
67e0c056-5d85-48a7-b35b-2dab744d3a92	2025-05-24 16:35:45.699806+00	SICARIA SOUND	\N	2025-05-29 13:24:10.622809+00
adb862d2-3ee1-4b01-9c84-832b60cac0ce	2025-05-24 16:35:45.699806+00	SICKISH	\N	2025-05-29 13:24:10.622809+00
5f6f9e95-6cad-4f8c-99b4-6b9cd9df8e6f	2025-05-24 16:35:45.699806+00	SIDEPIECE	\N	2025-05-29 13:24:10.622809+00
b4b686d0-7480-4b0a-8fb4-506885a48569	2025-05-24 16:35:45.699806+00	SIERRA FERRELL	\N	2025-05-29 13:24:10.622809+00
e12e314c-cd83-4ab6-86de-bf6a99f89a9d	2025-05-24 16:35:45.699806+00	SIERRA HULL	\N	2025-05-29 13:24:10.622809+00
4db2e660-0146-49af-a315-f6edc842d062	2025-05-24 16:35:45.699806+00	SINTRA	\N	2025-05-29 13:24:10.622809+00
923937af-4c37-4296-b7f6-4397b9adfaf3	2025-05-24 16:35:45.699806+00	SIPPY	\N	2025-05-29 13:24:10.622809+00
2e426ddc-3111-4113-a16e-0a07b36bec11	2025-05-24 16:35:45.699806+00	SIR HISS	\N	2025-05-29 13:24:10.622809+00
9fbec79b-3bc0-438d-ae9d-154e9707f0ad	2025-05-24 16:35:45.699806+00	SITA ABELLÁN	\N	2025-05-29 13:24:10.622809+00
226b1cfc-26e8-4490-b245-b234de3893d9	2025-05-24 16:35:45.699806+00	SIVZ	\N	2025-05-29 13:24:10.622809+00
80a26a28-66a2-40ae-ab8d-3278e45262de	2025-05-24 16:35:45.699806+00	SKANKTNK	\N	2025-05-29 13:24:10.622809+00
569e728f-948c-4bba-b55d-9eee0a49d12b	2025-05-24 16:35:45.699806+00	SKIITOUR	\N	2025-05-29 13:24:10.622809+00
a090196e-a680-4225-9c79-ee2730bb8402	2025-05-24 16:35:45.699806+00	SKIZ	\N	2025-05-29 13:24:10.622809+00
b775fc8d-c4a2-4c35-ad8c-4a80b4ba50d4	2025-05-24 16:35:45.699806+00	SKRATCH BASTID	\N	2025-05-29 13:24:10.622809+00
53cf4ee2-936b-4c34-af4d-332fb75fc5cc	2025-05-24 16:35:45.699806+00	SKRILLEX	\N	2025-05-29 13:24:10.622809+00
c0c6f23e-f110-417b-8fb3-4cc58a300cd2	2025-05-24 16:35:45.699806+00	SKY SUITE	\N	2025-05-29 13:24:10.622809+00
6bc6dccf-6809-440d-99eb-13e166c14d07	2025-05-24 16:35:45.699806+00	SKYEHYE	\N	2025-05-29 13:24:10.622809+00
d7fb7f0a-d3e8-47f8-94d9-fbe97d066394	2025-05-24 16:35:45.699806+00	SLANDER	\N	2025-05-29 13:24:10.622809+00
3227891f-4c92-4db9-96ca-a5516622e4dc	2025-05-24 16:35:45.699806+00	SLANG DOGS	\N	2025-05-29 13:24:10.622809+00
e3e7c5b0-fcd1-4373-a9ad-a88feb8d575c	2025-05-24 16:35:45.699806+00	SLENDERBODIES	\N	2025-05-29 13:24:10.622809+00
f77120bc-bfe5-4a96-8a8e-50e64884a5d9	2025-05-24 16:35:45.699806+00	SLOWTHAI	\N	2025-05-29 13:24:10.622809+00
53be6df2-9a07-4c27-a73e-4b54944ecf50	2025-05-24 16:35:45.699806+00	SLUDGE SWARM	\N	2025-05-29 13:24:10.622809+00
2b8232c1-e2f2-4aab-9bc1-543dbd3430fc	2025-05-24 16:35:45.699806+00	SLYNK	\N	2025-05-29 13:24:10.622809+00
6119b637-8a27-4c8c-8292-8e68bb791588	2025-05-24 16:35:45.699806+00	SLZRD	\N	2025-05-29 13:24:10.622809+00
9e2f74ae-8b82-4df6-9686-33d8627b4e2e	2025-05-24 16:35:45.699806+00	SMALLTOWN DJS	\N	2025-05-29 13:24:10.622809+00
5e2c6495-9ed6-4ca1-a31b-360802d44b85	2025-05-24 16:35:45.699806+00	SMITH	\N	2025-05-29 13:24:10.622809+00
bd506168-2866-4116-b39b-2160ee41240b	2025-05-24 16:35:45.699806+00	SMITH.	\N	2025-05-29 13:24:10.622809+00
576eb744-cdb3-4b16-a31d-6ab49e7a3e89	2025-05-24 16:35:45.699806+00	SMOAKLAND	\N	2025-05-29 13:24:10.622809+00
4b3ffea2-c1ae-4cb4-a5c9-b401d0f13248	2025-05-24 16:35:45.699806+00	SMOKEY BRIGHTS	\N	2025-05-29 13:24:10.622809+00
c8cd4800-8299-4cb4-a7cb-b4e64296fd7a	2025-05-24 16:35:45.699806+00	SNAKEHIPS	\N	2025-05-29 13:24:10.622809+00
c905136f-9daa-4bdd-9adf-d40c03d04f30	2025-05-24 16:35:45.699806+00	SNAKES & STARS	\N	2025-05-29 13:24:10.622809+00
a697f9e4-6810-44d4-98ac-ac2e6200efd6	2025-05-24 16:35:45.699806+00	SNBRN	\N	2025-05-29 13:24:10.622809+00
4aa4f365-1d20-4526-8a82-1d2447041197	2025-05-24 16:35:45.699806+00	SNUFFY	\N	2025-05-29 13:24:10.622809+00
b67f68a2-69a8-4cf0-8056-d077bf92e858	2025-05-24 16:35:45.699806+00	SO SUS	\N	2025-05-29 13:24:10.622809+00
f7bbaedf-794f-4ef6-86f1-73520e07ed3e	2025-05-24 16:35:45.699806+00	SO TUFF SO CUTE	\N	2025-05-29 13:24:10.622809+00
da8c5bfd-22a7-4bd9-9817-c52e2c13897b	2025-05-24 16:35:45.699806+00	SODOWN	\N	2025-05-29 13:24:10.622809+00
f2ea105b-bddc-4406-886d-270accc7e3d5	2025-05-24 16:35:45.699806+00	SOFI TUKKER	\N	2025-05-29 13:24:10.622809+00
0793764d-207d-4e6b-a80b-30b7ce7ec7d6	2025-05-24 16:35:45.699806+00	SOHMI	\N	2025-05-29 13:24:10.622809+00
165b4d76-1dd5-4950-bd20-89891f350d82	2025-05-24 16:35:45.699806+00	SOL	\N	2025-05-29 13:24:10.622809+00
e45f3dff-7c0b-4787-92b5-6c6c92e0f468	2025-05-24 16:35:45.699806+00	SOLARDO	\N	2025-05-29 13:24:10.622809+00
bb77a089-2158-42bd-aa26-54d380c746e5	2025-05-24 16:35:45.699806+00	SOMEDAY HONEY	\N	2025-05-29 13:24:10.622809+00
fd2ec9e0-1047-418f-bc35-1e09ad0a171b	2025-05-24 16:35:45.699806+00	SONNY FODERA	\N	2025-05-29 13:24:10.622809+00
02d47aa0-94c8-4102-895c-11e9e64a7f32	2025-05-24 16:35:45.699806+00	SONS OF KEMET	\N	2025-05-29 13:24:10.622809+00
ee71f90f-d63b-416a-a208-9eb7b26acce9	2025-05-24 16:35:45.699806+00	SOOHAN	\N	2025-05-29 13:24:10.622809+00
25627636-0e67-4772-808b-941ec85dfb56	2025-05-24 16:35:45.699806+00	SOSA	\N	2025-05-29 13:24:10.622809+00
136eaca8-0208-40cf-8439-965ba3197197	2025-05-24 16:35:45.699806+00	SOUKII	\N	2025-05-29 13:24:10.622809+00
54a301fe-a7e8-417f-b99c-f01a6eecc8d4	2025-05-24 16:35:45.699806+00	SOUND RUSH	\N	2025-05-29 13:24:10.622809+00
89afa76c-d707-414c-a445-ff7d3ca19f3f	2025-05-24 16:35:45.699806+00	SOUND WRECK	\N	2025-05-29 13:24:10.622809+00
9b0a38cd-1046-45c4-b166-e5a181b387dd	2025-05-24 16:35:45.699806+00	SOUNDTROOPER	\N	2025-05-29 13:24:10.622809+00
45321436-5571-44ef-9de4-0f118885272c	2025-05-24 16:35:45.699806+00	SOUTHERN AVENUE	\N	2025-05-29 13:24:10.622809+00
17608588-8b53-4a26-80e5-de881cce88fe	2025-05-24 16:35:45.699806+00	SPACE BACON	\N	2025-05-29 13:24:10.622809+00
c258e867-10d1-4a6f-99c4-f0d15d32de00	2025-05-24 16:35:45.699806+00	SPACE CADETS	\N	2025-05-29 13:24:10.622809+00
54cd01d2-648d-46ab-94ca-9672c3f83925	2025-05-24 16:35:45.699806+00	SPACE JESUS	\N	2025-05-29 13:24:10.622809+00
05da7f3a-6b1b-4046-9e17-efaaad1013b8	2025-05-24 16:35:45.699806+00	SPACE LACES	\N	2025-05-29 13:24:10.622809+00
03ab36a6-5afc-4e67-8977-e3a7823b5af7	2025-05-24 16:35:45.699806+00	SPACE WIZARD	\N	2025-05-29 13:24:10.622809+00
f9071cb2-0538-404f-b813-f18e58619d29	2025-05-24 16:35:45.699806+00	SPADES	\N	2025-05-29 13:24:10.622809+00
f017717d-3eac-4781-855e-37a23209b7ec	2025-05-24 16:35:45.699806+00	SPAFFORD	\N	2025-05-29 13:24:10.622809+00
efcf0d8c-13e5-4254-94b5-4c58ca7ae811	2025-05-24 16:35:45.699806+00	SPAG HEDDY	\N	2025-05-29 13:24:10.622809+00
f6e383ca-7d24-4422-812b-a60d1999dc3b	2025-05-24 16:35:45.699806+00	SPECTER	\N	2025-05-29 13:24:10.622809+00
2a5dc395-b820-4f39-9501-8f71ec679fa9	2025-05-24 16:35:45.699806+00	SPICY ASHAAN	\N	2025-05-29 13:24:10.622809+00
59b08c79-bac8-4216-a3f4-57eedd3f4ed4	2025-05-24 16:35:45.699806+00	SPOR	\N	2025-05-29 13:24:10.622809+00
b8be048f-5769-4038-977d-10dec8fcab1a	2025-05-24 16:35:45.699806+00	ST4RFOX	\N	2025-05-29 13:24:10.622809+00
89344b54-e3f6-4465-82cb-e55e940b53d0	2025-05-24 16:35:45.699806+00	STAN P BAND	\N	2025-05-29 13:24:10.622809+00
307f8eb0-79e1-429d-a960-99c318f198af	2025-05-24 16:35:45.699806+00	STAR KITCHEN	\N	2025-05-29 13:24:10.622809+00
e8b53213-9452-4f38-8ab7-a63a71516b64	2025-05-24 16:35:45.699806+00	STEADY FLOW	\N	2025-05-29 13:24:10.622809+00
20ebf32e-65ef-4085-b352-02fecc95c06a	2025-05-24 16:35:45.699806+00	STELLER	\N	2025-05-29 13:24:10.622809+00
bc008cb8-d2a8-4134-8f96-0dc3e6fac4ea	2025-05-24 16:35:45.699806+00	STEPHANIE MINH	\N	2025-05-29 13:24:10.622809+00
0c76fcdb-dd2c-496f-b218-2b4a57e95f1e	2025-05-24 16:35:45.699806+00	STEVE AOKI	\N	2025-05-29 13:24:10.622809+00
7907bc64-068a-45f3-82b5-7ef8ff08eb82	2025-05-24 16:35:45.699806+00	STEVE GERARD	\N	2025-05-29 13:24:10.622809+00
09b10a51-41ff-4945-9769-8530e6a3c7b7	2025-05-24 16:35:45.699806+00	STEVIE NICKS	\N	2025-05-29 13:24:10.622809+00
1e0dc034-a0ff-41ca-b593-2de879cc0dcb	2025-05-24 16:35:45.699806+00	STICK MARTIN & JON DITTY	\N	2025-05-29 13:24:10.622809+00
51815fbd-5fff-463c-b751-8dc2b07c9147	2025-05-24 16:35:45.699806+00	STILL SHINE	\N	2025-05-29 13:24:10.622809+00
d520d6ed-5975-4a78-9883-84de3499a718	2025-05-24 16:35:45.699806+00	STILL WOOZY	\N	2025-05-29 13:24:10.622809+00
d7fc954c-eb97-4f8c-b932-ba86ef90fa07	2025-05-24 16:35:45.699806+00	STS9	\N	2025-05-29 13:24:10.622809+00
93aed864-f143-42ae-a1ee-53193542c3bb	2025-05-24 16:35:45.699806+00	STUCA	\N	2025-05-29 13:24:10.622809+00
93e26fc8-8621-4a91-b748-bda1a4d30b3f	2025-05-24 16:35:45.699806+00	STYLUST	\N	2025-05-29 13:24:10.622809+00
effeab64-1222-4afb-91c4-9eaf8b89efe5	2025-05-24 16:35:45.699806+00	SUBDOCTA	\N	2025-05-29 13:24:10.622809+00
fa6fc32a-1198-4b7b-ab89-c50c2805e341	2025-05-24 16:35:45.699806+00	SUBRINSE	\N	2025-05-29 13:24:10.622809+00
ce19a837-4aed-4237-aa9c-27e6a1c72de6	2025-05-24 16:35:45.699806+00	SUBSTANCE	\N	2025-05-29 13:24:10.622809+00
2ff236d1-79c7-4024-82e2-36ab8448b544	2025-05-24 16:35:45.699806+00	SUBTRONICS	\N	2025-05-29 13:24:10.622809+00
7ffeb305-8ab2-46ef-b9a3-8f124b8bac38	2025-05-24 16:35:45.699806+00	SUCHOKO	\N	2025-05-29 13:24:10.622809+00
1e0d9e2d-c6ef-4ef0-87bb-b46d6f38e5fd	2025-05-24 16:35:45.699806+00	SUKH KNIGHT	\N	2025-05-29 13:24:10.622809+00
b2bac8b5-7e3c-45f5-a9b2-ee98cce286c1	2025-05-24 16:35:45.699806+00	SULLIVAN KING	\N	2025-05-29 13:24:10.622809+00
1935575c-6b2b-4f41-b8fc-edd258397c2e	2025-05-24 16:35:45.699806+00	SULLY	\N	2025-05-29 13:24:10.622809+00
6c5ce529-1788-4057-9176-9d0438acefcf	2025-05-24 16:35:45.699806+00	SUMTHIN SUMTHIN	\N	2025-05-29 13:24:10.622809+00
a4cf4763-47dd-4dbc-ac43-53ce011d534a	2025-05-24 16:35:45.699806+00	SUN STEREO	\N	2025-05-29 13:24:10.622809+00
160c3267-3dde-4672-8fc5-7977dc9e8cbf	2025-05-24 16:35:45.699806+00	SUNHONEY	\N	2025-05-29 13:24:10.622809+00
9cff1b7d-1364-4135-8526-5782888a15ab	2025-05-24 16:35:45.699806+00	SUNNERY JAMES & RYAN MARCIANO	\N	2025-05-29 13:24:10.622809+00
ba136da2-7e08-4b99-989f-997cc7da5a4c	2025-05-24 16:35:45.699806+00	SUNSQUABI	\N	2025-05-29 13:24:10.622809+00
b6582170-250f-4c8f-940b-f8422b2dc3a1	2025-05-24 16:35:45.699806+00	SUPER FUTURE	\N	2025-05-29 13:24:10.622809+00
b7dff97a-bf8c-466b-b6a4-8d4520be4557	2025-05-24 16:35:45.699806+00	SUPERAVE.	\N	2025-05-29 13:24:10.622809+00
3dd8e024-6b50-4372-b55c-37e0f1a3e4a3	2025-05-24 16:35:45.699806+00	SUPERTASK	\N	2025-05-29 13:24:10.622809+00
7bb06c25-b6f9-4668-a908-c115948b44df	2025-05-24 16:35:45.699806+00	SURF MESA	\N	2025-05-29 13:24:10.622809+00
0df90d6e-601e-4d0d-bf0a-6c6f7be82852	2025-05-24 16:35:45.699806+00	SURPRISE SET	\N	2025-05-29 13:24:10.622809+00
3f3adbb3-b1b7-4fa9-a83a-f44730df8ef6	2025-05-24 16:35:45.699806+00	SUSTO	\N	2025-05-29 13:24:10.622809+00
627bb0d8-8b12-497c-9e7a-3707dd885489	2025-05-24 16:35:45.699806+00	SVBLE	\N	2025-05-29 13:24:10.622809+00
14de17b4-ad41-4c59-af07-7c15f73d2df2	2025-05-24 16:35:45.699806+00	SVDDEN DEATH	\N	2025-05-29 13:24:10.622809+00
d4ada604-31d8-4db5-b619-609053a20007	2025-05-24 16:35:45.699806+00	SWARM	\N	2025-05-29 13:24:10.622809+00
7676afb0-c888-4e59-a2e4-8f455f7e53c5	2025-05-24 16:35:45.699806+00	SWATKINS & THE POSITIVE AGENDA	\N	2025-05-29 13:24:10.622809+00
951b51e9-b557-43f8-a19c-53fdbf60fb13	2025-05-24 16:35:45.699806+00	SWEEZ	\N	2025-05-29 13:24:10.622809+00
c312cf6f-e592-446f-972e-1adf2cdd7a0c	2025-05-24 16:35:45.699806+00	SYENCE	\N	2025-05-29 13:24:10.622809+00
ec6058cb-a255-4add-a8db-571246be12a2	2025-05-24 16:35:45.699806+00	SYLPH	\N	2025-05-29 13:24:10.622809+00
88511fca-1ad3-4a61-8fef-ecadc9dc661c	2025-05-24 16:35:45.699806+00	SYLVAN ESSO	\N	2025-05-29 13:24:10.622809+00
71a4b814-a1cf-4adf-b1dd-37f41ec17258	2025-05-24 16:35:45.699806+00	SYLVI	\N	2025-05-29 13:24:10.622809+00
065aee73-c9e8-4a62-a1a1-82cad5292241	2025-05-24 16:35:45.699806+00	SYNE	\N	2025-05-29 13:24:10.622809+00
10a2fb0d-b0c3-4e2b-89a7-5548e4617c4e	2025-05-24 16:35:45.699806+00	TAI VERDES	\N	2025-05-29 13:24:10.622809+00
e2b5f287-b07e-4029-ba65-93babf31be3d	2025-05-24 16:35:45.699806+00	TAIKI NULIGHT	\N	2025-05-29 13:24:10.622809+00
0f5df69f-aa10-4937-8bc4-a38e9cb33643	2025-05-24 16:35:45.699806+00	TALON	\N	2025-05-29 13:24:10.622809+00
5fc466aa-83a7-461a-98e7-05206ea213eb	2025-05-24 16:35:45.699806+00	TAND	\N	2025-05-29 13:24:10.622809+00
4f326b12-0c99-4d61-86f1-16bfcb1e0c21	2025-05-24 16:35:45.699806+00	TANK AND THE BANGAS	\N	2025-05-29 13:24:10.622809+00
7e37c869-3c43-44e1-a933-5530e4db2d5d	2025-05-24 16:35:45.699806+00	TAPE B	\N	2025-05-29 13:24:10.622809+00
6b4ec44b-b609-4e71-8a6f-257c6d24e7d4	2025-05-24 16:35:45.699806+00	TASH SULTANA	\N	2025-05-29 13:24:10.622809+00
99ac0624-101d-4ac1-9ae5-171029ae4cbd	2025-05-24 16:35:45.699806+00	TAUK	\N	2025-05-29 13:24:10.622809+00
08289d94-dd50-4ce8-a523-c7a9aa63b679	2025-05-24 16:35:45.699806+00	TAYLOR TORRENCE	\N	2025-05-29 13:24:10.622809+00
85afef37-792a-4266-b5a7-ed66be187004	2025-05-24 16:35:45.699806+00	TCHAMI	\N	2025-05-29 13:24:10.622809+00
f3a7e079-37d2-442b-bbf4-7feaae77cc2b	2025-05-24 16:35:45.699806+00	TCHAMI X MALAA	\N	2025-05-29 13:24:10.622809+00
230462a2-1ff0-4245-b342-cc30cfa180f7	2025-05-24 16:35:45.699806+00	TCHILT	\N	2025-05-29 13:24:10.622809+00
e8135ab6-17b2-42ec-9743-dc45a876342a	2025-05-24 16:35:45.699806+00	TEDDY SWIMS	\N	2025-05-29 13:24:10.622809+00
fb756d15-5617-4e8b-9c90-b354d073e6a4	2025-05-24 16:35:45.699806+00	TEL05369	\N	2025-05-29 13:24:10.622809+00
40f37933-130a-4f46-b34b-166b6959b9bd	2025-05-24 16:35:45.699806+00	TEMPO GIUSTO	\N	2025-05-29 13:24:10.622809+00
8447d406-ca7a-4e33-a432-db89fd5619ac	2025-05-24 16:35:45.699806+00	TERNION SOUND	\N	2025-05-29 13:24:10.622809+00
99541c7c-56c6-4c04-b09d-90e79e91de0a	2025-05-24 16:35:45.699806+00	TESTPILOT	\N	2025-05-29 13:24:10.622809+00
74698313-9315-44c5-8316-d1e4cf7c76ec	2025-05-24 16:35:45.699806+00	THE AL LEONG BAND	\N	2025-05-29 13:24:10.622809+00
62c17d7c-596d-49f4-8dc6-05a61c99c5ea	2025-05-24 16:35:45.699806+00	THE BACKSEAT LOVERS	\N	2025-05-29 13:24:10.622809+00
68f6777f-7ef7-4de5-a383-d74d8d324d6a	2025-05-24 16:35:45.699806+00	THE BROOK & THE BLUFF	\N	2025-05-29 13:24:10.622809+00
3a75eb9e-79c2-43db-b649-8dc8767f359a	2025-05-24 16:35:45.699806+00	THE CAR THIEF	\N	2025-05-29 13:24:10.622809+00
96c1e840-3cd7-4322-8913-358d9d4f147a	2025-05-24 16:35:45.699806+00	THE CHEEKS	\N	2025-05-29 13:24:10.622809+00
b47af50c-9983-425c-a953-4040c1f3b746	2025-05-24 16:35:45.699806+00	THE CHICKS	\N	2025-05-29 13:24:10.622809+00
2bea46ec-ee93-4dba-ac82-0729cd49ab73	2025-05-24 16:35:45.699806+00	THE CLAUDETTES	\N	2025-05-29 13:24:10.622809+00
d6daa9dd-f98c-40b9-81f1-21dd76f12958	2025-05-24 16:35:45.699806+00	THE DIP	\N	2025-05-29 13:24:10.622809+00
10ffa50c-135a-40f8-a100-840bb0b8a650	2025-05-24 16:35:45.699806+00	THE DISCO BISCUITS	\N	2025-05-29 13:24:10.622809+00
e387fe82-de95-4b51-bb07-a8906557e2aa	2025-05-24 16:35:45.699806+00	THE FLOOZIES	\N	2025-05-29 13:24:10.622809+00
2bf200ed-8835-44c2-812e-89c163104fb4	2025-05-24 16:35:45.699806+00	THE FRITZ	\N	2025-05-29 13:24:10.622809+00
39471588-3189-4770-a60f-01cc9df308ff	2025-05-24 16:35:45.699806+00	THE FUNK HUNTERS	\N	2025-05-29 13:24:10.622809+00
b6b7c2de-d0d2-46df-88a2-9e5dc92b059e	2025-05-24 16:35:45.699806+00	THE GAFF	\N	2025-05-29 13:24:10.622809+00
ec35a7f6-3112-49ed-a2eb-4b06880894a7	2025-05-24 16:35:45.699806+00	THE GRASS IS DEAD	\N	2025-05-29 13:24:10.622809+00
f11de338-1309-449c-b41b-bcd9c0ab07b5	2025-05-24 16:35:45.699806+00	THE GREY MAN	\N	2025-05-29 13:24:10.622809+00
5608c9fe-c319-40ae-bd94-af0371e683c7	2025-05-24 16:35:45.699806+00	THE HIGH SEAGRASS	\N	2025-05-29 13:24:10.622809+00
9fe897b6-8fe1-4a71-8866-827fc2cee3d4	2025-05-24 16:35:45.699806+00	THE HILLBENDERS	\N	2025-05-29 13:24:10.622809+00
64bb4c70-3f0a-4b86-bea2-ed65900a7c4f	2025-05-24 16:35:45.699806+00	THE HORN SECTION	\N	2025-05-29 13:24:10.622809+00
4f3aa2ac-7df5-47e9-9547-cf45d4dde7c7	2025-05-24 16:35:45.699806+00	THE INFAMOUS STRINGDUSTERS	\N	2025-05-29 13:24:10.622809+00
b2f3d8e0-3bef-4f4b-873b-4330726e72b0	2025-05-24 16:35:45.699806+00	THE INTURNSHIP	\N	2025-05-29 13:24:10.622809+00
eedb12b9-7bef-4bc5-b0fd-5d3f9b105c18	2025-05-24 16:35:45.699806+00	THE KNOCKS	\N	2025-05-29 13:24:10.622809+00
93b3953b-9dcf-4d27-879e-13f4b46d8cf7	2025-05-24 16:35:45.699806+00	THE LIBRARIAN	\N	2025-05-29 13:24:10.622809+00
e82070a5-6d5b-4d70-9ea8-7c7aef21886b	2025-05-24 16:35:45.699806+00	THE MAIN SQUEEZE	\N	2025-05-29 13:24:10.622809+00
9c3f4b3a-b661-457f-87d0-6051a2fe29bb	2025-05-24 16:35:45.699806+00	THE MOLE	\N	2025-05-29 13:24:10.622809+00
00a45d6f-8e7b-45ab-b3a9-35eb4991f308	2025-05-24 16:35:45.699806+00	THE MOTET	\N	2025-05-29 13:24:10.622809+00
a10245c0-0fe7-454a-8d04-867ffce252fb	2025-05-24 16:35:45.699806+00	THE NORTH 41	\N	2025-05-29 13:24:10.622809+00
fafc08ab-5651-4f4c-9f3b-7b234d6836be	2025-05-24 16:35:45.699806+00	THE NTH POWER	\N	2025-05-29 13:24:10.622809+00
cc81f963-99c8-4562-9f53-bde5fc69aa1f	2025-05-24 16:35:45.699806+00	THE ORIGINAL NTH POWER	\N	2025-05-29 13:24:10.622809+00
c3a4071c-8ea4-450a-b755-b6230c644e25	2025-05-24 16:35:45.699806+00	THE REALITY	\N	2025-05-29 13:24:10.622809+00
913e4468-2140-40bb-b661-b0f90af3fe12	2025-05-24 16:35:45.699806+00	THE REGRETTES	\N	2025-05-29 13:24:10.622809+00
4cb1595d-33ad-4338-84cc-7632c2bc9ee1	2025-05-24 16:35:45.699806+00	THE REMINDERS	\N	2025-05-29 13:24:10.622809+00
9ecd15f5-43ae-43a7-afa5-f1575eead64a	2025-05-24 16:35:45.699806+00	THE SMASHING PUMPKINS	\N	2025-05-29 13:24:10.622809+00
42d0c4b0-fdaa-461f-828b-46981a0097aa	2025-05-24 16:35:45.699806+00	THE SOUL REBELS FT. GZA	\N	2025-05-29 13:24:10.622809+00
6a26a6a8-1a63-4755-890b-f9de6d1164a2	2025-05-24 16:35:45.699806+00	THE SPONGES	\N	2025-05-29 13:24:10.622809+00
7b5025b2-a17d-44f0-8a71-f1308b3a5a23	2025-05-24 16:35:45.699806+00	THE STRING CHEESE INCIDENT	\N	2025-05-29 13:24:10.622809+00
9ae7a3dc-450d-4629-8b8f-79a013f4ccfe	2025-05-24 16:35:45.699806+00	THE TRIPP BROTHERS	\N	2025-05-29 13:24:10.622809+00
9e08d17d-84b1-451c-b271-ab7384e615e7	2025-05-24 16:35:45.699806+00	THE WAR ON DRUGS	\N	2025-05-29 13:24:10.622809+00
5329754f-8393-4ff8-87b8-7d1ac1300303	2025-05-24 16:35:45.699806+00	THE WEATHER STATION	\N	2025-05-29 13:24:10.622809+00
b7cfbb70-06c7-40bf-829d-6e4124aa4ebc	2025-05-24 16:35:45.699806+00	THE WERKS	\N	2025-05-29 13:24:10.622809+00
180e6554-4a75-4844-b8dd-493427a59044	2025-05-24 16:35:45.699806+00	THE WIDDLER	\N	2025-05-29 13:24:10.622809+00
8bb2e2c5-74ec-4d6e-8a34-c69972793891	2025-05-24 16:35:45.699806+00	THOUGHT PROCESS	\N	2025-05-29 13:24:10.622809+00
5574d102-74b2-47c4-b74b-8972922a338d	2025-05-24 16:35:45.699806+00	TIEDYE KY	\N	2025-05-29 13:24:10.622809+00
34ab0db0-a416-4bec-9b40-cc478903ad89	2025-05-24 16:35:45.699806+00	TIEDYEKY	\N	2025-05-29 13:24:10.622809+00
f16ae8d3-4746-418c-b40a-d344edd612e9	2025-05-24 16:35:45.699806+00	TIERRA WHACK	\N	2025-05-29 13:24:10.622809+00
d903be99-99d7-4118-aefa-8f427e6dc367	2025-05-24 16:35:45.699806+00	TIERRO BAND FT BRIDGET LAW	\N	2025-05-29 13:24:10.622809+00
390e24bf-4e92-4337-82c6-3759cf8d5fcb	2025-05-24 16:35:45.699806+00	TIESTO	\N	2025-05-29 13:24:10.622809+00
16598014-ac2a-4ef7-afd3-7cd39ed932de	2025-05-24 16:35:45.699806+00	TIËSTO	\N	2025-05-29 13:24:10.622809+00
46977bff-53bc-465f-80ae-45c5da43e2d1	2025-05-24 16:35:45.699806+00	WUZZY	\N	2025-05-29 13:24:10.622809+00
92ac373e-f057-48ab-bab4-aad88d663ebd	2025-05-24 16:35:45.699806+00	TIËSTO (SUNSET SET)	\N	2025-05-29 13:24:10.622809+00
e0696f51-6e79-44e4-a27a-a5a79633c334	2025-05-24 16:35:45.699806+00	TIMMY TRUMPET	\N	2025-05-29 13:24:10.622809+00
60f18319-8124-4bd8-ab68-e0417c6183cd	2025-05-24 16:35:45.699806+00	TINASHE	\N	2025-05-29 13:24:10.622809+00
1c305017-c86c-405e-a9b4-7017609b0140	2025-05-24 16:35:45.699806+00	TINLICKER	\N	2025-05-29 13:24:10.622809+00
c23f3324-ded6-4f05-8c63-8242f853d687	2025-05-24 16:35:45.699806+00	TIPPER	\N	2025-05-29 13:24:10.622809+00
ca10b9fd-5d67-4c7c-889e-4e6ca926e27e	2025-05-24 16:35:45.699806+00	TIRE FIRE	\N	2025-05-29 13:24:10.622809+00
6af44586-fa04-4ced-858c-c3921f46fac1	2025-05-24 16:35:45.699806+00	TITA LAU	\N	2025-05-29 13:24:10.622809+00
881a4b8d-e05f-4ab8-9cdd-5c0ffd50b879	2025-05-24 16:35:45.699806+00	TK & THE HOLY KNOW NOTHINGS	\N	2025-05-29 13:24:10.622809+00
5cb625b2-97d8-44ad-8543-ce657addf2de	2025-05-24 16:35:45.699806+00	TLZMN	\N	2025-05-29 13:24:10.622809+00
0345bbab-281d-4555-ac41-33227d7fd11f	2025-05-24 16:35:45.699806+00	TNT	\N	2025-05-29 13:24:10.622809+00
d9aacecd-4e49-4504-99a7-7865352caed3	2025-05-24 16:35:45.699806+00	TOADFACE	\N	2025-05-29 13:24:10.622809+00
830949c0-af44-4035-9bfa-e479c17c3662	2025-05-24 16:35:45.699806+00	TOBE NWIGWE	\N	2025-05-29 13:24:10.622809+00
cfd3c25c-7b1c-4570-8c2e-0375438185a8	2025-05-24 16:35:45.699806+00	TOKIMONSTA	\N	2025-05-29 13:24:10.622809+00
bf97a613-7b16-4518-a596-0c1bbcc666c5	2025-05-24 16:35:45.699806+00	TOLLEFSON	\N	2025-05-29 13:24:10.622809+00
d56466f6-9c1d-4f1b-a101-fc9d54322aa0	2025-05-24 16:35:45.699806+00	TOMAHAWK BANG	\N	2025-05-29 13:24:10.622809+00
e05ba0a6-cf2d-406c-b546-796b2d1d8997	2025-05-24 16:35:45.699806+00	TOOL	\N	2025-05-29 13:24:10.622809+00
bab98b31-ac85-4abe-80c9-ebad53985ed2	2025-05-24 16:35:45.699806+00	TOR	\N	2025-05-29 13:24:10.622809+00
bd7cf9c9-5c34-4689-8740-b4d229fe9cea	2025-05-24 16:35:45.699806+00	TORO Y MOI	\N	2025-05-29 13:24:10.622809+00
f0db6dd8-1813-448c-87c5-f6909776625d	2025-05-24 16:35:45.699806+00	TOVE LO	\N	2025-05-29 13:24:10.622809+00
abf2f9a7-2ed1-4d53-9a36-6f04f730e6c8	2025-05-24 16:35:45.699806+00	TOWNSHIP REBELLION	\N	2025-05-29 13:24:10.622809+00
003c09dc-b37e-47a7-9736-9b559a6fe226	2025-05-24 16:35:45.699806+00	TRASH ANGEL	\N	2025-05-29 13:24:10.622809+00
0c2456a6-0112-4ead-9e84-dfca041f0a3e	2025-05-24 16:35:45.699806+00	TRAVIS THOMPSON	\N	2025-05-29 13:24:10.622809+00
dbf58ff2-afbf-4718-a2dc-2d1fbd931d16	2025-05-24 16:35:45.699806+00	TREE SAP	\N	2025-05-29 13:24:10.622809+00
fec61f2f-9dcf-4817-ab68-7ec2984b75a7	2025-05-24 16:35:45.699806+00	TREEPEOH	\N	2025-05-29 13:24:10.622809+00
8fb09ee0-a315-4821-85d3-0368548f1cb7	2025-05-24 16:35:45.699806+00	TREVOR LIFEBOOGIE WALKER	\N	2025-05-29 13:24:10.622809+00
ae46228d-9a1e-433a-9586-aaf97db54b3f	2025-05-24 16:35:45.699806+00	TRIP DROP	\N	2025-05-29 13:24:10.622809+00
b5320379-c452-4375-8b09-d1ebbad2a34c	2025-05-24 16:35:45.699806+00	TRIPP ST	\N	2025-05-29 13:24:10.622809+00
df085140-4e96-46ed-b256-38eb250455ee	2025-05-24 16:35:45.699806+00	TRIPP ST.	\N	2025-05-29 13:24:10.622809+00
843f2712-fb08-4e32-8841-5677f9dac3e1	2025-05-24 16:35:45.699806+00	TRIPSITTER	\N	2025-05-29 13:24:10.622809+00
d9dc1b8a-4e9d-4284-a5bf-0cf24cc75e50	2025-05-24 16:35:45.699806+00	TRIPZY LEARY	\N	2025-05-29 13:24:10.622809+00
ae0dbf60-36e1-427a-946e-0af8da493b57	2025-05-24 16:35:45.699806+00	TRITONAL	\N	2025-05-29 13:24:10.622809+00
62aeac50-58e8-46a2-87ee-38407d84b9dd	2025-05-24 16:35:45.699806+00	TRIVECTA	\N	2025-05-29 13:24:10.622809+00
85172259-2c43-4318-87aa-0920f82979d3	2025-05-24 16:35:45.699806+00	TROYBOI	\N	2025-05-29 13:24:10.622809+00
9cfc9f69-953f-42f5-b788-678378968929	2025-05-24 16:35:45.699806+00	TRUTH	\N	2025-05-29 13:24:10.622809+00
fc66a3a1-e0bf-424b-beed-ce2f31aa72d0	2025-05-24 16:35:45.699806+00	TRUTH X LIES	\N	2025-05-29 13:24:10.622809+00
aa06a6ce-f444-4adf-a217-857d584ec902	2025-05-24 16:35:45.699806+00	TRVPSQUAD	\N	2025-05-29 13:24:10.622809+00
275feab2-01fa-4b36-b085-16ccfc8116b1	2025-05-24 16:35:45.699806+00	TSHA	\N	2025-05-29 13:24:10.622809+00
42be549c-1569-409f-97c8-5a95ed5d53ae	2025-05-24 16:35:45.699806+00	TSIMBA	\N	2025-05-29 13:24:10.622809+00
63364adc-e4e6-4574-838a-5bf0e2cd4f60	2025-05-24 16:35:45.699806+00	TSU NAMI	\N	2025-05-29 13:24:10.622809+00
67d27126-360a-43d7-951c-b61bb3d11612	2025-05-24 16:35:45.699806+00	TSURUDA	\N	2025-05-29 13:24:10.622809+00
25510454-fc02-4960-b04a-073e0e03f6d8	2025-05-24 16:35:45.699806+00	TUNIC	\N	2025-05-29 13:24:10.622809+00
1e45de67-b840-4417-92a3-d6663ba24172	2025-05-24 16:35:45.699806+00	TURKUAZ	\N	2025-05-29 13:24:10.622809+00
ed77a0a0-b6f7-40da-9c65-c1da43a57b18	2025-05-24 16:35:45.699806+00	TVBOO	\N	2025-05-29 13:24:10.622809+00
c6d01805-71b9-4040-9fd5-dfac3871a7a4	2025-05-24 16:35:45.699806+00	TWEED	\N	2025-05-29 13:24:10.622809+00
01bddf74-7a13-4443-927c-fd6a0628de7c	2025-05-24 16:35:45.699806+00	TWEEKACORE	\N	2025-05-29 13:24:10.622809+00
8c1a0749-3cdf-4391-a4b8-e2f3ad58ce69	2025-05-24 16:35:45.699806+00	TWIDDLE	\N	2025-05-29 13:24:10.622809+00
d1e1f7c4-e88e-486e-aa84-7ccacd9b7e3c	2025-05-24 16:35:45.699806+00	TWO COMMAS	\N	2025-05-29 13:24:10.622809+00
c2fc6e87-068a-4710-a2f5-5ed71bf74cc8	2025-05-24 16:35:45.699806+00	TWO FEET	\N	2025-05-29 13:24:10.622809+00
59b8bdce-e93c-4cb2-9ac2-49400fa17470	2025-05-24 16:35:45.699806+00	TWO FINGERS	\N	2025-05-29 13:24:10.622809+00
e94a5917-c7ee-4e2f-a17f-aa4347de516d	2025-05-24 16:35:45.699806+00	TWO FRIENDS	\N	2025-05-29 13:24:10.622809+00
ef0dde40-afa1-41fa-8cd2-15761bf646f8	2025-05-24 16:35:45.699806+00	TYEGUYS	\N	2025-05-29 13:24:10.622809+00
066d83f3-a809-4fc2-b0f4-798bbfeef1f0	2025-05-24 16:35:45.699806+00	TYLER STADIUS	\N	2025-05-29 13:24:10.622809+00
ac1fd6e3-ee58-43ad-8044-377cc55e3bcd	2025-05-24 16:35:45.699806+00	TYNAN	\N	2025-05-29 13:24:10.622809+00
9da7ef1b-8961-4449-b3e4-cd8c920de51a	2025-05-24 16:35:45.699806+00	UJUU	\N	2025-05-29 13:24:10.622809+00
56b1c256-ec8b-4d1c-b166-5fba1723b72f	2025-05-24 16:35:45.699806+00	ULTRASLOTH	\N	2025-05-29 13:24:10.622809+00
870e113c-7293-4de0-9078-0104a617e85e	2025-05-24 16:35:45.699806+00	UM..	\N	2025-05-29 13:24:10.622809+00
98585607-f831-4dc8-84cc-57ef4bcd10a2	2025-05-24 16:35:45.699806+00	UMPHREY’S MCGEE	\N	2025-05-29 13:24:10.622809+00
47ba861b-de5b-47bc-9667-6d9d9d5fb3bd	2025-05-24 16:35:45.699806+00	UNDEHFINED	\N	2025-05-29 13:24:10.622809+00
75c4e37c-9cbc-4379-b010-5e9e2d1653ff	2025-05-24 16:35:45.699806+00	UNDERSCORES	\N	2025-05-29 13:24:10.622809+00
cb2c47f9-da26-4589-860d-2e7663e16608	2025-05-24 16:35:45.699806+00	UNIIQU3	\N	2025-05-29 13:24:10.622809+00
b3129cbe-5d6f-477e-a482-f92f816bfdcd	2025-05-24 16:35:45.699806+00	UNIQU3	\N	2025-05-29 13:24:10.622809+00
3c8d370f-2b08-4671-8a7c-0f4bf60bdf9c	2025-05-24 16:35:45.699806+00	VALENTINO KHAN	\N	2025-05-29 13:24:10.622809+00
9cd279b9-bace-4408-bf0e-7e44a68f2a1a	2025-05-24 16:35:45.699806+00	VAMPA	\N	2025-05-29 13:24:10.622809+00
41550ea9-a802-49f2-9f58-f884b90ba143	2025-05-24 16:35:45.699806+00	VASKI	\N	2025-05-29 13:24:10.622809+00
feda39e9-313c-4323-a5bc-3d466166a4e0	2025-05-24 16:35:45.699806+00	VCTRE	\N	2025-05-29 13:24:10.622809+00
4b01cef4-0b89-4f0d-93a7-9ec743666a16	2025-05-24 16:35:45.699806+00	VEDIC	\N	2025-05-29 13:24:10.622809+00
a534ec16-bc6e-4fa3-acee-540bccff7d36	2025-05-24 16:35:45.699806+00	VEIL	\N	2025-05-29 13:24:10.622809+00
90b14ffc-48e4-42e2-8c12-559bd3a75a70	2025-05-24 16:35:45.699806+00	VEIL B2B NOTLÖ	\N	2025-05-29 13:24:10.622809+00
b38e8a12-abe3-4e39-9fd8-b8b78ee29af1	2025-05-24 16:35:45.699806+00	VERUM	\N	2025-05-29 13:24:10.622809+00
8a989189-f660-4fd6-a2f0-b33460647924	2025-05-24 16:35:45.699806+00	VHSCERAL	\N	2025-05-29 13:24:10.622809+00
9afdd972-fc4d-4d8f-b7be-bb4aad115cbe	2025-05-24 16:35:45.699806+00	VIBE EMISSIONS	\N	2025-05-29 13:24:10.622809+00
4e21b110-1e13-4dff-9fb5-3a73da7609bb	2025-05-24 16:35:45.699806+00	VIBESQUAD	\N	2025-05-29 13:24:10.622809+00
651788a3-d8f3-4f17-a359-dd0c6ab71ff5	2025-05-24 16:35:45.699806+00	VICTOR WOOTEN	\N	2025-05-29 13:24:10.622809+00
d8c7aad7-6bd1-4eb6-a587-2c27a5484364	2025-05-24 16:35:45.699806+00	VIDE	\N	2025-05-29 13:24:10.622809+00
8703aa74-9b9b-41bb-a987-e7f584080ce3	2025-05-24 16:35:45.699806+00	VINI VICI	\N	2025-05-29 13:24:10.622809+00
ded84e71-b069-4974-8fa6-69f85d6b5a50	2025-05-24 16:35:45.699806+00	VINTAGE CULTURE	\N	2025-05-29 13:24:10.622809+00
c1ae9a68-7534-45e0-8455-d5b40fb240f9	2025-05-24 16:35:45.699806+00	VINTAGE PISTOL	\N	2025-05-29 13:24:10.622809+00
796a5191-2970-401d-8a69-bea76a4a98df	2025-05-24 16:35:45.699806+00	VINYL RITCHIE	\N	2025-05-29 13:24:10.622809+00
03198e4d-0bd0-40bb-8a15-d07c3ace24e2	2025-05-24 16:35:45.699806+00	VIRTUAL RIOT	\N	2025-05-29 13:24:10.622809+00
5a266d24-3607-47b4-bb6e-bf07b450fe13	2025-05-24 16:35:45.699806+00	VIRTUAL RIOT B2B BARELY ALIVE	\N	2025-05-29 13:24:10.622809+00
91125f9d-ab47-405b-b864-cbd1443ae48c	2025-05-24 16:35:45.699806+00	VISKUS	\N	2025-05-29 13:24:10.622809+00
af3efe8f-5685-4de3-9e3c-a9ca2f2f41de	2025-05-24 16:35:45.699806+00	VITILLAZ	\N	2025-05-29 13:24:10.622809+00
6a1d9b12-3885-4d22-8651-0890b0d680c4	2025-05-24 16:35:45.699806+00	VIV CASTLE	\N	2025-05-29 13:24:10.622809+00
282d2742-bc6b-4b95-8914-bebf97fffef1	2025-05-24 16:35:45.699806+00	VLCN	\N	2025-05-29 13:24:10.622809+00
a4a2dfc7-1c30-4448-b7f0-f9b5ed0fb67f	2025-05-24 16:35:45.699806+00	VNSSA	\N	2025-05-29 13:24:10.622809+00
86532dfa-9199-4415-8666-82afd1cb5242	2025-05-24 16:35:45.699806+00	VOLAC	\N	2025-05-29 13:24:10.622809+00
0a421e60-96e9-4adf-8d18-e7553585d9e6	2025-05-24 16:35:45.699806+00	VON:D	\N	2025-05-29 13:24:10.622809+00
f033c53c-fca2-4fff-bc3c-1e49e2163515	2025-05-24 16:35:45.699806+00	WAKAAN FAMILY B2B SET	\N	2025-05-29 13:24:10.622809+00
024afd57-2c8d-419b-9703-c22a78da9a71	2025-05-24 16:35:45.699806+00	WALKER & ROYCE	\N	2025-05-29 13:24:10.622809+00
674e77be-e7fc-4e4f-b142-9c75694ecab4	2025-05-24 16:35:45.699806+00	WALLOWS	\N	2025-05-29 13:24:10.622809+00
9579f625-3e06-4c89-992d-d6271c9c49b6	2025-05-24 16:35:45.699806+00	WARF	\N	2025-05-29 13:24:10.622809+00
70147e65-fc1b-4599-825e-6e8b35b524bf	2025-05-24 16:35:45.699806+00	WARFACE	\N	2025-05-29 13:24:10.622809+00
0ba8d2b8-db33-483d-8437-032ea4cc525c	2025-05-24 16:35:45.699806+00	WATER SPIRIT	\N	2025-05-29 13:24:10.622809+00
1862866c-ed89-4c2a-8166-73bf3a09e6f3	2025-05-24 16:35:45.699806+00	WAX MOTIF	\N	2025-05-29 13:24:10.622809+00
395b9490-6b8e-40e4-9d17-58e1b9ec47ca	2025-05-24 16:35:45.699806+00	WEIRD WAIFU	\N	2025-05-29 13:24:10.622809+00
73caabc1-08a4-4bc5-80e8-4af66b8bbcd5	2025-05-24 16:35:45.699806+00	WENZDAY	\N	2025-05-29 13:24:10.622809+00
7378b2f1-4747-49e8-96a0-94704410717e	2025-05-24 16:35:45.699806+00	WESSANDERS	\N	2025-05-29 13:24:10.622809+00
9389c001-3eaa-4991-8774-be680f3b69c3	2025-05-24 16:35:45.699806+00	WEST END BLEND	\N	2025-05-29 13:24:10.622809+00
19a5202a-71fd-4173-bc1d-f40b319df917	2025-05-24 16:35:45.699806+00	WESTEND	\N	2025-05-29 13:24:10.622809+00
f1fd959c-a7e5-4c6e-8222-a9c9d42821bb	2025-05-24 16:35:45.699806+00	WEVAL	\N	2025-05-29 13:24:10.622809+00
fa693d77-4646-4cdc-8540-bf565f528b3b	2025-05-24 16:35:45.699806+00	WHAT SO NOT	\N	2025-05-29 13:24:10.622809+00
692d0cde-a29f-4931-9295-725e06da3cb9	2025-05-24 16:35:45.699806+00	WHETHAN	\N	2025-05-29 13:24:10.622809+00
b020b383-f800-40cd-8381-33ab46cffe32	2025-05-24 16:35:45.699806+00	WHIPPED CREAM	\N	2025-05-29 13:24:10.622809+00
c52c80c8-8717-496a-bc11-2e737037294f	2025-05-24 16:35:45.699806+00	WHISKEY MYERS	\N	2025-05-29 13:24:10.622809+00
e0f38653-f5a5-4f42-a1eb-733d41c3dc63	2025-05-24 16:35:45.699806+00	WHITNEY MONGE	\N	2025-05-29 13:24:10.622809+00
1b0d6d5d-11f8-41b4-9850-56223d1b8c22	2025-05-24 16:35:45.699806+00	WHOMADEWHO	\N	2025-05-29 13:24:10.622809+00
b75f9543-6845-44c5-a97f-4f3861975edc	2025-05-24 16:35:45.699806+00	WICKERS PORTAL	\N	2025-05-29 13:24:10.622809+00
096af610-e900-41ac-879a-cd2c49a5fded	2025-05-24 16:35:45.699806+00	WIDOW	\N	2025-05-29 13:24:10.622809+00
7242c962-e6b8-4ccf-9b9a-766c334aafd9	2025-05-24 16:35:45.699806+00	WILD RIVERS	\N	2025-05-29 13:24:10.622809+00
d46e0b4d-4a60-467f-a720-100da15f55eb	2025-05-24 16:35:45.699806+00	WILDSTYLEZ	\N	2025-05-29 13:24:10.622809+00
7a9aa10a-0669-4e77-b7d0-d8cf04b86254	2025-05-24 16:35:45.699806+00	WILL CLARKE	\N	2025-05-29 13:24:10.622809+00
b495f987-fdf0-4902-8cf6-a494e1f5b01d	2025-05-24 16:35:45.699806+00	WILLIAM BLACK	\N	2025-05-29 13:24:10.622809+00
96d26628-7e5f-43cc-aab1-f9dd4123f2f2	2025-05-24 16:35:45.699806+00	WINSLOW	\N	2025-05-29 13:24:10.622809+00
77082f90-e79d-4e48-a8ef-421b581d6ad5	2025-05-24 16:35:45.699806+00	WNDOW	\N	2025-05-29 13:24:10.622809+00
2b78772f-6604-41e3-af3b-22ae66015d04	2025-05-24 16:35:45.699806+00	WOKEZAN	\N	2025-05-29 13:24:10.622809+00
1204efbe-00af-4ad8-83f5-fc2d4f205aad	2025-05-24 16:35:45.699806+00	WOLFCHILD	\N	2025-05-29 13:24:10.622809+00
069e24f2-7c23-4eee-8aab-f6ffd0a86d3f	2025-05-24 16:35:45.699806+00	WOOFAX	\N	2025-05-29 13:24:10.622809+00
7b8d35eb-1661-4758-9b23-9a4300c98dc7	2025-05-24 16:35:45.699806+00	WOOGIE STAGE:	\N	2025-05-29 13:24:10.622809+00
4b441a88-0f24-4023-9166-7caeee61c9db	2025-05-24 16:35:45.699806+00	WOOLI	\N	2025-05-29 13:24:10.622809+00
d701f254-1d5b-4f32-ba43-08f3dd73b639	2025-05-24 16:35:45.699806+00	WORAKLS	\N	2025-05-29 13:24:10.622809+00
d4ae31e4-4477-4e48-8bef-47ae27c8f7c2	2025-05-24 16:35:45.699806+00	WRAITH	\N	2025-05-29 13:24:10.622809+00
3fc5368d-17f2-4bbe-ac9c-1846df1df061	2025-05-24 16:35:45.699806+00	WRAZ	\N	2025-05-29 13:24:10.622809+00
d3046501-1cc4-4f36-bea6-fdcba9ceac7c	2025-05-24 16:35:45.699806+00	WRECKNO	\N	2025-05-29 13:24:10.622809+00
1ca50ab3-1ac2-4e27-b827-25f4e4094b94	2025-05-24 16:35:45.699806+00	WUB CONTROL	\N	2025-05-29 13:24:10.622809+00
f18d2a7a-668d-48b9-9d2d-9cbd12e0571a	2025-05-24 16:35:45.699806+00	WUKI	\N	2025-05-29 13:24:10.622809+00
4629eb76-4459-40d3-83a7-b81f2661596b	2025-05-24 16:35:45.699806+00	WYZKI	\N	2025-05-29 13:24:10.622809+00
a6dfb807-e568-497a-8d2d-f0e33866d411	2025-05-24 16:35:45.699806+00	XAEBOR	\N	2025-05-29 13:24:10.622809+00
d3f0ecc4-70f0-4028-972b-0d33d685e340	2025-05-24 16:35:45.699806+00	XAVIER LEBLANC	\N	2025-05-29 13:24:10.622809+00
701d1735-54d8-4800-bc6b-01b1f6c8b72c	2025-05-24 16:35:45.699806+00	XCRPT	\N	2025-05-29 13:24:10.622809+00
cbaacc19-1bbb-4672-bb71-d1c44566ffd7	2025-05-24 16:35:45.699806+00	XIE	\N	2025-05-29 13:24:10.622809+00
b12cc347-a7fa-4762-83a6-e486aa6c47c2	2025-05-24 16:35:45.699806+00	XIJARO & PITCH	\N	2025-05-29 13:24:10.622809+00
cef58682-aa2a-4be6-85d5-c563eaeafe05	2025-05-24 16:35:45.699806+00	XOTIX	\N	2025-05-29 13:24:10.622809+00
9acb79a3-dd1c-4624-8620-2831dbad7b6a	2025-05-24 16:35:45.699806+00	YAKSTA	\N	2025-05-29 13:24:10.622809+00
a26f2697-0486-4e3e-adea-9058eca93c4d	2025-05-24 16:35:45.699806+00	YAM YAM	\N	2025-05-29 13:24:10.622809+00
02c71b49-c23a-46b3-a537-41b5e0c5f717	2025-05-24 16:35:45.699806+00	YELLOW CLAW	\N	2025-05-29 13:24:10.622809+00
b30d1d81-22f3-4f1a-8a37-115ef98c0d80	2025-05-24 16:35:45.699806+00	YETEP	\N	2025-05-29 13:24:10.622809+00
91f2f3b2-7222-4f54-a961-71152e5fb8b9	2025-05-24 16:35:45.699806+00	YHETI	\N	2025-05-29 13:24:10.622809+00
f00c4abe-278a-4f3c-8749-2115914ad2ce	2025-05-24 16:35:45.699806+00	YOLANDA BE COOL	\N	2025-05-29 13:24:10.622809+00
09cfa368-6726-4a2a-827b-db6056556eb4	2025-05-24 16:35:45.699806+00	YONDER MOUNTAIN STRING BAND	\N	2025-05-29 13:24:10.622809+00
fc8e9c7f-a78d-4660-bcb4-045ba5b4553c	2025-05-24 16:35:45.699806+00	YOOKIE	\N	2025-05-29 13:24:10.622809+00
332a77d1-1552-479f-93a0-25b562cf21e1	2025-05-24 16:35:45.699806+00	YOTTO	\N	2025-05-29 13:24:10.622809+00
19941ab5-7b9a-43aa-b258-10173b29dac0	2025-05-24 16:35:45.699806+00	YUKI-SAN	\N	2025-05-29 13:24:10.622809+00
944899b7-3e56-432f-8c5d-254ca43e8760	2025-05-24 16:35:45.699806+00	YULTRON	\N	2025-05-29 13:24:10.622809+00
2dbba9cf-fc7f-4719-9b52-8c585b920a00	2025-05-24 16:35:45.699806+00	YUNG BAE	\N	2025-05-29 13:24:10.622809+00
4a3fded5-ad2d-468d-aec3-7cc77a310dc0	2025-05-24 16:35:45.699806+00	YUNG VAMP	\N	2025-05-29 13:24:10.622809+00
5611d37f-c4b2-4043-91be-bb5e854a01bd	2025-05-24 16:35:45.699806+00	YVES TUMOR	\N	2025-05-29 13:24:10.622809+00
7b2af6e8-bdba-409a-898f-bce297e645db	2025-05-24 16:35:45.699806+00	ZACH BRYAN	\N	2025-05-29 13:24:10.622809+00
27613b08-3d78-4eb4-b7bf-b51aa7f2f77b	2025-05-24 16:35:45.699806+00	ZACK MARTINO	\N	2025-05-29 13:24:10.622809+00
fb8ef487-ed6f-49f5-8350-99a2b1c87da2	2025-05-24 16:35:45.699806+00	ZEBBLER ENCANTI EXPERIENCE	\N	2025-05-29 13:24:10.622809+00
cf532188-6e27-4f90-a77e-fe6e8bba1a63	2025-05-24 16:35:45.699806+00	ZEDD	\N	2025-05-29 13:24:10.622809+00
8787935e-a836-41f7-bcb0-e239701eedad	2025-05-24 16:35:45.699806+00	ZEDS DEAD	\N	2025-05-29 13:24:10.622809+00
f29f2886-57f6-4716-aa5f-910561f8921d	2025-05-24 16:35:45.699806+00	ZEE	\N	2025-05-29 13:24:10.622809+00
e9e87d59-3ebe-4bd2-9a13-9787d02610de	2025-05-24 16:35:45.699806+00	ZEKE BEATS	\N	2025-05-29 13:24:10.622809+00
9380748a-1e48-4afc-b6cd-0077ecef5e20	2025-05-24 16:35:45.699806+00	ZEN SELEKTA	\N	2025-05-29 13:24:10.622809+00
78899ff3-56e0-474c-bf4a-51f73bc42d0e	2025-05-24 16:35:45.699806+00	ZEPLINN	\N	2025-05-29 13:24:10.622809+00
2f6db5ab-7cc6-4fb5-88a2-19b5d4c54991	2025-05-24 16:35:45.699806+00	ZHU	\N	2025-05-29 13:24:10.622809+00
ac78693d-a968-42bd-8b5b-8f3eb3700729	2025-05-24 16:35:45.699806+00	ZIA	\N	2025-05-29 13:24:10.622809+00
6c162111-eaa4-4943-9004-0b6f8bf67d08	2025-05-24 16:35:45.699806+00	ZIIM	\N	2025-05-29 13:24:10.622809+00
2908d9d1-9824-4c5b-a11b-a22552fdcf1e	2025-05-24 16:35:45.699806+00	ZILLA	\N	2025-05-29 13:24:10.622809+00
91b4afa4-e104-473b-8cc6-7a31688e8e1c	2025-05-24 16:35:45.699806+00	ZINGARA	\N	2025-05-29 13:24:10.622809+00
00e4d6d6-1015-447a-a743-4616ff6971a9	2025-05-24 16:35:45.699806+00	ZOMBOY	\N	2025-05-29 13:24:10.622809+00
e43751e0-ae8d-4184-b020-22f909e5b606	2025-05-24 16:35:45.699806+00	ZOOFUNKYOU	\N	2025-05-29 13:24:10.622809+00
5b5c0cf7-c6bc-4515-9f0a-2b673fd0e315	2025-05-24 16:35:45.699806+00	ZUBAH	\N	2025-05-29 13:24:10.622809+00
9d16e7fb-13dc-4fe4-aefc-198cf833ae25	2025-05-29 02:29:05.174121+00	IC3PEAK	\N	2025-05-29 13:24:10.622809+00
dadbd065-da48-4793-b3ef-d31324c91dd5	2025-05-29 13:39:35.836064+00	TEST	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-05-29 13:39:35.836064+00
b56b2920-37bf-46ed-8ede-c810e7bf8f07	2025-05-29 13:56:21.211138+00	BOOP DOGG	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-05-29 13:56:21.211138+00
d2dc9307-0a0b-45a7-94ff-d22fff4e6121	2025-05-29 21:46:26.737869+00	PROBCAUSE	7f2169d3-894f-484f-bf65-8be242c8cd24	2025-05-29 21:46:26.737869+00
b93cf86d-6480-4418-aa5f-f8413c204711	2025-05-29 21:47:20.033494+00	OPUIO	7f2169d3-894f-484f-bf65-8be242c8cd24	2025-05-29 21:47:20.033494+00
c1c24e02-6163-4ec1-9e01-7be09048b365	2025-05-29 21:47:54.7255+00	BOOMBOX CARTEL	7f2169d3-894f-484f-bf65-8be242c8cd24	2025-05-29 21:47:54.7255+00
59524fc3-ab6c-46dd-bc3d-1206cd8add3d	2025-05-29 21:50:08.47575+00	LYNY	7f2169d3-894f-484f-bf65-8be242c8cd24	2025-05-29 21:50:08.47575+00
e36ef47e-9501-49e6-9486-bf15d790eb1c	2025-05-29 21:54:14.566551+00	THE POLISH AMBASSADOR	7f2169d3-894f-484f-bf65-8be242c8cd24	2025-05-29 21:54:14.566551+00
56128709-6076-44b7-947a-bad7ed7fcbfb	2025-05-29 21:56:47.247036+00	RÜFÜS DU SOL	7f2169d3-894f-484f-bf65-8be242c8cd24	2025-05-29 21:56:47.247036+00
ccc0cac3-9fd6-4884-beb7-3fdbd04b533a	2025-05-29 21:57:32.644037+00	POLO AND PAN	7f2169d3-894f-484f-bf65-8be242c8cd24	2025-05-29 21:57:32.644037+00
3f116bc3-cf51-4085-97d8-f07fd532555d	2025-05-29 22:00:01.898662+00	BEAR GRILLZ	7f2169d3-894f-484f-bf65-8be242c8cd24	2025-05-29 22:00:01.898662+00
b5df5cf8-999a-413e-a3f5-8d12c5998be3	2025-05-29 22:00:28.090884+00	CAPOCHINO	7f2169d3-894f-484f-bf65-8be242c8cd24	2025-05-29 22:00:28.090884+00
cc4ec826-fec6-43a5-bd2a-df79453908d7	2025-05-29 22:01:45.483625+00	DOSES	7f2169d3-894f-484f-bf65-8be242c8cd24	2025-05-29 22:01:45.483625+00
4eaaa400-d5ad-4d08-aeb2-63e77e27391e	2025-05-29 22:05:04.922208+00	LEVITY	7f2169d3-894f-484f-bf65-8be242c8cd24	2025-05-29 22:05:04.922208+00
0c88940f-d78b-406c-9f17-ecdc1b1842cb	2025-05-29 22:05:55.144149+00	ALLEYCVT	7f2169d3-894f-484f-bf65-8be242c8cd24	2025-05-29 22:05:55.144149+00
998ca517-d793-4e53-8859-fadd418da2b2	2025-05-29 22:09:17.997284+00	GREEN MATTER	7f2169d3-894f-484f-bf65-8be242c8cd24	2025-05-29 22:09:17.997284+00
1175a04b-450f-4618-b7f0-f9777600bf78	2025-05-29 22:23:29.311099+00	SAVANT	7f2169d3-894f-484f-bf65-8be242c8cd24	2025-05-29 22:23:29.311099+00
94f2f589-b501-4a61-98ff-98b802394b0d	2025-05-29 22:23:45.520643+00	CULPRATE	7f2169d3-894f-484f-bf65-8be242c8cd24	2025-05-29 22:23:45.520643+00
c7dc1662-031d-4a59-9625-02978ed4cbb2	2025-05-29 22:26:19.455655+00	ALISON WONDERLAND	7f2169d3-894f-484f-bf65-8be242c8cd24	2025-05-29 22:26:19.455655+00
86759873-08dc-42b4-8426-35ba0be89d3c	2025-05-29 22:31:38.712636+00	SKYSIA	7f2169d3-894f-484f-bf65-8be242c8cd24	2025-05-29 22:31:38.712636+00
c0bfac75-1573-4d1f-bf91-ab6689e12bfa	2025-05-29 22:33:53.832204+00	VIBELINE	7f2169d3-894f-484f-bf65-8be242c8cd24	2025-05-29 22:33:53.832204+00
de641158-86c0-427f-bc54-95fcf25431d7	2025-05-29 23:38:17.30491+00	CHOCOLATE DROP	7f2169d3-894f-484f-bf65-8be242c8cd24	2025-05-29 23:38:17.30491+00
45da4a20-9a06-4869-ad3b-e6ea35a68b02	2025-05-30 19:19:22.221272+00	CHEZ	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-05-30 19:19:22.221272+00
312d780b-61dc-4eff-9855-43474fcc67c9	2025-05-30 19:19:36.35601+00	CUALLI	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-05-30 19:19:36.35601+00
6fec28e0-d77e-4885-b235-03a36d0fb037	2025-05-30 19:20:14.477818+00	HUMANDALA	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-05-30 19:20:14.477818+00
fababe41-0154-4f1d-bb31-a6d9c548b937	2025-05-30 19:20:32.731485+00	OZZTIN	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-05-30 19:20:32.731485+00
fe56b223-e30e-4a75-9256-1a1edc43a910	2025-05-30 19:20:46.135654+00	SWOMP	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-05-30 19:20:46.135654+00
236288cd-69cc-47b9-82f4-42766ab5bfc2	2025-05-30 19:21:06.409034+00	TREE GAUD	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-05-30 19:21:06.409034+00
72584885-1655-419f-ae38-362c692576f0	2025-05-30 19:22:09.156352+00	ABSNT	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-05-30 19:22:09.156352+00
b1fed32f-f705-4e8b-a7a3-3ca93d27ec5c	2025-05-30 19:22:19.660426+00	DESACORE	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-05-30 19:22:19.660426+00
f86d8d82-9cb0-450b-b236-349e2a1e9893	2025-05-30 19:22:28.796133+00	DRAEKA	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-05-30 19:22:28.796133+00
a2f46ce9-2dfc-4d05-8d59-589ab0a503f7	2025-05-30 19:22:39.803617+00	HERICANE	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-05-30 19:22:39.803617+00
a88ca122-d2a7-43db-9e44-dcaf890b7b4e	2025-05-30 19:23:00.38585+00	MLRTYME	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-05-30 19:23:00.38585+00
2d6d7f93-8b7a-4f5a-b345-6e871fadd4c4	2025-05-30 19:23:07.736772+00	MR LANG	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-05-30 19:23:07.736772+00
19801225-6cfc-4ce1-a227-d3289c641386	2025-05-30 19:23:11.93458+00	REVIBE	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-05-30 19:23:11.93458+00
249a3111-e1de-41d2-bb88-fc509eb10055	2025-05-30 19:23:16.346386+00	SHLOP	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-05-30 19:23:16.346386+00
5745033e-0ed3-4326-be42-a2e300aeb339	2025-05-30 19:23:21.542487+00	SWEETBOI	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-05-30 19:23:21.542487+00
05f60a8b-6189-45b5-aa88-384934751dbb	2025-05-30 19:23:31.308035+00	TESLA NIKOLE	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-05-30 19:23:31.308035+00
b10f7bc8-dabf-4a90-b848-26944243f74f	2025-05-30 19:23:38.917582+00	ULTRAXVIOLET	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-05-30 19:23:38.917582+00
59c1144d-7ae2-425b-a411-28b59cb19b70	2025-05-30 19:24:15.925637+00	INDUBITABLY	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-05-30 19:24:15.925637+00
df5e983f-965c-43ef-be0c-3784d9030ece	2025-05-31 04:46:01.752181+00	FRED V & GRAFIX	c3866d1b-210f-490a-b300-bde91941735b	2025-05-31 04:46:01.752181+00
74d70d79-7c93-42aa-9f9b-20f3fe495e75	2025-06-01 03:00:36.680216+00	CYCLOPS	\N	2025-06-01 03:00:36.680216+00
df1ea834-99f2-4818-9103-f2a766a786f8	2025-06-01 03:00:37.032413+00	DAB THE SKY	\N	2025-06-01 03:00:37.032413+00
e019f0eb-7e66-4913-b533-709a8b361258	2025-06-01 03:00:38.179803+00	BOOGIET	\N	2025-06-01 03:00:38.179803+00
306b3106-f67a-4bc6-9d7d-af105f157d48	2025-06-01 03:00:39.323319+00	DEADROOM	\N	2025-06-01 03:00:39.323319+00
60209388-5b5c-4ecf-9ae2-ee094ea97bc7	2025-06-01 03:00:41.68558+00	EMORFIK	\N	2025-06-01 03:00:41.68558+00
047a687b-cf71-4bd0-885a-265c2e67a4c3	2025-06-01 03:00:42.833133+00	FUNTCASE	\N	2025-06-01 03:00:42.833133+00
58f85bdf-d31c-4928-ba9b-dcd3aeb50031	2025-06-01 03:00:43.15007+00	GHENGAR	\N	2025-06-01 03:00:43.15007+00
f3216e0c-68f6-42f9-b8af-598ac340de91	2025-06-01 03:00:43.484371+00	GORILLAT	\N	2025-06-01 03:00:43.484371+00
00522649-f2f7-4491-8f56-9c1b425096d6	2025-06-01 03:00:44.364559+00	HEDEX	\N	2025-06-01 03:00:44.364559+00
3217dc55-0db5-42b2-932b-93a455c801d8	2025-06-01 03:00:44.7745+00	INFEKTI	\N	2025-06-01 03:00:44.7745+00
23b6c9c8-a3b8-47fc-ac55-8447e4dec5cd	2025-06-01 03:00:45.102039+00	INZOI	\N	2025-06-01 03:00:45.102039+00
88b1bbc2-13f6-4302-86c7-b18e096c4151	2025-06-01 03:00:46.23856+00	JESSICA AUDIFFREDI	\N	2025-06-01 03:00:46.23856+00
e01529d6-eca0-4b4c-bcdd-9c8b2cd7e7f1	2025-06-01 03:00:46.570414+00	JKYL	\N	2025-06-01 03:00:46.570414+00
fd16d9e4-37dd-46ec-afcf-222f25099338	2025-06-01 03:00:46.747867+00	HYDE	\N	2025-06-01 03:00:46.747867+00
fa83623b-b829-419b-b92d-a703a93476ef	2025-06-01 03:00:47.373395+00	KILL SAFARI	\N	2025-06-01 03:00:47.373395+00
90733164-4d01-4262-844c-48c3ad58811a	2025-06-01 03:00:48.768968+00	LSZEE	\N	2025-06-01 03:00:48.768968+00
174658af-fc18-4a28-b8a9-2b4d940a75d9	2025-06-01 03:00:49.627671+00	MOODY GOOD	\N	2025-06-01 03:00:49.627671+00
8ceb0b93-18d6-4db2-984b-838c542eb540	2025-06-01 03:00:52.529352+00	REZZI	\N	2025-06-01 03:00:52.529352+00
219bc444-14b4-465e-953a-0a14f5c83222	2025-06-01 03:00:53.129323+00	SAMPLIFIRE	\N	2025-06-01 03:00:53.129323+00
482707af-7ba4-4458-94bc-7b6018688775	2025-06-01 03:00:53.723923+00	SIMULAI	\N	2025-06-01 03:00:53.723923+00
d28544c8-82e0-4916-92c3-97588de128df	2025-06-01 03:00:55.17637+00	SOTA	\N	2025-06-01 03:00:55.17637+00
167e742b-d72e-4ef2-95cb-6cc59a2e6eb5	2025-06-01 03:00:55.758634+00	STUMPI	\N	2025-06-01 03:00:55.758634+00
7c63a957-c3f1-46b9-8edd-fdd94efb2b8e	2025-06-01 03:16:27.010899+00	SVDDEN DEATH PRESENTS: VOYD	\N	2025-06-01 03:16:27.010899+00
65c89026-890b-483d-b3e5-0391dfa12f5c	2025-06-01 03:16:28.499177+00	VENJENT	\N	2025-06-01 03:16:28.499177+00
d6bbf497-50f7-43dc-825d-11ed40222fdb	2025-06-01 03:16:30.148596+00	AFTERXHEAVEN	\N	2025-06-01 03:16:30.148596+00
0ad8f85b-e3f9-45df-a4d1-3d4ce0d8b680	2025-06-01 03:16:30.574153+00	ALIENPARK	\N	2025-06-01 03:16:30.574153+00
8fb84757-1e1e-4823-b856-dac72d7898a0	2025-06-01 03:16:31.026783+00	ALL THE REASON	\N	2025-06-01 03:16:31.026783+00
6c9c34c6-c33e-46ed-8702-c7824c43fc58	2025-06-01 03:16:31.474291+00	AUTOMHATE	\N	2025-06-01 03:16:31.474291+00
fa6c77b9-3651-4e00-961c-020bb6fe8b28	2025-06-01 03:16:31.909518+00	AVANCE	\N	2025-06-01 03:16:31.909518+00
19130e85-db04-44f6-80d8-512a31148d3c	2025-06-01 03:16:35.458984+00	BRAINRACK	\N	2025-06-01 03:16:35.458984+00
9104987a-3565-4ca3-ad81-0b20f8f2ec48	2025-06-01 03:16:39.394731+00	CRISO	\N	2025-06-01 03:16:39.394731+00
00678654-d763-4c5d-9ef2-139377fe7357	2025-06-01 03:16:40.696977+00	DECIMATE	\N	2025-06-01 03:16:40.696977+00
2b06e12c-11b3-4aa7-8677-0724b0b59f89	2025-06-01 03:16:41.151497+00	DÊTRE	\N	2025-06-01 03:16:41.151497+00
87a51e44-6e07-4450-a756-1f1378b0db9a	2025-06-01 03:16:42.459749+00	DOMINA	\N	2025-06-01 03:16:42.459749+00
de7fe74e-5d3d-4a9c-abd7-add8f5243856	2025-06-01 03:16:45.382438+00	FLOZONE	\N	2025-06-01 03:16:45.382438+00
e8d59e5c-daae-49e9-900f-0b917ff1051e	2025-06-01 03:16:45.86255+00	FOCUSS	\N	2025-06-01 03:16:45.86255+00
9a3a5556-a998-4abc-b614-02733f67bc1c	2025-06-01 03:16:51.937538+00	IVORY	\N	2025-06-01 03:16:51.937538+00
c3bc395e-bce7-4e0c-9bff-70fab06d22b9	2025-06-01 03:16:54.118854+00	LAZRUS	\N	2025-06-01 03:16:54.118854+00
d1319b74-9daa-4c0f-9ac0-b9add934395c	2025-06-01 03:16:55.461832+00	LOUIEJAYXX	\N	2025-06-01 03:16:55.461832+00
f9c1afbb-3d91-4250-954c-d155e44eda3e	2025-06-01 03:16:56.771893+00	MACHAKI	\N	2025-06-01 03:16:56.771893+00
cad7a9a6-3df6-4d04-88db-cc784a16c460	2025-06-01 03:16:57.221454+00	MAD DUBZ	\N	2025-06-01 03:16:57.221454+00
7f6801a8-de5f-4acd-922b-3f85be6c176e	2025-06-01 03:16:59.777442+00	NEOTEK	\N	2025-06-01 03:16:59.777442+00
ed74d466-bdf2-4273-a2cd-e27dbd8d1d62	2025-06-01 03:17:00.430052+00	THE WICKED	\N	2025-06-01 03:17:00.430052+00
5e8257e2-5aa3-45da-86cf-5b835a24a2c9	2025-06-01 03:17:04.664277+00	PUSHING DAIZIES	\N	2025-06-01 03:17:04.664277+00
637b6fb5-85aa-4db3-b5b3-3ec908b4e38d	2025-06-01 03:17:05.14652+00	PYKE	\N	2025-06-01 03:17:05.14652+00
c78257db-1bd9-4ec9-9686-b3700d447f5a	2025-06-01 03:17:05.999539+00	RIOTI	\N	2025-06-01 03:17:05.999539+00
04805ebd-47c6-4a96-996a-c85626fbcf9e	2025-06-01 03:17:06.479714+00	RUVLO	\N	2025-06-01 03:17:06.479714+00
abd99ae6-81cf-4c5c-9ea6-82a5c06e8d77	2025-06-01 03:17:08.74817+00	SCAREXXI	\N	2025-06-01 03:17:08.74817+00
57dd854b-ef0f-4b07-ae43-f5178d234568	2025-06-01 03:17:09.186904+00	SHADIENT	\N	2025-06-01 03:17:09.186904+00
f78a7070-dcb0-4e74-8ab9-3cc6c999d5b8	2025-06-01 03:17:10.002734+00	SHIVERZI	\N	2025-06-01 03:17:10.002734+00
51c1e7d9-ba9a-4db6-8d68-510cf945a330	2025-06-01 03:17:10.481459+00	SISTO	\N	2025-06-01 03:17:10.481459+00
627e295c-b577-48eb-9962-51a7d1aa20cd	2025-06-01 03:17:12.689623+00	STVSH	\N	2025-06-01 03:17:12.689623+00
835c137a-81d9-4a65-a5fa-df0e2656f938	2025-06-01 03:17:13.165816+00	SUBFILTRONIK	\N	2025-06-01 03:17:13.165816+00
38d1adc9-d9df-433c-9a72-a36e4a5c701c	2025-06-01 03:17:15.320612+00	THE ARCTURIANS	\N	2025-06-01 03:17:15.320612+00
835a307e-c774-46f4-ae30-a2f4d48b1741	2025-06-01 03:17:19.631599+00	VIPERACTIVE	\N	2025-06-01 03:17:19.631599+00
341ca0a2-8234-4367-96c2-41f5fdae4e7c	2025-06-01 03:17:20.080809+00	VKTM	\N	2025-06-01 03:17:20.080809+00
d78f96f6-ae87-4140-9142-3d23164e8c80	2025-06-01 03:17:20.970555+00	VRG	\N	2025-06-01 03:17:20.970555+00
6fc7ee4e-458b-44ba-991f-3e72f93d0f75	2025-06-01 03:17:21.427315+00	WHALES	\N	2025-06-01 03:17:21.427315+00
b67d1087-31c4-4cf9-aa7d-40ef1506eb53	2025-06-01 03:16:32.338933+00	BADGER	\N	2025-06-01 03:16:32.338933+00
04cb7168-9a94-4f1b-9a83-5a18396cca75	2025-06-01 03:16:32.806479+00	BADKLAAT	\N	2025-06-01 03:16:32.806479+00
d8d45d2e-b6dd-4552-a1a4-dd0f1aaa99b1	2025-06-01 03:16:33.276164+00	BADVOID	\N	2025-06-01 03:16:33.276164+00
6c9cb39f-27be-40d8-872c-c311036cd5f0	2025-06-01 03:16:36.692541+00	CHASSI	\N	2025-06-01 03:16:36.692541+00
8c0ec8fd-72f5-453e-a0cf-2802245ca916	2025-06-01 03:16:37.960978+00	CODD DUBZ	\N	2025-06-01 03:16:37.960978+00
14d2fecb-ccc7-4f87-a4d3-b91aecc193b0	2025-06-01 03:16:41.619155+00	DEUCEZ	\N	2025-06-01 03:16:41.619155+00
b3ccddb5-ac26-4bb8-a7d2-b895bbf66e7c	2025-06-01 03:16:42.939868+00	DR. USHUU	\N	2025-06-01 03:16:42.939868+00
ed7c3117-8c6a-47c9-903d-eeddd9dbde40	2025-06-01 03:16:43.406742+00	DREAM TAKERS	\N	2025-06-01 03:16:43.406742+00
44e4f2e4-9ebc-4533-937d-d41a0e00cd5e	2025-06-01 03:16:43.873886+00	EATER	\N	2025-06-01 03:16:43.873886+00
ba3ab646-9007-4ffa-ba1c-a8a11a1887ca	2025-06-01 03:16:47.976782+00	GUNPOINT	\N	2025-06-01 03:16:47.976782+00
5cad1267-d80d-4edd-990f-9af160cca717	2025-06-01 03:16:49.355877+00	HEXXA	\N	2025-06-01 03:16:49.355877+00
9db4595a-8717-4743-8f37-d427aeda2111	2025-06-01 03:16:50.250867+00	HUMANSION	\N	2025-06-01 03:16:50.250867+00
f53f4d2a-cbbf-4d68-9de5-48c3bbbdd8eb	2025-06-01 03:16:50.727289+00	HURTBOX	\N	2025-06-01 03:16:50.727289+00
f56970a6-b2b2-4835-b4ae-cbc079b9572e	2025-06-01 03:16:52.443699+00	JIQUI	\N	2025-06-01 03:16:52.443699+00
9e9d9143-ee2e-478b-9192-e7b8af049855	2025-06-01 03:16:57.676623+00	MANTIS	\N	2025-06-01 03:16:57.676623+00
0ac486af-f2ff-44de-8fcb-94ed5fc22b0b	2025-06-01 03:16:58.119824+00	MASHBIT	\N	2025-06-01 03:16:58.119824+00
46b22946-8d5d-4a82-bdc5-2d80e4c4ae16	2025-06-01 03:16:58.92339+00	MUERTE	\N	2025-06-01 03:16:58.92339+00
b47be5d0-7f44-4357-b934-74c00fd2e0a1	2025-06-01 03:17:00.222889+00	NIKITA	\N	2025-06-01 03:17:00.222889+00
fae66ce7-2cce-43bc-aa03-42421fb5ecba	2025-06-01 03:17:00.881779+00	NIMDA	\N	2025-06-01 03:17:00.881779+00
e0459022-45d4-46fc-8c16-bbe4d1fd02e6	2025-06-01 03:17:01.359061+00	NITEPUNK	\N	2025-06-01 03:17:01.359061+00
14414e78-198a-47dd-8ddd-07c6c382265c	2025-06-01 03:17:02.249296+00	OKAYJAKE	\N	2025-06-01 03:17:02.249296+00
28cacff2-92e3-4fb1-8171-ef6f479a9bcf	2025-06-01 03:17:02.710537+00	PAPER SKIES	\N	2025-06-01 03:17:02.710537+00
697ff785-bd47-43e8-b39a-1e12f9d3cfec	2025-06-01 03:17:03.165881+00	PERRY WAYNE	\N	2025-06-01 03:17:03.165881+00
9faf7810-0fda-4d65-aead-6f193cf0814e	2025-06-01 03:17:06.980009+00	RYNS	\N	2025-06-01 03:17:06.980009+00
ac3871d0-4c75-4b49-bad5-e7a84c364946	2025-06-01 03:17:07.480045+00	RZRKT	\N	2025-06-01 03:17:07.480045+00
6d27a68e-1ab3-4f96-8d00-90b2a1c8b0f0	2025-06-01 03:17:15.808078+00	THE RESISTANCE	\N	2025-06-01 03:17:15.808078+00
649cc4f8-0120-4cee-8761-bd2d1a9bfdc2	2025-06-01 03:17:16.301037+00	TISOKI	\N	2025-06-01 03:17:16.301037+00
927c13e0-2eac-4efb-9136-6657ea744a6e	2025-06-01 03:17:16.760645+00	TORCHA	\N	2025-06-01 03:17:16.760645+00
ceaf01d3-aec1-4e24-8636-6ad63d7f2a78	2025-06-01 03:17:18.215264+00	USAYBFLOW	\N	2025-06-01 03:17:18.215264+00
edb54d68-cbb2-4fb9-b552-9d936ce13154	2025-06-01 03:17:21.873796+00	WILEY	\N	2025-06-01 03:17:21.873796+00
9f3ff3b1-47cd-4d58-88eb-d9949440252a	2025-06-01 03:17:22.345321+00	WODD	\N	2025-06-01 03:17:22.345321+00
8a35f5a4-0a8b-4470-98c4-9c3db2d1bfab	2025-06-01 03:17:22.821496+00	WONKYWILLA	\N	2025-06-01 03:17:22.821496+00
26fc74e0-e7c8-4295-ade2-3a1de27eac5a	2025-06-01 03:17:24.244042+00	YOSUF	\N	2025-06-01 03:17:24.244042+00
e498a430-fa7b-4072-a0c1-d3b6b6157b4c	2025-06-01 03:16:33.722+00	BEASTBOI.	\N	2025-06-01 03:16:33.722+00
e85bda01-a523-4e15-b805-229d4c03b02e	2025-06-01 03:16:37.156421+00	CHIBS	\N	2025-06-01 03:16:37.156421+00
5f746639-90a4-428a-a971-0794a0d5d330	2025-06-01 03:16:38.441686+00	CONTRA	\N	2025-06-01 03:16:38.441686+00
9d23165d-6952-471a-928c-57ee7f9fecab	2025-06-01 03:16:44.351564+00	EDDIE	\N	2025-06-01 03:16:44.351564+00
1082f781-fe16-413b-aa30-4f1601348307	2025-06-01 03:16:47.128121+00	GHOST IN REAL LIFE	\N	2025-06-01 03:16:47.128121+00
353584db-3709-4c3c-9d35-db52e86425a1	2025-06-01 03:16:48.455216+00	HAMRO	\N	2025-06-01 03:16:48.455216+00
6d6d1600-f4aa-4d35-a3f5-3afe6d850660	2025-06-01 03:17:03.651177+00	PHOCUST	\N	2025-06-01 03:17:03.651177+00
785c5ccc-4601-48cb-96fc-ea26795f36a7	2025-06-01 03:17:11.73182+00	STONED LEVEL	\N	2025-06-01 03:17:11.73182+00
be5ebc3b-dcd4-4f06-b02d-a3d36fd36081	2025-06-01 03:17:17.351301+00	TWOPERCENT	\N	2025-06-01 03:17:17.351301+00
beb589c5-a55b-44a4-9d54-b746a0804b5a	2025-06-01 03:17:18.690851+00	VASTIVE	\N	2025-06-01 03:17:18.690851+00
12763e43-a9fb-431d-a8eb-47f1fa175e8d	2025-06-01 03:17:23.387959+00	WRAZ.	\N	2025-06-01 03:17:23.387959+00
196e61b2-5f11-4627-8278-d5195ff5663e	2025-06-01 03:17:24.794104+00	LCN	\N	2025-06-01 03:17:24.794104+00
802340ec-f288-4a91-a9d6-4ae203c485f2	2025-06-01 03:16:38.919364+00	CONTROL FREAK	\N	2025-06-01 03:16:38.919364+00
a518e470-7921-4baf-baff-a76e14858ac8	2025-06-01 03:16:40.247201+00	DAGGZ	\N	2025-06-01 03:16:40.247201+00
35832705-682a-4c8a-8b27-66799add85df	2025-06-01 03:16:44.942771+00	FAIRLANE	\N	2025-06-01 03:16:44.942771+00
cd12fb3e-ebfd-464e-a9c1-87fa567f2bed	2025-06-01 03:16:53.656947+00	KLIPTIC	\N	2025-06-01 03:16:53.656947+00
7fafec9c-d345-434e-848a-16c483beb506	2025-06-01 03:16:55.011224+00	LIQUID SMOAK	\N	2025-06-01 03:16:55.011224+00
9a3b7737-0b86-4157-b903-1751992276c8	2025-06-01 03:16:56.319236+00	M?STIC	\N	2025-06-01 03:16:56.319236+00
d4db4d8c-3c84-460c-8d0f-16bdf66dc245	2025-06-01 03:17:04.105312+00	PROSECUTE	\N	2025-06-01 03:17:04.105312+00
61aac405-a84b-467b-81d4-4721710d3548	2025-06-01 03:17:12.170315+00	STÖÖKI SOUND	\N	2025-06-01 03:17:12.170315+00
375774d6-4803-428a-a838-104f0646a1ea	2025-06-01 03:17:19.159652+00	VERSA	\N	2025-06-01 03:17:19.159652+00
b4dc2171-a97a-48c7-bc28-f720a079690f	2025-06-01 03:17:25.289258+00	VRG W	\N	2025-06-01 03:17:25.289258+00
cd51ef2d-109b-4319-abc8-b3a6fefe3973	2025-06-01 04:00:16.936746+00	MYRIAS	06082977-180b-4170-a3d5-72f7005652a9	2025-06-01 04:00:16.936746+00
e7e95fb5-597c-41f5-bfbc-a130c340f68a	2025-06-01 05:19:22.417706+00	COSMIC WAFFLE	9547e1f9-306e-4dd2-96fb-89fc33ce7512	2025-06-01 05:19:22.417706+00
3d70d102-ff6c-4720-ade3-0b1e25a30336	2025-06-01 05:19:48.117632+00	WAVETONIX	9547e1f9-306e-4dd2-96fb-89fc33ce7512	2025-06-01 05:19:48.117632+00
\.


--
-- Data for Name: b2b_sets; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.b2b_sets (id, name, artist_ids, created_by, created_at, fingerprint) FROM stdin;
9008c542-036b-42b9-b503-8820f01b5935	EXCISION B2B SUBTRONICS	{87b41ea5-c560-4722-9176-9a2b14d8cce5,2ff236d1-79c7-4024-82e2-36ab8448b544}	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-06-01 00:55:39.761113+00	2ff236d1-79c7-4024-82e2-36ab8448b544,87b41ea5-c560-4722-9176-9a2b14d8cce5
64471ea9-9b29-4012-a9df-a43777525bcc	12TH PLANET B2B21 SAVAGE	{1441b842-428f-4f72-aa0c-394f3c565028,e70b0cc4-446f-4e46-8236-0a5f5cb934c1}	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-06-01 01:10:03.0551+00	1441b842-428f-4f72-aa0c-394f3c565028,e70b0cc4-446f-4e46-8236-0a5f5cb934c1
76731565-3880-4502-bc49-396c20086027	100 GECS B2B21 SAVAGE	{1441b842-428f-4f72-aa0c-394f3c565028,c225abe4-6747-44a4-b89b-98389549d504}	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-06-01 02:13:39.518274+00	1441b842-428f-4f72-aa0c-394f3c565028,c225abe4-6747-44a4-b89b-98389549d504
6388f0cc-242e-4c15-980e-868b471cdbc3	12TH PLANET B2B A HUNDRED DRUMS	{b0201b37-2235-4f7d-8003-1a997ce45ec7,e70b0cc4-446f-4e46-8236-0a5f5cb934c1}	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-06-01 02:16:10.782152+00	b0201b37-2235-4f7d-8003-1a997ce45ec7,e70b0cc4-446f-4e46-8236-0a5f5cb934c1
617523cf-4675-4064-b4bc-c0a06e8b6d53	MPORT B2B TVBOO	{a086100e-92d9-4f7a-a69d-82ea9e2661d3,ed77a0a0-b6f7-40da-9c65-c1da43a57b18}	06082977-180b-4170-a3d5-72f7005652a9	2025-06-01 05:24:40.174067+00	a086100e-92d9-4f7a-a69d-82ea9e2661d3,ed77a0a0-b6f7-40da-9c65-c1da43a57b18
\.


--
-- Data for Name: event_set_artists; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.event_set_artists (set_id, artist_id, event_id) FROM stdin;
84d8766b-ba81-4c70-ab2b-660d94f523eb	db20f866-7a4c-4332-bf46-3fad46432c32	\N
e2329188-5f97-43c6-bd76-26fff75ba291	87c114d4-b366-4ed0-a238-6d6c06df12a8	\N
e2f01aef-6691-4e1d-834e-61dd66c0a591	0c88940f-d78b-406c-9f17-ecdc1b1842cb	\N
998eff6c-a020-4755-ab2f-60043d1cbf0e	ed95cba1-893a-4d90-b88f-3b732fc775a8	\N
54ebe86e-b22c-418b-98b2-e02f812ddd78	c64a7496-30b4-47d8-8182-9a98a8fed3ee	\N
9d89cf96-99cd-42f9-b6fc-81033f4f472e	e10642bc-41a4-4508-a333-2ecb6c9d3f17	\N
33de02c9-54b9-49d8-bb36-bd040d92962f	3f116bc3-cf51-4085-97d8-f07fd532555d	\N
588f9962-947a-40f9-a3a7-6ae4af9638ca	74d70d79-7c93-42aa-9f9b-20f3fe495e75	\N
7ecb507f-ef68-4b45-bff8-b434a2a7453b	df1ea834-99f2-4818-9103-f2a766a786f8	\N
ececa5f0-50bc-42e5-99fe-92ecaf957349	2738faf7-37f0-4185-949a-89cfd3886c0a	\N
14e1d9b8-bd6a-4c4a-b978-11f34920d57d	10889bf3-e3b6-483c-8db1-d3c56b2116a1	\N
4048ca94-2e91-4a46-ad41-42b7336d3362	c13a2416-037d-4923-97f7-fd7642373ec8	\N
dd48b403-ca91-4c4f-83e4-246dbe1f82ad	e019f0eb-7e66-4913-b533-709a8b361258	\N
20c14211-7270-481d-92a8-e698d31416f2	ea8fa0e5-508f-48a1-8f7f-e1a92ba7eada	\N
2d454029-f321-4d06-aab2-fa0700f5a4df	a0b3fdde-922b-4ad8-97c9-1680acde14c6	\N
f3b33507-8548-4c37-98b7-49b02515a146	adfc4748-e24f-4717-9871-614c621b8abf	\N
c52f83c8-8ffd-4ee5-9b3b-a451a8ab666c	306b3106-f67a-4bc6-9d7d-af105f157d48	\N
0b5f5222-901c-4783-b7b9-0ad0ec1fdd26	a21aa284-cf62-4345-aabf-2195094d6c63	\N
019b2ca2-d81f-4f35-8899-03cfeddc2f5e	87b41ea5-c560-4722-9176-9a2b14d8cce5	\N
fab66451-b981-497d-9297-704b1e0e8573	3d1b7778-c1e7-441c-8b7d-a960905a60f4	\N
3db32862-276a-491a-b497-2aecdbcc615d	33391ef7-8678-445a-b96e-74e868f15393	\N
793cfe7c-f39b-454a-a554-e0ff208e1209	35e7c4f0-e39b-4d60-8b67-931a2280b494	\N
baab080f-0634-4ec9-8118-d4b2ef5850c1	82b3a6d3-7751-4fa9-810d-c8f65bdd4735	\N
c8dc2c2a-e7dd-4ffa-a883-40b4b1d4c568	69f9dfec-af6a-4db1-b864-bd7bf83fd4e1	\N
a6ba73ba-9619-4f97-ba6a-55a473ec0ecd	5433d511-91ae-47d4-9300-b60debf25374	\N
2104deb3-e969-424f-944a-a1c40eea8fe6	60209388-5b5c-4ecf-9ae2-ee094ea97bc7	\N
b290a994-f42a-4d39-9295-e04b145d683a	cd7a8718-db44-4ef9-b39d-a33828286d63	\N
47f0cfbc-826f-42a8-9b9c-3adecd022516	87b41ea5-c560-4722-9176-9a2b14d8cce5	\N
5743aabc-e8de-42cf-ba08-2b5787236522	87b41ea5-c560-4722-9176-9a2b14d8cce5	\N
5743aabc-e8de-42cf-ba08-2b5787236522	2ff236d1-79c7-4024-82e2-36ab8448b544	\N
2456d584-01fa-418e-8776-e7873b4c3e40	047a687b-cf71-4bd0-885a-265c2e67a4c3	\N
56245968-b6db-4c3c-bbe7-73089d2a1eed	58f85bdf-d31c-4928-ba9b-dcd3aeb50031	\N
4f1601f8-792d-45be-9407-c1ce6d2647d3	f3216e0c-68f6-42f9-b8af-598ac340de91	\N
2cbec768-d803-43af-bd86-8ccd98a92394	c41316c0-b177-4c9d-b8b7-097988b9534f	\N
8a8b4ed5-61fd-4f39-84ee-cb72f1225b09	47be4daf-5aa2-4064-9885-c142ce1f2e70	\N
a44d8000-ecd6-45ec-82d0-d9508e5dcfad	00522649-f2f7-4491-8f56-9c1b425096d6	\N
d68d8793-094d-4c91-b552-df458a358575	3217dc55-0db5-42b2-932b-93a455c801d8	\N
2a007b87-a50c-481e-ae55-a40fc2eb89e2	23b6c9c8-a3b8-47fc-ac55-8447e4dec5cd	\N
f588f8cc-a9d8-4ea4-80f6-e4754a14afc2	cfb93b76-9df9-4359-8757-384063e62ef2	\N
bc41eb76-71d7-4593-8ac3-841a45a54433	312b7a85-2a3c-4c22-ab67-c6b164c34c76	\N
0f670b06-376d-4c43-8f8d-6c6896d0711d	032f8fe8-3b19-4c7e-a3fb-dd00b3ec0bfe	\N
0de554be-2c47-49b1-bb45-fb99ad173aca	88b1bbc2-13f6-4302-86c7-b18e096c4151	\N
785a0640-ad8e-4c3e-b0ef-a07dd4adcaf2	e01529d6-eca0-4b4c-bcdd-9c8b2cd7e7f1	\N
785a0640-ad8e-4c3e-b0ef-a07dd4adcaf2	fd16d9e4-37dd-46ec-afcf-222f25099338	\N
39e1b4e9-680c-408b-bd1a-778583586ac4	e114cf87-7ded-4b01-8fcb-2e3be7ae874e	\N
80df8f7b-1b2a-4e54-8da1-42095f49c0b1	fa83623b-b829-419b-b92d-a703a93476ef	\N
1e64d177-9228-43a2-b84e-0a66b51af8e6	8d70afd4-c541-4a0e-9fa4-40b0271f4d69	\N
f634cb18-000a-42ca-9b4a-82371db9b1c5	47e0528e-a7f5-4d6f-a6cc-167b5891efde	\N
569aa501-fc8c-4771-88df-a675a6197e26	08b5d3e4-5720-443e-ab15-d79d4cbab070	\N
f34d358b-11d6-42b1-b64c-e87ee227e840	1c32cf44-79e3-4c2a-b52a-8f7d33454d97	\N
bef28ab9-83fd-4a28-a2e0-654c894eefcd	90733164-4d01-4262-844c-48c3ad58811a	\N
4b9922b0-8a27-45ae-b84a-b1d2034a9bb4	59524fc3-ab6c-46dd-bc3d-1206cd8add3d	\N
d712e5d9-21e2-4ec5-ba20-46da66af7701	11ab2bff-caf6-4824-b632-1c3fde9886c1	\N
81a2cea9-7185-4fef-b849-27701f9e95f5	174658af-fc18-4a28-b8a9-2b4d940a75d9	\N
c871b26f-83a2-43e5-90c3-43e9641f42fa	2b62d188-c0f0-4333-bb44-2e1a70fab6ae	\N
56275bb0-34bf-4607-960c-d990e6526b37	73629646-a622-4f56-9ae7-eb0bd6914c20	\N
91fd681c-f598-419d-8106-c632a83c5efe	70ecbbb3-d239-4e8d-8d8c-f17f4d46a17f	\N
f86035c1-aeb3-4eec-9cdb-0f9668a8fefc	e8e7b6e8-8153-4363-a5e8-5eaf4219b1ff	\N
5203df64-6fb2-4c28-869c-e6913751921b	dcb49616-3db2-439e-8e94-c4eba88edfbd	\N
acfba784-4e08-4980-a875-b50f3f5aff20	4c5325ac-f7b1-47ab-b3d1-7d5ce3535c55	\N
daf2daaf-3469-49a5-a569-694072cb5f53	65f67e0c-79dd-4c6a-823a-297a3c2cf3d4	\N
d38084f4-9e43-42f9-8969-8cb599b20b38	baa43c55-7964-4641-a10c-3d48b4687e61	\N
3fadf773-7be1-42a4-98f4-f655d435a59b	09bcd870-e9c0-4e32-af0b-645558f64e44	\N
9c0ef3c0-2055-4483-a345-b964de9e4bef	aa842970-ec6d-42a0-bc4a-807050a097d5	\N
df194a68-0f2f-4a3a-9739-ef4ed1e7b97b	8ceb0b93-18d6-4db2-984b-838c542eb540	\N
523702a6-1185-4171-9141-6f9144e22320	ffd5d1c9-76fd-4617-8528-a37c486f4321	\N
7a927525-5f8d-4cac-9698-71c53652c28b	219bc444-14b4-465e-953a-0a14f5c83222	\N
4be64b4c-11c8-498e-a951-10218b3d0d41	4f031ee2-2f9d-4a73-87da-a06ac2a72a9b	\N
8a649159-62e8-422a-933b-e8422d5bfc9b	482707af-7ba4-4458-94bc-7b6018688775	\N
9b139b6f-a231-483e-9fc0-9221ab95a12f	923937af-4c37-4296-b7f6-4397b9adfaf3	\N
b857101d-bcb9-46e4-819f-288a6a266ebd	d7fb7f0a-d3e8-47f8-94d9-fbe97d066394	\N
9ef9635d-5cbd-43b4-99f0-d5e80873eb6a	576eb744-cdb3-4b16-a31d-6ab49e7a3e89	\N
a102a0e7-f545-46fd-b370-a6ec2053855c	da8c5bfd-22a7-4bd9-9817-c52e2c13897b	\N
f7893f04-57d5-4eff-89c4-33318ee83417	d28544c8-82e0-4916-92c3-97588de128df	\N
62c58d0e-88cb-42a8-a519-e12433738905	05da7f3a-6b1b-4046-9e17-efaaad1013b8	\N
99572902-b0f4-4b02-883b-69252feda4b2	167e742b-d72e-4ef2-95cb-6cc59a2e6eb5	\N
67bb6794-a2ca-4bc4-aa84-a06ebe9f638b	b2bac8b5-7e3c-45f5-a9b2-ee98cce286c1	\N
8afb04ac-a954-44ad-a542-a3204d0abf02	7c63a957-c3f1-46b9-8edd-fdd94efb2b8e	\N
38b85cbd-125f-4a70-b650-5a8013f7c42c	7e37c869-3c43-44e1-a933-5530e4db2d5d	\N
eb062424-1be6-4e5c-88c0-49d26ed63ddc	62aeac50-58e8-46a2-87ee-38407d84b9dd	\N
857a21a8-0147-46cf-98fb-5aa9bad1e334	9cd279b9-bace-4408-bf0e-7e44a68f2a1a	\N
f68c76c1-419b-4936-a1da-6e8bd83bfa30	65c89026-890b-483d-b3e5-0391dfa12f5c	\N
4f75c5ff-6991-4974-9300-41d0cb7b4d66	4b441a88-0f24-4023-9166-7caeee61c9db	\N
1f7d3553-b847-4b6d-b5eb-77235e94faaa	d3046501-1cc4-4f36-bea6-fdcba9ceac7c	\N
633ff831-a573-4f09-97b6-3ff4bcae69f1	91b4afa4-e104-473b-8cc6-7a31688e8e1c	\N
88abd92e-3456-4755-8b2f-44a35e7e9db2	d6bbf497-50f7-43dc-825d-11ed40222fdb	\N
d924dc54-c80b-465e-ab5b-a5dec21565f8	0ad8f85b-e3f9-45df-a4d1-3d4ce0d8b680	\N
3f433ebf-aae2-4b24-a853-d32305d84c8d	8fb84757-1e1e-4823-b856-dac72d7898a0	\N
b849b4f9-983a-423d-b4b8-5967976bb815	6c9c34c6-c33e-46ed-8702-c7824c43fc58	\N
7f1a0271-770e-4a17-b711-09238352f083	fa6c77b9-3651-4e00-961c-020bb6fe8b28	\N
4b44efdb-e9a7-490a-8c25-a6650db981f4	b67d1087-31c4-4cf9-aa7d-40ef1506eb53	\N
c0beb2bd-f426-43ff-bce0-86c69a79c7be	04cb7168-9a94-4f1b-9a83-5a18396cca75	\N
c32a27a4-f252-4808-96d7-98fb4591aef3	d8d45d2e-b6dd-4552-a1a4-dd0f1aaa99b1	\N
41678674-2f44-4d8c-b67b-2a03179d78af	e498a430-fa7b-4072-a0c1-d3b6b6157b4c	\N
56d73f81-f850-42fc-8265-0d9cb42b2afb	b49b8a41-618d-4f17-a07a-bca2538439f3	\N
076980cc-1709-4cb2-81bb-8f51cac691f8	1dfae29e-a0e2-48b0-b3ef-77b217e61715	\N
5d473a0e-ff0b-45c8-ab5a-d609bc9eb68f	a8f0cdf1-0dc0-4f5d-8443-8e1802f799bc	\N
e99100ca-6bea-4e2a-ac4b-f664de8da4e7	19130e85-db04-44f6-80d8-512a31148d3c	\N
6d674cd7-3718-4626-8d22-63cfebe6bba1	bda40a00-6f80-4934-8687-2e2946e207c9	\N
8a728440-6cc5-4ced-8067-cc12bea8cd48	b5df5cf8-999a-413e-a3f5-8d12c5998be3	\N
087ae26a-66e7-41a7-9288-f585cd354eea	6c9cb39f-27be-40d8-872c-c311036cd5f0	\N
fecd8080-0d3d-4829-8df0-737dac3794d6	e85bda01-a523-4e15-b805-229d4c03b02e	\N
89dd7de7-1092-4ccd-bdf9-056e61ae2cb9	4b5837f1-f7fe-423f-a027-ce6e9699f200	\N
a54fa50b-de99-4cd0-9651-e8a96c409a77	8c0ec8fd-72f5-453e-a0cf-2802245ca916	\N
7d26ef97-970b-4de9-9a8d-4ebcd97e4bb9	5f746639-90a4-428a-a971-0794a0d5d330	\N
d1a584a1-7fba-4a20-898d-82056ebb77c6	802340ec-f288-4a91-a9d6-4ae203c485f2	\N
adce45ad-10a9-44c0-9cfa-1dd3e5e25bb9	9104987a-3565-4ca3-ad81-0b20f8f2ec48	\N
4ea379f8-6c07-4e74-8b3b-bd7794fbe2df	ae79e033-31dc-4d71-ab55-b0494eb7faa7	\N
d17c3c86-5ab0-408d-af57-f260644a4874	a518e470-7921-4baf-baff-a76e14858ac8	\N
245fb3ba-d511-449f-8415-459b30f2234b	00678654-d763-4c5d-9ef2-139377fe7357	\N
a93d62af-d96c-4ead-bc97-b1a697372852	2b06e12c-11b3-4aa7-8677-0724b0b59f89	\N
93391781-e984-4ad6-b1d5-c74233b40956	14d2fecb-ccc7-4f87-a4d3-b91aecc193b0	\N
98495b7c-2964-4f7f-b930-c5508b0c573f	646ec18b-fee7-4b20-aa8c-c274d6c7a440	\N
78835b21-7b73-4ff5-91c3-3a5ab6809e37	87a51e44-6e07-4450-a756-1f1378b0db9a	\N
67f210d4-ef02-47aa-92ee-fea9cf873c58	b3ccddb5-ac26-4bb8-a7d2-b895bbf66e7c	\N
de971a93-4704-4225-a40d-38297e423291	ed7c3117-8c6a-47c9-903d-eeddd9dbde40	\N
c071306d-a540-408b-8c70-86a4599cf19d	44e4f2e4-9ebc-4533-937d-d41a0e00cd5e	\N
d4d06314-7a12-4e8b-a15f-7fbfa47a56e6	9d23165d-6952-471a-928c-57ee7f9fecab	\N
27da91f1-f1ef-436b-9df9-6f1120bfd985	35832705-682a-4c8a-8b27-66799add85df	\N
0f7f38fe-8db5-415a-835a-612d4edf2854	de7fe74e-5d3d-4a9c-abd7-add8f5243856	\N
8d58167a-0cc3-4b10-aa67-ac931c691b94	e8d59e5c-daae-49e9-900f-0b917ff1051e	\N
1aef572e-77a8-476d-9d5c-29c0501f3437	f91106ff-53df-4ebb-a44a-9715115ac2a0	\N
f92c1054-573b-4343-8d6c-4796754d967d	520a5fe5-3c1f-452e-80f0-122260e49497	\N
72dec661-a83c-4fea-9181-25de1711e986	1082f781-fe16-413b-aa30-4f1601348307	\N
0e6fdbe1-a278-4e7e-93b5-3a04565e28e1	eb558179-dba1-4ddf-b392-0d9af9d40e3e	\N
e2bb7126-1d0f-4f8e-b3c2-0fc540ee8d07	ba3ab646-9007-4ffa-ba1c-a8a11a1887ca	\N
e64d523a-1bd3-4a54-8845-79d3ae840885	353584db-3709-4c3c-9d35-db52e86425a1	\N
0f4c304e-387c-43b8-8357-8631d4ab6132	c7b9a5f6-2c6d-4304-b8a6-4624d8bca27c	\N
0f2c2056-bc42-466a-808a-e335027d54ad	5cad1267-d80d-4edd-990f-9af160cca717	\N
b1940707-739c-4b09-be9c-086e5e4c912c	ff0890bd-97e9-43b0-be9f-6a38aed71d3e	\N
ee759d23-6dbe-46ee-b5cb-792a37c70eb4	9db4595a-8717-4743-8f37-d427aeda2111	\N
062c8f1d-fdae-46b2-b81a-08df913c3c18	f53f4d2a-cbbf-4d68-9de5-48c3bbbdd8eb	\N
1efe6324-e951-4251-a32a-9dd076b3fc35	5e4c41bb-f708-4c8b-ba0a-b849f66645f0	\N
c2597af5-d9f0-4944-9520-dfc285ba1659	c12473f3-6818-43ec-b547-22773a403e5e	\N
9886a94c-6432-4d21-86f5-b74fafb219eb	9a3a5556-a998-4abc-b614-02733f67bc1c	\N
7e513aff-44c9-40f2-b1dd-2e344665fa28	f56970a6-b2b2-4835-b4ae-cbc079b9572e	\N
8f5eb443-9d68-40b1-8c5d-70e52cb0cca6	f05a3773-5847-4f8d-b0d2-706f0004e5cd	\N
e5d33305-41e7-4e99-bcfb-0ece79776d6f	c3bc395e-bce7-4e0c-9bff-70fab06d22b9	\N
0a38ba54-d686-4090-ba37-9015eef72de9	d1319b74-9daa-4c0f-9ac0-b9add934395c	\N
0923cd94-8808-46d2-8cad-0752e9b29556	f9c1afbb-3d91-4250-954c-d155e44eda3e	\N
35dfa3ec-0c88-48ce-9eca-eb20a63df7fd	e1524bfa-4479-45a1-9504-9f90764112f5	\N
4fe9ee55-b1f7-412a-ac58-e9da1d0a79ea	5e8257e2-5aa3-45da-86cf-5b835a24a2c9	\N
1598f25e-47ea-4969-a4b4-5b3cd417e587	c78257db-1bd9-4ec9-9686-b3700d447f5a	\N
e256a70e-ec72-428c-ad44-fb5647902da3	abd99ae6-81cf-4c5c-9ea6-82a5c06e8d77	\N
2447e5e9-de74-4cb7-a5c2-3c7bedcb793a	f78a7070-dcb0-4e74-8ab9-3cc6c999d5b8	\N
9d7a28a3-cb9c-421d-80aa-3a5da5acf7e5	627e295c-b577-48eb-9962-51a7d1aa20cd	\N
da08e58b-146a-4080-903d-8490555876f8	b6582170-250f-4c8f-940b-f8422b2dc3a1	\N
dc68172b-e435-4b05-874a-c11561b5d04c	b801b40b-6ddc-4c7e-96cc-6e4802043bba	\N
00a4498a-cc2a-49d2-aa38-26579accfd5e	f7e847ff-fb32-42f9-a545-e906f6b9ed0e	\N
a2019523-d76f-48a8-bac9-b1ae965ac77c	2eb51647-373d-4a11-9a30-dbe1a4ba0789	\N
9c2ba381-006d-4424-a0d7-01f9575b6fef	6d6d1600-f4aa-4d35-a3f5-3afe6d850660	\N
21bcd165-500c-4785-aadb-28f2a394862a	785c5ccc-4601-48cb-96fc-ea26795f36a7	\N
01211aa1-ec89-4032-8001-ea26f9b6b179	cd12fb3e-ebfd-464e-a9c1-87fa567f2bed	\N
6cabb71d-5c2a-4805-9dd0-c151c798bcba	7fafec9c-d345-434e-848a-16c483beb506	\N
526d81bb-4b31-48ca-9a21-6e65e4db9150	9a3b7737-0b86-4157-b903-1751992276c8	\N
340c1444-9e0f-4b4e-b8ff-137392f01379	d4db4d8c-3c84-460c-8d0f-16bdf66dc245	\N
23df5e9a-3656-4809-bdf3-be05b7c73a6c	f3a06d38-66fe-4693-9574-49622eb9493c	\N
fb9164e7-10d0-41ae-9623-d0ee05ca6f61	c8347d37-a45d-489d-8bcf-0010db6cd2cb	\N
124ac509-5755-4077-a81b-7b3c43df352f	6d97d81b-01c0-4c37-a28f-d2067f3e9509	\N
6bb37d93-fc61-4529-9e85-6e3526827145	bd506168-2866-4116-b39b-2160ee41240b	\N
30d90fdb-7ac2-4c92-aa77-7dc7cbede159	61aac405-a84b-467b-81d4-4721710d3548	\N
e787e40e-8e57-41a4-adcf-706ed453e62e	1935575c-6b2b-4f41-b8fc-edd258397c2e	\N
5952aa3b-057f-47de-b73c-ef63e596e26d	cad7a9a6-3df6-4d04-88db-cc784a16c460	\N
83c8fe9e-c0b6-4bfb-b07f-2bdd390094f5	e1aeebae-5de3-4b93-bb0c-8d014928af69	\N
a5365d66-de7e-44bc-a182-3c9353e3df81	7f6801a8-de5f-4acd-922b-3f85be6c176e	\N
37a9111b-61f0-4582-8d0a-c1c00ffff449	b47be5d0-7f44-4357-b934-74c00fd2e0a1	\N
37a9111b-61f0-4582-8d0a-c1c00ffff449	ed74d466-bdf2-4273-a2cd-e27dbd8d1d62	\N
bbbe0994-c07c-4fd9-9f00-34e9de9b9ef4	b95e06f2-6341-4ada-8d88-ce0c760e8df0	\N
5e14d7b3-c740-4cdf-af83-43ffbab5d1ef	637b6fb5-85aa-4db3-b5b3-3ec908b4e38d	\N
bdf8666a-c644-4d13-82ae-d28a33afb2f6	04805ebd-47c6-4a96-996a-c85626fbcf9e	\N
6c8990b4-4002-4de1-827c-01c68440225f	a5df90d4-c578-4d14-a1ea-4ef52413ac1b	\N
39ae4909-c3cd-435a-9771-e3504eb138da	57dd854b-ef0f-4b07-ae43-f5178d234568	\N
46944ab6-8de8-40c9-be12-822bb3c84c2b	51c1e7d9-ba9a-4db6-8d68-510cf945a330	\N
856f4150-c771-4636-8bb5-5a11abb80321	835c137a-81d9-4a65-a5fa-df0e2656f938	\N
61d37a74-5a0e-4c28-b939-9e4e256039fc	38d1adc9-d9df-433c-9a72-a36e4a5c701c	\N
88e6f9ea-cc3e-48f8-bf07-3da0e6105094	9e9d9143-ee2e-478b-9192-e7b8af049855	\N
48195de4-55c1-4bce-8f06-62450498fe85	46b22946-8d5d-4a82-bdc5-2d80e4c4ae16	\N
f8297030-350a-4e37-9ee1-ee8611db141b	fae66ce7-2cce-43bc-aa03-42421fb5ecba	\N
d718aa80-6719-492f-9b4c-8351422c52fd	14414e78-198a-47dd-8ddd-07c6c382265c	\N
581aab1f-d10d-4188-a4b1-9a0d8d29c985	9faf7810-0fda-4d65-aead-6f193cf0814e	\N
8a1c8db1-1f86-4f86-a018-8a136b62c306	b7dff97a-bf8c-466b-b6a4-8d4520be4557	\N
d929fdf0-894b-49da-8823-31095493e2db	6d27a68e-1ab3-4f96-8d00-90b2a1c8b0f0	\N
bee11816-82b5-4997-a763-e14970f41ec5	0ac486af-f2ff-44de-8fcb-94ed5fc22b0b	\N
99cc1aab-c052-4914-8029-ca8f5b5703a2	e0459022-45d4-46fc-8c16-bbe4d1fd02e6	\N
e1421e5c-ed5a-472f-95f0-c02dffdbe5f9	28cacff2-92e3-4fb1-8171-ef6f479a9bcf	\N
a6898f28-9ed6-46c8-938a-785b447eb21e	ac3871d0-4c75-4b49-bad5-e7a84c364946	\N
7f3249e5-953c-4667-9bcc-bd0a6499f07c	649cc4f8-0120-4cee-8761-bd2d1a9bfdc2	\N
78d82968-35b9-4c95-8155-3810ebf32328	697ff785-bd47-43e8-b39a-1e12f9d3cfec	\N
0a283705-3cef-4530-b8fb-a6c1f05ca9ca	03ab36a6-5afc-4e67-8977-e3a7823b5af7	\N
b3a7f495-1688-4920-9df9-8cafd1b51a44	6c5ce529-1788-4057-9176-9d0438acefcf	\N
9f801b5d-c415-4cce-92d3-4ddb03f6abf8	927c13e0-2eac-4efb-9136-6657ea744a6e	\N
417434b3-1dc2-45d9-93a0-82ed8f352b45	be5ebc3b-dcd4-4f06-b02d-a3d36fd36081	\N
880d9a58-feed-42e7-a542-be4815a1c614	ac1fd6e3-ee58-43ad-8044-377cc55e3bcd	\N
ebeb502f-70e4-4bbf-be0d-0e28c234665a	ceaf01d3-aec1-4e24-8636-6ad63d7f2a78	\N
56364d21-8606-4d50-ac15-34af656e530b	beb589c5-a55b-44a4-9d54-b746a0804b5a	\N
817ef459-07ea-49f9-a4cf-d1f93ce97c59	375774d6-4803-428a-a838-104f0646a1ea	\N
d17fa935-eaed-4ee4-b1ab-25b97e4c8ec6	835a307e-c774-46f4-ae30-a2f4d48b1741	\N
506ae4b1-cc09-4d52-a63d-be6da00dec3e	341ca0a2-8234-4367-96c2-41f5fdae4e7c	\N
1bba9f04-1b35-46c0-9a07-e5b7dfeac355	282d2742-bc6b-4b95-8914-bebf97fffef1	\N
af65669c-470a-4b47-a435-ffb3ec785067	d78f96f6-ae87-4140-9142-3d23164e8c80	\N
2324bb04-70b4-461d-96ee-a656610af3c1	6fc7ee4e-458b-44ba-991f-3e72f93d0f75	\N
de56794a-6202-4369-9f9f-868c1f913a4d	edb54d68-cbb2-4fb9-b552-9d936ce13154	\N
941ec87d-a5e1-4677-801d-561b0f9339e4	9f3ff3b1-47cd-4d58-88eb-d9949440252a	\N
38267381-cba3-4ef8-bd10-3a256b272a5f	8a35f5a4-0a8b-4470-98c4-9c3db2d1bfab	\N
074a8a97-bb4c-418f-84bd-88447f5f0660	12763e43-a9fb-431d-a8eb-47f1fa175e8d	\N
6cb5a124-90d4-40b0-852b-aea04dddba08	b30d1d81-22f3-4f1a-8a37-115ef98c0d80	\N
3143ce33-b70e-40ab-bf66-c9ea63a7183a	26fc74e0-e7c8-4295-ade2-3a1de27eac5a	\N
05c183fc-98af-445c-a30f-7614314b91fa	196e61b2-5f11-4627-8278-d5195ff5663e	\N
b221d699-a9b9-4da3-bf4c-7bfcbefb27ee	b4dc2171-a97a-48c7-bc28-f720a079690f	\N
\.


--
-- Data for Name: event_sets; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.event_sets (event_id, tier, set_note, display_name, created_by, id) FROM stdin;
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	ACRAZE	\N	84d8766b-ba81-4c70-ab2b-660d94f523eb
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	AHEE	\N	e2329188-5f97-43c6-bd76-26fff75ba291
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	ALLEYCVT	\N	e2f01aef-6691-4e1d-834e-61dd66c0a591
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	BARELY ALIVE	\N	998eff6c-a020-4755-ab2f-60043d1cbf0e
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	ANDY C	\N	54ebe86e-b22c-418b-98b2-e02f812ddd78
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	ARMNHMR	\N	9d89cf96-99cd-42f9-b6fc-81033f4f472e
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	BEAR GRILLZ	\N	33de02c9-54b9-49d8-bb36-bd040d92962f
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	CYCLOPS	\N	588f9962-947a-40f9-a3a7-6ae4af9638ca
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	DAB THE SKY	\N	7ecb507f-ef68-4b45-bff8-b434a2a7453b
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	ATLIENS	\N	ececa5f0-50bc-42e5-99fe-92ecaf957349
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	AUDIOFREQ	\N	14e1d9b8-bd6a-4c4a-b978-11f34920d57d
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	BIJOU	\N	4048ca94-2e91-4a46-ad41-42b7336d3362
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	BOOGIET	\N	dd48b403-ca91-4c4f-83e4-246dbe1f82ad
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	CALCIUM	\N	20c14211-7270-481d-92a8-e698d31416f2
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	CRANKDAT	\N	2d454029-f321-4d06-aab2-fa0700f5a4df
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	SAID THE SKY	\N	f3b33507-8548-4c37-98b7-49b02515a146
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	DEADROOM	\N	c52f83c8-8ffd-4ee5-9b3b-a451a8ab666c
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	DION TIMMER	\N	0b5f5222-901c-4783-b7b9-0ad0ec1fdd26
916b254c-6e26-4d0b-8275-54425c812c00	1	DETOX SET	EXCISION	\N	019b2ca2-d81f-4f35-8899-03cfeddc2f5e
916b254c-6e26-4d0b-8275-54425c812c00	1	SUNSET SET	ILLENIUM	\N	fab66451-b981-497d-9297-704b1e0e8573
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	DISTINCT MOTIVE	\N	3db32862-276a-491a-b497-2aecdbcc615d
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	DRINKURWATER	\N	793cfe7c-f39b-454a-a554-e0ff208e1209
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	EAZYBAKED	\N	baab080f-0634-4ec9-8118-d4b2ef5850c1
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	EFFIN	\N	c8dc2c2a-e7dd-4ffa-a883-40b4b1d4c568
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	ELIMINATE	\N	a6ba73ba-9619-4f97-ba6a-55a473ec0ecd
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	EMORFIK	\N	2104deb3-e969-424f-944a-a1c40eea8fe6
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	EPTIC	\N	b290a994-f42a-4d39-9295-e04b145d683a
916b254c-6e26-4d0b-8275-54425c812c00	1	2 HOUR SET	EXCISION	\N	47f0cfbc-826f-42a8-9b9c-3adecd022516
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	EXCISION B2B SUBTRONICS	\N	5743aabc-e8de-42cf-ba08-2b5787236522
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	FUNTCASE	\N	2456d584-01fa-418e-8776-e7873b4c3e40
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	GHENGAR	\N	56245968-b6db-4c3c-bbe7-73089d2a1eed
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	GORILLAT	\N	4f1601f8-792d-45be-9407-c1ce6d2647d3
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	HAIRITAGE	\N	2cbec768-d803-43af-bd86-8ccd98a92394
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	HESH	\N	8a8b4ed5-61fd-4f39-84ee-cb72f1225b09
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	HEDEX	\N	a44d8000-ecd6-45ec-82d0-d9508e5dcfad
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	INFEKTI	\N	d68d8793-094d-4c91-b552-df458a358575
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	INZOI	\N	2a007b87-a50c-481e-ae55-a40fc2eb89e2
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	IVY LAB	\N	f588f8cc-a9d8-4ea4-80f6-e4754a14afc2
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	JANTSEN	\N	bc41eb76-71d7-4593-8ac3-841a45a54433
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	JEANIE	\N	0f670b06-376d-4c43-8f8d-6c6896d0711d
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	JESSICA AUDIFFREDI	\N	0de554be-2c47-49b1-bb45-fb99ad173aca
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	HYDE B2B JKYL	\N	785a0640-ad8e-4c3e-b0ef-a07dd4adcaf2
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	JSTJR	\N	39e1b4e9-680c-408b-bd1a-778583586ac4
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	KILL SAFARI	\N	80df8f7b-1b2a-4e54-8da1-42095f49c0b1
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	KOAN SOUND	\N	1e64d177-9228-43a2-b84e-0a66b51af8e6
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	KOMPANY	\N	f634cb18-000a-42ca-9b4a-82371db9b1c5
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	LAYZ	\N	569aa501-fc8c-4771-88df-a675a6197e26
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	LEVEL UP	\N	f34d358b-11d6-42b1-b64c-e87ee227e840
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	LSZEE	\N	bef28ab9-83fd-4a28-a2e0-654c894eefcd
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	LYNY	\N	4b9922b0-8a27-45ae-b84a-b1d2034a9bb4
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	MERSIV	\N	d712e5d9-21e2-4ec5-ba20-46da66af7701
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	MOODY GOOD	\N	81a2cea9-7185-4fef-b849-27701f9e95f5
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	MUST DIE!	\N	c871b26f-83a2-43e5-90c3-43e9641f42fa
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	NOSTALGIX	\N	56275bb0-34bf-4607-960c-d990e6526b37
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	OLIVERSE	\N	91fd681c-f598-419d-8106-c632a83c5efe
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	ONE TRUE GOD	\N	f86035c1-aeb3-4eec-9cdb-0f9668a8fefc
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	PEEKABOO	\N	5203df64-6fb2-4c28-869c-e6913751921b
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	PHASEONE	\N	acfba784-4e08-4980-a875-b50f3f5aff20
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	PHIBES	\N	daf2daaf-3469-49a5-a569-694072cb5f53
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	RAVENSCOON	\N	d38084f4-9e43-42f9-8969-8cb599b20b38
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	RAY VOLPE	\N	3fadf773-7be1-42a4-98f4-f655d435a59b
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	REAPER	\N	9c0ef3c0-2055-4483-a345-b964de9e4bef
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	REZZI	\N	df194a68-0f2f-4a3a-9739-ef4ed1e7b97b
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	RIOT TEN	\N	523702a6-1185-4171-9141-6f9144e22320
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	SAMPLIFIRE	\N	7a927525-5f8d-4cac-9698-71c53652c28b
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	SHOCKONE	\N	4be64b4c-11c8-498e-a951-10218b3d0d41
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	SIMULAI	\N	8a649159-62e8-422a-933b-e8422d5bfc9b
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	SIPPY	\N	9b139b6f-a231-483e-9fc0-9221ab95a12f
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	SLANDER	\N	b857101d-bcb9-46e4-819f-288a6a266ebd
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	SMOAKLAND	\N	9ef9635d-5cbd-43b4-99f0-d5e80873eb6a
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	SODOWN	\N	a102a0e7-f545-46fd-b370-a6ec2053855c
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	SOTA	\N	f7893f04-57d5-4eff-89c4-33318ee83417
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	SPACE LACES	\N	62c58d0e-88cb-42a8-a519-e12433738905
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	STUMPI	\N	99572902-b0f4-4b02-883b-69252feda4b2
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	SULLIVAN KING	\N	67bb6794-a2ca-4bc4-aa84-a06ebe9f638b
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	SVDDEN DEATH PRESENTS: VOYD	\N	8afb04ac-a954-44ad-a542-a3204d0abf02
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	TAPE B	\N	38b85cbd-125f-4a70-b650-5a8013f7c42c
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	TRIVECTA	\N	eb062424-1be6-4e5c-88c0-49d26ed63ddc
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	VAMPA	\N	857a21a8-0147-46cf-98fb-5aa9bad1e334
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	VENJENT	\N	f68c76c1-419b-4936-a1da-6e8bd83bfa30
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	WOOLI	\N	4f75c5ff-6991-4974-9300-41d0cb7b4d66
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	WRECKNO	\N	1f7d3553-b847-4b6d-b5eb-77235e94faaa
916b254c-6e26-4d0b-8275-54425c812c00	1	\N	ZINGARA	\N	633ff831-a573-4f09-97b6-3ff4bcae69f1
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	AFTERXHEAVEN	\N	88abd92e-3456-4755-8b2f-44a35e7e9db2
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	ALIENPARK	\N	d924dc54-c80b-465e-ab5b-a5dec21565f8
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	ALL THE REASON	\N	3f433ebf-aae2-4b24-a853-d32305d84c8d
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	AUTOMHATE	\N	b849b4f9-983a-423d-b4b8-5967976bb815
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	AVANCE	\N	7f1a0271-770e-4a17-b711-09238352f083
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	BADGER	\N	4b44efdb-e9a7-490a-8c25-a6650db981f4
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	BADKLAAT	\N	c0beb2bd-f426-43ff-bce0-86c69a79c7be
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	BADVOID	\N	c32a27a4-f252-4808-96d7-98fb4591aef3
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	BEASTBOI.	\N	41678674-2f44-4d8c-b67b-2a03179d78af
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	BENDA	\N	56d73f81-f850-42fc-8265-0d9cb42b2afb
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	BLOSSOM	\N	076980cc-1709-4cb2-81bb-8f51cac691f8
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	BOMMER	\N	5d473a0e-ff0b-45c8-ab5a-d609bc9eb68f
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	BRAINRACK	\N	e99100ca-6bea-4e2a-ac4b-f664de8da4e7
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	CRISO	\N	adce45ad-10a9-44c0-9cfa-1dd3e5e25bb9
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	DECIMATE	\N	245fb3ba-d511-449f-8415-459b30f2234b
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	DIESELBOY	\N	98495b7c-2964-4f7f-b930-c5508b0c573f
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	FLOZONE	\N	0f7f38fe-8db5-415a-835a-612d4edf2854
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	HYDRAULIX	\N	c2597af5-d9f0-4944-9520-dfc285ba1659
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	JON CASEY	\N	8f5eb443-9d68-40b1-8c5d-70e52cb0cca6
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	LAZRUS	\N	e5d33305-41e7-4e99-bcfb-0ece79776d6f
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	LOUIEJAYXX	\N	0a38ba54-d686-4090-ba37-9015eef72de9
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	MACHAKI	\N	0923cd94-8808-46d2-8cad-0752e9b29556
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	MYTHM	\N	35dfa3ec-0c88-48ce-9eca-eb20a63df7fd
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	PUSHING DAIZIES	\N	4fe9ee55-b1f7-412a-ac58-e9da1d0a79ea
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	RIOTI	\N	1598f25e-47ea-4969-a4b4-5b3cd417e587
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	SCAREXXI	\N	e256a70e-ec72-428c-ad44-fb5647902da3
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	SHIVERZI	\N	2447e5e9-de74-4cb7-a5c2-3c7bedcb793a
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	STVSH	\N	9d7a28a3-cb9c-421d-80aa-3a5da5acf7e5
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	SUPER FUTURE	\N	da08e58b-146a-4080-903d-8490555876f8
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	CANABLISS	\N	6d674cd7-3718-4626-8d22-63cfebe6bba1
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	CHIBS	\N	fecd8080-0d3d-4829-8df0-737dac3794d6
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	CONTRA	\N	7d26ef97-970b-4de9-9a8d-4ebcd97e4bb9
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	CRYSTAL SKIES	\N	4ea379f8-6c07-4e74-8b3b-bd7794fbe2df
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	EDDIE	\N	d4d06314-7a12-4e8b-a15f-7fbfa47a56e6
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	GHOST IN REAL LIFE	\N	72dec661-a83c-4fea-9181-25de1711e986
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	HAMRO	\N	e64d523a-1bd3-4a54-8845-79d3ae840885
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	JOSH TEED	\N	dc68172b-e435-4b05-874a-c11561b5d04c
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	LEOTRIX	\N	00a4498a-cc2a-49d2-aa38-26579accfd5e
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	LUZCID	\N	a2019523-d76f-48a8-bac9-b1ae965ac77c
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	PHOCUST	\N	9c2ba381-006d-4424-a0d7-01f9575b6fef
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	STONED LEVEL	\N	21bcd165-500c-4785-aadb-28f2a394862a
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	CAPOCHINO	\N	8a728440-6cc5-4ced-8067-cc12bea8cd48
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	CHMURA	\N	89dd7de7-1092-4ccd-bdf9-056e61ae2cb9
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	DREAM TAKERS	\N	de971a93-4704-4225-a40d-38297e423291
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	GOOD TIMES AHEAD	\N	0e6fdbe1-a278-4e7e-93b5-3a04565e28e1
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	HEKLER	\N	0f4c304e-387c-43b8-8357-8631d4ab6132
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	HUMANSION	\N	ee759d23-6dbe-46ee-b5cb-792a37c70eb4
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	MASHBIT	\N	bee11816-82b5-4997-a763-e14970f41ec5
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	NITEPUNK	\N	99cc1aab-c052-4914-8029-ca8f5b5703a2
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	PAPER SKIES	\N	e1421e5c-ed5a-472f-95f0-c02dffdbe5f9
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	RZRKT	\N	a6898f28-9ed6-46c8-938a-785b447eb21e
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	TISOKI	\N	7f3249e5-953c-4667-9bcc-bd0a6499f07c
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	CHASSI	\N	087ae26a-66e7-41a7-9288-f585cd354eea
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	CODD DUBZ	\N	a54fa50b-de99-4cd0-9651-e8a96c409a77
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	EATER	\N	c071306d-a540-408b-8c70-86a4599cf19d
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	G-REX	\N	f92c1054-573b-4343-8d6c-4796754d967d
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	GUNPOINT	\N	e2bb7126-1d0f-4f8e-b3c2-0fc540ee8d07
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	HEXXA	\N	0f2c2056-bc42-466a-808a-e335027d54ad
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	HURTBOX	\N	062c8f1d-fdae-46b2-b81a-08df913c3c18
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	PERRY WAYNE	\N	78d82968-35b9-4c95-8155-3810ebf32328
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	SPACE WIZARD	\N	0a283705-3cef-4530-b8fb-a6c1f05ca9ca
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	SUMTHIN SUMTHIN	\N	b3a7f495-1688-4920-9df9-8cafd1b51a44
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	CONTROL FREAK	\N	d1a584a1-7fba-4a20-898d-82056ebb77c6
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	DAGGZ	\N	d17c3c86-5ab0-408d-af57-f260644a4874
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	FAIRLANE	\N	27da91f1-f1ef-436b-9df9-6f1120bfd985
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	FREAKY	\N	1aef572e-77a8-476d-9d5c-29c0501f3437
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	KLIPTIC	\N	01211aa1-ec89-4032-8001-ea26f9b6b179
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	LIQUID SMOAK	\N	6cabb71d-5c2a-4805-9dd0-c151c798bcba
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	M?STIC	\N	526d81bb-4b31-48ca-9a21-6e65e4db9150
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	PROSECUTE	\N	340c1444-9e0f-4b4e-b8ff-137392f01379
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	RATED R	\N	23df5e9a-3656-4809-bdf3-be05b7c73a6c
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	SATURNA	\N	fb9164e7-10d0-41ae-9623-d0ee05ca6f61
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	SHANGHAI DOOM	\N	124ac509-5755-4077-a81b-7b3c43df352f
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	SMITH.	\N	6bb37d93-fc61-4529-9e85-6e3526827145
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	STÖÖKI SOUND	\N	30d90fdb-7ac2-4c92-aa77-7dc7cbede159
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	SULLY	\N	e787e40e-8e57-41a4-adcf-706ed453e62e
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	DÊTRE	\N	a93d62af-d96c-4ead-bc97-b1a697372852
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	DOMINA	\N	78835b21-7b73-4ff5-91c3-3a5ab6809e37
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	FOCUSS	\N	8d58167a-0cc3-4b10-aa67-ac931c691b94
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	IVORY	\N	9886a94c-6432-4d21-86f5-b74fafb219eb
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	MAD DUBZ	\N	5952aa3b-057f-47de-b73c-ef63e596e26d
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	MEDICINE PLACE	\N	83c8fe9e-c0b6-4bfb-b07f-2bdd390094f5
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	NEOTEK	\N	a5365d66-de7e-44bc-a182-3c9353e3df81
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	NIKITA B2B THE WICKED	\N	37a9111b-61f0-4582-8d0a-c1c00ffff449
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	NXSTY	\N	bbbe0994-c07c-4fd9-9f00-34e9de9b9ef4
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	PYKE	\N	5e14d7b3-c740-4cdf-af83-43ffbab5d1ef
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	RUVLO	\N	bdf8666a-c644-4d13-82ae-d28a33afb2f6
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	SAKA	\N	6c8990b4-4002-4de1-827c-01c68440225f
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	SHADIENT	\N	39ae4909-c3cd-435a-9771-e3504eb138da
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	SISTO	\N	46944ab6-8de8-40c9-be12-822bb3c84c2b
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	SUBFILTRONIK	\N	856f4150-c771-4636-8bb5-5a11abb80321
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	THE ARCTURIANS	\N	61d37a74-5a0e-4c28-b939-9e4e256039fc
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	DEUCEZ	\N	93391781-e984-4ad6-b1d5-c74233b40956
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	DR. USHUU	\N	67f210d4-ef02-47aa-92ee-fea9cf873c58
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	HEYZ	\N	b1940707-739c-4b09-be9c-086e5e4c912c
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	HVDES	\N	1efe6324-e951-4251-a32a-9dd076b3fc35
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	JIQUI	\N	7e513aff-44c9-40f2-b1dd-2e344665fa28
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	MANTIS	\N	88e6f9ea-cc3e-48f8-bf07-3da0e6105094
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	MUERTE	\N	48195de4-55c1-4bce-8f06-62450498fe85
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	NIMDA	\N	f8297030-350a-4e37-9ee1-ee8611db141b
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	OKAYJAKE	\N	d718aa80-6719-492f-9b4c-8351422c52fd
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	RYNS	\N	581aab1f-d10d-4188-a4b1-9a0d8d29c985
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	SUPERAVE.	\N	8a1c8db1-1f86-4f86-a018-8a136b62c306
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	THE RESISTANCE	\N	d929fdf0-894b-49da-8823-31095493e2db
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	TORCHA	\N	9f801b5d-c415-4cce-92d3-4ddb03f6abf8
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	TWOPERCENT	\N	417434b3-1dc2-45d9-93a0-82ed8f352b45
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	TYNAN	\N	880d9a58-feed-42e7-a542-be4815a1c614
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	USAYBFLOW	\N	ebeb502f-70e4-4bbf-be0d-0e28c234665a
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	VASTIVE	\N	56364d21-8606-4d50-ac15-34af656e530b
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	VERSA	\N	817ef459-07ea-49f9-a4cf-d1f93ce97c59
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	VIPERACTIVE	\N	d17fa935-eaed-4ee4-b1ab-25b97e4c8ec6
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	VKTM	\N	506ae4b1-cc09-4d52-a63d-be6da00dec3e
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	VLCN	\N	1bba9f04-1b35-46c0-9a07-e5b7dfeac355
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	VRG	\N	af65669c-470a-4b47-a435-ffb3ec785067
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	WHALES	\N	2324bb04-70b4-461d-96ee-a656610af3c1
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	WILEY	\N	de56794a-6202-4369-9f9f-868c1f913a4d
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	WODD	\N	941ec87d-a5e1-4677-801d-561b0f9339e4
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	WONKYWILLA	\N	38267381-cba3-4ef8-bd10-3a256b272a5f
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	WRAZ.	\N	074a8a97-bb4c-418f-84bd-88447f5f0660
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	YETEP	\N	6cb5a124-90d4-40b0-852b-aea04dddba08
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	YOSUF	\N	3143ce33-b70e-40ab-bf66-c9ea63a7183a
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	LCN	\N	05c183fc-98af-445c-a30f-7614314b91fa
916b254c-6e26-4d0b-8275-54425c812c00	2	\N	VRG W	\N	b221d699-a9b9-4da3-bf4c-7bfcbefb27ee
\.


--
-- Data for Name: events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.events (id, name, date, location, created_by, created_at, num_tiers, slug, is_draft, status) FROM stdin;
51685989-4b2a-4e2b-8c03-f5d67ebb79b1	Untitled Event	2025-06-01		\N	2025-06-01 00:03:19.358719+00	3	untitled-event-2025-06-01	t	draft
916b254c-6e26-4d0b-8275-54425c812c00	Lost Lands	2025-09-19	Legend Valley, Thornville, OH	\N	2025-05-31 20:29:55.68883+00	2	lost-lands-2025-09-19	t	draft
55b10bd8-053d-4946-8e29-5d60447b4eeb	Badger Bass Camp	2025-08-08	Hartsel, CO	\N	2025-05-30 19:18:23.750482+00	3	badger-bass-camp-2025-08-08	t	draft
\.


--
-- Data for Name: feature_votes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.feature_votes (id, feature_id, user_id, voted_at) FROM stdin;
3a5bfc6f-5b1c-47ca-8522-00829aa4fade	398d3c2d-8d34-4cd4-ad04-6bdf4d250093	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-05-29 14:33:55.887652+00
ca211613-02e7-4524-b107-c1b878c05285	9f0be72a-7eb0-47bb-a663-72fb5a587453	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-05-29 14:33:56.985974+00
984f2c06-df05-45e4-aa95-1746cca476c5	1c3b46a8-071e-4282-953e-0b4914f8afa2	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-05-29 14:33:57.961167+00
24f61395-5eef-48b6-83cb-daa41685d626	77f6d8ef-50a4-49e0-991e-2beba33d9132	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-05-29 14:33:59.492867+00
c8b85b57-fdcf-4689-9e80-df323e881076	d3fd5269-4408-415b-a4a9-6e6c5e2a367d	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-05-29 14:34:00.416148+00
ab6c57e2-94b0-4e23-8c54-91cc370bc46a	81f318cb-6a41-4999-92ce-1f1164960311	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-05-29 14:34:01.767239+00
4c297578-a619-4238-9cc1-8fa8f4134dff	398d3c2d-8d34-4cd4-ad04-6bdf4d250093	dfa7ac70-3f2d-47e5-86e4-49bba65a68b5	2025-05-29 14:42:06.776023+00
ca7f8b3e-dd03-4ec7-8289-576fae809a34	1c3b46a8-071e-4282-953e-0b4914f8afa2	dfa7ac70-3f2d-47e5-86e4-49bba65a68b5	2025-05-29 14:42:15.426134+00
4592f724-fef9-42d3-b63a-8d3a1431780f	77f6d8ef-50a4-49e0-991e-2beba33d9132	dfa7ac70-3f2d-47e5-86e4-49bba65a68b5	2025-05-29 14:42:58.947517+00
a444de58-001d-4dfd-8d41-aa7c4955959f	81f318cb-6a41-4999-92ce-1f1164960311	7f2169d3-894f-484f-bf65-8be242c8cd24	2025-05-29 21:43:32.475372+00
f60abd1c-0cd5-445d-8c6e-0ea2f9ebabd7	d3fd5269-4408-415b-a4a9-6e6c5e2a367d	7f2169d3-894f-484f-bf65-8be242c8cd24	2025-05-29 21:43:42.489762+00
b6a452ab-6fb6-44ed-9259-46c95385062e	77f6d8ef-50a4-49e0-991e-2beba33d9132	7f2169d3-894f-484f-bf65-8be242c8cd24	2025-05-29 21:43:56.381242+00
a99048a3-77c6-46a1-97dc-0110fbc990a8	398d3c2d-8d34-4cd4-ad04-6bdf4d250093	7f2169d3-894f-484f-bf65-8be242c8cd24	2025-05-29 21:44:10.177927+00
29c73f86-60af-438e-b7a3-e14576f4e1e9	9f0be72a-7eb0-47bb-a663-72fb5a587453	7f2169d3-894f-484f-bf65-8be242c8cd24	2025-05-29 21:44:30.334443+00
78e53a37-42d6-4ad8-8c86-3717da7d1648	1c3b46a8-071e-4282-953e-0b4914f8afa2	7f2169d3-894f-484f-bf65-8be242c8cd24	2025-05-29 21:44:39.902425+00
8706c163-f87f-429e-8fe2-2140f4c10ca1	398d3c2d-8d34-4cd4-ad04-6bdf4d250093	06082977-180b-4170-a3d5-72f7005652a9	2025-05-30 09:35:49.52096+00
a445c6ad-cd66-4fe4-9b00-4be5228232ec	1c3b46a8-071e-4282-953e-0b4914f8afa2	06082977-180b-4170-a3d5-72f7005652a9	2025-05-30 09:35:57.407072+00
a8a0d331-02ec-420b-8ef2-9c5d84e8a1be	d3fd5269-4408-415b-a4a9-6e6c5e2a367d	06082977-180b-4170-a3d5-72f7005652a9	2025-05-30 09:38:15.593054+00
0898faed-d585-45d1-b122-054f0155de6e	81f318cb-6a41-4999-92ce-1f1164960311	06082977-180b-4170-a3d5-72f7005652a9	2025-05-30 09:38:34.877568+00
e3462776-d171-46b4-b352-6afbcda97616	77f6d8ef-50a4-49e0-991e-2beba33d9132	06082977-180b-4170-a3d5-72f7005652a9	2025-05-30 09:38:54.232099+00
f5d2890a-087c-42b7-87bd-603a7a4f7c17	9f0be72a-7eb0-47bb-a663-72fb5a587453	06082977-180b-4170-a3d5-72f7005652a9	2025-05-30 09:39:06.995851+00
a3770bb1-50d2-407a-af48-a8d4d002061f	12fec405-c991-4c91-9c93-efd4f34effb9	06082977-180b-4170-a3d5-72f7005652a9	2025-05-30 09:43:27.520175+00
c8bcde01-63c0-4ab2-9993-cd5c71d9fc3f	12fec405-c991-4c91-9c93-efd4f34effb9	eda854e4-0358-4ae6-b5e2-8bb490e5782a	2025-06-03 07:07:28.100197+00
f11aa3ce-0205-4954-ae98-c76b3162f4c9	12fec405-c991-4c91-9c93-efd4f34effb9	dfa7ac70-3f2d-47e5-86e4-49bba65a68b5	2025-06-03 07:09:05.704274+00
\.


--
-- Data for Name: features; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.features (id, title, description, status, created_by, created_at) FROM stdin;
1c3b46a8-071e-4282-953e-0b4914f8afa2	Event Lineups using my rankings	Automatically re-sort event lineups based on your artist rankings.	Open	\N	2025-05-29 14:33:46.75915+00
81f318cb-6a41-4999-92ce-1f1164960311	Share rankings with friends	Let users share their ranked artist list via link or social.	Open	\N	2025-05-29 14:33:46.75915+00
77f6d8ef-50a4-49e0-991e-2beba33d9132	Ranking comparison with friends	View side-by-side artist ranking comparisons with friends.	Open	\N	2025-05-29 14:33:46.75915+00
398d3c2d-8d34-4cd4-ad04-6bdf4d250093	Event feedback	Give feedback on how an event went, and help artists and organizers learn.	Open	\N	2025-05-29 14:33:46.75915+00
d3fd5269-4408-415b-a4a9-6e6c5e2a367d	Event "Memory Lane"	Organize and revisit videos/photos from events you attended.	Open	\N	2025-05-29 14:33:46.75915+00
9f0be72a-7eb0-47bb-a663-72fb5a587453	Add all unranked artists from an event	Easily pull all artists from a lineup into your "My Artists" list for ranking.	Open	\N	2025-05-29 14:33:46.75915+00
12fec405-c991-4c91-9c93-efd4f34effb9	Make a "Home"  Button for Mobile 	When you click "feature voting" there is no way to return back to the main page or "home" \n	Shipped	06082977-180b-4170-a3d5-72f7005652a9	2025-05-30 09:43:10.325307+00
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.roles (id, user_id, role) FROM stdin;
0fc1eb42-8f75-4549-8c83-2ef658326fee	eda854e4-0358-4ae6-b5e2-8bb490e5782a	admin
b0f3d40c-5a12-4185-8fc9-4bf310524df3	7f2169d3-894f-484f-bf65-8be242c8cd24	fan
16cf9e6a-42e3-4191-a851-bef56915109e	9547e1f9-306e-4dd2-96fb-89fc33ce7512	fan
f3d76fa2-491d-438a-a590-0d5f43a54931	dfa7ac70-3f2d-47e5-86e4-49bba65a68b5	fan
1c6e7f52-7f68-45c6-825f-be11a21eeb4b	82f7f043-f150-4052-82a7-d98c4c31237c	fan
91e490ef-b45d-4dfa-a6a1-2a56daf221cd	06082977-180b-4170-a3d5-72f7005652a9	fan
6147206f-dee8-45d3-9e7e-ed3c070125d6	b0b0ed7d-538a-4b52-bc1c-f5410677612c	fan
16077492-22ea-4ec8-abd8-49f6052e4050	1988ae88-45c3-4529-929f-24fe6ed0b93b	fan
545cc741-8eac-4e77-af65-b3acabc32278	c3866d1b-210f-490a-b300-bde91941735b	fan
9e4f7234-6e61-4d35-a50f-9fac2e2b874b	419646ee-1d59-4497-9fae-60b0eed36064	fan
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.schema_migrations (version, inserted_at) FROM stdin;
20211116024918	2025-05-24 01:57:05
20211116045059	2025-05-24 01:57:07
20211116050929	2025-05-24 01:57:09
20211116051442	2025-05-24 01:57:11
20211116212300	2025-05-24 01:57:14
20211116213355	2025-05-24 01:57:16
20211116213934	2025-05-24 01:57:18
20211116214523	2025-05-24 01:57:21
20211122062447	2025-05-24 01:57:23
20211124070109	2025-05-24 01:57:25
20211202204204	2025-05-24 01:57:27
20211202204605	2025-05-24 01:57:29
20211210212804	2025-05-24 01:57:35
20211228014915	2025-05-24 01:57:37
20220107221237	2025-05-24 01:57:39
20220228202821	2025-05-24 01:57:41
20220312004840	2025-05-24 01:57:43
20220603231003	2025-05-24 01:57:47
20220603232444	2025-05-24 01:57:49
20220615214548	2025-05-24 01:57:51
20220712093339	2025-05-24 01:57:53
20220908172859	2025-05-24 01:57:55
20220916233421	2025-05-24 01:57:57
20230119133233	2025-05-24 01:57:59
20230128025114	2025-05-24 01:58:02
20230128025212	2025-05-24 01:58:04
20230227211149	2025-05-24 01:58:06
20230228184745	2025-05-24 01:58:08
20230308225145	2025-05-24 01:58:10
20230328144023	2025-05-24 01:58:12
20231018144023	2025-05-24 01:58:14
20231204144023	2025-05-24 01:58:18
20231204144024	2025-05-24 01:58:20
20231204144025	2025-05-24 01:58:22
20240108234812	2025-05-24 01:58:24
20240109165339	2025-05-24 01:58:26
20240227174441	2025-05-24 01:58:29
20240311171622	2025-05-24 01:58:32
20240321100241	2025-05-24 01:58:37
20240401105812	2025-05-24 01:58:42
20240418121054	2025-05-24 01:58:45
20240523004032	2025-05-24 01:58:52
20240618124746	2025-05-24 01:58:54
20240801235015	2025-05-24 01:58:57
20240805133720	2025-05-24 01:58:59
20240827160934	2025-05-24 01:59:01
20240919163303	2025-05-24 01:59:03
20240919163305	2025-05-24 01:59:05
20241019105805	2025-05-24 01:59:07
20241030150047	2025-05-24 01:59:15
20241108114728	2025-05-24 01:59:18
20241121104152	2025-05-24 01:59:20
20241130184212	2025-05-24 01:59:22
20241220035512	2025-05-24 01:59:24
20241220123912	2025-05-24 01:59:26
20241224161212	2025-05-24 01:59:28
20250107150512	2025-05-24 01:59:30
20250110162412	2025-05-24 01:59:32
20250123174212	2025-05-24 01:59:34
20250128220012	2025-05-24 01:59:37
20250506224012	2025-05-24 01:59:38
20250523164012	2025-05-28 14:06:49
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.subscription (id, subscription_id, entity, filters, claims, created_at) FROM stdin;
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit, allowed_mime_types, owner_id) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.migrations (id, name, hash, executed_at) FROM stdin;
0	create-migrations-table	e18db593bcde2aca2a408c4d1100f6abba2195df	2025-05-24 01:57:02.195892
1	initialmigration	6ab16121fbaa08bbd11b712d05f358f9b555d777	2025-05-24 01:57:02.200091
2	storage-schema	5c7968fd083fcea04050c1b7f6253c9771b99011	2025-05-24 01:57:02.20344
3	pathtoken-column	2cb1b0004b817b29d5b0a971af16bafeede4b70d	2025-05-24 01:57:02.240699
4	add-migrations-rls	427c5b63fe1c5937495d9c635c263ee7a5905058	2025-05-24 01:57:02.27745
5	add-size-functions	79e081a1455b63666c1294a440f8ad4b1e6a7f84	2025-05-24 01:57:02.28144
6	change-column-name-in-get-size	f93f62afdf6613ee5e7e815b30d02dc990201044	2025-05-24 01:57:02.288722
7	add-rls-to-buckets	e7e7f86adbc51049f341dfe8d30256c1abca17aa	2025-05-24 01:57:02.295309
8	add-public-to-buckets	fd670db39ed65f9d08b01db09d6202503ca2bab3	2025-05-24 01:57:02.299987
9	fix-search-function	3a0af29f42e35a4d101c259ed955b67e1bee6825	2025-05-24 01:57:02.307323
10	search-files-search-function	68dc14822daad0ffac3746a502234f486182ef6e	2025-05-24 01:57:02.314214
11	add-trigger-to-auto-update-updated_at-column	7425bdb14366d1739fa8a18c83100636d74dcaa2	2025-05-24 01:57:02.31853
12	add-automatic-avif-detection-flag	8e92e1266eb29518b6a4c5313ab8f29dd0d08df9	2025-05-24 01:57:02.322702
13	add-bucket-custom-limits	cce962054138135cd9a8c4bcd531598684b25e7d	2025-05-24 01:57:02.327906
14	use-bytes-for-max-size	941c41b346f9802b411f06f30e972ad4744dad27	2025-05-24 01:57:02.332858
15	add-can-insert-object-function	934146bc38ead475f4ef4b555c524ee5d66799e5	2025-05-24 01:57:02.37545
16	add-version	76debf38d3fd07dcfc747ca49096457d95b1221b	2025-05-24 01:57:02.37949
17	drop-owner-foreign-key	f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101	2025-05-24 01:57:02.384111
18	add_owner_id_column_deprecate_owner	e7a511b379110b08e2f214be852c35414749fe66	2025-05-24 01:57:02.3875
19	alter-default-value-objects-id	02e5e22a78626187e00d173dc45f58fa66a4f043	2025-05-24 01:57:02.392122
20	list-objects-with-delimiter	cd694ae708e51ba82bf012bba00caf4f3b6393b7	2025-05-24 01:57:02.395868
21	s3-multipart-uploads	8c804d4a566c40cd1e4cc5b3725a664a9303657f	2025-05-24 01:57:02.406082
22	s3-multipart-uploads-big-ints	9737dc258d2397953c9953d9b86920b8be0cdb73	2025-05-24 01:57:02.434237
23	optimize-search-function	9d7e604cddc4b56a5422dc68c9313f4a1b6f132c	2025-05-24 01:57:02.505803
24	operation-function	8312e37c2bf9e76bbe841aa5fda889206d2bf8aa	2025-05-24 01:57:02.509418
25	custom-metadata	d974c6057c3db1c1f847afa0e291e6165693b990	2025-05-24 01:57:02.520796
\.


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.s3_multipart_uploads (id, in_progress_size, upload_signature, bucket_id, key, version, owner_id, created_at, user_metadata) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.s3_multipart_uploads_parts (id, upload_id, size, part_number, bucket_id, key, etag, owner_id, version, created_at) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: supabase_migrations; Owner: -
--

COPY supabase_migrations.schema_migrations (version, statements, name) FROM stdin;
20250603230040	\N	remote_schema
\.


--
-- Data for Name: secrets; Type: TABLE DATA; Schema: vault; Owner: -
--

COPY vault.secrets (id, name, description, secret, key_id, nonce, created_at, updated_at) FROM stdin;
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: -
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 299, true);


--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: -
--

SELECT pg_catalog.setval('realtime.subscription_id_seq', 1, false);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: artist_placement_history artist_placement_history_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_placement_history
    ADD CONSTRAINT artist_placement_history_pkey PRIMARY KEY (id);


--
-- Name: artist_placements artist_placements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_placements
    ADD CONSTRAINT artist_placements_pkey PRIMARY KEY (id);


--
-- Name: artists artists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artists
    ADD CONSTRAINT artists_pkey PRIMARY KEY (id);


--
-- Name: b2b_sets b2b_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_sets
    ADD CONSTRAINT b2b_sets_pkey PRIMARY KEY (id);


--
-- Name: event_set_artists event_lineup_artists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_set_artists
    ADD CONSTRAINT event_lineup_artists_pkey PRIMARY KEY (set_id, artist_id);


--
-- Name: event_sets event_lineups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_sets
    ADD CONSTRAINT event_lineups_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: events events_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_slug_key UNIQUE (slug);


--
-- Name: feature_votes feature_votes_feature_id_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feature_votes
    ADD CONSTRAINT feature_votes_feature_id_user_id_key UNIQUE (feature_id, user_id);


--
-- Name: feature_votes feature_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feature_votes
    ADD CONSTRAINT feature_votes_pkey PRIMARY KEY (id);


--
-- Name: features features_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.features
    ADD CONSTRAINT features_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: roles roles_user_id_role_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_user_id_role_key UNIQUE (user_id, role);


--
-- Name: artist_placements unique_user_artist; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_placements
    ADD CONSTRAINT unique_user_artist UNIQUE (user_id, artist_id);


--
-- Name: artist_placements unique_user_b2b_placement; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_placements
    ADD CONSTRAINT unique_user_b2b_placement UNIQUE (user_id, b2b_set_id);


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: supabase_migrations; Owner: -
--

ALTER TABLE ONLY supabase_migrations.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: unique_b2b_fingerprint; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_b2b_fingerprint ON public.b2b_sets USING btree (fingerprint);


--
-- Name: unique_upper_artist_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_upper_artist_name ON public.artists USING btree (upper(name));


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- Name: subscription_subscription_id_entity_filters_key; Type: INDEX; Schema: realtime; Owner: -
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_key ON realtime.subscription USING btree (subscription_id, entity, filters);


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: users on_auth_user_created; Type: TRIGGER; Schema: auth; Owner: -
--

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_role();


--
-- Name: artist_placements set_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.artist_placements FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: b2b_sets trigger_set_b2b_fingerprint; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_set_b2b_fingerprint BEFORE INSERT OR UPDATE ON public.b2b_sets FOR EACH ROW EXECUTE FUNCTION public.set_b2b_fingerprint();


--
-- Name: b2b_sets trigger_set_fingerprint; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_set_fingerprint BEFORE INSERT OR UPDATE ON public.b2b_sets FOR EACH ROW EXECUTE FUNCTION public.set_b2b_fingerprint();


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: -
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: artist_placement_history artist_placement_history_artist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_placement_history
    ADD CONSTRAINT artist_placement_history_artist_id_fkey FOREIGN KEY (artist_id) REFERENCES public.artists(id);


--
-- Name: artist_placement_history artist_placement_history_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_placement_history
    ADD CONSTRAINT artist_placement_history_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);


--
-- Name: artist_placements artist_placements_artist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_placements
    ADD CONSTRAINT artist_placements_artist_id_fkey FOREIGN KEY (artist_id) REFERENCES public.artists(id);


--
-- Name: artist_placements artist_placements_b2b_set_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_placements
    ADD CONSTRAINT artist_placements_b2b_set_id_fkey FOREIGN KEY (b2b_set_id) REFERENCES public.b2b_sets(id);


--
-- Name: artist_placements artist_placements_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_placements
    ADD CONSTRAINT artist_placements_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id);


--
-- Name: artists artists_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artists
    ADD CONSTRAINT artists_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id);


--
-- Name: b2b_sets b2b_sets_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.b2b_sets
    ADD CONSTRAINT b2b_sets_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id);


--
-- Name: event_set_artists event_lineup_artists_artist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_set_artists
    ADD CONSTRAINT event_lineup_artists_artist_id_fkey FOREIGN KEY (artist_id) REFERENCES public.artists(id) ON DELETE CASCADE;


--
-- Name: event_set_artists event_lineup_artists_lineup_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_set_artists
    ADD CONSTRAINT event_lineup_artists_lineup_id_fkey FOREIGN KEY (set_id) REFERENCES public.event_sets(id) ON DELETE CASCADE;


--
-- Name: event_sets event_lineups_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_sets
    ADD CONSTRAINT event_lineups_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.events(id) ON DELETE CASCADE;


--
-- Name: events events_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id);


--
-- Name: feature_votes feature_votes_feature_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feature_votes
    ADD CONSTRAINT feature_votes_feature_id_fkey FOREIGN KEY (feature_id) REFERENCES public.features(id) ON DELETE CASCADE;


--
-- Name: feature_votes feature_votes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.feature_votes
    ADD CONSTRAINT feature_votes_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: features features_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.features
    ADD CONSTRAINT features_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id) ON DELETE SET NULL;


--
-- Name: roles roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: artist_placement_history Admins can delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can delete" ON public.artist_placement_history FOR DELETE USING (public.has_role('admin'::text));


--
-- Name: artist_placements Admins can delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can delete" ON public.artist_placements FOR DELETE USING (public.has_role('admin'::text));


--
-- Name: artists Admins can delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can delete" ON public.artists FOR DELETE USING (public.has_role('admin'::text));


--
-- Name: event_sets Admins can delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can delete" ON public.event_sets FOR DELETE USING (public.has_role('admin'::text));


--
-- Name: events Admins can delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can delete" ON public.events FOR DELETE USING (public.has_role('admin'::text));


--
-- Name: feature_votes Admins can delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can delete" ON public.feature_votes FOR DELETE USING (public.has_role('admin'::text));


--
-- Name: features Admins can delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can delete" ON public.features FOR DELETE USING (public.has_role('admin'::text));


--
-- Name: artist_placement_history Admins can insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can insert" ON public.artist_placement_history FOR INSERT WITH CHECK (public.has_role('admin'::text));


--
-- Name: artist_placements Admins can insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can insert" ON public.artist_placements FOR INSERT WITH CHECK (public.has_role('admin'::text));


--
-- Name: artists Admins can insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can insert" ON public.artists FOR INSERT WITH CHECK (public.has_role('admin'::text));


--
-- Name: event_sets Admins can insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can insert" ON public.event_sets FOR INSERT WITH CHECK (public.has_role('admin'::text));


--
-- Name: events Admins can insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can insert" ON public.events FOR INSERT WITH CHECK (public.has_role('admin'::text));


--
-- Name: feature_votes Admins can insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can insert" ON public.feature_votes FOR INSERT WITH CHECK (public.has_role('admin'::text));


--
-- Name: features Admins can insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can insert" ON public.features FOR INSERT WITH CHECK (public.has_role('admin'::text));


--
-- Name: artist_placement_history Admins can read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can read" ON public.artist_placement_history FOR SELECT USING (public.has_role('admin'::text));


--
-- Name: artist_placements Admins can read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can read" ON public.artist_placements FOR SELECT USING (public.has_role('admin'::text));


--
-- Name: artists Admins can read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can read" ON public.artists FOR SELECT USING (public.has_role('admin'::text));


--
-- Name: event_sets Admins can read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can read" ON public.event_sets FOR SELECT USING (public.has_role('admin'::text));


--
-- Name: events Admins can read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can read" ON public.events FOR SELECT USING (public.has_role('admin'::text));


--
-- Name: feature_votes Admins can read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can read" ON public.feature_votes FOR SELECT USING (public.has_role('admin'::text));


--
-- Name: features Admins can read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can read" ON public.features FOR SELECT USING (public.has_role('admin'::text));


--
-- Name: artist_placement_history Admins can update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can update" ON public.artist_placement_history FOR UPDATE USING (public.has_role('admin'::text));


--
-- Name: artist_placements Admins can update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can update" ON public.artist_placements FOR UPDATE USING (public.has_role('admin'::text));


--
-- Name: artists Admins can update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can update" ON public.artists FOR UPDATE USING (public.has_role('admin'::text));


--
-- Name: event_sets Admins can update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can update" ON public.event_sets FOR UPDATE USING (public.has_role('admin'::text));


--
-- Name: events Admins can update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can update" ON public.events FOR UPDATE USING (public.has_role('admin'::text));


--
-- Name: feature_votes Admins can update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can update" ON public.feature_votes FOR UPDATE USING (public.has_role('admin'::text));


--
-- Name: features Admins can update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins can update" ON public.features FOR UPDATE USING (public.has_role('admin'::text));


--
-- Name: event_set_artists All users can delete lineup artists; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "All users can delete lineup artists" ON public.event_set_artists FOR DELETE USING (true);


--
-- Name: event_set_artists All users can insert lineup artists; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "All users can insert lineup artists" ON public.event_set_artists FOR INSERT WITH CHECK (true);


--
-- Name: b2b_sets All users can read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "All users can read" ON public.b2b_sets FOR SELECT USING (true);


--
-- Name: artists All users can read artists; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "All users can read artists" ON public.artists FOR SELECT USING (true);


--
-- Name: event_set_artists All users can read lineup artists; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "All users can read lineup artists" ON public.event_set_artists FOR SELECT USING (true);


--
-- Name: event_sets All users can read lineups; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "All users can read lineups" ON public.event_sets FOR SELECT USING (true);


--
-- Name: event_set_artists All users can update lineup artists; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "All users can update lineup artists" ON public.event_set_artists FOR UPDATE USING (true) WITH CHECK (true);


--
-- Name: artists Allow authenticated artist creation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow authenticated artist creation" ON public.artists FOR INSERT WITH CHECK ((auth.role() = 'authenticated'::text));


--
-- Name: artist_placement_history Allow user to insert their own placement history; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow user to insert their own placement history" ON public.artist_placement_history FOR INSERT WITH CHECK ((user_id = auth.uid()));


--
-- Name: artist_placements Allow user to insert their own placements; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow user to insert their own placements" ON public.artist_placements FOR INSERT WITH CHECK ((user_id = auth.uid()));


--
-- Name: artist_placement_history Allow user to update their own placement history; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow user to update their own placement history" ON public.artist_placement_history FOR UPDATE USING ((user_id = auth.uid())) WITH CHECK ((user_id = auth.uid()));


--
-- Name: artist_placements Allow user to update their own placements; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow user to update their own placements" ON public.artist_placements FOR UPDATE USING ((user_id = auth.uid())) WITH CHECK ((user_id = auth.uid()));


--
-- Name: artist_placements Allow user to view their own placements; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Allow user to view their own placements" ON public.artist_placements FOR SELECT USING ((user_id = auth.uid()));


--
-- Name: events Anyone can read published events; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Anyone can read published events" ON public.events FOR SELECT USING ((status = 'published'::text));


--
-- Name: feature_votes Authenticated users can insert their own votes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Authenticated users can insert their own votes" ON public.feature_votes FOR INSERT TO authenticated WITH CHECK ((user_id = auth.uid()));


--
-- Name: feature_votes Authenticated users can read feature votes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Authenticated users can read feature votes" ON public.feature_votes FOR SELECT TO authenticated USING (true);


--
-- Name: features Authenticated users can read features; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Authenticated users can read features" ON public.features FOR SELECT TO authenticated USING (true);


--
-- Name: artists Enable read access for all users; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Enable read access for all users" ON public.artists FOR SELECT USING (true);


--
-- Name: event_sets Public can delete event lineups; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Public can delete event lineups" ON public.event_sets FOR DELETE USING (true);


--
-- Name: events Public can delete events; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Public can delete events" ON public.events FOR DELETE USING (true);


--
-- Name: event_sets Public can insert event lineups; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Public can insert event lineups" ON public.event_sets FOR INSERT WITH CHECK (true);


--
-- Name: events Public can insert events; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Public can insert events" ON public.events FOR INSERT WITH CHECK (true);


--
-- Name: event_sets Public can read all event lineups; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Public can read all event lineups" ON public.event_sets FOR SELECT USING (true);


--
-- Name: events Public can read all events; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Public can read all events" ON public.events FOR SELECT USING (true);


--
-- Name: event_sets Public can update event lineups; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Public can update event lineups" ON public.event_sets FOR UPDATE USING (true) WITH CHECK (true);


--
-- Name: events Public can update events; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Public can update events" ON public.events FOR UPDATE USING (true) WITH CHECK (true);


--
-- Name: b2b_sets User can insert own sets; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "User can insert own sets" ON public.b2b_sets FOR INSERT WITH CHECK ((auth.uid() = created_by));


--
-- Name: artist_placements Users can delete their own placements; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Users can delete their own placements" ON public.artist_placements FOR DELETE TO authenticated USING ((user_id = auth.uid()));


--
-- Name: artist_placement_history; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.artist_placement_history ENABLE ROW LEVEL SECURITY;

--
-- Name: artist_placements; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.artist_placements ENABLE ROW LEVEL SECURITY;

--
-- Name: artists; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.artists ENABLE ROW LEVEL SECURITY;

--
-- Name: b2b_sets; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.b2b_sets ENABLE ROW LEVEL SECURITY;

--
-- Name: event_sets; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.event_sets ENABLE ROW LEVEL SECURITY;

--
-- Name: events; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;

--
-- Name: feature_votes; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.feature_votes ENABLE ROW LEVEL SECURITY;

--
-- Name: features; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.features ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: -
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: -
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


--
-- PostgreSQL database dump complete
--

