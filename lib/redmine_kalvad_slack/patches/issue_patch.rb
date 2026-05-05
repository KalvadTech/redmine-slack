# frozen_string_literal: true

module RedmineKalvadSlack
  module Patches
    module IssuePatch
      def self.prepended(base)
        base.class_eval do
          after_create_commit :send_kalvad_slack_create
          after_update_commit :send_kalvad_slack_update
        end
      end

      private

      def send_kalvad_slack_create
        return if project.nil?
        return unless RedmineKalvadSlack::SettingsResolver.bool?(project, :enabled)
        return unless RedmineKalvadSlack::SettingsResolver.bool?(project, :post_issue_created)
        return if is_private? && !RedmineKalvadSlack::SettingsResolver.bool?(project, :post_private_issues)

        payload = RedmineKalvadSlack::PayloadBuilder.issue_created(self)
        RedmineKalvadSlack::Notifier.deliver(project: project, payload: payload)
      end

      def send_kalvad_slack_update
        return unless kalvad_slack_should_post_update?

        payload = build_kalvad_slack_update_payload
        return if payload.nil?

        RedmineKalvadSlack::Notifier.deliver(project: project, payload: payload)
      end

      def kalvad_slack_should_post_update?
        return false if project.nil? || current_journal.nil?
        return false unless RedmineKalvadSlack::SettingsResolver.bool?(project, :enabled)
        return false if is_private? && !RedmineKalvadSlack::SettingsResolver.bool?(project, :post_private_issues)
        return false if current_journal.private_notes? &&
                        !RedmineKalvadSlack::SettingsResolver.bool?(project, :post_private_notes)

        true
      end

      def build_kalvad_slack_update_payload
        if kalvad_slack_status_closed_transition?
          return nil unless RedmineKalvadSlack::SettingsResolver.bool?(project, :post_issue_closed)

          return RedmineKalvadSlack::PayloadBuilder.issue_closed(self, current_journal)
        end

        return nil unless RedmineKalvadSlack::SettingsResolver.bool?(project, :post_issue_updated)

        RedmineKalvadSlack::PayloadBuilder.issue_updated(self, current_journal)
      end

      def kalvad_slack_status_closed_transition?
        detail = current_journal.details.find { |d| d.property == 'attr' && d.prop_key == 'status_id' }
        return false if detail.nil?

        new_status = IssueStatus.find_by(id: detail.value)
        new_status&.is_closed?
      end
    end
  end
end
