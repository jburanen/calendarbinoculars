# Release image: the static app baked into nginx.
# Built and published to GHCR by .github/workflows/release.yml on every v* tag.
FROM nginx:stable-alpine

LABEL org.opencontainers.image.title="CalendarBinoculars" \
      org.opencontainers.image.description="Long-range multi-month view of Google Calendars" \
      org.opencontainers.image.source="https://github.com/jburanen/calendarbinoculars" \
      org.opencontainers.image.licenses="MIT"

# Copy only the shipped files, so stray local files in src/ never end up in an image.
COPY src/index.html src/favicon.ico /usr/share/nginx/html/

EXPOSE 80
