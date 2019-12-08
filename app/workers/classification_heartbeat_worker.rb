class ClassificationHeartbeatWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  sidekiq_options queue: :data_medium

  recurrence { hourly.minute_of_hour(0, 15, 30, 45) }

  def perform
    if heartbeat_check? && missing_classifications?
      ClassificationHeartbeatMailer.missing_classifications(emails, window_period).deliver
      ## REMOVED HB CALL
    end
  end

  private

  def missing_classifications?
    latest_receipt = Classification.last.created_at
    (DateTime.now.utc.to_i - latest_receipt.utc.to_i) > window_period
  end

  def window_period
    Panoptes::ClassificationHeartbeat.window_period
  end

  def emails
    Panoptes::ClassificationHeartbeat.emails
  end

  def heartbeat_check?
    return false
    # Rails.env.production?
  end
end
