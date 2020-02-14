module Panoptes
  def self.project_request
    @project_request ||= OpenStruct
      .new(**begin
               file = Rails.root.join('config/project_request.yml')
               YAML.load(ERB.new(File.read(file).result))[Rails.env].symbolize_keys
             rescue Errno::ENOENT, NoMethodError
               { }
             end)
  end
end

Panoptes.project_request
