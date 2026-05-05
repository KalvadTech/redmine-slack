# frozen_string_literal: true

module RedmineKalvadSlack
  module Patches
    module NewsPatch
      def self.prepended(base)
        base.class_eval do
          after_create_commit :send_kalvad_slack_create
        end
      end

      private

      def send_kalvad_slack_create
        setting = project&.kalvad_slack_setting
        return unless setting&.enabled?
        return unless setting.post_news?

        payload = RedmineKalvadSlack::PayloadBuilder.news_created(self)
        RedmineKalvadSlack::Notifier.deliver(setting: setting, payload: payload)
      end
    end
  end
end
