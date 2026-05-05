# frozen_string_literal: true

require_relative '../test_helper'

class KalvadSlackNotifierTest < RedmineKalvadSlack::TestCase
  fixtures :projects

  def setup
    @setting = KalvadSlackSetting.new(
      project_id: Project.find(1).id,
      webhook_url: 'https://hooks.slack.test/T/B/X',
      channel: '#redmine',
      username: 'Redmine',
      enabled: true
    )
  end

  def test_does_nothing_when_setting_is_nil
    Net::HTTP.stub :new, ->(*) { raise 'must not be called' } do
      RedmineKalvadSlack::Notifier.deliver(setting: nil, payload: { text: 'x' })
    end
  end

  def test_does_nothing_when_disabled
    @setting.enabled = false
    Net::HTTP.stub :new, ->(*) { raise 'must not be called' } do
      RedmineKalvadSlack::Notifier.deliver(setting: @setting, payload: { text: 'x' })
    end
  end

  def test_does_nothing_when_channel_is_dash
    @setting.channel = '-'
    Net::HTTP.stub :new, ->(*) { raise 'must not be called' } do
      RedmineKalvadSlack::Notifier.deliver(setting: @setting, payload: { text: 'x' })
    end
  end

  def test_swallows_exceptions_and_logs
    fake_http = Object.new
    def fake_http.use_ssl=(_); end
    def fake_http.open_timeout=(_); end
    def fake_http.read_timeout=(_); end
    def fake_http.request(_) = raise(SocketError, 'boom')

    Net::HTTP.stub :new, fake_http do
      assert_nothing_raised do
        RedmineKalvadSlack::Notifier.deliver(setting: @setting, payload: { text: 'x' })
      end
    end
  end
end
