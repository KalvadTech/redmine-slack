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
      :webhook_url, :channel, :username, :icon,
      *KalvadSlackSetting::BOOL_FIELDS
    )
  end
end
