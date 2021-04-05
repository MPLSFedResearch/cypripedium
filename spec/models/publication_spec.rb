# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Publication do
  let(:work) { FactoryBot.build(:publication) }
  it_behaves_like 'a work with additional metadata'
  it "can set and retrieve a creator value" do
    publication = Publication.new
    publication.title = ["Some title, cuz it's required"]
    publication.creator = ["Alvarez, Fernando, 1964-"]
    publication.save!
    expect(publication.creator).to eq(["Alvarez, Fernando, 1964-"])
    expect(publication.creator).to be_an_instance_of ActiveTriples::Relation
  end
end
