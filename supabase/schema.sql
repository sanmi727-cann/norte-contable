-- ════════════════════════════════════════════════════════════════
-- NORTE CONTABLE — esquema multi-tenant
-- Pegar COMPLETO en Supabase → SQL Editor → Run (una sola vez).
-- Cada firma ve únicamente sus datos: la separación la garantiza
-- Row Level Security (RLS) por el email del usuario conectado.
-- ════════════════════════════════════════════════════════════════

-- Una fila por firma; todo el estado de la app viaja en "data"
create table if not exists public.firmas (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  data jsonb,
  updated_at timestamptz not null default now()
);

-- Quién pertenece a qué firma y con qué rol
create table if not exists public.miembros (
  email text primary key,
  firma_id uuid not null references public.firmas(id) on delete cascade,
  rol text not null default 'staff' check (rol in ('socio','staff')),
  nombre text
);

alter table public.firmas enable row level security;
alter table public.miembros enable row level security;

drop policy if exists "miembro lee su firma" on public.firmas;
create policy "miembro lee su firma" on public.firmas
  for select to authenticated
  using (id in (select firma_id from public.miembros where email = (auth.jwt()->>'email')));

drop policy if exists "miembro actualiza su firma" on public.firmas;
create policy "miembro actualiza su firma" on public.firmas
  for update to authenticated
  using (id in (select firma_id from public.miembros where email = (auth.jwt()->>'email')))
  with check (id in (select firma_id from public.miembros where email = (auth.jwt()->>'email')));

drop policy if exists "miembro lee su fila" on public.miembros;
create policy "miembro lee su fila" on public.miembros
  for select to authenticated
  using (email = (auth.jwt()->>'email'));

-- Sincronización en vivo entre computadoras de la misma firma
-- (si esta línea da error "already member of publication", ignórala)
alter publication supabase_realtime add table public.firmas;

-- ════════════════════════════════════════════════════════════════
-- PRIMERA FIRMA: Fontan Tax & Accounting
-- ════════════════════════════════════════════════════════════════
insert into public.firmas (nombre)
select 'Fontan Tax & Accounting'
where not exists (select 1 from public.firmas where nombre = 'Fontan Tax & Accounting');

-- ════════════════════════════════════════════════════════════════
-- CÓMO AÑADIR PERSONAS (una línea por persona, con su correo real):
-- 1. Supabase → Authentication → Add user → email + contraseña,
--    marcando "Auto Confirm User".
-- 2. Correr aquí la línea con el MISMO correo:
--
-- insert into public.miembros (email, firma_id, rol, nombre) values
--   ('contable@fontantax.com',
--    (select id from public.firmas where nombre = 'Fontan Tax & Accounting'),
--    'socio', 'Nombre Apellido');
--
-- rol 'socio' = ve todo (facturación y config) · 'staff' = trabajo diario
-- ════════════════════════════════════════════════════════════════

-- CÓMO AÑADIR OTRA FIRMA (cuando entre el próximo contable):
-- insert into public.firmas (nombre) values ('Nombre de la Firma CPA');
-- ...y luego sus miembros con las líneas de arriba.
