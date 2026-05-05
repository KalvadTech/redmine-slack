# frozen_string_literal: true

module RedmineKalvadSlack
  module Patches
    module WikiPagePatch
      def self.prepended(base)
        base.class_eval do
          after_create_commit :send_kalvad_slack_create
          after_update_commit :send_kalvad_slack_update
        end
      end

      private

      def send_kalvad_slack_create
        deliver_kalvad_slack(:post_wiki_created?) do
          RedmineKalvadSlack::PayloadBuilder.wiki_created(self)
        end
      end

      def send_kalvad_slack_update
        deliver_kalvad_slack(:post_wiki_updated?) do
          RedmineKalvadSlack::PayloadBuilder.wiki_updated(self)
        end
      end

      def deliver_kalvad_slack(toggle)
        setting = project&.kalvad_slack_setting
        return unless setting&.enabled?
        return unless setting.public_send(toggle)

        RedmineKalvadSlack::Notifier.deliver(setting: setting, payload: yield)
      end
    end
  end
end
