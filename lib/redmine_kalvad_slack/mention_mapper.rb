# frozen_string_literal: true

module RedmineKalvadSlack
  module MentionMapper
    LOGIN_RE = /(?<![A-Za-z0-9_])@([A-Za-z0-9][A-Za-z0-9._-]*)/

    module_function

    def transform(text, project)
      return text if text.blank?
      return text unless SettingsResolver.bool?(project, :auto_mentions)

      cf_id = SettingsResolver.global(:slack_member_id_custom_field_id).to_i
      return text if cf_id.zero?

      text.gsub(LOGIN_RE) do
        login = Regexp.last_match(1)
        slack_id = lookup_slack_id(login, cf_id)
        slack_id.present? ? "<@#{slack_id}>" : "@#{login}"
      end
    end

    def keyword_hits(text, project)
      raw = SettingsResolver.string(project, :mention_keywords).to_s
      return [] if raw.blank?

      raw.split(',').map(&:strip).reject(&:blank?).select { |kw| text.to_s.include?(kw) }
    end

    def lookup_slack_id(login, cf_id)
      user = User.active.find_by(login: login)
      return nil unless user

      user.custom_field_value(cf_id).presence
    end
  end
end
