# Norte Contable — Contexto para asistentes de IA

> Léeme completo antes de tocar nada. Esta app está **EN PRODUCCIÓN** con un
> cliente real (la firma Fontan Tax & Accounting la usa a diario). Un error de
> sintaxis publicado tumba la app para ellos.

## Qué es

Producto SaaS de Carlos (Norte, Manatí PR) para contables/CPAs de Puerto Rico:
calendario contributivo (IVU, retención 10%, patronales, planillas, CRIM,
patente…), tablero de radicación, tareas de equipo, documentos, tiempo,
facturación y renovaciones de permisos. Multi-tenant: cada firma paga
mensualidad y ve solo sus datos. Hay 2 contables más interesados.

## Arquitectura (código → git → Supabase → Netlify)

- **Una sola página**: TODO vive en `index.html` (HTML+CSS+JS inline, sin
  build, sin framework). Tema oscuro "futurista" (teal #3ECFBF + ámbar
  #FFB454 sobre azul #0B1220); respaldo del diseño claro en la rama
  `diseno-clasico`.
- **Repo**: `github.com/sanmi727-cann/norte-contable`, rama `main`, carpeta
  local `~/proyectos/norte-contable`.
- **Netlify**: site `nortecontable` → https://nortecontable.netlify.app —
  deploy automático en ~30 seg con cada push a main. No hay staging: push a
  main = producción.
- **Supabase**: proyecto ref `rysecnkzdabypdltlrtw` (URL y publishable key
  están hardcodeadas en index.html — la publishable es pública, está bien).
  OJO: ese proyecto contiene además una tabla `cierres` ajena (de otra app de
  Carlos) — no tocarla.

## Los dos modos de la app

- **Modo nube** (el site publicado): login email+contraseña de Supabase.
  El campo usuario autocompleta `@norte.app` si escriben solo "fontan".
- **Modo demo** (`?demo` en la URL, o abrir el archivo por `file://`):
  PINs 1234 (Socio) / 0000 (Staff), datos de ejemplo en localStorage,
  generados por `seedState()`. Es la herramienta de ventas — mantenerla
  enseñando todas las funciones nuevas.

## Modelo de datos en Supabase

- `firmas` (id uuid, nombre, **data jsonb**, updated_at): TODO el estado de
  una firma viaja como UN blob JSON en `data` (clientes, radicaciones,
  tareas, config, etc.). No hay tablas normalizadas todavía.
- `miembros` (email pk, firma_id, rol 'socio'|'staff', nombre): quién
  pertenece a qué firma. RLS por `auth.jwt()->>'email'` — cada usuario solo
  ve/edita la fila de SU firma. Esquema completo en `supabase/schema.sql`.
- Sincronización: `saveState()` → debounce 800ms → UPDATE del blob; canal
  realtime recarga el estado si otro miembro guardó (last-write-wins, ventana
  de eco de 3 seg en `nube.ultimoGuardado`).
- Cuentas nuevas: se crean en el dashboard (Auto Confirm) + INSERT en
  miembros (pasos en `INSTRUCCIONES-NUBE.md`). El signup por API exige
  confirmación por email — no sirve para esto.

## Evolución del esquema: migrar()

El estado guardado de una firma puede ser viejo. `migrar()` corre en cada
carga y completa lo que falte (campos nuevos, obligaciones nuevas del
catálogo por id, mudanzas de modelo). REGLAS: solo añadir/mudar con cuidado,
nunca borrar datos que el usuario escribió, siempre idempotente. Las firmas
nuevas nacen de `estadoVacio()` (catálogo listo, cero datos).

## Convenciones del código

- Motor de fechas: `catalogoObligaciones()` + `fechaVence()` + `generarPeriodo()`.
  Frecuencias: mensual/trimestral/estimada/anual/anual_cierre. Fin de semana
  rueda al lunes (`rodarFinDeSemana`). Feriados NO se ruedan (botón Posponer).
- `alias` en cada obligación = nombre amigable ("Retención 10%" por 480.9A);
  mostrar con `oblNombre(o)`; el número técnico va pequeño al lado.
- LLC: `cliente.tributacion` 'corp' (default PR) o 'conducto' → decide
  480.2 vs 480.2(EC) en `aplicaA()`.
- Renovaciones de permisos: `config.renovables` (lista editable) +
  `cliente.renovaciones = {nombre: {num, vence}}`; alerta en Hoy a 60 días
  (`renovacionesPorVencer()`). El Registro de Comerciante vive AQUÍ, no en el
  catálogo de obligaciones.
- Credenciales SURI del cliente: `cliente.suriUsuario/suriPass` (se muestran
  en la ficha con botón "ver").
- Roles: socio ve Facturación y Config; staff no. `config.staff` es la lista
  de NOMBRES para asignar trabajo (no confundir con las cuentas de auth).

## Flujo de trabajo obligatorio para cambios

1. Editar `~/proyectos/norte-contable/index.html`.
2. **Verificar sintaxis ANTES de publicar** (ya hubo un incidente de 5 min):
   extraer el bloque `<script>` más largo y correr `node --check`.
3. Commit descriptivo en español + push a main.
4. Esperar el deploy (~30s) y **verificar en vivo**: la demo en
   `/?demo` y, si el cambio toca datos, entrar como la firma (credenciales
   las tiene Carlos) y confirmar que `migrar()` hizo lo suyo.
5. Si otro Claude/sesión pudo tocar el repo: `git log --oneline -5` ANTES de
   editar. Ya pasó que dos sesiones trabajaron en paralelo.

## Estructura del repo

- `index.html` — la app completa
- `supabase/schema.sql` — tablas + RLS + instrucciones de firmas/miembros
- `INSTRUCCIONES-NUBE.md` — pasos de Carlos para cuentas y setup
- `assets/` — íconos PWA (NC) y logo de Fontan Tax
- `manifest.json` — PWA instalable (sin service worker: requiere internet)
- `docs/` — manual de usuario (.docx) y este contexto

## Estado del cliente Fontan Tax & Accounting (ago 2026)

- Firma id `77a1b51b-6ab7-43e8-a2bf-cee74de9b31a`, logo montado, branding
  completo, 42 clientes importados con perfiles de servicio reales.
- Equipo: Luis M. Fontan (socio), Michelle Rosado y Zulmarie Barreto (staff)
  — cuentas @norte.app activas. El equipo usa la app a diario y pide
  funciones vía Carlos.
- Historial pre-app marcado como radicado con nota "Trabajada antes de
  entrar a la app". 6 planillas 2025 están EN PRÓRROGA hasta el 15 oct 2026.

## Sobre Carlos (el dueño)

No es programador — es productor y QA. Explicarle en español claro, sin
jerga, con verificación en vivo de cada cambio. Él decide el producto; los
pedidos de features suelen venir del equipo de Fontan a través de él.
