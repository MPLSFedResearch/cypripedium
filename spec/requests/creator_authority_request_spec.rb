# frozen_string_literal: true

require 'rails_helper'

describe 'Creator authority', type: :request do
  before do
    creator_array = [
      {"id":"http://id.loc.gov/authorities/names/no2003126550","label":"Cagetti, Marco"},
      {"id":"https://ideas.repec.org/f/pca1299.html","label":"Cai, Zhifeng"},
      {"id":"https://ideas.repec.org/e/pca150.html","label":"Calsamiglia, Caterina"},
      {"id":"https://ideas.repec.org/f/pca694.html","label":"Calvo, Guillermo A."},
      {"id":"https://ideas.repec.org/f/pca371.html","label":"Camargo, Braz"},
      {"id":"https://ideas.repec.org/e/pca89.html","label":"Campbell, Jeffrey R."},
      {"id":"https://ideas.repec.org/e/pca50.html","label":"Canova, Fabio"},
      {"id":"https://ideas.repec.org/e/pca77.html","label":"Caplin, Andrew"},
      {"id":"https://ideas.repec.org/f/pca1029.html","label":"Carapella, Francesca"},
      {"id":"https://ideas.repec.org/e/pca42.html","label":"Carlstrom, Charles T., 1960-"},
      {"id":"https://ideas.repec.org/f/pca205.html","label":"Caselli, Francesco, 1966-"},
      {"id":"https://ideas.repec.org/e/pca73.html","label":"Caucutt, Elizabeth M. (Elizabeth Miriam)"},
      {"id":"https://ideas.repec.org/f/pca963.html","label":"Cavalcanti, Ricardo de Oliveira"}
    ]
    creator_array.each do |creator|
      Creator.create!(
        display_name: creator[:label]
      )
    end
  end

  describe "GET /authorities/search/local_names/creators" do
    it "returns http success" do
      get "/authorities/search/local_names/creators?q=Ca"
      expect(response).to have_http_status(:success)
      expect(response.content_type).to eq "application/json"
      json_body = JSON.parse(response.body)
      expect(json_body.count).to eq 13
      expect(json_body.first["display_name"]).to eq "Cagetti, Marco"
    end
    it "returns fewer responses for a longer string" do
      get "/authorities/search/local_names/creators?q=Cam"
      expect(response).to have_http_status(:success)
      json_body = JSON.parse(response.body)
      expect(json_body.count).to eq 2
      expect(json_body.first["display_name"]).to eq "Camargo, Braz"
    end

    it "can return an authority entry based on identifier" do
      # uri_identifier = Qa::LocalAuthorityEntry.first.uri
      # expect(uri_identifier).to eq "http://id.loc.gov/authorities/names/no2003126550"
      # uri_escaped = CGI.escape(uri_identifier)
      # puts uri_escaped

      get "/authorities/show/local_names/creators/#{Creator.first.id}"
      expect(response).to have_http_status(:success)
      expect(response.body).not_to be_empty
      expect(response.content_length).to be > 3
      json_body = JSON.parse(response.body)
      expect(json_body["display_name"]).to eq "Cagetti, Marco"
    end

    it "can fail gracefully when an id doesn't exist" do
      get "/authorities/show/local_names/creators/9999"
      expect(response).to have_http_status(:missing)
    end
  end
end
