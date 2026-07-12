// config.example.js — copy this file to config.js and fill in your own values:
//
//     cp config.example.js config.js
//
// config.js is gitignored so your API key never lands in version control.
//
// SECURITY NOTE: this is a browser app, so everything here is delivered to
// every visitor and is visible via View Source / DevTools. Keeping it out of
// the repo is good hygiene, but it does NOT hide the key. The real protection
// is to restrict the API key by HTTP referrer in the Google Cloud Console.

window.APP_CONFIG = {
  // Google Calendar API browser key.
  apiKey: 'YOUR_GOOGLE_CALENDAR_API_KEY',

  // Add as many calendars as you like — each needs a Google calendar ID and a
  // display color. The app renders all of them together.
  calendars: [
    { googleCalendarId: 'your-first-calendar-id@group.calendar.google.com',  color: '#EDC14B' },
    { googleCalendarId: 'your-second-calendar-id@group.calendar.google.com', color: '#7D3512' }
  ]
};
