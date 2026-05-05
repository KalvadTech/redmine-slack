# frozen_string_literal: true

require_relative '../test_helper'

class KalvadSlackSettingsControllerTest < Redmine::ControllerTest
  tests KalvadSlackSettingsController
  fixtures :projects, :users, :members, :member_roles, :roles, :enabled_modules

  def setup
    @project = Project.find(1)
    Role.find(1).add_permission!(:manage_kalvad_slack)
  end

  def test_anonymous_redirects
    put :update, params: { project_id: @project.id, kalvad_slack_setting: { webhook_url: 'https://x' } }
    assert_response :redirect
  end

  def test_unauthorized_member_forbidden
    Role.find(1).remove_permission!(:manage_kalvad_slack)
    @request.session[:user_id] = 2
    put :update, params: { project_id: @project.id, kalvad_slack_setting: { webhook_url: 'https://x' } }
    assert_response :forbidden
  end

  def test_authorized_update_creates_row
    @request.session[:user_id] = 2
    put :update, params: { project_id: @project.id,
                           kalvad_slack_setting: {
                             webhook_url: 'https://hooks.slack.test/abc',
                             channel: '#redmine-test'
                           } }
    assert_redirected_to settings_project_path(@project, tab: 'kalvad_slack')
    setting = KalvadSlackSetting.find_by(project_id: @project.id)
    assert_equal 'https://hooks.slack.test/abc', setting.webhook_url
    assert_equal '#redmine-test', setting.channel
  end
end
