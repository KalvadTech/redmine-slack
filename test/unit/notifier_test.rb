# frozen_string_literal: true

require_relative '../test_helper'

class KalvadSlackNotifierTest < RedmineKalvadSlack::TestCase
  fixtures :projects

  def setup
    Setting.send('plugin_redmine_kalvad_slack=',
                 'webhook_url' => 'https://hooks.slack.test/T/B/X',
                 'channel' => '#redmine',
                 'username' => 'Redmine',
                 'icon' => '',
                 'enabled' => '1',
                 'verify_ssl' => '1',
                 'connect_timeout' => '3',
                 'read_timeout' => '3')
    @project = Project.find(1)
    KalvadSlackSetting.where(project_id: @project.id).destroy_all
  end

  def test_does_nothing_when_disabled
    Setting.send('plugin_redmine_kalvad_slack=',
                 Setting.send('plugin_redmine_kalvad_slack').merge('enabled' => '0'))
    Net::HTTP.stub :new, ->(*) { raise 'must not be called' } do
      RedmineKalvadSlack::Notifier.deliver(project: @project, payload: { text: 'x' })
    end
  end

  def test_does_nothing_when_channel_is_dash
    KalvadSlackSetting.create!(project_id: @project.id, channel: '-')
    Net::HTTP.stub :new, ->(*) { raise 'must not be called' } do
      RedmineKalvadSlack::Notifier.deliver(project: @project, payload: { text: 'x' })
    end
  end

  def test_swallows_exceptions_and_logs
    fake_http = Object.new
    def fake_http.use_ssl=(_); end
    def fake_http.verify_mode=(_); end
    def fake_http.open_timeout=(_); end
    def fake_http.read_timeout=(_); end
    def fake_http.request(_) = raise(SocketError, 'boom')

    Net::HTTP.stub :new, fake_http do
      assert_nothing_raised do
        RedmineKalvadSlack::Notifier.deliver(project: @project, payload: { text: 'x' })
      end
    end
  end
end
