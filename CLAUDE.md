# CalendarBinoculars

A single-page web app that shows a **continuous multi-month view** of several Google
Calendars at once — a long-range "binoculars" look at what's coming up.

## Architecture

- **`src/index.html`** — the entire application. HTML, CSS, and JS in one file. There is
  no build step and no server-side code.
- **`src/config.js`** — gitignored runtime config holding the Google API key and the list
  of calendars (`window.APP_CONFIG`). Copy `src/config.example.js` to create it; it must
  exist or the page shows a "Missing config.js" message.
- **`src/config.example.js`** — committed template for `config.js`.
- **`src/favicon.ico`** — site icon (binary).
- **`docker-compose.yml`** — serves `src/` as static files via an `nginx` container.

All third-party libraries load from CDNs (no local `node_modules`):

- FullCalendar v6.1.21 global bundle (`index.global.min.js`) — injects its own CSS.
- `@fullcalendar/google-calendar` v6.1.21 — connector required for the Google Calendar
  event sources; **not** part of the core bundle.
- `moment` — used for date math and formatting month labels.
- Bootstrap 5 + Bootstrap Icons — used via `themeSystem: 'bootstrap5'`.

## Running it

```bash
docker compose up        # serves on http://localhost:8082
```

nginx mounts `./src` read-only into the container, so edits to `src/index.html` show up
on refresh — no rebuild needed. In production this runs on an Ubuntu server.

## How the calendar is built

Rather than rendering one FullCalendar per month, it renders a **single** `dayGrid` view
spanning `num_months` (currently 9) via `visibleRange`. This produces one continuous grid
of week rows with no hard month breaks. Key behaviors:

- Day 1 of each month gets a highlighted `.first-of-month` cell and an in-cell
  `.month-label` badge (`dayCellContent` / `dayCellClassNames`).
- `height: 'auto'` plus a CSS `min-height` on `.fc-daygrid-day-frame` gives each row an
  appealing minimum height that grows to fit however many events land that day.
- `firstDay: 1` starts weeks on Monday.
- Calendars to aggregate (and their colors) live in `window.APP_CONFIG.calendars` in
  `config.js`; add/remove Google calendar IDs there (any number is supported).

## Conventions & gotchas

- Keep FullCalendar's three CDN version numbers **in sync** and pinned (currently
  `@6.1.21`); an unpinned URL silently drifts to whatever the CDN serves.
- The API key and calendars live in gitignored `src/config.js`, not in the repo. After a
  fresh clone/pull, `config.js` won't exist — copy `config.example.js` to `config.js` and
  fill it in, or the page renders a "Missing config.js" message.
- This is a **browser app**: whatever is in `config.js` is still delivered to every
  visitor. Keeping it out of git is hygiene only — the real protection is restricting the
  API key by HTTP referrer in Google Cloud Console.
- No test suite or linter — verify changes by loading the page and confirming events
  render and month boundaries look right.
