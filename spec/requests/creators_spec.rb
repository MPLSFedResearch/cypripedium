# frozen_string_literal: true
require 'rails_helper'
include Warden::Test::Helpers
# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe "/creators", type: :request do
  let(:user) { FactoryBot.create(:admin) }
  before do
    login_as user
  end
  # Creator. As you add validations to Creator, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    { display_name: "A display name", alternate_names: ["Another name", "a third name"],
      repec: "Stuff", viaf: "Things", active: true }
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  describe "GET /index" do
    it "renders a successful response" do
      Creator.create! valid_attributes
      get creators_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      creator = Creator.create! valid_attributes
      get creator_url(creator)
      expect(response).to be_successful
    end

    it "renders a successful json response" do
      creator = Creator.create! valid_attributes
      get creator_url(creator), params: { format: :json }
      expect(response).to be_successful
      expect(response.content_type).to eq "application/json"
      expect(response.body).not_to be_empty
      expect(response.content_length).to be > 0
      response_values = JSON.parse(response.body)
      expect(response_values["display_name"]).to eq "A display name"
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_creator_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "render a successful response" do
      creator = Creator.create! valid_attributes
      get edit_creator_url(creator)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new Creator" do
        expect {
          post creators_url, params: { creator: valid_attributes }
        }.to change(Creator, :count).by(1)
      end

      it "redirects to the created creator" do
        post creators_url, params: { creator: valid_attributes }
        expect(response).to redirect_to(creator_url(Creator.last) + "?locale=en")
      end
    end

    context "with invalid parameters" do
      it "does not create a new Creator" do
        expect {
          post creators_url, params: { creator: invalid_attributes }
        }.to change(Creator, :count).by(0)
      end

      it "renders a successful response (i.e. to display the 'new' template)" do
        post creators_url, params: { creator: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        { display_name: "A new display name", alternate_names: ["Additional naming", "So many names"],
          repec: "12345", viaf: "6789", active: false }
      }

      it "updates the requested creator" do
        creator = Creator.create! valid_attributes
        patch creator_url(creator), params: { creator: new_attributes }
        creator.reload
        expect(creator.active).to be false
      end

      it "redirects to the creator" do
        creator = Creator.create! valid_attributes
        patch creator_url(creator), params: { creator: new_attributes }
        creator.reload
        expect(response).to redirect_to(creator_url(creator) + "?locale=en")
      end
    end

    context "with invalid parameters" do
      it "renders a successful response (i.e. to display the 'edit' template)" do
        creator = Creator.create! valid_attributes
        patch creator_url(creator), params: { creator: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end
end
