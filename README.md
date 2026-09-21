# CasaPlan

CasaPlan ist eine Multi-User-Applikation zur Belegungsplanung eines gemeinsam genutzten Ferienhauses.
Familienmitglieder fragen Aufenthalte an, der Verwalter bestätigt oder lehnt sie ab. Die Applikation
garantiert, dass sich bestätigte Aufenthalte nie überschneiden, auch bei gleichzeitigen Zugriffen.

Projektarbeit im ÜK Modul 223. Die Projektdokumentation (Was und Warum) befindet sich unter
[`docs/projektdokumentation.md`](docs/projektdokumentation.md).

## Technologie-Stack

| Komponente | Version |
|---|---|
| Ruby | 4.0.6 |
| Ruby on Rails | 8.1.3.1 |
| Datenbank | SQLite 3 |
| Autorisierung | Pundit |
| CSS | Tailwind CSS 4 (tailwindcss-rails) |
| Übersetzungen | rails-i18n (Deutsch) |

## Voraussetzungen

- [mise](https://mise.jdx.dev/) (oder eine andere Ruby-Versionsverwaltung) mit Ruby 4.0.6
- SQLite 3
- Git

## Installation

```sh
git clone <repository-url> casa_plan
cd casa_plan
mise use ruby@4.0.6      # nur nötig, falls Ruby 4.0.6 noch nicht aktiv ist
bundle install
```

## Datenbank und Demo-Daten

```sh
bin/rails db:setup
```

Der Befehl erstellt die Datenbank, lädt das Schema und legt über `db/seeds.rb` die Demo-Daten an:
ein Haus, vier Benutzer, einen bestätigten Aufenthalt und zwei sich überschneidende offene Anfragen.

Datenbank zurücksetzen: `bin/rails db:reset`

## Starten

```sh
bin/dev
```

Startet den Rails-Server und den Tailwind-Watcher. Die Applikation läuft auf
[http://localhost:3000](http://localhost:3000).

## Demo-Konten

Alle Demo-Konten verwenden das Passwort `casaplan-demo`.

| E-Mail-Adresse | Rolle |
|---|---|
| verwalter@casaplan.ch | Verwalter |
| anna@casaplan.ch | Familienmitglied |
| ben@casaplan.ch | Familienmitglied |
| clara@casaplan.ch | Familienmitglied |

Einladungscode für neue Registrierungen: `moghegno-2026`

## E-Mails in der Entwicklungsumgebung

E-Mails (Passwort zurücksetzen, E-Mail-Adresse bestätigen) werden nicht verschickt, sondern als Datei
unter `tmp/mails/` abgelegt, eine Datei pro Empfängeradresse. Der Bestätigungslink für eine neue
E-Mail-Adresse erscheint zusätzlich im Server-Log.

## Tests

```sh
bin/rails test
```

Die Tests verwenden die separate Testdatenbank und die Fixtures unter `test/fixtures`.

## Bekannte Einschränkung

Im `Gemfile` ist `json` auf Version `< 3` beschränkt. `json` 3.x akzeptiert bei `JSON.parse` nur noch
Keyword-Optionen, ActiveSupport 8.1.3.1 übergibt sie aber als Hash. Dadurch schlägt das Lesen des
Session-Cookies fehl. Die Einschränkung kann entfernt werden, sobald Rails das behoben hat.
