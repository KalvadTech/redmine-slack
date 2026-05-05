# frozen_string_literal: true

Rails.application.routes.draw do
  resources :projects, only: [] do
    resource :kalvad_slack_setting,
             only: %i[update],
             controller: 'kalvad_slack_settings'
  end
end
