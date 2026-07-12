# CalendarBinoculars

A single-page web app that shows a **continuous, multi-month view** of several Google
Calendars at once — a long-range "binoculars" look at what's coming up. Instead of paging
through one month at a time, it renders many months as one uninterrupted grid of weeks.

## Features

- **Continuous grid** — weeks flow straight across month boundaries with no hard breaks.
  The first day of each month shows the **month name** in place of the day number, with a
  subtle highlight so boundaries stay obvious.
- **Multiple calendars, one view** — aggregates any number of Google Calendars, each with
  its own color.
- **Dark theme** by default.
- **Event-aware rows** — day cells have a comfortable minimum height and grow vertically to
  fit however many events land on a given day.
- **No build step** — plain HTML/CSS/JS served as static files.

## How it works

The whole app is [`src/index.html`](src/index.html). It uses
[FullCalendar](https://fullcalendar.io/) v6 in a single `dayGrid` view spanning
`num_months` (default 9) via `visibleRange`, which is what produces the continuous
month-to-month flow. Events come straight from the Google Calendar API through the
FullCalendar Google Calendar connector. All libraries load from CDNs — there is no
`node_modules` and nothing to compile.

## Prerequisites

- **Docker** (with Compose) to serve the app, or any static file server.
- A **Google Calendar API key** (a browser key from the
  [Google Cloud Console](https://console.cloud.google.com/apis/credentials)).
- The **calendar IDs** you want to display, and each calendar shared such that it's
  readable by the API key.

## Setup

Configuration lives in `src/config.js`, which is **gitignored** so your API key never
lands in version control. Create it from the template:

```bash
cd src
cp config.example.js config.js
```

Then edit `src/config.js` with your key and calendars:

```js
window.APP_CONFIG = {
  apiKey: 'YOUR_GOOGLE_CALENDAR_API_KEY',

  // Add as many calendars as you like.
  calendars: [
    { googleCalendarId: 'first-calendar-id@group.calendar.google.com',  color: '#EDC14B' },
    { googleCalendarId: 'second-calendar-id@group.calendar.google.com', color: '#7D3512' }
  ]
};
```

If `config.js` is missing, the page renders a "Missing config.js" message instead of the
calendar.

## Running

```bash
docker compose up -d      # serves on http://localhost:8082
```

`nginx` serves `./src` directly (see [`docker-compose.yml`](docker-compose.yml)), so edits
to files under `src/` show up on a browser refresh — no rebuild or restart needed.

## Configuration reference

All in `src/config.js` and the top of the script in `src/index.html`:

| What | Where | Notes |
|------|-------|-------|
| API key | `config.js` → `apiKey` | Google Calendar browser key |
| Calendars | `config.js` → `calendars[]` | `{ googleCalendarId, color }`; any number |
| Months shown | `index.html` → `num_months` | Default `9`, starting at the current month |
| Week start | `index.html` → `firstDay` | `1` = Monday |

## Security

This is a **browser app**, so whatever is in `config.js` is delivered to every visitor and
is visible via View Source / DevTools. Keeping it out of the repo is good hygiene, but it
does **not** hide the key. Protect the key by **restricting it to your site's HTTP
referrer** in the Google Cloud Console. If a key is ever exposed in a commit, rotate it —
removing it from a file (or even from git history) does not un-leak an already-public key.

## Tech stack

- [FullCalendar](https://fullcalendar.io/) v6 (+ Google Calendar connector)
- [Bootstrap 5](https://getbootstrap.com/) (`themeSystem: 'bootstrap5'`, dark mode)
- [Moment.js](https://momentjs.com/) for date math and month labels
- `nginx` (via Docker Compose) for static serving
