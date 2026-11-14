# CalendarBinoculars

A single-page web app for a **long-range look at the all-day events** in several Google
Calendars at once. Instead of paging through one month at a time, you see up to 12 months
together.

## Features

- **Many months at once.** Show 1–12 months. On desktop, the month cards resize to fill the
  window. If a day has more events than fit, it shows a "+N" badge.
- **Mobile stream.** On narrow screens the months run together as one continuous list of
  weeks.
- **Multiple calendars, one view.** Add any number of public Google Calendars, each with a
  Google-style color. Click a calendar in the legend to show or hide it.
- **Multi-day events** are drawn as bars that span days, with consistent lanes so they line
  up.
- **Click a day** to see the full titles of all its events.
- **Multiple API keys.** Group calendars into accounts, each with its own API key.
- **Settings stay in the browser.** The accounts and their API keys, calendars, title, week start, text size
  and theme (dark or light) are saved in `localStorage`. There's nothing to configure on
  the server.
- **Open `.ics` files** to view a downloaded calendar. These aren't saved.
- **No dependencies.** One HTML file with inline CSS and JS, and no CDNs or build step.

## Using it

Open the page and click **Settings**:

1. Fill in the first **account**. Give it an optional name and paste a **Google Calendar
   API key**. See "How to get an API key" in the panel: enable the Google Calendar API in
   the [Google Cloud Console](https://console.cloud.google.com/apis/credentials) and create
   an API key.
2. Add one or more calendars to the account. You can paste a public **iCal address**, an
   **embed link** or a **Calendar ID**. The calendar must be public.
3. To use more than one API key, click **+ Add account**. Each account's calendars load
   with that account's key.
4. Click **Load calendars**.

Without an API key, the app tries to fetch the public iCal feed directly and then through
public CORS relays. This works less reliably, so an API key is recommended.

## Optional config file

Instead of entering everything in each browser, you can set the page title, API keys and
calendar links in a `config.yaml` file next to `index.html`:

```bash
cp src/config.yaml.example src/config.yaml     # gitignored
```

```yaml
title: Calendar Binoculars

accounts:
  - name: Family
    api_key: AIza...
    calendars:
      - url: https://calendar.google.com/calendar/ical/.../public/basic.ics
        color: "#039BE5"           # optional; quote it
      - another-id@group.calendar.google.com
```

- **Where it shows up:** accounts from the file appear for every visitor and are read-only
  in Settings, marked `config.yaml`. Visitors can still add their own accounts in the
  browser.
- **Hiding calendars:** hiding a calendar from the legend is remembered in each browser.
- **Title:** the file's `title` replaces the default. A title typed in Settings still takes
  priority.
- **Colors:** colors are optional. Quote them (`"#039BE5"`), because an unquoted `#` starts
  a comment in YAML.
- **No file needed:** if there's no `config.yaml`, the app works entirely from browser
  settings, as before.
- **Errors:** if the file can't be parsed, the page shows the error and the line number.

The app reads a simple subset of YAML: nested maps and `- ` lists, plain or quoted values,
and `#` comments. It doesn't support anchors, inline `[a, b]` or `{a: b}` values, or
multi-line strings.

**Security:** `config.yaml` is sent to the browser, so anyone who can load the page can read
its API keys. Restrict each key in the Google Cloud Console, as described below.

## Running it

Copy the example compose file. Your `docker-compose.yml` is gitignored, so you can adjust it
for each machine.

```bash
cp docker-compose.yml.example docker-compose.yml
docker compose up -d          # serves on http://<host>:8082
```

As written, the example mounts `./src` into nginx, so edits to `src/index.html` show up when
you refresh the browser.

### Using a release image

Each release is published as a Docker image at `ghcr.io/jburanen/calendarbinoculars`. It's
nginx with the app baked in, so the server doesn't need a clone of the repo. In your
`docker-compose.yml`, change three things:

1. Swap the `image:` line for the commented `ghcr.io/...` one.
2. To pin a version, change `:latest` to a tag such as `:1.0.0`.
3. Replace the `./src` volume with the commented `config.yaml` mount. If you don't use a
   config file, remove the `volumes:` block instead.

To upgrade:

```bash
docker compose pull && docker compose up -d
```

Every release also attaches a zip of the static files to the
[GitHub Release](https://github.com/jburanen/calendarbinoculars/releases), so you can host
it with any static web server.

## Cutting a release

Push a semver tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

[`.github/workflows/release.yml`](.github/workflows/release.yml) then builds the image for
amd64 and arm64. It pushes the image to GHCR with the tags `1.0.0`, `1.0`, `1` and
`latest`, and creates a GitHub Release with the zip attached.

## Security

Keys entered in Settings are saved only in that visitor's browser, and the server never sees
them. Keys in `config.yaml` are public to anyone who can load the page. Either way they're
browser keys, so **restrict each one** in the Google Cloud Console to the Google Calendar
API, and to your site's HTTP referrer if you can.

## License

Released under the [MIT License](LICENSE).
