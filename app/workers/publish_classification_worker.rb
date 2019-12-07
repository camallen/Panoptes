class PublishClassificationWorker
  include Sidekiq::Worker

  sidekiq_options queue: :data_high

  attr_reader :classification

  def perform(classification_id)
    return

    @classification = Classification.find(classification_id)
    if classification.complete?
      publish_to_kinesis!
    end
  rescue ActiveRecord::RecordNotFound
  end

  private

  def serialized_classification
    @serialized_classification ||= EventStreamSerializers::ClassificationSerializer
      .serialize(classification, include: ['project', 'workflow', 'user', 'subjects'])
      .as_json
      .with_indifferent_access
  end

  def publish_to_kinesis!
    ## REMOVED CALL TO KINESIS STREAM PUBLISH
  end

  def kinesis_data
    serialized_classification[:classifications][0]
  end

  def kinesis_linked
    serialized_classification[:linked]
  end
end
