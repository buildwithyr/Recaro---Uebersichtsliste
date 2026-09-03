-- Schreibschutz fuer notizen / push_subscriptions / storage.objects (Bucket notiz-fotos).
--
-- Hintergrund: SB_URL und SB_ANON_KEY stehen bewusst im Klartext im Client
-- (index.html), weil die App ohne Login funktionieren soll. Der Anon-Key
-- erlaubt aber jedem, der den Quelltext liest, ueber die REST-API direkt zu
-- schreiben - unabhaengig davon, was die UI verlangt. Diese Migration
-- verlangt deshalb zusaetzlich einen geheimen Request-Header (x-app-secret)
-- fuer INSERT/UPDATE/DELETE. Lesen (SELECT) auf notizen bleibt offen, siehe
-- Aufgabenstellung - das sind interne Werkstatt-Notizen ohne Login.
--
-- Der eigentliche Geheimwert steht NICHT in dieser Datei. Er liegt in
-- Supabase Vault (vault.create_secret(...)) unter dem Namen
-- 'app_write_secret' und wurde separat per SQL gesetzt, bevor diese
-- Migration angewendet wurde. Diese Datei referenziert den Secret-Namen nur.
--
-- Quelle fuer die verwendete PostgREST-Syntax (current_setting('request.headers', true)):
-- https://supabase.com/docs/guides/api/securing-your-api (Abschnitt
-- "Accessing request headers/cookies" bzw. "Rate limiting"/"Restricting access
-- to your API").

-- 1) Pruef-Funktion: vergleicht den Header x-app-secret mit dem Vault-Secret.
--    security definer, damit anon/authenticated nicht direkt auf vault.*
--    zugreifen muessen; search_path leer gegen Function-Search-Path-Hijacking.
create or replace function public.check_app_secret()
returns boolean
language sql
security definer
set search_path = ''
stable
as $$
  select coalesce(
    (select current_setting('request.headers', true)::json ->> 'x-app-secret'),
    ''
  ) = coalesce(
    (select decrypted_secret from vault.decrypted_secrets where name = 'app_write_secret'),
    -- Kein Secret hinterlegt -> Vergleich schlaegt garantiert fehl statt alles zu erlauben.
    '__kein_secret_hinterlegt__'
  );
$$;

revoke all on function public.check_app_secret() from public;
grant execute on function public.check_app_secret() to anon, authenticated;

-- 2) notizen: Lesen bleibt offen, Schreiben (insert/update/delete) braucht den Header.
drop policy if exists "offen_notizen_alle" on public.notizen;

create policy "notizen_select_offen"
on public.notizen
for select
to public
using (true);

create policy "notizen_write_mit_code"
on public.notizen
for all
to public
using (public.check_app_secret())
with check (public.check_app_secret());

-- 3) push_subscriptions: komplett intern (Push-Endpunkte), auch hier
--    Schreiben nur mit Code. Lesen wird von der App nicht ueber die REST-API
--    gebraucht (nur vom Server/Trigger fuer den Push-Versand), daher auch
--    fuer SELECT den Code verlangen.
drop policy if exists "offen_push_subscriptions_alle" on public.push_subscriptions;

create policy "push_subscriptions_mit_code"
on public.push_subscriptions
for all
to public
using (public.check_app_secret())
with check (public.check_app_secret());

-- 4) storage.objects (Bucket notiz-fotos): Lesen bleibt offen (Fotos werden
--    in der Notiz-Ansicht angezeigt, Bucket ist public), Hochladen braucht
--    den Code. Bestehende offene INSERT-Policy wird ersetzt.
--
--    WICHTIG: Supabase Storage ist ein eigener Dienst (nicht PostgREST) und
--    setzt beim Ausfuehren der SQL-Queries KEIN current_setting('request.headers')
--    (per Quellcode-Pruefung von supabase/storage, src/storage/database/pg.ts:
--    keine set_config-Aufrufe fuer Request-Header/-Metadaten auf dem Query-Pfad).
--    Ein x-app-secret-Header waere in einer storage.objects-Policy also NICHT
--    sichtbar - anders als bei notizen/push_subscriptions ueber PostgREST.
--    Deshalb wird der Code hier stattdessen als Teil des Objekt-Pfads
--    mitgegeben, aber NICHT im Klartext: der Client haengt dem Dateinamen
--    einen SHA-256-Hash aus Code+Dateiname voran (Ordner-Segment), die Policy
--    berechnet denselben Hash serverseitig aus dem Vault-Secret nach und
--    vergleicht. So bleibt der Vergleich vollstaendig in der Datenbank, ohne
--    dass der Klartext-Code in der (oeffentlich lesbaren) Foto-URL auftaucht.
create or replace function public.notiz_foto_pfad_gueltig(pfad text)
returns boolean
language sql
security definer
set search_path = ''
stable
as $$
  select
    array_length(storage.foldername(pfad), 1) = 1
    and (storage.foldername(pfad))[1] = encode(
      extensions.digest(
        coalesce(
          (select decrypted_secret from vault.decrypted_secrets where name = 'app_write_secret'),
          '__kein_secret_hinterlegt__'
        ) || ':' || storage.filename(pfad),
        'sha256'
      ),
      'hex'
    );
$$;

revoke all on function public.notiz_foto_pfad_gueltig(text) from public;
grant execute on function public.notiz_foto_pfad_gueltig(text) to anon, authenticated;

drop policy if exists "offen_notiz_fotos_insert" on storage.objects;

create policy "notiz_fotos_insert_mit_code"
on storage.objects
for insert
to public
with check (
  bucket_id = 'notiz-fotos'
  and public.notiz_foto_pfad_gueltig(name)
);

-- 5) Bucket-Beschraenkung als zweite, vom Header unabhaengige Absicherung:
--    nur JPEG, max. 8 MB (Fotos werden im Client bereits auf ~1280px/JPEG
--    komprimiert, 8 MB laesst Luft nach oben).
update storage.buckets
set allowed_mime_types = array['image/jpeg'],
    file_size_limit = 8388608
where id = 'notiz-fotos';
