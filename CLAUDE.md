# CalendarBinoculars

A single-page web app that shows a long-range, multi-month view of the **all-day events**
from several public Google Calendars.

## Architecture

- **`src/index.html`**: the entire application, with HTML, CSS and JS in one file. It has
  no external libraries or CDNs, no build step and no server-side code.
- **`src/favicon.ico`**: the site icon (binary).
- **`src/config.yaml`** (optional, gitignored): the title plus read-only accounts (API keys
  and calendars), fetched at startup. Its template is `src/config.yaml.example`. The release
  image never includes it; mount it into the container instead.
- **`Dockerfile`**: the release image. It's `nginx:stable-alpine` with `index.html` and
  `favicon.ico` copied in, and nothing else.
- **`docker-compose.yml.example`**: the committed template. Copy it to `docker-compose.yml`,
  which is gitignored and is the user's own copy for each machine. By default it mounts
  `./src` read-only into nginx. Commented lines switch it to the GHCR release image.
- **`.github/workflows/release.yml`**: runs on `v*.*.*` tags. It builds a multi-arch image,
  pushes it to GHCR and creates a GitHub Release with a zip of the static files.

## Running it

```bash
cp docker-compose.yml.example docker-compose.yml   # once
docker compose up -d                              # http://localhost:8082
```

## How the app works

- **Settings live in the browser's `localStorage`** (`adc.*` keys). `adc.settings.v3` holds
  `{accounts:[{name,key,cals:[{url,color,hidden}]}], title, wkst}`. Each account's
  calendars load with that account's API key. The older `adc.settings.v2` format
  (`{key,cals}`) is migrated into a single account. Theme, text size and month count have
  their own keys. Settings are saved only once some account has an API key and there is at
  least one calendar.
- **config.yaml:** `loadConfigFile()` reads it into `fileCfg`. A 404 or fetch failure means
  there's no config, which is not an error. The file is parsed by a built-in YAML-subset
  parser (`parseYAML`) to stay dependency-free. Config accounts are flagged `managed`: they
  render read-only (`configBox`) and are never written to `adc.settings.v3`. Their
  hidden/shown state lives in `adc.hidden.config` (a list of URLs). `allAccounts()` is the
  config accounts plus browser accounts. `cfg.title` overrides `fileCfg.title`, which
  overrides the default title.
- **Fetching:** with an API key, Google calendars load through the Calendar API v3, with
  `singleEvents=true` and all-day events only. Without a key, or for non-Google feeds, the
  app fetches the `.ics` file directly and then falls back to the CORS relays in `PROXIES`.
  The app has its own ICS parser and RRULE expander.
- **Dates** are day numbers (`DN`, days since the epoch in UTC), which avoids timezone and
  DST bugs.
- **Desktop:** month cards. `fitLayout()` picks the columns × rows that fill the window
  (`body.fit`, or `.tight` for smaller screens). Events that overflow are hidden, and the
  day gets a `+N` badge (`markHidden()`).
- **Mobile** (≤768px): one continuous stream of weeks, with alternating month shading.
- The first month shown is remembered in `adc.start`. Any navigation (‹ ›, This Month, or
  the Start month field) updates it. `?start=YYYY-MM` in the URL overrides it.

## Conventions & gotchas

- Keep it a single, dependency-free file. Don't add CDN libraries.
- When you add a shipped file under `src/`, also add it to the `COPY` line in the
  `Dockerfile`, to `.dockerignore` and to the zip step in `release.yml`.
- A release is a pushed git tag such as `v1.2.3`. Don't hand-edit image tags.
- There's no test suite or linter. To verify a change, load the page, add a calendar and
  check that events render, on both desktop and mobile widths.
