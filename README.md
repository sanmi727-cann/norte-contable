# Norte Contable

Gestión de práctica para contables, CPAs y preparadores de planillas de Puerto Rico.

Calendario contributivo de PR (IVU, 480.9A, 499-R-1B, informativas, patente, CRIM), tablero de radicación, prórrogas, checklist de documentos por tipo de entidad, tareas del equipo, bitácora por cliente, tiempo y facturación con retención en el origen.

- App de un solo archivo: `index.html`
- **Modo nube (multi-tenant):** el site publicado usa Supabase — login por email/contraseña, cada firma ve solo sus datos (RLS), sincronización en vivo entre computadoras y logo propio por firma. Activación: ver `INSTRUCCIONES-NUBE.md` y `supabase/schema.sql`.
- **Modo demo (ventas):** añadir `?demo` a la URL, o abrir el archivo local — PIN Socio: 1234 · PIN Staff: 0000, datos de ejemplo en localStorage.

Norte · Manatí, Puerto Rico
