# RECARO – Übersichtsliste

Durchsuchbare Bauteil-/Schablonenauskunft, liest die Excel-Datei direkt im Browser ein, keine Serverkomponente.

Die Excel-Datei wird nirgendwohin hochgeladen, sondern ausschließlich lokal im Browser verarbeitet.

## Notizen: Zugriffscode

Notizen lesen (Übersicht der offenen Notizen, Verlauf) funktioniert ohne Login,
wie bisher. Zum **Schreiben** (Notiz anlegen/erledigen, Foto anhängen, Push
an-/abmelden) fragt die App beim ersten Versuch einmalig per Fenster nach
einem Zugriffscode. Der Code wird nur lokal im Browser gespeichert
(`localStorage`) und bei jedem Schreibzugriff an Supabase mitgeschickt; das
Backend (RLS-Policy, siehe `supabase/migrations/`) lehnt Schreibversuche ohne
oder mit falschem Code ab - unabhängig davon, was im Quelltext steht.

Der Code selbst steht nirgends im Repo. Er liegt ausschließlich in Supabase
Vault des Projekts `recaro-notizen`. Bei Bedarf (Rotation, neue:r
Kolleg:in, Verdacht auf Weitergabe) im Supabase-Dashboard unter
**Database → Vault** den Eintrag `app_write_secret` aktualisieren.

**Weitergabe an Kolleg:innen:** mündlich oder über einen bereits vertrauten
Kanal (z. B. persönlich, Diensttelefon), nicht per offener/durchsuchbarer
Ablage und nicht im Repo/Issue/Commit. Wer den Code kennt, kann in der App
schreiben - also nur an Kolleg:innen weitergeben, die die Notizfunktion
aktiv nutzen sollen. Bei Verdacht auf Missbrauch: Code in Vault ändern (siehe
oben) - alle, die den alten Code hatten, müssen ihn dann neu eingeben (der
Browser fragt automatisch erneut, sobald der gespeicherte Code vom Server
abgelehnt wird).
