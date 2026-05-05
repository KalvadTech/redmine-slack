# frozen_string_literal: true

require_relative '../test_helper'

class KalvadSlackSettingsResolverTest < RedmineKalvadSlack::TestCase
  fixtures :projects

  def setup
    Setting.send('plugin_redmine_kalvad_slack=',
                 'webhook_url' => 'https://global.test/x',
                 'channel' => '#global',
                 'username' => 'Redmine',
                 'enabled' => '1',
                 'post_issue_created' => '1',
                 'post_issue_updated' => '1',
                 'post_issue_closed' => '1',
                 'post_wiki_created' => '1',
                 'post_wiki_updated' => '0',
                 'post_news' => '1',
                 'post_private_issues' => '0',
                 'post_private_notes' => '0',
                 'display_watchers' => '0',
                 'display_description_on_create' => '1',
                 'auto_mentions' => '1',
                 'verify_ssl' => '1',
                 'connect_timeout' => '3',
                 'read_timeout' => '3')
    @project = Project.find(1)
    KalvadSlackSetting.where(project_id: @project.id).destroy_all
  end

  def test_global_webhook_url_when_no_override
    assert_equal 'https://global.test/x', KalvadSlack::SettingsResolver.webhook_url(@project)
  end

  def test_project_overrides_webhook_url
    KalvadSlackSetting.create!(project_id: @project.id, webhook_url: 'https://proj.test/y')
    assert_equal 'https://proj.test/y', KalvadSlack::SettingsResolver.webhook_url(@project)
  end

  def test_channel_dash_passes_through
    KalvadSlackSetting.create!(project_id: @project.id, channel: '-')
    assert_equal '-', KalvadSlack::SettingsResolver.channel(@project)
  end

  def test_tri_state_force_off_overrides_global_true
    KalvadSlackSetting.create!(project_id: @project.id, post_issue_created: KalvadSlackSetting::TRI_OFF)
    assert_not KalvadSlack::SettingsResolver.bool?(@project, :post_issue_created)
  end

  def test_tri_state_force_on_overrides_global_false
    KalvadSlackSetting.create!(project_id: @project.id, post_wiki_updated: KalvadSlackSetting::TRI_ON)
    assert KalvadSlack::SettingsResolver.bool?(@project, :post_wiki_updated)
  end

  def test_inherit_falls_through_to_parent
    parent = Project.create!(name: 'parent_test', identifier: 'parent-test')
    child = Project.create!(name: 'child_test', identifier: 'child-test', parent_id: parent.id)
    KalvadSlackSetting.create!(project_id: parent.id, post_news: KalvadSlackSetting::TRI_OFF)
    assert_not KalvadSlack::SettingsResolver.bool?(child, :post_news)
  end
end
