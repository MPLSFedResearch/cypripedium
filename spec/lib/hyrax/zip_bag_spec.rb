# frozen_string_literal: true

require 'rails_helper'
require 'fileutils'

RSpec.describe Hyrax::ZipBag, type: :model do
  subject(:work_bag) { described_class.new(work_ids: [publication.id, publication2.id], time_stamp: time_stamp) }
  let(:time_stamp) { 109_092 }
  let(:file_path) { Rails.application.config.bag_path }

  let(:pdf_file) do
    File.open(file_fixture('pdf-sample.pdf')) { |file| create(:file_set, content: file) }
  end

  let(:image_file) do
    File.open(file_fixture('sir_mordred.jpg')) { |file| create(:file_set, content: file) }
  end

  let(:publication) do
    create(:publication, title: ['My Publication'], file_sets: [pdf_file, image_file])
  end

  let(:publication2) do
    create(:publication, title: ['My Publication 2'], file_sets: [pdf_file, image_file])
  end

  describe '#work_count' do
    after do
      FileUtils.rm_rf(file_path)
    end

    it 'can return the number of works in the bag' do
      work_bag.create
      expect(work_bag.work_count).to eq(2)
    end
  end

  describe '#create' do
    after do
      FileUtils.rm_rf(file_path)
    end

    context 'a work with attached files' do
      it 'creates a bag from the works' do
        work_bag.create
        expect(File.exist?("#{work_bag.bag_path}.zip"))
      end
    end
  end
end
