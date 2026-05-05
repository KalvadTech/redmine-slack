# frozen_string_literal: true

require_relative '../test_helper'

class KalvadSlackSettingTest < RedmineKalvadSlack::TestCase
  fixtures :projects

  def test_accepts_blank_webhook_url
    setting = KalvadSlackSetting.new(project_id: Project.first.id, webhook_url: '')
    assert setting.valid?
  end

  def test_accepts_https_webhook_url
    setting = KalvadSlackSetting.new(project_id: Project.first.id,
                                     webhook_url: 'https://hooks.slack.com/services/x',
                                     channel: '#x')
    assert setting.valid?
  end

  def test_rejects_non_http_webhook_url
    setting = KalvadSlackSetting.new(project_id: Project.first.id,
                                     webhook_url: 'ftp://example.com')
    assert_not setting.valid?
  end

  def test_for_returns_existing_or_new
    project = Project.find(1)
    s = KalvadSlackSetting.for(project)
    assert_kind_of KalvadSlackSetting, s
    assert_equal project.id, s.project_id
  end

  def test_deliverable_requires_enabled_url_and_channel
    s = KalvadSlackSetting.new(enabled: true, webhook_url: 'https://x', channel: '#a')
    assert s.deliverable?

    s.enabled = false
    assert_not s.deliverable?

    s.enabled = true
    s.channel = ''
    assert_not s.deliverable?

    s.channel = '-'
    assert_not s.deliverable?

    s.channel = '#a'
    s.webhook_url = ''
    assert_not s.deliverable?
  end
end
