# Norte Contable — pasos para activar la nube

Son 3 pasos. Los haces una vez y de ahí en adelante todo es automático.

## 1. Crear las tablas (una sola vez)

1. Entra a [supabase.com](https://supabase.com) → tu proyecto de Norte Contable
2. Menú izquierdo → **SQL Editor** → **New query**
3. Abre el archivo `supabase/schema.sql` de este repo, copia TODO y pégalo
4. Botón **Run**. Debe decir "Success". (Si la línea de `supabase_realtime` da error "already member", ignóralo — es que ya estaba.)

Con eso quedan las tablas, la seguridad (cada firma ve solo lo suyo) y la firma de Fontan Tax creada.

## 2. Crear la cuenta de cada persona

Por cada persona que va a usar la app (el contable, su staff):

1. Supabase → **Authentication** → **Users** → **Add user** → **Create new user**
2. Pon su **email** y una **contraseña**, y marca ✅ **Auto Confirm User**
3. Vuelve al **SQL Editor** y corre esta línea con el mismo email (está también al final de `schema.sql`):

```sql
insert into public.miembros (email, firma_id, rol, nombre) values
  ('elcorreo@delcontable.com',
   (select id from public.firmas where nombre = 'Fontan Tax & Accounting'),
   'socio', 'Su Nombre');
```

- `'socio'` → ve todo, incluyendo facturación y configuración
- `'staff'` → trabajo diario, sin facturación ni config

## 3. Publicar en Netlify

1. [app.netlify.com](https://app.netlify.com) → **Add new site** → **Import an existing project** → GitHub → repo **norte-contable**
2. Sin configuración especial (es un solo archivo). **Deploy**.
3. La dirección que te dé Netlify es la que usan TODOS los contables — cada uno entra con su cuenta y ve solo su firma.

## Notas

- **La demo de ventas** sigue viva en la misma dirección añadiendo `?demo` al final (ej. `tusitio.netlify.app/?demo`) — abre con los PINs de siempre (1234 / 0000) y datos de mentira. La pantalla de login de la nube tiene un enlace directo a la demo.
- **Firma nueva** (próximo contable): una línea de SQL para la firma + sus usuarios. Está al final de `schema.sql`.
- **Cambiar una contraseña**: Authentication → Users → los tres puntitos → Reset password (o bórralo y créalo de nuevo).
- La clave que va dentro de la app (`sb_publishable_...`) es la **pública** — está bien que se vea. La `service_role`/secret **nunca** va en la app ni se comparte.
