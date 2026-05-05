# redmine_kalvad_slack

[![lint](https://github.com/KalvadTech/redmine-slack/actions/workflows/lint.yml/badge.svg)](https://github.com/KalvadTech/redmine-slack/actions/workflows/lint.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Redmine](https://img.shields.io/badge/Redmine-%E2%89%A56.0-c61b1b.svg)](https://www.redmine.org/)

Slack incoming-webhook notifications for Redmine 6.x.

A focused, opinionated rewrite of the Slack feature surface from
[`alphanodes/redmine_messenger`](https://github.com/alphanodes/redmine_messenger).
Slack only, Redmine 6 only, zero extra runtime dependencies, fire-and-forget
delivery, with a per-project override tab that inherits from a global default.

## Features

- Posts on issue created, updated, closed, wiki page created or updated, news.
- Color-coded Slack `attachments` payload (green, blue, grey, purple, yellow).
- Global plugin settings plus a dedicated `Slack` tab in each project's settings.
- Per-project tri-state overrides (`Inherit`, `On`, `Off`) for every toggle.
- Cascade: project -> parent project chain -> global default.
- Privacy gates: choose whether to post private issues and private notes.
- Optional `@login` to Slack `<@U0123ABC>` conversion via a user custom field.
- Keyword-based auto-mention tokens (e.g. `@channel`, `@here`, `<!subteam^XYZ>`).
- Net::HTTP delivery with configurable timeouts and SSL verification.
- English and French locales.

## Compatibility

| Component | Version       |
| --------- | ------------- |
| Redmine   | >= 6.0.0      |
| Rails     | 7.2           |
| Ruby      | >= 3.2        |
| Slack     | Incoming webhooks (legacy `attachments` payload) |

## Install

> [!IMPORTANT]
> The plugin directory under `plugins/` must be named `redmine_kalvad_slack`.
> The repository slug on GitHub is `redmine-slack` (with a hyphen) but Redmine
> requires the directory name to match the plugin id passed to
> `Redmine::Plugin.register`, which is `redmine_kalvad_slack` (with
> underscores). The clone, submodule, or symlink commands below all rename to
> the correct path. If you have already cloned to a different name, run
> `git mv plugins/<wrong-name> plugins/redmine_kalvad_slack` from inside your
> Redmine checkout.

### Option 1: clone

```bash
cd <redmine>/plugins
git clone https://github.com/KalvadTech/redmine-slack.git redmine_kalvad_slack
cd ..
bundle install
bundle exec rake redmine:plugins:migrate RAILS_ENV=production NAME=redmine_kalvad_slack
```

### Option 2: submodule

```bash
cd <redmine>
git submodule add https://github.com/KalvadTech/redmine-slack.git plugins/redmine_kalvad_slack
git submodule update --init --recursive
bundle install
bundle exec rake redmine:plugins:migrate RAILS_ENV=production NAME=redmine_kalvad_slack
```

### Option 3: symlink (development)

```bash
ln -s <path-to-this-repo> <redmine>/plugins/redmine_kalvad_slack
cd <redmine>
bundle install
bundle exec rake redmine:plugins:migrate RAILS_ENV=development NAME=redmine_kalvad_slack
```

Restart Redmine.

## Uninstall

```bash
cd <redmine>
bundle exec rake redmine:plugins:migrate NAME=redmine_kalvad_slack VERSION=0 RAILS_ENV=production
rm -rf plugins/redmine_kalvad_slack
```

## Configuration

### Global

`Administration -> Plugins -> Redmine Kalvad Slack -> Configure`.

| Setting | Notes |
| --- | --- |
| Slack webhook URL | Incoming webhook URL from Slack. |
| Channel | e.g. `#redmine`. Use a single dash (`-`) at the project level to disable notifications for that project. |
| Posted as | Display name shown in Slack. Defaults to `Redmine`. |
| Icon | `:emoji:` code or HTTPS URL. |
| Per-event toggles | One checkbox each for issue created, updated, closed, wiki created, wiki updated, news. |
| Privacy gates | `Post private issues`, `Post private notes`. |
| Auto-mention keywords | Comma-separated literal tokens (e.g. `@channel`, `@here`). Appended to the Slack message when found in issue text. |
| User custom field with Slack member ID | A `UserCustomField` whose value holds each user's Slack member id (e.g. `U0123ABC`). |
| Verify SSL | Default on. |
| Connect / read timeout | Seconds. Default 3. |

### Permissions

Grant `Manage Kalvad Slack` to the roles that should be allowed to edit the
per-project tab. Set under `Administration -> Roles and permissions`.

### Per-project tab

`Project -> Settings -> Slack`.

- Webhook URL and channel can be overridden.
- Every toggle is tri-state: `Inherit`, `On`, `Off`.
- Settings cascade: project -> parent project chain -> global default.

### Slack mentions setup

To convert `@redmine_login` in issue text to a Slack user mention:

1. `Administration -> Custom fields -> Users -> New`. Format: Text. Name:
   `Slack Member ID` (or any name).
2. Note the field's numeric id, then paste it into
   `Administration -> Plugins -> Redmine Kalvad Slack -> Configure ->
   User custom field with Slack member ID`.
3. Each user enters their own Slack member id (e.g. `U0123ABC`) under
   `My account`. Slack member ids are visible in Slack under
   `Profile -> View full profile -> three dots -> Copy member ID`.
4. Make sure `Convert @logins to Slack mentions` is on.

## Events

| Event             | Color  |
| ----------------- | ------ |
| Issue created     | green  |
| Issue updated     | blue   |
| Issue closed      | grey   |
| Wiki page created | purple |
| Wiki page updated | purple |
| News              | yellow |

## Behavior notes

- Delivery is fire-and-forget over `Net::HTTP` with a 3-second connect / read
  timeout. Failures are logged at `warn` and swallowed: a Slack outage will
  never raise out of a Redmine save.
- No retries. Slack incoming webhooks tolerate roughly one message per second
  per channel; bulk updates will burst.
- No external gem dependencies.
- Translations: English (`en`) and French (`fr`).

## Troubleshooting

- Nothing is posted: check `log/production.log` for lines tagged
  `[redmine_kalvad_slack]`.
- 4xx from Slack: usually a bad webhook URL or a channel the webhook is not
  authorized for.
- A specific project goes silent: check the project's `Slack` tab. A channel
  set to `-` disables the project, and the master `Enabled` toggle on `Off`
  stops everything.

## Development

```bash
# Lint
gem install rubocop --version '~> 1.71'
rubocop

# Tests (requires a Redmine 6 checkout with this plugin under plugins/)
bundle exec rake redmine:plugins:test NAME=redmine_kalvad_slack
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for setup and PR conventions, and
[AGENTS.md](AGENTS.md) for guidance when working with AI coding assistants.

## Security

To report a vulnerability, see [SECURITY.md](SECURITY.md).

## License

MIT. See [LICENSE](LICENSE).
