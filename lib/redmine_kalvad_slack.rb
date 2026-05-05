# frozen_string_literal: true

require 'net/http'
require 'openssl'
require 'uri'
require 'json'

module RedmineKalvadSlack
  VERSION = '0.1.0'

  DEFAULT_SETTINGS = {
    'webhook_url' => '',
    'channel' => '',
    'username' => 'Redmine',
    'icon' => '',
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
    'mention_keywords' => '',
    'slack_member_id_custom_field_id' => '',
    'verify_ssl' => '1',
    'connect_timeout' => '3',
    'read_timeout' => '3'
  }.freeze

  class << self
    def setup!
      Issue.prepend(Patches::IssuePatch) unless Issue.include?(Patches::IssuePatch)
      WikiPage.prepend(Patches::WikiPagePatch) unless WikiPage.include?(Patches::WikiPagePatch)
      News.prepend(Patches::NewsPatch) unless News.include?(Patches::NewsPatch)
      Project.prepend(Patches::ProjectPatch) unless Project.include?(Patches::ProjectPatch)
      return if ProjectsHelper.include?(Patches::ProjectsHelperPatch)

      ProjectsHelper.prepend(Patches::ProjectsHelperPatch)
    end
  end
end
