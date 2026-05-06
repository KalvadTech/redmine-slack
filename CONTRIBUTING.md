# Contributing

Thanks for considering a contribution. This document covers setup, the change
flow, and the rules we follow for commits and PRs.

## Setup

You need a working Redmine 6.x checkout to run the test suite. The plugin
itself only needs Ruby >= 3.2.

```bash
# Clone Redmine somewhere
git clone https://github.com/redmine/redmine.git ~/redmine
cd ~/redmine
git checkout 6.1-stable

# Symlink or clone this plugin into Redmine's plugins directory
ln -s <path-to-this-repo> plugins/redmine_kalvad_slack

# Configure database (sqlite is fine for development)
cp config/database.yml.example config/database.yml
bundle install
bundle exec rake generate_secret_token
bundle exec rake db:create db:migrate RAILS_ENV=development
bundle exec rake redmine:plugins:migrate NAME=redmine_kalvad_slack RAILS_ENV=development
bundle exec rails server
```

## Local checks

```bash
# Lint
gem install rubocop --version '~> 1.71'
rubocop

# Tests (from the Redmine root, with this plugin in plugins/)
cd ~/redmine
bundle exec rake redmine:plugins:test NAME=redmine_kalvad_slack
```

CI runs Rubocop on every push and PR. Make sure it is clean locally before
pushing.

## Branching and PRs

- Fork the repo, work on a topic branch, open a PR against `main`.
- One logical change per PR. Keep PRs reviewable; large refactors should be
  discussed in an issue first.
- Update `CHANGELOG.md` for user-visible changes.
- Update `README.md` and locales when adding settings or events.
- Tests are required for new logic in `lib/` and `app/`.

## Commit messages

Follow [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/).

Format: `<type>[optional scope][!]: <description>`

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`,
`ci`, `chore`, `revert`. Use `!` or a `BREAKING CHANGE:` footer for breaking
changes.

Examples:

```
feat(payload): emit a watcher field on issue creation
fix(notifier): swallow OpenSSL::SSL::SSLError on bad TLS
docs(readme): clarify Slack member ID setup
refactor!(settings): rename Setting plugin key
```

Constraints:

- One logical change per commit. Do not bundle unrelated edits.
- No AI attribution in commit messages or PR descriptions. No
  `Generated with`, no `Co-Authored-By: Claude`, no similar trailer.
- No emoji in code, comments, commits, PR titles or bodies.
- No em dash or en dash. Use a hyphen, comma, colon, or sentence break.
- Never use `--no-verify`, `--no-gpg-sign`, or skip hooks. If a hook fails,
  fix the cause and create a new commit.
- Never amend a published commit.

## Reporting bugs and proposing features

Use the issue templates in `.github/ISSUE_TEMPLATE/`. Include Redmine version,
Ruby version, plugin version, and reproduction steps.

## Security

Do not file public issues for security problems. See
[SECURITY.md](SECURITY.md) for the disclosure process.

## License

By contributing you agree that your contribution will be licensed under the
MIT License (see [LICENSE](LICENSE)).
