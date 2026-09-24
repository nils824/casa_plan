# CasaPlan

Belegungsplanung für ein Ferienhaus, das mehrere Familienmitglieder gemeinsam nutzen.
Mitglieder fragen Aufenthalte an, der Verwalter bestätigt oder lehnt sie ab. Die Applikation
stellt sicher, dass sich bestätigte Aufenthalte nie überschneiden, auch wenn mehrere Personen
gleichzeitig arbeiten.

Projektarbeit ÜK Modul 223. Details zu Problemstellung, Anforderungen, ERM sowie Locking und
Transaktionen: [`docs/projektdokumentation.md`](docs/projektdokumentation.md).

## Technologie

Ruby 4.0.6, Ruby on Rails 8.1.3.1, SQLite 3, Pundit (Autorisierung), Tailwind CSS 4, rails-i18n.

## Voraussetzungen

Ruby 4.0.6 (z.B. über [mise](https://mise.jdx.dev/)), SQLite 3 und Git.

## Befehle

| Befehl | Zweck |
|---|---|
| `bundle install` | Gems installieren (einmalig nach dem Klonen) |
| `bin/rails db:setup` | Datenbank erstellen und Demo-Daten laden |
| `bin/rails db:reset` | Datenbank zurücksetzen und Demo-Daten neu laden |
| `bin/dev` | Applikation starten auf http://localhost:3000 |
| `bin/rails test` | Alle Tests ausführen |
| `bin/rails console` | Rails-Konsole öffnen |

Erstmalige Einrichtung:

```sh
bundle install
bin/rails db:setup
bin/dev
```

## Demo-Konten

Passwort für alle Konten: `casaplan-demo`

| E-Mail-Adresse | Rolle |
|---|---|
| verwalter@casaplan.ch | Verwalter |
| anna@casaplan.ch | Familienmitglied |
| ben@casaplan.ch | Familienmitglied |
| clara@casaplan.ch | Familienmitglied |

Einladungscode für neue Registrierungen: `moghegno-2026`

## Hinweise

- E-Mails werden nicht verschickt, sondern unter `tmp/mails/` abgelegt (eine Datei pro Adresse).
- Im `Gemfile` ist `json` auf `< 3` beschränkt: `json` 3.x ist mit ActiveSupport 8.1.3.1
  inkompatibel und bricht das Lesen des Session-Cookies.