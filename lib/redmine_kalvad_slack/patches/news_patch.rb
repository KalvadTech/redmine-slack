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
        return if project.nil?
        return unless RedmineKalvadSlack::SettingsResolver.bool?(project, :enabled)
        return unless RedmineKalvadSlack::SettingsResolver.bool?(project, :post_news)

        RedmineKalvadSlack::Notifier.deliver(project: project,
                                             payload: RedmineKalvadSlack::PayloadBuilder.news_created(self))
      end
    end
  end
end
