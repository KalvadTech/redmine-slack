# Test harness image for redmine_kalvad_slack.
#
# Builds a Redmine 6 + SQLite container with this plugin pre-installed.
# The official redmine image entrypoint runs db:migrate and
# redmine:plugins:migrate on container start, so no extra wrapping is needed.
#
# Build:  docker build -t redmine-kalvad-slack:test .
# Run:    docker run --rm -p 3000:3000 redmine-kalvad-slack:test
# Browse: http://localhost:3000   (admin / admin on first login)
ARG REDMINE_VERSION=6.0
FROM redmine:${REDMINE_VERSION}

# Plugin id (= directory name under plugins/) must match Redmine::Plugin.register.
COPY --chown=redmine:redmine . /usr/src/redmine/plugins/redmine_kalvad_slack

# Drop git metadata, dev-only files, and CI configuration from the image.
RUN rm -rf \
    /usr/src/redmine/plugins/redmine_kalvad_slack/.git \
    /usr/src/redmine/plugins/redmine_kalvad_slack/.github \
    /usr/src/redmine/plugins/redmine_kalvad_slack/test \
    /usr/src/redmine/plugins/redmine_kalvad_slack/.rubocop.yml
