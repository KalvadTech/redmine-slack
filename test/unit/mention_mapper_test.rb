# frozen_string_literal: true

require_relative '../test_helper'

class KalvadSlackMentionMapperTest < RedmineKalvadSlack::TestCase
  fixtures :projects, :users, :custom_fields, :custom_values, :roles, :members, :member_roles

  def setup
    @project = Project.find(1)
    @cf = UserCustomField.create!(name: 'Slack Member ID', field_format: 'string')
    @user = User.find(2)
    CustomValue.create!(custom_field_id: @cf.id, customized_type: 'Principal',
                        customized_id: @user.id, value: 'U999ABC')
    Setting.send('plugin_redmine_kalvad_slack=',
                 'auto_mentions' => '1',
                 'mention_keywords' => '@channel, urgent',
                 'slack_member_id_custom_field_id' => @cf.id.to_s)
  end

  def test_transforms_known_login
    out = RedmineKalvadSlack::MentionMapper.transform("hello @#{@user.login} bye", @project)
    assert_includes out, '<@U999ABC>'
  end

  def test_keeps_unknown_login
    out = RedmineKalvadSlack::MentionMapper.transform('hello @ghost', @project)
    assert_includes out, '@ghost'
    refute_includes out, '<@'
  end

  def test_skips_when_disabled
    Setting.send('plugin_redmine_kalvad_slack=',
                 Setting.send('plugin_redmine_kalvad_slack').merge('auto_mentions' => '0'))
    out = RedmineKalvadSlack::MentionMapper.transform("hi @#{@user.login}", @project)
    assert_includes out, "@#{@user.login}"
  end

  def test_keyword_hits
    hits = RedmineKalvadSlack::MentionMapper.keyword_hits('this is urgent and @channel here', @project)
    assert_includes hits, 'urgent'
    assert_includes hits, '@channel'
  end
end
