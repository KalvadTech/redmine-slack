# frozen_string_literal: true

require_relative '../test_helper'

class KalvadSlackRoutingTest < Redmine::RoutingTest
  def test_update_route
    assert_routing(
      { method: 'put', path: '/projects/foo/kalvad_slack_setting' },
      controller: 'kalvad_slack_settings', action: 'update', project_id: 'foo'
    )
  end
end
