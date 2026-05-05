# redmine_kalvad_slack

[![lint](https://github.com/KalvadTech/redmine-slack/actions/workflows/lint.yml/badge.svg)](https://github.com/KalvadTech/redmine-slack/actions/workflows/lint.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Redmine](https://img.shields.io/badge/Redmine-%E2%89%A56.0-c61b1b.svg)](https://www.redmine.org/)

Slack incoming-webhook notifications for Redmine 6.x.

A focused, opinionated rewrite inspired by
[`alphanodes/redmine_messenger`](https://github.com/alphanodes/redmine_messenger).
Slack only, Redmine 6 only, zero extra runtime gem dependencies, fire-and-forget
delivery. Configuration is fully per-project: there is no global plugin
settings page.

## Features

- Posts on issue created, updated, closed, wiki page created or updated, news.
- Color-coded Slack `attachments` payload (green, blue, grey, purple, yellow).
- Each project has its own `Settings -> Slack` tab. No global config.
- Per-project webhook URL, channel, posted-as username, and icon.
- Per-event boolean toggles, plus privacy gates for private issues and
  private notes.
- Net::HTTP delivery with hardcoded 3 second open and read timeouts.
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

There is no global configuration. Each project sets its own Slack target.

### Permissions

Grant `Manage Kalvad Slack` to the roles that should be allowed to edit the
per-project tab. Set under `Administration -> Roles and permissions`.

### Per-project tab

`Project -> Settings -> Slack`.

| Field | Notes |
| --- | --- |
| Slack webhook URL | Incoming webhook URL from Slack. Required. |
| Channel | e.g. `#redmine`. Required. Set to a single dash (`-`) to disable notifications without clearing the rest of the config. |
| Posted as | Display name shown in Slack. Defaults to `Redmine`. |
| Icon | `:emoji:` code or HTTPS URL. Optional. |
| Enabled | Master toggle. Off disables all delivery for this project. |
| Per-event toggles | Issue created, updated, closed, wiki created, wiki updated, news. |
| Privacy gates | `Post private issues`, `Post private notes`. Off by default. |
| Display watchers | Adds a watchers field on issue creation. |
| Include description on creation | Adds the issue description as the attachment text. |

A project posts to Slack only if all of these are true: a `KalvadSlackSetting`
row exists, `enabled` is on, the webhook URL is non-blank, and the channel is
non-blank and not `-`.

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

- Delivery is fire-and-forget over `Net::HTTP` with a hardcoded 3 second open
  and read timeout. Failures are logged at `warn` and swallowed: a Slack
  outage will never raise out of a Redmine save.
- No retries. Slack incoming webhooks tolerate roughly one message per second
  per channel; bulk updates will burst.
- No external gem dependencies.
- Translations: English (`en`) and French (`fr`).

## Troubleshooting

- Nothing is posted: check `log/production.log` for lines tagged
  `[redmine_kalvad_slack]`. Confirm the project's `Slack` tab has a webhook
  URL, a channel that is not `-`, and `Enabled` ticked.
- 4xx from Slack: usually a bad webhook URL or a channel the webhook is not
  authorized for.

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
