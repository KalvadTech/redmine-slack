# Changelog

## 0.2.0

Breaking. Configuration model rewritten.

- Removed the global `Administration -> Plugins -> Configure` page entirely.
  All configuration now lives on each project's `Settings -> Slack` tab.
- Per-project schema simplified: tri-state inherit / on / off booleans
  replaced with plain booleans. Defaults: issue created/updated/closed and
  news on; wiki off; private issues/notes off.
- Dropped parent-project cascade. Each project is independent.
- Dropped `@login` to `<@SLACKID>` auto-mention conversion. Users can still
  type Slack-native syntax in notes (`<@U0123ABC>`).
- Dropped configurable `verify_ssl`, `connect_timeout`, `read_timeout`.
  Hardcoded: SSL verified, 3 second open / read timeout.
- Per-project `username` and `icon` now stored on the project setting row.
- Migration `002_recreate_kalvad_slack_settings` drops the old table and
  creates a new one. Existing per-project settings, if any, will be lost.
  Re-enter them on each project's `Settings -> Slack` tab.

## 0.1.0

- Initial release.
- Slack incoming-webhook notifications for Redmine 6.x.
- Events: issue created, updated, closed, wiki page created or updated, news.
- Global settings, per-project tab with tri-state inheritance, parent project
  cascade.
- Optional `@login` to Slack member ID conversion via a user custom field.
- Keyword-based auto-mention tokens (e.g. `@channel`, `@here`).
- Fire-and-forget Net::HTTP delivery with configurable timeouts.
- English and French locales.
