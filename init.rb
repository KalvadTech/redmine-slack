# frozen_string_literal: true

require_relative 'lib/redmine_kalvad_slack'

Redmine::Plugin.register :redmine_kalvad_slack do
  name 'Redmine Kalvad Slack'
  author 'Kalvad'
  url 'https://github.com/KalvadTech/redmine-slack'
  author_url 'https://kalvad.com'
  description 'Slack incoming-webhook notifications for Redmine 6.x.'
  version RedmineKalvadSlack::VERSION
  requires_redmine version_or_higher: '6.1.0'

  permission :manage_kalvad_slack,
             { kalvad_slack_settings: :update },
             require: :member
end

RedmineKalvadSlack.setup!

Rails.application.reloader.to_prepare do
  RedmineKalvadSlack.setup!
end
