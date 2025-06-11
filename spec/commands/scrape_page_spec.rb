require "rails_helper"

RSpec.describe ScrapePage do
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

  before { Rails.cache.clear }

  it "extracts regular fields" do
    expect(URI).to receive(:open).with(url).and_return(StringIO.new(html_content))

    result = described_class.new(url: url, fields: fields).call.result

    expect(result["rating_count"]).to eq("25 hodnocení")
  end

  it "extracts meta fields" do
    expect(URI).to receive(:open).with(url).and_return(StringIO.new(html_content))

    result = described_class.new(url: url, fields: fields).call.result

    expect(result["meta"]).to eq({ "keywords" => "AEG,7000,ProSteam®,LFR73964CC,Automatické pračky,Automatické pračky AEG,Chytré pračky,Chytré pračky AEG" })
  end

  it "returns nil for missing selectors and meta" do
    expect(URI).to receive(:open).with(url).and_return(StringIO.new(html_content))

    result = described_class.call(
      url: url,
      fields: {
        "missing" => ".notfound",
        "meta" => [ "notfound" ]
      }
    ).result

    expect(result["missing"]).to be_nil
    expect(result["meta"]["notfound"]).to be_nil
  end

  it "does not include meta if not requested" do
    expect(URI).to receive(:open).with(url).and_return(StringIO.new(html_content))

    result = described_class.call(url: url, fields: { "rating_count" => ".ratingCount" }).result

    expect(result).not_to have_key("meta")
  end

  it "uses cache on consecutive calls" do
    expect(URI).to receive(:open).with(url).once.and_return(StringIO.new(html_content))

    2.times do
      result = described_class.new(url: url, fields: fields).call.result
      expect(result["rating_count"]).to eq("25 hodnocení")
    end
  end
end
