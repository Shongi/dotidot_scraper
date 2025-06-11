require "rails_helper"

RSpec.describe ScraperController, type: :request do
  let(:url) { "https://www.alza.cz/aeg-7000-prosteam-lfr73964cc-d7635493.htm" }
  let(:fields) do
    {
      "rating_count" => ".ratingCount",
      "meta" => [ "keywords" ]
    }
  end
  let(:html_content) do
    <<~HTML
      <html>
        <head>
          <meta name="keywords" content="AEG,7000,ProSteam®,LFR73964CC,Automatické pračky,Automatické pračky AEG,Chytré pračky,Chytré pračky AEG">
        </head>
        <body>
          <span class="ratingCount">25 hodnocení</span>
        </body>
      </html>
    HTML
  end

  describe 'POST /data' do
    before do
      allow(URI).to receive(:open).and_return(StringIO.new(html_content))
      Rails.cache.clear
    end

    it "returns scraped data as JSON" do
      post "/data", params: { url: url, fields: fields }

      expect(response).to have_http_status(:ok)

      json = JSON.parse(response.body)
      expect(json["rating_count"]).to eq("25 hodnocení")
      expect(json["meta"]["keywords"]).to eq("AEG,7000,ProSteam®,LFR73964CC,Automatické pračky,Automatické pračky AEG,Chytré pračky,Chytré pračky AEG")
    end

    it "returns 400 when url is missing" do
      post "/data", params: { fields: fields }

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)["error"]).to match(/Missing/)
    end

    it "returns 400 when fields are missing" do
      post "/data", params: { url: url }

      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)["error"]).to match(/Missing/)
    end

    it "returns 500 on error" do
      allow(::ScrapePage).to receive(:call).and_raise(StandardError, "fail!")

      post "/data", params: { url: url, fields: fields }

      expect(response).to have_http_status(500)

      json = JSON.parse(response.body)
      expect(json["error"]).to eq("fail!")
    end
  end
end
