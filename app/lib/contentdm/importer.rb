require 'nokogiri'

# An importer for ContentDM exported Metadata
module Contentdm
  class Importer
    attr_reader :doc, :records, :input_file, :data_path
    def initialize(input_file, data_path)
      @data_path = data_path
      @input_file = input_file
      @doc = File.open(input_file) { |f| Nokogiri::XML(f) }
      @records = @doc.xpath("//record")
      @collection = collection
      @log = Importer.logger
    end

    # Class level method, to be called, e.g., from a rake task
    # @example
    # Contentdm::Importer.import
    def self.import(input_file, data_path)
      Importer.new(input_file, data_path).import
    end

    def self.logger
      Logger.new(STDOUT)
    end

    def import
      @records.each do |record|
        begin
          work = process_record(record)
          @log.info Rainbow("Adding #{work.id} to collection: #{collection_name}")
        rescue
          @log.error Rainbow("Could not import record #{record}
").red
          Rails.logger.error "Could not import record #{record}"
        end
      end
      @collection.save
    end

    def document_count
      @records.count
    end

    def process_record(record)
      cdm_record = Contentdm::Record.new(record)
      # TODO: How to know whether a work is a Publication, DataSet, ConferenceProceeding, etc?
      @log.info "Creating new Publication for #{cdm_record.identifer}"
      work = work_model(cdm_record.work_type).new
      work.title = cdm_record.title
      work.creator = cdm_record.creators
      work.contributor = cdm_record.contributors
      work.subject = cdm_record.subjects
      work.description = cdm_record.descriptions
      work.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      save_work(cdm_record, work)
      @collection.add_members(work.id)
      work
    end

    ##
    # @return [Array<String>] this returns the name of the collection based on the XML
    def collection_name
      [@doc.xpath("//collection_name").text]
    end

    ##
    # @return [String] this returns the name of the folder that the collection's
    # files are stored in the folder specified during the import
    def collection_path
      collection_path = @doc.xpath("//collection_name").text.split(' ').join('_')
      "#{@data_path}/#{collection_path}"
    end

    ##
    # @return [ActiveFedora::Base] return the collection object
    def collection
      CollectionBuilder.new(collection_name).find_or_create
    end

    # Converts a class name into a class.
    # @param class_name [String] the type of work we want to create, 'Publication', 'ConferenceProceeding', or 'DataSet'.
    # @return [Class] return the work's class
    # @example If you pass in a string 'Publication', it returns the class ::Publication
    def work_model(class_name)
      # todo - don't hard-code Publication
      class_name.constantize || Publication
    rescue NameError
      raise "Invalid work type: #{class_name}"
    end

    private

      def save_work(cdm_record, work)
        importer_user = ::User.batch_user
        current_ability = ::Ability.new(importer_user)
        uploaded_file = Contentdm::ImportFile.new(cdm_record, collection_path, importer_user).uploaded_file
        attributes = { uploaded_files: [uploaded_file.id] }
        env = Hyrax::Actors::Environment.new(work, current_ability, attributes)
        if Hyrax::CurationConcern.actor.create(env) != false
          @log.info "Saved work with title: #{cdm_record.title[0]}"
        else
          @log.info Rainbow("Problem saving #{cdm_record.identifier}").red
        end
      end
  end
end
