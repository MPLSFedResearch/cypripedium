# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BagJob, type: :job do
  let(:work_ids) { [1, 2] }
  let(:file_path) { Rails.application.config.bag_path }
  let(:user) { FactoryBot.create(:admin) }
  let(:request) { ActionDispatch::Request.new(host: 'http://localhost:3000') }

  context 'running the job' do
    it 'get queued' do
      ActiveJob::Base.queue_adapter = :test
      described_class.perform_later(work_ids: work_ids, user: user, request: request.as_json)
      expect(described_class).to have_been_enqueued
    end
  end
end
