# frozen_string_literal: true

module RedmineKalvadSlack
  module Patches
    module ProjectsHelperPatch
      def project_settings_tabs
        tabs = super
        return tabs unless @project
        return tabs unless User.current.allowed_to?(:manage_kalvad_slack, @project)

        tabs << {
          name: 'kalvad_slack',
          action: :manage_kalvad_slack,
          partial: 'kalvad_slack_settings/show',
          label: :label_kalvad_slack
        }
        tabs
      end
    end
  end
end
