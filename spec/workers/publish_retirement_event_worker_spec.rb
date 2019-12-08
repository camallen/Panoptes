require 'spec_helper'

RSpec.describe PublishRetirementEventWorker do
  let(:worker) { described_class.new }
  let(:workflow) { create(:workflow) }
  let(:payload_expectation) do
    a_hash_including(
      project_id: workflow.project_id,
      project_name: workflow.project.display_name,
      workflow_id: workflow.id,
      workflow_name: workflow.display_name,
      subjects_count: workflow.subjects_count,
      retired_subjects_count: workflow.retired_subjects_count,
      classifications_count: workflow.classifications_count
    )
  end

  describe "#perform", :disabled do
    it "should gracefully handle a missing workflow lookup" do
      expect{
        worker.perform(-1)
      }.not_to raise_error
    end

    it "should publish via Kinesis" do
      expect(ZooStream).to receive(:publish)
        .with(event: "workflow_counters", shard_by: workflow.id, data: payload_expectation)
      worker.perform(workflow.id)
    end
  end
end
