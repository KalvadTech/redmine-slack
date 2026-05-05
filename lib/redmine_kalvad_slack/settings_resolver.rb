# frozen_string_literal: true

module RedmineKalvadSlack
  module SettingsResolver
    PLUGIN_ID = 'redmine_kalvad_slack'

    BOOL_FIELDS = KalvadSlackSetting::TRI_FIELDS

    module_function

    def webhook_url(project)
      cascade_string(project, :webhook_url)
    end

    def channel(project)
      cascade_string(project, :channel)
    end

    def username(_project)
      global(:username).presence || 'Redmine'
    end

    def icon(_project)
      global(:icon).to_s
    end

    def bool?(project, field)
      raise ArgumentError, "Unknown bool field #{field}" unless BOOL_FIELDS.include?(field.to_sym)

      cascade_bool?(project, field.to_sym)
    end

    def string(project, field)
      cascade_string(project, field.to_sym)
    end

    def global(key)
      values = Setting.send("plugin_#{PLUGIN_ID}") || {}
      values[key.to_s]
    end

    def global_bool?(key)
      truthy?(global(key))
    end

    def global_int(key, default)
      val = global(key).to_s
      val.match?(/\A\d+\z/) ? val.to_i : default
    end

    def cascade_string(project, field)
      walk_projects(project) do |setting|
        value = setting&.public_send(field)
        return value if value.present?
      end
      global(field).to_s
    end

    def cascade_bool?(project, field)
      walk_projects(project) do |setting|
        next if setting.nil?

        case setting.tri_state(field)
        when KalvadSlackSetting::TRI_ON  then return true
        when KalvadSlackSetting::TRI_OFF then return false
        end
      end
      global_bool?(field)
    end

    def walk_projects(project)
      return if project.nil?

      current = project
      while current
        yield current.kalvad_slack_setting
        current = current.parent
      end
    end

    def truthy?(value)
      ['1', 1, true, 'true', 'yes'].include?(value)
    end
  end
end
