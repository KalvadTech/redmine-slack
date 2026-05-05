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
        kalvad_slack_dispatch(:post_wiki_created) do
          KalvadSlack::PayloadBuilder.wiki_created(self)
        end
      end

      def send_kalvad_slack_update
        kalvad_slack_dispatch(:post_wiki_updated) do
          KalvadSlack::PayloadBuilder.wiki_updated(self)
        end
      end

      def kalvad_slack_dispatch(toggle)
        return if project.nil?
        return unless KalvadSlack::SettingsResolver.bool?(project, :enabled)
        return unless KalvadSlack::SettingsResolver.bool?(project, toggle)

        KalvadSlack::Notifier.deliver(project: project, payload: yield)
      end
    end
  end
end
