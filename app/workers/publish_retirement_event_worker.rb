class PublishRetirementEventWorker
  include Sidekiq::Worker

  sidekiq_options queue: :data_high

  def perform(workflow_id)
    return

    workflow = Workflow.includes(:project).find(workflow_id)
    counters = {
      project_id: workflow.project_id,
      project_name: workflow.project.display_name,
      workflow_id: workflow.id,
      workflow_name: workflow.display_name,
      subjects_count: workflow.subjects_count,
      retired_subjects_count: workflow.retired_subjects_count,
      classifications_count: workflow.classifications_count
    }

    ## REMOVED CALL TO KINESIS STREAM PUBLISH
  rescue ActiveRecord::RecordNotFound
  end
end
