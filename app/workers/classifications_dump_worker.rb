require 'csv'

class ClassificationsDumpWorker
  include Sidekiq::Worker
  include RateLimitDumpWorker

  sidekiq_options queue: :data_high

  attr_reader :resource, :medium, :scope, :processor

  def perform(resource_id, resource_type, medium_id=nil, requester_id=nil, *args)
    raise ApiErrors::FeatureDisabled unless Panoptes.flipper[:dump_worker_exports].enabled?

    if @resource = CsvDumps::FindsDumpResource.find(resource_type, resource_id)
      @medium = CsvDumps::FindsMedium.new(medium_id, @resource, dump_target).medium
      scope = get_scope(resource)
  # run this one first
  @processor = CsvDumps::DumpProcessor.new(formatter, scope, medium)

  # add a feature flag to switch this behaviour on/off at run time (Code experiment? example for tracking data?)

      # @processor = CsvDumps::CachingDumpProcessor.new(formatter, scope, medium) do |formatter|
      #   # if no pre-formatted cached resource then create a one for re-use in future exports
      #   unless formatter.cache_resource
      #     # dump scopes are wrapped in a read replica block by default
      #     # ensure these writes goto the primary db
      #     Standby.on_primary do
      #       classification = formatter.model
      #       cached_export = CachedExport.create!(
      #         resource: classification,
      #         data: ClassificationExport.hash_format(formatter)
      #       )
      #       # link the newly saved classification export to the classification for re-use
      #       classification.update_column(:cached_export_id, cached_export.id) # rubocop:disable Rails/SkipsModelValidations
      #     end
      #   end
      # end

      @processor.execute

      DumpMailer.new(resource, medium, dump_target).send_email
    end
  end

  def formatter
    @formatter ||= Formatter::Csv::Classification.new(cache)
  end

  def get_scope(resource)
    @scope ||= CsvDumps::ClassificationScope.new(resource, cache)
  end

  def cache
    @cache ||= ClassificationDumpCache.new
  end

  def dump_target
    "classifications"
  end
end
