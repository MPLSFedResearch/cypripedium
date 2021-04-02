# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Creator, type: :model do
  it "has a ID" do
    creator = described_class.create(display_name: "Allen, Stephen G.")
    expect(creator.id).not_to be nil
    expect(creator.display_name).to eq "Allen, Stephen G."
  end
  it "doesn't allow an empty display_name" do
    expect do
      described_class.create
    end.to raise_error(ActiveRecord::NotNullViolation, /ERROR:  null value in column \"display_name\"/)
  end
  it "doesn't allow a blank display_name" do
    expect do
      described_class.create!(display_name: "")
    end.to raise_error(ActiveRecord::RecordInvalid, /Validation failed: Display name can't be blank/)
  end
  it "doesn't allow duplicate RePEc ids" do
    creator = described_class.create(display_name: "Allen, Stephen G.", repec: "pal73")
    expect do
      described_class.create!(display_name: "Allen, Stephen Gomes", repec: "pal73")
    end.to raise_error(ActiveRecord::RecordInvalid, /Validation failed: Repec id already in the system/)
  end
  it "doesn't allow duplicate VIAF ids" do
    creator = described_class.create(display_name: "Allen, Stephen G.", viaf: "789875")
    expect do
      described_class.create!(display_name: "Allen, Stephen Gomes", viaf: "789875")
    end.to raise_error(ActiveRecord::RecordInvalid, /Validation failed: Viaf id already in the system/)
  end
end
