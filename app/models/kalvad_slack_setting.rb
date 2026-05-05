# frozen_string_literal: true

class KalvadSlackSetting < ApplicationRecord
  TRI_INHERIT = 0
  TRI_OFF     = 1
  TRI_ON      = 2

  TRI_VALUES = [TRI_INHERIT, TRI_OFF, TRI_ON].freeze

  TRI_FIELDS = %i[
    enabled
    post_issue_created
    post_issue_updated
    post_issue_closed
    post_wiki_created
    post_wiki_updated
    post_news
    post_private_issues
    post_private_notes
    display_watchers
    display_description_on_create
    auto_mentions
  ].freeze

  belongs_to :project

  validates :project_id, uniqueness: true
  validates :webhook_url,
            format: { with: %r{\Ahttps?://}i, allow_blank: true,
                      message: :kalvad_slack_invalid_webhook_url }
  validates(*TRI_FIELDS, inclusion: { in: TRI_VALUES })

  def self.for(project)
    find_or_initialize_by(project_id: project.id)
  end

  def inherited?(field)
    self[field].to_i == TRI_INHERIT
  end

  def tri_state(field)
    self[field].to_i
  end
end
