# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contentdm::ProblemRecord do
  let(:collection_name) { 'Test Collection' }
  let(:file) { Tempfile.create(['problem', '.xml'], nil) }
  let(:problem_record) { described_class.new(collection_name, file) }
  let(:record_xml) { Nokogiri::XML(file_fixture('some_records.xml')).xpath('//record')[2] }
  describe '#add_record' do
    it 'adds a record to the xml document' do
      problem_record.doc = Nokogiri::XML('<foo></foo>')
      problem_record.add_record(record_xml)
      expect(problem_record.doc.xpath('//record').length).to eq(1)
    end
  end
  describe '#save_xml' do
    it 'saves the xml to a file' do
      problem_record.doc = Nokogiri::XML('<foo></foo>')
      problem_record.add_record(record_xml)
      problem_record.save_xml
      file_with_record = File.open(file)
      expect(file_with_record.read).to match(/Record 333/)
      file_with_record.close
    end
  end
  describe '#problem_record' do
    it 'adds a record to the xml document' do
      problem_record.save_xml
      expect(File.exist?(problem_record.file_name.to_path)).to eq(true)
      problem_record.clean_up
      expect(File.exist?(problem_record.file_name.to_path)).to eq(false)
    end
  end
end
