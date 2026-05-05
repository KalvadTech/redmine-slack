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
                                     webhook_url: 'https://hooks.slack.com/services/x')
    assert setting.valid?
  end

  def test_rejects_non_http_webhook_url
    setting = KalvadSlackSetting.new(project_id: Project.first.id,
                                     webhook_url: 'ftp://example.com')
    assert_not setting.valid?
    assert_includes setting.errors[:webhook_url].first.to_s,
                    I18n.t('activerecord.errors.messages.kalvad_slack_invalid_webhook_url')
  end

  def test_for_returns_existing_or_new
    project = Project.find(1)
    s = KalvadSlackSetting.for(project)
    assert_kind_of KalvadSlackSetting, s
    assert_equal project.id, s.project_id
  end

  def test_inherited_predicate
    s = KalvadSlackSetting.new
    assert s.inherited?(:enabled)
    s.enabled = KalvadSlackSetting::TRI_ON
    assert_not s.inherited?(:enabled)
  end
end
