# Release image: the static app baked into nginx.
# Built and published to GHCR by .github/workflows/release.yml on each new VERSION pushed to main.
FROM nginx:stable-alpine

# Listen on 8080 instead of 80. The grep makes the build fail loudly if the stock config changes.
RUN sed -i -E 's/listen([[:space:]]+)80;/listen\18080;/; s/listen([[:space:]]+)\[::\]:80;/listen\1[::]:8080;/' \
        /etc/nginx/conf.d/default.conf \
 && grep -qE 'listen[[:space:]]+8080;' /etc/nginx/conf.d/default.conf

LABEL org.opencontainers.image.title="CalendarBinoculars" \
      org.opencontainers.image.description="Long-range multi-month view of Google Calendars" \
      org.opencontainers.image.source="https://github.com/jburanen/calendarbinoculars" \
      org.opencontainers.image.licenses="MIT"

# Copy only the shipped files, so config.yaml and other local files never end up in an image.
COPY index.html favicon.ico /usr/share/nginx/html/

EXPOSE 8080
