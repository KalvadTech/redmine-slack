# frozen_string_literal: true

require 'net/http'
require 'openssl'
require 'uri'
require 'json'

module RedmineKalvadSlack
  VERSION = '0.2.0'

  class << self
    def setup!
      Issue.prepend(Patches::IssuePatch) unless Issue.include?(Patches::IssuePatch)
      WikiPage.prepend(Patches::WikiPagePatch) unless WikiPage.include?(Patches::WikiPagePatch)
      News.prepend(Patches::NewsPatch) unless News.include?(Patches::NewsPatch)
      Project.prepend(Patches::ProjectPatch) unless Project.include?(Patches::ProjectPatch)
      return if ProjectsHelper.include?(Patches::ProjectsHelperPatch)

      ProjectsHelper.prepend(Patches::ProjectsHelperPatch)
    end
  end
end
