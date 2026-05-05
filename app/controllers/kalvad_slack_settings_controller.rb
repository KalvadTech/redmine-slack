# frozen_string_literal: true

class KalvadSlackSettingsController < ApplicationController
  before_action :find_project_by_project_id
  before_action :authorize

  def update
    setting = KalvadSlackSetting.for(@project)
    if setting.update(allowed_params)
      flash[:notice] = l(:notice_successful_update)
    else
      flash[:error] = setting.errors.full_messages.join("\n")
    end
    redirect_to settings_project_path(@project, tab: 'kalvad_slack')
  end

  private

  def allowed_params
    params.require(:kalvad_slack_setting).permit(
      :webhook_url, :channel, :enabled, :mention_keywords,
      :post_issue_created, :post_issue_updated, :post_issue_closed,
      :post_wiki_created, :post_wiki_updated, :post_news,
      :post_private_issues, :post_private_notes,
      :display_watchers, :display_description_on_create,
      :auto_mentions
    )
  end
end
