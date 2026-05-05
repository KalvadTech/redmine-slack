# frozen_string_literal: true

require File.expand_path('../../../test/test_helper', __dir__)

module RedmineKalvadSlack
  class TestCase < ActiveSupport::TestCase
    self.fixture_path = File.expand_path('fixtures', __dir__)
  end
end
