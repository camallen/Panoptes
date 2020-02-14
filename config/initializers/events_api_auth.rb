module Panoptes
  module EventsApi
    def self.auth
      @events_api_auth ||= begin
                         file = Rails.root.join('config/events_api_auth.yml')
                         YAML.load(ERB.new(File.read(file)).result)[Rails.env].symbolize_keys
                       rescue Errno::ENOENT, NoMethodError
                         {  }
                       end
    end

    def self.username
      auth[:username]
    end

    def self.password
      auth[:password]
    end
  end
end

Panoptes::EventsApi.auth
