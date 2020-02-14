module Panoptes
  module StorageAdapter
    def self.configuration
      return @configuration if @configuration
      begin
        file = Rails.root.join('config/storage.yml')
        @configuration = YAML.load(ERB.new(File.read(file)).result)[Rails.env].symbolize_keys
        @configuration.freeze
      rescue Errno::ENOENT, NoMethodError
        {adapter: "default"}
      end
    end
  end
end

config = Panoptes::StorageAdapter.configuration
MediaStorage.adapter(config[:adapter], **config.except(:adapter))
