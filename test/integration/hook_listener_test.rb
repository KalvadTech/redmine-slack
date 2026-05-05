# frozen_string_literal: true

require_relative '../test_helper'

class KalvadSlackHookListenerTest < Redmine::IntegrationTest
  fixtures :projects, :users, :members, :member_roles, :roles,
           :issues, :issue_statuses, :trackers, :enumerations,
           :enabled_modules, :journals, :journal_details

  def setup
    KalvadSlackSetting.where(project_id: 1).destroy_all
    KalvadSlackSetting.create!(
      project_id: 1,
      webhook_url: 'https://hooks.slack.test/x',
      channel: '#redmine',
      enabled: true,
      post_issue_created: true,
      post_issue_updated: true,
      post_issue_closed: true
    )
    @calls = []
    RedmineKalvadSlack::Notifier.singleton_class.alias_method :__orig_deliver, :deliver
    RedmineKalvadSlack::Notifier.singleton_class.send(:define_method, :deliver) do |setting:, payload:|
      @calls << [setting, payload]
    end
    RedmineKalvadSlack::Notifier.instance_variable_set(:@calls, @calls)
  end

  def teardown
    RedmineKalvadSlack::Notifier.singleton_class.alias_method :deliver, :__orig_deliver
  end

  def test_issue_create_triggers_notifier
    issue = Issue.new(project_id: 1, tracker_id: 1, status_id: 1, priority_id: 5,
                      author_id: 2, subject: 'Hook test', description: 'd')
    assert issue.save
    assert_operator RedmineKalvadSlack::Notifier.instance_variable_get(:@calls).size, :>=, 1
  end
end
