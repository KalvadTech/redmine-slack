# frozen_string_literal: true

module KalvadSlack
  class Notifier
    SUCCESS_CLASSES = [Net::HTTPSuccess, Net::HTTPRedirection].freeze
    DEFAULT_TIMEOUT = 3

    def self.deliver(project:, payload:)
      new(project, payload).deliver
    end

    def initialize(project, payload)
      @project = project
      @payload = payload
    end

    def deliver
      return unless @project
      return unless SettingsResolver.bool?(@project, :enabled)

      url = SettingsResolver.webhook_url(@project)
      ch  = SettingsResolver.channel(@project)
      return if url.blank? || ch.blank? || ch == '-'

      post(url, build_body(ch))
    end

    private

    def build_body(channel)
      body = @payload.merge(
        channel: channel,
        username: SettingsResolver.username(@project),
        link_names: 1
      )
      icon = SettingsResolver.icon(@project)
      if icon.present?
        if icon.start_with?(':')
          body[:icon_emoji] = icon
        elsif icon.start_with?('http')
          body[:icon_url] = icon
        end
      end
      body
    end

    def post(url, body)
      uri = URI.parse(url)
      http = build_http(uri)
      req = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
      req.body = body.to_json
      response = http.request(req)
      return if SUCCESS_CLASSES.any? { |klass| response.is_a?(klass) }

      Rails.logger.warn(
        "[redmine_kalvad_slack] non-2xx from Slack: #{response.code} #{response.body.to_s[0, 200]}"
      )
    rescue StandardError => e
      Rails.logger.warn("[redmine_kalvad_slack] delivery failed: #{e.class}: #{e.message}")
    end

    def build_http(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE unless SettingsResolver.global_bool?(:verify_ssl)
      http.open_timeout = SettingsResolver.global_int(:connect_timeout, DEFAULT_TIMEOUT)
      http.read_timeout = SettingsResolver.global_int(:read_timeout, DEFAULT_TIMEOUT)
      http
    end
  end
end
