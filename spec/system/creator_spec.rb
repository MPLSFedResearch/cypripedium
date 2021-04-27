# frozen_string_literal: true

require 'rails_helper'

include Warden::Test::Helpers

RSpec.describe 'Creators', type: :system, js: true do
  let(:creator) { Creator.create(display_name: "Cheese, The Big") }
  let(:creator_with_alternates) { Creator.create(display_name: "Allen, Stephen G.", alternate_names: ["Allen, S. Gomes", "Aliens, Steve"]) }

  context "as an unauthenticated user" do
    it "can show the index page" do
      creator
      creator_with_alternates
      visit "/creators"
      expect(page).to have_content(/Display name/i)
      expect(page).to have_content(/Alternate names/i)
      expect(page).to have_content("Cheese, The Big", count: 1)
      expect(page).to have_content('Allen, S. Gomes ; Aliens, Steve')
      expect(page).not_to have_link("Edit")
    end

    it "cannot navigate to the new page" do
      visit "/creators/new"
      expect(page).to have_content("You are not authorized to access this page")
    end
  end
  context "as an admin" do
    let(:admin_user) { FactoryBot.create(:admin) }
    before do
      login_as admin_user
    end
    it "can show the index page" do
      creator
      visit "/creators"
      expect(page).to have_content(/ID/i)
      expect(page).to have_content(/Display name/i)
      expect(page).to have_content(/Alternate names/i)
      expect(page).to have_content("Cheese, The Big", count: 1)
      within(".display_name") do
        expect(page).to have_content("Cheese, The Big")
      end
      within(".alternate_names") do
        expect(page).not_to have_content("[]")
      end
      expect(page).to have_link("Edit")
    end
    it "can create a new creator record" do
      visit "/creators/new"
      expect(page).to have_field("Display name")
      expect(page).to have_field("Alternate names")
      fill_in "Display name", with: "Allen, Stephen G."
      fill_in "Alternate names", with: "Allen, S. Gomes"
      click_button("Add another Alternate names")
      find(:xpath, "//div[3]/form/div[2]/ul/li[2]/input").set("Aliens, Steve")
      click_on "Save"
      expect(page).to have_content('Allen, S. Gomes ; Aliens, Steve')
      expect(Creator.first.alternate_names).to eq ["Allen, S. Gomes", "Aliens, Steve"]
    end
    it "has a dashboard link to manage creators" do
      visit "/dashboard"
      expect(page).to have_link("Manage Embargoes")
      expect(page).to have_link("Manage Creators")
      click_on "Manage Creators"
      expect(page).to have_content(/ID/i)
      expect(page).to have_content(/Display name/i)
      expect(page).to have_content(/Alternate names/i)
    end
    it "can edit an existing creator" do
      creator
      visit "/creators/#{creator.id}/edit"
      expect(page).to have_field("Display name")
      expect(page).to have_field("Alternate names")
      expect(page).to have_field("Repec")
      expect(page).to have_field("Viaf")
      fill_in "Alternate names", with: "Cheese, Delicious"
      click_button("Add another Alternate names")
      find(:xpath, "//div[3]/form/div[2]/ul/li[2]/input").set("Cheese, Delectable")
      click_on "Save"
      expect(creator.reload.alternate_names).to eq ["Cheese, Delicious", "Cheese, Delectable"]
    end
    it "does not do weird things to the Alternate names array" do
      creator_with_alternates
      visit "/creators/#{creator_with_alternates.id}/edit"
      expect(page.find(:xpath, "//div[3]/form/div[2]/ul/li[1]/input").value).to eq "Allen, S. Gomes"
      expect(page.find(:xpath, "//div[3]/form/div[2]/ul/li[2]/input").value).to eq "Aliens, Steve"
      
      click_on "Save"
      expect(creator_with_alternates.reload.alternate_names).to eq ["Allen, S. Gomes", "Aliens, Steve"]
    end
  end
end
