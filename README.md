# CalendarBinoculars

A long-range view of the all-day events from several Google Calendars: 1–12 months on one
screen. It's a single HTML file with no dependencies.

## Quick start

```yaml
# docker-compose.yml
services:
  calbinocs:
    image: ghcr.io/jburanen/calendarbinoculars:latest
    restart: unless-stopped
    ports:
      - 8080:8080
```

```bash
docker compose up -d     # http://localhost:8080
```

Open **Settings**, paste a Google Calendar API key, and add public calendars. A calendar
can be an iCal address, an embed link or a Calendar ID. Settings are saved in your browser.
To use more than one API key, add more accounts.

To upgrade, run `docker compose pull && docker compose up -d`. To host the app without
Docker, download the zip from
[Releases](https://github.com/jburanen/calendarbinoculars/releases).

## Optional: config.yaml

To set the title and calendars once for everyone, put a `config.yaml` file next to
`docker-compose.yml` and mount it into the container. See
[`config.yaml.example`](config.yaml.example) for the format.

```yaml
# docker-compose.yml
services:
  calbinocs:
    image: ghcr.io/jburanen/calendarbinoculars:latest
    restart: unless-stopped
    ports:
      - 8080:8080
    volumes:
      - ./config.yaml:/usr/share/nginx/html/config.yaml:ro
```

Create `config.yaml` before you start the container. If it's missing, Docker creates an
empty directory with that name instead.

Accounts from the file are read-only in Settings. Visitors can still add their own.

## API keys

Anyone who can open the page can read any key in `config.yaml`. A key entered in Settings
stays in that browser. In the Google Cloud Console, restrict each key to the Calendar API,
and to your site's referrer if you can.

## Development

- **Running locally:** `cp docker-compose.yml.example docker-compose.yml` serves your clone
  live.
- **Version bumps:** run `git config core.hooksPath .githooks` once. After that, each commit
  bumps the patch version in `VERSION`. To choose a minor or major version, edit `VERSION`
  yourself.
- **Releases:** every push to `main` with a new version publishes a release, covering the
  image, the tag and the zip.

## License

[MIT](LICENSE)
