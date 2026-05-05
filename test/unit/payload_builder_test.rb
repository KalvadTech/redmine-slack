# frozen_string_literal: true

require_relative '../test_helper'

class KalvadSlackPayloadBuilderTest < RedmineKalvadSlack::TestCase
  fixtures :projects, :users, :issues, :issue_statuses, :trackers, :enumerations,
           :members, :member_roles, :roles, :journals, :journal_details

  def setup
    Setting.host_name = 'redmine.test'
    Setting.protocol = 'https'
    @setting = KalvadSlackSetting.new(
      project_id: 1,
      webhook_url: 'https://x',
      channel: '#x',
      enabled: true,
      display_description_on_create: true,
      display_watchers: false,
      post_private_notes: false
    )
  end

  def test_issue_created_shape
    issue = Issue.find(1)
    payload = RedmineKalvadSlack::PayloadBuilder.issue_created(issue, @setting)
    assert_kind_of Hash, payload
    assert payload[:text].include?("##{issue.id}")
    att = payload[:attachments].first
    assert_equal RedmineKalvadSlack::Color::CREATED, att[:color]
    assert att[:title].include?(issue.subject)
    assert_equal "https://redmine.test/issues/#{issue.id}", att[:title_link]
    titles = att[:fields].map { |f| f[:title] }
    assert_includes titles, I18n.t(:field_tracker)
    assert_includes titles, I18n.t(:field_status)
  end

  def test_issue_closed_uses_closed_color
    issue = Issue.find(1)
    journal = issue.journals.first || Journal.create!(journalized: issue, user: User.find(1))
    payload = RedmineKalvadSlack::PayloadBuilder.issue_closed(issue, journal, @setting)
    assert_equal RedmineKalvadSlack::Color::CLOSED, payload[:attachments].first[:color]
  end

  def test_news_payload
    project = Project.find(1)
    news = News.create!(project: project, author: User.find(2),
                        title: 'Hello', summary: 'world', description: '<3')
    payload = RedmineKalvadSlack::PayloadBuilder.news_created(news)
    att = payload[:attachments].first
    assert_equal RedmineKalvadSlack::Color::NEWS, att[:color]
    assert_equal news.title, att[:title]
  end

  def test_escape_handles_brackets
    assert_equal '&lt;a&gt; &amp; &lt;b&gt;', RedmineKalvadSlack::PayloadBuilder.escape('<a> & <b>')
  end
end
