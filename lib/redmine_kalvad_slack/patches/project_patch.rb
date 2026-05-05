# frozen_string_literal: true

module RedmineKalvadSlack
  module Patches
    module ProjectPatch
      def self.prepended(base)
        base.class_eval do
          has_one :kalvad_slack_setting, dependent: :destroy
        end
      end
    end
  end
end
