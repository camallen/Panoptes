module CsvDumps
  class ClassificationScope < DumpScope
    attr_reader :cache

    def initialize(resource, cache)
      super(resource)
      @cache = cache
    end

    def each
      read_from_database do
        completed_resource_classifications.find_in_batches do |batch|
          subject_ids = setup_subjects_cache(batch)
          setup_retirement_cache(batch, subject_ids)
          results = []
          batch.each do |classification|
            results << yield classification
          end
          cached_exports = results.map do |formatter|
            CachedExport.new(resource: formatter.model, data: ClassificationExport.hash_format(formatter))
          end
          next unless cached_exports.empty?

          # ensure we import to the primary DB
          Standby.on_primary do
            # bulk import the cached exports
            import_results = CachedExport.import(cached_exports, returning: :resource_id, validate: false)

            # https://github.com/zdennis/activerecord-import/#return-info
            # ensure the order of the import results matches the id of the cached export
            classification_upserts = []
            import_results.each_with_index do |cached_export_id, index|
              classification_upserts << {
                id: import_results.results[index],
                cached_export_id: cached_export_id
              }
            end
            # bulk import the classification FK to formatted cached_export resource
            Classification.import classification_upserts, on_duplicate_key_update: [:cached_export_id]
          end
        end
      end
    end

    private

    def setup_subjects_cache(classifications)
      classification_ids = classifications.map(&:id).join(",")
      sql = "SELECT classification_id, subject_id FROM classification_subjects where classification_id IN (#{classification_ids})"
      c_s_ids = ActiveRecord::Base.connection.select_rows(sql)
      cache.reset_classification_subjects(c_s_ids)
      subject_ids = c_s_ids.map { |_, subject_id| subject_id }
      cache.reset_subjects(Subject.where(id: subject_ids).load)
      subject_ids
    end

    def completed_resource_classifications
      resource.classifications
        .complete
        .joins(:workflow).where(workflows: {activated_state: "active"})
        .includes(:user, :workflow, :cached_export)
    end

    def setup_retirement_cache(classifications, subject_ids)
      workflow_ids = classifications.map(&:workflow_id).uniq
      retired_counts = SubjectWorkflowStatus.retired.where(
        subject_id: subject_ids,
        workflow_id: workflow_ids
      ).load
      cache.reset_subject_workflow_statuses(retired_counts)
    end
  end
end
