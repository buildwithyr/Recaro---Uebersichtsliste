# RECARO – Übersichtsliste

Eine installierbare, durchsuchbare Bauteil- und Schablonenauskunft. Die Anwendung liest die betriebliche Excel-Arbeitsmappe direkt im Browser und verknüpft Bauteile, Schablonen und Einzelteile miteinander.

## Bedienung

1. `index.html` über HTTPS (empfohlen) oder einen lokalen Webserver öffnen.
2. **Datei auswählen** und die aktuelle `.xlsx`/`.xlsm`-Datei laden.
3. Nach Nummer, Projekt oder vorhandenen Beschreibungsfeldern suchen; Trennzeichen und Revisionskennung dürfen entfallen.
4. Treffer per Maus, Touch oder Pfeiltasten/Enter öffnen. Nummern lassen sich kopieren und die Browser-Zurück-Funktion führt durch die Details.

## Zwei Einträge vergleichen

Über **Vergleichen** können zwei Bauteile, zwei Schablonen oder zwei Einzelteile als A und B ausgewählt werden. Nach der zweiten Auswahl öffnet sich automatisch eine responsive Vergleichsansicht. Unterschiede werden hervorgehoben, fehlende Angaben klar gekennzeichnet und Listen wie Schablonen- oder Bauteilzuordnungen unabhängig von ihrer Reihenfolge als Mengen verglichen. Optional lassen sich nur Unterschiede anzeigen sowie beide Nummern kopieren, ersetzen oder zurücksetzen. Die Auswahl gilt nur für die aktuelle Browser-Sitzung. Über **Drucken / PDF** kann der Vergleich vollständig lokal gedruckt oder als PDF gespeichert werden.

Erwartet werden die Blätter **Übersichtsliste**, **Schablnr - Bauteilnr.** und **Schablonen**. Vor dem Import werden Blattaufbau, Datenpositionen und verwertbare Nummern geprüft. Fehler verhindern einen unsicheren Import; weniger kritische Abweichungen erscheinen als Warnung.

## Datenschutz und Offline-Daten

Die Excel-Datei wird ausschließlich im Arbeitsspeicher des Browsers verarbeitet und **nie hochgeladen**. Es gibt keine Serverkomponente. Erst nach einem bewussten Klick auf **Offline verfügbar machen** wird nur das daraus erzeugte Datenmodell samt Dateimetadaten in IndexedDB gespeichert – niemals die Originaldatei. **Lokale Daten löschen** entfernt diesen Datenstand wieder. Der Suchverlauf liegt ausschließlich im lokalen Browser-Speicher und kann separat gelöscht werden.

Der Service Worker speichert lediglich die App-Shell (HTML, Manifest und Icons). Excel-Anfragen werden ausdrücklich nicht gecacht.

## PWA und iPhone

Die Anwendung unterstützt aktuelle Versionen von Chrome und Edge am PC sowie Safari auf dem iPhone. In Safari: Seite über HTTPS öffnen, **Teilen** wählen und **Zum Home-Bildschirm** antippen. Nach dem ersten Online-Aufruf kann die App-Shell offline starten; fachliche Daten sind offline nur verfügbar, wenn sie zuvor ausdrücklich lokal gespeichert wurden.

Google Fonts sind eine optionale Gestaltungsergänzung. Sind sie offline nicht erreichbar, verwendet die App lokale System- und Monospace-Schriften.

## Barcode-Scanner

Der Scanner benötigt eine Kameraberechtigung und einen sicheren Kontext (HTTPS oder localhost). Er verwendet – je nach Browser – `BarcodeDetector` oder den vorhandenen ZXing-Fallback. Beim Schließen werden Kamera und Scanschleife beendet.

Safari gestattet Kamera, Service Worker und Installation nicht zuverlässig bei einer direkt aus der Dateien-App geöffneten HTML-Datei (`file://`). Verwenden Sie für diese Funktionen eine HTTPS-Testseite. Die File System Access API zum erneuten Öffnen einer gewählten Datei ist derzeit primär in Chrome/Edge verfügbar; Safari kann die Datei weiterhin normal neu auswählen.

## Lokaler Start

```bash
python3 -m http.server 8000
```

Danach `http://localhost:8000` öffnen. Für Tests auf einem iPhone ist eine echte HTTPS-Adresse erforderlich.

## Organisatorische Empfehlungen nach erfolgreichem Test

Repository-Beschreibung und Homepage-Link können später manuell ergänzt werden. Sichtbarkeit, Standard-Branch und GitHub-Pages-Quelle sollten erst nach ausdrücklicher Freigabe geändert werden. Für eine Pages-Testversion kann vorübergehend dieser Feature-Branch als Quelle gewählt und danach wieder auf die bisherige Quelle zurückgestellt werden.
