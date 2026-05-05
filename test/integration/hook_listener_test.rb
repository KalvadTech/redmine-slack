# frozen_string_literal: true

require_relative '../test_helper'

class KalvadSlackHookListenerTest < Redmine::IntegrationTest
  fixtures :projects, :users, :members, :member_roles, :roles,
           :issues, :issue_statuses, :trackers, :enumerations,
           :enabled_modules, :journals, :journal_details

  def setup
    Setting.send('plugin_redmine_kalvad_slack=',
                 'webhook_url' => 'https://hooks.slack.test/x',
                 'channel' => '#redmine',
                 'username' => 'Redmine',
                 'enabled' => '1',
                 'post_issue_created' => '1',
                 'post_issue_updated' => '1',
                 'post_issue_closed' => '1',
                 'verify_ssl' => '1',
                 'connect_timeout' => '3',
                 'read_timeout' => '3')
    @calls = []
    RedmineKalvadSlack::Notifier.singleton_class.alias_method :__orig_deliver, :deliver
    RedmineKalvadSlack::Notifier.singleton_class.send(:define_method, :deliver) do |project:, payload:|
      @calls << [project, payload]
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
